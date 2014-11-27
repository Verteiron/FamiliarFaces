Scriptname vMYC_DataManager extends Quest
{Save and restore character and other data using the registry.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

String				Property META			= ".Info"				Auto Hidden

;=== Properties ===--

String 				Property SessionID 								Hidden
{Return SID for this game.}
	String Function Get()
		Return GetSessionStr("SessionID")
	EndFunction
EndProperty


Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden

vMYC_HangoutManager Property HangoutManager 						Auto

vMYC_PlayerTracker	Property PlayerTracker							Auto

Int 				Property SerializationVersion = 4 				Auto Hidden

Actor 				Property PlayerRef 								Auto
{The Player, duh}

ActorBase 			Property vMYC_InvisibleMActor					Auto
{Invisible actor for collecting custom weapons}

Formlist 			Property vMYC_DummyActorsMList 					Auto
{Formlist containing the male dummy actors}

Formlist 			Property vMYC_DummyActorsFList					Auto
{Formlist containing the female dummy actors}

Formlist 			Property vMYC_PerkList 							Auto
{A list of all perks as found by ActorValueInfo.}

Formlist 			Property vMYC_InventoryList						Auto
{A list of all Forms as found by ObjectReference.GetAllForms.}

Formlist			Property vMYC_zTempListsList					Auto
{A list of Formlists to be used as temporary storage for functions requiring them.}

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
		SetSessionID()
		CreateMiscStatNames()
		CreateAVNames()
		InitNINodeList()
		If !HasSessionKey("ActorbaseMap")
			SetSessionObj("ActorbaseMap",JFormMap.Object())
		EndIf
		DoUpkeep(False)
		SendModEvent("vMYC_DataManagerReady")
		RegisterForSingleUpdate(5.0)
	EndIf
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
	SendModEvent("vMYC_DataManagerReady")
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnTrackerReady(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("Tracker reports ready, save the player!")
	While IsBusy
		DebugTrace("Waiting to be not busy....")
		WaitMenuMode(1)
	EndWhile
	WaitMenuMode(10)
	;SavePlayerData()
	ActorBase kDoppelganger = GetAvailableActorBase(PlayerREF.GetActorBase().GetSex())
	Actor kDoppelActor = PlayerREF.PlaceAtMe(kDoppelganger) as Actor
	vMYC_Doppelganger kDoppelScript = kDoppelActor as vMYC_Doppelganger
	kDoppelScript.AssignCharacter(SessionID)
EndEvent

;=== Functions - Startup ===--

Function DoUpkeep(Bool bInBackground = True)
	{Run whenever the player loads up the Game.}
	RegisterForModEvent("vMYC_SetCustomHangout","OnSetCustomHangout")
	RegisterForModEvent("vMYC_TrackerReady","OnTrackerReady")
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	IsBusy = True
	DebugTrace("Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	InitReg()
	If !GetRegBool("Config.DefaultsSet")
		SetRegObj("Characters",JMap.Object(),True)
		SetRegObj("Hangouts",JMap.Object(),True)
		SetRegObj("Shrine",JMap.Object(),True)
		SetConfigDefaults()
	EndIf

	String sMatchedSID = MatchSession()
	If sMatchedSID
		SetSessionID(sMatchedSID)
	EndIf
	
	;Don't register this until after we've init'd everything else
	RegisterForModEvent("vMYC_BackgroundFunction","OnBackgroundFunction")
	RegisterForModEvent("vMYC_LoadSerializedEquipmentReq","OnLoadSerializedEquipmentReq")
	IsBusy = False
	DebugTrace("Finished upkeep!")
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Function SetConfigDefaults(Bool abForce = False)
	If !GetRegBool("Config.DefaultsSet") || abForce
		DebugTrace("Setting Config defaults!")
		SetRegBool("Config.Enabled",True,True,True)
		SetRegBool("Config.Compat.Enabled",True,True,True)
		SetRegBool("Config.Warnings.Enabled",True,True,True)
		SetRegBool("Config.Debug.Perf.Threads.Limit",False,True,True)
		SetRegInt ("Config.Debug.Perf.Threads.Max",4,True,True)
		SetRegBool("Config.DefaultsSet",True)
	EndIf
EndFunction


;=== Functions - Character data ===--

Function ScanPlayerStats()
{Writes current player stats to the session}
	If GetSessionBool("Status.Stats.Busy")
		Return
	EndIf
	SetSessionBool("Status.Stats.Busy",True)
	StartTimer("ScanPlayerStats")
	Int i = 0
	
	SetSessionFlt("Stats.Experience",GetPlayerExperience())
	SetSessionFlt("Stats.PerkPoints",GetPerkPoints())
	
	StartTimer("SaveAVs")
	
	Int iAddedCount = 0 
	Int iAdvSkills = 24 ; Start at Health
	While iAdvSkills < 44 ; Proceed through MagicResist
		String sAVName = GetAVName(iAdvSkills)
		Float fAV = 0.0
		fAV = PlayerREF.GetBaseActorValue(sAVName)
		If fAV
			SetSessionFlt("Stats.AV." + sAVName,fAV)
			DebugTrace("Saved AV " + sAVName + "!")
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
			fAV = PlayerREF.GetBaseActorValue(sAVName)
			iLL = GetSkillLegendaryLevel(sAVName)
		EndIf
		If iLL
			SetSessionInt("Stats.Legendary." + sAVName,iLL)
		EndIf
		If fAV
			SetSessionFlt("Stats.AV." + sAVName,fAV)
			DebugTrace("Saved AV " + sAVName + "!")
		EndIf
		iAdvSkills += 1
	EndWhile
	StopTimer("SaveSkills")
	StopTimer("ScanPlayerStats")
	SetSessionBool("Status.Stats.Busy",False)
EndFunction

Function ScanPlayerPerks()
{Writes current player perks to the session}
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
		vMYC_PerkList.Revert()
		Int iAVI = JArray.GetInt(jSkillList,iAdvSkills)
		String sAVName = GetAVName(iAVI)
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAVI)
		AVInfo.GetPerkTree(vMYC_PerkList, PlayerREF, false, true)
		Int iPerkCount = vMYC_PerkList.GetSize()
		If iPerkCount
			Int i = JArray.Count(jPerkList) ; Grab length of array before adding the Formlist
			JArray.AddFromFormList(jPerkList,vMYC_PerkList)
			SetSessionInt("PerkCounts." + sAVName,iPerkCount)
			While i < JArray.Count(jPerkList)  ; Each perk added
				Perk kPerk = JArray.GetForm(jPerkList,i) as Perk
				AddToReqList(kPerk,"Perk")
				If iAddedCount % 3 == 0
					SendModEvent("vMYC_PerkSaved")
				EndIf
				iAddedCount += 1
				i += 1
			EndWhile
			DebugTrace("Saved " + iPerkCount + " perks in the " + sAVName + " tree!")
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
	SendModEvent("vMYC_PerksSaveBegin")
	
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
	
	SendModEvent("vMYC_PerksSaveEnd",JArray.Count(GetSessionObj("Perks")))
	StopTimer("SavePlayerPerks")
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
	
	Int jPlayerSpells = JArray.Object()
	SetSessionObj("Spells",jPlayerSpells)
	
	Int iSpellCount = PlayerREF.GetSpellCount()
	iAddedCount = 0
	Bool bAddItem = False
	i = 0
	While i < iSpellCount
		bAddItem = False
		Spell kSpell = PlayerREF.GetNthSpell(i)
		If kSpell
			bAddItem = True
			Int iSpellID = kSpell.GetFormID()
			DebugTrace("Player knows the spell " + kSpell + ", " + kSpell.GetName())
			If bAddItem
				;vMYC_PlayerFormlist.AddForm(kSpell)
				JArray.AddForm(jPlayerSpells,kSpell)
				AddToReqList(kSpell,"Spell")
				iAddedCount += 1
				If iAddedCount % 2 == 0
					kSpell.SendModEvent("vMYC_SpellSaved")
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	DebugTrace("Scanned " + iAddedCount + " spells.")
	SendModEvent("vMYC_SpellsSaveEnd")
	StopTimer("ScanPlayerSpells")
	SetSessionBool("Status.Spells.Busy",False)
EndFunction

Function SavePlayerSpells()
	;== Spells ===--
	
	StartTimer("SavePlayerSpells")
	SendModEvent("vMYC_SpellsSaveBegin")

	While GetSessionBool("Status.Spells.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Spells")
		ScanPlayerSpells()
	EndIf
	
	SetRegObj(sRegKey + ".Spells",GetSessionObj("Spells"))
	
	SendModEvent("vMYC_SpellsSaveEnd")
	StopTimer("SavePlayerSpells")

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
			;Debug.Trace("MYC/CM: " + sPlayerName + " is wearing " + WornForm + ", " + WornForm.GetName() + " on slot " + h)
			If JArray.FindForm(jPlayerArmorList,WornForm) < 0
				JArray.AddForm(jPlayerArmorList,WornForm)
				Int iArmorIndex = JArray.FindForm(jPlayerArmorList,WornForm)
				If WornForm as Armor && iArmorIndex > -1
					;Debug.Trace("MYC/CM: Added " + WornForm.GetName())

					Int jPlayerArmorInfo = JMap.Object()

					JArray.AddObj(jPlayerArmorInfoList,jPlayerArmorInfo)
					AddToReqList(WornForm,"Equipment")
					SerializeEquipment(WornForm,jPlayerArmorInfo,1,h)

				EndIf
			EndIf
		EndIf
		h = Math.LeftShift(h,1)
	endWhile

	Int jEquipLeft = JMap.Object()
	JMap.SetObj(jPlayerEquipment,"Left",jEquipLeft)
	Int jEquipRight = JMap.Object()
	JMap.SetObj(jPlayerEquipment,"Right",jEquipRight)

	SerializeEquipment(PlayerREF.GetEquippedObject(0),jEquipLeft,0,0)
	SerializeEquipment(PlayerREF.GetEquippedObject(1),jEquipRight,1,0)
	
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
	SendModEvent("vMYC_EquipmentSaveBegin")

	While GetSessionBool("Status.Equipment.Busy")
		WaitMenuMode(1)
	EndWhile
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	
	If !HasSessionKey("Equipment")
		ScanPlayerEquipment()
	EndIf
	
	SetRegObj(sRegKey + ".Equipment",GetSessionObj("Equipment"))
	
	SendModEvent("vMYC_EquipmentSaveEnd")
	
	StopTimer("SavePlayerEquipment")

EndFunction

Function ScanPlayerInventory()
	If GetSessionBool("Status.Inventory.Busy")
		Return
	EndIf
	SetSessionBool("Status.Inventory.Busy",True)

	DebugTrace("Refreshing player inventory...")
	StartTimer("ScanPlayerInventory")
	
	vMYC_InventoryList.Revert()
	PlayerREF.GetAllForms(vMYC_InventoryList)
	Int jInventoryList = JArray.Object()
	SetSessionObj("PlayerInventoryList",jInventoryList)
	JArray.AddFromFormlist(jInventoryList,vMYC_InventoryList)

	Int jInventory = JMap.Object()
	SetSessionObj("Inventory",jInventory)
	Int i = JArray.Count(jInventoryList)
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jInventoryList,i)
		If kItem
			If !PlayerRef.IsEquipped(kItem)
				Int iType = kItem.GetType()
				Int iCount = PlayerRef.GetItemCount(kItem)
				If iCount > 0 
					Int jItemTypeFMap = JMap.getObj(jInventory,iType)
					If !JValue.IsFormMap(jItemTypeFMap)
						jItemTypeFMap = JFormMap.Object()
						JMap.setObj(jInventory,iType,jItemTypeFMap)
					EndIf
					JFormMap.SetInt(jItemTypeFMap,kItem,iCount)
				EndIf
			EndIf
			If IsObjectFavorited(kItem)
				Int jItemFavoriteFMap = JMap.getObj(jInventory,"Favorites")
				If !JValue.IsArray(jItemFavoriteFMap)
					jItemFavoriteFMap = JArray.Object()
					JMap.setObj(jInventory,"Favorites",jItemFavoriteFMap)
				EndIf
				If JArray.FindForm(jItemFavoriteFMap,kItem) < 0
					JArray.AddForm(jItemFavoriteFMap,kItem)
				EndIf
			EndIf
		EndIf
	EndWhile
	DebugTrace("Refreshed player inventory! Got " + JArray.Count(jInventoryList) + " items!")
	StopTimer("ScanPlayerInventory")
	SaveSession()
	SetSessionBool("Status.Inventory.Busy",False)
EndFunction

Function SavePlayerInventory()
	;== Inventory ===--
	StartTimer("SavePlayerInventory")
	SendModEvent("vMYC_InventorySaveBegin")
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	Int i = 0
	Int iAddedCount = 0

	;vMYC_InventoryList.Revert()
	;PlayerREF.GetAllForms(vMYC_InventoryList)
	;Int jInventoryList = JArray.Object()
	;SetSessionObj("PlayerInventoryList",jInventoryList)
	;JArray.AddFromFormlist(jInventoryList,vMYC_InventoryList)
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
	
	Int jWeaponsFMap 	= GetSessionObj("Inventory.41") ; kWeapon
	Int jArmorFMap 		= GetSessionObj("Inventory.26") ; kArmor
	Int jAmmoFMap 		= GetSessionObj("Inventory.42") ; kAmmo
	Int jFavoritesList 	= GetSessionObj("Inventory.Favorites") ; Favorites
	
	Int jWeaponList		= JFormMap.AllKeys(jWeaponsFMap)
	Int jArmorList 		= JFormMap.AllKeys(jArmorFMap)
	Int jAmmoList 		= JFormMap.AllKeys(jAmmoFMap)

	Int jWeaponArmorList = JArray.Object()
	JArray.AddFromArray(jWeaponArmorList,jWeaponList)
	JArray.AddFromArray(jWeaponArmorList,jArmorList)
	
	JValue.AddToPool(jWeaponList,"vMYC_InventoryPool")
	JValue.AddToPool(jArmorList,"vMYC_InventoryPool")
	JValue.AddToPool(jAmmoList,"vMYC_InventoryPool")
	JValue.AddToPool(jWeaponArmorList,"vMYC_InventoryPool")
	
	;== Create dummy actor for custom weapon scans ===--

	Actor kWeaponDummy = PlayerREF.PlaceAtMe(vMYC_InvisibleMActor,abInitiallyDisabled = True) as Actor
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
		If kItem
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
				Int jCustomWeapon = JMap.Object()

				JMap.setForm(jCustomWeapon,"Form",kItem)
				;JMap.setInt(jCustomWeapon,"Count",iCount)

				SerializeEquipment(kItem,jCustomWeapon,iHand,iSlotMask,kWeaponDummy)
				Int jPlayerCustomItems = GetRegObj(sRegKey + ".InventoryCustomItems")
				If !jPlayerCustomItems
					jPlayerCustomItems = JArray.Object()
				EndIf
				JArray.AddObj(jPlayerCustomItems,jCustomWeapon)
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
	SendModEvent("vMYC_InventorySaveEnd")
	StopTimer("SavePlayerInventory")
	JValue.CleanPool("vMYC_InventoryPool")
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
	SendModEvent("vMYC_NINodeInfoSaveBegin")

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
	
	SendModEvent("vMYC_NINodeInfoSaveEnd")
EndFunction

Int Function SavePlayerMiscStats()
	StartTimer("SavePlayerMiscStats")
	SendModEvent("vMYC_MiscStatSaveBegin")
	
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
	SendModEvent("vMYC_MiscStatSaveEnd")
	StopTimer("SavePlayerMiscStats")
	Return 0
EndFunction	
	
Int Function SavePlayerData()
	GotoState("Busy")
	DebugTrace("Saving player data...")
	StartTimer("SavePlayerData")
	SetSessionID()
	String sSessionID = GetSessionStr("SessionID")
	
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
	AddToReqList(kPlayerBase.GetRace(),"Race")
	SetRegStr(sRegKey + META + ".RaceText",kPlayerBase.GetRace().GetName())
	SetRegInt(sRegKey + META + ".SerializationVersion",SerializationVersion)
	
	SetRegObj(sRegKey + "._MYC",GetRegObj(sRegKey + META))
	
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
	_bSavedNINodeInfo	= False

	Int iSafety = 10
	While PlayerTracker.Busy && iSafety > 0
		iSafety -= 1
		WaitMenuMode(1.0)
	EndWhile

	RegisterForModEvent("vMYC_BackgroundFunction","OnBackgroundFunction")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerMiscStats")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerNINodeInfo")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerPerks")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerInventory")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerSpells")
	SendModEvent("vMYC_BackgroundFunction","SavePlayerEquipment")
	
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
	
	;== Save NIOverride overlays ===--
	StartTimer("NIOverrideData")
	If SKSE.GetPluginVersion("NiOverride") >= 1 ; Check for NIO
		Int jNIOData = JMap.Object()
		SetRegObj(sRegKey + ".NIOverrideData.BodyOverlays",NIO_GetOverlayData("Body [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.HandOverlays",NIO_GetOverlayData("Hand [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.FeetOverlays",NIO_GetOverlayData("Feet [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.FaceOverlays",NIO_GetOverlayData("Face [Ovl",NIOverride.GetNumBodyOverlays()))
	EndIf
	StopTimer("NIOverrideData")
		
	While (!_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells || !_bSavedNINodeInfo) 
		WaitMenuMode(0.5)
	EndWhile

	JValue.WriteToFile(GetRegObj(sRegKey),"Data/vMYC/" + sPlayerName + ".char.json")
	StopTimer("SavePlayerData")
	GotoState("")
	Debug.MessageBox("Finished saving player!")
	Return 0 
EndFunction

Event OnBackgroundFunction(string eventName, string strArg, float numArg, Form sender)
	Int iMaxThreads = GetRegInt("Config.Debug.Perf.Threads.Max")
	If _iThreadCount >= iMaxThreads
		DebugTrace("Deferring " + strArg + ", thread " + _iThreadCount + "/" + iMaxThreads)
		WaitMenuMode(1)
		SendModEvent("vMYC_BackgroundFunction",strArg)
		Return
	EndIf
	_iThreadCount += 1
	If GetSessionBool("Status.Background." + strArg)
		DebugTrace(strArg + " is already running! Ignoring duplicate request.")
		Return
	EndIf
	SetSessionBool("Status.Background." + strArg,True)
	
	DebugTrace("Backgrounding " + strArg + ", thread " + _iThreadCount + "/" + iMaxThreads)
	If strArg == "SavePlayerEquipment"
		SavePlayerEquipment()
		_bSavedEquipment = True
	ElseIf strArg == "SavePlayerPerks"
		SavePlayerPerks()
		_bSavedPerks = True
	ElseIf strArg == "SavePlayerSpells"
		SavePlayerSpells()
		_bSavedSpells = True
	ElseIf strArg == "SavePlayerInventory"
		SavePlayerInventory()
		_bSavedInventory = True
	ElseIf strArg == "SavePlayerNINodeInfo"
		SavePlayerNINodeInfo()
		_bSavedNINodeInfo = True
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
	EndIf
	SetSessionBool("Status.Background." + strArg,False)
	_iThreadCount -= 1
EndEvent


;=== Functions - Actorbase/Actor management ===--

ActorBase Function GetAvailableActorBase(Int iSex, ActorBase kPreferredAB = None)
{Returns the first available dummy actorbase of the right sex, optionally fetch the preferred one}
	ActorBase kDoppelgangerBase = None
	Int jActorbaseMap = GetSessionObj("ActorbaseMap")
	
	If kPreferredAB
		If !JFormMap.GetStr(jActorbaseMap,kPreferredAB) ; If this AB is not already assigned in this session...
			JFormMap.SetStr(jActorBaseMap,kPreferredAB,"Reserved")
			SaveSession()
			Return kPreferredAB
		EndIf
	EndIf
	
	;== If we got this far then the preferred base is either not set or is in use ===--

	
	;== Init ActorBasePool forms in case they're not there already ===-- FIXME: Move this to init!
	If !HasRegKey("ActorbasePool.F")
		Int jABPool = JArray.Object()
		JArray.AddFromFormlist(jABPool,vMYC_DummyActorsFList)
		SetRegObj("ActorbasePool.F",jABPool)
	EndIf
	If !HasRegKey("ActorbasePool.M")
		Int jABPool = JArray.Object()
		JArray.AddFromFormlist(jABPool,vMYC_DummyActorsMList)
		SetRegObj("ActorbasePool.M",jABPool)
	EndIf

	Int jActorbasePool = 0
	
	If iSex ; 0 = m, 1 = f
		jActorbasePool = GetRegObj("ActorbasePool.F")
	Else
		jActorbasePool = GetRegObj("ActorbasePool.M")
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

	DebugTrace("Couldn't find an available ActorBase!",1)
	;== Either no more are available, or something else went wrong ===--
	Return None
EndFunction



;=== Functions - Requirement list ===--

String Function GetSourceMod(Form akForm)
	Return GetModName(akForm.GetFormID() / 0x1000000)
EndFunction

Function AddToReqList(Form akForm, String asType, String sSID = "")
{Take the form and add its provider/source to the required mods list of the specified ajCharacterData.}
	;Return
	
	If !sSID
		sSID = SessionID
	EndIf
	If !sSID || !akForm || !asType 
		Return
	EndIf

	Int jReqList = GetRegObj("Characters." + sSID + META + ".ReqList")
	If !jReqList
		jReqList = JMap.Object()
	EndIf
	String sModName = GetSourceMod(akForm)
	If sModName
		If sModName == "Skyrim.esm" || sModName == "Update.esm"
			Return
		EndIf
		
		sModName = StringReplace(sModName,".","_dot_") ; Strip . to avoid confusing JContainers
		String sFormName = akForm.GetName()
		If !sFormName
			sFormName = akForm as String
		EndIf
		SetRegStr("Characters." + sSID + META + ".ReqList." + sModName + "." + asType + ".0x" + GetFormIDString(akForm),sFormName)
	EndIf
EndFunction

;=== Functions - NIOverride ===--

Function InitNINodeList()
	Int jNINodeList = GetRegObj("NINodeList")
	If !jNINodeList
		jNINodeList = JValue.ReadFromFile("Data/vMYC/vMYC_NodeList.json")
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
				DebugTrace("NINodeList - Erased entry " + sNodeName + "!")
				iNodeCount -= 1
			Else
				DebugTrace("NINodeList - Retained entry " + sNodeName + "!")
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
		jNINodeList = JValue.ReadFromFile("Data/vMYC/vMYC_NodeList.json")
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

Function SerializeEquipment(Form kItem, Int jEquipmentInfo, Int iHand = 1, Int h = 0, Actor kWornObjectActor = None)
{Fills the JMap jEquipmentInfo with all info from Form kItem}
	GotoState("SerializeBusy")
	JMap.SetForm(jEquipmentInfo,"Form",kItem)

	If !kWornObjectActor
		kWornObjectActor = PlayerREF
	EndIf

	Bool isWeapon = False
	Bool isEnchantable = False
	Bool isTwoHanded = False
	Enchantment kItemEnchantment
	If kItem
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " is Mod ID " + (kItem.GetFormID() / 0x1000000))
		JMap.SetStr(jEquipmentInfo,"Source",GetModName(kItem.GetFormID() / 0x1000000))
	EndIf
	;Debug.Trace("MYC/CM: Serializing " + kItem.GetName() + "...")
	If (kItem as Weapon)
		isWeapon = True
		isEnchantable = True
		Int iWeaponType = (kItem as Weapon).GetWeaponType()
		If iWeaponType > 4 && iWeaponType != 8
			IsTwoHanded = True
		EndIf
		kItemEnchantment = (kItem as Weapon).GetEnchantment()
	ElseIf (kItem as Armor)
		isEnchantable = True
		kItemEnchantment = (kItem as Armor).GetEnchantment()
	EndIf

	Int jEquipmentEnchantmentInfo = JMap.Object()
	If isEnchantable ; don't create enchantment block unless object can be enchanted
		JMap.SetObj(jEquipmentInfo,"Enchantment",jEquipmentEnchantmentInfo)
	EndIf

	If kItemEnchantment
		;PlayerEnchantments[newindex] = kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
		JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
		JMap.SetStr(jEquipmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
		AddToReqList(kItemEnchantment,"Enchantment")
		JMap.SetStr(jEquipmentEnchantmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
		JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",0)
	EndIf
	String sItemDisplayName = WornObject.GetDisplayName(kWornObjectActor,iHand,h)
	sItemDisplayName = StringUtil.SubString(sItemDisplayName,0,StringUtil.Find(sItemDisplayName,"(") - 1) ; Strip " (Legendary)"
	kItemEnchantment = WornObject.GetEnchantment(kWornObjectActor,iHand,h)
	If sItemDisplayName || kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem + " is enchanted/forged item " + sItemDisplayName)
		JMap.SetInt(jEquipmentInfo,"IsCustom",1)
		JMap.SetFlt(jEquipmentInfo,"ItemHealthPercent",WornObject.GetItemHealthPercent(kWornObjectActor,iHand,h))
		JMap.SetFlt(jEquipmentInfo,"ItemCharge",WornObject.GetItemCharge(kWornObjectActor,iHand,h))
		JMap.SetFlt(jEquipmentInfo,"ItemMaxCharge",WornObject.GetItemMaxCharge(kWornObjectActor,iHand,h))
		JMap.SetStr(jEquipmentInfo,"DisplayName",sItemDisplayName)
		kItemEnchantment = WornObject.GetEnchantment(kWornObjectActor,iHand,h)
		If kItemEnchantment
			JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
			JMap.SetStr(jEquipmentEnchantmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
			AddToReqList(kItemEnchantment,"Enchantment")
			JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",1)
			Int iNumEffects = kItemEnchantment.GetNumEffects()
			JMap.SetInt(jEquipmentEnchantmentInfo,"NumEffects",iNumEffects)
			Int jEffectsArray = JArray.Object()
			Int j = 0
			While j < iNumEffects
				Int jEffectsInfo = JMap.Object()
				JMap.SetFlt(jEffectsInfo, "Magnitude", kItemEnchantment.GetNthEffectMagnitude(j))
				JMap.SetFlt(jEffectsInfo, "Area", kItemEnchantment.GetNthEffectArea(j))
				JMap.SetFlt(jEffectsInfo, "Duration", kItemEnchantment.GetNthEffectDuration(j))
				JMap.SetForm(jEffectsInfo,"MagicEffect", kItemEnchantment.GetNthEffectMagicEffect(j))
				JMap.SetStr(jEffectsInfo,"Source",GetModName(kItemEnchantment.GetNthEffectMagicEffect(j).GetFormID() / 0x1000000))
				AddToReqList(kItemEnchantment.GetNthEffectMagicEffect(j),"MagicEffect")
				JArray.AddObj(jEffectsArray,jEffectsInfo)
				j += 1
			EndWhile
			JMap.SetObj(jEquipmentEnchantmentInfo,"Effects",jEffectsArray)
		EndIf
	Else
		JMap.SetInt(jEquipmentInfo,"IsCustom",0)
	EndIf
	
	;Save dye color, if applicable
	If GetRegBool("Config.NIO.ArmorDye.Enabled") && kItem as Armor 
		Bool bHasDye = False
		Int iHandle = NiOverride.GetItemUniqueID(kWornObjectActor, 0, (kItem as Armor).GetSlotMask(), False)
		Int[] iNIODyeColors = New Int[15]
		Int iMaskIndex = 0
		While iMaskIndex < iNIODyeColors.Length
			Int iColor = NiOverride.GetItemDyeColor(iHandle, iMaskIndex)
			If Math.RightShift(iColor,24) > 0
				bHasDye = True
				iNIODyeColors[iMaskIndex] = iColor
			EndIf
			iMaskIndex += 1
		EndWhile
		If bHasDye
			JMap.SetObj(jEquipmentInfo,"NIODyeColors",JArray.objectWithInts(iNIODyeColors))
		EndIf
	EndIf

	If !(iHand == 0 && IsTwoHanded) && kItem ; exclude left-hand iteration of two-handed weapons
		If kWornObjectActor == PlayerREF
			kItem.SendModEvent("vMYC_EquipmentSaved","",iHand)
		Else ;Was not saved from player, indicate this with iHand = -1
			kItem.SendModEvent("vMYC_EquipmentSaved","",-1)
		EndIf
	EndIf
	;Debug.Trace("MYC/CM: Finished serializing " + kItem.GetName() + ", JMap count is " + JMap.Count(jEquipmentInfo))
	GotoState("")
EndFunction

Event OnLoadSerializedEquipmentReq(Int jItem)
	Int iMaxThreads = GetRegInt("Config.Debug.Perf.Threads.Max")
	If _iThreadCount >= iMaxThreads
		DebugTrace("Deferring LoadSerializedEquipmentReq, thread " + _iThreadCount + "/" + iMaxThreads)
		WaitMenuMode(RandomFloat(0.8,1.2))
		Int iEventHandle = ModEvent.Create("vMYC_LoadSerializedEquipmentObj")
		If iEventHandle
			ModEvent.PushForm(iEventHandle,LoadSerializedEquipment(jItem))
			ModEvent.Send(iEventHandle)
		EndIf
		Return
	EndIf
	_iThreadCount += 1
	Int iEventHandle = ModEvent.Create("vMYC_LoadSerializedEquipmentObject")
	If iEventHandle
		ModEvent.PushForm(iEventHandle,LoadSerializedEquipment(jItem))
		ModEvent.Send(iEventHandle)
	EndIf
	_iThreadCount -= 1
EndEvent

ObjectReference Function LoadSerializedEquipment(Int jItem)
{Recreate a custom weapon or armor using jItem. }
	Form kItem = JMap.getForm(jItem,"Form")
	If !(kItem as Weapon) && !(kItem as Armor)
		DebugTrace("Passed item is neither weapon nor armor!",1)
		Return None
	EndIf
	ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	ObjectReference kObject = kNowhere.PlaceAtMe(kItem)
	If !kObject
		DebugTrace("Couldn't create ObjectReference for " + kItem + "!",1)
		Return None
	EndIf
	If JMap.getInt(jItem,"IsCustom")
		String sDisplayName = JMap.getStr(jItem,"DisplayName")
		DebugTrace(kItem.GetName() + " is customized item " + sDisplayName + "!")
		kObject.SetItemHealthPercent(JMap.getFlt(jItem,"ItemHealthPercent"))
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  WornObject.SetItemMaxCharge(kCharacterActor," + iHand + ",0," + JMap.getFlt(jItem,"ItemMaxCharge"))
		kObject.SetItemMaxCharge(JMap.getFlt(jItem,"ItemMaxCharge"))
		If sDisplayName ; Will be blank if player hasn't renamed the item
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  WornObject.SetDisplayName(kCharacterActor," + iHand + ",0," + sDisplayName)
			kObject.SetDisplayName(sDisplayName)
		EndIf

		Float[] fMagnitudes = New Float[8]
		Int[] iDurations = New Int[8]
		Int[] iAreas = New Int[8]
		MagicEffect[] kMagicEffects = New MagicEffect[8]
		;Wait(1)
		If JValue.solveInt(jItem,".Enchantment.IsCustom")
			Int iNumEffects = JValue.solveInt(jItem,".Enchantment.NumEffects")
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " has a customized enchantment with " + inumEffects + " magiceffects!")
			Int j = 0
			Int jWeaponEnchEffects = JValue.SolveObj(jItem,".Enchantment.Effects")
			While j < iNumEffects
				Int jWeaponEnchEffect = JArray.getObj(jWeaponEnchEffects,j)
				fMagnitudes[j] = JMap.GetFlt(jWeaponEnchEffect,"Magnitude")
				iDurations[j] = JMap.GetFlt(jWeaponEnchEffect,"Duration") as Int
				iAreas[j] = JMap.GetFlt(jWeaponEnchEffect,"Area") as Int
				kMagicEffects[j] = JMap.GetForm(jWeaponEnchEffect,"MagicEffect") as MagicEffect
				j += 1
			EndWhile
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " creating custom enchantment...")
			kObject.CreateEnchantment(JMap.getFlt(jItem,"ItemMaxCharge"), kMagicEffects, fMagnitudes, iAreas, iDurations)
			kObject.SetItemCharge(JMap.getFlt(jItem,"ItemCharge"))
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " done!")
		EndIf
	Else
		kObject.SetItemCharge(JMap.getFlt(jItem,"ItemCharge"))
	EndIf
	Return kObject
EndFunction

Formlist Function LockFormlist()
	Int jTempFormlistPool = GetSessionObj("TempFormlistPool")
	If !JValue.IsArray(jTempFormlistPool)
		jTempFormlistPool = JArray.Object()
		JArray.AddFromFormList(jTempFormlistPool,vMYC_zTempListsList)
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

String Function MatchSession()
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + PlayerREF.GetActorBase().GetName()))
	DebugTrace("Looking for matching session in " + JArray.Count(jSIDList) + " saved sessions!")
	If jSIDList
		Int iSID = JArray.Count(jSIDList)
		While iSID > 0
			iSID -= 1
			String sSID = JArray.GetStr(jSIDList,iSID)
			DebugTrace("Checking current session against " + sSID + "...")
			If Math.ABS(GetRegFlt("Characters." + sSID + META + ".PlayTime") - GetRealHoursPassed()) < 0.1
				DebugTrace("Current session matches " + sSID + "!")
				Return sSID
			EndIf
		EndWhile
	EndIf
	Return ""
EndFunction

Function SetSessionID(String sSessionID = "")
	If !sSessionID && !GetSessionStr("SessionID")
		SetSessionStr("SessionID",GetUUIDTrue())
		DebugTrace("Set SessionID: " + GetSessionStr("SessionID"))
	ElseIf !sSessionID && GetSessionStr("SessionID")
		DebugTrace("SessionID already set!")
	ElseIf sSessionID
		SetSessionStr("SessionID",sSessionID)
		DebugTrace("Forced SessionID: " + sSessionID)
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/DataManager: " + sDebugString,iSeverity)
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
	DebugTrace("Timer: Starting for " + sTimerLabel)
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
