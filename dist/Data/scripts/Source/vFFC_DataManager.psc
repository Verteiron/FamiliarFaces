Scriptname vFFC_DataManager extends vFFC_ManagerBase
{Save and restore character and other data using the registry.}

; === [ vFFC_DataManager.psc ] ============================================---
; Main interface for managing character-related data. 
; Handles:
;  Loading/saving character data
;  Scanning of Player for various data
;  Game session identification and matching
;  Equipment serialization
;  Population of certain lists, like AVNames
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_Session

;=== Constants ===--

String				Property META			= ".Info"				Auto Hidden

Int 				Property VOICETYPE_NOFILTER  	= 0				AutoReadOnly Hidden
Int 				Property VOICETYPE_FOLLOWER  	= 1				AutoReadOnly Hidden
Int 				Property VOICETYPE_SPOUSE 		= 2				AutoReadOnly Hidden
Int 				Property VOICETYPE_ADOPT 		= 4				AutoReadOnly Hidden
Int 				Property VOICETYPE_GENDER		= 8 			AutoReadOnly Hidden

;=== Properties ===--

String 				Property SessionID 								Hidden
{Return SessionID for this game session.}
	String Function Get()
		Return GetSessionStr("SessionID")
	EndFunction
EndProperty


Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden

vFFC_PlayerTracker	Property PlayerTracker							Auto

Int 				Property SerializationVersion = 5 				Auto Hidden

Actor 				Property PlayerRef 								Auto
{The Player, duh.}

ActorBase 			Property vFFC_InvisibleMActor					Auto
{Invisible actor for collecting custom weapons.}

Formlist 			Property vFFC_DoppelgangersMList				Auto
{Formlist containing the auto-leveled male dummy actors.}

Formlist 			Property vFFC_DoppelgangersFList				Auto
{Formlist containing the auto-leveled female dummy actors.}

Formlist 			Property vFFC_DoppelgangersULMList				Auto
{Formlist containing the unleveled male dummy actors.}

Formlist 			Property vFFC_DoppelgangersULFList				Auto
{Formlist containing the unleveled female dummy actors.}

Formlist 			Property vFFC_PerkList 							Auto
{A list of all perks as found by ActorValueInfo.}

Formlist 			Property vFFC_InventoryList						Auto
{A list of all Forms as found by ObjectReference.GetAllForms.}

Formlist 			Property vFFC_PlayerShoutCheckList 				Auto
{A list of all Shouts the player can learn.}

Formlist			Property vFFC_zTempListsList					Auto
{A list of Formlists to be used as temporary storage for functions requiring them.}

Formlist 			Property vFFC_VoiceTypesAllList 				Auto
{A list of all vanilla VoiceTypes.}
Formlist 			Property vFFC_VoiceTypesFollowerList			Auto
{A list of all vanilla VoiceTypes with follower dialog.}
Formlist 			Property vFFC_VoiceTypesSpouseList 				Auto
{A list of all vanilla VoiceTypes with marriage dialog.}
Formlist 			Property vFFC_VoiceTypesAdoptList 				Auto
{A list of all vanilla VoiceType with adoption dialog.}

Formlist 			Property vFFC_CombatStyles 						Auto
{A list of selected vanilla CombatStyles.}

;=== Achievement test Properties ===--

Faction 			Property CWImperialFaction 						Auto
Faction 			Property CWSonsFaction 							Auto

Spell 				Property WerewolfChange 						Auto 
{Beast form, if player has this then they're a worwelf.}

Spell 				Property DLC1VampireChange						Auto 
{Vampire lord form, if player has this then they're a wampire.}

GlobalVariable 		Property DLC1PlayingVampireLine 				Auto 
{1 = Vampires, 0 = Dawnguard.}

;=== Variables ===--

Bool _bSavedPerks 		= False
Bool _bSavedSpells 		= False
Bool _bSavedEquipment 	= False
Bool _bSavedInventory 	= False
Bool _bSavedNINodeInfo 	= False

Int		_iThreadCount	= 0

Int		_jAVNames		= 0

;=== Events ===--

Event OnInit()
	If IsRunning() && !IsBusy
		IsBusy = True
		CreateMiscStatNames()
		CreateAVNames()
		InitNINodeList()
		SortVoiceTypes()
		SortCombatStyles()

		;Init ActorBasePool forms in case they're not there already
		If !HasRegKey("ActorbasePool.F")
			Int jABPool = JArray.Object()
			JArray.AddFromFormlist(jABPool,vFFC_DoppelgangersFList)
			SetRegObj("ActorbasePool.F",jABPool)
		EndIf
		
		If !HasRegKey("ActorbasePool.M")
			Int jABPool = JArray.Object()
			JArray.AddFromFormlist(jABPool,vFFC_DoppelgangersMList)
			SetRegObj("ActorbasePool.M",jABPool)
		EndIf

		If !HasRegKey("ActorbasePool.UF")
			Int jABPool = JArray.Object()
			JArray.AddFromFormlist(jABPool,vFFC_DoppelgangersULFList)
			SetRegObj("ActorbasePool.UF",jABPool)
		EndIf

		If !HasRegKey("ActorbasePool.UM")
			Int jABPool = JArray.Object()
			JArray.AddFromFormlist(jABPool,vFFC_DoppelgangersULMList)
			SetRegObj("ActorbasePool.UM",jABPool)
		EndIf

		If !HasSessionKey("ActorbaseMap")
			SetSessionObj("ActorbaseMap",JFormMap.Object())
		EndIf
		DoUpkeep(False)
		RegisterForSingleUpdate(5.0)
	EndIf
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
	SendModEvent("vFFC_DataManagerReady")
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnTrackerReady(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("Tracker reports ready, save the player!")
	While IsBusy
		DebugTrace("Waiting to be not busy....")
		WaitMenuMode(1)
	EndWhile
	SavePlayerData()
	;Debug.MessageBox("Finished saving!")

EndEvent

;=== Functions - Startup ===--

Function LoadTestCharacter()
	Actor[] kDoppelgangers = New Actor[32]
	Debug.StartScriptProfiling("vFFC_DataManager")
	Debug.StartScriptProfiling("vFF_API_Doppelganger")
	Debug.StartScriptProfiling("vFFC_Doppelganger")
	Int jCharacters = JMap.AllKeys(GetRegObj("Characters"))
	Int i = JArray.Count(jCharacters)
	JValue.Retain(jCharacters)
	While i > 0
		i -= 1
		String sUUID = JArray.GetStr(jCharacters,i)
		If vFF_API_Character.GetCharacterName(sUUID) ;== "Magraz"  ; != PlayerREF.GetActorBase().GetName() ; "Tagaerys"
			kDoppelgangers[i] = vFF_API_Doppelganger.CreateDoppelganger(sUUID,False) ;as vFFC_Doppelganger
		EndIf

		;ActorBase kDoppelganger = GetAvailableActorBase(iSex)
		;Actor kDoppelActor = PlayerREF.PlaceAtMe(kDoppelganger) as Actor
		;vFFC_Doppelganger kDoppelScript = kDoppelActor as vFFC_Doppelganger
		;kDoppelScript.AssignCharacter(sUUID)
		;While kDoppelActor.NeedAppearance && kDoppelActor.NeedEquipment
		;	DebugTrace("Waiting for actor to be ready...")
		;	Wait(0.5)
		;EndWhile
	EndWhile
	JValue.Release(jCharacters)


	i = kDoppelgangers.Length
	While i > 0
		i -= 1
		If kDoppelgangers[i] as Actor
			Int iSafety = 20
			While ((kDoppelgangers[i] as vFFC_Doppelganger).NeedAppearance || (kDoppelgangers[i] as vFFC_Doppelganger).NeedSpells) && iSafety > 0
				iSafety -= 1
				DebugTrace((kDoppelgangers[i] as vFFC_Doppelganger).SID + " - Waiting for actor to be ready...")
				Wait(0.5)
			EndWhile
			kDoppelgangers[i].MoveTo(PlayerREF,RandomInt(-500,500),RandomInt(-500,500), 100)
			iSafety = 20
			While !kDoppelgangers[i].Is3DLoaded()
				iSafety -= 1
				DebugTrace((kDoppelgangers[i] as vFFC_Doppelganger).SID + " - Waiting for actor to be loaded...")
				Wait(0.5)
			EndWhile
		EndIf
	EndWhile
	Wait(5)
	i = kDoppelgangers.Length
	While i > 0
		i -= 1
		If kDoppelgangers[i]
			vFF_API_Doppelganger.SetFoe(kDoppelgangers[i])
			kDoppelgangers[i].SetActorValue("Aggression",3)
		EndIf
	EndWhile
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game.}
	RegisterForModEvent("vFFC_SetCustomHangout","OnSetCustomHangout")
	RegisterForModEvent("vFFC_TrackerReady","OnTrackerReady")
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	NeedUpkeep = False
	GotoState("Busy")
	IsBusy = True
	DebugTrace("Starting upkeep...")
	SendModEvent("vFFC_UpkeepBegin")
	InitReg()
	If !GetConfigBool("DefaultsSet")
		SetConfigDefaults()
	EndIf

	String sMatchedSID = MatchSession()
	If sMatchedSID
		SetSessionID(sMatchedSID)
	EndIf

	;=== Add shouts from expansions to the checklist ===--
	If GetModByName("Dawnguard.esm") != 255
		vFFC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x02007CB6,"Dawnguard.esm")) ; Soul Tear
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		vFFC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x020179d8,"Dragonborn.esm")) ; Bend Will
		vFFC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x0201df92,"Dragonborn.esm")) ; Dragon Aspect
		vFFC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x020200c0,"Dragonborn.esm")) ; Cyclone
		vFFC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x0202ad09,"Dragonborn.esm")) ; Battle Fury
	EndIf

	ImportCharacterFiles()
	; Import files from older versions
	ImportCharacterFiles("Data/vMYC/")
	ImportCharacterFiles(JContainers.userDirectory() + "/vMYC/") 

	UpgradeRegistryData()
	;=== Don't register this until after we've init'd everything else
	RegisterForModEvent("vFFC_BackgroundFunction","OnBackgroundFunction")
	;RegisterForModEvent("vFFC_LoadSerializedEquipmentReq","OnLoadSerializedEquipmentReq")

	IsBusy = False
	GotoState("")
	DebugTrace("Finished upkeep!")
	SendModEvent("vFFC_UpkeepEnd")
EndFunction

Function SetConfigDefaults(Bool abForce = False)
	If !GetRegBool("Config.DefaultsSet") || abForce
		DebugTrace("Setting Config defaults!")
		SetConfigBool("Compat.Enabled",True,abMakeDefault = True)
		SetConfigBool("Warnings.Enabled",True,abMakeDefault = True)
		SetConfigBool("Debug.Perf.Threads.Limit",False,abMakeDefault = True)
		SetConfigInt("Debug.Perf.Threads.Max",4,abMakeDefault = True)
		SetConfigBool("Magic.AutoByPerks",True,abMakeDefault = True)
		SetConfigBool("Magic.AllowHealing",True,abMakeDefault = True)
		SetConfigBool("Magic.AllowDefense",True,abMakeDefault = True)
		SetConfigBool("Magic.BlockWallOfs",True,abMakeDefault = True)
		SetConfigBool("Magic.AllowOther",True,abMakeDefault = True)
		SetConfigBool("Magic.AllowDefense",True,abMakeDefault = True)
		SetConfigBool("Magic.AllowDefense",True,abMakeDefault = True)
		SetConfigBool("Stats.UseAutoLeveling",False,abMakeDefault = True)
	EndIf
EndFunction

;=== Functions - Character data ===--

Function ScanPlayerStats()
{Writes current player stats to the session.}
	If GetSessionBool("Status.Stats.Busy")
		Return
	EndIf
	SetSessionBool("Status.Stats.Busy",True)
	StartTimer("ScanPlayerStats")
	Int i = 0
	
	SetSessionFlt("Stats.Experience",GetPlayerExperience())
	SetSessionFlt("Stats.PerkPoints",GetPerkPoints())
	SetSessionInt("Stats.Level",PlayerREF.GetLevel())
	
	StartTimer("SaveAVs")
	
	Int iAddedCount = 0 
	Int iAdvSkills = 24 ; Start at Health
	While iAdvSkills < 44 ; Proceed through MagicResist
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAdvSkills)
		String sAVName = GetAVName(iAdvSkills)
		Float fAV = 0.0
		fAV = AVInfo.GetBaseValue(PlayerREF)
		If fAV
			SetSessionFlt("Stats.AV." + sAVName,fAV)
			;DebugTrace("Saved AV " + sAVName + "!")
		EndIf
		iAdvSkills += 1
	EndWhile
	StopTimer("SaveAVs")

	StartTimer("SaveSkills")
	Int jSkillList = GetRegObj("SkillAVIs")
	Int iSkillCount = JArray.Count(jSkillList)
	iAdvSkills = 0
	While iAdvSkills < iSkillCount
		Int iAVI = JArray.GetInt(jSkillList,iAdvSkills)
		String sAVName = GetAVName(iAVI)
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAVI)
		Float fAV = 0.0
		Int iLL = 0
		If iAVI < 158 || iAVI > 159 ; Skip Werewolf/Vampire Lord
			fAV = AVInfo.GetBaseValue(PlayerREF)
			iLL = GetSkillLegendaryLevel(sAVName)
		EndIf
		If iLL
			SetSessionInt("Stats.Legendary." + sAVName,iLL)
		EndIf
		If fAV
			SetSessionFlt("Stats.AV." + sAVName,fAV)
			;DebugTrace("Saved AV " + sAVName + "!")
		EndIf
		iAdvSkills += 1
	EndWhile
	StopTimer("SaveSkills")
	StopTimer("ScanPlayerStats")
	SetSessionBool("Status.Stats.Busy",False)
	SetSessionBool("Status.Stats.Ready",True)
EndFunction

Function ScanPlayerPerks()
{Writes current player perks to the session.}
;Slight redundancy with ScanPlayerStats but this will need to be called less often
	If GetSessionBool("Status.Perks.Busy")
		Return
	EndIf
	SetSessionBool("Status.Perks.Busy",True)
	StartTimer("ScanPlayerPerks")
	Int jPerkList = JArray.Object()
	SetSessionObj("Perks",jPerkList)	
	
	Int jSkillList = GetRegObj("SkillAVIs")
	Int iSkillCount = JArray.Count(jSkillList)
	Int iAdvSkills = 0
	Int iAddedCount = 0
	While iAdvSkills < iSkillCount
		vFFC_PerkList.Revert()
		Int iAVI = JArray.GetInt(jSkillList,iAdvSkills)
		String sAVName = GetAVName(iAVI)
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAVI)
		AVInfo.GetPerkTree(vFFC_PerkList, PlayerREF, false, true)
		Int iPerkCount = vFFC_PerkList.GetSize()
		If iPerkCount
			Int i = JArray.Count(jPerkList) ; Grab length of array before adding the Formlist
			JArray.AddFromFormList(jPerkList,vFFC_PerkList)
			SetSessionInt("PerkCounts." + sAVName,iPerkCount)
			While i < JArray.Count(jPerkList)  ; Each perk added
				Perk kPerk = JArray.GetForm(jPerkList,i) as Perk
				AddToReqList(kPerk,"Perk")
				If iAddedCount % 3 == 0
					SendModEvent("vFFC_PerkSaved")
				EndIf
				iAddedCount += 1
				i += 1
			EndWhile
			;DebugTrace("Saved " + iPerkCount + " perks in the " + sAVName + " tree!")
		EndIf
		iAdvSkills += 1
	EndWhile
	SaveSession()
	StopTimer("ScanPlayerPerks")
	SetSessionBool("Status.Perks.Busy",False)
EndFunction

Function SavePlayerPerks(Bool bSessionOnly = False)
	;== Actor values and Perks ===--
	StartTimer("SavePlayerPerks")
	SendModEvent("vFFC_PerksSaveBegin")
	
	String sRegKey = "Characters." + SessionID
	
	While GetSessionBool("Status.Perks.Busy") || GetSessionBool("Status.Stats.Busy")
		WaitMenuMode(1)
	EndWhile
	
	If !HasSessionKey("Stats")
		ScanPlayerStats()
	EndIf
	If !HasSessionKey("Perks")
		ScanPlayerPerks()
	EndIf
	
	If !bSessionOnly
		SetRegObj(sRegKey + ".Stats",GetSessionObj("Stats"))
		SetRegObj(sRegKey + ".Perks",GetSessionObj("Perks"))
		SetRegObj(sRegKey + ".PerkCounts",GetSessionObj("PerkCounts"))
	EndIf
	
	SendModEvent("vFFC_PerksSaveEnd",JArray.Count(GetSessionObj("Perks")))
	StopTimer("SavePlayerPerks")
EndFunction

Function ScanPlayerAchievements()
{Writes current player achievements to the session.}
;These were called Spawnpoints in 1.x
	If GetSessionBool("Status.Achievements.Busy")
		Return
	EndIf
	
	SetSessionBool("Status.Achievements.Busy",True)
	StartTimer("ScanPlayerAchievements")
	Int i = 0

	Int jAchievementsList = JArray.Object()
	SetSessionObj("Achievements",jAchievementsList)
	
	If Quest.GetQuest("MQ305").IsCompleted()
		JArray.AddStr(jAchievementsList,"Hero")
	EndIf
	If Quest.GetQuest("DB11").IsCompleted()
		JArray.AddStr(jAchievementsList,"DarkBrotherhoodRestored")
	ElseIf Quest.GetQuest("DBDestroy").IsCompleted()
		JArray.AddStr(jAchievementsList,"DarkBrotherhoodDestroyed")
	EndIf
	If Quest.GetQuest("MG08").IsCompleted()
		JArray.AddStr(jAchievementsList,"Mage")
	EndIf
	If Quest.GetQuest("TG09").IsCompleted()
		JArray.AddStr(jAchievementsList,"Thief")
	EndIf
	If Quest.GetQuest("MQ206").IsCompleted()
		If Quest.GetQuest("MQPaarthurnax").IsCompleted()
			JArray.AddStr(jAchievementsList,"Blade")
		Else
			JArray.AddStr(jAchievementsList,"Greybeard")
		EndIf
	EndIf
	If Quest.GetQuest("CWSiegeObj").IsCompleted()
		If PlayerREF.IsInFaction(CWImperialFaction)
			JArray.AddStr(jAchievementsList,"Imperial")
		ElseIf PlayerREF.IsInFaction(CWSonsFaction)
			JArray.AddStr(jAchievementsList,"Stormcloak")
		EndIf
	EndIf
	If Quest.GetQuest("MS05").IsCompleted()
		JArray.AddStr(jAchievementsList,"Bard")
	EndIf
	If Quest.GetQuest("C06").IsCompleted()
		JArray.AddStr(jAchievementsList,"Companion")
	EndIf

	; Dawnguard
	If GetModByName("Dawnguard.esm") != 255
		DLC1VampireChange = GetFormFromFile(0x0200283B,"Dawnguard.esm") as Spell
	EndIf
	If PlayerREF.HasSpell(WerewolfChange) ; Player is a worwelf
		JArray.AddStr(jAchievementsList,"Werewolf")
	ElseIf DLC1VampireChange
		If PlayerREF.HasSpell(DLC1VampireChange) ; Player is a vampire lord
			JArray.AddStr(jAchievementsList,"VampireLord")
		EndIf
	EndIf
	If Quest.GetQuest("DLC1MQ02") ;Only filled if Dawnguard is loaded
		If Quest.GetQuest("DLC1MQ02").IsCompleted() ; Only handle dawnguard if player is actually doing the questline
			If DLC1PlayingVampireLine.GetValue() == 1
				JArray.AddStr(jAchievementsList,"VampireFaction")
			Else
				JArray.AddStr(jAchievementsList,"DawnguardFaction")
			EndIf
			If Quest.GetQuest("DLC1MQ08").IsCompleted()
				JArray.AddStr(jAchievementsList,"DLC1Completed")
			EndIf
		EndIf
	EndIf

	; Dragonborn
	If Quest.GetQuest("DLC2MQ06") ;Only filled if Dragonborn is loaded
		If Quest.GetQuest("DLC2MQ06").IsCompleted()
			JArray.AddStr(jAchievementsList,"DLC2KilledMiraak")
		EndIf
	EndIf

	;Thane of X
	FavorJarlsMakeFriendsScript ThaneTracker = Quest.GetQuest("FavorJarlsMakeFriends") as FavorJarlsMakeFriendsScript
	If ThaneTracker.PaleImpGetOutOfJail > 0 || ThaneTracker.PaleSonsGetOutOfJail > 0
		JArray.AddStr(jAchievementsList,"Dawnstar")
	EndIf
	If ThaneTracker.WhiterunImpGetOutofJail > 0 || ThaneTracker.WhiterunSonsGetOutofJail > 0
		JArray.AddStr(jAchievementsList,"Whiterun")
	EndIf
	If ThaneTracker.HjaalmarchImpGetOutofJail > 0 || ThaneTracker.HjaalmarchSonsGetOutofJail > 0
		JArray.AddStr(jAchievementsList,"Morthal")
	EndIf
	If ThaneTracker.ReachImpGetOutofJail > 0 || ThaneTracker.ReachSonsGetOutofJail > 0
		JArray.AddStr(jAchievementsList,"Markarth")
	EndIf
	If ThaneTracker.FalkreathImpGetOutofJail > 0 || ThaneTracker.FalkreathSonsGetOutofJail > 0
		JArray.AddStr(jAchievementsList,"Falkreath")
	EndIf
	StopTimer("ScanPlayerAchievements")
	SetSessionBool("Status.Achievements.Busy",False)
EndFunction

Function SavePlayerAchievements()
	StartTimer("SavePlayerAchievements")
	SendModEvent("vFFC_AchievementsSaveBegin")

	While GetSessionBool("Status.Achievements.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Achievements")
		ScanPlayerAchievements()
	EndIf
	
	SetRegObj(sRegKey + ".Achievements",GetSessionObj("Achievements"))
	
	SendModEvent("vFFC_AchievementsSaveEnd")
	StopTimer("SavePlayerAchievements")

EndFunction

Function ScanPlayerSpells()
	;== Spells ===--
	If GetSessionBool("Status.Spells.Busy")
		Return
	EndIf
	SetSessionBool("Status.Spells.Busy",True)
	StartTimer("ScanPlayerSpells")

	Int i = 0
	Int iAddedCount = 0
	
	Form[] kPlayerSpellList = FFUtils.GetActorSpellList(PlayerREF)
	
	Int jPlayerSpells = JArray.Object()
	SetSessionObj("Spells",jPlayerSpells)
	
	Int iSpellCount = kPlayerSpellList.Length
	iAddedCount = 0
	Bool bAddItem = False
	i = 0
	While i < iSpellCount
		bAddItem = False
		Spell kSpell = kPlayerSpellList[i] as Spell
		If kSpell
			bAddItem = True
			Int iSpellID = kSpell.GetFormID()
			;DebugTrace("Player knows the spell " + kSpell + ", " + kSpell.GetName())
			If bAddItem
				;vFFC_PlayerFormlist.AddForm(kSpell)
				JArray.AddForm(jPlayerSpells,kSpell)
				AddToReqList(kSpell,"Spell")
				iAddedCount += 1
				If iAddedCount % 2 == 0
					kSpell.SendModEvent("vFFC_SpellSaved")
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	DebugTrace("Scanned " + iAddedCount + " spells.")
	StopTimer("ScanPlayerSpells")
	SetSessionBool("Status.Spells.Busy",False)
EndFunction

Function SavePlayerSpells()
	;== Spells ===--
	
	StartTimer("SavePlayerSpells")
	SendModEvent("vFFC_SpellsSaveBegin")

	While GetSessionBool("Status.Spells.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Spells")
		ScanPlayerSpells()
	EndIf
	
	SetRegObj(sRegKey + ".Spells",GetSessionObj("Spells"))
	
	SendModEvent("vFFC_SpellsSaveEnd")
	StopTimer("SavePlayerSpells")

EndFunction

Function ScanPlayerShouts()
	;== Shouts ===--
	If GetSessionBool("Status.Shouts.Busy")
		Return
	EndIf
	SetSessionBool("Status.Shouts.Busy",True)
	StartTimer("ScanPlayerShouts")

	Int i = 0
	Int iAddedCount = 0
	
	Int jPlayerShouts = JArray.Object()
	SetSessionObj("Shouts",jPlayerShouts)
	Int jPlayerShoutInfo = JArray.Object()
	SetSessionObj("ShoutInfo",jPlayerShoutInfo)
	
	Form[] kPlayerShoutList = FFUtils.GetActorShoutList(PlayerREF.GetActorBase())
	String[] sShoutNames = FFUtils.GetItemNames(kPlayerShoutList)
	
	Int iShoutCount = kPlayerShoutList.Length
	i = 0
	While i < iShoutCount
		Shout kShout = kPlayerShoutList[i] as Shout
		Int jShoutInfo = JMap.Object()
		JMap.SetForm(jShoutInfo,"Form",kShout)
		JValue.SolveIntSetter(jShoutInfo,".UnlockLevel",0,True)
		Int iWord = 0
		While iWord < 3
			WordOfPower kWord = kShout.GetNthWordOfPower(iWord)
			If kWord
				If Game.IsWordUnlocked(kWord)
					If iWord == 0 ; 
						JArray.AddForm(jPlayerShouts,kShout)
						;DebugTrace("Player knows Shout " + sShoutNames[i] + " and has unlocked at least one word of it.")
						iAddedCount += 1
					EndIf
					JValue.SolveIntSetter(jShoutInfo,".UnlockLevel",iWord + 1,True)
					String sWordName = kWord.GetName()
					If !sWordName
						sWordName = GetFormIDString(kWord)
					EndIf
					JValue.SolveFormSetter(jShoutInfo,".Words." + sWordName + ".Form",kWord,True)
				EndIf
				;DebugTrace("Word " + iWord + " of " + sShoutNames[i] + " is " + kWord.GetName() + ". Unlocked: " + Game.IsWordUnlocked(kWord))
			EndIf
			iWord += 1
		EndWhile
		JArray.AddObj(jPlayerShoutInfo,jShoutInfo)
		i += 1
	EndWhile

	DebugTrace("Scanned " + iAddedCount + " Shouts.")
	StopTimer("ScanPlayerShouts")
	SetSessionBool("Status.Shouts.Busy",False)
EndFunction

Function SavePlayerShouts()
	;== Shouts ===--
	
	StartTimer("SavePlayerShouts")
	SendModEvent("vFFC_ShoutsSaveBegin")

	While GetSessionBool("Status.Shouts.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Shouts")
		ScanPlayerShouts()
	EndIf
	
	SetRegObj(sRegKey + ".Shouts",GetSessionObj("Shouts"))
	SetRegObj(sRegKey + ".ShoutInfo",GetSessionObj("ShoutInfo"))
	
	SendModEvent("vFFC_ShoutsSaveEnd")
	StopTimer("SavePlayerShouts")

EndFunction

Function ScanPlayerEquipment()
	;== Equipment ===--
	If GetSessionBool("Status.Equipment.Busy")
		Return
	EndIf
	SetSessionBool("Status.Equipment.Busy",True)
	StartTimer("ScanPlayerEquipment")

	Int i = 0
	Int iAddedCount = 0
	
	Int jPlayerEquipment = JMap.Object()
	SetSessionObj("Equipment",jPlayerEquipment)

	Int jPlayerArmorList = JArray.Object()
	JMap.SetObj(jPlayerEquipment,"Armor",jPlayerArmorList)

	Int jPlayerArmorInfoList = JArray.Object()
	JMap.SetObj(jPlayerEquipment,"ArmorInfo",jPlayerArmorInfoList)

	Int h = 0x00000001
	While (h < 0x80000000)
		Form WornForm = PlayerREF.GetWornForm(h)
		If (WornForm)
			;Debug.Trace("vFF/CM: " + sPlayerName + " is wearing " + WornForm + ", " + WornForm.GetName() + " on slot " + h)
			If JArray.FindForm(jPlayerArmorList,WornForm) < 0
				JArray.AddForm(jPlayerArmorList,WornForm)
				Int iArmorIndex = JArray.FindForm(jPlayerArmorList,WornForm)
				If WornForm as Armor && iArmorIndex > -1
					;Debug.Trace("vFF/CM: Added " + WornForm.GetName())

					AddToReqList(WornForm,"Equipment")
					String sItemID = vFF_API_Item.SerializeEquippedObject(WornForm,1,h)
					JArray.AddObj(jPlayerArmorInfoList,vFF_API_Item.GetItemJMap(sItemID))
				EndIf
			EndIf
		EndIf
		h = Math.LeftShift(h,1)
	endWhile

	String sLeftID = vFF_API_Item.SerializeEquippedObject(PlayerREF.GetEquippedObject(0),0,0)
	String sRightID = vFF_API_Item.SerializeEquippedObject(PlayerREF.GetEquippedObject(1),1,0)

	If sLeftID 
		JMap.SetObj(jPlayerEquipment,"Left",vFF_API_Item.GetItemJMap(sLeftID))
	Else
		JValue.SolveFormSetter(jPlayerEquipment,".Left.Form",PlayerREF.GetEquippedObject(0),True)
	EndIf
	If sRightID 
		JMap.SetObj(jPlayerEquipment,"Right",vFF_API_Item.GetItemJMap(sRightID))
	Else
		JValue.SolveFormSetter(jPlayerEquipment,".Right.Form",PlayerREF.GetEquippedObject(1),True)
	EndIf

	Int jEquipVoice = JMap.Object()
	JMap.SetForm(jEquipVoice,"Form",PlayerREF.GetEquippedObject(2))
	JMap.SetObj(jPlayerEquipment,"Voice",jEquipVoice)

	AddToReqList(PlayerREF.GetEquippedObject(0),"Equipment")
	AddToReqList(PlayerREF.GetEquippedObject(1),"Equipment")
	AddToReqList(PlayerREF.GetEquippedObject(2),"Equipment")

	StopTimer("ScanPlayerEquipment")
	SetSessionBool("Status.Equipment.Busy",False)
EndFunction

Function SavePlayerEquipment()
	;== Equipment ===--
	
	StartTimer("SavePlayerEquipment")
	SendModEvent("vFFC_EquipmentSaveBegin")

	While GetSessionBool("Status.Equipment.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Equipment")
		ScanPlayerEquipment()
	EndIf
	
	SetRegObj(sRegKey + ".Equipment",GetSessionObj("Equipment"))
	
	SendModEvent("vFFC_EquipmentSaveEnd")
	
	StopTimer("SavePlayerEquipment")

EndFunction

Function ScanPlayerInventory()
	If GetSessionBool("Status.Inventory.Busy")
		Return
	EndIf
	SetSessionBool("Status.Inventory.Busy",True)

	DebugTrace("Refreshing player inventory...")
	StartTimer("ScanPlayerInventory")
	
	vFFC_InventoryList.Revert()
	;PlayerREF.GetAllForms(vFFC_InventoryList)
	Form[] kInventoryList = PlayerREF.GetContainerForms()
	Int[] iInventoryCount = FFUtils.GetItemCounts(kInventoryList,PlayerREF)
	Int[] iInventoryTypes = FFUtils.GetItemTypes(kInventoryList)
	String[] sInventoryNames = FFUtils.GetItemNames(kInventoryList)
	Int[] iInventoryHasExtra = FFUtils.GetItemHasExtraData(kInventoryList)
	Int[] iInventoryFavorites = FFUtils.GetItemFavorited(kInventoryList)
	
	Int jInventoryList = JArray.Object()
	SetSessionObj("PlayerInventoryList",jInventoryList)
	JArray.AddFromFormlist(jInventoryList,vFFC_InventoryList)

	Int jInventory = JMap.Object()
	SetSessionObj("Inventory",jInventory)
	Int jInventoryInfo = JArray.Object()
	SetSessionObj("InventoryInfo",jInventoryInfo)
	
	Int i = kInventoryList.Length
	While i > 0
		i -= 1
		Form kItem = kInventoryList[i]
		If kItem
			Int iType = iInventoryTypes[i]
			Int iCount = iInventoryCount[i]
			If !PlayerRef.IsEquipped(kItem)
				If iCount > 0 
					;Int iFormID = kItem.GetFormId()
					;If iFormID >= 0xFF000000 && iFormID <= 0xFFFFFFFF
					;	DebugTrace("Found a session object: " + kItem + " is " + sInventoryNames[i] + ".")
					;	If iType == 46
					;		Int jPotionItem = JMap.Object()
					;		SerializePotion(kItem,jPotionItem)
					;		JArray.AddObj(jInventoryInfo,jPotionItem)
					;	EndIf
					;EndIf
					Int jItemTypeFMap = JMap.getObj(jInventory,iType)
					If !JValue.IsFormMap(jItemTypeFMap)
						jItemTypeFMap = JFormMap.Object()
						JMap.setObj(jInventory,iType,jItemTypeFMap)
					EndIf
					JFormMap.SetInt(jItemTypeFMap,kItem,iCount)
				EndIf
			EndIf
			If iInventoryFavorites[i]
				Int jItemFavoriteFMap = JMap.getObj(jInventory,"Favorites")
				If !JValue.IsArray(jItemFavoriteFMap)
					jItemFavoriteFMap = JArray.Object()
					JMap.setObj(jInventory,"Favorites",jItemFavoriteFMap)
				EndIf
				If JArray.FindForm(jItemFavoriteFMap,kItem) < 0
					JArray.AddForm(jItemFavoriteFMap,kItem)
				EndIf
			EndIf
			If iInventoryHasExtra[i] && iCount
				Int jItemHasExtraFMap = JMap.getObj(jInventory,"HasExtraData")
				If !JValue.IsArray(jItemHasExtraFMap)
					jItemHasExtraFMap = JArray.Object()
					JMap.setObj(jInventory,"HasExtraData",jItemHasExtraFMap)
				EndIf
				If JArray.FindForm(jItemHasExtraFMap,kItem) < 0
					JArray.AddForm(jItemHasExtraFMap,kItem)
				EndIf
			EndIf
		EndIf
	EndWhile
	DebugTrace("Refreshed player inventory! Got " + kInventoryList.Length + " items!")
	StopTimer("ScanPlayerInventory")
	SaveSession()
	SetSessionBool("Status.Inventory.Busy",False)
EndFunction

Function SavePlayerInventory()
	;== Inventory ===--
	StartTimer("SavePlayerInventory")
	SendModEvent("vFFC_InventorySaveBegin")
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	Int i = 0
	Int iAddedCount = 0

	;vFFC_InventoryList.Revert()
	;PlayerREF.GetAllForms(vFFC_InventoryList)
	;Int jInventoryList = JArray.Object()
	;SetSessionObj("PlayerInventoryList",jInventoryList)
	;JArray.AddFromFormlist(jInventoryList,vFFC_InventoryList)
	;Int jInventory = JMap.Object() ;JFormMap.Object()
	;SetRegObj(sRegKey + ".Inventory",jInventory)
	;i = JArray.Count(jInventoryList)

	While GetSessionBool("Status.Inventory.Busy")
		WaitMenuMode(1)
	EndWhile
	
	If !HasSessionKey("Inventory")
		ScanPlayerInventory()
	EndIf
	
	Int jInventory = GetSessionObj("Inventory")
	Int jInventoryInfo = GetSessionObj("InventoryInfo")
	
	Int jWeaponsFMap 	= GetSessionObj("Inventory.41") ; kWeapon
	Int jArmorFMap 		= GetSessionObj("Inventory.26") ; kArmor
	Int jAmmoFMap 		= GetSessionObj("Inventory.42") ; kAmmo
	Int jFavoritesList 	= GetSessionObj("Inventory.Favorites") ; Favorites
	Int jExtraDataList 	= GetSessionObj("Inventory.HasExtraData") ; list of forms with extradata to scan
	
	Int jWeaponList		= JFormMap.AllKeys(jWeaponsFMap)
	Int jArmorList 		= JFormMap.AllKeys(jArmorFMap)
	Int jAmmoList 		= JFormMap.AllKeys(jAmmoFMap)

	Int jWeaponArmorList = JArray.Object()
	JArray.AddFromArray(jWeaponArmorList,jWeaponList)
	JArray.AddFromArray(jWeaponArmorList,jArmorList)
	
	JValue.AddToPool(jWeaponList,"vFFC_InventoryPool")
	JValue.AddToPool(jArmorList,"vFFC_InventoryPool")
	JValue.AddToPool(jAmmoList,"vFFC_InventoryPool")
	JValue.AddToPool(jWeaponArmorList,"vFFC_InventoryPool")
	
	;== Create dummy actor for custom weapon scans ===--

	Actor kWeaponDummy = PlayerREF.PlaceAtMe(vFFC_InvisibleMActor,abInitiallyDisabled = True) as Actor
	kWeaponDummy.SetScale(0.01)
	kWeaponDummy.SetGhost(True)
	kWeaponDummy.EnableAI(False)
	kWeaponDummy.EnableNoWait()
	Int iSafetyTimer = 30
	While !kWeaponDummy.Is3DLoaded() && iSafetyTimer
		iSafetyTimer -= 1
		Wait(0.1)
	EndWhile
	Bool bAddItem = True
	
	i = JArray.Count(jWeaponArmorList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jWeaponArmorList,i)
		If kItem && JArray.FindForm(jExtraDataList,kItem) >= 0
			Int iHand = 0
			Int iSlotMask = 0
			Int iType = kItem.GetType()
			If iType == 41 ;kWeapon
				iHand = 1
			Else ; kArmor
				iSlotMask = (kItem as Armor).GetSlotMask()
			EndIf
			PlayerREF.RemoveItem(kItem,iHand,True,kWeaponDummy)
			kWeaponDummy.EquipItemEX(kItem,iHand,preventUnequip = True,equipSound = False)
			String sDisplayName = WornObject.GetDisplayName(kWeaponDummy,iHand,iSlotMask)
			If (sDisplayName && sDisplayName != kItem.GetName()) || WornObject.GetItemHealthPercent(kWeaponDummy,iHand,iSlotMask) > 1.0
				DebugTrace(kItem + " is a custom item named " + WornObject.GetDisplayName(kWeaponDummy,iHand,iSlotMask))

				Int jPlayerCustomItems = GetRegObj(sRegKey + ".InventoryCustomItems")
				If !jPlayerCustomItems
					jPlayerCustomItems = JArray.Object()
				EndIf
				String sItemID = vFF_API_Item.SerializeEquippedObject(kItem,iHand,iSlotMask,kWeaponDummy)
				JArray.AddObj(jPlayerCustomItems,vFF_API_Item.GetItemJMap(sItemID))
				SetRegObj(sRegKey + ".InventoryCustomItems",jPlayerCustomItems)
			EndIf
			kWeaponDummy.RemoveItem(kItem,iHand,True,PlayerREF)
		EndIf
	EndWhile
	kWeaponDummy.Delete()
	i = JArray.Count(jAmmoList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jWeaponArmorList,i)
		If kItem
			If PlayerRef.IsEquipped(kItem)
				SetRegForm(sRegKey + ".Equipment.Ammo",kItem)
			EndIf
		EndIf
	EndWhile
	SetRegObj(sRegKey + ".Inventory",jInventory)
	SetRegObj(sRegKey + ".InventoryInfo",jInventoryInfo)
	SendModEvent("vFFC_InventorySaveEnd")
	StopTimer("SavePlayerInventory")
	JValue.CleanPool("vFFC_InventoryPool")
EndFunction

Function ScanPlayerNINodeInfo()
	;== NINodeInfo ===--
	If GetSessionBool("Status.NINodeInfo.Busy")
		Return
	EndIf
	SetSessionBool("Status.NINodeInfo.Busy",True)
	StartTimer("ScanPlayerNINodeInfo")
		
	;== Save node info from RaceMenuPlugins ===--
	SetSessionObj("NINodeData",GetNINodeInfo(PlayerREF))
	
	StopTimer("ScanPlayerNINodeInfo")
	
	SetSessionBool("Status.NINodeInfo.Busy",False)
EndFunction

Function SavePlayerNINodeInfo()
	;== NINodeInfo ===--
	
	StartTimer("SavePlayerNINodeInfo")
	SendModEvent("vFFC_NINodeInfoSaveBegin")

	While GetSessionBool("Status.NINodeInfo.Busy")
		WaitMenuMode(1.0)
	EndWhile
	If !HasSessionKey("NINodeData")
		ScanPlayerNINodeInfo()
	EndIf
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	;== Save node info from RaceMenuPlugins ===--
	SetRegObj(sRegKey + ".NINodeData",GetSessionObj("NINodeData"))
	
	StopTimer("SavePlayerNINodeInfo")
	
	SendModEvent("vFFC_NINodeInfoSaveEnd")
EndFunction

Int Function SavePlayerMiscStats()
	StartTimer("SavePlayerMiscStats")
	SendModEvent("vFFC_MiscStatSaveBegin")
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	;== Save misc stats ===--
	Int jMiscStatNames = GetRegObj("MiscStatNames")
	Int i = JArray.Count(jMiscStatNames)
	Int jMiscStats = JMap.Object()
	SetRegObj(sRegKey + ".MiscStats",jMiscStats)
	While i > 0
		i -= 1
		String sStatName = JArray.GetStr(jMiscStatNames,i)
		If sStatName
			Int iStat = QueryStat(sStatName)
			If iStat
				JMap.SetInt(jMiscStats,sStatName,iStat)
			EndIf
		EndIf
	EndWhile
	SendModEvent("vFFC_MiscStatSaveEnd")
	StopTimer("SavePlayerMiscStats")
	Return 0
EndFunction	
	
Int Function SavePlayerData()
	GotoState("Busy")
	DebugTrace("Saving player data...")
	StartTimer("SavePlayerData")
	String sSessionID = SessionID
	
	ActorBase 	kPlayerBase 	= PlayerREF.GetActorBase()
	String 		sPlayerName 	= kPlayerBase.GetName()

	
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + sPlayerName))
	If jSIDList
		Int iSID = JArray.Count(jSIDList)
		While iSID > 0
			iSID -= 1
			String sSID = JArray.GetStr(jSIDList,iSID)
			DebugTrace("Checking current session against " + sSID + "...")
			If Math.ABS(GetRegFlt("Characters." + sSID + META + ".PlayTime") - GetRealHoursPassed()) < 0.1
				sSessionID = sSID
				SetSessionID(sSID)
				DebugTrace("Current session matches " + sSID + "!")
			EndIf
		EndWhile
	EndIf

	
	String sRegKey = "Characters." + sSessionID
	Int jPlayerData = GetRegObj(sRegKey)
	
	If !jPlayerData
		DebugTrace("First save of " + sPlayerName + "(" + sSessionID + ")")
	Else
		DebugTrace("Will overwrite data of " + sPlayerName + " with playtime " + JValue.SolveFlt(jPlayerData,META + ".Playtime") + "!")
	EndIf

	;Clear/overwrite registry info for this character
	StartTimer("SaveInfo")
	;== Save basic info ==-
	jPlayerData = JMap.Object()
	SetRegObj(sRegKey,jPlayerData)
	DebugTrace(sRegKey + META + ".Name")
	SetRegFlt(sRegKey + META + ".PlayTime",GetRealHoursPassed())
	SetRegStr(sRegKey + META + ".Name",sPlayerName)
	SetRegStr(sRegKey + META + ".UUID",sSessionID)
	SetRegInt(sRegKey + META + ".Sex",kPlayerBase.GetSex())
	SetRegForm(sRegKey + META + ".Race",kPlayerBase.GetRace())
	SetRegInt(sRegKey + META + ".Level",PlayerREF.GetLevel())
	AddToReqList(kPlayerBase.GetRace(),"Race")
	SetRegStr(sRegKey + META + ".RaceText",kPlayerBase.GetRace().GetName())
	SetRegInt(sRegKey + META + ".SerializationVersion",SerializationVersion)
	
	;SetRegObj(sRegKey + "._vFF",GetRegObj(sRegKey + META))
	
	Int jPlayerModList = JArray.Object()
	Int iModCount = GetModCount()
	Int i = 0
	While i < iModCount
		JArray.AddStr(jPlayerModList,GetModName(i))
		i += 1
	EndWhile

	SetRegObj(sRegKey + META + ".Modlist",jPlayerModList)
	SetRegObj(sRegKey,jPlayerData)

	SetRegObj("Names." + sPlayerName + "." + sSessionID,jPlayerData)
	StopTimer("SaveInfo")
	
	_bSavedPerks 		= False
	_bSavedSpells 		= False
	_bSavedEquipment 	= False
	_bSavedInventory 	= False
	;_bSavedNINodeInfo	= False

	Int iSafety = 10
	While PlayerTracker.Busy && iSafety > 0
		iSafety -= 1
		WaitMenuMode(1.0)
	EndWhile

	RegisterForModEvent("vFFC_BackgroundFunction","OnBackgroundFunction")
	;SendModEvent("vFFC_BackgroundFunction","SavePlayerAchievements")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerMiscStats")
	;SendModEvent("vFFC_BackgroundFunction","SavePlayerNINodeInfo")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerPerks")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerInventory")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerSpells")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerShouts")
	SendModEvent("vFFC_BackgroundFunction","SavePlayerEquipment")
	
	WaitMenuMode(1)
	
	;== Save character appearance ===-
	StartTimer("SaveCharacter")
	
	Bool bUseExternal = False
	If GetModByName("EnhancedCharacterEdit.esp") < 255
		DebugTrace("ECE detected, using SaveExternalCharacter!")
		bUseExternal = True
	EndIf
	
	If CharGen.IsExternalEnabled() || bUseExternal
		SetRegBool(sRegKey + META + ".UsesExternalHead",True)
		 CharGen.SaveExternalCharacter(sPlayerName) 
	Else
		SetRegBool(sRegKey + META + ".UsesExternalHead",False)
		 CharGen.SaveCharacter(sPlayerName) 
	EndIf
	
	StopTimer("SaveCharacter")
	
	;== Save NINode/Override overlays ===--
	
	;=== Import NINode data from .jslot, if available ===--
	
	String sCharGenPath = "Data/skse/Plugins/CharGen/Exported/" + sPlayerName + ".jslot"
	Int jCharGenData = JValue.ReadFromFile(sCharGenPath)
	If jCharGenData
		SetRegObj(sRegKey + ".CharGenData", jCharGenData)
	Else
		;For whatever reason the jSlot couldn't be found or read, use legacy method
		SendModEvent("vFFC_BackgroundFunction","SavePlayerNINodeInfo")
		StartTimer("NIOverrideData")
		If SKSE.GetPluginVersion("NiOverride") >= 1 ; Check for NIO
			Int jNIOData = JMap.Object()
			SetRegObj(sRegKey + ".NIOverrideData.BodyOverlays",NIO_GetOverlayData("Body [Ovl",NIOverride.GetNumBodyOverlays()))
			SetRegObj(sRegKey + ".NIOverrideData.HandOverlays",NIO_GetOverlayData("Hand [Ovl",NIOverride.GetNumBodyOverlays()))
			SetRegObj(sRegKey + ".NIOverrideData.FeetOverlays",NIO_GetOverlayData("Feet [Ovl",NIOverride.GetNumBodyOverlays()))
			SetRegObj(sRegKey + ".NIOverrideData.FaceOverlays",NIO_GetOverlayData("Face [Ovl",NIOverride.GetNumBodyOverlays()))
		EndIf
		StopTimer("NIOverrideData")
		While !_bSavedNINodeInfo
			WaitMenuMode(0.5)
		EndWhile
	EndIf

	;FIXME: Restore Trophy functionality in an API-friendly way!
	;StartTimer("TrophyManagerUpdate")
	;vFFC_TrophyManager TrophyManager = Quest.GetQuest("vFFC_TrophyManagerQuest") as vFFC_TrophyManager
	;TrophyManager.UpdateAvailabilityList()
	;StopTimer("TrophyManagerUpdate")
	;SetRegObj(sRegKey + ".Trophies",GetSessionObj("Trophies"))
	;SetRegObj(sRegKey + ".TrophyData",GetSessionObj("TrophyData"))
	
	While (!_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells) 
		WaitMenuMode(0.5)
	EndWhile

	JValue.WriteToFile(GetRegObj(sRegKey),"Data/vFFC/" + sPlayerName + ".char.json")
	StopTimer("SavePlayerData")
	GotoState("")
;	Debug.MessageBox("Finished saving player!")
	Return 0 
EndFunction

Event OnBackgroundFunction(string eventName, string strArg, float numArg, Form sender)
	Int iMaxThreads = GetRegInt("Config.Debug.Perf.Threads.Max")
	If _iThreadCount >= iMaxThreads
		;DebugTrace("Deferring " + strArg + ", thread " + _iThreadCount + "/" + iMaxThreads)
		WaitMenuMode(1)
		SendModEvent("vFFC_BackgroundFunction",strArg)
		Return
	EndIf
	_iThreadCount += 1
	If GetSessionBool("Status.Background." + strArg)
		DebugTrace(strArg + " is already running! Ignoring duplicate request.")
		Return
	EndIf
	SetSessionBool("Status.Background." + strArg,True)
	
	;DebugTrace("Backgrounding " + strArg + ", thread " + _iThreadCount + "/" + iMaxThreads)
	If strArg == "SavePlayerEquipment"
		SavePlayerEquipment()
		_bSavedEquipment = True
	ElseIf strArg == "SavePlayerPerks"
		SavePlayerPerks()
		_bSavedPerks = True
	ElseIf strArg == "SavePlayerSpells"
		SavePlayerSpells()
		_bSavedSpells = True
	ElseIf strArg == "SavePlayerShouts"
		SavePlayerShouts()
		_bSavedSpells = True
	ElseIf strArg == "SavePlayerInventory"
		SavePlayerInventory()
		_bSavedInventory = True
	ElseIf strArg == "SavePlayerNINodeInfo"
		SavePlayerNINodeInfo()
		_bSavedNINodeInfo = True
	ElseIf strArg == "SavePlayerAchievements"
		SavePlayerAchievements()
	ElseIf strArg == "SavePlayerMiscStats"
		SavePlayerMiscStats()
	ElseIf strArg == "ScanPlayerPerks"
		ScanPlayerPerks()
	ElseIf strArg == "ScanPlayerStats"
		ScanPlayerStats()
	ElseIf strArg == "ScanPlayerInventory"
		ScanPlayerInventory()
	ElseIf strArg == "ScanPlayerEquipment"
		ScanPlayerEquipment()
	ElseIf strArg == "ScanPlayerNINodeInfo"
		ScanPlayerNINodeInfo()
	ElseIf strArg == "ScanPlayerSpells"
		ScanPlayerSpells()
	ElseIf strArg == "ScanPlayerShouts"
		ScanPlayerShouts()
	ElseIf strArg == "ScanPlayerAchievements"
		ScanPlayerAchievements()
	EndIf
	SetSessionBool("Status.Background." + strArg,False)
	_iThreadCount -= 1
EndEvent

;=== Functions - Character data import/export ===--

Function ImportCharacterFiles(String sDataFolder = "Data/vFFC/")
{Load data from all Data/vFFC/*.char.json files.}
	StartTimer("ImportCharacterFiles")
	DebugTrace("ImportCharacters!")
	DebugTrace("ImportCharacters is checking " + sDataFolder + " for character files...")
	Int jDirectoryScan = JValue.readFromDirectory(sDataFolder)

	Int jCharFiles = JMap.allKeys(jDirectoryScan)
	Int jCharData = JMap.allValues(jDirectoryScan)

	JValue.AddToPool(jDirectoryScan,"vFFC_DM_Import")
	JValue.AddToPool(jCharFiles,"vFFC_DM_Import")
	JValue.AddToPool(jCharData,"vFFC_DM_Import")
	
	Int i = JArray.Count(jCharData)
	;== Load and validate all files in the data directory ===--
	While i > 0
		i -= 1
		Int jCharacterData = JArray.getObj(jCharData,i)
		
;		DebugTrace("ImportCharacters - Checking " + JArray.GetStr(jCharFiles,i) + "...")
;		SetSessionObj(StringReplace(JArray.GetStr(jCharFiles,i),".","_"),jCharacterData)
;		SaveSession()
;		Debug.MessageBox("Saved session with " + JArray.GetStr(jCharFiles,i) + "!")
		If !JValue.SolveObj(jCharacterData,META)
			;Missing META key, copy it from the older one
			JValue.SolveObjSetter(jCharacterData,META,JValue.SolveObj(jCharacterData,"._MYC"),True)
		EndIf
		Int iDataVersion = jValue.SolveInt(jCharacterData,META + ".SerializationVersion")
		String sUUID = jValue.SolveStr(jCharacterData,META + ".UUID")
		String sCharacterName = jValue.SolveStr(jCharacterData,META + ".Name")
		Float fPlayTime = jValue.SolveFlt(jCharacterData,META + ".Playtime")
		If sCharacterName
			DebugTrace("ImportCharacters - " + JArray.GetStr(jCharFiles,i) + " is " + sCharacterName + "!")
		EndIf

		;It's possible the UUID is missing due to a bug in an earlier version		
		If iDataVersion >= 3 && sCharacterName && fPlayTime && !sUUID 
			sUUID = MatchSession(sCharacterName,fPlayTime)
			If !sUUID
				sUUID = FFUtils.UUID()
				;Get a UUID if FFUtils failed to do it
				If !sUUID
					sUUID = GetUUID()
				EndIf
			EndIf
		EndIf
		
		If iDataVersion >= 3 && sCharacterName && fPlayTime && sUUID
			;=== Data is complete enough to load ===--
			If !HasRegKey("Characters." + sUUID) ; Character doesn't exist, import them
				DebugTrace("ImportCharacters - Adding " + sCharacterName + " to the registry with UUID " + sUUID)
				SetRegObj("Characters." + sUUID,jCharacterData)
				SetRegObj("Names." + sCharacterName + "." + sUUID,jCharacterData)
				If iDataVersion < SerializationVersion
					DebugTrace("ImportCharacters - Upgrading data from version " + iDataVersion + " for " + sCharacterName + "! (" + sUUID + ")")
					UpgradeData(sUUID)
				EndIf
			Else  ; Data already exists for this SSID
				;FIXME: If we're going to overwrite existing data check the playtime, ask the player
				If Math.ABS(GetRegFlt("Characters." + sUUID + META + ".PlayTime") - fPlayTime) < 0.1
					DebugTrace("ImportCharacters - Data for " + sCharacterName + " matches what's in the registry for UUID " + sUUID)
				Else ;== Data does NOT match up, prompt the player for what to do about it
					DebugTrace("ImportCharacters - Data for " + sCharacterName + " DOES NOT MATCH what's in the registry for UUID " + sUUID)
					;FIXME: This needs to do something
				EndIf
			EndIf
		ElseIf sCharacterName
			;== Data is from a version too old to be worth importing ==--
			DebugTrace("ImportCharacters - Data for " + sCharacterName + " is too old to import!",1)
		Else
			;== Data is not a character file. ==--
			DebugTrace("ImportCharacters - Skipping " + JArray.GetStr(jCharFiles,i) + "!")
		EndIf
	EndWhile
	JValue.CleanPool("vFFC_DM_Import")
	StopTimer("ImportCharacterFiles")
EndFunction

Int Function UpdateMetaData(String asUUID)
	Int jMetaData = GetRegObj("Characters." + asUUID + META)
	If !jMetaData
		jMetaData = GetRegObj("Characters." + asUUID + "._MYC")
		If !jMetaData
			jMetaData = GetRegObj("Characters." + asUUID + "._vFF")
		EndIf
		If jMetaData
			DebugTrace("UpdateMetaData - Found Metadata at old location, moving it...")
			SetRegObj("Characters." + asUUID + META,JValue.DeepCopy(jMetaData))
		EndIf
	EndIf
	ClearRegKey("Characters." + asUUID + "._MYC")
	ClearRegKey("Characters." + asUUID + "._vFF")
	Return jMetaData
EndFunction

Function UpgradeRegistryData()
	StartTimer("UpgradeRegistryData")
	Int jCharacters = JMap.AllKeys(GetRegObj("Characters"))
	JValue.addToPool(jCharacters,"vFF_CharacterPool")
	Int i = JArray.Count(jCharacters)
	While i > 0
		i -= 1
		String sUUID = JArray.GetStr(jCharacters,i)
		Int jMetaData = UpdateMetaData(sUUID)
		If jMetaData
			Int iDataVersion = GetRegInt("Characters." + sUUID + META + ".SerializationVersion")
			;If iDataVersion < SerializationVersion
				String sCharacterName = GetRegStr("Characters." + sUUID + META + ".Name")
				DebugTrace("UpgradeRegistryData - Upgrading Registry data from version " + iDataVersion + " for " + sCharacterName + "! (" + sUUID + ")")
				UpgradeData(sUUID)
			;EndIf
		Else
			DebugTrace("UpgradeRegistryData - No Metadata could be found for " + sUUID + "!")
		EndIf
	EndWhile
	JValue.cleanPool("vFF_CharacterPool")
	StopTimer("UpgradeRegistryData")
EndFunction

Function UpgradeData(String sUUID)
{Upgrade data from earlier version to match current version.}
	Int jCharacterData = GetRegObj("Characters." + sUUID)
	If !jCharacterData
		DebugTrace("UpgradeData - No data for " + sUUID + "!")
		Return
	EndIf
	;StartTimer("UpgradeData")

	String sCharacterName = GetRegStr("Characters." + sUUID + META + ".Name")

	If !HasRegKey("Characters." + sUUID + META + ".Race")
		SetRegForm("Characters." + sUUID + META + ".Race",GetRegForm("Characters." + sUUID + ".Race"))
	EndIf

	If !HasRegKey("Characters." + sUUID + META + ".Sex")
		SetRegInt("Characters." + sUUID + META + ".Sex",GetRegInt("Characters." + sUUID + ".Sex"))
	EndIf

	;=== Upgrade Inventory section ===--

	Int jOldInventory = GetRegObj("Characters." + sUUID + ".Inventory")
	If JValue.IsFormMap(jOldInventory)
		;Old inventory storage, upgrade it
		;DebugTrace("UpgradeData - Upgrading Inventory...")
		Int jOldItems = JFormMap.AllKeys(jOldInventory)
		Int jNewInventory = JMap.Object()
		Int i = JArray.Count(jOldItems)
		While i > 0
			i -= 1
			Form kItem = JArray.GetForm(jOldItems,i)
			If kItem
				Int iItemCount = JFormMap.GetInt(jOldInventory,kItem)
				Int iItemType = kItem.GetType()
				Int jItemTypeMap = JMap.GetObj(jNewInventory,iItemType)
				If !jItemTypeMap
					jItemTypeMap = JFormMap.Object()
					JMap.SetObj(jNewInventory,iItemType,jItemTypeMap)
				EndIf
				JFormMap.SetInt(jItemTypeMap,kItem,iItemCount)
			EndIf
		EndWhile
		JMap.SetObj(jCharacterData,"Inventory",jNewInventory)
	EndIf

	;=== Upgrade Equipment section ===--

	Int jOldArmorInfo = GetRegObj("Characters." + sUUID + ".Equipment.ArmorInfo")
	If JValue.IsArray(jOldArmorInfo)
		;DebugTrace("UpgradeData - Upgrading ArmorInfo...")
		Int jNewArmorInfos = JArray.Object()
		Int i = JArray.Count(jOldArmorInfo)
		While i > 0
			i -= 1
			Int ajItemInfo = JArray.GetObj(jOldArmorInfo,i)
			String sItemID = vFF_API_Item.SaveItem(ajItemInfo)
			If sItemID
				JArray.AddObj(jNewArmorInfos,vFF_API_Item.GetItemJMap(sItemID))
			EndIf
		EndWhile
		JValue.SolveObjSetter(jCharacterData,".Equipment.ArmorInfo",jNewArmorInfos)
	EndIf

	String[] sHands = New String[2]
	sHands[0] = "Right"
	sHands[1] = "Left"

	Bool bTwoHanded = False

	Int iHand = 0
	While iHand < 2
		Int jOldHandInfo = GetRegObj("Characters." + sUUID + ".Equipment." + sHands[iHand])
		Form kItem = JValue.SolveForm(jOldHandInfo,".Form")
		If kItem as Weapon 
			Weapon kWeapon = kItem as Weapon
			If kWeapon
				If kWeapon.IsBow() || kWeapon.IsGreatsword() || kWeapon.IsWaraxe() || kWeapon.IsWarhammer()
					bTwoHanded = True
				EndIf
			EndIf
		EndIf
		If bTwoHanded && sHands[iHand] == "Left"
			SetRegObj("Characters." + sUUID + ".Equipment.Left",JMap.Object())
		Else
			String sItemID = vFF_API_Item.SaveItem(jOldHandInfo)
			If sItemID
				SetRegObj("Characters." + sUUID + ".Equipment." + sHands[iHand],vFF_API_Item.GetItemJMap(sItemID))
			EndIf
		EndIf
		iHand += 1
	EndWhile

	;=== Upgrade InventoryCustomItems section ===--

	Int jOldItemInfos = GetRegObj("Characters." + sUUID + ".InventoryCustomItems")
	If JValue.IsArray(jOldItemInfos)
		;DebugTrace("UpgradeData - Upgrading ItemInfos...")
		Int jNewItemInfos = JArray.Object()
		Int i = JArray.Count(jOldItemInfos)
		While i > 0
			i -= 1
			Int ajItemInfo = JArray.GetObj(jOldItemInfos,i)
			String sItemID = vFF_API_Item.SaveItem(ajItemInfo)
			If sItemID
				JArray.AddObj(jNewItemInfos,vFF_API_Item.GetItemJMap(sItemID))
			EndIf
		EndWhile
		JMap.SetObj(jCharacterData,"InventoryCustomItems",jNewItemInfos)
	EndIf

	;=== Import NINode/Overlay data from .jslot, if available ===--

	String sCharGenPath = "Data/skse/Plugins/CharGen/Exported/" + sCharacterName + ".jslot"
	If JContainers.fileExistsAtPath(sCharGenPath)
		Int jCharGenInfo = JValue.ReadFromFile(sCharGenPath)
		If jCharGenInfo
			JMap.SetObj(jCharacterData,"CharGenData", jCharGenInfo)
			JMap.RemoveKey(jCharacterData,"NINodeInfo")
			JMap.RemoveKey(jCharacterData,"NIOverrideData")
		EndIf
	EndIf

	JValue.SolveIntSetter(jCharacterData,META + ".SerializationVersion",SerializationVersion)
	;StopTimer("UpgradeData")
EndFunction

;=== Functions - Requirement list ===--

String Function GetSourceMod(Form akForm)
	Return FFUtils.GetSourceMod(akForm)
EndFunction

Function AddToReqList(Form akForm, String asType, String sSID = "")
{Take the form and add its provider/source to the required mods list of the specified ajCharacterData.
If sSID is blank, then add to the current Session instead.}
	;Return
	
	If !sSID
		sSID = SessionID
	EndIf
	If !sSID || !akForm || !asType 
		Return
	EndIf

	Int jReqList 
	If sSID == SessionID 
		jReqList = GetSessionObj("Characters." + sSID + META + ".ReqList")		
	Else
		jReqList = GetRegObj("Characters." + sSID + META + ".ReqList")
	EndIf
	If !jReqList
		jReqList = JMap.Object()
	EndIf
	String sModName = FFUtils.GetSourceMod(akForm) ;GetSourceMod(akForm)
	If sModName
		If sModName == "Skyrim.esm" || sModName == "Update.esm"
			Return
		EndIf
		
		;sModName = StringReplace(sModName,".","_dot_") ; Strip . to avoid confusing JContainers
		sModName = StringUtil.Substring(sModName,0,StringUtil.Find(sModName,".")) ; Strip extension to avoid confusing JContainers
		String sFormName = akForm.GetName()
		If !sFormName
			sFormName = akForm as String
		EndIf
		If sSID == SessionID 
			SetSessionStr("Characters." + sSID + META + ".ReqList." + sModName + "." + asType + ".0x" + GetFormIDString(akForm),sFormName)
		Else
			SetRegStr("Characters." + sSID + META + ".ReqList." + sModName + "." + asType + ".0x" + GetFormIDString(akForm),sFormName)
		EndIf
	EndIf
EndFunction

;=== Functions - NIOverride ===--

Function InitNINodeList()
	Int jNINodeList = GetRegObj("NINodeList")
	If !jNINodeList
		jNINodeList = JValue.ReadFromFile("Data/vFF/vFFC_NodeList.json")
		SetRegObj("NINodeList",jNINodeList)
	EndIf
	DebugTrace("NINodeList contains " + JArray.Count(jNINodeList) + " entries!")
	Int i = 0
	Int iNodeCount = JArray.Count(jNINodeList)
	
	If !GetRegBool("Config.NINodeList.IsFiltered")
		DebugTrace("NINodeList needs filtering, we'll do that now.")
		While i < iNodeCount
			String sNodeName = JArray.getStr(jNINodeList,i)
			Bool bErased = False
			If sNodeName
				If !NetImmerse.HasNode(PlayerRef,sNodeName,False)
					JArray.EraseIndex(jNINodeList,i)
					bErased = True
				EndIf
			EndIf
			If bErased
				;DebugTrace("NINodeList - Erased entry " + sNodeName + "!")
				iNodeCount -= 1
			Else
				;DebugTrace("NINodeList - Retained entry " + sNodeName + "!")
				i += 1
			EndIf
		EndWhile
		SetRegObj("NINodeList",jNINodeList)
		SetRegBool("Config.NINodeList.IsFiltered",True)
		DebugTrace("NINodeList now contains " + JArray.Count(jNINodeList) + " entries!")
	EndIf
EndFunction

Int Function GetNINodeInfo(Actor akActor)
	Int jNINodeList = GetRegObj("NINodeList")
	If !jNINodeList
		jNINodeList = JValue.ReadFromFile("Data/vFFC/vFFC_NodeList.json")
		SetRegObj("NINodeList",jNINodeList)
	EndIf
	DebugTrace("NINodeList contains " + JArray.Count(jNINodeList) + " entries!")

	Int i = 0
	Int iNodeCount = JArray.Count(jNINodeList)
	Int jNINodes = JMap.Object()
	SetSessionObj("NINodeScales",jNINodes)
	While i < iNodeCount
		String sNodeName = JArray.getStr(jNINodeList,i)
		If sNodeName
			Float fNodeScale = NetImmerse.GetNodeScale(akActor,sNodeName,false)
			If fNodeScale && fNodeScale != 1.0 ;avoid saving defaults
				DebugTrace("Saving NINode " + sNodeName + " at scale " + fNodeScale + "!")
				Int jNINodeData = JMap.Object()
				JMap.SetFlt(jNINodeData,"Scale",fNodeScale)
				JMap.SetObj(jNINodes,sNodeName,jNINodeData)
			EndIf
		EndIf
		i += 1
	EndWhile
	Return jNINodes
EndFunction

Int Function NIO_GetOverlayData(String sTintTemplate, Int iTintCount, Actor kTargetActor = None)
	If !kTargetActor
		kTargetActor = PlayerREF
	EndIf
	Int i
	Int jOverlayData = JArray.Object()
	While i < iTintCount
		String nodeName = sTintTemplate + i + "]"
		Int iRGB = 0
		Int iGlow = 0
		Float fMultiple = 0.0
		Float fAlpha = 0
		String sTexture = ""
		If NetImmerse.HasNode(kTargetActor, nodeName, false) ; Actor has the node, get the immediate property
			iRGB = NiOverride.GetNodePropertyInt(kTargetActor, false, nodeName, 7, -1)
			iGlow = NiOverride.GetNodePropertyInt(kTargetActor, false, nodeName, 0, -1)
			fAlpha = NiOverride.GetNodePropertyFloat(kTargetActor, false, nodeName, 8, -1)
			sTexture = NiOverride.GetNodePropertyString(kTargetActor, false, nodeName, 9, 0)
			fMultiple = NiOverride.GetNodePropertyFloat(kTargetActor, false, nodeName, 1, -1)
		Else ; Doesn't have the node, get it from the override
			bool isFemale = kTargetActor.GetActorBase().GetSex() as bool
			iRGB = NiOverride.GetNodeOverrideInt(kTargetActor, isFemale, nodeName, 7, -1)
			iGlow = NiOverride.GetNodeOverrideInt(kTargetActor, isFemale, nodeName, 0, -1)
			fAlpha = NiOverride.GetNodeOverrideFloat(kTargetActor, isFemale, nodeName, 8, -1)
			sTexture = NiOverride.GetNodeOverrideString(kTargetActor, isFemale, nodeName, 9, 0)
			fMultiple = NiOverride.GetNodeOverrideFloat(kTargetActor, isFemale, nodeName, 1, -1)
		Endif
		Int iColor = Math.LogicalOr(Math.LogicalAnd(iRGB, 0xFFFFFF), Math.LeftShift((fAlpha * 255) as Int, 24))
		Int iGlowData = Math.LogicalOr(Math.LeftShift(((fMultiple * 10.0) as Int), 24), iGlow)
		If sTexture == ""
			sTexture = "Actors\\Character\\Overlays\\Default.dds"
		Endif
		;"HandOverlays": [
        ;  {
        ;    "Alpha": 0.0,
        ;    "color": 0,
        ;    "rgb": 0,
        ;    "glow": 0,
        ;    "GlowData": 0,
        ;    "texture": "Actors\\Character\\Overlays\\Default.dds",
        ;    "multiple": 0.0
			;textures\\actors\\character\\overlays\\default.dds
		If !(StringUtil.Find(sTexture,"Default.dds") > -1)  ;!(iRGB + iGlow + fAlpha + fMultiple == 0) && ;|| (iRGB && iRGB != -1 && iRGB != 16777215) || (sTexture && sTexture != "Textures\\Actors\\Character\\Overlays\\Default.dds")
			Int jLayer = JMap.Object()
			JMap.setInt(jLayer,"RGB",iRGB)
			JMap.setInt(jLayer,"Glow",iGlow)
			JMap.setInt(jLayer,"GlowData",iGlowData)
			JMap.setFlt(jLayer,"Alpha",fAlpha)
			JMap.setFlt(jLayer,"Multiple",fMultiple)
			JMap.setInt(jLayer,"Color",iColor)
			JMap.setStr(jLayer,"Texture",sTexture)
			JArray.AddObj(jOverlayData,jLayer)
		EndIf
		i += 1
	EndWhile
	Return jOverlayData
EndFunction

;=== Functions - Utility ===--

;Event OnLoadSerializedEquipmentReq(Int jItem)
;	Int iMaxThreads = GetRegInt("Config.Debug.Perf.Threads.Max")
;	If _iThreadCount >= iMaxThreads
;		DebugTrace("Deferring LoadSerializedEquipmentReq, thread " + _iThreadCount + "/" + iMaxThreads)
;		WaitMenuMode(RandomFloat(0.8,1.2))
;		Int iEventHandle = ModEvent.Create("vFFC_LoadSerializedEquipmentObj")
;		If iEventHandle
;			ModEvent.PushForm(iEventHandle,vFF_API_Item.CreateItem(jItem))
;			ModEvent.Send(iEventHandle)
;		EndIf
;		Return
;	EndIf
;	_iThreadCount += 1
;	Int iEventHandle = ModEvent.Create("vFFC_LoadSerializedEquipmentObject")
;	If iEventHandle
;		ModEvent.PushForm(iEventHandle,LoadSerializedEquipment(jItem))
;		ModEvent.Send(iEventHandle)
;	EndIf
;	_iThreadCount -= 1
;EndEvent

Formlist Function LockFormlist()
	Int jTempFormlistPool = GetSessionObj("TempFormlistPool")
	If !JValue.IsArray(jTempFormlistPool)
		jTempFormlistPool = JArray.Object()
		JArray.AddFromFormList(jTempFormlistPool,vFFC_zTempListsList)
		SetSessionObj("TempFormlistPool",jTempFormlistPool)
	EndIf
	Int iSafetyTimer = 5
	While JArray.Count(jTempFormlistPool) == 0 && iSafetyTimer
		iSafetyTimer -= 1
		WaitMenuMode(0.5)
	EndWhile
	If !iSafetyTimer
		DebugTrace("Warning! Couldn't lock a formlist!",1)
		Return None
	EndIf
	Formlist kFormlist = JArray.GetForm(jTempFormlistPool,0) as Formlist
	JArray.EraseIndex(jTempFormlistPool,0)
	Return kFormList
EndFunction

Function UnlockFormlist(Formlist kLockedFormlist)
	Int jTempFormlistPool = GetSessionObj("TempFormlistPool")
	kLockedFormlist.Revert()
	If JArray.FindForm(jTempFormlistPool,kLockedFormList) < 0
		JArray.AddForm(jTempFormlistPool,kLockedFormlist)
	EndIf
EndFunction

String Function MatchSession(String sCharacterName = "", Float fPlayTime = 0.0)
{Return the UUID of a session that matches the passed name and playtime. Use the current player's data if none supplied.}
	If !sCharacterName
		sCharacterName = PlayerREF.GetActorBase().GetName()
	EndIf
	If !fPlayTime
		fPlayTime = GetRealHoursPassed()
	EndIf
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + sCharacterName))
	DebugTrace("Looking for matching session in " + JArray.Count(jSIDList) + " saved sessions!")
	If jSIDList
		Int iSID = JArray.Count(jSIDList)
		While iSID > 0
			iSID -= 1
			String sSID = JArray.GetStr(jSIDList,iSID)
			DebugTrace("Checking current session against " + sSID + "...")
			If Math.ABS(GetRegFlt("Characters." + sSID + META + ".PlayTime") - fPlayTime) < 0.1
				DebugTrace("Current session matches " + sSID + "!")
				Return sSID
			EndIf
		EndWhile
	EndIf
	Return ""
EndFunction

; Function SetSessionID(String sSessionID = "")
; 	If !sSessionID && !GetSessionStr("SessionID")
; 		SetSessionStr("SessionID",GetUUIDTrue())
; 		DebugTrace("Set SessionID: " + GetSessionStr("SessionID"))
; 	ElseIf !sSessionID && GetSessionStr("SessionID")
; 		DebugTrace("SessionID already set!")
; 	ElseIf sSessionID
; 		SetSessionStr("SessionID",sSessionID)
; 		DebugTrace("Forced SessionID: " + sSessionID)
; 	EndIf
; EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/DataManager: " + sDebugString,iSeverity)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

Function StartTimer(String sTimerLabel)
	Float fTime = GetCurrentRealTime()
	;Debug.Trace("TimerStart(" + sTimerLabel + ") " + fTime)
	;DebugTrace("Timer: Starting for " + sTimerLabel)
	SetSessionFlt("Timers." + sTimerLabel,fTime)
EndFunction

Function StopTimer(String sTimerLabel)
	Float fTime = GetCurrentRealTime()
	;Debug.Trace("TimerStop (" + sTimerLabel + ") " + fTime)
	DebugTrace("Timer: " + (fTime - GetSessionFlt("Timers." + sTimerLabel)) + " for " + sTimerLabel)
	ClearSessionKey("Timers." + sTimerLabel)
EndFunction

String Function StringReplace(String sString, String sToFind, String sReplacement)
	If sToFind == sReplacement 
		Return sString
	EndIf
	While StringUtil.Find(sString,sToFind) > -1
		sString = StringUtil.SubString(sString,0,StringUtil.Find(sString,sToFind)) + sReplacement + StringUtil.SubString(sString,StringUtil.Find(sString,sToFind) + 1)
	EndWhile
	Return sString
EndFunction

String[] Function JObjToArrayStr(Int ajObj)

	String[] sReturn
	Int jStrArray
	If JValue.IsMap(ajObj)
		jStrArray = JMap.AllKeys(ajObj)
	ElseIf jValue.IsArray(ajObj)
		jStrArray = ajObj
	EndIf
	If jStrArray
		Int i = JArray.Count(jStrArray)
		DebugTrace("JObjToArrayStr: Converting " + i + " jValues to an array of strings...")
		sReturn = Utility.CreateStringArray(i, "")
		While i > 0
			i -= 1
			sReturn[i] = JArray.GetStr(jStrArray,i)
			DebugTrace("JObjToArrayStr:  Added " + sReturn[i] + " at index " + i + "!")
		EndWhile
	EndIf
	DebugTrace("JObjToArrayStr: Done!")
	Return sReturn
EndFunction

String Function GetAVName(Int iAVIndex)
	If !_jAVNames
		DebugTrace("Pulling AVNames from registry...")
		_jAVNames = GetRegObj("AVNames")
		If !_jAVNames
			CreateAVNames()
			_jAVNames = GetRegObj("AVNames")
		EndIf
	EndIf
	Return JArray.GetStr(_jAVNames,iAVIndex)
EndFunction

Function CreateMiscStatNames()
	Int jMiscStatNames = JArray.Object()
	JArray.AddStr(jMiscStatNames,"Locations Discovered")
	JArray.AddStr(jMiscStatNames,"Dungeons Cleared")
	JArray.AddStr(jMiscStatNames,"Days Passed")
	JArray.AddStr(jMiscStatNames,"Hours Slept")
	JArray.AddStr(jMiscStatNames,"Hours Waiting")
	JArray.AddStr(jMiscStatNames,"Standing Stones Found")
	JArray.AddStr(jMiscStatNames,"Gold Found")
	JArray.AddStr(jMiscStatNames,"Most Gold Carried")
	JArray.AddStr(jMiscStatNames,"Chests Looted")
	JArray.AddStr(jMiscStatNames,"Skill Increases")
	JArray.AddStr(jMiscStatNames,"Skill Books Read")
	JArray.AddStr(jMiscStatNames,"Food Eaten")
	JArray.AddStr(jMiscStatNames,"Training Sessions")
	JArray.AddStr(jMiscStatNames,"Books Read")
	JArray.AddStr(jMiscStatNames,"Horses Owned")
	JArray.AddStr(jMiscStatNames,"Houses Owned")
	JArray.AddStr(jMiscStatNames,"Stores Invested In")
	JArray.AddStr(jMiscStatNames,"Barters")
	JArray.AddStr(jMiscStatNames,"Persuasions")
	JArray.AddStr(jMiscStatNames,"Bribes")
	JArray.AddStr(jMiscStatNames,"Intimidations")
	JArray.AddStr(jMiscStatNames,"Diseases Contracted")
	JArray.AddStr(jMiscStatNames,"Days as a Vampire")
	JArray.AddStr(jMiscStatNames,"Days as a Werewolf")
	JArray.AddStr(jMiscStatNames,"Necks Bitten")
	JArray.AddStr(jMiscStatNames,"Vampirism Cures")
	JArray.AddStr(jMiscStatNames,"Werewolf Transformations")
	JArray.AddStr(jMiscStatNames,"Mauls")
	JArray.AddStr(jMiscStatNames,"Quests Completed")
	JArray.AddStr(jMiscStatNames,"Misc Objectives Completed")
	JArray.AddStr(jMiscStatNames,"Main Quests Completed")
	JArray.AddStr(jMiscStatNames,"Side Quests Completed")
	JArray.AddStr(jMiscStatNames,"The Companions Quests Completed")
	JArray.AddStr(jMiscStatNames,"College of Winterhold Quests Completed")
	JArray.AddStr(jMiscStatNames,"Thieves' Guild Quests Completed")
	JArray.AddStr(jMiscStatNames,"The Dark Brotherhood Quests Completed")
	JArray.AddStr(jMiscStatNames,"Civil War Quests Completed")
	JArray.AddStr(jMiscStatNames,"Daedric Quests Completed")
	JArray.AddStr(jMiscStatNames,"Dawnguard Quests Completed")
	JArray.AddStr(jMiscStatNames,"Dragonborn Quests Completed")
	JArray.AddStr(jMiscStatNames,"Questlines Completed")
	JArray.AddStr(jMiscStatNames,"People Killed")
	JArray.AddStr(jMiscStatNames,"Animals Killed")
	JArray.AddStr(jMiscStatNames,"Creatures Killed")
	JArray.AddStr(jMiscStatNames,"Undead Killed")
	JArray.AddStr(jMiscStatNames,"Daedra Killed")
	JArray.AddStr(jMiscStatNames,"Automatons Killed")
	JArray.AddStr(jMiscStatNames,"Favorite Weapon")
	JArray.AddStr(jMiscStatNames,"Critical Strikes")
	JArray.AddStr(jMiscStatNames,"Sneak Attacks")
	JArray.AddStr(jMiscStatNames,"Backstabs")
	JArray.AddStr(jMiscStatNames,"Weapons Disarmed")
	JArray.AddStr(jMiscStatNames,"Brawls Won")
	JArray.AddStr(jMiscStatNames,"Bunnies Slaughtered")
	JArray.AddStr(jMiscStatNames,"Spells Learned")
	JArray.AddStr(jMiscStatNames,"Favorite Spell")
	JArray.AddStr(jMiscStatNames,"Favorite School")
	JArray.AddStr(jMiscStatNames,"Dragon Souls Collected")
	JArray.AddStr(jMiscStatNames,"Words Of Power Learned")
	JArray.AddStr(jMiscStatNames,"Words Of Power Unlocked")
	JArray.AddStr(jMiscStatNames,"Shouts Learned")
	JArray.AddStr(jMiscStatNames,"Shouts Unlocked")
	JArray.AddStr(jMiscStatNames,"Shouts Mastered")
	JArray.AddStr(jMiscStatNames,"Times Shouted")
	JArray.AddStr(jMiscStatNames,"Favorite Shout")
	JArray.AddStr(jMiscStatNames,"Soul Gems Used")
	JArray.AddStr(jMiscStatNames,"Souls Trapped")
	JArray.AddStr(jMiscStatNames,"Magic Items Made")
	JArray.AddStr(jMiscStatNames,"Weapons Improved")
	JArray.AddStr(jMiscStatNames,"Weapons Made")
	JArray.AddStr(jMiscStatNames,"Armor Improved")
	JArray.AddStr(jMiscStatNames,"Armor Made")
	JArray.AddStr(jMiscStatNames,"Potions Mixed")
	JArray.AddStr(jMiscStatNames,"Potions Used")
	JArray.AddStr(jMiscStatNames,"Poisons Mixed")
	JArray.AddStr(jMiscStatNames,"Poisons Used")
	JArray.AddStr(jMiscStatNames,"Ingredients Harvested")
	JArray.AddStr(jMiscStatNames,"Ingredients Eaten")
	JArray.AddStr(jMiscStatNames,"Nirnroots Found")
	JArray.AddStr(jMiscStatNames,"Wings Plucked")
	JArray.AddStr(jMiscStatNames,"Total Lifetime Bounty")
	JArray.AddStr(jMiscStatNames,"Largest Bounty")
	JArray.AddStr(jMiscStatNames,"Locks Picked")
	JArray.AddStr(jMiscStatNames,"Pockets Picked")
	JArray.AddStr(jMiscStatNames,"Items Pickpocketed")
	JArray.AddStr(jMiscStatNames,"Times Jailed")
	JArray.AddStr(jMiscStatNames,"Days Jailed")
	JArray.AddStr(jMiscStatNames,"Fines Paid")
	JArray.AddStr(jMiscStatNames,"Jail Escapes")
	JArray.AddStr(jMiscStatNames,"Items Stolen")
	JArray.AddStr(jMiscStatNames,"Assaults")
	JArray.AddStr(jMiscStatNames,"Murders")
	JArray.AddStr(jMiscStatNames,"Horses Stolen")
	JArray.AddStr(jMiscStatNames,"Trespasses")
	JArray.AddStr(jMiscStatNames,"Eastmarch Bounty")
	JArray.AddStr(jMiscStatNames,"Falkreath Bounty")
	JArray.AddStr(jMiscStatNames,"Haafingar Bounty")
	JArray.AddStr(jMiscStatNames,"Hjaalmarch Bounty")
	JArray.AddStr(jMiscStatNames,"The Pale Bounty")
	JArray.AddStr(jMiscStatNames,"The Reach Bounty")
	JArray.AddStr(jMiscStatNames,"The Rift Bounty")
	JArray.AddStr(jMiscStatNames,"Tribal Orcs Bounty")
	JArray.AddStr(jMiscStatNames,"Whiterun Bounty")
	JArray.AddStr(jMiscStatNames,"Winterhold Bounty")
	SetRegObj("MiscStatNames",jMiscStatNames)
EndFunction

Function CreateAVNames()
	DebugTrace("Indexing AVNames from scratch!")
	_jAVNames = JArray.Object()
	JArray.AddStr(_jAVNames,"Aggression")
	JArray.AddStr(_jAVNames,"Confidence")
	JArray.AddStr(_jAVNames,"Energy")
	JArray.AddStr(_jAVNames,"Morality")
	JArray.AddStr(_jAVNames,"Mood")
	JArray.AddStr(_jAVNames,"Assistance")
	JArray.AddStr(_jAVNames,"OneHanded")
	JArray.AddStr(_jAVNames,"TwoHanded")
	JArray.AddStr(_jAVNames,"Marksman")
	JArray.AddStr(_jAVNames,"Block")
	JArray.AddStr(_jAVNames,"Smithing")
	JArray.AddStr(_jAVNames,"HeavyArmor")
	JArray.AddStr(_jAVNames,"LightArmor")
	JArray.AddStr(_jAVNames,"Pickpocket")
	JArray.AddStr(_jAVNames,"LockPicking")
	JArray.AddStr(_jAVNames,"Sneak")
	JArray.AddStr(_jAVNames,"Alchemy")
	JArray.AddStr(_jAVNames,"SpeechCraft")
	JArray.AddStr(_jAVNames,"Alteration")
	JArray.AddStr(_jAVNames,"Conjuration")
	JArray.AddStr(_jAVNames,"Destruction")
	JArray.AddStr(_jAVNames,"Illusion") ; Wiki says Mysticism but game expects Illusion
	JArray.AddStr(_jAVNames,"Restoration")
	JArray.AddStr(_jAVNames,"Enchanting")
	JArray.AddStr(_jAVNames,"Health")
	JArray.AddStr(_jAVNames,"Magicka")
	JArray.AddStr(_jAVNames,"Stamina")
	JArray.AddStr(_jAVNames,"HealRate")
	JArray.AddStr(_jAVNames,"MagickaRate")
	JArray.AddStr(_jAVNames,"StaminaRate")
	JArray.AddStr(_jAVNames,"SpeedMult")
	JArray.AddStr(_jAVNames,"InventoryWeight")
	JArray.AddStr(_jAVNames,"CarryWeight")
	JArray.AddStr(_jAVNames,"CritChance")
	JArray.AddStr(_jAVNames,"MeleeDamage")
	JArray.AddStr(_jAVNames,"UnarmedDamage")
	JArray.AddStr(_jAVNames,"Mass")
	JArray.AddStr(_jAVNames,"VoicePoints")
	JArray.AddStr(_jAVNames,"VoiceRate")
	JArray.AddStr(_jAVNames,"DamageResist")
	JArray.AddStr(_jAVNames,"PoisonResist")
	JArray.AddStr(_jAVNames,"FireResist")
	JArray.AddStr(_jAVNames,"ElectricResist")
	JArray.AddStr(_jAVNames,"FrostResist")
	JArray.AddStr(_jAVNames,"MagicResist")
	JArray.AddStr(_jAVNames,"NormalWeaponsResist")
	JArray.AddStr(_jAVNames,"PerceptionCondition")
	JArray.AddStr(_jAVNames,"EnduranceCondition")
	JArray.AddStr(_jAVNames,"LeftAttackCondition")
	JArray.AddStr(_jAVNames,"RightAttackCondition")
	JArray.AddStr(_jAVNames,"LeftMobilityCondition")
	JArray.AddStr(_jAVNames,"RightMobilityCondition")
	JArray.AddStr(_jAVNames,"BrainCondition")
	JArray.AddStr(_jAVNames,"Paralysis")
	JArray.AddStr(_jAVNames,"Invisibility")
	JArray.AddStr(_jAVNames,"NightEye")
	JArray.AddStr(_jAVNames,"DetectLifeRange")
	JArray.AddStr(_jAVNames,"WaterBreathing")
	JArray.AddStr(_jAVNames,"WaterWalking")
	JArray.AddStr(_jAVNames,"IgnoreCrippleLimbs")
	JArray.AddStr(_jAVNames,"Fame")
	JArray.AddStr(_jAVNames,"Infamy")
	JArray.AddStr(_jAVNames,"JumpingBonus")
	JArray.AddStr(_jAVNames,"WardPower")
	JArray.AddStr(_jAVNames,"EquippedItemCharge")
	JArray.AddStr(_jAVNames,"ArmorPerks")
	JArray.AddStr(_jAVNames,"ShieldPerks")
	JArray.AddStr(_jAVNames,"WardDeflection")
	JArray.AddStr(_jAVNames,"Variable01")
	JArray.AddStr(_jAVNames,"Variable02")
	JArray.AddStr(_jAVNames,"Variable03")
	JArray.AddStr(_jAVNames,"Variable04")
	JArray.AddStr(_jAVNames,"Variable05")
	JArray.AddStr(_jAVNames,"Variable06")
	JArray.AddStr(_jAVNames,"Variable07")
	JArray.AddStr(_jAVNames,"Variable08")
	JArray.AddStr(_jAVNames,"Variable09")
	JArray.AddStr(_jAVNames,"Variable10")
	JArray.AddStr(_jAVNames,"BowSpeedBonus")
	JArray.AddStr(_jAVNames,"FavorActive")
	JArray.AddStr(_jAVNames,"FavorsPerDay")
	JArray.AddStr(_jAVNames,"FavorsPerDayTimer")
	JArray.AddStr(_jAVNames,"EquippedStaffCharge")
	JArray.AddStr(_jAVNames,"AbsorbChance")
	JArray.AddStr(_jAVNames,"Blindness")
	JArray.AddStr(_jAVNames,"WeaponSpeedMult")
	JArray.AddStr(_jAVNames,"ShoutRecoveryMult")
	JArray.AddStr(_jAVNames,"BowStaggerBonus")
	JArray.AddStr(_jAVNames,"Telekinesis")
	JArray.AddStr(_jAVNames,"FavorPointsBonus")
	JArray.AddStr(_jAVNames,"LastBribedIntimidated")
	JArray.AddStr(_jAVNames,"LastFlattered")
	JArray.AddStr(_jAVNames,"Muffled")
	JArray.AddStr(_jAVNames,"BypassVendorStolenCheck")
	JArray.AddStr(_jAVNames,"BypassVendorKeywordCheck")
	JArray.AddStr(_jAVNames,"WaitingForPlayer")
	JArray.AddStr(_jAVNames,"OneHandedMod")
	JArray.AddStr(_jAVNames,"TwoHandedMod")
	JArray.AddStr(_jAVNames,"MarksmanMod")
	JArray.AddStr(_jAVNames,"BlockMod")
	JArray.AddStr(_jAVNames,"SmithingMod")
	JArray.AddStr(_jAVNames,"HeavyArmorMod")
	JArray.AddStr(_jAVNames,"LightArmorMod")
	JArray.AddStr(_jAVNames,"PickPocketMod")
	JArray.AddStr(_jAVNames,"LockPickingMod")
	JArray.AddStr(_jAVNames,"SneakMod")
	JArray.AddStr(_jAVNames,"AlchemyMod")
	JArray.AddStr(_jAVNames,"SpeechcraftMod")
	JArray.AddStr(_jAVNames,"AlterationMod")
	JArray.AddStr(_jAVNames,"ConjurationMod")
	JArray.AddStr(_jAVNames,"DestructionMod")
	JArray.AddStr(_jAVNames,"IllusionMod")
	JArray.AddStr(_jAVNames,"RestorationMod")
	JArray.AddStr(_jAVNames,"EnchantingMod")
	JArray.AddStr(_jAVNames,"OneHandedSkillAdvance")
	JArray.AddStr(_jAVNames,"TwoHandedSkillAdvance")
	JArray.AddStr(_jAVNames,"MarksmanSkillAdvance")
	JArray.AddStr(_jAVNames,"BlockSkillAdvance")
	JArray.AddStr(_jAVNames,"SmithingSkillAdvance")
	JArray.AddStr(_jAVNames,"HeavyArmorSkillAdvance")
	JArray.AddStr(_jAVNames,"LightArmorSkillAdvance")
	JArray.AddStr(_jAVNames,"PickPocketSkillAdvance")
	JArray.AddStr(_jAVNames,"LockPickingSkillAdvance")
	JArray.AddStr(_jAVNames,"SneakSkillAdvance")
	JArray.AddStr(_jAVNames,"AlchemySkillAdvance")
	JArray.AddStr(_jAVNames,"SpeechcraftSkillAdvance")
	JArray.AddStr(_jAVNames,"AlterationSkillAdvance")
	JArray.AddStr(_jAVNames,"ConjurationSkillAdvance")
	JArray.AddStr(_jAVNames,"DestructionSkillAdvance")
	JArray.AddStr(_jAVNames,"IllusionSkillAdvance")
	JArray.AddStr(_jAVNames,"RestorationSkillAdvance")
	JArray.AddStr(_jAVNames,"EnchantingSkillAdvance")
	JArray.AddStr(_jAVNames,"LeftWeaponSpeedMult")
	JArray.AddStr(_jAVNames,"DragonSouls")
	JArray.AddStr(_jAVNames,"CombatHealthRegenMult")
	JArray.AddStr(_jAVNames,"OneHandedPowerMod")
	JArray.AddStr(_jAVNames,"TwoHandedPowerMod")
	JArray.AddStr(_jAVNames,"MarksmanPowerMod")
	JArray.AddStr(_jAVNames,"BlockPowerMod")
	JArray.AddStr(_jAVNames,"SmithingPowerMod")
	JArray.AddStr(_jAVNames,"HeavyArmorPowerMod")
	JArray.AddStr(_jAVNames,"LightArmorPowerMod")
	JArray.AddStr(_jAVNames,"PickPocketPowerMod")
	JArray.AddStr(_jAVNames,"LockPickingPowerMod")
	JArray.AddStr(_jAVNames,"SneakPowerMod")
	JArray.AddStr(_jAVNames,"AlchemyPowerMod")
	JArray.AddStr(_jAVNames,"SpeechcraftPowerMod")
	JArray.AddStr(_jAVNames,"AlterationPowerMod")
	JArray.AddStr(_jAVNames,"ConjurationPowerMod")
	JArray.AddStr(_jAVNames,"DestructionPowerMod")
	JArray.AddStr(_jAVNames,"IllusionPowerMod")
	JArray.AddStr(_jAVNames,"RestorationPowerMod")
	JArray.AddStr(_jAVNames,"EnchantingPowerMod")
	JArray.AddStr(_jAVNames,"DragonRend")
	JArray.AddStr(_jAVNames,"AttackDamageMult")
	JArray.AddStr(_jAVNames,"CombatHealthRegenMultMod")
	JArray.AddStr(_jAVNames,"CombatHealthRegenMultPowerMod")
	JArray.AddStr(_jAVNames,"StaminaRateMult")
	JArray.AddStr(_jAVNames,"Werewolf") ; "HealRatePowerMod" before Dawnguard
	JArray.AddStr(_jAVNames,"Vampire Lord") ; "MagickaRateMod" before Dawnguard
	JArray.AddStr(_jAVNames,"GrabActorOffset")
	JArray.AddStr(_jAVNames,"Grabbed")
	JArray.AddStr(_jAVNames,"UNKNOWN")
	JArray.AddStr(_jAVNames,"ReflectDamage")
	SetRegObj("AVNames",_jAVNames)
	Int i = 0
	Int iAVCount = JArray.Count(_jAVNames)
	Int jSkills = JArray.Object()
	SetRegObj("SkillAVIs",jSkills)
	While i < iAVCount
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(i)
		If AVInfo.IsSkill()
			JArray.AddInt(jSkills,i)
		EndIf
		i += 1
	EndWhile
EndFunction

String Function GetVoiceTypeName(VoiceType akVoiceType)
	String sRet
	sRet = akVoiceType as String
	sRet = StringUtil.SubString(sRet,0,StringUtil.Find(sRet,">") - 11)
	sRet = StringUtil.SubString(sRet,StringUtil.Find(sRet,"<") + 1)
	Return sRet
EndFunction

String Function GetCombatStyleName(CombatStyle akCombatStyle)
	String sRet
	sRet = akCombatStyle as String
	DebugTrace("CombatStyle " + akCombatStyle + " is named " + akCombatStyle.GetName())
	sRet = StringUtil.SubString(sRet,0,StringUtil.Find(sRet,">") - 11)
	sRet = StringUtil.SubString(sRet,StringUtil.Find(sRet,"<") + 1)
	Return sRet
EndFunction

Function SortVoiceTypes()

	Int jVoiceTypesAll 		= JArray.Object()
	Int jVoiceTypesFollower = JArray.Object()
	Int jVoiceTypesSpouse 	= JArray.Object()
	Int jVoiceTypesAdopt 	= JArray.Object()

	JArray.addFromFormList(jVoiceTypesAll,		vFFC_VoiceTypesAllList)
	JArray.addFromFormList(jVoiceTypesFollower,	vFFC_VoiceTypesFollowerList)
	JArray.addFromFormList(jVoiceTypesSpouse,	vFFC_VoiceTypesSpouseList)
	JArray.addFromFormList(jVoiceTypesAdopt,	vFFC_VoiceTypesAdoptList)

	;SetRegObj("VoiceTypes.All",		jVoiceTypesAll)
	;SetRegObj("VoiceTypes.Follower",jVoiceTypesFollower)
	;SetRegObj("VoiceTypes.Spouse",	jVoiceTypesSpouse)
	;SetRegObj("VoiceTypes.Adopt",	jVoiceTypesAdopt)

	Int jVoiceTypeData 	= JMap.Object() 

	Int i = JArray.Count(jVoiceTypesAll)
	While i > 0
		i -= 1
		VoiceType kVoiceType 	= JArray.GetForm(jVoiceTypesAll,i) as VoiceType
		String sVoiceName 		= ""

		sVoiceName = GetVoiceTypeName(kVoiceType)

		If sVoiceName
			SetRegForm("VoiceTypes.Info." + sVoiceName + ".Form",kVoiceType)
			
			If JArray.FindForm(jVoiceTypesFollower,	kVoiceType) > -1
				SetRegBool("VoiceTypes.Info." + sVoiceName + ".Follower",True)
			EndIf
			If JArray.FindForm(jVoiceTypesSpouse,kVoiceType) > -1
				SetRegBool("VoiceTypes.Info." + sVoiceName + ".Spouse",True)
			EndIf
			If JArray.FindForm(jVoiceTypesAdopt,kVoiceType) > -1
				SetRegBool("VoiceTypes.Info." + sVoiceName + ".Adopt",True)
			EndIf
		EndIf
	EndWhile

	SetRegObj("VoiceTypes.Names",JMap.AllKeys(GetRegObj("VoiceTypes.Info")))
EndFunction

Function SortCombatStyles()
	Int jCombatStyles 		= JArray.Object()

	JArray.addFromFormList(jCombatStyles,		vFFC_CombatStyles)

	Int jCombatStyleFMap 	= JFormMap.Object() 

	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(0),"Default")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(1),"Tank")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(2),"Balanced")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(3),"Prefer 1-handed")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(4),"Prefer 2-handed")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(5),"Berserker")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(6),"Prefer magic")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(7),"Prefer bow")
	JFormMap.SetStr(jCombatStyleFMap,vFFC_CombatStyles.GetAt(8),"Dual-wielding")

	SetRegObj("CombatStyles.FormMap",jCombatStyleFMap)
	
	Form kCombatStyle = JFormMap.nextKey(jCombatStyleFMap)
	While kCombatStyle 
		SetRegForm("CombatStyles.Map." + jFormMap.GetStr(jCombatStyleFMap,kCombatStyle),kCombatStyle)
		kCombatStyle = JFormMap.nextKey(jCombatStyleFMap,kCombatStyle)
	EndWhile

	SetRegObj("CombatStyles.Names",JFormMap.AllValues(jCombatStyleFMap))
EndFunction

;=== Functions - Busy state ===--

State Busy

	Function DoUpkeep(Bool bInBackground = True)
		DebugTrace("DoUpkeep called while busy!")
	EndFunction

	Int Function SavePlayerData()
		DebugTrace("SavePlayerData called while busy!")
		Return 1 ; Busy
	EndFunction

EndState
