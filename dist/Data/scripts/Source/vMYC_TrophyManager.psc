Scriptname vMYC_TrophyManager extends vMYC_ManagerBase
{Handles registration and tracking of trophies.}

;=== [ vMYC_TrophyManager.psc ] ===========================================---
; Manager for Trophies.
; Handles:
;  Tracking of Trophy forms, templates, and placed objects
;  Placement and display of Trophy forms
;========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--


;=== Properties ===--

Actor 				Property PlayerRef 								Auto
{The Player, duh.}

Static				Property vMYC_AlcoveTrophyPlacementMarker		Auto

Form				Property vMYC_TrophyBannerHangingMarker			Auto
Form				Property vMYC_TrophyBannerStandingMarker		Auto

FormList			Property vMYC_BannerAnchors						Auto

ObjectReference[]	Property HangingBannerTemplates					Auto

Bool				Property ReadyToDisplay 						Auto

;=== Achievement test Properties ===--

;=== Variables ===--

ObjectReference	TrophyPlacementMarker
Float			fLastRegTime

;=== Events ===--

Event OnInit()
	If IsRunning()
		SetRegObj("Trophies",0)
		SetSessionObj("TrophyDisplayTargets",JFormMap.Object())
		fLastRegTime = GetCurrentRealTime()
		RegisterForSingleUpdate(5)
	EndIf
EndEvent

Event OnGameReload()
	ReadyToDisplay = False
	fLastRegTime = GetCurrentRealTime()
	RegisterForSingleUpdate(5)
EndEvent

Event OnUpdate()
	If !ReadyToDisplay
		SendTrophyManagerReady()
	EndIf
	If GetCurrentRealTime() - fLastRegTime > 8
		DebugTrace("All trophies appear to be registered!")
		ReadyToDisplay = True
	Else
		ReadyToDisplay = False
		RegisterForSingleUpdate(2)
	EndIf
EndEvent

Event OnTrophyRegister(String asTrophyName, Form akTrophyForm)
{Register a new TrophyBase object.}
	fLastRegTime = GetCurrentRealTime()
	ReadyToDisplay = False
	DebugTrace("Registering " + akTrophyform + " (" + asTrophyName + ")...")
	vMYC_TrophyBase kTrophy = akTrophyForm as vMYC_TrophyBase
	Int jTrophy = JMap.Object()
	JMap.SetStr(jTrophy,"Name",asTrophyName)
	JMap.SetForm(jTrophy,"Form",kTrophy)
	JMap.SetInt(jTrophy,"Version",kTrophy.TrophyVersion)
	JMap.SetInt(jTrophy,"Priority",kTrophy.TrophyPriority)
	JMap.SetStr(jTrophy,"Source",FFUtils.GetSourceMod(kTrophy))
	JMap.SetInt(jTrophy,"Loc",kTrophy.TrophyLoc)
	JMap.SetInt(jTrophy,"Size",kTrophy.TrophySize)
	JMap.SetInt(jTrophy,"Type",kTrophy.TrophyType)
	JMap.SetInt(jTrophy,"Extras",kTrophy.TrophyExtras)
	JMap.SetInt(jTrophy,"Flags",kTrophy.TrophyFlags)
	JMap.SetInt(jTrophy,"Enabled",kTrophy.Enabled as Int)
	SetRegObj("Trophies." + asTrophyName,jTrophy)

	RegisterForSingleUpdate(2)
EndEvent

Function SendTrophyManagerReady()
{Sent once initialization is done to let TrophyBases know they can register themselves.}
	DebugTrace("Checking trophies!")
	RegisterForModEvent("vMYC_TrophyRegister","OnTrophyRegister")
	Int iHandle = ModEvent.Create("vMYC_TrophyManagerReady")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING! Could not send vMYC_TrophyRegister event!",1)
	EndIf
EndFunction

Int Function PlaceTrophies(ObjectReference akTargetObject, String sCharacterID)
{Place all Trophies earned by sCharacterID around akTargetObject. Trophies will not be displayed until DisplayTrophies is called.
 Returns: Number of trophies processed.}
	Int jCharacterTrophies = GetRegObj("Characters." + sCharacterID + ".Trophies")
	JValue.WriteToFile(jCharacterTrophies,JContainers.userDirectory() + "vMYC/displaytrophies.json")
	Int jTrophyNames = JMap.AllKeys(jCharacterTrophies)
	Int iCount = JArray.Count(jTrophyNames)
	Int i = 0
	While i < iCount
		String sTrophyName = JArray.GetStr(jTrophyNames,i)
		DebugTrace("(" + i + "/" + (iCount - 1) + "): Checking trophy " + sTrophyName + " for " + sCharacterID + "...")
		vMYC_TrophyBase kTrophyBase = GetRegForm("Trophies." + sTrophyName + ".Form") as vMYC_TrophyBase
		Int iTrophyFlags = JMap.GetInt(jCharacterTrophies,sTrophyName)
		If kTrophyBase && iTrophyFlags
			DebugTrace("(" + i + "/" + (iCount - 1) + "): Placing trophy " + sTrophyName + " with flags: " + iTrophyFlags + " for " + sCharacterID)
			kTrophyBase._Place(akTargetObject,iTrophyFlags,sCharacterID)
		EndIf
		i += 1
	EndWhile
	Return iCount
EndFunction

Int Function DisplayTrophies(ObjectReference akTargetObject, String sCharacterID, Bool abPlaceOnly = False)
{Display all Trophies earned by sCharacterID around akTargetObject. Optionally place without displaying.
 Returns: Number of trophies processed.}
	Int jCharacterTrophies = GetRegObj("Characters." + sCharacterID + ".Trophies")
	JValue.WriteToFile(jCharacterTrophies,JContainers.userDirectory() + "vMYC/displaytrophies.json")
	Int jTrophyNames = JMap.AllKeys(jCharacterTrophies)
	Int iCount = JArray.Count(jTrophyNames)
	Int i = 0
	While i < iCount
		String sTrophyName = JArray.GetStr(jTrophyNames,i)
		DebugTrace("(" + i + "/" + (iCount - 1) + "): Checking trophy " + sTrophyName + " for " + sCharacterID + "...")
		vMYC_TrophyBase kTrophyBase = GetRegForm("Trophies." + sTrophyName + ".Form") as vMYC_TrophyBase
		If kTrophyBase
			DebugTrace("(" + i + "/" + (iCount - 1) + "): Displaying trophy " + sTrophyName + " for " + sCharacterID)
			kTrophyBase._Display(akTargetObject)
		EndIf
		i += 1
	EndWhile
	Return iCount
EndFunction

Function SendDisplayAllEvent(ObjectReference akTargetObject)
{Send a ModEvent to all Trophies associated with akTargetObject telling them to display themselves.}
	DebugTrace("SendDisplayAllEvent(" + akTargetObject + ")")
	Int jTrophyNames = JMap.AllKeys(GetRegObj("Trophies"))
	Int iCount = JArray.Count(jTrophyNames)
	Int i = 0
	While i < iCount
		String sTrophyName = JArray.GetStr(jTrophyNames,i)
		vMYC_TrophyBase kTrophyBase = GetRegForm("Trophies." + sTrophyName + ".Form") as vMYC_TrophyBase
		kTrophyBase._Display(akTargetObject)
		Wait(0.25)
		i += 1
	EndWhile
EndFunction

Int Function GetFreeBannerForTarget(ObjectReference akTargetObject, String asBannerType = "Standing")
{Get the first available banner template of type asBannerType around akTargetObject.
 Returns: Index of banner template.}
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	If !jDisplayTarget
		jDisplayTarget = JMap.Object()
		JFormMap.SetObj(jDisplayTargets,akTargetObject,jDisplayTarget)
	EndIf
	Int jBannersDisabled = JValue.SolveObj(jDisplayTarget,".BannersDisabled." + asBannerType)
	Int jBannerCount = JValue.SolveInt(jDisplayTarget,".BannerCount." + asBannerType)
	Int iSafety = 15
	While JArray.FindInt(jBannersDisabled,jBannerCount) > -1 && iSafety
		jBannerCount += 1
		iSafety -= 1
	EndWhile
	JValue.SolveIntSetter(jDisplayTarget,".BannerCount." + asBannerType,jBannerCount + 1,True)
	SaveSession()
	Return jBannerCount
EndFunction

Function DisableBannerPosition(ObjectReference akTargetObject, Int aiPosition, String asBannerType = "Standing")
{Disable the banner template at position aiPosition. Used by Trophies that would otherwise block or clip that banner.}
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	If !jDisplayTarget
		jDisplayTarget = JMap.Object()
		JFormMap.SetObj(jDisplayTargets,akTargetObject,jDisplayTarget)
	EndIf
	Int jBannersDisabled = JValue.SolveObj(jDisplayTarget,".BannersDisabled." + asBannerType)
	If !jBannersDisabled
		jBannersDisabled = JArray.Object()
		JValue.SolveObjSetter(jDisplayTarget,".BannersDisabled." + asBannerType,jBannersDisabled,True)
	EndIf
	JArray.AddInt(jBannersDisabled,aiPosition)
	SaveSession()
EndFunction

Function RegisterTrophyObject(ObjectReference akTrophyObject, ObjectReference akTargetObject)
{Register a Trophy ObjectReference associated with akTargetObject.}
	;DebugTrace("RegisterTrophyObject(" + akTrophyObject + "," + akTargetObject + ")")
	;SetSessionFlt("TrophyDisplayTargets.LastUpdated." + GetFormIDString(akTargetObject),GetCurrentRealTime())
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	If !jDisplayTarget
		jDisplayTarget = JMap.Object()
		JFormMap.SetObj(jDisplayTargets,akTargetObject,jDisplayTarget)
	EndIf
	JMap.SetFlt(jDisplayTarget,"LastUpdated",GetCurrentRealTime())
	Int jDisplayedObjects = JMap.GetObj(jDisplayTarget,"Objects")
	If !jDisplayedObjects
		jDisplayedObjects = JArray.Object()
		JMap.SetObj(jDisplayTarget,"Objects",jDisplayedObjects)
	EndIf
	JArray.AddForm(jDisplayedObjects,akTrophyObject)
	;SaveSession()
EndFunction

Function DeleteTrophies(ObjectReference akTargetObject)
{Delete all registered Trophy objects associated with akTargetObject.}
	DebugTrace("DeleteTrophies(" + akTargetObject + ")")
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	Int jDisplayedObjects = JMap.GetObj(jDisplayTarget,"Objects")
	If jDisplayedObjects
		Int iCount = JArray.Count(jDisplayedObjects)
		Int i = 0
		While i < iCount
			ObjectReference kTrophyObject = JArray.GetForm(jDisplayedObjects,i) as ObjectReference
			If kTrophyObject
				If kTrophyObject as vMYC_TrophyObject
					(kTrophyObject as vMYC_TrophyObject).DeleteTrophyForm()
				EndIf
				(kTrophyObject as ObjectReference).Delete()
			EndIf
			i += 1
		EndWhile
	EndIf
	JFormMap.RemoveKey(jDisplayTargets,akTargetObject)
	SaveSession()
EndFunction

Function UpdateAvailabilityList()
{Update the Trophies available for the current player character. Relies on vMYC_TrophyBase@_IsAvailable.}
	DebugTrace("Updating trophy availability...")
	Int jTrophies = GetRegObj("Trophies")
	If !jTrophies
		DebugTrace("WARNING! No trophies found!",1)
	EndIf
	Int jTrophyNames = JMap.AllKeys(jTrophies)
	Int i = JArray.Count(jTrophyNames)
	While i > 0
		i -= 1
		String sTrophyName = JArray.GetStr(jTrophyNames,i)
		If sTrophyName
			vMYC_TrophyBase kTrophy = GetRegForm("Trophies." + sTrophyName + ".Form") as vMYC_TrophyBase
			If kTrophy
				Int iAvailable = kTrophy._IsAvailable()
				DebugTrace("Trophy " + sTrophyName + " reports availability of " + iAvailable)
				SetSessionInt("Trophies." + sTrophyName,iAvailable)
			Else
				DebugTrace("WARNING! Couldn't find form for " + sTrophyName + "!",1)
			EndIf
		EndIf
	EndWhile
EndFunction

ObjectReference Function GetTrophyOrigin()
{Returns: TrophyOrigin marker in Cell vMYC_AlcoveLayout.}
	;FIXME - For now always returns statue marker in vMYC_AlcoveLayout
	;Return GetFormFromFile(0x0203051d,"vMYC_MeetYourCharacters.esp") as ObjectReference (Mannequin)
	Return GetFormFromFile(0x02033e5b,"vMYC_MeetYourCharacters.esp") as ObjectReference ;(Actual origin marker)
EndFunction

ObjectReference Function GetTrophyOffsetOrigin()
{Returns: TrophyOffset marker in Cell vMYC_AlcoveLayout (for debugging purposes).}
	;FIXME - For now always returns statue marker in vMYC_AlcoveLayout
	;Return GetFormFromFile(0x02031C1E,"vMYC_MeetYourCharacters.esp") as ObjectReference
	Return GetFormFromFile(0x0202fed9,"vMYC_MeetYourCharacters.esp") as ObjectReference
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/TrophyManager: " + sDebugString,iSeverity)
EndFunction

Form Function GetHangingBannerMarker()
{Returns: Hanging banner base form.}
	Return vMYC_TrophyBannerHangingMarker
EndFunction

Form Function GetStandingBannerMarker()
{Returns: Standing banner base form.}
	Return vMYC_TrophyBannerStandingMarker
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
