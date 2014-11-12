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

Int 				Property SerializationVersion = 3 				Auto Hidden

Actor 				Property PlayerRef 								Auto
{The Player, duh}

ActorBase 			Property vMYC_InvisibleMActor					Auto
{Invisible actor for collecting custom weapons}

Formlist 			Property vMYC_PerkList 							Auto
{A list of all perks as found by ActorValueInfo.}

Formlist 			Property vMYC_InventoryList						Auto
{A list of all Forms as found by ObjectReference.GetAllForms.}

;=== Variables ===--

Bool _bSavedPerks 		= False
Bool _bSavedSpells 		= False
Bool _bSavedEquipment 	= False
Bool _bSavedInventory 	= False

;=== Events ===--

Event OnInit()
	If IsRunning()
		SetSessionID()
		DoUpkeep()
	EndIf
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
	Debug.MessageBox("Done!")
EndEvent

;=== Functions - Startup ===--

Function DoUpkeep(Bool bInBackground = True)
	{Run whenever the player loads up the Game.}
	RegisterForModEvent("vMYC_SetCustomHangout","OnSetCustomHangout")
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
	DebugTrace("Finished upkeep!")
	SendModEvent("vMYC_UpkeepEnd")
	SavePlayerData()
EndFunction

Function SetConfigDefaults(Bool abForce = False)
	If !GetRegBool("Config.DefaultsSet") || abForce
		DebugTrace("Setting Config defaults!")
		SetRegBool("Config.Enabled",True,True,True)
		SetRegBool("Config.Compat.Enabled",True,True,True)
		SetRegBool("Config.Warnings.Enabled",True,True,True)
		SetRegBool("Config.Debug.Perf.Threads.Limit",False,True,True)
		SetRegInt ("Config.Debug.Perf.Threads.Max",50,True,True)
		SetRegBool("Config.DefaultsSet",True)
	EndIf
EndFunction


;=== Functions - Character data ===--

Function SavePlayerPerks()
	;== Actor values and Perks ===--
	StartTimer("SavePerks")
	SendModEvent("vMYC_PerksSaveBegin")
	
	String sRegKey = "Characters." + SessionID
	Int i = 0

	vMYC_PerkList.Revert()
	CreateAVNames()
	Int iAdvSkills = 0
	While iAdvSkills < 162
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAdvSkills)
		String sAVName = GetAVName(iAdvSkills)
		Float fAV = 0.0
		; Game claims 155-159 don't exist, but they still have Perks attached to them. Maybe the names are wrong.
		If iAdvSkills < 155 || iAdvSkills > 159 
			fAV = PlayerREF.GetBaseActorValue(sAVName)
		EndIf
		If fAV
			SetRegFlt(sRegKey + ".Stats.AV." + sAVName,fAV)
			DebugTrace("Saved AV " + sAVName + "!")
		EndIf
		If AVInfo.IsSkill() 
			StartTimer("SavePerks-" + sAVName)
			Int iLastCount = vMYC_PerkList.GetSize()
			AVInfo.GetPerkTree(vMYC_PerkList, PlayerREF, false, true)
			Int iThisCount = vMYC_PerkList.GetSize()
			If iThisCount - iLastCount > 0
				SetRegInt(sRegKey + ".PerkCounts." + sAVName,iThisCount - iLastCount)
				DebugTrace("Saved " + (iThisCount - iLastCount) + " perks in the " + sAVName + " tree!")
			EndIf
			StopTimer("SavePerks-" + sAVName)
		EndIf
		iAdvSkills += 1
		;Skip unused AVs
		If iAdvSkills == 45 
			iAdvSkills = 96 
		EndIf
		If iAdvSkills == 114
			iAdvSkills = 132
		EndIf
	EndWhile
	SendModEvent("vMYC_PerksSaveEnd",iAddedCount)
	DebugTrace("Saved " + iAddedCount + " perks!")
	StopTimer("SavePerks")
	
	StartTimer("SavePerkCompat")
	Int jPerkList = JArray.Object()
	JArray.AddFromFormList(jPerkList,vMYC_PerkList)
	SetRegObj(sRegKey + ".Perks",jPerkList)
	Int iAddedCount = 0
	
	i = JArray.Count(jPerkList)
	While i > 0
		i -= 1
		Perk kPerk = JArray.GetForm(jPerkList,i) as Perk
		AddToReqList(kPerk,"Perk")
		If iAddedCount % 3 == 0
			SendModEvent("vMYC_PerkSaved")
		EndIf
		iAddedCount += 1
	EndWhile
	StopTimer("SavePerkCompat")
EndFunction

Function SavePlayerSpells()
	;== Spells ===--
	
	StartTimer("SaveSpells")
	SendModEvent("vMYC_SpellsSaveBegin")

	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	Int i = 0
	Int iAddedCount = 0
	
	Int jPlayerSpells = JArray.Object()
	SetRegObj(sRegKey + ".Spells",jPlayerSpells)
	
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
			;Debug.Trace("MYC/CM: " + sPlayerName + " knows the spell " + kSpell + ", " + kSpell.GetName())
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
	DebugTrace("Saved " + iAddedCount + " spells for " + sPlayerName + ".")
	SendModEvent("vMYC_SpellsSaveEnd")
	StopTimer("SaveSpells")

EndFunction

Function SavePlayerEquipment()
	;== Equipment ===--
	
	StartTimer("SaveEquipment")
	SendModEvent("vMYC_EquipmentSaveBegin")

	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	Int i = 0
	Int iAddedCount = 0
	
	Int jPlayerEquipment = JMap.Object()
	SetRegObj(sRegKey + ".Equipment",jPlayerEquipment)

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

	SendModEvent("vMYC_EquipmentSaveEnd")
	
	StopTimer("SaveEquipment")

EndFunction

Function SavePlayerInventory()
	;== Inventory ===--
	StartTimer("SaveInventory")
	SendModEvent("vMYC_InventorySaveBegin")
	
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	String sRegKey = "Characters." + SessionID
	Int i = 0
	Int iAddedCount = 0
	
	vMYC_InventoryList.Revert()
	PlayerREF.GetAllForms(vMYC_InventoryList)
	Int jInventoryList = JArray.Object()
	SetSessionObj("PlayerInventoryList",jInventoryList)
	JArray.AddFromFormlist(jInventoryList,vMYC_InventoryList)
	Int jInventory = JFormMap.Object()
	SetRegObj(sRegKey + ".Inventory",jInventory)
	i = JArray.Count(jInventoryList)
	
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
	While i > 0
		i -= 1
		Form kItem = JArray.GetForm(jInventoryList,i)
		If kItem
			If IsObjectFavorited(kItem)
				Int iCount = PlayerREF.GetItemCount(kItem)
				If PlayerREF.IsEquipped(kItem)
					iCount -= 1
				EndIf
				If iCount
					Int iItemID = kItem.GetFormID()
					Int iType = kItem.GetType()

					;===== Save custom weapons =====----
					If iType == 41 ;kWeapon
						bAddItem = False
						PlayerREF.RemoveItem(kItem,1,True,kWeaponDummy)
						kWeaponDummy.EquipItemEX(kItem,1,preventUnequip = True,equipSound = False)
						If ((WornObject.GetDisplayName(kWeaponDummy,1,0) || WornObject.GetItemHealthPercent(kWeaponDummy,1,0) > 1.0)) 
							DebugTrace(kItem + " is a weapon named " + WornObject.GetDisplayName(kWeaponDummy,1,0))
							Int jCustomWeapon = JMap.Object()

							JMap.setForm(jCustomWeapon,"Form",kItem)
							JMap.setInt(jCustomWeapon,"Count",iCount)

							SerializeEquipment(kItem,jCustomWeapon,1,0,kWeaponDummy)
							Int jPlayerCustomItems = GetRegObj(sRegKey + ".InventoryCustomItems")
							If !jPlayerCustomItems
								jPlayerCustomItems = JArray.Object()
							EndIf
							JArray.AddObj(jPlayerCustomItems,jCustomWeapon)
							SetRegObj(sRegKey + ".InventoryCustomItems",jPlayerCustomItems)
						EndIf
						kWeaponDummy.RemoveItem(kItem,1,True,PlayerREF)
						;JArray.AddForm(jWeaponsToCheck,kItem)
					EndIf
					If iItemID > 0x05000000 || iItemID < 0 && !(iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF)
						; Item is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn and is not a custom item
						;Debug.Trace("MYC/CM: " + kItem + " is a mod-added item!")
						;bAddItem = False
					ElseIf (iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF)
						; This is a custom-made item
						DebugTrace(kItem + " is a customized/forged/mixed item!")
						bAddItem = False
					EndIf
					If kItem as ObjectReference
						DebugTrace(kItem + " is an ObjectReference named " + (kItem as ObjectReference).GetDisplayName())
					EndIf
					JFormMap.SetInt(jInventory,kItem,iCount)
				EndIf
			EndIf
		EndIf
	EndWhile
	SetRegObj(sRegKey + ".Inventory",jInventory)
	SendModEvent("vMYC_InventorySaveEnd")
	StopTimer("SaveInventory")
EndFunction

Int Function SavePlayerData()
	GotoState("Busy")
	DebugTrace("Saving player data...")
	StartTimer("SavePlayer")
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
	SetRegInt(sRegKey + META + ".Sex",kPlayerBase.GetSex())
	SetRegForm(sRegKey + META + ".Race",kPlayerBase.GetRace())
	AddToReqList(kPlayerBase.GetRace(),"Race")
	SetRegStr(sRegKey + META + ".RaceText",kPlayerBase.GetRace().GetName())

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
	
	RegisterForModEvent("vMYC_SavePlayerEquipment","OnSavePlayerEquipment")
	SendModEvent("vMYC_SavePlayerEquipment")

	RegisterForModEvent("vMYC_SavePlayerPerks","OnSavePlayerPerks")
	SendModEvent("vMYC_SavePlayerPerks")

	RegisterForModEvent("vMYC_SavePlayerSpells","OnSavePlayerSpells")
	SendModEvent("vMYC_SavePlayerSpells")

	RegisterForModEvent("vMYC_SavePlayerInventory","OnSavePlayerInventory")
	SendModEvent("vMYC_SavePlayerInventory")

	;== Save NIOverride overlays ===--

	If SKSE.GetPluginVersion("NiOverride") >= 1 ; Check for NIO
		Int jNIOData = JMap.Object()
		SetRegObj(sRegKey + ".NIOverrideData.BodyOverlays",NIO_GetOverlayData("Body [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.HandOverlays",NIO_GetOverlayData("Hand [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.FeetOverlays",NIO_GetOverlayData("Feet [Ovl",NIOverride.GetNumBodyOverlays()))
		SetRegObj(sRegKey + ".NIOverrideData.FaceOverlays",NIO_GetOverlayData("Face [Ovl",NIOverride.GetNumBodyOverlays()))
	EndIf

	;== Save node info from RaceMenuPlugins ===--
	
	SetRegObj(sRegKey + ".NINodeData",GetNINodeInfo(PlayerREF))

	
	While (!_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells) 
		WaitMenuMode(0.5)
	EndWhile
	
	StopTimer("SavePlayer")
	GotoState("")
	Return 0 
EndFunction

Event OnSavePlayerEquipment(string eventName, string strArg, float numArg, Form sender)
	SavePlayerEquipment()
	_bSavedEquipment = True
EndEvent

Event OnSavePlayerPerks(string eventName, string strArg, float numArg, Form sender)
	SavePlayerPerks()
	_bSavedPerks = True
EndEvent

Event OnSavePlayerSpells(string eventName, string strArg, float numArg, Form sender)
	SavePlayerSpells()
	_bSavedSpells = True
EndEvent

Event OnSavePlayerInventory(string eventName, string strArg, float numArg, Form sender)
	SavePlayerInventory()
	_bSavedInventory = True
EndEvent

;=== Functions - Requirement list ===--

String Function GetSourceMod(Form akForm)
	Return GetModName(akForm.GetFormID() / 0x1000000)
EndFunction

Function AddToReqList(Form akForm, String asType, String sSID = "")
{Take the form and add its provider/source to the required mods list of the specified ajCharacterData.}
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
		;If sModName == "Skyrim.esm" || sModName == "Update.esm"
		;	Return
		;EndIf
		
		sModName = StringReplace(sModName,".","_dot_")
		String sFormName = akForm.GetName()
		If !sFormName
			sFormName = akForm as String
		EndIf
		SetRegStr("Characters." + sSID + META + ".ReqList." + sModName + "." + asType + ".0x" + GetFormIDString(akForm),sFormName)
	EndIf
EndFunction

;=== Functions - NIOverride ===--

Int Function GetNINodeInfo(Actor akActor)
	Int jNINodeList = JValue.ReadFromFile("Data/vMYC/vMYC_NodeList.json")
	JValue.Retain(jNINodeList,"vMYC_DM")
	DebugTrace("NINodeList contains " + JArray.Count(jNINodeList) + " entries!")
		
	Int jNINodes = JMap.Object()
	JValue.Retain(jNINodes,"vMYC_DM")
	Int i = 0
	Int iNodeCount = JArray.Count(jNINodeList)
	While i < iNodeCount
		String sNodeName = JArray.getStr(jNINodeList,i)
		If sNodeName
			If NetImmerse.HasNode(akActor,sNodeName,false)
				Float fNodeScale = NetImmerse.GetNodeScale(akActor,sNodeName,false)
				If fNodeScale != 1.0
					Debug.Trace("Saving NINode " + sNodeName + " at scale " + fNodeScale + "!")
					Int jNINodeData = JMap.Object()
					JMap.SetFlt(jNINodeData,"Scale",fNodeScale)
					JMap.SetObj(jNINodes,sNodeName,jNINodeData)
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	JValue.Release(jNINodeList)
	JValue.Release(jNINodes)
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
		If !(iRGB + iGlow + fAlpha + fMultiple == 0 && StringUtil.Find(sTexture,"Default.dds") > -1) || (iRGB && iRGB != -1 && iRGB != 16777215) || iGlow || (fAlpha && fAlpha != 1.0) || (fMultiple && fMultiple != 1.0) || (sTexture && sTexture != "Textures\\Actors\\Character\\Overlays\\Default.dds")
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
	If GetRegBool("Config.Extras.NIO.ArmorDye.Enabled") && kItem as Armor 
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
	Int jAVNames = GetSessionObj("AVNames")
	If !jAVNames
		CreateAVNames()
		jAVNames = GetSessionObj("AVNames")
	EndIf
	Return JArray.GetStr(jAVNames,iAVIndex)
EndFunction

Function CreateAVNames()
	Int jAVNames = JArray.Object()
	JArray.AddStr(jAVNames,"Aggression")
	JArray.AddStr(jAVNames,"Confidence")
	JArray.AddStr(jAVNames,"Energy")
	JArray.AddStr(jAVNames,"Morality")
	JArray.AddStr(jAVNames,"Mood")
	JArray.AddStr(jAVNames,"Assistance")
	JArray.AddStr(jAVNames,"OneHanded")
	JArray.AddStr(jAVNames,"TwoHanded")
	JArray.AddStr(jAVNames,"Marksman")
	JArray.AddStr(jAVNames,"Block")
	JArray.AddStr(jAVNames,"Smithing")
	JArray.AddStr(jAVNames,"HeavyArmor")
	JArray.AddStr(jAVNames,"LightArmor")
	JArray.AddStr(jAVNames,"Pickpocket")
	JArray.AddStr(jAVNames,"LockPicking")
	JArray.AddStr(jAVNames,"Sneak")
	JArray.AddStr(jAVNames,"Alchemy")
	JArray.AddStr(jAVNames,"SpeechCraft")
	JArray.AddStr(jAVNames,"Alteration")
	JArray.AddStr(jAVNames,"Conjuration")
	JArray.AddStr(jAVNames,"Destruction")
	JArray.AddStr(jAVNames,"Illusion")
	JArray.AddStr(jAVNames,"Restoration")
	JArray.AddStr(jAVNames,"Enchanting")
	JArray.AddStr(jAVNames,"Health")
	JArray.AddStr(jAVNames,"Magicka")
	JArray.AddStr(jAVNames,"Stamina")
	JArray.AddStr(jAVNames,"HealRate")
	JArray.AddStr(jAVNames,"MagickaRate")
	JArray.AddStr(jAVNames,"StaminaRate")
	JArray.AddStr(jAVNames,"SpeedMult")
	JArray.AddStr(jAVNames,"InventoryWeight")
	JArray.AddStr(jAVNames,"CarryWeight")
	JArray.AddStr(jAVNames,"CritChance")
	JArray.AddStr(jAVNames,"MeleeDamage")
	JArray.AddStr(jAVNames,"UnarmedDamage")
	JArray.AddStr(jAVNames,"Mass")
	JArray.AddStr(jAVNames,"VoicePoints")
	JArray.AddStr(jAVNames,"VoiceRate")
	JArray.AddStr(jAVNames,"DamageResist")
	JArray.AddStr(jAVNames,"PoisonResist")
	JArray.AddStr(jAVNames,"FireResist")
	JArray.AddStr(jAVNames,"ElectricResist")
	JArray.AddStr(jAVNames,"FrostResist")
	JArray.AddStr(jAVNames,"MagicResist")
	JArray.AddStr(jAVNames,"NormalWeaponsResist")
	JArray.AddStr(jAVNames,"PerceptionCondition")
	JArray.AddStr(jAVNames,"EnduranceCondition")
	JArray.AddStr(jAVNames,"LeftAttackCondition")
	JArray.AddStr(jAVNames,"RightAttackCondition")
	JArray.AddStr(jAVNames,"LeftMobilityCondition")
	JArray.AddStr(jAVNames,"RightMobilityCondition")
	JArray.AddStr(jAVNames,"BrainCondition")
	JArray.AddStr(jAVNames,"Paralysis")
	JArray.AddStr(jAVNames,"Invisibility")
	JArray.AddStr(jAVNames,"NightEye")
	JArray.AddStr(jAVNames,"DetectLifeRange")
	JArray.AddStr(jAVNames,"WaterBreathing")
	JArray.AddStr(jAVNames,"WaterWalking")
	JArray.AddStr(jAVNames,"IgnoreCrippleLimbs")
	JArray.AddStr(jAVNames,"Fame")
	JArray.AddStr(jAVNames,"Infamy")
	JArray.AddStr(jAVNames,"JumpingBonus")
	JArray.AddStr(jAVNames,"WardPower")
	JArray.AddStr(jAVNames,"EquippedItemCharge")
	JArray.AddStr(jAVNames,"ArmorPerks")
	JArray.AddStr(jAVNames,"ShieldPerks")
	JArray.AddStr(jAVNames,"WardDeflection")
	JArray.AddStr(jAVNames,"Variable01")
	JArray.AddStr(jAVNames,"Variable02")
	JArray.AddStr(jAVNames,"Variable03")
	JArray.AddStr(jAVNames,"Variable04")
	JArray.AddStr(jAVNames,"Variable05")
	JArray.AddStr(jAVNames,"Variable06")
	JArray.AddStr(jAVNames,"Variable07")
	JArray.AddStr(jAVNames,"Variable08")
	JArray.AddStr(jAVNames,"Variable09")
	JArray.AddStr(jAVNames,"Variable10")
	JArray.AddStr(jAVNames,"BowSpeedBonus")
	JArray.AddStr(jAVNames,"FavorActive")
	JArray.AddStr(jAVNames,"FavorsPerDay")
	JArray.AddStr(jAVNames,"FavorsPerDayTimer")
	JArray.AddStr(jAVNames,"EquippedStaffCharge")
	JArray.AddStr(jAVNames,"AbsorbChance")
	JArray.AddStr(jAVNames,"Blindness")
	JArray.AddStr(jAVNames,"WeaponSpeedMult")
	JArray.AddStr(jAVNames,"ShoutRecoveryMult")
	JArray.AddStr(jAVNames,"BowStaggerBonus")
	JArray.AddStr(jAVNames,"Telekinesis")
	JArray.AddStr(jAVNames,"FavorPointsBonus")
	JArray.AddStr(jAVNames,"LastBribedIntimidated")
	JArray.AddStr(jAVNames,"LastFlattered")
	JArray.AddStr(jAVNames,"Muffled")
	JArray.AddStr(jAVNames,"BypassVendorStolenCheck")
	JArray.AddStr(jAVNames,"BypassVendorKeywordCheck")
	JArray.AddStr(jAVNames,"WaitingForPlayer")
	JArray.AddStr(jAVNames,"OneHandedMod")
	JArray.AddStr(jAVNames,"TwoHandedMod")
	JArray.AddStr(jAVNames,"MarksmanMod")
	JArray.AddStr(jAVNames,"BlockMod")
	JArray.AddStr(jAVNames,"SmithingMod")
	JArray.AddStr(jAVNames,"HeavyArmorMod")
	JArray.AddStr(jAVNames,"LightArmorMod")
	JArray.AddStr(jAVNames,"PickPocketMod")
	JArray.AddStr(jAVNames,"LockPickingMod")
	JArray.AddStr(jAVNames,"SneakMod")
	JArray.AddStr(jAVNames,"AlchemyMod")
	JArray.AddStr(jAVNames,"SpeechcraftMod")
	JArray.AddStr(jAVNames,"AlterationMod")
	JArray.AddStr(jAVNames,"ConjurationMod")
	JArray.AddStr(jAVNames,"DestructionMod")
	JArray.AddStr(jAVNames,"IllusionMod")
	JArray.AddStr(jAVNames,"RestorationMod")
	JArray.AddStr(jAVNames,"EnchantingMod")
	JArray.AddStr(jAVNames,"OneHandedSkillAdvance")
	JArray.AddStr(jAVNames,"TwoHandedSkillAdvance")
	JArray.AddStr(jAVNames,"MarksmanSkillAdvance")
	JArray.AddStr(jAVNames,"BlockSkillAdvance")
	JArray.AddStr(jAVNames,"SmithingSkillAdvance")
	JArray.AddStr(jAVNames,"HeavyArmorSkillAdvance")
	JArray.AddStr(jAVNames,"LightArmorSkillAdvance")
	JArray.AddStr(jAVNames,"PickPocketSkillAdvance")
	JArray.AddStr(jAVNames,"LockPickingSkillAdvance")
	JArray.AddStr(jAVNames,"SneakSkillAdvance")
	JArray.AddStr(jAVNames,"AlchemySkillAdvance")
	JArray.AddStr(jAVNames,"SpeechcraftSkillAdvance")
	JArray.AddStr(jAVNames,"AlterationSkillAdvance")
	JArray.AddStr(jAVNames,"ConjurationSkillAdvance")
	JArray.AddStr(jAVNames,"DestructionSkillAdvance")
	JArray.AddStr(jAVNames,"IllusionSkillAdvance")
	JArray.AddStr(jAVNames,"RestorationSkillAdvance")
	JArray.AddStr(jAVNames,"EnchantingSkillAdvance")
	JArray.AddStr(jAVNames,"LeftWeaponSpeedMult")
	JArray.AddStr(jAVNames,"DragonSouls")
	JArray.AddStr(jAVNames,"CombatHealthRegenMult")
	JArray.AddStr(jAVNames,"OneHandedPowerMod")
	JArray.AddStr(jAVNames,"TwoHandedPowerMod")
	JArray.AddStr(jAVNames,"MarksmanPowerMod")
	JArray.AddStr(jAVNames,"BlockPowerMod")
	JArray.AddStr(jAVNames,"SmithingPowerMod")
	JArray.AddStr(jAVNames,"HeavyArmorPowerMod")
	JArray.AddStr(jAVNames,"LightArmorPowerMod")
	JArray.AddStr(jAVNames,"PickPocketPowerMod")
	JArray.AddStr(jAVNames,"LockPickingPowerMod")
	JArray.AddStr(jAVNames,"SneakPowerMod")
	JArray.AddStr(jAVNames,"AlchemyPowerMod")
	JArray.AddStr(jAVNames,"SpeechcraftPowerMod")
	JArray.AddStr(jAVNames,"AlterationPowerMod")
	JArray.AddStr(jAVNames,"ConjurationPowerMod")
	JArray.AddStr(jAVNames,"DestructionPowerMod")
	JArray.AddStr(jAVNames,"IllusionPowerMod")
	JArray.AddStr(jAVNames,"RestorationPowerMod")
	JArray.AddStr(jAVNames,"EnchantingPowerMod")
	JArray.AddStr(jAVNames,"DragonRend")
	JArray.AddStr(jAVNames,"AttackDamageMult")
	JArray.AddStr(jAVNames,"CombatHealthRegenMultMod")
	JArray.AddStr(jAVNames,"CombatHealthRegenMultPowerMod")
	JArray.AddStr(jAVNames,"StaminaRateMult")
	JArray.AddStr(jAVNames,"HealRatePowerMod")
	JArray.AddStr(jAVNames,"MagickaRateMod")
	JArray.AddStr(jAVNames,"GrabActorOffset")
	JArray.AddStr(jAVNames,"Grabbed")
	JArray.AddStr(jAVNames,"UNKNOWN")
	JArray.AddStr(jAVNames,"ReflectDamage")
	SetSessionObj("AVNames",jAVNames)
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
