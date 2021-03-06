Scriptname vFFC_MetaQuestScript extends vFFC_BaseQuest
{Do initialization and track variables for scripts.}

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry

;=== Properties ===--

Actor Property PlayerRef Auto

Bool Property Ready = False Auto

Float Property ModVersion Auto Hidden
Int Property ModVersionInt Auto Hidden

Int Property ModVersionMajor Auto Hidden
Int Property ModVersionMinor Auto Hidden
Int Property ModVersionPatch Auto Hidden

String Property ModName = "Familiar Faces" Auto Hidden

Message Property vFFC_ModLoadedMSG Auto
Message Property vFFC_ModUpdatedMSG Auto
Message Property vFFC_ModShutdownMSG Auto

vFFC_DataManager 	Property DataManager 	Auto

VisualEffect 	Property vFFC_FFLogoEffect 	Auto
;=== Config variables ===--

GlobalVariable Property vFFC_CFG_Changed Auto
GlobalVariable Property vFFC_CFG_Shutdown Auto
GlobalVariable Property vFFC_WaitForMQ Auto

;=== Variables ===--

Float _CurrentVersion
Int _iCurrentVersion
String _sCurrentVersion

Bool _ShowedSKSEWarning = False
Bool _ShowedJContainersWarning = False
Bool _Running
Bool _bVersionSystemUpdated = False

Bool _bShowedCompatibilityErrorSkyRE = False
Bool _bShowedCompatibilityErrorEFF = False
Bool _bShowedCompatibilityErrorAFT = False

Float _ScriptLatency
Float _StartTime
Float _EndTime

Int _iUpkeepsExpected
Int _iUpkeepsCompleted

;=== Events ===--

Event OnInit()
	DebugTrace("Metaquest event: OnInit - IsRunning: " + IsRunning() + " ModVersion: " + ModVersion + " ModVersionMajor: " + ModVersionMajor)
	If IsRunning() && ModVersion == 0 && !ModVersionMajor
		DoUpkeep(True)
	;Else
		;DoUpkeep(True)
	EndIf
EndEvent

Event OnReset()
	;DebugTrace("Metaquest event: OnReset")
EndEvent

Event OnUpdate()

EndEvent

Event OnGameReload()
	DebugTrace("Metaquest event: OnGameReload")
	;If vFFC_CFG_Shutdown.GetValue() != 0
		DoUpkeep(False)
	;EndIf
EndEvent

Event OnUpkeepState(string eventName, string strArg, float numArg, Form sender)
	If eventName == "vFFC_UpkeepBegin"
		_iUpkeepsExpected += 1
	ElseIf eventName == "vFFC_UpkeepEnd"
		_iUpkeepsCompleted += 1
		;DebugTrace("Metaquest Upkeep finished for " + sender + ". (" + _iUpkeepsCompleted + "/" + _iUpkeepsExpected + ")")
	EndIf
EndEvent

Event OnShutdown(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("OnShutdown!")
	Wait(0.1)
	DoShutdown()
EndEvent

;=== Functions ===--

Function DoUpkeep(Bool DelayedStart = True)
	DebugTrace("Metaquest event: DoUpkeep(" + DelayedStart + ")")
	_iUpkeepsExpected = 0
	_iUpkeepsCompleted = 0
	;FIXME: CHANGE THIS WHEN UPDATING!
	ModVersionMajor = 1
	ModVersionMinor = 9
	ModVersionPatch = 1
	If !CheckDependencies()
		AbortStartup()
		Return
	EndIf
	_iCurrentVersion = GetVersionInt(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	_sCurrentVersion = GetVersionString(_iCurrentVersion)
	String sModVersion = GetVersionString(ModVersion as Int)
	RegisterForModEvent("vFFC_InitBegin","OnInitState")
	RegisterForModEvent("vFFC_InitEnd","OnInitState")
	RegisterForModEvent("vFFC_UpkeepBegin","OnUpkeepState")
	RegisterForModEvent("vFFC_UpkeepEnd","OnUpkeepState")
	RegisterForModEvent("vFFC_Shutdown","OnShutdown")
	Ready = False
	If DelayedStart
		Wait(RandomFloat(3,5))
	EndIf
	
	;FIXME: Do this some other way!
	;Quest MQ101 = Quest.GetQuest("MQ101")
	;While vFFC_WaitForMQ.GetValue() > 0 && MQ101.IsRunning() && MQ101.GetCurrentStageID() < 900
	;	WaitMenuMode(10)
	;EndWhile
	
	String sErrorMessage
	SendModEvent("vFFC_UpkeepBegin")
	DebugTrace("" + ModName)
	DebugTrace("Performing upkeep...")
	DebugTrace("Loaded version is " + sModVersion + ", Current version is " + _sCurrentVersion)
	If ModVersion == 0
		DebugTrace("Newly installed, doing initialization...")
		DoInit()
		If ModVersion == _iCurrentVersion
			DebugTrace("Initialization succeeded.")
		Else
			DebugTrace("WARNING! Initialization had a problem!")
		EndIf
	ElseIf ModVersion < _iCurrentVersion
		DebugTrace("Installed version is older. Starting the upgrade...")
		DoUpgrade() ; this should also fire DoUpkeep
		If ModVersion != _iCurrentVersion
			DebugTrace("WARNING! Upgrade failed!")
			Debug.MessageBox("WARNING! " + ModName + " upgrade failed for some reason. You should report this to the mod author.")
		EndIf
		DebugTrace("Upgraded to " + GetVersionString(_iCurrentVersion))
		vFFC_ModUpdatedMSG.Show(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	Else
		;FIXME: Do init stuff in other quests
		vFF_API_Doppelganger.RefreshAll()
		DataManager.DoUpkeep(True)
;		ShrineOfHeroes.DoUpkeep()
;		HangoutManager.DoUpkeep()
		DebugTrace("Loaded, no updates.")
		;CheckForOrphans()
	EndIf
	CheckForExtras()
	UpdateConfig()
	DebugTrace("Upkeep complete!")
	Ready = True
	;HangoutManager.AssignActorToHangout(CharacterManager.GetCharacterActorByName("Kmiru"),"Blackreach")
	SendModEvent("vFFC_UpkeepEnd")
	;DataManager.LoadTestCharacter()
EndFunction

Function DoInit()
	;vFFC_ModLoadedMSG.Show(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	Debug.Notification("Familiar Faces will be ready in just a few seconds...")


	InitReg()

	DebugTrace("DoInit: Starting DataManager...")
	DataManager.Start()
	WaitMenuMode(1)
	While DataManager.IsBusy
		WaitMenuMode(0.5)
	EndWhile

	DebugTrace("DoInit: Starting Compatibility modules...")
	CheckCompatibilityModules()

	DebugTrace("DoInit: Starting PlayerTracker...")
	SendModEvent("vFFC_PlayerTrackerStart")

	;DataManager.LoadTestCharacter()

	_Running = True
	ModVersion = _iCurrentVersion
	;vFFC_FFLogoEffect.Play(PlayerREF)
	vFFC_ModLoadedMSG.Show(ModVersionMajor,ModVersionMinor,ModVersionPatch)
EndFunction

Function DoUpgrade()
	_Running = False
	;version-specific upgrade code
	
	If ModVersion < GetVersionInt(1,1,2)
		Debug.Trace("vFF/Upgrade/1.1.2: Upgrading to 1.1.2...")
		Debug.Trace("vFF/Upgrade/1.1.2: Upgrade to 1.1.2 complete!")
		ModVersion = GetVersionInt(1,1,2)
	EndIf
	
	;Generic upgrade code
	If ModVersion < _iCurrentVersion
		DebugTrace("Upgrading to " + GetVersionString(_iCurrentVersion) + "...")
		;FIXME: Do upgrade stuff!
		ModVersion = _iCurrentVersion
		DebugTrace("Upgrade to " + GetVersionString(_iCurrentVersion) + " complete!")
	EndIf
	_Running = True
	DebugTrace("Upgrade complete!")
EndFunction

Function CheckCompatibilityModules(Bool abReset = False)
	DebugTrace("Checking compatibility modules!")
	RegisterForModEvent("vFFC_CompatReport","OnCompatReport")
	Int iHandle = ModEvent.Create("vFFC_CompatCheck")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING! Could not send vFFC_CompatCheck event!",1)
	EndIf
EndFunction

Event OnCompatReport(String asName, Form akSender, Bool abRequired, Bool abEnabled)
	DebugTrace("Compat module " + asName + " report - Required: " + abRequired + ", Enabled: " + abEnabled)
EndEvent

Function AbortStartup(String asAbortReason = "None specified")
	DebugTrace("Aborting startup! Reason: " + asAbortReason,2)
	Ready = False

	_Running = False
	Ready = True
	Stop()
EndFunction

Function DoShutdown(Bool abClearData = False)
	Ready = False
	DebugTrace("Shutting down!")
	_iCurrentVersion = 0
	ModVersion = 0
	
	If DataManager.IsRunning()
		DataManager.Stop()
	EndIf

	If abClearData
		JDB.SolveObjSetter(".vFFC",0)
		DebugTrace("Data cleared, ready for removal!")
		Debug.Notification("Familiar Faces\nData has been cleared. You should now save and exit, then uninstall the mod before re-launching the game.")
	EndIf
	vFFC_ModShutdownMSG.Show()
	_Running = False
	Ready = True
EndFunction

Bool Function CheckDependencies()
	Float fSKSE = SKSE.GetVersion() + SKSE.GetVersionMinor() * 0.01 + SKSE.GetVersionBeta() * 0.0001
	DebugTrace("SKSE is version " + fSKSE)
	DebugTrace("JContainers is version " + SKSE.GetPluginVersion("Jcontainers") + ", API is " + JContainers.APIVersion())
	DebugTrace("FFutils is version " + SKSE.GetPluginVersion("ffutils"))
	DebugTrace("CharGen is version " + SKSE.GetPluginVersion("chargen"))
	DebugTrace("NIOverride is version " + SKSE.GetPluginVersion("nioverride"))
	;Debug.MessageBox("SKSE version is " + fSKSE)
	If fSKSE < 1.0702
		Debug.MessageBox("Familiar Faces\nThis mod requires SKSE 1.7.2 or higher, but it seems to be missing or out of date.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If JContainers.APIVersion() < 3
		Debug.MessageBox("Familiar Faces\nThis mod requires JContainers with API 3 (3.1.x), but it seems to be missing or out of date.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If SKSE.GetPluginVersion("chargen") < 4
		Debug.MessageBox("Familiar Faces\nThis mod requires RaceMenu 3.2.0 or higher, but it seems to be missing or out of date.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If SKSE.GetPluginVersion("nioverride") >= 3 && NIOverride.GetScriptVersion() > 1
		SetRegBool("Config.NIO.ArmorDye.Enabled",True)
	Else
		SetRegBool("Config.NIO.ArmorDye.Enabled",False)
	EndIf

	;In an upgrade from 1.x the *Manager objects might not be filled, so fill them.
	If !DataManager
		DataManager = Quest.GetQuest("vFFC_DataManagerQuest") as vFFC_DataManager
	EndIf

	;Removed write test in Skyrim folder, it was dumb anyway.

	Return True
EndFunction

Function UpdateConfig()
	DebugTrace("Updating configuration...")

	DebugTrace("Updated configuration values, some scripts may update in the background!")
EndFunction

Int Function GetVersionInt(Int iMajor, Int iMinor, Int iPatch)
	Return Math.LeftShift(iMajor,16) + Math.LeftShift(iMinor,8) + iPatch
EndFunction

String Function GetVersionString(Int iVersion)
	Int iMajor = Math.RightShift(iVersion,16)
	Int iMinor = Math.LogicalAnd(Math.RightShift(iVersion,8),0xff)
	Int iPatch = Math.LogicalAnd(iVersion,0xff)
	String sMajorZero
	String sMinorZero
	String sPatchZero
	If !iMajor
		sMajorZero = "0"
	EndIf
	If !iMinor
		sMinorZero = "0"
	EndIf
	;If !iPatch
		;sPatchZero = "0"
	;EndIf
	;DebugTrace("Got version " + iVersion + ", returning " + sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch)
	Return sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch
EndFunction

Function CheckForExtras()
	If GetModByName("Dawnguard.esm") != 255
		DebugTrace("Dawnguard is installed!")
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		DebugTrace("Dragonborn is installed!")
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/MetaQuest: " + sDebugString,iSeverity)
EndFunction
