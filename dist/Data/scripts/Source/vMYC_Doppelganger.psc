Scriptname vMYC_Doppelganger extends Actor
{Apply character appearance, handle inventory import, etc.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

;=== Properties ===--

Bool Property IsAvailable Hidden
{Return whether this actor has been assigned a character.}
	Bool Function Get()
		If GetState() == "Available"
			Return True
		Else
			Return False
		EndIf
	EndFunction
EndProperty

String Property ScriptState Hidden
{Return this actor's script state.}
	String Function Get()
		Return GetState()
	EndFunction
EndProperty

vMYC_DataManager	Property DataManager							Auto

Bool 				Property NeedAppearance	= False 				Auto Hidden
Bool 				Property NeedPerks		= False 				Auto Hidden
Bool 				Property NeedSpells		= False 				Auto Hidden
Bool 				Property NeedEquipment	= False 				Auto Hidden
Bool 				Property NeedInventory	= False 				Auto Hidden
Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden
Bool 				Property IsCharGenBusy	= False 				Auto Hidden
Bool 				Property IsInCity		= False 				Auto Hidden
Bool				Property IsRaceInvalid	= False					Auto Hidden

String 				Property CharacterName	= ""					Auto Hidden
String 				Property CharacterUUID	= ""					Auto Hidden
Race				Property CharacterRace	= None					Auto Hidden

Actor 				Property PlayerREF 									Auto
Armor 				Property vMYC_DummyArmor							Auto
EffectShader 		Property vMYC_BlindingLightGold						Auto
Explosion 			Property vMYC_CharacterDeathExplosion				Auto
VisualEffect		Property vMYC_ValorFX								Auto
VisualEffect		Property DA02SummonValorTargetFX					Auto
ImageSpaceModifier	Property ISMDwhiteoutFULLthenFade					Auto
Sound				Property NPCDragonDeathFX2D							Auto
Sound				Property NPCDragonDeathSequenceExplosion			Auto
FormList 			Property vMYC_CombatStyles 							Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Safe 		Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Unsafe 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Healing 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Armor 		Auto
Message 			Property vMYC_VoiceTypeNoFollower 					Auto
Message 			Property vMYC_VoiceTypeNoSpouse						Auto

;=== Variables ===--

ActorBase 	_kActorBase 				= None
		
Bool 		_bFirstLoad 				= True
				
String[] 	_sSkillNames

Float 		_fDecapitationChance

Int 		_iMagicUpdateCounter

Float 		_fOrphanedTime
Bool 		_bOrphaned

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int 		_iCharGenVersion

Int			_jCharacterData

String 		_sCharacterInfo

String		_sFormID

;=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
EndEvent

Auto State Available
	Event OnLoad()
		;Clear out because we shouldn't be loaded
	EndEvent
	
	Function AssignCharacter(String sUUID)
	{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
		GoToState("Busy")
		_jCharacterData = GetRegObj("Characters." + sUUID)
		_sCharacterInfo = "Characters." + sUUID + ".Info."
		SaveSession()
		If !_jCharacterData
			DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, but there's no data for that UUID!")
			GotoState("Available")
			Return
		EndIf
		DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, transforming into " + GetRegStr(_sCharacterInfo + "Name") + "!")
		SetRegForm("Doppelgangers.Preferred." + sUUID + ".ActorBase",_kActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".ActorBase",_kActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".Actor",Self as Actor)
		CharacterName = GetRegStr(_sCharacterInfo + "Name")
		CharacterRace = GetRegForm(_sCharacterInfo + "Race") as Race
		_kActorBase.SetName(CharacterName)
		NeedAppearance	= True
		NeedPerks		= True
		NeedSpells		= True
		NeedEquipment	= True
		NeedInventory	= True
		NeedRefresh 	= True
		NeedUpkeep		= True
		GotoState("Assigned")
	EndFunction
EndState

State Assigned
	Event OnBeginState()
		DebugTrace("Entered Assigned state! CharacterName is " + CharacterName + ". Will update appearance, etc in just a sec...")
		RegisterForSingleUpdate(1)
		SetNameIfNeeded()
	EndEvent

	Event OnUpdate()
		If NeedInventory 
			If UpdateInventory() >= 0
				NeedInventory = False
			EndIf
			; Adding items usually makes the target unequip gear, so make sure it's back on.
			If !NeedEquipment
				EquipDefaultGear() 
			EndIf
		EndIf
		If NeedAppearance
			If UpdateAppearance() == 0 ; No error
				UpdateNINodes()
				NeedAppearance = False
			EndIf
		EndIf
		If NeedEquipment
			Int bResultArmor = UpdateArmor()
			Int bResultWeapons = UpdateWeapons()
			If bResultArmor >= 0 && bResultWeapons >= 0 ; No error
				NeedEquipment = False
			EndIf
		EndIf
	EndEvent

	Event OnLoad()
		
	EndEvent
EndState

State Busy

EndState

Function AssignCharacter(String sUUID)
{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
	DebugTrace("AssignCharacter(" + sUUID + ") was called outside of Available state, doing nothing!",1)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game. Sets the name and such.}
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	IsBusy = True
	;DebugTrace("MYC/Actor/" + CharacterName + ": Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	If IsRaceInvalid 
		; Reset the race during upkeep in case the needed mod has been installed
		CharacterRace = None
		IsRaceInvalid = False
	EndIf
	;CheckVars()
	;SyncCharacterData()
	If !HasSessionKey(CharacterName + ".Shouts.Allow")
		SetSessionBool(CharacterName + ".Shouts.Allow",True) ; allow shouts by default
	EndIf
;	SetNonpersistent()
	If _iCharGenVersion == 3
;		RefreshMeshNewCG()
	EndIf
;	_bWarnedVoiceTypeNoFollower = False
	;_bWarnedVoiceTypeNoSpouse = False
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	;DebugTrace("MYC/Actor/" + CharacterName + ": finished upkeep!")
	If !PlayerREF.HasLos(Self)
		RegisterForSingleLOSGain(PlayerREF,Self)
	EndIf
EndFunction

Function SetNameIfNeeded(Bool abForce = False)
	If (CharacterName && _kActorBase.GetName() != CharacterName) || abForce
		DebugTrace("Setting actorbase name!")
		_kActorBase.SetName(CharacterName)
		SetName(CharacterName)
		;FIXME: This will need to be reenabled, just disabling now to simply things
		;Int i = GetNumReferenceAliases()
		;While i > 0
		;	i -= 1
		;	ReferenceAlias kThisRefAlias = GetNthReferenceAlias(i)
		;	;If kThisRefAlias.GetOwningQuest() != CharacterManager && kThisRefAlias.GetOwningQuest() != ShrineOfHeroes
		;		DebugTrace("Resetting RefAlias " + kThisRefAlias + "!")
		;		kThisRefAlias.TryToClear()
		;		kThisRefAlias.ForceRefIfEmpty(Self)
		;	;EndIf
		;EndWhile
		SendModEvent("vMYC_UpdateXFLPanel")
	EndIf
EndFunction

;=== Appearance functions ===--

Int Function UpdateAppearance()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateAppearance called outside Assigned state!")
		Return -2
	EndIf
	Bool _bInvulnerableState = _kActorBase.IsInvulnerable()
	Bool _bCharGenSuccess = False
	_kActorBase.SetInvulnerable(True)
	_bCharGenSuccess = CharGenLoadCharacter(Self,CharacterRace,CharacterName)
	_kActorBase.SetInvulnerable(_bInvulnerableState)
	If _bCharGenSuccess
		Return 0
	Else
		DebugTrace("Something went wrong during UpdateAppearance!",1)
		;FIXME: Add more error handling like checking for missing files, etc
		Return -1
	EndIf
EndFunction

Int Function UpdateNINodes()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateAppearance called outside Assigned state!")
		Return -2
	EndIf
	Int jNINodeData = JValue.SolveObj(_jCharacterData,".NINodeData")
	
	Int jNiNodeNames = JMap.AllKeys(jNINodeData)
	Int i = JArray.Count(jNINodeNames)
	While i > 0
		i -= 1
		String sNodeName = JArray.GetStr(jNINodeNames,i)
		If sNodeName
			Float NINodeScale = JMap.GetFlt(JArray.getObj(jNINodeData,i),"Scale")
			NetImmerse.SetNodeScale(Self,sNodeName,NINodeScale,False)
			NetImmerse.SetNodeScale(Self,sNodeName,NINodeScale,True)
		EndIf
	EndWhile
EndFunction

Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName)
	If !ScriptState == "Assigned"
		DebugTrace("CharGenLoadCharacter called outside Assigned state!")
		Return False
	EndIf
	Bool bResult
	Int iDismountSafetyTimer = 10
	While akActor.IsOnMount() && iDismountSafetyTimer
		iDismountSafetyTimer -= 1
		Bool bDismountSent = akActor.Dismount()
		Wait(1)
	EndWhile
	If !iDismountSafetyTimer
		Debug.Trace("MYC: (" + CharacterName + "/Actor) Dismount timer expired!",1)
	EndIf
	If akActor.IsOnMount()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Actor is still mounted, will not apply CharGen data!",2)
		Return False
	EndIf
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Checking for Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	Bool _bExternalHeadExists = JContainers.fileExistsAtPath("Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	If CharGen.IsExternalEnabled()
		If !_bExternalHeadExists
			Debug.Trace("MYC/Actor/" + CharacterName + ": Warning, IsExternalEnabled is true but no head NIF exists, will use LoadCharacter instead!",1)
			bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + CharacterName + ": IsExternalEnabled is true, using LoadExternalCharacter...")
		bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
		Return bResult
	Else
		If _bExternalHeadExists
			Debug.Trace("MYC/Actor/" + CharacterName + ": Warning, external head NIF exists but IsExternalEnabled is false, using LoadExternalCharacter instead...",1)
			bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + CharacterName + ": IsExternalEnabled is false, using LoadCharacter...")
		bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
		WaitMenuMode(1)
		RegenerateHead()
		Return bResult
	EndIf
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety As Bool
EndFunction

;=== Equipment and inventory functions ===--

Int Function EquipDefaultGear(Bool abLockEquip = False)
{Re-equip the gear this character was saved with, optionally locking it in place}
;FIXME: This may fail to equip the correct item if character has both the base 
;and a customized version of the same item in their inventory

	Int jCharacterArmor = JValue.SolveObj(_jCharacterData,".Equipment.Armor")
	Int jCharacterArmorInfo = JValue.SolveObj(_jCharacterData,".Equipment.ArmorInfo")

	Actor kCharacterActor = Self
	
	Int i = JArray.Count(jCharacterArmorInfo)
	Int iCount = 0
	While i > 0
		i -= 1
		Int jArmor = JArray.GetObj(jCharacterArmorInfo,i)
		Form kItem = JMap.GetForm(jArmor,"Form")
		If !IsEquipped(kItem)
			kCharacterActor.EquipItemEx(kItem,0,abLockEquip,True)
			iCount += 1
		EndIf
	EndWhile
	Form kItemL = JValue.SolveForm(_jCharacterData,".Equipment.Left.Form")
	Form kItemR = JValue.SolveForm(_jCharacterData,".Equipment.Right.Form")
	If !IsEquipped(kItemL)
		kCharacterActor.EquipItemEx(kItemL,2,abLockEquip,True)
		iCount += 1
	EndIf
	If !IsEquipped(kItemR)
		kCharacterActor.EquipItemEx(kItemR,1,abLockEquip,True)
		iCount += 1
	EndIf
	Form kAmmo = JValue.SolveForm(_jCharacterData,".Equipment.Ammo")
	If kAmmo
		kCharacterActor.EquipItemEx(kAmmo,0,abLockEquip,True)
		iCount += 1
	EndIf
	Return iCount
EndFunction

Int Function UpdateArmor(Bool abReplaceMissing = True, Bool abFullReset = False)
	Int i
	Int iCount
	
	DebugTrace("Applying Armor...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdateArmor called outside Assigned state!",1)
		Return -2
	EndIf
	
	If !_jCharacterData
		DebugTrace("UpdateArmor called but _jCharacterData is missing!",1)
		Return -3
	EndIf
	
	Int jCharacterArmor = JValue.SolveObj(_jCharacterData,".Equipment.Armor")
	Int jCharacterArmorInfo = JValue.SolveObj(_jCharacterData,".Equipment.ArmorInfo")

	Actor kCharacterActor = Self
	
	i = JArray.Count(jCharacterArmorInfo)
	While i > 0
		i -= 1
		Int jArmor = JArray.GetObj(jCharacterArmorInfo,i)
		Form kItem = JMap.GetForm(jArmor,"Form")
		If kItem
			Int h = (kItem as Armor).GetSlotMask()
			ObjectReference kObject = DataManager.LoadSerializedEquipment(jArmor)
			If kObject
				kCharacterActor.AddItem(kObject,1,True)
				kCharacterActor.EquipItemEx(kItem,0,False,True)
				;== Load NIO dye, if applicable ===--
				If GetRegBool("Config.NIO.ArmorDye.Enabled")
					Int jNIODyeColors = JValue.solveObj(jArmor,".NIODyeColors")
					If JValue.isArray(jNIODyeColors)
						Int iHandle = NIOverride.GetItemUniqueID(kCharacterActor, 0, h, True)
						Int iMaskIndex = 0
						Int iIndexMax = 15
						While iMaskIndex < iIndexMax
							Int iColor = JArray.GetInt(jNIODyeColors,iMaskIndex)
							If Math.RightShift(iColor,24) > 0
								NiOverride.SetItemDyeColor(iHandle, iMaskIndex, iColor)
							EndIf
							iMaskIndex += 1
						EndWhile
					EndIf
				EndIf
			Else ;kObject failed, armor didn't get loaded/created for some reason
				DebugTrace("Couldn't create an ObjectReference for " + kItem + "!",1)
			EndIf
		EndIf
	EndWhile

	Return iCount
EndFunction

Int Function UpdateWeapons(Bool abReplaceMissing = True, Bool abFullReset = False)
	Int i
	Int iCount
	DebugTrace("Applying Weapons...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdateWeapons called outside Assigned state!",1)
		Return -2
	EndIf
	
	If !_jCharacterData
		DebugTrace("UpdateWeapons called but _jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = Self
	
	Int iHand = 1 ; start with right
	While iHand >= 0
		Bool bTwoHanded = False
		String sHand = "Right"
		If iHand == 0
			sHand = "Left"
		EndIf
		Int jItem = JValue.SolveObj(_jCharacterData,".Equipment." + sHand)
		Form kItem = JMap.GetForm(jItem,"Form")
		ObjectReference kObject = DataManager.LoadSerializedEquipment(jItem)
		If kObject
			kCharacterActor.AddItem(kObject,1,True)
			kCharacterActor.EquipItemEx(kItem,iHand,False,True)
			Weapon kWeapon = kObject.GetBaseObject() as Weapon
			If kWeapon.IsBow() || kWeapon.IsGreatsword() || kWeapon.IsWaraxe() || kWeapon.IsWarhammer()
				bTwoHanded = True
			EndIf
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			DebugTrace("Couldn't create an ObjectReference for " + kItem + "!",1)
		EndIf
		iHand -= 1
		iCount += 1
		If bTwoHanded ; skip left hand
			iHand -= 1
			iCount -= 1
		EndIf
	EndWhile
	
	Bool bBow = False
	Bool bCrossbow = False
	If GetEquippedItemType(0) == 12
		bCrossBow = True
	ElseIf GetEquippedItemType(0) == 7
		bBow = True
	EndIf
	
	Float fBestAmmoDamage = 0.0
	Ammo kBestAmmo = JValue.SolveForm(_jCharacterData,".Equipment.Ammo") as Ammo
	Bool bFindBestAmmo = False
	If !kBestAmmo && (bBow || bCrossbow)
		bFindBestAmmo = True
	EndIf
	If bFindBestAmmo 
		Int jAmmoFMap = JValue.SolveObj(_jCharacterData,".Inventory.42") ; kAmmo
		Int jAmmoList = JFormMap.AllKeys(jAmmoFMap)
		i = JArray.Count(jAmmoList)
		While i > 0
			i -= 1
			Ammo kAmmo = JArray.GetForm(jAmmoList,i) as Ammo
			If kAmmo
				If (kAmmo.IsBolt() && bCrossBow) || (!kAmmo.IsBolt() && bBow) ;right ammo
					If kCharacterActor.GetItemCount(kAmmo) ; character has it
						If bFindBestAmmo ; but is it the BEST? OF THE BEST? OF THE BEST? SIR?
							Float fAmmoDamage = (kAmmo as Ammo).GetDamage()
							If fAmmoDamage > fBestAmmoDamage
								fBestAmmoDamage = fAmmoDamage
								kBestAmmo = kAmmo as Ammo
								DebugTrace("BestAmmo is now " + kBestAmmo.GetName())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndWhile
	EndIf
	If kBestAmmo
		EquipItemEx(kBestAmmo,0,False,False)
	EndIf
	
	Return iCount
EndFunction

Int Function UpdateInventory(Bool abReplaceMissing = True, Bool abFullReset = False)
	Int i
	Int iCount
	DebugTrace("Applying Inventory...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdateInventory called outside Assigned state!",1)
		Return -2
	EndIf
	
	If !_jCharacterData
		DebugTrace("UpdateInventory called but _jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = Self
	
	Int jCustomItems = JValue.SolveObj(_jCharacterData,".InventoryCustomItems")

	i = JArray.Count(jCustomItems)
	DebugTrace("Has " + i + " items to be customized!")
	While i > 0
		i -= 1
		Int jItem = JArray.GetObj(jCustomItems,i)
		Form kItem = JMap.GetForm(jItem,"Form")
		ObjectReference kObject = DataManager.LoadSerializedEquipment(jItem)
		If kObject
			kCharacterActor.AddItem(kObject,1,True)
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			DebugTrace("Couldn't create an ObjectReference for " + kItem + "!",1)
		EndIf
		iCount += 1
	EndWhile

	Int jAmmoFMap = JValue.SolveObj(_jCharacterData,".Inventory.42") ; kAmmo
	Int jAmmoList = JFormMap.AllKeys(jAmmoFMap)
	i = JArray.Count(jAmmoList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jAmmoList,i)
		Int iItemCount = JFormMap.GetInt(jAmmoFMap,kItem)
		If kItem
			If iItemCount
				kCharacterActor.AddItem(kItem,iItemCount,True)
				iCount += iItemCount
			EndIf
		EndIf
	EndWhile
	
	Int jPotionFMap = JValue.SolveObj(_jCharacterData,".Inventory.46") ; kPotion
	Int	jPotionList = JFormMap.AllKeys(jPotionFMap)
	i = JArray.Count(jPotionList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jPotionList,i)
		Int iItemCount = JFormMap.GetInt(jPotionFMap,kItem)
		If !kItem.HasKeywordString("VendorItemFood")
			AddItem(kItem,iItemCount,True)
			iCount += iItemCount
		EndIf
	EndWhile
	
	Return iCount
EndFunction
;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	If CharacterName
		Debug.Trace("MYC/Doppelganger/" + _sFormID + "(" + CharacterName + "): " + sDebugString,iSeverity)
	Else
		Debug.Trace("MYC/Doppelganger/" + _sFormID + ": " + sDebugString,iSeverity)
	EndIf
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
