#include "PapyrusFFUtils.h"

#include "common/IFileStream.h"

#include "skse/GameAPI.h"
#include "skse/GameFormComponents.h"
#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include "skse/GameExtraData.h"
#include "skse/GameForms.h"
#include "skse/PapyrusArgs.h"
//#include "skse/PapyrusGame.h"
//#include "skse/PapyrusObjectReference.h"
#include "skse/NiNodes.h"

#include "ziputils\unzip.h"
#include "ziputils\zip.h"

#include <shlobj.h>
#include <functional>
#include <random>
#include <vector>
#include <map>

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

// probably shouldn't use this, it has problems
void VisitNIFNodes(NiNode * thisNode, std::function<void(NiNode*)> functor) 
{
	if (thisNode)
	{ 
		//make sure this is actually an ninode pointer, these values are equal in every one I've examined
		if (thisNode->m_children.m_arrayBufLen == thisNode->m_children.m_size)
		{
			for (int i = 0; i < thisNode->m_children.m_size; i++)
			{
				NiNode* childNode = NULL;
				if (!(thisNode->m_children.m_data[i] == NULL))
					childNode = (NiNode*)thisNode->m_children.m_data[i];

				if (childNode) {
					if (childNode->m_children.m_size)
						VisitNIFNodes(childNode, functor);
					functor(childNode);
				}
			}
		}
	}
}

bool isReadable(const std::string& name) {
	FILE *file;
	
	if (fopen_s(&file, name.c_str(), "r") == 0) {
		fclose(file);
		return true;
	}
	else {
		return false;
	}
}

std::string GetFFDirectory()
{
	char path[MAX_PATH];
	if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYDOCUMENTS | CSIDL_FLAG_CREATE, NULL, SHGFP_TYPE_CURRENT, path)))
	{
		return std::string();
	}
	strcat_s(path, sizeof(path), "/My Games/Skyrim/FamiliarFaces/");
	return path;
}

UInt32 FFCopyFile(LPCSTR lpExistingFileName, LPCSTR lpNewFileName)
{
	UInt32 ret = 0;
	if (!isReadable(lpExistingFileName))
	{
		return ERROR_FILE_NOT_FOUND;
	}
	IFileStream::MakeAllDirs(lpNewFileName);
	if (!CopyFile(lpExistingFileName, lpNewFileName, false)) {
		UInt32 lastError = GetLastError();
		ret = lastError;
		switch (lastError) {
		case ERROR_FILE_NOT_FOUND: // We don't need to display a message for this
			break;
		default:
			_ERROR("%s - error copying file %s (Error %d)", __FUNCTION__, lpExistingFileName, lastError);
			break;
		}
	}
	return ret;
}

bool IsObjectFavorited(TESForm * form)
{
	PlayerCharacter* player = (*g_thePlayer);
	if (!player || !form)
		return false;

	UInt8 formType = form->formType;

	// Spell or shout - check MagicFavorites
	if (formType == kFormType_Spell || formType == kFormType_Shout)
	{
		MagicFavorites * magicFavorites = MagicFavorites::GetSingleton();

		return magicFavorites && magicFavorites->IsFavorited(form);
	}
	// Other - check ExtraHotkey. Any hotkey data (including -1) means favorited
	else
	{
		bool result = false;

		ExtraContainerChanges* pContainerChanges = static_cast<ExtraContainerChanges*>(player->extraData.GetByType(kExtraData_ContainerChanges));
		if (pContainerChanges) {
			HotkeyData data = pContainerChanges->FindHotkey(form);
			if (data.pHotkey)
				result = true;
		}

		return result;
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

	void LoadCharacterSpells(StaticFunctionTag*, TESNPC* actorBase, BGSListForm* spellFormList)
	{
		if (actorBase && spellFormList) {
			UInt32 spellCount = 0;
			VisitFormList(spellFormList, [&](TESForm * form){
				if (DYNAMIC_CAST(form, TESForm, SpellItem)) {
					spellCount++;
				}
			});

			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;
			
			if (spellCount > 0) {
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
				SpellItem ** spellArray = (SpellItem **)FormHeap_Allocate(spellCount * sizeof(SpellItem*));
				VisitFormList(spellFormList, [&](TESForm * form){
					if (SpellItem * spell = DYNAMIC_CAST(form, TESForm, SpellItem)) {
						spellArray[i] = spell;
						i++;
					}
				});

				spellData->spells = spellArray;
				spellData->numShouts = spellCount;
			}
			else {
				spellData->spells = NULL;
				spellData->numShouts = 0;
			}
		}
	}
	
	VMResultArray<TESForm*> GetActorSpellList(StaticFunctionTag*, Actor* character, bool includeBaseSpells)
	{
		VMResultArray<TESForm*> result;
		TESNPC* actorBase = DYNAMIC_CAST(character->baseForm, TESForm, TESNPC);
		if (actorBase) {
			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;

			if (spellData && includeBaseSpells)
			{
				if (spellData->spells)
				{
					// Add spells from the actorbase
					for (int i = 0; i < spellData->numSpells; i++)
					{
						result.push_back(spellData->spells[i]);
					}
				}
			}

			if (character->addedSpells.Length())
			{
				// Add spells from the actor's own list
				for (int i = 0; i < character->addedSpells.Length(); i++)
				{
					result.push_back(character->addedSpells.Get(i));
				}
			}
		}
		return result;
	}

	void GetCharacterSpells(StaticFunctionTag*, Actor* character,  BGSListForm * list, bool includeBase)
	{
		TESNPC* actorBase = DYNAMIC_CAST(character->baseForm, TESForm, TESNPC);
		if (actorBase && includeBase) {
			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;

			if (spellData)
			{
				if (spellData->spells)
				{
					// Add spells from the actorbase
					for (int i = 0; i < spellData->numSpells; i++)
					{
						CALL_MEMBER_FN(list, AddFormToList)(spellData->spells[i]);
					}
				}
			}
			
			// Add spells from the actor's own list
			for (int i = 0; i < character->addedSpells.Length(); i++)
			{
				CALL_MEMBER_FN(list, AddFormToList)(character->addedSpells.Get(i));
			}
		}
	}

	VMResultArray<TESForm*> GetActorShoutList(StaticFunctionTag*, TESNPC* actorBase)
	{
		VMResultArray<TESForm*> result;
		if (actorBase) {
			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;
			
			if (spellData)
			{
				if (spellData->shouts)
				{
					// Add shouts from the actorbase
					for (int i = 0; i < spellData->numShouts; i++)
					{
						if (TESShout * shout = DYNAMIC_CAST(spellData->shouts[i], TESForm, TESShout)) {
							result.push_back(shout);
						}
					}
				}
			}

		}
		return result;
	}

	void GetCharacterShouts(StaticFunctionTag*, Actor* character, BGSListForm * list)
	{
		TESNPC* actorBase = DYNAMIC_CAST(character->baseForm, TESForm, TESNPC);

		if (actorBase) {
			TESSpellList * spellList = &actorBase->spellList;
			TESSpellList::Data * spellData = spellList->unk04;

			if (spellData)
			{
				if (spellData->shouts)
				{
					// Add shouts from the actorbase
					for (int i = 0; i < spellData->numShouts; i++)
					{
						CALL_MEMBER_FN(list, AddFormToList)(spellData->shouts[i]);
					}
				}
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
	
	SInt32 BuildCharacterPackage(StaticFunctionTag*, BSFixedString characterName)
	{
		SInt32 ret = 0;

		HZIP hz;

		char ddsPath[MAX_PATH];
		char jslotPath[MAX_PATH];
		char nifPath[MAX_PATH];
		char jsonPath[MAX_PATH];
		
		char exportPath[MAX_PATH];
		char sourcePath[MAX_PATH];
		char targetPath[MAX_PATH];
		
		char zipFilename[MAX_PATH];

		sprintf_s(ddsPath, "Textures\\CharGen\\Exported\\%s.dds", characterName);
		sprintf_s(nifPath, "Meshes\\CharGen\\Exported\\%s.nif", characterName);
		sprintf_s(jslotPath, "SKSE\\Plugins\\CharGen\\Exported\\%s.jslot", characterName);
		sprintf_s(jsonPath, "vMYC\\%s.char.json", characterName);

		sprintf_s(exportPath, "%sExported\\%s\\", GetFFDirectory().data(), characterName);
		
		sprintf_s(zipFilename, "%sExported\\%s.zip", GetFFDirectory().data(), characterName);

		IFileStream::MakeAllDirs(zipFilename);
		hz = CreateZip(zipFilename, 0); //Create new zip with no password

		sprintf_s(sourcePath, "Data/%s", ddsPath);
		sprintf_s(targetPath, "%s/%s", exportPath, ddsPath);
		ZipAdd(hz, ddsPath, sourcePath);
		//FFCopyFile(sourcePath, targetPath);

		sprintf_s(sourcePath, "Data/%s", nifPath);
		sprintf_s(targetPath, "%s/%s", exportPath, nifPath);
		ZipAdd(hz, nifPath, sourcePath);
		//FFCopyFile(sourcePath, targetPath);

		sprintf_s(sourcePath, "Data/%s", jslotPath);
		sprintf_s(targetPath, "%s/%s", exportPath, jslotPath);
		ZipAdd(hz, jslotPath, sourcePath);
		//FFCopyFile(sourcePath, targetPath);
		
		sprintf_s(sourcePath, "Data/%s", jsonPath);
		sprintf_s(targetPath, "%s/%s", exportPath, jsonPath);
		ZipAdd(hz, jsonPath, sourcePath);
		//FFCopyFile(sourcePath, targetPath);
		
		CloseZip(hz);

		return ret;
	}

	BSFixedString userDirectory(StaticFunctionTag*) {
		return GetFFDirectory().c_str();
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

	SInt32 FilterFormlist(StaticFunctionTag*, BGSListForm* sourceList, BGSListForm* filteredList, UInt32 typeFilter)
	{
		SInt32 formCount = 0;
		if (sourceList && filteredList) {
			VisitFormList(sourceList, [&](TESForm * form){
				if (form->formType == typeFilter) {
					formCount++;
					CALL_MEMBER_FN(filteredList, AddFormToList)(form);
				}
			});
		}
		return formCount;
	}

	VMResultArray<TESForm*> GetFilteredList(StaticFunctionTag*, BGSListForm* sourceList, UInt32 typeFilter)
	{
		VMResultArray<TESForm*> result;
		if (sourceList) {
			VisitFormList(sourceList, [&](TESForm * form){
				if (form->formType == typeFilter) {
					result.push_back(form);
				}
			});
		}
		return result;
	}

	VMResultArray<SInt32> GetItemCounts(StaticFunctionTag*, VMArray<TESForm*> formArr, TESObjectREFR* object)
	{
		VMResultArray<SInt32> result;

		TESContainer* pContainer = NULL;
		TESForm* pBaseForm = object->baseForm;
		if (pBaseForm)
			pContainer = DYNAMIC_CAST(pBaseForm, TESForm, TESContainer);

		ExtraContainerChanges* pXContainerChanges = static_cast<ExtraContainerChanges*>(object->extraData.GetByType(kExtraData_ContainerChanges));

		TESForm *form = NULL;

		if (formArr.Length() && object) {
			for (int i = 0; i < formArr.Length(); i++) {
				formArr.Get(&form, i);
				if (form) {
					UInt32 countBase = pContainer->CountItem(form);
					ExtraContainerChanges::EntryData *entrydata = pXContainerChanges->data->FindItemEntry(form);
					UInt32 countXtra = (entrydata) ? entrydata->countDelta : 0;
					result.push_back(countBase + countXtra);
				}
			}
		}

		return result;
	}

	VMResultArray<SInt32> GetItemTypes(StaticFunctionTag*, VMArray<TESForm*> formArr)
	{
		VMResultArray<SInt32> result;

		TESForm *form = NULL;

		if (formArr.Length()) {
			for (int i = 0; i < formArr.Length(); i++) {
				formArr.Get(&form, i);
				if (form) {
					result.push_back(form->formType);
				}
			}
		}

		return result;
	}

	VMResultArray<BSFixedString> GetItemNames(StaticFunctionTag*, VMArray<TESForm*> formArr)
	{
		VMResultArray<BSFixedString> result;

		TESForm *form = NULL;

		if (formArr.Length()) {
			for (int i = 0; i < formArr.Length(); i++) {
				formArr.Get(&form, i);
				if (form) {
					TESFullName* pFullName = DYNAMIC_CAST(form, TESForm, TESFullName);
					result.push_back(pFullName->name.data);
				}
			}
		}

		return result;
	}

	VMResultArray<SInt32> GetItemFavorited(StaticFunctionTag* base, VMArray<TESForm*> formArr)
	{
		VMResultArray<SInt32> result;
		TESForm *form = NULL;

		if (formArr.Length()) {
			for (int i = 0; i < formArr.Length(); i++) {
				formArr.Get(&form, i);
				if (form) {
					result.push_back(IsObjectFavorited(form));
				}
			}
		}

		return result;
	}

	VMResultArray<SInt32> GetItemHasExtraData(StaticFunctionTag*, VMArray<TESForm*> formArr)
	{
		VMResultArray<SInt32> result;

		TESForm *form = NULL;

		PlayerCharacter* player = (*g_thePlayer);
		if (!player)
			return result;
		
		ExtraContainerChanges* pContainerChanges = static_cast<ExtraContainerChanges*>(player->extraData.GetByType(kExtraData_ContainerChanges));
		
		if (formArr.Length()) {
			for (int i = 0; i < formArr.Length(); i++) {
				formArr.Get(&form, i);
				int thisResult = 0;
				if (form) {
					ExtraContainerChanges::EntryData * formEntryData = pContainerChanges->data->FindItemEntry(form);
					//TESFullName* pFullName = DYNAMIC_CAST(form, TESForm, TESFullName);
					//_MESSAGE("Dumping extendDataList for form %08X (%s)-------", form->formID, (pFullName) ? pFullName->name.data : 0);
					if (formEntryData) {
						if (formEntryData->extendDataList->Count())
							thisResult = 1;
					}
					//_MESSAGE("------------------------------------------------", form->formID, (pFullName) ? pFullName->name.data : 0);
				}
				result.push_back(thisResult);
			}
		}

		return result;
	}

	BSFixedString GetSourceMod(StaticFunctionTag*, TESForm* form)
	{
		if (!form)
		{
			return NULL;
		}
		UInt8 modIndex = form->formID >> 24;
		if (modIndex > 255)
		{
			return NULL;
		}
		DataHandler* pDataHandler = DataHandler::GetSingleton();
		ModInfo* modInfo = pDataHandler->modList.modInfoList.GetNthItem(modIndex);
		return (modInfo) ? modInfo->name : NULL;
	}

	BSFixedString ReadStringFromFile(StaticFunctionTag*, BSFixedString path)
	{
		BSFixedString retString;

		IFileStream	fileToRead;

		std::string fileString;

		if (fileToRead.Open(path.data))
		{
			while (!fileToRead.HitEOF())
			{
				char buf[512];
				fileToRead.ReadString(buf, 512);
				fileString.append(buf);
			}
			retString = fileString.c_str();
		}
		fileToRead.Close();

		return retString;
	}

	//purely a learning exercise, don't actually use this
	VMResultArray<BSFixedString> GetNodeList(StaticFunctionTag*, TESForm * form)
	{
		VMResultArray<BSFixedString> ret;

		PlayerCharacter* player = (*g_thePlayer);
		
		NiNode * thisNode = player->GetNiNode();
		
		VisitNIFNodes(thisNode, [&](NiNode * childNode){
			if (childNode) {
				if (childNode->m_name)
					ret.push_back(childNode->m_name);
			}
		});

		return ret;
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
		new NativeFunction2<StaticFunctionTag, void, TESNPC*, BGSListForm*>("LoadCharacterSpells", "FFUtils", papyrusFFUtils::LoadCharacterSpells, registry));

	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, Actor*, BGSListForm*, bool>("GetCharacterSpells", "FFUtils", papyrusFFUtils::GetCharacterSpells, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, VMResultArray<TESForm*>, Actor*, bool>("GetActorSpellList", "FFUtils", papyrusFFUtils::GetActorSpellList, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, Actor*, BGSListForm*>("GetCharacterShouts", "FFUtils", papyrusFFUtils::GetCharacterShouts, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<TESForm*>, TESNPC*>("GetActorShoutList", "FFUtils", papyrusFFUtils::GetActorShoutList, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, SInt32, TESNPC*>("DeleteFaceGenData", "FFUtils", papyrusFFUtils::DeleteFaceGenData, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, BSFixedString>("TraceConsole", "FFUtils", papyrusFFUtils::TraceConsole, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("userDirectory", "FFUtils", papyrusFFUtils::userDirectory, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("UUID", "FFUtils", papyrusFFUtils::UUID, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, SInt32, BSFixedString>("BuildCharacterPackage", "FFUtils", papyrusFFUtils::BuildCharacterPackage, registry));

	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, SInt32, BGSListForm*, BGSListForm*, UInt32>("FilterFormlist", "FFUtils", papyrusFFUtils::FilterFormlist, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, BSFixedString, TESForm*>("GetSourceMod", "FFUtils", papyrusFFUtils::GetSourceMod, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, VMResultArray<TESForm*>, BGSListForm*, UInt32>("GetFilteredList", "FFUtils", papyrusFFUtils::GetFilteredList, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, VMResultArray<SInt32>, VMArray<TESForm*>, TESObjectREFR*>("GetItemCounts", "FFUtils", papyrusFFUtils::GetItemCounts, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<SInt32>, VMArray<TESForm*>>("GetItemTypes", "FFUtils", papyrusFFUtils::GetItemTypes, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<SInt32>, VMArray<TESForm*>>("GetItemFavorited", "FFUtils", papyrusFFUtils::GetItemFavorited, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<SInt32>, VMArray<TESForm*>>("GetItemHasExtraData", "FFUtils", papyrusFFUtils::GetItemHasExtraData, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<BSFixedString>, VMArray<TESForm*>>("GetItemNames", "FFUtils", papyrusFFUtils::GetItemNames, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("ReadStringFromFile", "FFUtils", papyrusFFUtils::ReadStringFromFile, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<BSFixedString>, TESForm*>("GetNodeList", "FFUtils", papyrusFFUtils::GetNodeList, registry));

}
