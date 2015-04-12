Scriptname vMYC_API_Doppelganger extends vMYC_APIBase Hidden
{Manage saving and loading of Doppelgangers.}

; === [ vMYC_API_Doppelganger.psc ] =======================================---
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_Session
Import vMYC_API_Character

;=== Generic Functions ===--

Int Function GetCharacterJMap(String asSID) Global
	Int iRet = -2 ; SID not present
	String sRegKey = "Characters." + asSID
	Int jCharacterData = vMYC_Registry.GetRegObj(sRegKey)
	If jCharacterData
		Return jCharacterData
	EndIf
	Return iRet
EndFunction

;=== Functions - Actorbase/Actor management ===--

ActorBase Function GetAvailableActorBase(Int aiSex, ActorBase akPreferredAB = None, Bool abLeveled = True) Global
{Returns the first available dummy actorbase of the right sex, optionally fetch the preferred one, optionally only choose unleveled ABs.}
	
	ActorBase kDoppelgangerBase = None
	Int jActorbaseMap = GetSessionObj("ActorbaseMap")
	
	If akPreferredAB
		If !JFormMap.GetStr(jActorbaseMap,akPreferredAB) ; If this AB is not already assigned in this session...
			JFormMap.SetStr(jActorBaseMap,akPreferredAB,"Reserved")
			SaveSession()
			Return akPreferredAB
		EndIf
	EndIf
	
	;== If we got this far then the preferred base is either not set or is in use ===--

	Int jActorbasePool = 0
	
	If aiSex ; 0 = m, 1 = f
		If abLeveled
			jActorbasePool = GetRegObj("ActorbasePool.F")
		Else
			jActorbasePool = GetRegObj("ActorbasePool.UF")
		EndIf
	Else
		If abLeveled
			jActorbasePool = GetRegObj("ActorbasePool.M")
		Else
			jActorbasePool = GetRegObj("ActorbasePool.UM")
		EndIf
	EndIf
	
	Int i = JArray.Count(jActorbasePool)
	While i > 0
		i -= 1
		kDoppelgangerBase = JArray.GetForm(jActorBasePool,i) as ActorBase
		If kDoppelgangerBase
			If !JFormMap.GetStr(jActorbaseMap,kDoppelgangerBase) ; If this AB is not already assigned in this session...
				JFormMap.SetStr(jActorBaseMap,kDoppelgangerBase,"Reserved")
				SaveSession()
				Return kDoppelgangerBase
			EndIf
		EndIf
	EndWhile

	Debug.Trace("MYC/API/Doppelganger/GetAvailableActorBase: Couldn't find an available ActorBase!",1)
	;== Either no more are available, or something else went wrong ===--
	Return None
EndFunction

String Function GetSIDForActor(Actor kActor) Global
	If (kActor as vMYC_Doppelganger)
		Return (kActor as vMYC_Doppelganger).SID
	EndIf
	Return ""
EndFunction

Actor Function GetActorForSID(String asSID)
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	Int jActorForms = JFormMap.AllKeys(jActorBaseMap)
	Int jActorSIDs = JFormMap.AllValues(jActorBaseMap)
	Int idx = JArray.FindStr(jActorSIDs,asSID)
	If idx > -1
		Return JArray.GetForm(jActorForms,idx) as Actor
	EndIf
	Return None
EndFunction

Function AddMappedActorBase(ActorBase akActorBase, String asSID) Global
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	If !jActorBaseMap
		SetSessionObj("ActorbaseMap",JFormMap.Object())
		jActorBaseMap = GetSessionObj("ActorbaseMap")
	EndIf
	JFormMap.SetStr(jActorbaseMap,akActorBase,asSID)
	SaveSession()
EndFunction

Function RemoveMappedActorBase(ActorBase akActorBase, String asSID) Global
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	If !jActorBaseMap
		SetSessionObj("ActorbaseMap",JFormMap.Object())
		jActorBaseMap = GetSessionObj("ActorbaseMap")
	EndIf
	JFormMap.RemoveKey(jActorbaseMap,akActorBase)
	SaveSession()
EndFunction

Function RegisterActor(Actor akActor,String asSID = "") Global
	vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
	If kDoppelganger && !asSID
		asSID = kDoppelganger.SID
	EndIf
	If !asSID
		Return
	EndIf
	ActorBase kActorBase = akActor.GetActorBase()

	If !HasRegKey("Doppelgangers.Preferred." + asSID + ".ActorBase") 
		SetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase",kActorBase)
	EndIf
	SetSessionForm("Doppelgangers." + asSID + ".ActorBase",kActorBase)
	SetSessionForm("Doppelgangers." + asSID + ".Actor",akActor)
	AddMappedActorBase(kActorBase,asSID)
EndFunction

Function UnregisterActor(Actor akActor = None,String asSID = "") Global
	ActorBase kActorBase
	If akActor
		kActorBase = akActor.GetActorBase()
		vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
		If kDoppelganger && !asSID
			asSID = kDoppelganger.SID
		EndIf
		If !asSID
			Return
		EndIf
	EndIf

	If !kActorBase
		kActorBase = GetSessionForm("Doppelgangers." + asSID + ".ActorBase") as ActorBase
	EndIf
	RemoveMappedActorBase(kActorBase,asSID)
	ClearSessionKey("Doppelgangers." + asSID)
EndFunction

Actor Function CreateDoppelganger(String asSID, Bool abLeveled = True) Global
	Int jCharacterData = GetCharacterJMap(asSID)
	If !jCharacterData
		Debug.Trace("MYC/API/Doppelganger/CreateDoppelganger: Invalid SID!",1)
		Return None
	EndIf

	String sName = GetCharacterName(asSID)
	Int iSex = GetCharacterSex(asSID)
	Race kRace = GetCharacterRace(asSID)

	If sName && iSex > -1 && kRace
		DebugTraceAPIDopp(asSID,"CreateDoppelganger: Going to assign a Doppelganger to " + sName + " (" + kRace.GetName() + ")")
	Else
		DebugTraceAPIDopp(asSID,"CreateDoppelganger: Character " + asSID + " (" + sName + ") is missing vital data, aborting!",1)
		Return None
	EndIf
	ActorBase kDoppelgangerBase = GetAvailableActorBase(iSex,GetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase") as Actorbase,abLeveled)
	DebugTraceAPIDopp(asSID,"CreateDoppelganger: Target ActorBase for " + sName + " will be " + kDoppelgangerBase + " (" + kDoppelgangerBase.GetName() + ")")
;	;GetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase")
;	;SetSessionForm("Doppelgangers." + asSID + ".ActorBase",kActorBase)
	;SetSessionForm("Doppelgangers." + asSID + ".Actor",akActor as Actor)
	ObjectReference kNowhere = Game.GetFormFromFile(0x00004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	Actor kDoppelActor = kNowhere.PlaceAtMe(kDoppelgangerBase) as Actor
	vMYC_Doppelganger kDoppelScript = kDoppelActor as vMYC_Doppelganger
	kDoppelScript.AssignCharacter(asSID)
	Return kDoppelActor
EndFunction

Function DeleteDoppelganger(Actor akActor) Global
	vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
 	If !kDoppelganger
 		DebugTraceAPIDopp("SetFoe","Passed actor " + akActor + " is not a Doppelganger!",1)
 		Return
 	EndIf
 	String sSID = kDoppelganger.SID
 	UnregisterActor(akActor,sSID)
 	akActor.RemoveAllItems()
 	akActor.Delete()
EndFunction

;=== Functions - Control and settings for Doppelgangers ===--

Int Function SetFoe(Actor akActor, Bool abVanishOnDeath = True) Global
{Set the target Actor as a Foe of the player. 
 abVanishOnDeath: (Optional) When target is killed by the player, they explode and vanish instead of entering bleedout.}
 	Int iRet = -1
	vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
 	If !kDoppelganger
 		DebugTraceAPIDopp("SetFoe","Passed actor " + akActor + " is not a Doppelganger!",1)
 		Return iRet
 	EndIf
 	String sSID = kDoppelganger.SID
 	;FIXME: Avoid Gopher's bug, make sure they are NOT a follower before making them a baddie!
	SetSessionBool("Characters." + sSID + ".Config.IsFriend",False)
	SetSessionBool("Characters." + sSID + ".Config.CanMarry",False)
 	SetSessionBool("Characters." + sSID + ".Config.IsFoe",True)
 	SetSessionBool("Characters." + sSID + ".Config.VanishOnDeath",abVanishOnDeath)
 	Return kDoppelganger.UpdateDisposition()
EndFunction


;=== Functions - Appearance ===--

Int Function UpdateAppearance(String asSID, Actor akActor) Global
	Race kRace = vMYC_API_Character.GetCharacterRace(asSID) as Race
	String sCharacterName = vMYC_API_Character.GetCharacterName(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	If kRace && sCharacterName
		Bool bInvulnerableState = kActorBase.IsInvulnerable()
		kActorBase.SetInvulnerable(True)
		Bool bCharGenSuccess = CharGenLoadCharacter(akActor,kRace,sCharacterName)
		kActorBase.SetInvulnerable(bInvulnerableState)

		If bCharGenSuccess
			Return 0
		EndIf
	EndIf
	;DebugTraceAPIDopp(asSID,"Something went wrong during UpdateAppearance!",1)
	Return -1
EndFunction

Int Function UpdateNINodes(String asSID, Actor akActor) Global
	Int i

	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)

	;DebugTraceAPIDopp(asSID,"Updating NINodes...")
	Int jCharGenNodeTransforms = JValue.SolveObj(jCharacterData,".CharGenData.Transforms")
	If jCharGenNodeTransforms
		i = JArray.Count(jCharGenNodeTransforms)
		While i > 0
			i -= 1
			Int jNodeTransform = JArray.GetObj(jCharGenNodeTransforms,i)
			String sNodeName = JValue.SolveStr(jNodeTransform,".node")
			If sNodeName
		        Bool bFirstPerson = JValue.SolveInt(jNodeTransform,".firstPerson") as Bool
				Int jNodeKeys = JValue.SolveObj(jNodeTransform,".keys")
				Int iKey = JArray.Count(jNodeKeys)
				While iKey > 0
					iKey -= 1
					Int jNodeKey = JArray.GetObj(jNodeKeys,iKey)
					String sKeyName = JValue.SolveStr(jNodeKey,".name")
					Int jNodeKeyValues = JValue.SolveObj(jNodeKey,".values")
					Int iValue = JArray.Count(jNodeKeyValues)
					While iValue > 0
						iValue -= 1
						Int jNodeKeyValue = JArray.GetObj(jNodeKeyValues,iValue)
						Float fData = JValue.SolveFlt(jNodeKeyValue,".data")
						Int iType = JValue.SolveInt(jNodeKeyValue,".type")
						If iType == 4 && fData && fData != 1
							;DebugTraceAPIDopp(asSID,"Scaling NINode " + sNodeName + " to " + fData + "!")
							NetImmerse.SetNodeScale(akActor,sNodeName,fData,bFirstPerson)
						EndIf
					EndWhile
				EndWhile
			EndIf
		EndWhile
		Return 0
	EndIf

	Int jNINodeData = JValue.SolveObj(jCharacterData,".NINodeData")

	Int jNiNodeNameList = JMap.AllKeys(jNINodeData)
	Int jNiNodeValueList = JMap.AllValues(jNINodeData)
	i = JArray.Count(jNiNodeNameList)
	While i > 0
		i -= 1
		String sNodeName = JArray.GetStr(jNiNodeNameList,i)
		If sNodeName
			Int jNINodeValues = JArray.GetObj(jNiNodeValueList,i)
			Float fNINodeScale = JMap.GetFlt(jNINodeValues,"Scale")
			;DebugTraceAPIDopp(asSID,"Scaling NINode " + sNodeName + " to " + fNINodeScale + "!")
			NetImmerse.SetNodeScale(akActor,sNodeName,fNINodeScale,False)
			NetImmerse.SetNodeScale(akActor,sNodeName,fNINodeScale,True)
		EndIf
	EndWhile
	Return 0
EndFunction

Int Function UpdateNIOverlays(String asSID, Actor akActor) Global 
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	Int jOverlayData = JValue.SolveObj(jCharacterData,".NIOverrideData")

	If !jOverlayData
		Return 0 
	EndIf

	If !NiOverride.HasOverlays(akActor)
		NiOverride.AddOverlays(akActor)
	EndIf
	
	NiOverride.RevertOverlays(akActor)
	ApplyNIOverlay(akActor,JMap.GetObj(jOverlayData,"BodyOverlays"),"Body [Ovl")
	ApplyNIOverlay(akActor,JMap.GetObj(jOverlayData,"HandOverlays"),"Hand [Ovl")
	ApplyNIOverlay(akActor,JMap.GetObj(jOverlayData,"FeetOverlays"),"Feet [Ovl")
	ApplyNIOverlay(akActor,JMap.GetObj(jOverlayData,"FaceOverlays"),"Face [Ovl")

	Return 1
EndFunction

Function ApplyNIOverlay(Actor akActor, Int ajLayers, String asNodeTemplate) Global
	If !akActor
		Return
	EndIf
	Int iLayerCount = JArray.Count(ajLayers)
	Int i = 0
	Bool bIsFemale = akActor.GetActorBase().GetSex()
	While i < iLayerCount
		Int jLayer = JArray.GetObj(ajLayers,i)
		String sNodeName = asNodeTemplate + i + "]"

		NiOverride.AddNodeOverrideInt(akActor, bIsFemale, sNodeName, 7, -1, JMap.GetInt(jLayer,"RGB"), True) ; Set the tint color
		NiOverride.AddNodeOverrideFloat(akActor, bIsFemale, sNodeName, 8, -1, JMap.GetFlt(jLayer,"Alpha"), True) ; Set the alpha
		NiOverride.AddNodeOverrideString(akActor, bIsFemale, sNodeName, 9, 0, JMap.GetStr(jLayer,"Texture"), True) ; Set the tint texture

		Int iGlowData = JMap.GetInt(jLayer,"GlowData")
		Int iGlowColor = iGlowData
		Int iGlowEmissive = Math.RightShift(iGlowColor, 24)
		NiOverride.AddNodeOverrideInt(akActor, bIsFemale, sNodeName, 0, -1, iGlowColor, True) ; Set the emissive color
		NiOverride.AddNodeOverrideFloat(akActor, bIsFemale, sNodeName, 1, -1, iGlowEmissive / 10.0, True) ; Set the emissive multiple
		i += 1
	EndWhile
EndFunction

Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName) Global
	Bool bResult
	Int iDismountSafetyTimer = 10
	While akActor.IsOnMount() && iDismountSafetyTimer
		iDismountSafetyTimer -= 1
		Bool bDismountSent = akActor.Dismount()
		Wait(1)
	EndWhile
	If !iDismountSafetyTimer
		;DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + " Dismount timer expired!",1)
	EndIf
	If akActor.IsOnMount()
		;Debug.Trace("MYC: (" + asCharacterName + "/Actor) Actor is still mounted, will not apply CharGen data!",2)
		Return False
	EndIf
	;Debug.Trace("MYC: (" + asCharacterName + "/Actor) Checking for Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	Bool bExternalHeadExists = JContainers.fileExistsAtPath("Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	If CharGen.IsExternalEnabled()
		If !bExternalHeadExists
			;DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + ": Warning, IsExternalEnabled is true but no head NIF exists, will use LoadCharacter instead!",1)
			bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + asCharacterName + ": IsExternalEnabled is true, using LoadExternalCharacter...")
		bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
		Return bResult
	Else
		If bExternalHeadExists
			;DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + ": Warning, external head NIF exists but IsExternalEnabled is false, using LoadExternalCharacter instead...",1)
			bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + asCharacterName + ": IsExternalEnabled is false, using LoadCharacter...")
		bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
		WaitMenuMode(1)
		akActor.RegenerateHead()
		Return bResult
	EndIf
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20) Global
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety As Bool
EndFunction

;=== Equipment and inventory functions ===--

Int Function EquipDefaultGear(String asSID, Actor akActor, Bool abLockEquip = False) Global 
{Re-equip the gear this character was saved with, optionally locking it in place.
 abLockEquip: (Optional) Lock equipment in place, so AI cannot remove it automatically.
 Returns: Number of items processed.}
;FIXME: This may fail to equip the correct item if character has both the base 
;and a customized version of the same item in their inventory
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	Int jCharacterArmor = JValue.SolveObj(jCharacterData,".Equipment.Armor")
	Int jCharacterArmorInfo = JValue.SolveObj(jCharacterData,".Equipment.ArmorInfo")

	Actor kCharacterActor = akActor
	
	Int i = JArray.Count(jCharacterArmorInfo)
	Int iCount = 0
	While i > 0
		i -= 1
		Int jArmor = JArray.GetObj(jCharacterArmorInfo,i)
		Form kItem = JMap.GetForm(jArmor,"Form")
		If !akActor.IsEquipped(kItem)
			kCharacterActor.EquipItemEx(kItem,0,abLockEquip,True)
			iCount += 1
		EndIf
	EndWhile
	Form kItemL = JValue.SolveForm(jCharacterData,".Equipment.Left.Form")
	Form kItemR = JValue.SolveForm(jCharacterData,".Equipment.Right.Form")
	If !akActor.IsEquipped(kItemL)
		kCharacterActor.EquipItemEx(kItemL,2,abLockEquip,True)
		iCount += 1
	EndIf
	If !akActor.IsEquipped(kItemR)
		kCharacterActor.EquipItemEx(kItemR,1,abLockEquip,True)
		iCount += 1
	EndIf
	Form kAmmo = JValue.SolveForm(jCharacterData,".Equipment.Ammo")
	If kAmmo
		If !kCharacterActor.GetItemCount(kAmmo)
			kCharacterActor.AddItem(kAmmo,1,True)
		EndIf
		kCharacterActor.EquipItemEx(kAmmo,0,abLockEquip,True)
		iCount += 1
	EndIf
	Return iCount
EndFunction

Int Function UpdateArmor(String asSID, Actor akActor, Bool abReplaceMissing = True, Bool abFullReset = False) Global 
{Setup equipped Armor based on the saved character data.}
	Int i
	Int iCount
	
	ActorBase kActorBase = akActor.GetActorBase()
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)

	;DebugTraceAPIDopp(asSID,"Applying Armor...")
	
	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdateArmor called but jCharacterData is missing!",1)
		Return -3
	EndIf
	
	Int jCharacterArmor = JValue.SolveObj(jCharacterData,".Equipment.Armor")
	Int jCharacterArmorInfo = JValue.SolveObj(jCharacterData,".Equipment.ArmorInfo")

	Actor kCharacterActor = akActor
	
	i = JArray.Count(jCharacterArmorInfo)
	While i > 0
		i -= 1

		String sItemID = JValue.SolveStr(JArray.GetObj(jCharacterArmorInfo,i),".UUID")
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)

		If kObject
			Int h = (kObject.GetBaseObject() as Armor).GetSlotMask()
			kObject.SetActorOwner(kActorBase)
			kCharacterActor.AddItem(kObject,1,True)
			kCharacterActor.EquipItemEx(kObject.GetBaseObject(),0,True,True) ; By default do not allow unequip, otherwise they strip whenever they draw a weapon.
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
			;DebugTraceAPIDopp(asSID,"Couldn't create an ObjectReference for " + sItemID + "!",1)
		EndIf
	EndWhile

	Return iCount
EndFunction

Int Function UpdateWeapons(String asSID, Actor akActor, Bool abReplaceMissing = True, Bool abFullReset = False) Global 
{Setup equipped Weapons and Ammo based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
	Int i
	Int iCount
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()
	;DebugTraceAPIDopp(asSID,"Applying Weapons...")
	
	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdateWeapons called but jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = akActor
	
	Int iHand = 1 ; start with right
	While iHand >= 0
		Bool bTwoHanded = False
		String sHand = "Right"
		If iHand == 0
			sHand = "Left"
		EndIf
		String sItemID = JValue.SolveStr(jCharacterData,".Equipment." + sHand + ".UUID")
		;ObjectReference kObject = vMYC_API_Item.CreateObjectFromJObj(JValue.SolveObj(jCharacterData,".Equipment." + sHand))
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)

		If kObject
			kObject.SetActorOwner(kActorBase)
			If !(kObject.GetBaseObject() as Spell)
				kCharacterActor.AddItem(kObject,1,True)
			EndIf
			kCharacterActor.EquipItemEx(kObject.GetBaseObject(),iHand,False,True) ;FIXME: May need to use the Base form here?
			Weapon kWeapon = kObject.GetBaseObject() as Weapon
			If kWeapon
				If kWeapon.IsBow() || kWeapon.IsGreatsword() || kWeapon.IsWaraxe() || kWeapon.IsWarhammer()
					bTwoHanded = True
				EndIf
			EndIf
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			;DebugTraceAPIDopp(asSID,"Couldn't create an ObjectReference for " + sItemID + "!",1)
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
	If akActor.GetEquippedItemType(0) == 12
		bCrossBow = True
	ElseIf akActor.GetEquippedItemType(0) == 7
		bBow = True
	EndIf
	
	Float fBestAmmoDamage = 0.0
	Ammo kBestAmmo = JValue.SolveForm(jCharacterData,".Equipment.Ammo") as Ammo
	Bool bFindBestAmmo = False
	If !kBestAmmo && (bBow || bCrossbow)
		bFindBestAmmo = True
	EndIf
	If bFindBestAmmo 
		Int jAmmoFMap = JValue.SolveObj(jCharacterData,".Inventory.42") ; kAmmo
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
								;DebugTraceAPIDopp(asSID,"BestAmmo is now " + kBestAmmo.GetName())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndWhile
	EndIf
	If kBestAmmo
		akActor.EquipItemEx(kBestAmmo,0,False,False)
	EndIf
	
	Return iCount
EndFunction

Int Function UpdateInventory(String asSID, Actor akActor, Bool abReplaceMissing = True, Bool abFullReset = False) Global 
{Setup Inventory items based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
	Int i
	Int iCount

	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	;DebugTraceAPIDopp(asSID,"Applying Inventory...")
	
	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdateInventory called but jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = akActor
	
	Int jCustomItems = JValue.SolveObj(jCharacterData,".InventoryCustomItems")

	i = JArray.Count(jCustomItems)
	;DebugTraceAPIDopp(asSID,"Has " + i + " items to be customized!")
	While i > 0
		i -= 1
		String sItemID = JValue.SolveStr(JArray.GetObj(jCustomItems,i),".UUID")
		;ObjectReference kObject = vMYC_API_Item.CreateObjectFromJObj(JArray.GetObj(jCustomItems,i))
		ObjectReference kObject = vMYC_API_Item.CreateObject(sItemID)

		If kObject
			kObject.SetActorOwner(kActorBase)
			kCharacterActor.AddItem(kObject,1,True)
		Else ;kObject failed, weapon didn't get loaded/created for some reason
			;DebugTraceAPIDopp(asSID,"Couldn't create an ObjectReference for " + sItemID + "!",1)
		EndIf
		iCount += 1
	EndWhile

	Int jAmmoFMap = JValue.SolveObj(jCharacterData,".Inventory.42") ; kAmmo
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
	
	Int jPotionFMap = JValue.SolveObj(jCharacterData,".Inventory.46") ; kPotion
	Int	jPotionList = JFormMap.AllKeys(jPotionFMap)
	i = JArray.Count(jPotionList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jPotionList,i)
		If kItem
			Int iItemCount = JFormMap.GetInt(jPotionFMap,kItem)
			If (kItem as Potion)
				If !(kItem as Potion).IsFood() ;.HasKeywordString("VendorItemFood")
					akActor.AddItem(kItem,iItemCount,True)
					iCount += iItemCount
				EndIf
			EndIf
		EndIf
	EndWhile
	
	Return iCount
EndFunction

;=== Stats ===--

Int Function UpdateStats(String asSID, Actor akActor, Bool abForceValues = False) Global
{Apply AVs and other stats like health. 
 abForceValues: (Optional) Set values absolutely, ignoring any buffs or nerfs from enchantments/magiceffects.
 Returns: -1 for generic failure.}
	Int i
	Int iCount
	
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	;DebugTraceAPIDopp(asSID,"Applying Perks...")

	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdatePerks called but jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = akActor

	Int jStats = JValue.SolveObj(jCharacterData,".Stats")
	Int jAVs = JValue.SolveObj(jCharacterData,".Stats.AV")
	
	Int jAVNames = JMap.AllKeys(jAVs)
	i = JArray.Count(jAVNames)
	While i > 0
		i -= 1
		String sAVName = JArray.GetStr(jAVNames,i)
		If sAVName
			Float fAV = JMap.GetFlt(jAVS,sAVName)
			If abForceValues
				akActor.ForceActorValue(sAVName,fAV)
				;;DebugTraceAPIDopp(asSID,"Force " + sAVName + " to " + fAV + " - GetBase/Get returns " + GetBaseActorValue(sAVName) + "/" + GetActorValue(sAVName) + "!")
			Else
				akActor.SetActorValue(sAVName,fAV) 
				;;DebugTraceAPIDopp(asSID,"Set " + sAVName + " to " + fAV + " - GetBase/Get returns " + GetBaseActorValue(sAVName) + "/" + GetActorValue(sAVName) + "!")
			EndIf
		EndIf
	EndWhile
	
	Return JArray.Count(jAVNames)
EndFunction

;=== Perks ===--

Int Function UpdatePerks(String asSID, Actor akActor) Global
{Apply perks.
 Returns:  for failure, or number of perks applied for success.}
	Int i
	Int iCount

	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	;FIXME: Compatibility Formlists should probably be provided by another API rather than by GetFormFromFile.
	FormList vMYC_ModCompatibility_PerkList_Unsafe = Game.GetFormFromFile(0x0202573e, "vMYC_MeetYourCharacters.esp") as FormList
	vMYC_DataManager DataManager = Quest.GetQuest("vMYC_DataManagerQuest") as vMYC_DataManager



	;DebugTraceAPIDopp(asSID,"Applying Perks...")

	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdatePerks called but jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = akActor
	
	Int jPerks = JValue.SolveObj(jCharacterData,".Perks")

	Formlist kPerklist = DataManager.LockFormList()
	kPerkList.Revert() ; Should already be empty, but just in case

	i = JArray.Count(jPerks)
	;DebugTraceAPIDopp(asSID,"Has " + i + " perks to be checked!")
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
		;;DebugTraceAPIDopp(asSID,"Adding perk " + kPerk + " (" + kPerk.GetName() + ") to list...")
	EndWhile
	Int iPerkCountTotal = kPerklist.GetSize()
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + kPerklist.GetSize() + " perks to Actorbase...")
	If iPerkCountTotal + iMissingCount != JArray.Count(jPerks)
		Debug.Trace("PerkList size mismatch, probably due to simultaneous calls. Aborting!",1)
		DataManager.UnlockFormlist(kPerklist)
		Return -1
	ElseIf iPerkCountTotal == 0
		;DebugTraceAPIDopp(asSID,"PerkList size is 0. Won't attempt to apply this.")
		DataManager.UnlockFormlist(kPerklist)
		Return 0
	EndIf
	If iMissingCount
		;DebugTraceAPIDopp(asSID,"Loading " + iPerkCountTotal + " Perks with " + iMissingCount + " skipped...")
	Else
		;DebugTraceAPIDopp(asSID,"Loading " + iPerkCountTotal + " Perks...")
	EndIf
	FFUtils.LoadCharacterPerks(kActorBase,kPerklist)
	;DebugTraceAPIDopp(asSID,"Perks loaded successfully!")
	WaitMenuMode(0.1)
	DataManager.UnlockFormlist(kPerklist)
	Return iPerkCountTotal
EndFunction

;=== Shouts ===--

Int Function UpdateShouts(String asSID, Actor akActor) Global
{Apply shouts to named character. Needed because AddShout causes savegame corruption.
 Returns: -1 for failure, or number of shouts applied for success.}
;FIXME: I bet this could be done with FFUtils and avoid using the FormList.
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vMYC_DataManager DataManager = Quest.GetQuest("vMYC_DataManagerQuest") as vMYC_DataManager

	Int jShouts = JValue.SolveObj(jCharacterData,".Shouts")
	

	Formlist kShoutlist = DataManager.LockFormList()
	kShoutlist.Revert() ; Should already be empty, but just in case
	
	Int i = JArray.Count(jShouts)
	Int iMissingCount = 0

	Actor PlayerREF = Game.GetPlayer()

	While i > 0
		i -= 1
		Shout kShout = JArray.getForm(jShouts,i) as Shout
		If !kShout
			iMissingCount += 1
		Else
			Shout kStormCallShout = GetFormFromFile(0x0007097D,"Skyrim.esm") as Shout
			Shout kCallDragonShout = GetFormFromFile(0x00046b8c,"Skyrim.esm") as Shout
			Shout kDragonAspectShout
			Shout kDLC1SummonDragonShout
			If GetModByName("Dawnguard.esm")
				kDLC1SummonDragonShout = GetFormFromFile(0x020030d2,"Dawnguard.esm") as Shout
			EndIf
			If GetModByName("Dragonborn.esm")
				kDragonAspectShout = GetFormFromFile(0x0201DF92,"DragonBorn.esm") as Shout
			EndIf
			If kShout == kStormCallShout && GetRegBool("Config.Shouts.Disabled.CallStorm")
				;Don't add it
			ElseIf kShout == kDragonAspectShout && GetRegBool("Config.Shouts.Disabled.DragonAspect") ;FIXME: Maybe use an array for disabled shouts, then test each one
				;Don't add it
			ElseIf kShout == kCallDragonShout
				;Never add Summon Dragon, it screws up the main quest and generally doesn't behave right
				;FIXME: Is there a way to fake these? It'd be cool to have imported characters use them.
			ElseIf kShout == kDLC1SummonDragonShout 
				;Never add Summon Duhrni-whatever, it screws up the quest order and causes crashes
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
	;DebugTraceAPIDopp(asSID,"Loading " + iShoutCount + " Shouts to Actorbase...")
	If iShoutCount == 0
		;DebugTraceAPIDopp(asSID,"ShoutList size is 0. Won't attempt to apply this.")
		DataManager.UnlockFormlist(kShoutlist)
		Return 0
	EndIf
	If iMissingCount
		;DebugTraceAPIDopp(asSID,"Loading " + iShoutCount + " Shouts with " + iMissingCount + " skipped.",1)
	Else
		;DebugTraceAPIDopp(asSID,"Loaded " + iShoutCount + " Shouts.")
	EndIf
	FFUtils.LoadCharacterShouts(kActorBase,kShoutlist)
	WaitMenuMode(0.1)
	DataManager.UnlockFormlist(kShoutlist)
	Return kShoutlist.GetSize()
EndFunction

Function RemoveCharacterShouts(String asSID,Actor akActor) Global
{Remove all shouts from specified character. Needed because RemoveShout causes savegame corruption.}
	
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vMYC_DataManager DataManager = Quest.GetQuest("vMYC_DataManagerQuest") as vMYC_DataManager

	;DebugTraceAPIDopp(asSID,"Character is not allowed to use shouts, removing them!")
	Formlist kShoutlist = DataManager.LockFormList()
	kShoutlist.Revert() ; Should already be empty, but just in case
	Shout vMYC_NullShout = GetFormFromFile(0x0201f055,"vMYC_MeetYourCharacters.esp") as Shout
	kShoutlist.AddForm(vMYC_NullShout)
	FFUtils.LoadCharacterShouts(kActorBase,kShoutlist)
	WaitMenuMode(0.1)
EndFunction


;=== Spell functions ===--

Int Function UpdateSpells(String asSID, Actor akActor) Global
{Apply Spells. 
 Returns: -1 for failure, or number of Spells applied for success.}
	Int jCharacterData = vMYC_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vMYC_DataManager DataManager = Quest.GetQuest("vMYC_DataManagerQuest") as vMYC_DataManager
	;FIXME: Compatibility Formlists should probably be provided by another API rather than by GetFormFromFile.
	FormList vMYC_ModCompatibility_SpellList_Safe 	= Game.GetFormFromFile(0x02024c6b, "vMYC_MeetYourCharacters.esp") as FormList 
	FormList vMYC_ModCompatibility_SpellList_Unsafe 	= Game.GetFormFromFile(0x02024c6c, "vMYC_MeetYourCharacters.esp") as FormList 
	FormList vMYC_ModCompatibility_SpellList_Healing = Game.GetFormFromFile(0x02024c6d, "vMYC_MeetYourCharacters.esp") as FormList 
	FormList vMYC_ModCompatibility_SpellList_Armor 	= Game.GetFormFromFile(0x02024c6e, "vMYC_MeetYourCharacters.esp") as FormList

	Int i
	Int iCount
	Int iAdded = 0
	Int iRemoved = 0
	;DebugTraceAPIDopp(asSID,"Applying Spells...")

	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdateSpells called but jCharacterData is missing!",1)
		Return -3
	EndIf

	If GetRegBool("Config.Compat.AFT.MagicDisabled")
		;Do not alter spell list if Magic is disabled by AFT
		Return 0
	EndIf
	
	Actor kCharacterActor = akActor
	
	Int jSpells = JValue.SolveObj(jCharacterData,".Spells")
	Int jSkillNames = GetRegObj("AVNames")

	JValue.Retain(jSpells,asSID + "Spells")

	If GetRegBool("Config.Magic.AutoSelect")
		i = 18
		While i < 23
			String sMagicSchool = JArray.GetStr(jSkillNames,i)
			;DebugTraceAPIDopp(asSID,"Checking perkCount for " + sMagicSchool + "...")
			Int iPerkCount = JValue.SolveInt(jCharacterData,".PerkCounts." + sMagicSchool)
			If iPerkCount
				;DebugTraceAPIDopp(asSID,"PerkCount for " + sMagicSchool + " is " + iPerkCount)
			EndIf
			
			If iPerkCount > 1
				SetSessionBool("Config." + asSID + ".Magic.Allow" + sMagicSchool,True)
			Else
				SetSessionBool("Config." + asSID + ".Magic.Allow" + sMagicSchool,False)
			EndIf
			i += 1
		EndWhile
	EndIf
	
	i = JArray.Count(jSpells)
	
	While i > 0
		i -= 1
		Spell kSpell = JArray.GetForm(jSpells,i) As Spell
		If kSpell
			String sMagicSchool = kSpell.GetNthEffectMagicEffect(0).GetAssociatedSkill()
			Bool bSpellIsAllowed = False
			
			If sMagicSchool
				bSpellIsAllowed = GetSessionBool("Config." + asSID + ".Magic.Allow" + sMagicSchool)
			Else
				bSpellIsAllowed = GetSessionBool("Config." + asSID + ".Magic.AllowOther")
			EndIf
			
			MagicEffect kMagicEffect = kSpell.GetNthEffectMagicEffect(0)
			
			If GetSessionBool("Config." + asSID + ".Magic.AllowHealing") ;sMagicSchool == "Restoration" && 
				If kMagicEffect.HasKeywordString("MagicRestoreHealth") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
					bSpellIsAllowed = True
				ElseIf vMYC_ModCompatibility_SpellList_Healing.HasForm(kSpell)
					bSpellIsAllowed = True
				EndIf
			EndIf
			
			If GetSessionBool("Config." + asSID + ".Magic.AllowDefensive")
				If kMagicEffect.HasKeywordString("MagicArmorSpell") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
					bSpellIsAllowed = True
				ElseIf vMYC_ModCompatibility_SpellList_Armor.HasForm(kSpell)
					bSpellIsAllowed = True
				EndIf
			EndIf

			If GetModByName("Dawnguard.esm")
				Spell kDLC01SummonSoulHorse = Game.GetFormFromFile(0x0200C600, "Dawnguard.esm") as Spell
				If kSpell == kDLC01SummonSoulHorse
					bSpellIsAllowed = False
				EndIf
			EndIf

			If bSpellIsAllowed
				Int[] iAllowedSources = New Int[128]
				
				iAllowedSources[0] = GetModByName("Skyrim.esm")
				iAllowedSources[1] = GetModByName("Update.esm")
				iAllowedSources[2] = GetModByName("Dawnguard.esm")
				iAllowedSources[3] = GetModByName("Dragonborn.esm")
				iAllowedSources[4] = GetModByName("Hearthfires.esm")

				If GetSessionBool("Config." + asSID + ".Magic.AllowSelectMods") ; Select mods
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
				
			
			If bSpellIsAllowed && !akActor.HasSpell(kSpell)
				If akActor.AddSpell(kSpell,False)
					;DebugTraceAPIDopp(asSID,"Added " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ") from " + GetModName(Math.RightShift(kSpell.GetFormID(),24)))
					iAdded += 1
				EndIf
			ElseIf !bSpellIsAllowed && akActor.HasSpell(kSpell)
				;Remove only if it is hostile, or has a duration, or has an associated cost discount perk. This way we avoid stripping perk, race, and doom stone abilities
				If kMagicEffect.IsEffectFlagSet(0x00000001) || kSpell.GetPerk() || kSpell.GetNthEffectDuration(0) > 0
					If akActor.RemoveSpell(kSpell)
						;DebugTraceAPIDopp(asSID,"Removed " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ")")
						iRemoved += 1
					EndIf
				EndIf
			EndIf
		Else
			;DebugTraceAPIDopp(asSID,"Couldn't create Spell from " + JArray.GetForm(jSpells,i) + "!")
		EndIf
	EndWhile
	If iAdded || iRemoved
		;DebugTraceAPIDopp(asSID,"Added " + iAdded + " spells, removed " + iRemoved)
	EndIf
	SaveSession()
	JValue.Release(jSpells)
	JValue.ReleaseObjectsWithTag(asSID + "Spells") ; just in case
	Return iAdded
EndFunction

;=== Utility functions ===--

Function DebugTraceAPIDopp(String asSID,String sDebugString, Int iSeverity = 0) Global
	Debug.Trace("MYC/API/Doppelganger/" + asSID + ": " + sDebugString,iSeverity)
EndFunction

String Function GetFormIDString(Form kForm) Global
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
