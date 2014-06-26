Scriptname vMYC_MetaQuestScript extends Quest  
{Do initialization and track variables for scripts}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor Property PlayerRef Auto

Bool Property Ready = False Auto

Float Property ModVersion Auto Hidden

String Property ModName = "Meet Your Characters" Auto Hidden

Message Property vMYC_ModLoadedMSG Auto
Message Property vMYC_ModUpdatedMSG Auto
Message Property vMYC_ModShutdownMSG Auto

vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto

;--=== Config variables ===--

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto

;--=== Variables ===--

Float _CurrentVersion
String _sCurrentVersion

Bool _ShowedSKSEWarning = False
Bool _ShowedJContainersWarning = False
Bool _Running

Float _ScriptLatency
Float _StartTime
Float _EndTime

Int _iUpkeepsExpected
Int _iUpkeepsCompleted

;--=== Events ===--

Event OnInit()
	If ModVersion == 0
		DoUpkeep(True)
	EndIf
EndEvent

Event OnReset()
	Debug.Trace("MYC: Metaquest event: OnReset")
EndEvent

Event OnUpdate()
	
EndEvent

Event OnGameReloaded()
	Debug.Trace("MYC: Metaquest event: OnGameReloaded")
	;If vMYC_CFG_Shutdown.GetValue() != 0
		DoUpkeep()
	;EndIf
EndEvent

Event OnUpkeepState(string eventName, string strArg, float numArg, Form sender)
	If eventName == "vMYC_UpkeepBegin"
		_iUpkeepsExpected += 1
	ElseIf eventName == "vMYC_UpkeepEnd"
		_iUpkeepsCompleted += 1
		Debug.Trace("MYC: Metaquest Upkeep finished for " + sender + ". (" + _iUpkeepsCompleted + "/" + _iUpkeepsExpected + ")")
	EndIf
EndEvent

;--=== Functions ===--

Function DoUpkeep(Bool DelayedStart = True)
	RegisterForModEvent("vMYC_InitBegin","OnInitState")
	RegisterForModEvent("vMYC_InitEnd","OnInitState")
	RegisterForModEvent("vMYC_UpkeepBegin","OnUpkeepState")
	RegisterForModEvent("vMYC_UpkeepEnd","OnUpkeepState")
	Ready = False
	If DelayedStart
		Wait(RandomFloat(2,4))
	EndIf
	Float fSKSE = SKSE.GetVersion() + SKSE.GetVersionMinor() * 0.01 + SKSE.GetVersionBeta() * 0.0001
	;Debug.MessageBox("SKSE version is " + fSKSE)
	If fSKSE < 1.0700
		If !_ShowedSKSEWarning
			Debug.MessageBox("SKSE is missing or not installed correctly. This mod requires SKSE 1.7.0 or higher and will now shut down. This message will not be displayed again.")
			_ShowedSKSEWarning = True
		EndIf
		DoShutdown()
		Return
	Else ; reset message in case user breaks SKSE later
		_ShowedSKSEWarning = False
	EndIf
	If JContainers.APIVersion() < 2
		If !_ShowedJContainersWarning
			Debug.MessageBox("The SKSE plugin JContainers is missing or not installed correctly. This mod requires JContainers 0.67.1 or higher and will now shut down. This message will not be displayed again.")
		_ShowedJContainersWarning = True
		EndIf
		DoShutdown()
		Return
	Else
		_ShowedJContainersWarning = False
	EndIf
	;FIXME: CHANGE THIS WHEN UPDATING!
	_CurrentVersion = 80
	_sCurrentVersion = GetVersionString(_CurrentVersion)
	String sErrorMessage
	SendModEvent("vMYC_UpkeepBegin")
	Debug.Trace("MYC: " + ModName)
	Debug.Trace("MYC: Performing upkeep...")
	Debug.Trace("MYC: Loaded version is " + GetVersionString(ModVersion) + ", Current version is " + _sCurrentVersion)
	If ModVersion == 0
		Debug.Trace("MYC: Newly installed, doing initialization...")
		DoInit()
		If ModVersion == _CurrentVersion
			Debug.Trace("MYC: Initialization succeeded.")
		Else
			Debug.Trace("MYC: WARNING! Initialization had a problem!")
		EndIf
	ElseIf ModVersion < _CurrentVersion
		Debug.Trace("MYC: Installed version is older. Starting the upgrade...")
		DoUpgrade() ; this should also fire DoUpkeep
		If ModVersion != _CurrentVersion
			Debug.Trace("MYC: WARNING! Upgrade failed!")
			Debug.MessageBox("WARNING! " + ModName + " upgrade failed for some reason. You should report this to the mod author.")
		EndIf
		Debug.Trace("MYC: Upgraded to " + _CurrentVersion)
		vMYC_ModUpdatedMSG.Show((_CurrentVersion as Float) / 100.0)
	Else
		;FIXME: Do init stuff in other quests
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		Debug.Trace("MYC: Loaded, no updates.")
		;CheckForOrphans()
	EndIf
	CheckForExtras()
	UpdateConfig()
	Debug.Trace("MYC: Upkeep complete!")
	Ready = True
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Function DoInit()
	Debug.Trace("MYC: Initializing...")
	;FIXME: Do init stuff!
	If !(CharacterManager as Quest).IsRunning()
		(CharacterManager as Quest).Start()
		WaitMenuMode(0.5)
		CharacterManager.DoInit()
	EndIf

	If !(ShrineOfHeroes as Quest).IsRunning()
		WaitMenuMode(0.5)
		(ShrineOfHeroes as Quest).Start()
		;CharacterManager.DoInit()
	EndIf

	
	;Wait(3)
	;CharacterManager.SaveCurrentPlayer()
	;Int i = 0
	;While i < CharacterManager.CharacterNames.Length
		;If CharacterManager.CharacterNames[i]
			;CharacterManager.LoadCharacter(CharacterManager.CharacterNames[i])
		;EndIf
		;i += 1
	;EndWhile
	_Running = True
	ModVersion = _CurrentVersion
	vMYC_ModLoadedMSG.Show((_CurrentVersion as Float) / 100.0)
EndFunction

Function DoUpgrade()
	_Running = False
	;version-specific upgrade code
	If ModVersion < 50
		Debug.MessageBox("Familiar Faces\nHEY! You REALLY need to start from a clean save! Upgrading from previous tests to this version is NOT SUPPORTED!\nHit ~ and type qqq in the console to quit now!")
		Debug.MessageBox("Familiar Faces\nI'm serious, there is so much stuff that's going to be broken if you keep going, and any bug reports you submit will be useless. PLEASE quit the game ASAP, do a clean install of FF, and try it again from scratch!")
	EndIf
	;Generic upgrade code
	If ModVersion < _CurrentVersion
		Debug.Trace("MYC: Upgrading to " + ((_CurrentVersion as Float) / 100.0) + "...")
		;FIXME: Do upgrade stuff!
		CharacterManager.RepairSaves()
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		ModVersion = _CurrentVersion
		Debug.Trace("MYC: Upgrade to " + ((_CurrentVersion as Float) / 100.0) + " complete!")
	EndIf
	_Running = True
	Debug.Trace("MYC: Upgrade complete!")
EndFunction

Function DoShutdown()
	Ready = False
	Debug.Trace("MYC: Shutting down and preparing for removal...")
	;FIXME: Do shutdown stuff!
	_CurrentVersion = 0
	ModVersion = 0
	vMYC_ModShutdownMSG.Show()
	_Running = False
	Ready = True
EndFunction

Function UpdateConfig()
	Debug.Trace("MYC: Updating configuration...")

	Debug.Trace("MYC: Updated configuration values, some scripts may update in the background!")
EndFunction

String Function GetVersionString(Float fVersion)
	Int Major = Math.Floor(fVersion) as Int
	Int Minor = ((fVersion - (Major as Float)) * 100.0) as Int
	If Minor < 10
		Return Major + ".0" + Minor
	Else
		Return Major + "." + Minor
	EndIf
EndFunction

Function CheckForExtras()
	If GetModByName("Dawnguard.esm") != 255
		Debug.Trace("MYC: Dawnguard is installed!")
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		Debug.Trace("MYC: Dragonborn is installed!")
	EndIf
EndFunction