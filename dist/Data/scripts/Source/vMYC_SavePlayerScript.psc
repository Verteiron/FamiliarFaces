Scriptname vMYC_SavePlayerScript extends Quest  
{Save the current player to a file using PapyrusUtil}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor Property PlayerRef Auto
{The Player, duh}

ActorBase Property vMYC_CharacterDummyM01 Auto
{Male dummy}

Formlist Property vMYC_PlayerFormlist Auto
{An empty formlist that will be used to store all the player's spells, shouts, etc.}

Formlist Property vMYC_PerkList Auto
{A list of all the perks we want to check for.}

TextureSet Property vMYC_PlayerFaceTexture Auto
TextureSet Property vMYC_DummyTexture Auto

;--=== Config variables ===--

;--=== Variables ===--

String[] _sAVNames

;--=== Events ===--

Event OnInit()
	_sAVNames = New String[86]
	_sAVNames[00] = "Health"
	_sAVNames[01] = "Magicka"
	_sAVNames[02] = "Stamina"
	_sAVNames[03] = "OneHanded"
	_sAVNames[04] = "TwoHanded"
	_sAVNames[05] = "Marksman"
	_sAVNames[06] = "Block"
	_sAVNames[07] = "Smithing"
	_sAVNames[08] = "HeavyArmor"
	_sAVNames[09] = "LightArmor"
	_sAVNames[10] = "Pickpocket"
	_sAVNames[11] = "Lockpicking"
	_sAVNames[12] = "Sneak"
	_sAVNames[13] = "Alchemy"
	_sAVNames[14] = "Speechcraft"
	_sAVNames[15] = "Alteration"
	_sAVNames[16] = "Conjuration"
	_sAVNames[17] = "Destruction"
	_sAVNames[18] = "Illusion"
	_sAVNames[19] = "Restoration"
	_sAVNames[20] = "Enchanting"
	_sAVNames[21] = "Aggression"
	_sAVNames[22] = "Confidence"
	_sAVNames[23] = "Energy"
	_sAVNames[24] = "Morality"
	_sAVNames[25] = "Mood"
	_sAVNames[26] = "Assistance"
	_sAVNames[28] = "HealRate"
	_sAVNames[29] = "MagickaRate"
	_sAVNames[30] = "StaminaRate"
	_sAVNames[31] = "attackDamageMult"
	_sAVNames[32] = "SpeedMult"
	_sAVNames[33] = "ShoutRecoveryMult"
	_sAVNames[34] = "WeaponSpeedMult"
	_sAVNames[35] = "InventoryWeight"
	_sAVNames[36] = "CarryWeight"
	_sAVNames[37] = "CritChance"
	_sAVNames[38] = "MeleeDamage"
	_sAVNames[39] = "UnarmedDamage"
	_sAVNames[40] = "Mass"
	_sAVNames[41] = "VoicePoints"
	_sAVNames[42] = "VoiceRate"
	_sAVNames[43] = "DamageResist"
	_sAVNames[44] = "DiseaseResist"
	_sAVNames[45] = "PoisonResist"
	_sAVNames[46] = "FireResist"
	_sAVNames[47] = "ElectricResist"
	_sAVNames[48] = "FrostResist"
	_sAVNames[49] = "MagicResist"
	_sAVNames[50] = "Paralysis"
	_sAVNames[51] = "Invisibility"
	_sAVNames[52] = "NightEye"
	_sAVNames[53] = "DetectLifeRange"
	_sAVNames[54] = "WaterBreathing"
	_sAVNames[55] = "WaterWalking"
	_sAVNames[56] = "JumpingBonus"
	_sAVNames[57] = "WardPower"
	_sAVNames[58] = "WardDeflection"
;	_sAVNames[59] = "EquippedItemCharge"
;	_sAVNames[60] = "EquippedStaffCharge"
	_sAVNames[61] = "ArmorPerks"
	_sAVNames[62] = "ShieldPerks"
	_sAVNames[63] = "BowSpeedBonus"
	_sAVNames[64] = "DragonSouls"
;	_sAVNames[66] = "CombatHealthRegenMultMod"
;	_sAVNames[67] = "CombatHealthRegenMultPowerMod"
	_sAVNames[68] = "PerceptionCondition"
	_sAVNames[69] = "EnduranceCondition"
	_sAVNames[70] = "LeftAttackCondition"
	_sAVNames[71] = "RightAttackCondition"
	_sAVNames[72] = "LeftMobilityCondition"
	_sAVNames[73] = "RightMobilityCondition"
	_sAVNames[74] = "BrainCondition"
	_sAVNames[75] = "IgnoreCrippledLimbs"
	_sAVNames[76] = "Fame"
	_sAVNames[77] = "Infamy"
	_sAVNames[78] = "FavorActive"
	_sAVNames[79] = "FavorPointsBonus"
	_sAVNames[80] = "FavorsPerDay"
	_sAVNames[81] = "FavorsPerDayTimer"
	_sAVNames[82] = "BypassVendorStolenCheck"
	_sAVNames[83] = "BypassVendorKeywordCheck"
	_sAVNames[84] = "LastBribedIntimidated"
	_sAVNames[85] = "LastFlattered"
EndEvent

;--=== Functions ===--

Function DoSavePlayer()

	Form[] PlayerEquipment = New Form[64]
	Enchantment[] PlayerEnchantments = New Enchantment[64]
	
	String sPlayerName = PlayerREF.GetName()
	If !sPlayerName
		sPlayerName = PlayerREF.GetActorBase().GetName()
		Debug.Trace("MYC: Name from GetActorBase: " + sPlayerName)
	EndIf
	If !sPlayerName
		sPlayerName = PlayerREF.GetBaseObject().GetName()
		Debug.Trace("MYC: Name from GetBaseObject: " + sPlayerName)		
	EndIf
	Debug.Trace("MYC: Getting basic data from " + sPlayerName + "...")
	
	Debug.Trace("MYC:            Race: " + PlayerREF.GetRace() + ", " + PlayerREF.GetRace().GetName())
	Debug.Trace("MYC:          Weight: " + PlayerREF.GetWeight() + ", " + PlayerREF.GetActorBase().GetWeight())

	String sKey = "vMYC." + sPlayerName

	StorageUtil.StringListAdd(Self,"vMYC.CharacterNames",sPlayerName,allowDuplicate = False)
	
	StorageUtil.ExportFile("vMYC_CharacterList.txt", restrictForm = Self)

	StorageUtil.StringListClear(Self,"vMYC.CharacterNames")
	
	StorageUtil.SetFloatValue(Self,sKey + ".Playtime",GetCurrentGameTime())
	StorageUtil.SetIntValue(Self,sKey + ".Stat.Level",PlayerREF.GetLevel())
	StorageUtil.SetIntValue(Self,sKey + ".Stat.Sex",PlayerREF.GetActorBase().GetSex())
	StorageUtil.SetFloatValue(Self,sKey + ".Stat.Weight",PlayerREF.GetActorBase().GetWeight())
	StorageUtil.SetFormValue(Self,sKey + ".Stat.Race",PlayerREF.GetRace())
	StorageUtil.SetFloatValue(Self,sKey + ".Stat.Weight",PlayerREF.GetActorBase().GetWeight())
	
	Float[] fPlayerBaseAVs = New Float[97]
	String sBlank = "                             "

	Int i = 0

	While i < _sAVNames.Length
		If _sAVNames[i]
			fPlayerBaseAVs[i] = PlayerREF.GetBaseActorValue(_sAVNames[i])
			StorageUtil.SetFloatValue(Self,sKey + ".Stat.AV." + _sAVNames[i],fPlayerBaseAVs[i])
			Debug.Trace("MYC: " + StringUtil.SubString(sBlank,0,StringUtil.GetLength(sBlank) - StringUtil.GetLength(_sAVNames[i])) + _sAVNames[i] + ":, " + fPlayerBaseAVs[i])
		EndIf
		i += 1
	EndWhile

	i = vMYC_PerkList.GetSize()
	While i > 0
		i -= 1
		Perk kPerk = vMYC_PerkList.GetAt(i) as Perk
		If PlayerREF.HasPerk(kPerk)
			Debug.Trace("MYC: Player has Perk " + kPerk.GetName())
			StorageUtil.FormListAdd(Self,sKey + ".Perks",kPerk)
		EndIf
	EndWhile
	
	
	Int h = 0x00000001

	While (h < 0x80000000)
		Form WornForm = PlayerREF.GetWornForm(h)
		If (WornForm)
			Debug.Trace("MYC: " + sPlayerName + " is wearing " + WornForm.GetFormID() + ", " + WornForm.GetName() + " on slot " + h)
			If PlayerEquipment.Find(WornForm) < 0
				Int newindex = PlayerEquipment.Find(None)
				PlayerEquipment[newindex] = WornForm
				StorageUtil.FormListAdd(Self,sKey + ".Equipment.Armor",WornForm)
				If WornForm as Armor
					Enchantment kItemEnchantment = (WornForm as Armor).GetEnchantment()
					If kItemEnchantment
						PlayerEnchantments[newindex] = kItemEnchantment
						Debug.Trace("MYC: " + WornForm.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
					EndIf
				EndIf
			EndIf
		EndIf
		h = Math.LeftShift(h,1)
	endWhile
	
	i = 60
	PlayerEquipment[60] = PlayerREF.GetEquippedObject(0) ; LeftHand
	PlayerEquipment[61] = PlayerREF.GetEquippedObject(1) ; RightHand
	PlayerEquipment[62] = PlayerREF.GetEquippedObject(2) ; Shout/Power
	StorageUtil.FormListAdd(Self,sKey + ".Equipment.Left",PlayerEquipment[60])
	StorageUtil.FormListAdd(Self,sKey + ".Equipment.Right",PlayerEquipment[61])
	StorageUtil.FormListAdd(Self,sKey + ".Equipment.Power",PlayerEquipment[62])
	
	
	Int iSpellCount = PlayerREF.GetSpellCount()
	Int iAddedCount = 0
	i = 0
	Bool bAddItem = False
	Debug.Trace("MYC: " + sPlayerName + " knows " + iSpellCount + " spells.")
	While i < iSpellCount
		bAddItem = False
		Spell kSpell = PlayerREF.GetNthSpell(i)
		If kSpell
			bAddItem = True
			Int iSpellID = kSpell.GetFormID()
			;Debug.Trace("MYC: " + sPlayerName + " knows the spell " + kSpell + ", " + kSpell.GetName())
			If iSpellID > 0x05000000 || iSpellID < 0 ; Spell is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn
				bAddItem = False
				Debug.Trace("MYC: " + kSpell + " is a mod-added item!")
			EndIf
			If bAddItem
				;vMYC_PlayerFormlist.AddForm(kSpell)
				StorageUtil.FormListAdd(Self,sKey + ".Spell",kSpell)
				iAddedCount += 1
			EndIf
		EndIf
		i += 1
	EndWhile
	Debug.Trace("MYC: Saved " + iAddedCount + " spells for " + sPlayerName + ".")
	
	Int iItemCount = PlayerREF.GetNumItems()
	i = 0
	Debug.Trace("MYC: " + sPlayerName + " has " + iItemCount + " items.")
	iAddedCount = 0
	While i < iItemCount
		bAddItem = False
		Form kItem = PlayerREF.GetNthForm(i)
		Int iItemID = kItem.GetFormID()
		Int iType = kItem.GetType()
		If iType == 41 ; Weapon
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Weapon: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 26 ; Armor
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Armor: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 42 ; Ammo
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Ammo: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 23 ; Scroll
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Scroll: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 46 ; Potion 
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Potion: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 30 ; Ingredient
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Ingredient: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 31 ; Light (torch)
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Light: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 52 ; Soulgem
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Soulgem: " + kItem + ", " + kItem.GetName())
			bAddItem = True
		ElseIf iType == 32 ; MiscItem, gold, lockpicks, etc
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Misc: " + kItem + ", " + kItem.GetName())
			If iItemId == 0x0000000F || iItemId == 0x0000000A ; gold or lockpick
				bAddItem = True
			EndIf
		Else
			;Debug.Trace("MYC: " + sPlayerName + " has " +  PlayerREF.GetItemCount(kItem) + " of Type" + iType + ": " + kItem + ", " + kItem.GetName())
		EndIf
		If iItemID > 0x05000000 || iItemID < 0 && !(iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF) ; Item is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn and is not a custom item
			Debug.Trace("MYC: " + kItem + " is a mod-added item!")
			bAddItem = False
		ElseIf (iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF) ; This is a custom-made item
			Debug.Trace("MYC: " + kItem + " is a customized/forged/mixed item!")
			bAddItem = False
		EndIf
		
		If bAddItem
			;vMYC_PlayerFormlist.AddForm(kItem)
			StorageUtil.FormListAdd(Self,sKey + ".Item",kItem)
			StorageUtil.IntListAdd(Self,sKey + ".ItemCount",PlayerREF.GetItemCount(kItem))
			iAddedCount += 1
		EndIf
		i += 1
	EndWhile
	Debug.Trace("MYC: Saved " + iAddedCount + " items for " + sPlayerName + ".")
	
	
	ActorBase PlayerBase = PlayerREF.GetActorBase()
	
	StorageUtil.SetFormValue(Self,sKey + ".Appearance.Haircolor",PlayerBase.GetHairColor())
	StorageUtil.SetFormValue(Self,sKey + ".Appearance.Skin",PlayerBase.GetSkin())
	StorageUtil.SetFormValue(Self,sKey + ".Appearance.SkinFar",PlayerBase.GetSkinFar())
	StorageUtil.SetFormValue(Self,sKey + ".VoiceType",PlayerBase.GetVoiceType())
	
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		HeadPart kHeadPart = PlayerBase.GetNthHeadPart(i)
		StorageUtil.FormListAdd(Self,sKey + ".Appearance.HeadParts",kHeadPart)
		Int j = 0
		While j < kHeadPart.GetNumExtraParts()
			HeadPart kExtraHeadPart = kHeadPart.GetNthExtraPart(j)
			StorageUtil.FormListAdd(Self,sKey + ".Appearance.HeadParts.Extra",kExtraHeadPart)
			;PlayerDupe.ChangeHeadPart(kExtraHeadPart)
			j += 1
		EndWhile
		i += 1
	EndWhile
	
	vMYC_PlayerFaceTexture = PlayerBase.GetFaceTextureSet()
	i = 0
	While i < vMYC_PlayerFaceTexture.GetNumTexturePaths()
		;Debug.Trace("MYC: PlayerFaceTexture path " + i + " is " + vMYC_PlayerFaceTexture.GetNthTexturePath(i))
		StorageUtil.StringListAdd(Self,sKey + ".Appearance.FaceTextureSetPaths",vMYC_PlayerFaceTexture.GetNthTexturePath(i))
		i += 1
	EndWhile
	
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		;Debug.Trace("MYC: Copying face preset " + i)
		StorageUtil.IntListAdd(Self,sKey + ".Appearance.Face.Presets",PlayerBase.GetFacePreset(i))
		i += 1
	EndWhile
	
	i = 0
	While i < PlayerBase.GetNumHeadParts() * 4
		Float fFaceMorph = PlayerBase.GetFaceMorph(i)
		StorageUtil.FloatListAdd(Self,sKey + ".Appearance.Face.Morphs",fFaceMorph)
		i += 1
	EndWhile
	CharGen.SaveCharacter(sPlayerName)
	;Debug.MessageBox("Chargen Version is " + SKSE.GetPluginVersion("CharGen"))
	If SKSE.GetPluginVersion("CharGen") > 0
		Debug.Trace("MYC: Exporting head with CharGen...")
		UI.InvokeString("HUD Menu", "_global.skse.plugins.CharGen.ExportHead", "Data\\Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName)
		Debug.Trace("MYC: Done!")
	Else
		Debug.MessageBox("Fuckin', no CharGen, MAN!")
	EndIf
	
	StorageUtil.ExportFile("vMYC_" + sPlayerName, restrictForm = Self)
	Debug.Notification("Exported character data!")

	;Return
;------------------------------------ End export process
	Actor PlayerDupe = PlayerREF.PlaceActorAtMe(vMYC_CharacterDummyM01)
	Wait(1)
	PlayerDupe.SetAngle(0,0,90)
	Wait(1)
	
	;bool Function LoadCharacter(Actor akActor, Race akRace, string characterName) native global
	CharGen.LoadCharacter(PlayerDupe, PlayerREF.GetRace(), sPlayerName) 
	
	Return
	
	StorageUtil.ImportFile("vMYC_Tagaerys.txt")
	vMYC_CharacterDummyM01.SetName(sPlayerName)
	Debug.Notification("Duplicating character...")

	Debug.Notification("Setting body type...")
	vMYC_CharacterDummyM01.SetWeight(PlayerREF.GetActorBase().GetWeight())
	vMYC_CharacterDummyM01.SetHeight(PlayerREF.GetActorBase().GetHeight())
	vMYC_CharacterDummyM01.SetSkin(PlayerREF.GetActorBase().GetSkin())
	vMYC_CharacterDummyM01.SetHairColor(PlayerREF.GetActorBase().GetHairColor())
	Debug.Trace("MYC: Weight, Height, Haircolor")
	

	;Actor PlayerDupe = PlayerREF.PlaceActorAtMe(vMYC_CharacterDummyM01)
	If PlayerDupe.GetRace() != PlayerREF.GetRace() 
		PlayerDupe.SetRace(PlayerREF.GetRace())
	EndIf
	vMYC_PlayerFaceTexture = PlayerBase.GetFaceTextureSet()
	i = 0
	While i < vMYC_PlayerFaceTexture.GetNumTexturePaths()
		Debug.Trace("MYC: PlayerFaceTexture path " + i + " is " + vMYC_PlayerFaceTexture.GetNthTexturePath(i))
		i += 1
	EndWhile
	vMYC_DummyTexture = vMYC_PlayerFaceTexture
	vMYC_DummyTexture.SetNthTexturePath(6,"actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName + ".dds")
	Wait(1)
;	PlayerDupe.EnableAI(False)
	PlayerDupe.SetAngle(0,0,90)
	Debug.Notification("Setting head..")
	
	If SKSE.GetPluginVersion("CharGen") > 0
		Debug.Trace("MYC: Exporting head with CharGen...")
		UI.InvokeString("HUD Menu", "_global.skse.plugins.CharGen.ExportHead", "Data\\Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName)
		Debug.Trace("MYC: Done!")
	Else
		Debug.MessageBox("Fuckin', no CharGen, MAN!")
	EndIf
	
;-------Copies by num
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		HeadPart kHeadPart = PlayerBase.GetNthHeadPart(i)
		Debug.Trace("MYC: Copying HeadPart " + i + ": " + kHeadPart + ", type " + kHeadPart.GetType())
		Int j = 0
		;If kHeadPart.GetType() != 0
		;	Debug.Trace("MYC:  Running ChangeHeadPart")
		
		;EndIf
		;vMYC_CharacterDummyM01.SetNthHeadPart(kHeadPart,i)
		PlayerDupe.ChangeHeadPart(kHeadPart)
		While j < kHeadPart.GetNumExtraParts()
			HeadPart kExtraHeadPart = kHeadPart.GetNthExtraPart(j)
			Debug.Trace("MYC:  Copying Extra headPart " + i + "-" + j + ": " + kExtraHeadPart + ", index " + kHeadPart.GetIndexOfExtraPart(kExtraHeadPart) + ", type " + kExtraHeadPart.GetType())
			;vMYC_CharacterDummyM01.SetNthHeadPart(kExtraHeadPart,vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(kExtraHeadPart.GetType()))
			PlayerDupe.ChangeHeadPart(kExtraHeadPart)
			j += 1
		EndWhile
		i += 1
	EndWhile
	PlayerDupe.QueueNiNodeUpdate()
	Wait(2)
	String sNodeToOverride = vMYC_CharacterDummyM01.GetNthHeadPart(vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(1)).GetName()
	Debug.Trace("MYC: NiOverride.AddNodeOverrideString(" + PlayerDupe + ", " + vMYC_CharacterDummyM01.GetSex() + ", " + sNodeToOverride + ", 9, 6, SKSE\\Plugins\\CharGen\\" + sPlayerName + ".dds, false)")
	If PlayerDupe.HasNode(sNodeToOverride)
		Debug.Trace("MYC: PlayerDupe has a node named " + sNodeToOverride)
		NiOverride.AddNodeOverrideString(PlayerDupe, vMYC_CharacterDummyM01.GetSex(), sNodeToOverride, 9, 6, "Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName + ".dds", false)
	EndIf
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		Debug.Trace("MYC: Copying face preset " + i)
		vMYC_CharacterDummyM01.SetFacePreset(PlayerBase.GetFacePreset(i),i)
		i += 1
	EndWhile
	;PlayerDupe.RegenerateHead()
	Debug.Trace("MYC: Updated Face Presets.")
	Wait(2)
	;Wait(1)
	
	i = 0
	While i < PlayerBase.GetNumHeadParts() * 4
		Float fFaceMorph = PlayerBase.GetFaceMorph(i)
		Debug.Trace("MYC: Copying face morph " + i + ": " + fFaceMorph)
		vMYC_CharacterDummyM01.SetFaceMorph(fFaceMorph,i)
		i += 1
	EndWhile
	;PlayerDupe.RegenerateHead()
	Debug.Trace("MYC: Updated Face Morphs.")
	;Wait(2)
	PlayerDupe.QueueNiNodeUpdate()
	;Wait(2)

	
	
	Debug.Trace("MYC: Player has " + PlayerRef.GetActorBase().GetNumHeadParts() + " headparts, PlayerDupe has " + vMYC_CharacterDummyM01.GetNumHeadParts() + " headparts.")
	

;	Wait(5)

	;PlayerDupe.QueueNiNodeUpdate()
	;PlayerDupe.Disable(False)
	;PlayerDupe.Enable(False)
	
;Wait(2)	
	sNodeToOverride = vMYC_CharacterDummyM01.GetNthHeadPart(vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(1)).GetName()
	Debug.Trace("MYC: NiOverride.AddNodeOverrideString(" + PlayerDupe + ", " + vMYC_CharacterDummyM01.GetSex() + ", " + sNodeToOverride + ", 9, 6, SKSE\\Plugins\\CharGen\\" + sPlayerName + ".dds, false)")
	If PlayerDupe.HasNode(sNodeToOverride)
		Debug.Trace("MYC: PlayerDupe has a node named " + sNodeToOverride)
		NiOverride.AddNodeOverrideString(PlayerDupe, vMYC_CharacterDummyM01.GetSex(), sNodeToOverride, 9, 6, "Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName + ".dds", false)
	EndIf
;Wait(2)	
i = 0
	While i < PlayerBase.GetNumHeadParts() * 4
		Float fFaceMorph = PlayerBase.GetFaceMorph(i)
		Debug.Trace("MYC: Copying face morph " + i + ": " + fFaceMorph)
		vMYC_CharacterDummyM01.SetFaceMorph(fFaceMorph,i)
		i += 1
	EndWhile
	;PlayerDupe.RegenerateHead()
	Debug.Trace("MYC: Updated Face Morphs.")
	;Wait(2)
	;i = 0
	;While i < PlayerBase.GetNumHeadParts()
		;HeadPart kHeadPart = PlayerBase.GetNthHeadPart(i)
		;If kHeadPart.GetType() != 1  ;!vMYC_CharacterDummyM01.GetNthHeadPart(vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(kHeadPart.GetType())) ; Player has this type of headpart but target is missing it
			;;Debug.Trace("MYC: PlayerDupe is missing " + i + ": " + kHeadPart + ", type " + kHeadPart.GetType())
			;Debug.Trace("MYC:  Running ChangeHeadPart")
			;PlayerDupe.ChangeHeadPart(kHeadPart)
		;EndIf
		;i += 1
	;EndWhile
;Wait(2)
;NiOverride.ApplyNodeOverrides(PlayerDupe)
	Debug.Trace("MYC: Player has " + PlayerRef.GetActorBase().GetNumHeadParts() + " headparts, PlayerDupe has " + vMYC_CharacterDummyM01.GetNumHeadParts() + " headparts.")
	;PlayerDupe.Disable()
;	Wait(1)
	;PlayerDupe.Enable()
;------------ copies by type	
;i = 7
;While i > 0
;	i -= 1
;	HeadPart kHeadPart = PlayerBase.GetNthHeadPart(PlayerBase.GetIndexOfHeadPartByType(i))
;	String sHeadPartName = kHeadPart.GetName()
;	Debug.Trace("MYC: Copying HeadPart " + kHeadPart + ": " + sHeadPartName + ", type " + i)
;	vMYC_CharacterDummyM01.SetNthHeadPart(kHeadPart,PlayerBase.GetIndexOfHeadPartByType(i))
;	Int j = kHeadPart.GetNumExtraParts()
;	While j > 0
;		j -= 1
;		HeadPart kExtraHeadPart = kHeadPart.GetNthExtraPart(j)
;		String sExtraHeadPartName = kExtraHeadPart.GetName()
;		Debug.Trace("MYC: Copying Extra headPart " + kHeadPart + "-" + kExtraHeadPart + ": " + sExtraHeadPartName + ", index " + kHeadPart.GetIndexOfExtraPart(kExtraHeadPart) + ", type " + kExtraHeadPart.GetType())
;		vMYC_CharacterDummyM01.SetNthHeadPart(kExtraHeadPart,PlayerBase.GetIndexOfHeadPartByType(kExtraHeadPart.GetType()))
;	EndWhile
;	Wait(1)
;EndWhile
	;PlayerDupe.RegenerateHead()
	Debug.Trace("MYC: Updated HeadParts.")
	;Wait(1)
	
	;PlayerDupe.Disable(True)


	;i = 0
	;While i < 7
		;Int j = 0
		;String sHeadPartName = PlayerBase.GetNthHeadPart(PlayerBase.GetIndexOfHeadPartByType(i)).GetName()
		;Debug.Trace("MYC: Textures for PlayerOrig headpart " + sHeadPartName + ":")
		;While j < 9
			;Debug.Trace("MYC:   " + j + " is " + NiOverride.GetNodePropertyString(PlayerREF,False,sHeadPartName,9,j))
			;j += 1
		;EndWhile
		;i += 1
	;EndWhile

	
	


	;PlayerDupe.Enable(True)
	;PlayerDupe.Disable(True)
	;PlayerDupe.QueueNiNodeUpdate()

	
	;PlayerDupe.QueueNiNodeUpdate()

	i = 0
	While i < 7
		Int j = 0
		String sHeadPartName = vMYC_CharacterDummyM01.GetNthHeadPart(vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(i)).GetName()
		Debug.Trace("MYC: Textures for PlayerDupe headpart " + sHeadPartName + ":")
		While j < 9
			Debug.Trace("MYC:   " + j + " is " + NiOverride.GetNodePropertyString(PlayerDupe,False,sHeadPartName,9,j))
			j += 1
		EndWhile
		i += 1
	EndWhile

;	Wait(1)
	Debug.Trace("MYC: Setting textureset...")
	
	NetImmerse.SetNodeTextureSet(PlayerDupe, sNodeToOverride, vMYC_DummyTexture, False)
	
	Debug.Notification("Setting gear...")
	i = vMYC_PlayerFormlist.GetSize()
	Form kFormToAdd

	Debug.Trace("MYC: Player's head texture is " + NiOverride.GetNodePropertyString(PlayerREF,False,PlayerBase.GetNthHeadPart(PlayerBase.GetIndexOfHeadPartByType(1)).GetName(),9,6))
	Debug.Trace("MYC: Target's head texture is " + NiOverride.GetNodePropertyString(PlayerDupe,False,vMYC_CharacterDummyM01.GetNthHeadPart(vMYC_CharacterDummyM01.GetIndexOfHeadPartByType(1)).GetName(),9,6))

	
	While i > 0
		i -= 1
		kFormToAdd = vMYC_PlayerFormList.GetAt(i)
		If kFormToAdd as Spell
			PlayerDupe.AddSpell(kFormToAdd as Spell)
		Else
			PlayerDupe.AddItem(kFormToAdd)
		EndIf
	EndWhile
	
	i = 0
	While i < 60
		If PlayerEquipment[i]
			PlayerDupe.EquipItemEx(PlayerEquipment[i],0)
		EndIf
		i += 1
	EndWhile

	PlayerDupe.EquipItemEx(PlayerEquipment[61],2)
	PlayerDupe.EquipItemEx(PlayerEquipment[60],1)
	PlayerDupe.EquipItemEx(PlayerEquipment[62],0)

	Debug.Notification("Duplicate complete!")
	
EndFunction

