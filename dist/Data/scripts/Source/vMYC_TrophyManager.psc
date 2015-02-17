Scriptname vMYC_TrophyManager extends vMYC_ManagerBase
{Handle registration and tracking of trophies.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--


;=== Properties ===--

Actor 				Property PlayerRef 								Auto
{The Player, duh}

Static				Property vMYC_AlcoveTrophyPlacementMarker		Auto

Form				Property vMYC_TrophyBannerHangingMarker			Auto
Form				Property vMYC_TrophyBannerStandingMarker		Auto

FormList			Property vMYC_BannerAnchors						Auto

ObjectReference[]	Property HangingBannerTemplates					Auto

;=== Achievement test Properties ===--

;=== Variables ===--

ObjectReference	TrophyPlacementMarker

;=== Events ===--

Event OnInit()
	If IsRunning()
		SetRegObj("Trophies",0)
		SetSessionObj("TrophyDisplayTargets",JFormMap.Object())
		RegisterForSingleUpdate(5)
	EndIf
EndEvent

Event OnGameReload()
	RegisterForSingleUpdate(5)
EndEvent

Event OnUpdate()
	SendTrophyManagerReady()
EndEvent

Event OnTrophyRegister(String asTrophyName, Form akTrophyForm)
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
EndEvent

Function SendTrophyManagerReady()
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

Int Function DisplayTrophies(ObjectReference akTargetObject, String sCharacterID, Bool abPlaceOnly = False)
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
		If kTrophyBase ;&& iTrophyFlags
			DebugTrace("(" + i + "/" + iCount + "): Displaying trophy " + sTrophyName + " with flags: " + iTrophyFlags + " for " + sCharacterID)
			kTrophyBase._Display(akTargetObject,iTrophyFlags,abPlaceOnly,sCharacterID)
		EndIf
		i += 1
	EndWhile
	Return iCount
EndFunction

Function SendDisplayAllEvent(ObjectReference akTargetObject)
	Int jTrophyNames = JMap.AllKeys(GetRegObj("Trophies"))
	Int iCount = JArray.Count(jTrophyNames)
	Int i = 0
	While i < iCount
		String sTrophyName = JArray.GetStr(jTrophyNames,i)
		vMYC_TrophyBase kTrophyBase = GetRegForm("Trophies." + sTrophyName + ".Form") as vMYC_TrophyBase
		kTrophyBase.SendDisplayEvent(akTargetObject)
		i += 1
	EndWhile
EndFunction

Int Function GetFreeBannerForTarget(ObjectReference akTargetObject, String asBannerType = "Standing")
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	If !jDisplayTarget
		jDisplayTarget = JMap.Object()
		JFormMap.SetObj(jDisplayTargets,akTargetObject,jDisplayTarget)
	EndIf
	Int jBannerCount = JValue.SolveInt(jDisplayTarget,".BannerCount." + asBannerType)
	JValue.SolveIntSetter(jDisplayTarget,".BannerCount." + asBannerType,jBannerCount + 1,True)
	Return jBannerCount
EndFunction

Function RegisterTrophyObject(ObjectReference akTrophyObject, ObjectReference akTargetObject)
	;DebugTrace("RegisterTrophyObject(" + akTrophyObject + "," + akTargetObject + ")")
	Int jDisplayTargets = GetSessionObj("TrophyDisplayTargets")
	Int jDisplayTarget = JFormMap.GetObj(jDisplayTargets,akTargetObject)
	If !jDisplayTarget
		jDisplayTarget = JMap.Object()
		JFormMap.SetObj(jDisplayTargets,akTargetObject,jDisplayTarget)
	EndIf
	Int jDisplayedObjects = JMap.GetObj(jDisplayTarget,"Objects")
	If !jDisplayedObjects
		jDisplayedObjects = JArray.Object()
		JMap.SetObj(jDisplayTarget,"Objects",jDisplayedObjects)
	EndIf
	JArray.AddForm(jDisplayedObjects,akTrophyObject)
	;SaveSession()
EndFunction

Function DeleteTrophies(ObjectReference akTargetObject)
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
;FIXME - For now always returns statue marker in vMYC_AlcoveLayout
	;Return GetFormFromFile(0x0203051d,"vMYC_MeetYourCharacters.esp") as ObjectReference (Mannequin)
	Return GetFormFromFile(0x02033e5b,"vMYC_MeetYourCharacters.esp") as ObjectReference ;(Actual origin marker)
EndFunction

ObjectReference Function GetTrophyOffsetOrigin()
;FIXME - For now always returns statue marker in vMYC_AlcoveLayout
	;Return GetFormFromFile(0x02031C1E,"vMYC_MeetYourCharacters.esp") as ObjectReference
	Return GetFormFromFile(0x0202fed9,"vMYC_MeetYourCharacters.esp") as ObjectReference
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/TrophyManager: " + sDebugString,iSeverity)
EndFunction

Form Function GetHangingBannerMarker()
	Return vMYC_TrophyBannerHangingMarker
EndFunction

Form Function GetStandingBannerMarker()
	Return vMYC_TrophyBannerStandingMarker
EndFunction
