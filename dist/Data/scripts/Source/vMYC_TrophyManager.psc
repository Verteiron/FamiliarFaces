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

;=== Achievement test Properties ===--

;=== Variables ===--

ObjectReference	TrophyPlacementMarker

;=== Events ===--

Event OnInit()
	If IsRunning()
		SetRegObj("Trophies",0)
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

Function CreatePlacementGrid()
	Int jTrophies = GetRegObj("Trophies")
	
	
	
	TrophyPlacementMarker = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveTrophyPlacementMarker,PlayerREF,5000)
	Debug.Trace("TrophyPlacementMarker has node TrophyPlinthObjectSmallRCenter " + TrophyPlacementMarker.HasNode("TrophyPlinthObjectSmallRCenter"))
	Debug.Trace("TrophyPlacementMarker has node TrophyPlinthBaseDecalCenter " + TrophyPlacementMarker.HasNode("TrophyPlinthBaseDecalCenter"))
	Form FXEmptyActivator = GetFormFromFile(0x000b79ff,"Skyrim.esm")
	Form FXCampFireBlue =  GetFormFromFile(0x000153c8,"skyrim.esm")
	Form BoneHumanSkull =  GetFormFromFile(0x000af5fc,"skyrim.esm")
	TextureSet vMYC_VampireSymbol =  GetFormFromFile(0x0200f9ee,"vMYC_MeetYourCharacters.esp") as TextureSet
	TextureSet vMYC_WerewolfSymbol =  GetFormFromFile(0x0200f9ef,"vMYC_MeetYourCharacters.esp") as TextureSet
	TextureSet thiefmark =  GetFormFromFile(0x00068531,"skyrim.esm") as TextureSet
	ObjectReference object1 = TrophyPlacementMarker.PlaceAtMe(FXCampFireBlue,abInitiallyDisabled = True)
	ObjectReference object2 = TrophyPlacementMarker.PlaceAtMe(BoneHumanSkull,abInitiallyDisabled = True)
	ObjectReference placer = TrophyPlacementMarker.PlaceAtMe(FXEmptyActivator)
	
	placer.MoveToNode(TrophyPlacementMarker,"TrophyPlinthBaseDecalRight")
	placer.SetAngle(0,0,0)
	placer.PlaceAtMe(thiefmark)
	placer.SetAngle(0,0,90)
	placer.PlaceAtMe(thiefmark)
	placer.SetAngle(0,0,180)
	placer.PlaceAtMe(thiefmark)
	placer.SetAngle(0,0,270)
	placer.PlaceAtMe(thiefmark)
	placer.MoveToNode(TrophyPlacementMarker,"TrophyPlinthBaseDecalCenter")
	placer.PlaceAtMe(thiefmark)
	
	object1.MoveToNode(TrophyPlacementMarker,"TrophyPlinthObjectLargeRFar")
	object2.MoveToNode(TrophyPlacementMarker,"TrophyPlinthObjectSmallRCenter")
	
	object1.EnableNoWait()
	object2.EnableNoWait()
	
EndFunction

ObjectReference Function GetTrophyOrigin()
;FIXME - For now always returns statue marker in vMYC_AlcoveLayout
	Return GetFormFromFile(0x0203051d,"vMYC_MeetYourCharacters.esp") as ObjectReference
EndFunction


Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/TrophyManager: " + sDebugString,iSeverity)
EndFunction
