Scriptname vFFC_MCMConfigQuestScript extends vFFC_MCMPanelNav
{MCM config script for Familiar Faces 2.0.}

; === [ vFFC_MCMConfigQuestScript.psc ] ===================================---
; MCM config script. Pretty standard stuff, but probably way more complex than
; average due to the huge amount of data that is being managed here.
; ========================================================---

; === Imports ===--

Import vFF_Registry
Import vFF_Session

; === Constants ===--

;Int 	Property 	PANEL_CHAR_PICKER 					= 1		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS 					= 2		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_STATS			= 3		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_MAGIC			= 4		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_EQUIP			= 5		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_COMBAT			= 6		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL	= 7		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_SHOUTS_MANAGE	= 8		AutoReadOnly Hidden
;Int 	Property 	PANEL_CHAR_OPTIONS_BEHAVIOR			= 9		AutoReadOnly Hidden
; Int 	Property 	PANEL_CHAR_SELECT 			= 0			AutoReadOnly Hidden
; Int 	Property 	PANEL_CHAR_SELECT 			= 0			AutoReadOnly Hidden
; Int 	Property 	PANEL_CHAR_SELECT 			= 0			AutoReadOnly Hidden


; === Enums ===--

String[] Property	ENUM_CHAR_ARMORCHECK					Auto Hidden

String[] Property	ENUM_CHAR_PLAYERRELATIONSHIP			Auto Hidden

String[] Property	ENUM_GLOBAL_MAGIC_OVERRIDES				Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS		    Auto Hidden
String[] Property	ENUM_GLOBAL_SHOUTS_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_FILE_LOCATION			    Auto Hidden

Form[] 		Property 	CombatStyleList							Auto Hidden
String[] 	Property 	CombatStyleNames						Auto Hidden

Form[] 		Property 	VoiceTypeList							Auto Hidden
String[] 	Property 	VoiceTypeNames							Auto Hidden
String[] 	Property 	VoiceTypeLegends						Auto Hidden

; === Properties ===--

vFFC_MetaQuestScript 	Property MetaQuest 						Auto
vFFC_DataManager 		Property DataManager 					Auto

; === Properties: Character Page ===--

String[] 				Property CharacterNames 				Auto Hidden
String 					Property CurrentCharacterName			Auto Hidden
String 					Property CurrentSID		 				Auto Hidden
VoiceType 				Property CurrentVoiceType 				Auto Hidden
Class 					Property CurrentClass	 				Auto Hidden
CombatStyle				Property CurrentCombatStyle				Auto Hidden

Int[]					Property OPTIONLIST_CHARACTER 			Auto Hidden
Int 					Property OPTION_MENU_CHAR_PICKER 		Auto Hidden
Int 					Property OPTION_MENU_SID_PICKER 		Auto Hidden
Int 					Property OPTION_MENU_CHAR_VOICETYPE		Auto Hidden

Int 					Property OPTION_TOGGLE_CHAR_TRACKING 	Auto Hidden
Int 					Property OPTION_TEXT_CHAR_STATS 		Auto Hidden
Int 					Property OPTION_TEXT_CHAR_MAGIC 		Auto Hidden
Int 					Property OPTION_TEXT_BACK				Auto Hidden

; === Variables ===--

Int[] 					iShoutOptions

; === Events/Functions ===--

Int Function GetVersion()
    return 190
EndFunction

Event OnVersionUpdate(int a_version)
	If CurrentVersion < 190
		OnConfigInit()
		Debug.Trace("vFF/MCM: Updating script to version 190...")
	EndIf
EndEvent

Event OnConfigInit()
	ModName = "$Familiar Faces"
	Pages = New String[5]
	Pages[0] = "$Character Setup"
	Pages[1] = "$Shrine of Heroes"
	Pages[2] = "$Hangout Manager"
	Pages[3] = "$Global Options"
	Pages[4] = "$Debugging"


	CreatePanel("PANEL_CHAR_PICKER","$Character Picker")
	CreatePanel("PANEL_CHAR_OPTIONS","$Character Options","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_INFO","$Character Info","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_OPTIONS_STATS","$Character Stats","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_OPTIONS_MAGIC","$Magic and Shouts","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_OPTIONS_EQUIP","$Equipment","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_OPTIONS_BEHAVIOR","$Behavior","PANEL_CHAR_PICKER")
	CreatePanel("PANEL_CHAR_OPTIONS_COMBAT","$Combat behavior","PANEL_CHAR_OPTIONS_BEHAVIOR")
	CreatePanel("PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL","$Magic by school","PANEL_CHAR_OPTIONS_MAGIC")
	CreatePanel("PANEL_CHAR_OPTIONS_SHOUTS_MANAGE","$Manage Shouts","PANEL_CHAR_OPTIONS_MAGIC")

EndEvent

Event OnConfigOpen()
	DoInit()
EndEvent

Event OnPageReset(string a_page)
	
	; === Handle Logo ===--
	If (a_page == "")
        LoadCustomContent("vMYC_fflogo.dds")
        Return
    Else
        UnloadCustomContent()
    EndIf

	; === Handle other pages ===--
	If a_page == Pages[0]
		If !TopPanel()
			PushPanel("PANEL_CHAR_PICKER")
			PushPanel("PANEL_CHAR_INFO")
		EndIf
	Else

	EndIf
	DisplayPanels()
EndEvent




; === Panel display functions ===--

State PANEL_CHAR_PICKER

	Event OnPanelAdd(Int aiLeftRight)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)

		AddMenuOptionST("OPTION_MENU_CHAR_PICKER","$Settings for",CurrentCharacterName)

		If !CurrentCharacterName
			DebugTrace("No CharacterName selected!")
			Return
		EndIf

		String[] sSIDs = vFF_API_Character.GetSIDsByName(CurrentCharacterName)
		If sSIDs.Length == 1
			CurrentSID = sSIDs[0]
			ShowOptions_SIDPicker(aiLeftRight,True)
		ElseIf sSIDs.Length > 1
			CurrentSID = sSIDs[0]
			ShowOptions_SIDPicker(aiLeftRight)
		Else
			DebugTrace("No SIDs found for " + CurrentCharacterName,1)
			AddTextOption("$Error:","No data found!")
			Return
		EndIf
		AddEmptyOption()
		AddPanelLinkOption("PANEL_CHAR_INFO","$Character Info")
		AddPanelLinkOption("PANEL_CHAR_OPTIONS_BEHAVIOR","$Faction and behavior")
		AddPanelLinkOption("PANEL_CHAR_OPTIONS_STATS","$Skills and stats")
		AddPanelLinkOption("PANEL_CHAR_OPTIONS_MAGIC","$Magic and Shouts")

	EndEvent
EndState

Function ShowOptions_SIDPicker(Int aiLeftRight, Bool abDisabled = False)
	SetCursorPosition(aiLeftRight + 2)
	AddMenuOptionST("OPTION_MENU_SID_PICKER","$Choose session:",StringUtil.Substring(CurrentSID, StringUtil.GetLength(CurrentSID) - 7),abDisabled as Int)
EndFunction

State PANEL_CHAR_OPTIONS

	Event OnPanelAdd(Int aiLeftRight)

		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)

		Int OptionFlags = 0

		AddHeaderOption(CurrentCharacterName + " Options")

		;AddToggleOptionST("OPTION_TOGGLE_CHAR_TRACKING","$Track this character", GetSessionBool("Config." + CurrentSID + ".Tracking",abUseDefault = True))
		AddEmptyOption()
		
		OptionFlags = 0

		;=== Character voicetype option ===--
		CurrentVoiceType = vFF_API_Character.GetCharacterVoiceType(CurrentSID)
		String sVoiceTypeName = DataManager.GetVoiceTypeName(CurrentVoiceType)
		If !sVoiceTypeName
			sVoiceTypeName = "Default"
		EndIf

		AddMenuOptionST("OPTION_MENU_CHAR_VOICETYPE","$VoiceType",sVoiceTypeName,OptionFlags)
		;If PanelLeft == PANEL_CHAR_OPTIONS
		;	SetCursorPosition(22)
		;	AddTextOptionST("OPTION_TEXT_BACK","$Back_button", "Character Select")
		;EndIf
	EndEvent

EndState

State PANEL_CHAR_INFO

	Event OnPanelAdd(Int aiLeftRight)
; === Begin info column ===--
		If !CurrentSID 
			Return
		EndIf
		SetCursorPosition(aiLeftRight + 6)
		
		String[] sSex 	= New String[2]
		sSex[0] 		= "Male"
		sSex[1] 		= "Female"

		AddTextOption("Level " + (vFF_API_Character.GetCharacterLevel(CurrentSID) as Int) + " " + (vFF_API_Character.GetCharacterStr(CurrentSID,".Info.RaceText")) + " " + sSex[vFF_API_Character.GetCharacterSex(CurrentSID)],"",OPTION_FLAG_DISABLED)

		AddTextOption("Health: " + (vFF_API_Character.GetCharacterAV(CurrentSID,"Health") as Int) + \
						", Stamina:" + (vFF_API_Character.GetCharacterAV(CurrentSID,"Stamina") as Int) + \
						", Magicka:" + (vFF_API_Character.GetCharacterAV(CurrentSID,"Magicka") as Int), "",OPTION_FLAG_DISABLED)

		String sWeaponName = vFF_API_Item.GetItemName(vFF_API_Character.GetCharacterEquippedFormID(CurrentSID,1))
		String sLWeaponName = vFF_API_Item.GetItemName(vFF_API_Character.GetCharacterEquippedFormID(CurrentSID,0))
		If sLWeaponName && sLWeaponName != sWeaponName
			sWeaponName += " and " + sLWeaponName
		ElseIf sLWeaponName && sLWeaponName == sWeaponName
			sWeaponName += " (Both)"
		EndIf
		AddTextOption("Wielding " + sWeaponName,"",OPTION_FLAG_DISABLED)
		AddEmptyOption()
		String sActorBaseString = "Not loaded"
		String sActorString 	= "Not loaded"
		Actor kActor = vFF_API_Doppelganger.GetActorForSID(CurrentSID)
		If kActor 
			sActorBaseString 	= GetFormIDString(kActor.GetActorBase())
			sActorString 		= GetFormIDString(kActor)
		EndIf
		AddTextOption("ActorBase: " + sActorBaseString,"",OPTION_FLAG_DISABLED)
		AddTextOption("Actor: " + sActorString,"",OPTION_FLAG_DISABLED)

		If !kActor
			AddTextOptionST("OPTION_TEXT_CHAR_SUMMON", "Summon me", "right now!")
		EndIf
		;Int MissingReqs = CharacterManager.CheckModReqs(_sCharacterName)
		;If MissingReqs == 3
		;	AddEmptyOption()
		;	OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$critical} {$mods} !","$Report")
		;ElseIf MissingReqs == 2
		;	AddEmptyOption()
		;	OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$equipment} {$mods} !","$Report")
		;ElseIf MissingReqs == 1
		;	AddEmptyOption()
		;	OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$minor} {$mods} !","$Report")
		;Else
		;	AddEmptyOption()
		;	OPTION_TEXT_MODREQREPORT = AddTextOption("{$View mod requirements}","$Report")
		;EndIf
		;===== END info column =============----
	EndEvent

EndState

State PANEL_CHAR_OPTIONS_BEHAVIOR

	Event OnPanelAdd(Int aiLeftRight)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)
		AddHeaderOption("$Factions")
		AddEmptyOption()
		Int 	iPlayerRelationship	= GetSessionInt("Config." + CurrentSID + ".Behavior.PlayerRelationship") + 1 ; -1 is Foe but arrays can't have negative indicies
		Bool 	bVanish				= GetSessionBool("Config." + CurrentSID + ".Behavior.VanishOnDeath")

		AddTextOptionST("OPTION_TEXT_CHAR_PLAYERRELATIONSHIP", "$Player relationship", ENUM_CHAR_PLAYERRELATIONSHIP[iPlayerRelationship])
		AddEmptyOption()
		AddHeaderOption("$Behavior")
		AddEmptyOption()
		AddHeaderOption("$Combat")
		CurrentCombatStyle = vFF_API_Character.GetCharacterCombatStyle(CurrentSID)
		String sCombatStyleName = JFormMap.GetStr(GetRegObj("CombatStyles.FormMap"),CurrentCombatStyle)
		If !sCombatStyleName
			sCombatStyleName = "$Unknown"
		EndIf
		AddMenuOptionST("OPTION_TEXT_CHAR_COMBATSTYLE", "$CombatStyle", sCombatStyleName)

	EndEvent
EndState

State PANEL_CHAR_OPTIONS_STATS

	Event OnPanelAdd(Int aiLeftRight)
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)
		AddHeaderOption("$Stats and Skills")
		AddEmptyOption()
		AddEmptyOption()
		AddHeaderOption("$Skill settings")

	EndEvent

EndState

State PANEL_CHAR_OPTIONS_MAGIC

	Event OnPanelAdd(Int aiLeftRight)

		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)
		AddHeaderOption("{$Magic and Shouts}")

		Bool bAutoMagic 		= GetSessionBool("Config." + CurrentSID + ".Magic.AutoByPerks",True)
		Bool bAllowHealing 		= GetSessionBool("Config." + CurrentSID + ".Magic.AllowHealing",True)
		Bool bAllowDefense 		= GetSessionBool("Config." + CurrentSID + ".Magic.AllowDefense",True)
		Bool bBlockWallOfs 		= GetSessionBool("Config." + CurrentSID + ".Magic.BlockWallOfs",True)

		AddToggleOptionST("OPTION_TOGGLE_CHAR_MAGIC_AUTOBYPERKS","$Auto select spells by perks",bAutoMagic)
		AddPanelLinkOption("PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL", "$Choose allowed magic", Math.LogicalAnd(OPTION_FLAG_DISABLED,bAutoMagic as Int))
		AddEmptyOption()
		AddToggleOptionST("OPTION_TOGGLE_CHAR_MAGIC_ALLOWHEALING","$Always allow healing",bAllowHealing)
		AddToggleOptionST("OPTION_TOGGLE_CHAR_MAGIC_ALLOWDEFENSE","$Always allow defense",bAllowDefense)
		AddToggleOptionST("OPTION_TOGGLE_CHAR_MAGIC_BLOCKWALLOFS","$Always disable walls",bBlockWallOfs)

		AddEmptyOption()

		AddHeaderOption("$Shout settings")

		Bool bDisableShouts 	= GetSessionBool("Config." + CurrentSID + ".Shouts.Disabled")

		AddToggleOptionST("OPTION_TOGGLE_CHAR_SHOUTS_DISABLED","{$Disable} {$Shouts}",bDisableShouts)
		AddPanelLinkOption("PANEL_CHAR_OPTIONS_SHOUTS_MANAGE", "$Choose allowed Shouts", Math.LogicalAnd(OPTION_FLAG_DISABLED,bDisableShouts as Int))
		;AddTextOptionST("OPTION_TEXT_CHAR_SHOUTS_MANAGE","$Choose allowed Shouts","$More_button",OptionFlags)
		; AddEmptyOption()
		;If PanelLeft == PANEL_CHAR_OPTIONS_MAGIC
		;	SetCursorPosition(22)
		;	AddTextOptionST("OPTION_TEXT_BACK","$Back_button", "Character Options")
		;EndIf
	EndEvent
EndState

State PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL

	Event OnPanelAdd(Int aiLeftRight)

	SetCursorFillMode(TOP_TO_BOTTOM)
	
	SetCursorPosition(aiLeftRight)
	AddHeaderOption("{$Magic Allowed}")
	Int OptionFlags = 0

	; If !CharacterManager.GetLocalInt(_sCharacterName,"Compat_AFT_Tweaked")
	; 	Bool bAutoMagic = CharacterManager.GetLocalInt(_sCharacterName,"MagicAutoSelect") as Bool
	AddToggleOptionST("OPTION_TOGGLE_MAGICALLOW_ALTERATION","{$Allow} {$Alteration}",GetSessionBool("Config." + CurrentSID + ".Magic.AllowAlteration",OptionFlags))
	AddToggleOptionST("OPTION_TOGGLE_MAGICALLOW_CONJURATION","{$Allow} {$Conjuration}",GetSessionBool("Config." + CurrentSID + ".Magic.AllowConjuration",OptionFlags))
	AddToggleOptionST("OPTION_TOGGLE_MAGICALLOW_DESTRUCTION","{$Allow} {$Destruction}",GetSessionBool("Config." + CurrentSID + ".Magic.AllowDestruction",OptionFlags))
	AddToggleOptionST("OPTION_TOGGLE_MAGICALLOW_ILLUSION","{$Allow} {$Illusion}",GetSessionBool("Config." + CurrentSID + ".Magic.AllowIllusion",OptionFlags))
	AddToggleOptionST("OPTION_TOGGLE_MAGICALLOW_RESTORATION","{$Allow} {$Restoration}",GetSessionBool("Config." + CurrentSID + ".Magic.AllowRestoration",OptionFlags))

	;OPTION_TOGGLE_MAGICALLOW_OTHER			= AddToggleOption(" {$Allow} {$Other}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowOther") as Bool)


	EndEvent
EndState

State PANEL_CHAR_OPTIONS_SHOUTS_MANAGE

	Event OnPanelAdd(Int aiLeftRight)

		SetCursorFillMode(TOP_TO_BOTTOM)
		
		SetCursorPosition(aiLeftRight)
		AddHeaderOption("{$Shouts Allowed}")
		Int OptionFlags = 0

		Int jShoutsArray 	= GetRegObj("Characters." + CurrentSID + ".Shouts")
		Int jShoutsBL		= GetSessionObj("Config." + CurrentSID + ".Shouts.Blacklist")
		Int iShoutCount = JArray.Count(jShoutsArray)

		iShoutOptions = Utility.CreateIntArray(iShoutCount)

		Int i = 0
		While i < iShoutCount
			Shout kShout = JArray.GetForm(jShoutsArray,i) as Shout
			Bool bEnabled = True
			If jShoutsBL
				If JArray.FindForm(jShoutsBL,kShout) >= 0
					bEnabled = False
				EndIf
			EndIf
			iShoutOptions[i] = AddToggleOption(kShout.GetName(), bEnabled)
			i += 1
		EndWhile

	EndEvent
EndState

; == Text: Summon character ===--
State OPTION_TEXT_CHAR_SUMMON
	Event OnSelectST()
		vFF_API_Doppelganger.CreateDoppelganger(CurrentSID,False).MoveTo(Game.GetPlayer())
		ForcePageReset()
	EndEvent
EndState

; == Menu: Character Picker ===--
State OPTION_MENU_CHAR_PICKER

	Event OnMenuOpenST()
		SetMenuDialogOptions(CharacterNames)
		Int iCharacterNameIdx = CharacterNames.Find(CurrentCharacterName)
		If iCharacterNameIdx < 0
			iCharacterNameIdx = 0
		EndIf
		SetMenuDialogStartIndex(iCharacterNameIdx)
		SetMenuDialogDefaultIndex(iCharacterNameIdx)
	EndEvent

	Event OnMenuAcceptST(Int aiIndex)
		String sCharacterName = CharacterNames[aiIndex]
		If sCharacterName
			CurrentCharacterName = sCharacterName
		Else
			DebugTrace("OPTION_MENU_CHAR_PICKER: No character name found for index " + aiIndex + "!")
		EndIf
		ForcePageReset()
	EndEvent

EndState

; == Toggle: Character Tracking ===--
State OPTION_TOGGLE_CHAR_TRACKING

	Event OnSelectST()

	EndEvent

EndState

; == Menu: CombatStyle picker ===--
State OPTION_TEXT_CHAR_COMBATSTYLE

	Event OnMenuOpenST()
		SetMenuDialogOptions(CombatStyleNames)
		Int idxCS = CombatStyleList.Find(CurrentCombatStyle)
		SetMenuDialogStartIndex(idxCS)
		SetMenuDialogDefaultIndex(0)
	EndEvent
	
	Event OnMenuAcceptST(Int aiIndex)
		vFF_API_Character.SetCharacterCombatStyle(CurrentSID,CombatStyleList[aiIndex] as CombatStyle)
		SetSessionForm("Config." + CurrentSID + ".CombatStyle",CombatStyleList[aiIndex] as CombatStyle) ;FIXME: UGLY, are we setting Session or Registry data here?
		SetMenuOptionValueST(CombatStyleNames[aiIndex], false, GetState())
		;ForcePageReset()
	EndEvent

EndState

; == Option: Set character relationship ===--
State OPTION_TEXT_CHAR_PLAYERRELATIONSHIP

	Event OnSelectST()
		Int iPlayerRelationship	= GetSessionInt("Config." + CurrentSID + ".Behavior.PlayerRelationship") + 1 ; -1 is Foe but arrays can't have negative indicies
		iPlayerRelationship += 1
		If iPlayerRelationship >= ENUM_CHAR_PLAYERRELATIONSHIP.Length
			iPlayerRelationship = 0
		EndIf
		SetSessionInt("Config." + CurrentSID + ".Behavior.PlayerRelationship",iPlayerRelationship - 1)
		SetTextOptionValueST(ENUM_CHAR_PLAYERRELATIONSHIP[iPlayerRelationship], false, GetState())
	EndEvent

EndState

; == Option: Character stat/build options panel ===--
State OPTION_TEXT_CHAR_STATS

	Event OnSelectST()
		If TopPanel() != "PANEL_CHAR_OPTIONS"
			PopPanel()
		EndIf
		PushPanel("PANEL_CHAR_OPTIONS_STATS")
		ForcePageReset()
	EndEvent

EndState

; == Option: Character magic/shout options panel ===--
State OPTION_TEXT_CHAR_MAGIC

	Event OnSelectST()
		If TopPanel() != "PANEL_CHAR_OPTIONS"
			PopPanel()
		EndIf
		PushPanel("PANEL_CHAR_OPTIONS_MAGIC")
		ForcePageReset()
	EndEvent

EndState

State OPTION_TOGGLE_CHAR_MAGIC_AUTOBYPERKS
	
	Event OnSelectST()
		Bool bValue = ToggleSessionBool("Config." + CurrentSID + ".Magic.AutoByPerks")
		SetToggleOptionValueST(bValue,True,GetState())
		DebugTrace("OnSelectST called in " + GetState())
		SetOptionFlagsST(Math.LogicalAnd(OPTION_FLAG_DISABLED,bValue as Int), false, "PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL")
		;Handle player setting auto-select while magic panel is open
		If bValue && TopPanel() == "PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL"
			PopPanel()
			ForcePageReset()
		EndIf
	EndEvent

EndState

State OPTION_TOGGLE_CHAR_MAGIC_ALLOWHEALING
	
	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowHealing"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_CHAR_MAGIC_ALLOWDEFENSE
	
	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowDefense"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_CHAR_MAGIC_BLOCKWALLOFS

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.BlockWallOfs"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_MAGICALLOW_ALTERATION

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowAlteration"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_MAGICALLOW_DESTRUCTION

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowDestruction"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_MAGICALLOW_ILLUSION

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowIllusion"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_MAGICALLOW_CONJURATION

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowConjuration"),False,GetState())
	EndEvent

EndState

State OPTION_TOGGLE_MAGICALLOW_RESTORATION

	Event OnSelectST()
		SetToggleOptionValueST(ToggleSessionBool("Config." + CurrentSID + ".Magic.AllowRestoration"),False,GetState())
	EndEvent

EndState

; == Option: Character magic by school panel ===--
State OPTION_TEXT_CHAR_MAGIC_BYSCHOOL

	Event OnSelectST()
		If TopPanel() != "PANEL_CHAR_OPTIONS_MAGIC"
			PopPanel()
		EndIf
		PushPanel("PANEL_CHAR_OPTIONS_MAGIC_BYSCHOOL")
		ForcePageReset()
	EndEvent

EndState

; == Option: Character shout master disable ===--
State OPTION_TOGGLE_CHAR_SHOUTS_DISABLED

	Event OnSelectST()
		Bool bDisabled = ToggleSessionBool("Config." + CurrentSID + ".Shouts.Disabled")
		SetToggleOptionValueST(bDisabled,False,GetState())
		SetOptionFlagsST(Math.LogicalAnd(OPTION_FLAG_DISABLED,bDisabled as Int), false, "PANEL_CHAR_OPTIONS_SHOUTS_MANAGE")
		
		;Handle player disabling shouts while shout management panel is open
		If bDisabled && TopPanel() == "PANEL_CHAR_OPTIONS_SHOUTS_MANAGE"
			PopPanel()
			ForcePageReset()
		EndIf
	EndEvent

EndState

; == Option: Character shout management panel ===--
State OPTION_TEXT_CHAR_SHOUTS_MANAGE

	Event OnSelectST()
		If TopPanel() != "PANEL_CHAR_OPTIONS_MAGIC"
			PopPanel()
		EndIf
		PushPanel("PANEL_CHAR_OPTIONS_SHOUTS_MANAGE")
		ForcePageReset()
	EndEvent

EndState

; == Menu: Character Voicetype  ===--
State OPTION_MENU_CHAR_VOICETYPE
	
	Event OnMenuOpenST()
		SetMenuDialogOptions(VoiceTypeLegends)
		Int idxVT = VoiceTypeList.Find(CurrentVoiceType) + 1
		SetMenuDialogStartIndex(idxVT)
		SetMenuDialogDefaultIndex(0)
	EndEvent
	
	Event OnMenuAcceptST(Int aiIndex)
		vFF_API_Character.SetCharacterVoiceType(CurrentSID,VoiceTypeList[aiIndex] as VoiceType)
		SetMenuOptionValueST(VoiceTypeNames[aiIndex], false, GetState())
		;ForcePageReset()
	EndEvent

EndState

Event OnOptionSelect(int a_option)
	;A few options really aren't suited for states, so handle them here
	If iShoutOptions.Find(a_option) >= 0
		Int iShoutIndex = iShoutOptions.Find(a_option)

		Int jShoutsArray 	= GetRegObj("Characters." + CurrentSID + ".Shouts")
		Int jShoutsBL		= GetSessionObj("Config." + CurrentSID + ".Shouts.Blacklist")
		If !jShoutsBL
			jShoutsBL = JArray.Object()
			SetSessionObj("Config." + CurrentSID + ".Shouts.Blacklist",jShoutsBL)
		EndIf
		Shout kShout 		= JArray.GetForm(jShoutsArray,iShoutIndex) as Shout
		Int iBLIndex 		= JArray.FindForm(jShoutsBL,kShout)
		If iBLIndex >= 0 ; Remove this Shout from the blacklist
			SetToggleOptionValue(a_option, True)
			JArray.EraseIndex(jShoutsBL,iBLIndex)
			JArray.Unique(jShoutsBL)
		Else ; Add this Shout to the blacklist
			SetToggleOptionValue(a_option, False)
			JArray.AddForm(jShoutsBL,kShout)
			JArray.Unique(jShoutsBL)
		EndIf
		SetSessionObj("Config." + CurrentSID + ".Shouts.Blacklist",jShoutsBL)
	EndIf
EndEvent

Function DoInit()
	FillEnums()
	CharacterNames = vFF_API_Character.GetAllNames()
	GetVoiceTypeList()
	GetCombatStyleList()
EndFunction



Function FillEnums()

	ENUM_CHAR_ARMORCHECK 				= New String[3]
	ENUM_CHAR_ARMORCHECK[0]					= "$When missing"
	ENUM_CHAR_ARMORCHECK[1]					= "$Always"
	ENUM_CHAR_ARMORCHECK[2]					= "$Disable"

	ENUM_GLOBAL_MAGIC_OVERRIDES			= New String[3]
	ENUM_GLOBAL_MAGIC_OVERRIDES[0]			= "$None"
	ENUM_GLOBAL_MAGIC_OVERRIDES[1]			= "$Healing"
	ENUM_GLOBAL_MAGIC_OVERRIDES[2]			= "$Healing/Defense"

	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS		= New String[3]
	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS[0]		= "$Vanilla only"
	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS[1]		= "$Select mods"
	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS[2]		= "$All mods"
	
	ENUM_GLOBAL_SHOUTS_HANDLING			= New String[5]
	ENUM_GLOBAL_SHOUTS_HANDLING[0]			= "$All"
	ENUM_GLOBAL_SHOUTS_HANDLING[1]			= "$All but CS"
	ENUM_GLOBAL_SHOUTS_HANDLING[2]			= "$All but DA"
	ENUM_GLOBAL_SHOUTS_HANDLING[3]			= "$All but CS/DA"
	ENUM_GLOBAL_SHOUTS_HANDLING[4]			= "$No Shouts"
	
	ENUM_GLOBAL_FILE_LOCATION			= New String[2]
	ENUM_GLOBAL_FILE_LOCATION[0]			= "$Data/vFFC"
	ENUM_GLOBAL_FILE_LOCATION[1]			= "$My Games/Skyrim"
	

	ENUM_CHAR_PLAYERRELATIONSHIP		= New String[5]
	ENUM_CHAR_PLAYERRELATIONSHIP[0]			= "$Archenemy"
	ENUM_CHAR_PLAYERRELATIONSHIP[1]			= "$Neutral"
	ENUM_CHAR_PLAYERRELATIONSHIP[2]			= "$Friendly"
	ENUM_CHAR_PLAYERRELATIONSHIP[3]			= "$Follower"
	ENUM_CHAR_PLAYERRELATIONSHIP[4]			= "$CanMarry"
EndFunction

; === Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/MCMPanel: " + sDebugString,iSeverity)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

String Function GetPrettyTime(String asTimeInMinutes)
	Float fTimeInMinutes = asTimeInMinutes as Float
	Int iMinutes = Math.Floor(fTimeInMinutes)
	Int iSeconds = Math.Floor((fTimeInMinutes - iMinutes) * 60)
	String sZero = ""
	If iSeconds < 10
		sZero = "0"
	EndIf
	String sPrettyTime = iMinutes + ":" + sZero + iSeconds
	Return sPrettyTime
EndFunction

Function GetVoiceTypeList()
	String[] sRawVoiceTypeList = DataManager.JObjToArrayStr(GetRegObj("VoiceTypes.Names"))
	Int i = sRawVoiceTypeList.Length
	DebugTrace("Retrieved " + i + " VoiceTypes, creating string lists...")
	VoiceTypeList = Utility.CreateFormArray(i + 1)
	VoiceTypeNames = Utility.CreateStringArray(i + 1,"Default")
	VoiceTypeLegends = Utility.CreateStringArray(i + 1,"")
	While i > 0
		i -= 1
		String sVTName = sRawVoiceTypeList[i]
		String sLegend = ""
		If GetRegBool("VoiceTypes.Info." + sVTName + ".Follower")
			sLegend += "Follower"
		EndIf
		If GetRegBool("VoiceTypes.Info." + sVTName + ".Spouse")
			If sLegend
				sLegend += ","
			EndIf
			sLegend += "Spouse"
		EndIf
		If GetRegBool("VoiceTypes.Info." + sVTName + ".Adopt")
			If sLegend
				sLegend += ","
			EndIf
			sLegend += "Adoption"
		EndIf
		VoiceTypeList[i + 1] = GetRegForm("VoiceTypes.Info." + sVTName + ".Form") as VoiceType
		VoiceTypeNames[i + 1] = sVTName
		String sSpacer = "                                                " ;48 spaces
		;If sLegend
			
			sSpacer = StringUtil.Substring(sSpacer, 0, 48 - StringUtil.GetLength(sVTName + "(" + sLegend + ")"))
			VoiceTypeLegends[i + 1] = sVTName + sSpacer + "(" + sLegend + ")"
		;Else
		;	VoiceTypeLegends[i + 1] = sVTName + sSpacer 
		;EndIf
		DebugTrace("Processed " + sVTName + "!")
	EndWhile

	VoiceTypeList[0] = None
	VoiceTypeNames[0] = "Default"
	VoiceTypeLegends[0] = "Default"
EndFunction

Function GetCombatStyleList()
	CombatStyleNames = DataManager.JObjToArrayStr(GetRegObj("CombatStyles.Names"))
	Int i = CombatStyleNames.Length
	CombatStyleList = Utility.CreateFormArray(i)
	While i > 0
		i -= 1
		CombatStyleList[i] = GetRegForm("CombatStyles.Map." + CombatStyleNames[i])
	EndWhile
EndFunction

