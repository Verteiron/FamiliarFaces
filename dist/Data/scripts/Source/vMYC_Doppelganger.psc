Scriptname vMYC_Doppelganger extends Actor
{Apply character appearance, handle inventory import, etc.}

; === [ vMYC_Doppelganger.psc ] ===========================================---
; When assigned a character ID, set up this Actor's appearance, inventory, 
; name, ActorValues, etc based on that character's stored data.
; Handles:
;   Setting up Actor appearance
;   Setting up Actor's inventory and equipment (including custom equipment)
;   Setting up Actor's spells, shouts, perks, and actorvalues
;   Tracking the Actor adding/removing spells, items, etc as needed.
; Usage:
;   When in the Available state, call AssignCharacter and the script will
;   take care of everything else.
; ========================================================---

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

ActorBase			Property MyActorBase							Auto Hidden

vMYC_DataManager	Property DataManager							Auto

Bool 				Property NeedAppearance	= False 				Auto Hidden
Bool 				Property NeedStats		= False 				Auto Hidden
Bool 				Property NeedPerks		= False 				Auto Hidden
Bool 				Property NeedSpells		= False 				Auto Hidden
Bool 				Property NeedShouts		= False 				Auto Hidden
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
Formlist 			Property vMYC_ModCompatibility_PerkList_Unsafe 		Auto
{A list of Perks that are known to be unsafe or unnecessary to load on NPCs.}

Message 			Property vMYC_VoiceTypeNoFollower 					Auto
Message 			Property vMYC_VoiceTypeNoSpouse						Auto

Int					Property _jCharacterData							Auto Hidden

;=== Variables ===--

Bool 		_bFirstLoad 				= True
				
String[] 	_sSkillNames

Float 		_fDecapitationChance

Int 		_iMagicUpdateCounter

Float 		_fOrphanedTime
Bool 		_bOrphaned

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int 		_iCharGenVersion

;Int			_jCharacterData

String 		_sCharacterInfo

String		_sFormID

;=== Events ===--

Event OnInit()
	MyActorBase = GetActorBase()
	MyActorBase.SetEssential(True)
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
EndEvent

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	DebugTrace("AnimationEvent:" + asEventName)
	;If asEventName == "BeginCastVoice"
	;	Wait(0.1)
	;	InterruptCast()
	;EndIf
EndEvent

Event OnLoad()

EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	NeedStats = True
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	NeedStats = True
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
		SetRegForm("Doppelgangers.Preferred." + sUUID + ".ActorBase",MyActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".ActorBase",MyActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".Actor",Self as Actor)
		CharacterName = GetRegStr(_sCharacterInfo + "Name")
		CharacterRace = GetRegForm(_sCharacterInfo + "Race") as Race
		MyActorBase.SetName(CharacterName)
		NeedAppearance	= True
		NeedStats		= True
		NeedPerks		= True
		NeedSpells		= True
		NeedShouts		= True
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
		If NeedAppearance
			If UpdateAppearance() == 0 ; No error
				UpdateNINodes()
				UpdateNIOverlays()
				NeedAppearance = False
			EndIf
		EndIf
		If NeedInventory 
			If UpdateInventory() >= 0
				NeedInventory = False
			EndIf
			; Adding items usually makes the target unequip gear, so make sure it's back on.
			If !NeedEquipment
				EquipDefaultGear() 
			EndIf
		EndIf
		If NeedEquipment
			Int bResultArmor = UpdateArmor()
			Int bResultWeapons = UpdateWeapons()
			If bResultArmor >= 0 && bResultWeapons >= 0 ; No error
				NeedEquipment = False
			EndIf
		EndIf
		If NeedStats
			If UpdateStats() >= 0
				NeedStats = False
			EndIf
		EndIf
		If NeedPerks
			If UpdatePerks() >= 0 ; No error
				NeedPerks = False
			EndIf
		EndIf
		If NeedShouts
			If UpdateShouts() >= 0 ; No error
				NeedShouts = False
			EndIf
		EndIf
		If NeedSpells
			If UpdateSpells() >= 0 ; No error
				NeedSpells = False
			EndIf
		EndIf
		;ReportStats()
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
	If (CharacterName && MyActorBase.GetName() != CharacterName) || abForce
		DebugTrace("Setting actorbase name!")
		MyActorBase.SetName(CharacterName)
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
	Bool _bInvulnerableState = MyActorBase.IsInvulnerable()
	Bool _bCharGenSuccess = False
	MyActorBase.SetInvulnerable(True)
	_bCharGenSuccess = CharGenLoadCharacter(Self,CharacterRace,CharacterName)
	MyActorBase.SetInvulnerable(_bInvulnerableState)
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
	
	Int jNiNodeNameList = JMap.AllKeys(jNINodeData)
	Int jNiNodeValueList = JMap.AllValues(jNINodeData)
	Int i = JArray.Count(jNiNodeNameList)
	While i > 0
		i -= 1
		String sNodeName = JArray.GetStr(jNiNodeNameList,i)
		If sNodeName
			Int jNINodeValues = JArray.GetObj(jNiNodeValueList,i)
			Float fNINodeScale = JMap.GetFlt(jNINodeValues,"Scale")
			Debug.Trace("Scaling NINode " + sNodeName + " to " + fNINodeScale + "!")
			NetImmerse.SetNodeScale(Self,sNodeName,fNINodeScale,False)
			NetImmerse.SetNodeScale(Self,sNodeName,fNINodeScale,True)
		EndIf
	EndWhile
EndFunction

Int Function UpdateNIOverlays()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateNIOverlays called outside Assigned state!")
		Return -2
	EndIf
	Int jOverlayData = JValue.SolveObj(_jCharacterData,".NIOverrideData")

	If !jOverlayData
		Return 0 
	EndIf

	If !NiOverride.HasOverlays(Self)
		NiOverride.AddOverlays(Self)
	EndIf
	
	NiOverride.RevertOverlays(Self)
	ApplyNIOverlay(Self,JMap.GetObj(jOverlayData,"BodyOverlays"),"Body [Ovl")
	ApplyNIOverlay(Self,JMap.GetObj(jOverlayData,"HandOverlays"),"Hand [Ovl")
	ApplyNIOverlay(Self,JMap.GetObj(jOverlayData,"FeetOverlays"),"Feet [Ovl")
	ApplyNIOverlay(Self,JMap.GetObj(jOverlayData,"FaceOverlays"),"Face [Ovl")

	Return 1
EndFunction

Function ApplyNIOverlay(Actor kCharacter, Int jLayers, String sNodeTemplate)
	If !kCharacter
		Return
	EndIf
	Int iLayerCount = JArray.Count(jLayers)
	Int i = 0
	Bool bIsFemale = kCharacter.GetActorBase().GetSex()
	While i < iLayerCount
		Int jLayer = JArray.GetObj(jLayers,i)
		String sNodeName = sNodeTemplate + i + "]"

		NiOverride.AddNodeOverrideInt(kCharacter, bIsFemale, sNodeName, 7, -1, JMap.GetInt(jLayer,"RGB"), True) ; Set the tint color
		NiOverride.AddNodeOverrideFloat(kCharacter, bIsFemale, sNodeName, 8, -1, JMap.GetFlt(jLayer,"Alpha"), True) ; Set the alpha
		NiOverride.AddNodeOverrideString(kCharacter, bIsFemale, sNodeName, 9, 0, JMap.GetStr(jLayer,"Texture"), True) ; Set the tint texture

		Int iGlowData = JMap.GetInt(jLayer,"GlowData")
		Int iGlowColor = iGlowData
		Int iGlowEmissive = Math.RightShift(iGlowColor, 24)
		NiOverride.AddNodeOverrideInt(kCharacter, bIsFemale, sNodeName, 0, -1, iGlowColor, True) ; Set the emissive color
		NiOverride.AddNodeOverrideFloat(kCharacter, bIsFemale, sNodeName, 1, -1, iGlowEmissive / 10.0, True) ; Set the emissive multiple
		i += 1
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
{Re-equip the gear this character was saved with, optionally locking it in place.
 abLockEquip: (Optional) Lock equipment in place, so AI cannot remove it automatically.
 Returns: Number of items processed.}
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
		If !kCharacterActor.GetItemCount(kAmmo)
			kCharacterActor.AddItem(kAmmo,1,True)
		EndIf
		kCharacterActor.EquipItemEx(kAmmo,0,abLockEquip,True)
		iCount += 1
	EndIf
	Return iCount
EndFunction

Int Function UpdateArmor(Bool abReplaceMissing = True, Bool abFullReset = False)
{Setup equipped Armor based on the saved character data.}
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
		String sItemID = JValue.SolveStr(JArray.GetObj(jCharacterArmorInfo,i),".UUID")
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)
		If kObject
			Int h = (kObject.GetBaseObject() as Armor).GetSlotMask()
			kObject.SetActorOwner(MyActorBase)
			kCharacterActor.AddItem(kObject,1,True)
			kCharacterActor.EquipItemEx(kObject,0,True,True) ; By default do not allow unequip, otherwise they strip whenever they draw a weapon.
			;== Load NIO dye, if applicable ===--
			If GetRegBool("Config.NIO.ArmorDye.Enabled")
				Int jArmor = vMYC_API_Item.GetItemJMap(sItemID)
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
			DebugTrace("Couldn't create an ObjectReference for " + sItemID + "!",1)
		EndIf
	EndWhile

	Return iCount
EndFunction

Int Function UpdateWeapons(Bool abReplaceMissing = True, Bool abFullReset = False)
{Setup equipped Weapons and Ammo based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
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
		String sItemID = JValue.SolveStr(_jCharacterData,".Equipment." + sHand + ".UUID")
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)
		If kObject
			kObject.SetActorOwner(MyActorBase)
			kCharacterActor.AddItem(kObject,1,True)
			kCharacterActor.EquipItemEx(kObject,iHand,False,True) ;FIXME: May need to use the Base form here?
			Weapon kWeapon = kObject.GetBaseObject() as Weapon
			If kWeapon.IsBow() || kWeapon.IsGreatsword() || kWeapon.IsWaraxe() || kWeapon.IsWarhammer()
				bTwoHanded = True
			EndIf
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			DebugTrace("Couldn't create an ObjectReference for " + sItemID + "!",1)
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
{Setup Inventory items based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
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
		String sItemID = JValue.SolveStr(JArray.GetObj(jCustomItems,i),".UUID")
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)
		If kObject
			kObject.SetActorOwner(MyActorBase)
			kCharacterActor.AddItem(kObject,1,True)
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			DebugTrace("Couldn't create an ObjectReference for " + sItemID + "!",1)
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
		If kItem
			If !(kItem as Potion).IsFood() ;.HasKeywordString("VendorItemFood")
				AddItem(kItem,iItemCount,True)
				iCount += iItemCount
			EndIf
		EndIf
	EndWhile
	
	Return iCount
EndFunction

;=== Stats ===--

Int Function UpdateStats(Bool abForceValues = False)
{Apply AVs and other stats like health. 
 abForceValues: (Optional) Set values absolutely, ignoring any buffs or nerfs from enchantments/magiceffects.
 Returns: -1 for generic failure.}
	Int i
	Int iCount
	DebugTrace("Applying Perks...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdatePerks called outside Assigned state!",1)
		Return -2
	EndIf

	If !_jCharacterData
		DebugTrace("UpdatePerks called but _jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = Self

	Int jStats = JValue.SolveObj(_jCharacterData,".Stats")
	Int jAVs = JValue.SolveObj(_jCharacterData,".Stats.AV")
	
	Int jAVNames = JMap.AllKeys(jAVs)
	i = JArray.Count(jAVNames)
	While i > 0
		i -= 1
		String sAVName = JArray.GetStr(jAVNames,i)
		If sAVName
			Float fAV = JMap.GetFlt(jAVS,sAVName)
			If abForceValues
				ForceActorValue(sAVName,fAV)
				DebugTrace("Force " + sAVName + " to " + fAV + " - GetBase/Get returns " + GetBaseActorValue(sAVName) + "/" + GetActorValue(sAVName) + "!")
			Else
				SetActorValue(sAVName,fAV) 
				DebugTrace("Set " + sAVName + " to " + fAV + " - GetBase/Get returns " + GetBaseActorValue(sAVName) + "/" + GetActorValue(sAVName) + "!")
			EndIf
		EndIf
	EndWhile
	
	Return JArray.Count(jAVNames)
EndFunction

Function ReportStats()
{Just log all stats to the logfile, for testing purposes.}
	Actor kCharacterActor = Self

	Int jStats = JValue.SolveObj(_jCharacterData,".Stats")
	Int jAVs = JValue.SolveObj(_jCharacterData,".Stats.AV")
	
	Int jAVNames = JMap.AllKeys(jAVs)
	Int i = JArray.Count(jAVNames)
	While i > 0
		i -= 1
		String sAVName = JArray.GetStr(jAVNames,i)
		If sAVName
			Float fAV = JMap.GetFlt(jAVS,sAVName)
			DebugTrace("Set " + sAVName + " to " + fAV + " - GetBase/Get returns " + GetBaseActorValue(sAVName) + "/" + GetActorValue(sAVName) + "!")
		EndIf
	EndWhile
	
EndFunction

;=== Perks ===--

Int Function UpdatePerks()
{Apply perks.
 Returns:  for failure, or number of perks applied for success.}
	Int i
	Int iCount
	DebugTrace("Applying Perks...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdatePerks called outside Assigned state!",1)
		Return -2
	EndIf
	
	If !_jCharacterData
		DebugTrace("UpdatePerks called but _jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = Self
	
	Int jPerks = JValue.SolveObj(_jCharacterData,".Perks")

	Formlist kPerklist = DataManager.LockFormList()
	kPerkList.Revert() ; Should already be empty, but just in case

	i = JArray.Count(jPerks)
	DebugTrace("Has " + i + " perks to be checked!")
	Int iMissingCount = 0
	While i > 0
		i -= 1
		Perk kPerk = JArray.getForm(jPerks,i) as Perk
		If !kPerk
			iMissingCount += 1
		Else
			If vMYC_ModCompatibility_PerkList_Unsafe.HasForm(kPerk)
				iMissingCount += 1
			Else
				kPerklist.AddForm(kPerk)
			EndIf
		EndIf
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Perk is from " + JArray.getStr(jPerks,i))
		;DebugTrace("Adding perk " + kPerk + " (" + kPerk.GetName() + ") to list...")
	EndWhile
	Int iPerkCountTotal = kPerklist.GetSize()
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + kPerklist.GetSize() + " perks to Actorbase...")
	If iPerkCountTotal + iMissingCount != JArray.Count(jPerks)
		Debug.Trace("PerkList size mismatch, probably due to simultaneous calls. Aborting!",1)
		DataManager.UnlockFormlist(kPerklist)
		Return -1
	ElseIf iPerkCountTotal == 0
		DebugTrace("PerkList size is 0. Won't attempt to apply this.")
		DataManager.UnlockFormlist(kPerklist)
		Return 0
	EndIf
	If iMissingCount
		DebugTrace("Loading " + iPerkCountTotal + " Perks with " + iMissingCount + " skipped...")
	Else
		DebugTrace("Loading " + iPerkCountTotal + " Perks...")
	EndIf
	FFUtils.LoadCharacterPerks(MyActorBase,kPerklist)
	DebugTrace("Perks loaded successfully!")
	WaitMenuMode(0.1)
	DataManager.UnlockFormlist(kPerklist)
	Return iPerkCountTotal
EndFunction

;=== Shouts ===--

Int Function UpdateShouts()
{Apply shouts to named character. Needed because AddShout causes savegame corruption.
 Returns: -1 for failure, or number of shouts applied for success.}
;FIXME: I bet this could be done with FFUtils and avoid using the FormList.
	Int jShouts = JValue.SolveObj(_jCharacterData,".Shouts")
	
	Formlist kShoutlist = DataManager.LockFormList()
	kShoutlist.Revert() ; Should already be empty, but just in case
	
	Int i = JArray.Count(jShouts)
	Int iMissingCount = 0

	RegisterForAnimationEvent(Self,"BeginCastVoice")
	RegisterForAnimationEvent(Self,"MT_Shout_Exhale")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleLong")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleMedium")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleSlowTime")
	RegisterForAnimationEvent(Self,"MT_Shout_Inhale")
	RegisterForAnimationEvent(Self,"shoutStop")
	RegisterForAnimationEvent(Self,"Sneak1HM_Shout_Inhale")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_Exhale")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleLong")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleMedium")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleSlowTime")
	RegisterForAnimationEvent(Self,"Voice_SpellFire_Event")
	RegisterForAnimationEvent(Self,"CombatReady_ShoutExhaleMedium")
	RegisterForAnimationEvent(Self,"MC_shoutStart")
	RegisterForAnimationEvent(Self,"NPCshoutStart")
	RegisterForAnimationEvent(Self,"shoutLoopingRelease")
	RegisterForAnimationEvent(Self,"shoutRelease")
	RegisterForAnimationEvent(Self,"shoutReleaseSlowTime")
	RegisterForAnimationEvent(Self,"ShoutSprintLongestStart")
	RegisterForAnimationEvent(Self,"ShoutSprintLongStart")
	RegisterForAnimationEvent(Self,"ShoutSprintMediumStart")
	RegisterForAnimationEvent(Self,"ShoutSprintShortStart")
	RegisterForAnimationEvent(Self,"shoutStart")
	RegisterForAnimationEvent(Self,"shoutStop")
	
	While i > 0
		i -= 1
		Shout kShout = JArray.getForm(jShouts,i) as Shout
		If !kShout
			iMissingCount += 1
		Else
			Shout kStormCallShout = GetFormFromFile(0x0007097D,"Skyrim.esm") as Shout
			Shout kDragonAspectShout
			If GetModByName("Dragonborn.esm")
				kDragonAspectShout = GetFormFromFile(0x0201DF92,"DragonBorn.esm") as Shout
			EndIf
			If kShout == kStormCallShout && GetRegBool("Config.Shouts.Disabled.CallStorm")
				;Don't add it
			ElseIf kShout == kDragonAspectShout && GetRegBool("Config.Shouts.Disabled.DragonAspect") ;FIXME: Maybe use an array for disabled shouts, then test each one
				;Don't add it
			ElseIf GetRegBool("Config.Shouts.BlockUnlearned")
				If PlayerREF.HasSpell(kShout)
					kShoutlist.AddForm(kShout)
				EndIf
			Else
				kShoutlist.AddForm(kShout)		
			EndIf
		EndIf
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Adding Shout " + kShout + " (" + kShout.GetName() + ") to list...")
	EndWhile
	Int iShoutCount = kShoutlist.GetSize()
	DebugTrace("Loading " + iShoutCount + " Shouts to Actorbase...")
	If iShoutCount == 0
		DebugTrace("ShoutList size is 0. Won't attempt to apply this.")
		DataManager.UnlockFormlist(kShoutlist)
		Return 0
	EndIf
	If iMissingCount
		DebugTrace("Loading " + iShoutCount + " Shouts with " + iMissingCount + " skipped.",1)
	Else
		DebugTrace("Loaded " + iShoutCount + " Shouts.")
	EndIf
	FFUtils.LoadCharacterShouts(MyActorBase,kShoutlist)
	WaitMenuMode(0.1)
	DataManager.UnlockFormlist(kShoutlist)
	Return kShoutlist.GetSize()
EndFunction

Function RemoveCharacterShouts(String sCharacterName)
{Remove all shouts from named character. Needed because RemoveShout causes savegame corruption.}
	DebugTrace("Character is not allowed to use shouts, removing them!")
	Formlist kShoutlist = DataManager.LockFormList()
	kShoutlist.Revert() ; Should already be empty, but just in case
	Shout vMYC_NullShout = GetFormFromFile(0x0201f055,"vMYC_MeetYourCharacters.esp") as Shout
	kShoutlist.AddForm(vMYC_NullShout)
	FFUtils.LoadCharacterShouts(MyActorBase,kShoutlist)
	WaitMenuMode(0.1)
EndFunction


;=== Spell functions ===--

Int Function UpdateSpells()
{Apply Spells. 
 Returns: -1 for failure, or number of Spells applied for success.}
	Int i
	Int iCount
	Int iAdded = 0
	Int iRemoved = 0
	DebugTrace("Applying Spells...")

	If !ScriptState == "Assigned"
		DebugTrace("UpdateSpells called outside Assigned state!",1)
		Return -2
	EndIf
	
	If !_jCharacterData
		DebugTrace("UpdateSpells called but _jCharacterData is missing!",1)
		Return -3
	EndIf

	If GetRegBool("Config.Compat.AFT.MagicDisabled")
		;Do not alter spell list if Magic is disabled by AFT
		Return 0
	EndIf
	
	Actor kCharacterActor = Self
	
	Int jSpells = JValue.SolveObj(_jCharacterData,".Spells")
	Int jSkillNames = GetRegObj("AVNames")

	If GetRegBool("Config.Magic.AutoSelect")
		i = 18
		While i < 23
			String sMagicSchool = JArray.GetStr(jSkillNames,i)
			DebugTrace("Checking perkCount for " + sMagicSchool + "...")
			Int iPerkCount = JValue.SolveInt(_jCharacterData,".PerkCounts." + sMagicSchool)
			If iPerkCount
				DebugTrace("PerkCount for " + sMagicSchool + " is " + iPerkCount)
			EndIf
			
			If iPerkCount > 1
				SetSessionBool("Config.Magic.Allow" + sMagicSchool,True)
			Else
				SetSessionBool("Config.Magic.Allow" + sMagicSchool,False)
			EndIf
			i += 1
		EndWhile
	EndIf
	
	i = JArray.Count(jSpells)
	
	While i > 0
		i -= 1
		Spell kSpell = JArray.GetForm(jSpells,i) As Spell
		String sMagicSchool = kSpell.GetNthEffectMagicEffect(0).GetAssociatedSkill()
		Bool bSpellIsAllowed = False
		
		If sMagicSchool
			bSpellIsAllowed = GetSessionBool("Config.Magic.Allow" + sMagicSchool)
		Else
			bSpellIsAllowed = GetSessionBool("Config.Magic.AllowOther")
		EndIf
		
		MagicEffect kMagicEffect = kSpell.GetNthEffectMagicEffect(0)
		
		If GetSessionBool("Config.Magic.AllowHealing") ;sMagicSchool == "Restoration" && 
			If kMagicEffect.HasKeywordString("MagicRestoreHealth") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
				bSpellIsAllowed = True
			ElseIf vMYC_ModCompatibility_SpellList_Healing.HasForm(kSpell)
				bSpellIsAllowed = True
			EndIf
		EndIf
		
		If GetSessionBool("Config.Magic.AllowDefensive")
			If kMagicEffect.HasKeywordString("MagicArmorSpell") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
				bSpellIsAllowed = True
			ElseIf vMYC_ModCompatibility_SpellList_Armor.HasForm(kSpell)
				bSpellIsAllowed = True
			EndIf
		EndIf

		If bSpellIsAllowed
			Int[] iAllowedSources = New Int[128]
			
			iAllowedSources[0] = GetModByName("Skyrim.esm")
			iAllowedSources[1] = GetModByName("Update.esm")
			iAllowedSources[2] = GetModByName("Dawnguard.esm")
			iAllowedSources[3] = GetModByName("Dragonborn.esm")
			iAllowedSources[4] = GetModByName("Hearthfires.esm")

			If GetSessionBool("Config.Magic.AllowSelectMods") ; Select mods
				iAllowedSources[5] = GetModByName("ColorfulMagic.esp")
				iAllowedSources[6] = GetModByName("Magic of the Magna-Ge.esp")
				iAllowedSources[7] = GetModByName("Animated Dragon Wings.esp")
				iAllowedSources[8] = GetModByName("Dwemerverse.esp")
			EndIf
			
			bSpellIsAllowed = False
			
			;See if this spell is from an approved source
			Int iSpellSourceID = Math.RightShift(kSpell.GetFormID(),24)
			If iAllowedSources.Find(iSpellSourceID) > -1
				bSpellIsAllowed = True
			ElseIf vMYC_ModCompatibility_SpellList_Safe.HasForm(kSpell)
			;A mod author has gone to the trouble of assuring us the spell is compatible.
				bSpellIsAllowed = True
			EndIf
		EndIf

		If vMYC_ModCompatibility_SpellList_Unsafe.HasForm(kSpell)
		;A mod author has added the spell to the unsafe list.
			bSpellIsAllowed = False
		EndIf
			
		
		If bSpellIsAllowed && !HasSpell(kSpell)
			If AddSpell(kSpell,False)
				DebugTrace("Added " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ") from " + GetModName(Math.RightShift(kSpell.GetFormID(),24)))
				iAdded += 1
			EndIf
		ElseIf !bSpellIsAllowed && HasSpell(kSpell)
			;Remove only if it is hostile, or has a duration, or has an associated cost discount perk. This way we avoid stripping perk, race, and doom stone abilities
			If kMagicEffect.IsEffectFlagSet(0x00000001) || kSpell.GetPerk() || kSpell.GetNthEffectDuration(0) > 0
				If RemoveSpell(kSpell)
					DebugTrace("Removed " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ")")
					iRemoved += 1
				EndIf
			EndIf
		EndIf
	EndWhile
	If iAdded || iRemoved
		DebugTrace("Added " + iAdded + " spells, removed " + iRemoved)
	EndIf

	Return iAdded
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	If CharacterName
		Debug.Trace("MYC/Doppelganger/" + _sFormID + "(" + CharacterName + "): " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	Else
		Debug.Trace("MYC/Doppelganger/" + _sFormID + ": " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	EndIf
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
