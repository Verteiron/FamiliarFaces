Scriptname vMYC_MetaQuestScript extends Quest
{Do initialization and track variables for scripts}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

Actor Property PlayerRef Auto

Bool Property Ready = False Auto

Float Property ModVersion Auto Hidden
Int Property ModVersionInt Auto Hidden

Int Property ModVersionMajor Auto Hidden
Int Property ModVersionMinor Auto Hidden
Int Property ModVersionPatch Auto Hidden

String Property ModName = "Familiar Faces" Auto Hidden

Message Property vMYC_ModLoadedMSG Auto
Message Property vMYC_ModUpdatedMSG Auto
Message Property vMYC_ModShutdownMSG Auto

vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto
vMYC_HangoutManager Property HangoutManager Auto

;--=== Config variables ===--

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto
GlobalVariable Property vMYC_WaitForMQ Auto

;--=== Variables ===--

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

;--=== Events ===--

Event OnInit()
	If IsRunning() && ModVersion == 0 && !ModVersionMajor
		DoUpkeep(True)
	EndIf
EndEvent

Event OnReset()
	;Debug.Trace("MYC: Metaquest event: OnReset")
EndEvent

Event OnUpdate()

EndEvent

Event OnGameReloaded()
	Debug.Trace("MYC: Metaquest event: OnGameReloaded")
	;If vMYC_CFG_Shutdown.GetValue() != 0
		DoUpkeep(False)
	;EndIf
EndEvent

Event OnUpkeepState(string eventName, string strArg, float numArg, Form sender)
	If eventName == "vMYC_UpkeepBegin"
		_iUpkeepsExpected += 1
	ElseIf eventName == "vMYC_UpkeepEnd"
		_iUpkeepsCompleted += 1
		;Debug.Trace("MYC: Metaquest Upkeep finished for " + sender + ". (" + _iUpkeepsCompleted + "/" + _iUpkeepsExpected + ")")
	EndIf
EndEvent

Event OnShutdown(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("MYC: OnShutdown!")
	Wait(0.1)
	DoShutdown()
EndEvent

;--=== Functions ===--

Function DoUpkeep(Bool DelayedStart = True)
	_iUpkeepsExpected = 0
	_iUpkeepsCompleted = 0
	;FIXME: CHANGE THIS WHEN UPDATING!
	ModVersionMajor = 1
	ModVersionMinor = 1
	ModVersionPatch = 2
	_iCurrentVersion = GetVersionInt(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	_sCurrentVersion = GetVersionString(_iCurrentVersion)
	String sModVersion = GetVersionString(ModVersion as Int)
	RegisterForModEvent("vMYC_InitBegin","OnInitState")
	RegisterForModEvent("vMYC_InitEnd","OnInitState")
	RegisterForModEvent("vMYC_UpkeepBegin","OnUpkeepState")
	RegisterForModEvent("vMYC_UpkeepEnd","OnUpkeepState")
	RegisterForModEvent("vMYC_Shutdown","OnShutdown")
	Ready = False
	If DelayedStart
		Wait(RandomFloat(3,5))
	EndIf
	Quest MQ101 = Quest.GetQuest("MQ101")
	While vMYC_WaitForMQ.GetValue() > 0 && MQ101.IsRunning() && MQ101.GetCurrentStageID() < 900
		WaitMenuMode(10)
	EndWhile
	
	If !CheckDependencies()
		DoShutdown()
		Return
	EndIf
	
	SyncConfig()
	String sErrorMessage
	SendModEvent("vMYC_UpkeepBegin")
	Debug.Trace("MYC: " + ModName)
	Debug.Trace("MYC: Performing upkeep...")
	Debug.Trace("MYC: Loaded version is " + sModVersion + ", Current version is " + _sCurrentVersion)
	If ModVersion == 0
		Debug.Trace("MYC: Newly installed, doing initialization...")
		DoInit()
		If ModVersion == _iCurrentVersion
			Debug.Trace("MYC: Initialization succeeded.")
		Else
			Debug.Trace("MYC: WARNING! Initialization had a problem!")
		EndIf
	ElseIf ModVersion < _iCurrentVersion
		Debug.Trace("MYC: Installed version is older. Starting the upgrade...")
		DoUpgrade() ; this should also fire DoUpkeep
		If ModVersion != _iCurrentVersion
			Debug.Trace("MYC: WARNING! Upgrade failed!")
			Debug.MessageBox("WARNING! " + ModName + " upgrade failed for some reason. You should report this to the mod author.")
		EndIf
		Debug.Trace("MYC: Upgraded to " + GetVersionString(_iCurrentVersion))
		vMYC_ModUpdatedMSG.Show(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	Else
		;FIXME: Do init stuff in other quests
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		HangoutManager.DoUpkeep()
		Debug.Trace("MYC: Loaded, no updates.")
		;CheckForOrphans()
	EndIf
	CheckForExtras()
	CheckCompatibilityModules()
	UpdateConfig()
	Debug.Trace("MYC: Upkeep complete!")
	Ready = True
	;HangoutManager.AssignActorToHangout(CharacterManager.GetCharacterActorByName("Kmiru"),"Blackreach")
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
	InitConfig()
	If !GetConfigBool("DefaultsSet")
		SetConfigDefaults()
	EndIf
	If !(ShrineOfHeroes as Quest).IsRunning()
		WaitMenuMode(0.5)
		(ShrineOfHeroes as Quest).Start()
		;CharacterManager.DoInit()
	EndIf
	If !(HangoutManager as Quest).IsRunning()
		(HangoutManager as Quest).Start()
		WaitMenuMode(0.5)
		HangoutManager.DoInit()
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
	ModVersion = _iCurrentVersion
	vMYC_ModLoadedMSG.Show(ModVersionMajor,ModVersionMinor,ModVersionPatch)
EndFunction

Function DoUpgrade()
	_Running = False
	;version-specific upgrade code
	If ModVersion < 90
		Debug.MessageBox("Familiar Faces\nHEY! You REALLY need to start from a clean save! Upgrading from the beta to this version is NOT SUPPORTED!\nHit ~ and type qqq in the console to quit now!")
		Debug.MessageBox("Familiar Faces\nI'm serious, there is so much stuff that's going to be broken if you keep going, and any bug reports you submit will be useless. PLEASE quit the game ASAP, do a clean install of FF, and try it again from scratch!")
	EndIf
	If ModVersion < 104
		Debug.Trace("MYC: Upgrading to " + ((_iCurrentVersion as Float) / 100.0) + "...")
		CharacterManager.SerializationVersion = 3
		CharacterManager.RepairSaves()
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		ModVersion = 104
		Debug.Trace("MYC: Upgrade to " + ((_iCurrentVersion as Float) / 100.0) + " complete!")
	EndIf

	If ModVersion < 106
		Debug.Trace("MYC: Upgrading to 1.0.6...")
		Debug.Trace("MYC: Initialize new config storage...")
		InitConfig()
		SetConfigDefaults()
		CharacterManager.RepairSaves()
		CharacterManager.DoUpkeep()
		Debug.Trace("MYC: Shutting down Shrine of Heroes...")
		ShrineOfHeroes.Stop()
		While ShrineOfHeroes.IsRunning()
			Wait(0.5)
			ShrineOfHeroes.Stop()
			Debug.Trace("MYC: Waiting for Shrine to shut down...")
		EndWhile
		Debug.Trace("MYC: Restarting Shrine of Heroes...")
		ShrineOfHeroes.Start()
		Debug.Trace("MYC: Upgrade to " + ((_iCurrentVersion as Float) / 100.0) + " complete!")
		ModVersion = GetVersionInt(1,0,6)
	EndIf
	
	If ModVersion < GetVersionInt(1,1,0)
		Debug.Trace("MYC/Upgrade/1.1.0: Upgrading to 1.1.0...")
		Debug.Notification("Familiar Faces: Upgrading 1.0.x to 1.1.x, this may take a while!")
		Debug.Trace("MYC/Upgrade/1.1.0: Updating save data...")
		CharacterManager.RepairSaves()
		Debug.Trace("MYC/Upgrade/1.1.0: Doing CharacterManager upkeep without deferral, this may take a while...")
		CharacterManager.DoUpkeep(False)
		Debug.Trace("MYC/Upgrade/1.1.0: Doing Shrine of Heroes upkeep without deferral, this may take a while...")
		ShrineOfHeroes.DoUpkeep(False)
		Debug.Trace("MYC/Upgrade/1.1.0: Starting up HangoutManager...")
		HangoutManager.Stop()
		HangoutManager.Start()
		HangoutManager.DoInit()
		HangoutManager.ImportOldHangouts()
		Wait(2)
		;HangoutManager.AssignActorToHangout(CharacterManager.GetCharacterActorByName("Kmiru"),"Blackreach")
		Debug.Trace("MYC/Upgrade/1.1.0: Upgrade to 1.1.0 complete!")
		ModVersion = GetVersionInt(1,1,0)
	EndIf
	
	If ModVersion < GetVersionInt(1,1,1)
		Debug.Trace("MYC/Upgrade/1.1.1: Upgrading to 1.1.1...")
		Debug.Trace("MYC/Upgrade/1.1.1: Restarting compatibility quests...")
		CheckCompatibilityModules(abReset = True)
		Debug.Trace("MYC/Upgrade/1.1.1: Upgrade to 1.1.1 complete!")
		ModVersion = GetVersionInt(1,1,1)
	EndIf
	
	If ModVersion < GetVersionInt(1,1,2)
		Debug.Trace("MYC/Upgrade/1.1.2: Upgrading to 1.1.2...")
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		Debug.Trace("MYC/Upgrade/1.1.2: Upgrade to 1.1.2 complete!")
		ModVersion = GetVersionInt(1,1,2)
	EndIf
	
	;Generic upgrade code
	If ModVersion < _iCurrentVersion
		Debug.Trace("MYC: Upgrading to " + GetVersionString(_iCurrentVersion) + "...")
		;FIXME: Do upgrade stuff!
		CharacterManager.RepairSaves()
		CharacterManager.DoUpkeep()
		ShrineOfHeroes.DoUpkeep()
		ModVersion = _iCurrentVersion
		Debug.Trace("MYC: Upgrade to " + GetVersionString(_iCurrentVersion) + " complete!")
	EndIf
	_Running = True
	Debug.Trace("MYC: Upgrade complete!")
EndFunction

Function CheckCompatibilityModules(Bool abReset = False)
	If !CheckCompatibilityModule_EFF(abReset)
		Debug.Trace("MYC: Compatibility module check for EFF failed!",1)
		If !GetConfigBool("Compat_EFF_ShowedError")
			SetConfigBool("Compat_EFF_ShowedError",True)
			Debug.MessageBox("Familiar Faces\nThere was an error with the EFF compatibility module. Check the Papyrus log for more details.")
		EndIf
	Else
		SetConfigBool("Compat_EFF_ShowedError",False)
	EndIf
	If !CheckCompatibilityModule_AFT(abReset)
		Debug.Trace("MYC: Compatibility module check for AFT failed!",1)
		If !GetConfigBool("Compat_AFT_ShowedError")
			SetConfigBool("Compat_AFT_ShowedError",True)
			Debug.MessageBox("Familiar Faces\nThere was an error with the AFT compatibility module. Check the Papyrus log for more details.")
		EndIf
	Else
		SetConfigBool("Compat_AFT_ShowedError",False)
	EndIf
	If !CheckCompatibilityModule_SkyRE(abReset)
		Debug.Trace("MYC: Compatibility module check for SkyRE failed!",1)
		If !GetConfigBool("Compat_SkyRE_ShowedError")
			SetConfigBool("Compat_SkyRE_ShowedError",True)
			Debug.MessageBox("Familiar Faces\nThere was an error with the SkyRE compatibility module. Check the Papyrus log for more details.")
		EndIf
	Else
		SetConfigBool("Compat_SkyRE_ShowedError",False)
	EndIf
EndFunction

Bool Function CheckCompatibilityModule_EFF(Bool abReset = False)
	Quest vMYC_zCompat_EFFQuest = GetFormFromFile(0x0201eaf2,"vMYC_MeetYourCharacters.esp") as Quest
	If !vMYC_zCompat_EFFQuest
		Debug.Trace("MYC: Couldn't retrieve vMYC_zCompat_EFFQuest!",1)
		Return False
	EndIf
	If abReset
		Debug.Trace("MYC: Forcing reset of vMYC_zCompat_EFFQuest!",1)
		vMYC_zCompat_EFFQuest.Stop()
	EndIf
	Debug.Trace("MYC: Checking whether EFF compatibility is needed...")
	If GetModByName("EFFCore.esm") != 255 || (GetModByName("XFLMain.esm") != 255 && GetModByName("XFLPanel.esp") != 255)
		Debug.Trace("MYC:  EFF found!")
		SetConfigInt("Compat_EFF_Loaded",1)
		If !vMYC_zCompat_EFFQuest.IsRunning()
			vMYC_zCompat_EFFQuest.Start()
			Debug.Trace("MYC:  Started EFF compatibility module!")
			If vMYC_zCompat_EFFQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		Else
			Debug.Trace("MYC:  EFF compatibility module is already running.")
			Return True
		EndIf
	Else
		Debug.Trace("MYC:  EFF not found.")
		SetConfigInt("Compat_EFF_Loaded",0)
		If vMYC_zCompat_EFFQuest.IsRunning()
			(vMYC_zCompat_EFFQuest as vMYC_CompatEFF).DoShutdown()
			vMYC_zCompat_EFFQuest.Stop()
			Debug.Trace("MYC:  Stopped EFF compatibility module!")
			If !vMYC_zCompat_EFFQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		EndIf
	EndIf
	Return True
EndFunction

Bool Function CheckCompatibilityModule_AFT(Bool abReset = False)
	Quest vMYC_zCompat_AFTQuest = GetFormFromFile(0x02023c40,"vMYC_MeetYourCharacters.esp") as Quest
	If !vMYC_zCompat_AFTQuest
		Debug.Trace("MYC: Couldn't retrieve vMYC_zCompat_AFTQuest!",1)
		Return False
	EndIf
	If abReset
		Debug.Trace("MYC: Forcing reset of vMYC_zCompat_AFTQuest!",1)
		vMYC_zCompat_AFTQuest.Stop()
	EndIf
	Debug.Trace("MYC: Checking whether AFT compatibility is needed...")
	If GetModByName("AmazingFollowerTweaks.esp") != 255 
		Debug.Trace("MYC:  AFT found!")
		SetConfigInt("Compat_AFT_Loaded",1)
		If !vMYC_zCompat_AFTQuest.IsRunning()
			vMYC_zCompat_AFTQuest.Start()
			Debug.Trace("MYC:  Started AFT compatibility module!")
			If vMYC_zCompat_AFTQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		Else
			Debug.Trace("MYC:  AFT compatibility module is already running.")
			Return True
		EndIf
	Else
		Debug.Trace("MYC:  AFT not found.")
		SetConfigInt("Compat_AFT_Loaded",0)
		If vMYC_zCompat_AFTQuest.IsRunning()
			(vMYC_zCompat_AFTQuest as vMYC_CompatAFT).DoShutdown()
			vMYC_zCompat_AFTQuest.Stop()
			Debug.Trace("MYC:  Stopped AFT compatibility module!")
			If !vMYC_zCompat_AFTQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		EndIf
	EndIf
	Return True
EndFunction

Bool Function CheckCompatibilityModule_SkyRE(Bool abReset = False)
	Quest vMYC_zCompat_SkyREQuest = GetFormFromFile(0x02025740,"vMYC_MeetYourCharacters.esp") as Quest
	If !vMYC_zCompat_SkyREQuest
		Debug.Trace("MYC: Couldn't retrieve vMYC_zCompat_SkyREQuest!",1)
		Return False
	EndIf
	If abReset
		Debug.Trace("MYC: Forcing reset of vMYC_zCompat_SkyREQuest!",1)
		vMYC_zCompat_SkyREQuest.Stop()
	EndIf
	Debug.Trace("MYC: Checking whether SkyRE compatibility is needed...")
	If GetModByName("SkyRe_Main.esp") != 255 
		Debug.Trace("MYC:  SkyRE found!")
		SetConfigInt("Compat_SkyRE_Loaded",1)
		If !vMYC_zCompat_SkyREQuest.IsRunning()
			vMYC_zCompat_SkyREQuest.Start()
			Debug.Trace("MYC:  Started SkyRE compatibility module!")
			If vMYC_zCompat_SkyREQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		Else
			Debug.Trace("MYC:  SkyRE compatibility module is already running.")
			Return True
		EndIf
	Else
		Debug.Trace("MYC:  SkyRE not found.")
		SetConfigInt("Compat_SkyRE_Loaded",0)
		If vMYC_zCompat_SkyREQuest.IsRunning()
			(vMYC_zCompat_SkyREQuest as vMYC_CompatSkyRE).DoShutdown()
			vMYC_zCompat_SkyREQuest.Stop()
			Debug.Trace("MYC:  Stopped SkyRE compatibility module!")
			If !vMYC_zCompat_SkyREQuest.IsRunning()
				Return True
			Else
				Return False
			EndIf
		EndIf
	EndIf
	Return True
EndFunction


Function DoShutdown()
	Ready = False
	Debug.Trace("MYC: Shutting down and preparing for removal...")
	_iCurrentVersion = 0
	ModVersion = 0
	Quest vMYC_zCompat_AFTQuest = GetFormFromFile(0x02023c40,"vMYC_MeetYourCharacters.esp") as Quest
	Quest vMYC_zCompat_EFFQuest = GetFormFromFile(0x0201eaf2,"vMYC_MeetYourCharacters.esp") as Quest
	(vMYC_zCompat_AFTQuest as vMYC_CompatAFT).DoShutdown()
	vMYC_zCompat_AFTQuest.Stop()
	(vMYC_zCompat_EFFQuest as vMYC_CompatEFF).DoShutdown()
	vMYC_zCompat_EFFQuest.Stop()
	
	If HangoutManager.IsRunning()
		HangoutManager.DoShutdown()
		HangoutManager.Stop()
	EndIf
	If ShrineOfHeroes.IsRunning()
		ShrineOfHeroes.DoShutdown()
		ShrineOfHeroes.Stop()
	EndIf
	If CharacterManager.IsRunning()
		CharacterManager.DoShutdown()
		CharacterMAnager.Stop()
	EndIf
	
	JDB.SetObj("vMYC",0)
	vMYC_ModShutdownMSG.Show()
	Debug.Trace("MYC: Data cleared, ready for removal!")
	Debug.Notification("Familiar Faces\nData has been cleared. You should now save and exit, then uninstall the mod before re-launching the game.")
	_Running = False
	Ready = True
EndFunction

Function SetConfigDefaults(Bool abForce = False)
	If !GetConfigBool("DefaultsSet") || abForce
		Debug.Trace("MYC: Setting config defaults!")
		SetConfigInt("MAGIC_ALLOWFROMMODS",0,False,False)
		SetConfigInt("MAGIC_OVERRIDES",2,False,False)

		SetConfigBool("DEBUG_SHRINE_DISABLE_BG_VALIDATION",False,False,False)
		SetConfigBool("TRACKBYDEFAULT",True,False,False)
		SetConfigBool("TRACK_STOPONRECRUIT",True,False,False)
		SetConfigBool("AUTOLEVEL_CHARACTERS",True,False,False)
		SetConfigBool("WARNING_MISSINGMOD",True,False,False)
		SetConfigBool("DELETE_MISSING",True,False,False)
		SetConfigBool("SHOUTS_DISABLE_CITIES",True,False,False)
		SetConfigBool("DefaultsSet",True)
	EndIf
EndFunction

Bool Function CheckDependencies()
	Float fSKSE = SKSE.GetVersion() + SKSE.GetVersionMinor() * 0.01 + SKSE.GetVersionBeta() * 0.0001
	Debug.Trace("MYC: SKSE is version " + fSKSE)
	Debug.Trace("MYC: JContainers is version " + SKSE.GetPluginVersion("Jcontainers") + ", API is " + JContainers.APIVersion())
	Debug.Trace("MYC: FFutils is version " + SKSE.GetPluginVersion("ffutils"))
	Debug.Trace("MYC: CharGen is version " + SKSE.GetPluginVersion("chargen"))
	Debug.Trace("MYC: NIOverride is version " + SKSE.GetPluginVersion("nioverride"))
	;Debug.MessageBox("SKSE version is " + fSKSE)
	If fSKSE < 1.0700
		Debug.MessageBox("Familiar Faces\nSKSE is missing or not installed correctly. This mod requires SKSE 1.7.0 or higher, but the current version is " + fSKSE + ".\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If JContainers.APIVersion() != 3
		Debug.MessageBox("Familiar Faces\nThe SKSE plugin JContainers is missing or not installed correctly. This mod requires JContainers with API 3 (3.1.x), but the current version reports a different API version.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If SKSE.GetPluginVersion("chargen") < 3
		Debug.MessageBox("Familiar Faces\nThe SKSE plugin CharGen is missing or not installed correctly. This mod requires RaceMenu 2.9.1 or higher.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf
	If SKSE.GetPluginVersion("nioverride") >= 3 && NIOverride.GetScriptVersion() > 1
		SetConfigBool("NIO_UseDye",True)
	Else
		SetConfigBool("NIO_UseDye",False)
	EndIf
	Int iRandom = RandomInt(0,999999)
	Int jTestMap = JMap.Object()
	JMap.setInt(jTestMap,"RandomInt",iRandom)
	JValue.WriteToFile(jTestMap,"Data/vMYC/vMYC_testfile.json")
	WaitMenuMode(0.1)
	jTestMap = JValue.Release(jTestMap)
	jTestMap = JValue.ReadFromFile("Data/vMYC/vMYC_testfile.json")
	If JMap.getInt(jTestMap,"RandomInt") != iRandom
		Debug.MessageBox("Familiar Faces\nCould not write to Data/vMYC! This may be because your Skyrim directory's permissions are wrong, or the vMYC is missing.\nThe mod will shut down until this is fixed!")
		Return False
	EndIf
	Return True
EndFunction

Function UpdateConfig()
	Debug.Trace("MYC: Updating configuration...")

	Debug.Trace("MYC: Updated configuration values, some scripts may update in the background!")
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
	;Debug.Trace("MYC: Got version " + iVersion + ", returning " + sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch)
	Return sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch
EndFunction

Function CheckForExtras()
	If GetModByName("Dawnguard.esm") != 255
		Debug.Trace("MYC: Dawnguard is installed!")
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		Debug.Trace("MYC: Dragonborn is installed!")
	EndIf
EndFunction
