Scriptname vMYC_API_Item extends vMYC_APIBase Hidden
{Save and restore item data, including custom items.}

; === [ vMYC_API_Item.psc ] ===============================================---
; API for saving and loading customized items. 
; 
; This will serialize and write to the Registry Weapons, Armor, and Potions
; with all customizations included. Once serialized, the item is represented 
; by a UUID. 
; 
; This ID can then be used to recreate the item in any gaming session, with 
; all customizations intact.
; ========================================================---

Import vMYC_Registry
Import vMYC_Session

;=== Generic Functions ===--

Int Function GetItemJMap(String asItemID) Global
	Int iRet = -2 ; ItemID not present
	String sRegKey = "Items." + asItemID
	Int jItemData = GetRegObj(sRegKey)
	If jItemData
		Return jItemData
	EndIf
	Return iRet
EndFunction

Int Function GetItemInfosForForm(Form akForm) Global
;Return a JMap of JItemInfos already saved for akForm
	Int jItemFMap = GetRegObj("ItemMap")
	If !JValue.IsFormMap(jItemFMap)
		SetRegObj("ItemMap",JFormMap.Object())
		jItemFMap = GetRegObj("ItemMap")
	EndIf
	Int jItemInfoMap = JFormMap.GetObj(jItemFMap,akForm)
	If !jItemInfoMap
		JFormMap.SetObj(jItemFMap,akForm,JMap.Object())
		jItemInfoMap = JFormMap.GetObj(jItemFMap,akForm)
	EndIf
	Return jItemInfoMap
EndFunction

Function SetItemInfosForForm(Form akForm, Int jItemInfoMap) Global
;Return a JMap of JItemInfos already saved for akForm
	Int jItemFMap = GetRegObj("ItemMap")
	If !JValue.IsFormMap(jItemFMap)
		SetRegObj("ItemMap",JFormMap.Object())
		jItemFMap = GetRegObj("ItemMap")
	EndIf
	JFormMap.SetObj(jItemFMap,akForm,jItemInfoMap)
	SetRegObj("ItemMap",jItemFMap)
EndFunction

;Retrieve or create an ItemID for ajObjectInfo. If it has been serialized before, it will return its current itemID.
String Function AssignItemID(Int ajObjectInfo) Global
	Form kForm = JValue.SolveForm(ajObjectInfo,".Form")
	;Debug.Trace("MYC/API/Item/AssignItemID: Attempting to match item with form " + kForm + "...")
	Int jItemInfoMap = GetItemInfosForForm(kForm)
	Int jItemIDs = JMap.AllKeys(jItemInfoMap)
	Int jItemInfos = JMap.AllValues(jItemInfoMap)
	Int i = JArray.Count(jItemIDs)
	While i > 0
		i -= 1
		Int jItemInfo = JArray.GetObj(jItemInfos,i)
		If kForm as Weapon || kForm as Armor
			;FIXME: Are these the best comparisons? What would work better?
			;Debug.Trace("MYC/API/Item/AssignItemID: " + kForm + " is a weapon or armor!")
			;Debug.Trace("MYC/API/Item/AssignItemID: " + kForm + " .Enchantment.Effects[0].MagicEffect is " + JValue.SolveForm(ajObjectInfo,".Enchantment.Effects[0].MagicEffect"))
			;Debug.Trace("MYC/API/Item/AssignItemID: Saved form's .Enchantment.Effects[0].MagicEffect is " + JValue.SolveForm(jItemInfo,".Enchantment.Effects[0].MagicEffect"))
			If 	(JValue.HasPath(ajObjectInfo,".Enchantment.Effects[0].MagicEffect") && (JValue.SolveForm(jItemInfo,".Enchantment.Effects[0].MagicEffect") == JValue.SolveForm(ajObjectInfo,".Enchantment.Effects[0].MagicEffect"))) || \
				(JValue.HasPath(ajObjectInfo,".ItemHealthPercent") && (JValue.SolveFlt(jItemInfo,".ItemHealthPercent") == JValue.SolveFlt(ajObjectInfo,".ItemHealthPercent"))) && \
				(JValue.HasPath(ajObjectInfo,".ItemMaxCharge") && (JValue.SolveFlt(jItemInfo,".ItemMaxCharge") == JValue.SolveFlt(ajObjectInfo,".ItemMaxCharge")))
				
				Return JArray.GetStr(JItemIDs,i)
			EndIf
		ElseIf kForm as Potion
			Debug.Trace("MYC/API/Item/AssignItemID: " + kForm + " is a potion!")
			If 	(JValue.HasPath(ajObjectInfo,".Effects[0].Magnitude") && (JValue.SolveFlt(jItemInfo,".Effects[0].Magnitude") == JValue.SolveFlt(ajObjectInfo,".Effects[0].Magnitude"))) && \
				(JValue.HasPath(ajObjectInfo,".Effects[0].Duration") && (JValue.SolveFlt(jItemInfo,".Effects[0].Duration") == JValue.SolveFlt(ajObjectInfo,".Effects[0].Duration"))) && \
				(JValue.HasPath(ajObjectInfo,".Effects[0].MagicEffect") && (JValue.SolveForm(jItemInfo,".Effects[0].MagicEffect") == JValue.SolveForm(ajObjectInfo,".Effects[0].MagicEffect")))
				
				Return JArray.GetStr(JItemIDs,i)
			EndIf
		Else
			Debug.Trace("MYC/API/Item/AssignItemID: " + kForm + " is something I don't know how to check!")
		EndIf
	EndWhile

	Return FFUtils.UUID()
EndFunction

String Function SaveItem(Int ajObjectInfo) Global
	If !JValue.IsMap(ajObjectInfo)
		Return ""
	EndIf

	String sItemID = AssignItemID(ajObjectInfo)
	String sRegKey = "Items." + sItemID

	If !JValue.HasPath(ajObjectInfo,".SID")
		JValue.SolveStrSetter(ajObjectInfo,".SID",GetSessionStr("SessionID"),True)
	EndIf
	
	If !JValue.HasPath(ajObjectInfo,".UUID")
		JValue.SolveStrSetter(ajObjectInfo,".UUID",sItemID,True)
	EndIf

	;FIXME: Ugleh, UGLEH!
	Int jItemInfoMap = GetItemInfosForForm(JMap.GetForm(ajObjectInfo,"Form"))
	JMap.SetObj(jItemInfoMap,sItemID,ajObjectInfo)
	;SetItemInfosForForm(JMap.GetForm(ajObjectInfo,"Form"),jItemInfoMap)
	SetRegObj(sRegKey,ajObjectInfo)

	Return sItemID
EndFunction

;Serialize an objectReference if it is customized
String Function SerializeObject(ObjectReference akObject) Global
	
	Form kItem = akObject.GetBaseObject()
	If kItem as Weapon || kItem as Armor
		Return SerializeEquipment(akObject)
	ElseIf kItem as Potion
		Return SerializePotion(akObject)
	EndIf
	Return ""
EndFunction

String Function SerializeEquipment(ObjectReference akObject) Global
	Form kItem = akObject.GetBaseObject()
	Int jItemInfo = JMap.Object()

	JMap.SetForm(jItemInfo,"Form",akObject)

	Bool isWeapon = False
	Bool isEnchantable = False
	Bool isTwoHanded = False
	Enchantment kItemEnchantment
	If kItem
		JMap.SetStr(jItemInfo,"Source",FFUtils.GetSourceMod(kItem))
	EndIf
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

	Int jItemEnchantmentInfo = JMap.Object()
	If isEnchantable ; don't create enchantment block unless object can be enchanted
		JMap.SetObj(jItemInfo,"Enchantment",jItemEnchantmentInfo)
	EndIf

	If kItemEnchantment
		;PlayerEnchantments[newindex] = kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
		JMap.SetForm(jItemEnchantmentInfo,"Form",kItemEnchantment)
		JMap.SetStr(jItemInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
;		AddToReqList(kItemEnchantment,"Enchantment")
		JMap.SetStr(jItemEnchantmentInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
		JMap.SetInt(jItemEnchantmentInfo,"IsCustom",0)
	EndIf
	String sItemDisplayName = akObject.GetDisplayName()
	sItemDisplayName = StringUtil.SubString(sItemDisplayName,0,StringUtil.Find(sItemDisplayName,"(") - 1) ; Strip " (Legendary)"
	kItemEnchantment = akObject.GetEnchantment()
	If sItemDisplayName || kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem + " is enchanted/forged item " + sItemDisplayName)
		JMap.SetInt(jItemInfo,"IsCustom",1)
		JMap.SetFlt(jItemInfo,"ItemHealthPercent",akObject.GetItemHealthPercent())
		JMap.SetFlt(jItemInfo,"ItemCharge",akObject.GetItemCharge())
		JMap.SetFlt(jItemInfo,"ItemMaxCharge",akObject.GetItemMaxCharge())
		JMap.SetStr(jItemInfo,"DisplayName",sItemDisplayName)
		kItemEnchantment = akObject.GetEnchantment()
		If kItemEnchantment
			JMap.SetForm(jItemEnchantmentInfo,"Form",kItemEnchantment)
			JMap.SetStr(jItemEnchantmentInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
;			AddToReqList(kItemEnchantment,"Enchantment")
			JMap.SetInt(jItemEnchantmentInfo,"IsCustom",1)
			Int iNumEffects = kItemEnchantment.GetNumEffects()
			JMap.SetInt(jItemEnchantmentInfo,"NumEffects",iNumEffects)
			Int jEffectsArray = JArray.Object()
			Int j = 0
			While j < iNumEffects
				Int jEffectsInfo = JMap.Object()
				JMap.SetFlt(jEffectsInfo, "Magnitude", kItemEnchantment.GetNthEffectMagnitude(j))
				JMap.SetFlt(jEffectsInfo, "Area", kItemEnchantment.GetNthEffectArea(j))
				JMap.SetFlt(jEffectsInfo, "Duration", kItemEnchantment.GetNthEffectDuration(j))
				JMap.SetForm(jEffectsInfo,"MagicEffect", kItemEnchantment.GetNthEffectMagicEffect(j))
				JMap.SetStr(jEffectsInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment.GetNthEffectMagicEffect(j)))
;				AddToReqList(kItemEnchantment.GetNthEffectMagicEffect(j),"MagicEffect")
				JArray.AddObj(jEffectsArray,jEffectsInfo)
				j += 1
			EndWhile
			JMap.SetObj(jItemEnchantmentInfo,"Effects",jEffectsArray)
		EndIf
	Else
		JMap.SetInt(jItemInfo,"IsCustom",0)
	EndIf
	
	;Save dye color, if applicable
	;FIXME: Can dye color be saved when not equipped? There's no function for it...
	;If GetRegBool("Config.NIO.ArmorDye.Enabled") && kItem as Armor 
	;	Bool bHasDye = False
	;	Int iHandle = NiOverride.GetItemUniqueID(kWornObjectActor, 0, (kItem as Armor).GetSlotMask(), False)
	;	Int[] iNIODyeColors = New Int[15]
	;	Int iMaskIndex = 0
	;	While iMaskIndex < iNIODyeColors.Length
	;		Int iColor = NiOverride.GetItemDyeColor(iHandle, iMaskIndex)
	;		If Math.RightShift(iColor,24) > 0
	;			bHasDye = True
	;			iNIODyeColors[iMaskIndex] = iColor
	;		EndIf
	;		iMaskIndex += 1
	;	EndWhile
	;	If bHasDye
	;		JMap.SetObj(jItemInfo,"NIODyeColors",JArray.objectWithInts(iNIODyeColors))
	;	EndIf
	;EndIf

;	If !(iHand == 0 && IsTwoHanded) && kItem ; exclude left-hand iteration of two-handed weapons
;		If kWornObjectActor == PlayerREF
;			kItem.SendModEvent("vMYC_EquipmentSaved","",iHand)
;		Else ;Was not saved from player, indicate this with iHand = -1
;			kItem.SendModEvent("vMYC_EquipmentSaved","",-1)
;		EndIf
;	EndIf
	;Debug.Trace("MYC/CM: Finished serializing " + kItem.GetName() + ", JMap count is " + JMap.Count(jItemInfo))

	Return vMYC_API_Item.SaveItem(jItemInfo)
EndFunction

;Serialize an item without unequipping it from an actor
String Function SerializeEquippedObject(Form kItem, Int iHand = 1, Int h = 0, Actor kWornObjectActor = None) Global
{Fills the JMap jEquipmentInfo with all info from Form kItem.}
	
	Int jEquipmentInfo = JMap.Object()

	JMap.SetForm(jEquipmentInfo,"Form",kItem)

	If !kWornObjectActor
		kWornObjectActor = Game.GetPlayer()
	EndIf

	Bool isWeapon = False
	Bool isEnchantable = False
	Bool isTwoHanded = False
	Enchantment kItemEnchantment
	If kItem
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " is Mod ID " + (kItem.GetFormID() / 0x1000000))
		;JMap.SetStr(jEquipmentInfo,"Source",GetModName(kItem.GetFormID() / 0x1000000))
		JMap.SetStr(jEquipmentInfo,"Source",FFUtils.GetSourceMod(kItem))
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
	Else
		;If the Item isn't a Weapon or Armor, it's a Spell, Light (torch), or None. It doesn't need to be serialized.
		Return ""
	EndIf

	Int jEquipmentEnchantmentInfo = JMap.Object()
	If isEnchantable ; don't create enchantment block unless object can be enchanted
		JMap.SetObj(jEquipmentInfo,"Enchantment",jEquipmentEnchantmentInfo)
	EndIf

	If kItemEnchantment
		;PlayerEnchantments[newindex] = kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
		JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
		JMap.SetStr(jEquipmentInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
;		AddToReqList(kItemEnchantment,"Enchantment")
		JMap.SetStr(jEquipmentEnchantmentInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
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
			JMap.SetStr(jEquipmentEnchantmentInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment))
;			AddToReqList(kItemEnchantment,"Enchantment")
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
				JMap.SetStr(jEffectsInfo,"Source",FFUtils.GetSourceMod(kItemEnchantment.GetNthEffectMagicEffect(j)))
;				AddToReqList(kItemEnchantment.GetNthEffectMagicEffect(j),"MagicEffect")
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

;	If !(iHand == 0 && IsTwoHanded) && kItem ; exclude left-hand iteration of two-handed weapons
;		If kWornObjectActor == PlayerREF
;			kItem.SendModEvent("vMYC_EquipmentSaved","",iHand)
;		Else ;Was not saved from player, indicate this with iHand = -1
;			kItem.SendModEvent("vMYC_EquipmentSaved","",-1)
;		EndIf
;	EndIf
	;Debug.Trace("MYC/CM: Finished serializing " + kItem.GetName() + ", JMap count is " + JMap.Count(jEquipmentInfo))

	Return vMYC_API_Item.SaveItem(jEquipmentInfo)
EndFunction

ObjectReference Function CreateObject(String asItemID) Global
{Recreate an item from scratch using its ItemID.}
	Int jItem = GetItemJMap(asItemID)
	If !jItem
		DebugTraceAPIItem("CreateObject: " + asItemID + " is not a valid ItemID!",1)
		Return None
	EndIf
	Return CreateObjectFromJObj(jItem)
EndFunction

ObjectReference Function CreateObjectFromJObj(Int ajObjectInfo) Global
{Recreate an item from scratch using an appropriate JContainers object.}
	Int jItem = ajObjectInfo
	
	Form kItem = JMap.getForm(jItem,"Form")
	String sItemID = JMap.getStr(jItem,"UUID")
	If !kItem
		DebugTraceAPIItem("CreateObject: " + sItemID + " does not reference a valid base Form!!",1)
		Return None
	EndIf

	ObjectReference kNowhere = Game.GetFormFromFile(0x00004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	ObjectReference kObject = kNowhere.PlaceAtMe(kItem)
	If !kObject
		DebugTraceAPIItem("CreateObject: " + sItemID + " could not use base Form " + kItem + " to create an ObjectReference!",1)
		Return None
	EndIf



	If (kItem as Weapon) || (kItem as Armor)
		Return CustomizeEquipment(sItemID,kObject)
	ElseIf (kItem as Potion)
		Return CreatePotion(sItemID)
	EndIf
	Return kObject
EndFunction

ObjectReference Function CustomizeEquipment(String asItemID, ObjectReference akObject) Global
{Recreate a custom weapon or armor from its saved version. If akObject is passed, attempt to apply the customization to it rather than creating a new one.}
	ObjectReference kObject = akObject
	Int jItem = GetItemJMap(asItemID)
	Form kItem = JMap.getForm(jItem,"Form")
	If !(kItem as Weapon) && !(kItem as Armor)
		DebugTraceAPIItem("CustomizeEquipment: Item is not Weapon or Armor!",1)
		Return kObject
	EndIf
	If JMap.getInt(jItem,"IsCustom")
		String sDisplayName = JMap.getStr(jItem,"DisplayName")
		;DebugTrace(kItem.GetName() + " is customized item " + sDisplayName + "!")
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

String Function SerializePotion(Form akItem) Global
{
	Serialize a custom potion and return its new ItemID.
}

	Potion kPotion = akItem as Potion
	JMap.SetForm(jPotionInfo,"Form",akItem)
	If !akItem as Potion
		Return ""
	EndIf

	Int jPotionInfo = JMap.Object()
	
	JMap.SetStr(jPotionInfo,"Name",kPotion.GetName())
	JMap.SetStr(jPotionInfo,"WorldModelPath",kPotion.GetWorldModelPath())
	JMap.SetStr(jPotionInfo,"Source",FFUtils.GetSourceMod(kPotion))
	
	JMap.SetInt(jPotionInfo,"IsHostile",kPotion.IsHostile() as Int)
	JMap.SetInt(jPotionInfo,"IsFood",kPotion.IsFood() as Int)
	JMap.SetInt(jPotionInfo,"IsPoison",kPotion.IsPoison() as Int)

	Int iNumEffects = kPotion.GetNumEffects()
	JMap.SetInt(jPotionInfo,"NumEffects",iNumEffects)
	Int jEffectsArray = JArray.Object()
	Int i = 0
	While i < iNumEffects
		Int jEffectsInfo = JMap.Object()
		JMap.SetFlt(jEffectsInfo, "Magnitude", kPotion.GetNthEffectMagnitude(i))
		JMap.SetFlt(jEffectsInfo, "Area", kPotion.GetNthEffectArea(i))
		JMap.SetFlt(jEffectsInfo, "Duration", kPotion.GetNthEffectDuration(i))
		JMap.SetForm(jEffectsInfo,"MagicEffect", kPotion.GetNthEffectMagicEffect(i))
		JMap.SetStr(jEffectsInfo,"Source",FFUtils.GetSourceMod(kPotion))
		;AddToReqList(kPotion.GetNthEffectMagicEffect(i),"MagicEffect")
		JArray.AddObj(jEffectsArray,jEffectsInfo)
		i += 1
	EndWhile
	JMap.SetObj(jPotionInfo,"Effects",jEffectsArray)
	;Debug.Trace("MYC/CM: Finished serializing " + akItem.GetName() + ", JMap count is " + JMap.Count(jPotionInfo))
	Return vMYC_API_Item.SaveItem(jPotionInfo)
EndFunction

ObjectReference Function CreatePotion(String asItemID) Global
{Recreate a custom potion using jPotionInfo.}
;FIXME: This won't work because there is no SetNthMagicEffect!

	Int jPotionInfo = GetItemJMap(asItemID)
	Potion kDefaultPotion = Game.GetformFromFile(0x0005661f,"Skyrim.esm") as Potion
	Potion kDefaultPoison = Game.GetformFromFile(0x0005629e,"Skyrim.esm") as Potion
	
	ObjectReference kNowhere = Game.GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	Potion kPotion 
	If JMap.GetInt(jPotionInfo,"IsPoison")
		kPotion = kDefaultPoison
	Else
		kPotion = kDefaultPotion
	EndIf
	
	
	Int jEffectsArray = JMap.GetObj(jPotionInfo,"Effects")
	Int i = JArray.Count(jEffectsArray)
	While i > 0
		i -= 1
		Int jEffectsInfo = JArray.GetObj(jEffectsArray,i)
		;kPotion.SetNthEffectMagicEffect(i,JMap.GetForm(jEffectsInfo,"MagicEffect"))
		kPotion.SetNthEffectDuration(i,JMap.GetInt(jEffectsInfo,"Duration"))
		kPotion.SetNthEffectMagnitude(i,JMap.GetFlt(jEffectsInfo,"Magnitude"))
		kPotion.SetNthEffectArea(i,JMap.GetInt(jEffectsInfo,"Area"))
	EndWhile
	
	Return kNowhere.PlaceAtMe(kPotion,abForcePersist = True)
EndFunction

Function DebugTraceAPIItem(String sDebugString, Int iSeverity = 0) Global
	Debug.Trace("MYC/API/Item: " + sDebugString,iSeverity)
EndFunction