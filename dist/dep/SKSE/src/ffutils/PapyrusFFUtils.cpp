#include "PapyrusFFUtils.h"

#include "skse/GameAPI.h"
#include "skse/GameFormComponents.h"
#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include "skse/GameForms.h"
#include "skse/GameObjects.h"
#include "skse/GameReferences.h"

#include <functional>
#include <random>

void VisitFormList(BGSListForm * formList, std::function<void(TESForm*)> functor)
{
	for (int i = 0; i < formList->forms.count; i++)
	{
		TESForm* childForm = NULL;
		if (formList->forms.GetNthItem(i, childForm))
			functor(childForm);
	}

	// Script Added Forms
	if (formList->addedForms) {
		for (int i = 0; i < formList->addedForms->count; i++) {
			UInt32 formid = 0;
			formList->addedForms->GetNthItem(i, formid);
			TESForm* childForm = LookupFormByID(formid);
			if (childForm)
				functor(childForm);
		}
	}
}

namespace papyrusFFUtils
{
	void LoadCharacterPerks(StaticFunctionTag*, TESNPC* actorBase, BGSListForm* perkList)
	{
		if (actorBase && perkList) {
			UInt32 perkCount = 0;
			VisitFormList(perkList, [&](TESForm * form){
				if (DYNAMIC_CAST(form, TESForm, BGSPerk)) {
					perkCount++;
				}
			});

			if (actorBase->perkRanks.perkRanks)
				FormHeap_Free(actorBase->perkRanks.perkRanks);

			if (perkCount > 0) {
				UInt32 i = 0;
				BGSPerkRankArray::Data * perkData = (BGSPerkRankArray::Data *)FormHeap_Allocate(perkCount * sizeof(BGSPerkRankArray::Data));
				VisitFormList(perkList, [&](TESForm * form){
					if (BGSPerk * perk = DYNAMIC_CAST(form, TESForm, BGSPerk)) {
						perkData[i].perk = perk;
						perkData[i].rank = 1;
						i++;
					}
				});

				actorBase->perkRanks.perkRanks = perkData;
				actorBase->perkRanks.numPerkRanks = perkCount;
			}
			else {
				actorBase->perkRanks.perkRanks = NULL;
				actorBase->perkRanks.numPerkRanks = 0;
			}
		}
	}

	void LoadCharacterShouts(StaticFunctionTag*, TESNPC* actorBase, BGSListForm* shoutList)
	{
		if (actorBase && shoutList) {
			UInt32 shoutCount = 0;
			VisitFormList(shoutList, [&](TESForm * form){
				if (DYNAMIC_CAST(form, TESForm, TESShout)) {
					shoutCount++;
				}
			});

			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;

			if (shoutCount > 0) {
				// Have spellData, free the shouts
				if (spellData) {
					if (spellData->shouts)
						FormHeap_Free(spellData->shouts);
				}

				// No spellData? Create it
				if (!spellData) {
					spellData = (TESSpellList::Data *)FormHeap_Allocate(sizeof(TESSpellList::Data));
					spellData->spells = NULL;
					spellData->shouts = NULL;
					spellData->unk4 = NULL;
					spellData->numSpells = 0;
					spellData->numShouts = 0;
					spellData->numUnk4 = 0;
					spellList->unk04 = spellData;
				}

				// Create the shout list
				UInt32 i = 0;
				TESShout ** shoutArray = (TESShout **)FormHeap_Allocate(shoutCount * sizeof(TESShout*));
				VisitFormList(shoutList, [&](TESForm * form){
					if (TESShout * shout = DYNAMIC_CAST(form, TESForm, TESShout)) {
						shoutArray[i] = shout;
						i++;
					}
				});

				spellData->shouts = shoutArray;
				spellData->numShouts = shoutCount;
			}
			else {
				spellData->shouts = NULL;
				spellData->numShouts = 0;
			}
		}
	}

	SInt32 DeleteFaceGenData(StaticFunctionTag*, TESNPC * npc)
	{
		SInt32 ret = 0;
		if (!npc) {
			_ERROR("%s - invalid actorbase.", __FUNCTION__);
			return -1;
		}

		char * modName = NULL;
		UInt8 modIndex = npc->formID >> 24;
		UInt32 modForm = (npc->formID & 0xFFFFFF);
		DataHandler * dataHandler = DataHandler::GetSingleton();
		if (dataHandler) {
			ModInfo * modInfo = dataHandler->modList.modInfoList.GetNthItem(modIndex);
			if (modInfo)
				modName = modInfo->name;
		}

		enum
		{
			kReturnDeletedNif = 1,
			kReturnDeletedDDS = 2
		};

		char tempPath[MAX_PATH];
		sprintf_s(tempPath, "Data\\Meshes\\Actors\\Character\\FaceGenData\\FaceGeom\\%s\\%08X.nif", modName, modForm);
		if (!DeleteFile(tempPath)) {
			UInt32 lastError = GetLastError();
			switch (lastError) {
			case ERROR_FILE_NOT_FOUND: // We don't need to display a message for this
				break;
			case ERROR_ACCESS_DENIED:
				_ERROR("%s - access denied could not delete %s", __FUNCTION__, tempPath);
				break;
			default:
				_ERROR("%s - error deleting file %s (Error %d)", __FUNCTION__, tempPath, lastError);
				break;
			}
		}
		else
			ret |= kReturnDeletedNif;

		sprintf_s(tempPath, "Data\\Textures\\Actors\\Character\\FaceGenData\\FaceTint\\%s\\%08X.dds", modName, modForm);
		if (!DeleteFile(tempPath)) {
			UInt32 lastError = GetLastError();
			switch (lastError) {
			case ERROR_FILE_NOT_FOUND: // We don't need to display a message for this
				break;
			case ERROR_ACCESS_DENIED:
				_ERROR("%s - access denied could not delete %s", __FUNCTION__, tempPath);
				break;
			default:
				_ERROR("%s - error deleting file %s (Error %d)", __FUNCTION__, tempPath, lastError);
				break;
			}
		}
		else
			ret |= kReturnDeletedDDS;

		return ret;
	}
	
	void TraceConsole(StaticFunctionTag*, BSFixedString theString)
	{
		Console_Print(theString.data);
	}
	
	BSFixedString UUID(StaticFunctionTag*)
	{
		int bytes[16];
		std::string s;
		std::random_device rd;
		std::mt19937 generator;
		std::uniform_int_distribution<int> distByte(0, 255);
		generator.seed(rd());
		for (int i = 0; i < 16; i++) {
			bytes[i] = distByte(generator);
		}
		bytes[6] &= 0x0f;
		bytes[6] |= 0x40;
		bytes[8] &= 0x3f;
		bytes[8] |= 0x80;
		char thisOctet[4];
		for (int i = 0; i < 16; i++) {
			sprintf_s(thisOctet, "%02x", bytes[i]);
			s += thisOctet;
		}
		s.insert(20, "-");
		s.insert(16, "-");
		s.insert(12, "-");
		s.insert(8, "-");
		return s.c_str();
	}
}

#include "skse/PapyrusVM.h"
#include "skse/PapyrusNativeFunctions.h"

void papyrusFFUtils::RegisterFuncs(VMClassRegistry* registry)
{
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, TESNPC*, BGSListForm*>("LoadCharacterPerks", "FFUtils", papyrusFFUtils::LoadCharacterPerks, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, TESNPC*, BGSListForm*>("LoadCharacterShouts", "FFUtils", papyrusFFUtils::LoadCharacterShouts, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, SInt32, TESNPC*>("DeleteFaceGenData", "FFUtils", papyrusFFUtils::DeleteFaceGenData, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, BSFixedString>("TraceConsole", "FFUtils", papyrusFFUtils::TraceConsole, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("UUID", "FFUtils", papyrusFFUtils::UUID, registry));

}
