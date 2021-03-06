Scriptname vFF_API_Doppelganger extends vFF_APIBase Hidden
{Manage saving and loading of Doppelgangers.}

; === [ vFF_API_Doppelganger.psc ] =======================================---
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
Import vFF_Registry
Import vFF_Session
Import vFF_API_Character

;=== Generic Functions ===--

Int Function GetCharacterJMap(String asSID) Global
	Int iRet = -2 ; SID not present
	String sRegKey = "Characters." + asSID
	Int jCharacterData = vFF_Registry.GetRegObj(sRegKey)
	If jCharacterData
		Return jCharacterData
	EndIf
	Return iRet
EndFunction

Function RefreshAll() Global
	DebugTraceAPIDopp(0,"Starting character refresh...")
	String[] sSIDList = vFF_API_Character.GetAllSIDs()
	Int i = sSIDList.Length
	While i > 0
		i -= 1
		vFFC_Doppelganger kDoppelganger = vFF_API_Doppelganger.GetActorForSID(sSIDList[i]) as vFFC_Doppelganger
		If kDoppelganger
			DebugTraceAPIDopp(sSIDList[i],"Calling OnGameReload!")
			kDoppelganger.OnGameReload()
		EndIf
	EndWhile
EndFunction

;=== Functions - Actorbase/Actor management ===--

ActorBase Function GetAvailableActorBase(Int aiSex, ActorBase akPreferredAB = None, Bool abLeveled = True) Global
{Returns the first available dummy actorbase of the right sex, optionally fetch the preferred one, optionally only choose unleveled ABs.}
	
	ActorBase kDoppelgangerBase = None
	Int jActorbaseMap = GetSessionObj("ActorbaseMap")
	
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

	If akPreferredAB
		If !JFormMap.GetStr(jActorbaseMap,akPreferredAB) ; If this AB is not already assigned in this session...
			If JArray.FindForm(jActorbasePool,akPreferredAB) > -1 ; ...and the the AB is the right sex and autolevel type...
				JFormMap.SetStr(jActorBaseMap,akPreferredAB,"Reserved")
				SaveSession()
				Return akPreferredAB
			EndIf
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

	Debug.Trace("vFF/API/Doppelganger/GetAvailableActorBase: Couldn't find an available ActorBase!",1)
	;== Either no more are available, or something else went wrong ===--
	Return None
EndFunction

String Function GetSIDForActor(Actor kActor) Global
	If (kActor as vFFC_Doppelganger)
		Return (kActor as vFFC_Doppelganger).SID
	EndIf
	Return ""
EndFunction

Actor Function GetActorForSID(String asSID) Global
	;Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	;Int jActorForms = JFormMap.AllKeys(jActorBaseMap)
	;Int jActorSIDs = JFormMap.AllValues(jActorBaseMap)
	;Int idx = JArray.FindStr(jActorSIDs,asSID)
	;If idx > -1
	;	Return JArray.GetForm(jActorForms,idx) as Actor
	;EndIf
	;Return None
	Return GetSessionForm("Doppelgangers." + asSID + ".Actor") as Actor
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
	vFFC_Doppelganger kDoppelganger = akActor as vFFC_Doppelganger
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
		vFFC_Doppelganger kDoppelganger = akActor as vFFC_Doppelganger
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
		Debug.Trace("vFF/API/Doppelganger/CreateDoppelganger: Invalid SID!",1)
		Return None
	EndIf

	String sName = GetCharacterName(asSID)
	Int iSex = GetCharacterSex(asSID)
	Race kRace = GetCharacterRace(asSID)

	If sName && iSex > -1 ;&& kRace
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
	ObjectReference kNowhere = Game.GetFormFromFile(0x00FF0004,"vFFC_FamiliarFaces.esp") As ObjectReference ; Marker in vFFC_StagingCell
	DebugTraceAPIDopp(asSID,"kNowhere is " + kNowhere)
	Actor kDoppelActor = kNowhere.PlaceAtMe(kDoppelgangerBase) as Actor
	vFFC_Doppelganger kDoppelScript = kDoppelActor as vFFC_Doppelganger
	kDoppelScript.AssignCharacter(asSID)
	Return kDoppelActor
EndFunction

Function DeleteDoppelganger(Actor akActor) Global
	vFFC_Doppelganger kDoppelganger = akActor as vFFC_Doppelganger
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
	vFFC_Doppelganger kDoppelganger = akActor as vFFC_Doppelganger
 	If !kDoppelganger
 		DebugTraceAPIDopp("SetFoe","Passed actor " + akActor + " is not a Doppelganger!",1)
 		Return iRet
 	EndIf
 	String sSID = kDoppelganger.SID
 	;FIXME: Avoid Gopher's bug, make sure they are NOT a follower before making them a baddie!
 	SetCharConfigInt(sSID,"Behavior.PlayerRelationship",-1)
 	SetCharConfigBool(sSID,"Behavior.VanishOnDeath",abVanishOnDeath)
 	;Return kDoppelganger.UpdateDisposition()
EndFunction

;=== Functions - Appearance ===--

Int Function UpdateAppearance(String asSID, Actor akActor) Global
	Race kRace = vFF_API_Character.GetCharacterRace(asSID) as Race
	String sCharacterName = vFF_API_Character.GetCharacterName(asSID)
	ActorBase kActorBase = akActor.GetActorBase()
	If !NiOverride.HasOverlays(akActor)
		NiOverride.AddOverlays(akActor)
	EndIf
	If kRace && sCharacterName
		Bool bInvulnerableState = kActorBase.IsInvulnerable()
		kActorBase.SetInvulnerable(True)
		Bool bCharGenSuccess = CharGenLoadCharacter(akActor,kRace,sCharacterName)
		kActorBase.SetInvulnerable(bInvulnerableState)

		If bCharGenSuccess
			Return 0
		EndIf
	EndIf
	DebugTraceAPIDopp(asSID,"Something went wrong during UpdateAppearance!",1)
	Return -1
EndFunction

Int Function UpdateNINodes(String asSID, Actor akActor) Global
	Int i

	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)

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
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	Int jOverlayData = JValue.SolveObj(jCharacterData,".NIOverrideData")

	If jOverlayData
		;Use old system to apply overlays
		If !NiOverride.HasOverlays(akActor)
			NiOverride.AddOverlays(akActor)
		EndIf

		
		NiOverride.RevertOverlays(akActor)
		ApplyNIOverlayOLD(akActor,JMap.GetObj(jOverlayData,"BodyOverlays"),"Body [Ovl")
		ApplyNIOverlayOLD(akActor,JMap.GetObj(jOverlayData,"HandOverlays"),"Hand [Ovl")
		ApplyNIOverlayOLD(akActor,JMap.GetObj(jOverlayData,"FeetOverlays"),"Feet [Ovl")
		ApplyNIOverlayOLD(akActor,JMap.GetObj(jOverlayData,"FaceOverlays"),"Face [Ovl")
		Return 1
	EndIf

	Int jOverrides = JValue.SolveObj(jCharacterData,".CharGenData.overrides")
	
	Int iCount = JArray.Count(jOverrides)
	If iCount
		If !NiOverride.HasOverlays(akActor)
			NiOverride.AddOverlays(akActor)
		EndIf
	EndIf
	
	Bool bIsFemale = akActor.GetActorBase().GetSex() as Bool
	DebugTraceAPIDopp(asSID,"UpdateNIOverlays: Found " + iCount + " overlays!")	
	Int i = 0
	While i < iCount
		Int jOverrideNode 	= JArray.GetObj(jOverrides,i)
		String sNodeName 	= JValue.solveStr(jOverrideNode,".node")
		Int jNodeValues 	= JValue.solveObj(jOverrideNode,".values")
		Int iValueCount		= JArray.Count(jNodeValues)
		DebugTraceAPIDopp(asSID,"UpdateNIOverlays: Found " + iValueCount + " values for " + sNodeName)
		Int j = 0
		While j < iValueCount
			Int jNodeValue 	= JArray.getObj(jNodeValues,j)
			Int iNodeIndex 	= JValue.solveInt(jNodeValue,".index")
			Int iNodeType 	= JValue.solveInt(jNodeValue,".type")
			Int iNodeKey 	= JValue.solveInt(jNodeValue,".key")

			Float 	fNodeValue
			Int 	iNodeValue
			String 	sNodeValue
			If iNodeType == 2 ; string
				sNodeValue = JValue.solveStr(jNodeValue,".data")
				NiOverride.AddNodeOverrideString(akActor, bIsFemale, sNodeName, iNodeKey, iNodeIndex, sNodeValue, True)
			ElseIf iNodeType == 3 ; int
				iNodeValue = JValue.solveInt(jNodeValue,".data")
				NiOverride.AddNodeOverrideInt(akActor, bIsFemale, sNodeName, iNodeKey, iNodeIndex, iNodeValue, True)
			ElseIf iNodeType == 4 ; float
				fNodeValue = JValue.solveFlt(jNodeValue,".data")
				NiOverride.AddNodeOverrideFloat(akActor, bIsFemale, sNodeName, iNodeKey, iNodeIndex, fNodeValue, True)
			EndIf
			j += 1
		EndWhile
		
		i += 1
	EndWhile
 ; 	"overrides": [
 ;      {
 ;        "node": "Body [Ovl0]",
 ;        "values": [
 ;          {
 ;            "data": 1949307143,
 ;            "index": -1,
 ;            "key": 7,
 ;            "type": 3
 ;          },
 ;          {
 ;            "data": 0.45490196347236633,
 ;            "index": -1,
 ;            "key": 8,
 ;            "type": 4
 ;          },
 ;          {
 ;            "data": "Actors\\Character\\Overlays\\FreckleMania\\Body\\BodyBigStandard.dds",
 ;            "index": 0,
 ;            "key": 9,
 ;            "type": 2
 ;          }
 ;        ]
 ;      }
 ;    ]

	Return 1
EndFunction

Function ApplyNIOverlay(Actor akActor, Int ajLayers, String asNodeTemplate) Global

EndFunction

Function ApplyNIOverlayOLD(Actor akActor, Int ajLayers, String asNodeTemplate) Global
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
		DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + " Dismount timer expired!",1)
	EndIf
	If akActor.IsOnMount()
		DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + " Actor is still mounted, will not apply CharGen data!",2)
		Return False
	EndIf
	;Debug.Trace("vFF: (" + asCharacterName + "/Actor) Checking for Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	Bool bExternalHeadExists = JContainers.fileExistsAtPath("Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	If CharGen.IsExternalEnabled()
		If !bExternalHeadExists
			;DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + ": Warning, IsExternalEnabled is true but no head NIF exists, will use LoadCharacter instead!",1)
			bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("vFF/Actor/" + asCharacterName + ": IsExternalEnabled is true, using LoadExternalCharacter...")
		bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
		Return bResult
	Else
		If bExternalHeadExists
			;DebugTraceAPIDopp("CharGenLoadCharacter",asCharacterName + ": Warning, external head NIF exists but IsExternalEnabled is false, using LoadExternalCharacter instead...",1)
			bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
			Return bResult
		EndIf
		;Debug.Trace("vFF/Actor/" + asCharacterName + ": IsExternalEnabled is false, using LoadCharacter...")
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
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
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
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)

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
		ObjectReference kObject = vFF_API_Item.CreateObject(sItemID)

		If kObject
			Int h = (kObject.GetBaseObject() as Armor).GetSlotMask()
			kObject.SetActorOwner(kActorBase)
			kCharacterActor.AddItem(kObject,1,True)
			kCharacterActor.EquipItemEx(kObject.GetBaseObject(),0,True,True) ; By default do not allow unequip, otherwise they strip whenever they draw a weapon.
			;== Load NIO dye, if applicable ===--
			If GetRegBool("Config.NIO.ArmorDye.Enabled")
				Int jArmor = vFF_API_Item.GetItemJMap(sItemID)
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
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
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
		;ObjectReference kObject = vFF_API_Item.CreateObjectFromJObj(JValue.SolveObj(jCharacterData,".Equipment." + sHand))
		ObjectReference kObject = vFF_API_Item.CreateObject(sItemID)

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

	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
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
		;ObjectReference kObject = vFF_API_Item.CreateObjectFromJObj(JArray.GetObj(jCustomItems,i))
		ObjectReference kObject = vFF_API_Item.CreateObject(sItemID)

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

	If GetCharConfigBool(asSID,"Stats.UseAutoLeveling")
		Armor vFFC_DummyArmor = (akActor as vFFC_Doppelganger).vFFC_DummyArmor
		DebugTraceAPIDopp(asSID," is an Autolevel actor, ignoring saved actor values and recalculating!")
		akActor.AddItem(vFFC_DummyArmor, 1, True)
		akActor.RemoveItem(vFFC_DummyArmor, 1)
		Return 0
	EndIf

	Int i
	Int iCount
	
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
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
				;DebugTraceAPIDopp(asSID,"Force " + sAVName + " to " + fAV + " - GetBase/Get returns " + akActor.GetBaseActorValue(sAVName) + "/" + akActor.GetActorValue(sAVName) + "!")
			Else
				akActor.SetActorValue(sAVName,fAV) 
				;DebugTraceAPIDopp(asSID,"Set " + sAVName + " to " + fAV + " - GetBase/Get returns " + akActor.GetBaseActorValue(sAVName) + "/" + akActor.GetActorValue(sAVName) + "!")
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

	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	;FIXME: Compatibility Formlists should probably be provided by another API rather than by GetFormFromFile.
	FormList vFFC_ModCompatibility_PerkList_Unsafe = Game.GetFormFromFile(0x02ff006d, "vFFC_FamiliarFaces.esp") as FormList
	vFFC_DataManager DataManager = Quest.GetQuest("vFFC_DataManagerQuest") as vFFC_DataManager

	;DebugTraceAPIDopp(asSID,"Applying Perks...")

	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdatePerks called but jCharacterData is missing!",1)
		Return -3
	EndIf

	Actor kCharacterActor = akActor
	
	Int jPerks = JValue.SolveObj(jCharacterData,".Perks")

	;Formlist kPerklist = DataManager.LockFormList()
	;kPerkList.Revert() ; Should already be empty, but just in case

	i = JArray.Count(jPerks)
	
	Form[] akAllowedPerks = CreateFormArray(i)

	;DebugTraceAPIDopp(asSID,"Has " + i + " perks to be checked!")
	Int iMissingCount = 0
	While i > 0
		i -= 1
		Perk kPerk = JArray.getForm(jPerks,i) as Perk
		If !kPerk
			iMissingCount += 1
		Else
			If vFFC_ModCompatibility_PerkList_Unsafe.HasForm(kPerk)
				iMissingCount += 1
			Else
				;kPerklist.AddForm(kPerk)
				akAllowedPerks[i] = kPerk
			EndIf
		EndIf
		;Debug.Trace("vFF/CM/" + sCharacterName + ":  Perk is from " + JArray.getStr(jPerks,i))
		;;DebugTraceAPIDopp(asSID,"Adding perk " + kPerk + " (" + kPerk.GetName() + ") to list...")
	EndWhile
	Int iPerkCountTotal = akAllowedPerks.Length
	iPerkCountTotal -= iMissingCount
	;Int iPerkCountTotal = kPerklist.GetSize()
	;Debug.Trace("vFF/CM/" + sCharacterName + ":  Loading " + kPerklist.GetSize() + " perks to Actorbase...")
	;If iPerkCountTotal + iMissingCount != JArray.Count(jPerks)
	;	Debug.Trace("PerkList size mismatch, probably due to simultaneous calls. Aborting!",1)
	;	DataManager.UnlockFormlist(kPerklist)
	;	Return -1
	;ElseIf iPerkCountTotal == 0
	;	;DebugTraceAPIDopp(asSID,"PerkList size is 0. Won't attempt to apply this.")
	;	DataManager.UnlockFormlist(kPerklist)
	;	Return 0
	;EndIf
	If iMissingCount
		;DebugTraceAPIDopp(asSID,"Loading " + iPerkCountTotal + " Perks with " + iMissingCount + " skipped...")
	Else
		;DebugTraceAPIDopp(asSID,"Loading " + iPerkCountTotal + " Perks...")
	EndIf
	FFUtils.SetPerkList(kActorBase,akAllowedPerks)
	;FFUtils.LoadCharacterPerks(kActorBase,kPerklist)
	;DebugTraceAPIDopp(asSID,"Perks loaded successfully!")
	WaitMenuMode(0.1)
	;DataManager.UnlockFormlist(kPerklist)
	Return iPerkCountTotal
EndFunction

;=== Shouts ===--

Int Function UpdateShouts(String asSID, Actor akActor) Global
{Apply shouts to named character. Needed because AddShout causes savegame corruption.
 Returns: -1 for failure, or number of shouts applied for success.}
;FIXME: I bet this could be done with FFUtils and avoid using the FormList.
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vFFC_DataManager DataManager = Quest.GetQuest("vFFC_DataManagerQuest") as vFFC_DataManager

	Int jShouts = JValue.SolveObj(jCharacterData,".Shouts")
	Int jShoutsConfig = GetCharConfigObj(asSID,"Shouts")

	If JValue.SolveInt(jShoutsConfig,".Disabled")
		RemoveCharacterShouts(asSID, akActor)
		Return 0
	EndIf
	Int jShoutsBL = JValue.SolveObj(jShoutsConfig,".Blacklist")

	;Formlist kShoutlist = DataManager.LockFormList()
	;kShoutlist.Revert() ; Should already be empty, but just in case
	
	Int i = JArray.Count(jShouts)
	Form[] akAllowedShouts = CreateFormArray(i)

	Int iMissingCount = 0

	Actor PlayerREF = Game.GetPlayer()

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

	While i > 0
		i -= 1
		Shout kShout = JArray.getForm(jShouts,i) as Shout
		If !kShout
			iMissingCount += 1
		Else
			If JArray.FindForm(jShoutsBL,kShout) >= 0
				;Blacklisted by config, don't add it
				iMissingCount += 1
			ElseIf kShout == kStormCallShout && GetRegBool("Config.Shouts.Disabled.CallStorm")
				;Don't add it
				iMissingCount += 1
			ElseIf kShout == kDragonAspectShout && GetRegBool("Config.Shouts.Disabled.DragonAspect") ;FIXME: Maybe use an array for disabled shouts, then test each one
				;Don't add it
				iMissingCount += 1
			ElseIf kShout == kCallDragonShout
				;Never add Summon Dragon, it screws up the main quest and generally doesn't behave right
				;FIXME: Is there a way to fake these? It'd be cool to have imported characters use them.
				iMissingCount += 1
			ElseIf kShout == kDLC1SummonDragonShout 
				;Never add Summon Duhrni-whatever, it screws up the quest order and causes crashes
				iMissingCount += 1
			ElseIf GetRegBool("Config.Shouts.BlockUnlearned")
				If !PlayerREF.HasSpell(kShout)
					iMissingCount += 1
				EndIf
			Else
				akAllowedShouts[i] = kShout
				;kShoutlist.AddForm(kShout)		
			EndIf
		EndIf
		;Debug.Trace("vFF/CM/" + sCharacterName + ":  Adding Shout " + kShout + " (" + kShout.GetName() + ") to list...")
	EndWhile
	;Int iShoutCount = kShoutlist.GetSize()
	Int iShoutCount = akAllowedShouts.Length
	iShoutCount -= iMissingCount
	;DebugTraceAPIDopp(asSID,"Loading " + iShoutCount + " Shouts to Actorbase...")
	If iShoutCount == 0
		;DebugTraceAPIDopp(asSID,"ShoutList size is 0. Won't attempt to apply this.")
		;DataManager.UnlockFormlist(kShoutlist)
		Return 0
	EndIf
	If iMissingCount
		DebugTraceAPIDopp(asSID,"Loading " + iShoutCount + " Shouts with " + iMissingCount + " skipped.",1)
	Else
		DebugTraceAPIDopp(asSID,"Loaded " + iShoutCount + " Shouts.")
	EndIf
	FFUtils.SetShoutList(kActorBase,akAllowedShouts)
	;FFUtils.LoadCharacterShouts(kActorBase,kShoutlist)
	WaitMenuMode(0.1)
	;DataManager.UnlockFormlist(kShoutlist)
	Return iShoutCount
EndFunction

Function RemoveCharacterShouts(String asSID,Actor akActor) Global
{Remove all shouts from specified character. Needed because RemoveShout causes savegame corruption.}
	
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vFFC_DataManager DataManager = Quest.GetQuest("vFFC_DataManagerQuest") as vFFC_DataManager

	DebugTraceAPIDopp(asSID,"Character is not allowed to use shouts, removing them!")
	Formlist kShoutlist = DataManager.LockFormList()
	kShoutlist.Revert() ; Should already be empty, but just in case
	Shout vFFC_NullShout = GetFormFromFile(0x02ff0009,"vFFC_FamiliarFaces.esp") as Shout
	kShoutlist.AddForm(vFFC_NullShout)
	FFUtils.LoadCharacterShouts(kActorBase,kShoutlist)
	WaitMenuMode(0.1)
EndFunction


;=== Spell functions ===--

Int Function UpdateSpells(String asSID, Actor akActor, Bool bUseActorBase = True) Global
{Apply Spells. 
 bUseActorBase: If True, Spells are added to the ActorBase rather than the Actor and will thus ignore the RemoveSpell function.
                This is faster but may not always be the desired behavior.
 Returns: -1 for failure, or number of Spells applied for success.}
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	ActorBase kActorBase = akActor.GetActorBase()

	vFFC_DataManager DataManager = Quest.GetQuest("vFFC_DataManagerQuest") as vFFC_DataManager
	;FIXME: Compatibility Formlists should probably be provided by another API rather than by GetFormFromFile.
	FormList vFFC_ModCompatibility_SpellList_Safe 		= Game.GetFormFromFile(0x02ff0072, "vFFC_FamiliarFaces.esp") as FormList 
	FormList vFFC_ModCompatibility_SpellList_Unsafe 	= Game.GetFormFromFile(0x02ff0071, "vFFC_FamiliarFaces.esp") as FormList 
	FormList vFFC_ModCompatibility_SpellList_Healing 	= Game.GetFormFromFile(0x02ff0070, "vFFC_FamiliarFaces.esp") as FormList 
	FormList vFFC_ModCompatibility_SpellList_Armor 		= Game.GetFormFromFile(0x02ff006f, "vFFC_FamiliarFaces.esp") as FormList

	Int i
	Int iCount
	Int iAdded = 0
	Int iSkipped = 0
	String sReason = "Unknown"
	;DebugTraceAPIDopp(asSID,"Applying Spells...")

	If !jCharacterData
		;DebugTraceAPIDopp(asSID,"UpdateSpells called but jCharacterData is missing!",1)
		Return -3
	EndIf

	If GetConfigBool("Compat.AFT.MagicDisabled")
		;Do not alter spell list if Magic is disabled by AFT
		Return 0
	EndIf
	
	Actor kCharacterActor = akActor
	
	Int jSpells = JValue.SolveObj(jCharacterData,".Spells")
	Int jSkillNames = GetRegObj("AVNames")

	JValue.Retain(jSpells,asSID + "Spells")

	If vFF_API_Character.GetCharConfigInt(asSID,"Magic.AutoByPerks")
		i = 18
		While i < 23
			String sMagicSchool = JArray.GetStr(jSkillNames,i)
			;DebugTraceAPIDopp(asSID,"Checking perkCount for " + sMagicSchool + "...")
			Int iPerkCount = JValue.SolveInt(jCharacterData,".PerkCounts." + sMagicSchool)
			If iPerkCount
				;DebugTraceAPIDopp(asSID,"PerkCount for " + sMagicSchool + " is " + iPerkCount)
			EndIf
			
			If iPerkCount > 1
				SetCharConfigBool(asSID,"Magic.Allow" + sMagicSchool,True)
			Else
				SetCharConfigBool(asSID,"Magic.Allow" + sMagicSchool,False)
			EndIf
			i += 1
		EndWhile
	EndIf
	
	String[] sAllowedSources = New String[128]
				
	sAllowedSources[0] = "Skyrim.esm"
	sAllowedSources[1] = "Update.esm"
	sAllowedSources[2] = "Dawnguard.esm"
	sAllowedSources[3] = "Dragonborn.esm"
	sAllowedSources[4] = "Hearthfires.esm"
	sAllowedSources[5] = "Colorful_Magic.esp" ; FIXME: Test only!
	sAllowedSources[6] = "Animated Dragon Wings.esp" ; FIXME: Test only!

	Bool bAllowHealing = vFF_API_Character.GetCharConfigInt(asSID,"Magic.AllowHealing") as Bool
	Bool bAllowDefense = vFF_API_Character.GetCharConfigInt(asSID,"Magic.AllowDefense") as Bool
	Bool bBlockWallOfs = vFF_API_Character.GetCharConfigInt(asSID,"Magic.BlockWallOfs") as Bool
	Bool bDawnguard = False
	If GetModByName("Dawnguard.esm") != 255
		bDawnguard = True
	EndIf

	i = JArray.Count(jSpells)

	Form[] kCharacterSpells = DataManager.JObjToArrayForm(jSpells)
	String[] sSpellNames 	= FFUtils.GetItemNames(kCharacterSpells)
	Form[] kAllowedSpells 	= CreateFormArray(i)

	Int jAllowed = JArray.Object()
	Int jSkipped = JArray.Object()
	SetCharConfigObj(asSID,"Spells.Allowed",jAllowed)
	SetCharConfigObj(asSID,"Spells.Skipped",jSkipped)
	DebugTraceAPIDopp(asSID,"Filtering spells. AllowHealing:" + bAllowHealing + ", AllowDefense:" + bAllowDefense + ", BlockWalls:" + bBlockWallOfs + ", Dawnguard:" + bDawnguard)

	While i > 0
		i -= 1
		Spell kSpell = JArray.GetForm(jSpells,i) As Spell
		If kSpell
			Bool bDone 				= False
			Bool bSpellIsAllowed 	= True
			String sSpellName 		= sSpellNames[i]

			sReason = ""

			If vFFC_ModCompatibility_SpellList_Unsafe.HasForm(kSpell)
			;A mod author has added the spell to the unsafe list.
				bSpellIsAllowed = False
				bDone = True
				sReason = "Compatibility_SpellList_Unsafe"
			ElseIf bAllowHealing && vFFC_ModCompatibility_SpellList_Healing.HasForm(kSpell)
			;We always allow healing spells and a mod author has added the spell to the Healing list.
				bSpellIsAllowed = True
				bDone = True
				sReason = "AllowHealing + Compatibility_SpellList_Healing"
			ElseIf bAllowDefense && vFFC_ModCompatibility_SpellList_Armor.HasForm(kSpell)
			;We always allow defensive/armor spells and a mod author has added the spell to the Armor list.
				bSpellIsAllowed = True
				bDone = True
				sReason = "AllowDefense + Compatibility_SpellList_Armor"
			EndIf

			If !bDone
				String sSpellSource = FFUtils.GetSourceMod(kSpell)
				
				If sAllowedSources.Find(sSpellSource) > -1
				;Spell's source is on the compatible list.
					bSpellIsAllowed = True
					sReason += "Compatible source (" + sSpellSource + "), "
				ElseIf vFFC_ModCompatibility_SpellList_Safe.HasForm(kSpell)
				;A mod author has gone to the trouble of assuring us the spell is compatible.
					bSpellIsAllowed = True
					sReason += "Compatibility_SpellList_Safe (" + sSpellSource + "), "
				Else
					;Spell's source is not allowed.
					bSpellIsAllowed = False
					bDone = True
					sReason += "Blocked source (" + sSpellSource + ")"
				EndIf
			EndIf

			If !bDone

				If bDawnguard
					Spell kDLC01SummonSoulHorse = Game.GetFormFromFile(0x0200C600, "Dawnguard.esm") as Spell
					If kSpell == kDLC01SummonSoulHorse
						bSpellIsAllowed = False
						bDone = True
						sReason += "Player-only (kDLC01SummonSoulHorse)"
					EndIf
				EndIf

				MagicEffect[] kMagicEffects = kSpell.GetMagicEffects()
				Int iDeliveryType 			= kMagicEffects[0].GetDeliveryType()
				Int iCastingType 			= kMagicEffects[0].GetCastingType()
				Bool bIsHostile				= kSpell.IsHostile()
				Perk kSpellPerk				= kSpell.GetPerk()

				If iDeliveryType == 0 && iCastingType > 0 && !bIsHostile
					If bAllowHealing && !bDone
						If kMagicEffects[0].HasKeywordString("MagicRestoreHealth")
							bSpellIsAllowed = True
							bDone = True
							sReason += "AllowHealing + Self-targeted MagicRestoreHealth, "
						EndIf
					EndIf

					If bAllowDefense && !bDone
						If kMagicEffects[0].HasKeywordString("MagicArmorSpell")
							bSpellIsAllowed = True
							bDone = True
							sReason += "AllowDefense + Self-targeted MagicArmorSpell, "
						EndIf
					EndIf
				EndIf

				If !bDone
					String sMagicSchool = kMagicEffects[0].GetAssociatedSkill()
					If sMagicSchool
						bSpellIsAllowed = GetCharConfigInt(asSID,"Magic.Allow" + sMagicSchool) as Bool
					Else
						bSpellIsAllowed = GetCharConfigInt(asSID,"Magic.AllowOther") as Bool
					EndIf
					If sMagicSchool 
						If bSpellIsAllowed
							sReason += "Allowed school (" + sMagicSchool + "), "
						Else
							bDone = True
							sReason += "Blocked school (" + sMagicSchool + ")"
						EndIf
					EndIf
				EndIf				

				If !bDone && bBlockWallOfs
					If StringUtil.Find(sSpellName,"Wall of ") == 0
						bSpellIsAllowed = False
						bDone = True
						sReason += "Blocked wall spell"
					EndIf
				EndIf
			EndIf

			If bSpellIsAllowed
				kAllowedSpells[i] = kSpell
				iAdded += 1
				JArray.AddForm(JAllowed,kSpell)
				DebugTraceAPIDopp(asSID,"Allowed " + sSpellNames[i] + ": " + sReason)
			Else
				iSkipped += 1
				JArray.AddForm(JSkipped,kSpell)
				DebugTraceAPIDopp(asSID,"Skipped " + sSpellNames[i] + ": " + sReason)
			EndIf

		Else
			;DebugTraceAPIDopp(asSID,"Couldn't create Spell from " + JArray.GetForm(jSpells,i) + "!")
		EndIf
	EndWhile
	If bUseActorBase 
		;Use FFUtils function to add the spell to the ActorBase rather than the Actor.
		DebugTraceAPIDopp(asSID,"Adding " + kAllowedSpells.Length + " spells to ActorBase using SetSpellList!")
		FFUtils.SetSpellList(kActorBase,kAllowedSpells)
		Armor vFFC_DummyArmor = (akActor as vFFC_Doppelganger).vFFC_DummyArmor
		akActor.AddItem(vFFC_DummyArmor, 1, True)
		akActor.RemoveItem(vFFC_DummyArmor, 1)
	Else 
		;Add spells in the traditional way.
		i = JArray.Count(JAllowed)
		DebugTraceAPIDopp(asSID,"Adding " + i + " spells...")
		While i > 0
			i -= 1
			akActor.AddSpell(JArray.GetForm(JAllowed,i) as Spell, abVerbose = False)
		EndWhile
		;Remove all spells that weren't allowed.
		i = JArray.Count(JSkipped)
		DebugTraceAPIDopp(asSID,"Removing " + i + " spells...")
		While i > 0
			i -= 1
			akActor.RemoveSpell(JArray.GetForm(JSkipped,i) as Spell)
		EndWhile
	EndIf
	If iAdded || iSkipped
		DebugTraceAPIDopp(asSID,"Added " + iAdded + " spells, skipped " + iSkipped)
	EndIf
	JValue.Release(jSpells)
	JValue.ReleaseObjectsWithTag(asSID + "Spells") ; just in case
	SaveSession()
	Return iAdded
EndFunction

Int Function UpdateClass(String asSID, Actor akActor) Global
	ActorBase kActorBase = akActor.GetActorBase()
	Class kClass = GetSessionForm("Characters." + asSID + ".Class",True) as Class
	If !kClass
		kClass = GetCharConfigForm(asSID,"Class") as Class
	EndIf
	If !kClass
		Return -1
	EndIf
	If kActorBase.GetClass() && kActorBase.GetClass() != kClass
		kActorBase.SetClass(kClass)
	Else
		Return 0
	EndIf
	Return 1
EndFunction

Int Function UpdateCombatStyle(String asSID, Actor akActor) Global
	ActorBase kActorBase = akActor.GetActorBase()
	CombatStyle kCombatStyle = GetSessionForm("Characters." + asSID + ".CombatStyle",True) as CombatStyle
	If !kCombatStyle
		kCombatStyle = GetCharConfigForm(asSID,"CombatStyle") as CombatStyle
	EndIf
	If !kCombatStyle
		Return -1
	EndIf
	If kActorBase.GetCombatStyle() && kActorBase.GetCombatStyle() != kCombatStyle
		kActorBase.SetCombatStyle(kCombatStyle)
	Else
		Return 0
	EndIf
	Return 1
EndFunction

;=== Utility functions ===--

Function DebugTraceAPIDopp(String asSID,String sDebugString, Int iSeverity = 0) Global
	Debug.Trace("vFF/API/Doppelganger/" + asSID + ": " + sDebugString,iSeverity)
EndFunction

String Function GetFormIDString(Form kForm) Global
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
