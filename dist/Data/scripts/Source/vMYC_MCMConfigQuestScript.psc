Scriptname vMYC_MCMConfigQuestScript extends SKI_ConfigBase
{MCM config script for Familiar Faces 2.0.}

; === [ vMYC_MCMConfigQuestScript.psc ] ===================================---
; MCM config script. Pretty standard stuff, but probably way more complex than
; average due to the huge amount of data that is being managed here.
; ========================================================---

; === Imports ===--

Import vMYC_Registry
Import vMYC_Session

; === Constants ===--

; === Enums ===--

String[] Property	ENUM_CHAR_ARMORCHECK					Auto Hidden

String[] Property	ENUM_GLOBAL_MAGIC_OVERRIDES				Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS		    Auto Hidden
String[] Property	ENUM_GLOBAL_SHOUTS_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_FILE_LOCATION			    Auto Hidden


; === Properties ===--

vMYC_MetaQuestScript 	Property MetaQuest 					Auto
vMYC_DataManager 		Property DataManager 				Auto
vMYC_ShrineManager 		Property ShrineManager 				Auto

; === Properties: Character Page ===--

String[] 				Property CharacterNames 			Auto Hidden
String 					Property CurrentCharacterName		Auto Hidden
String 					Property CurrentSID		 			Auto Hidden

Int[]					Property OPTIONLIST_CHARACTER 		Auto Hidden
Int 					Property OPTION_MENU_CHAR_PICKER 	Auto Hidden
Int 					Property OPTION_MENU_SID_PICKER 	Auto Hidden

; === Variables ===--


; === Events/Functions ===--

Int Function GetVersion()
    return 190
EndFunction

Event OnVersionUpdate(int a_version)
	If CurrentVersion < 190
		OnConfigInit()
		Debug.Trace("MYC/MCM: Updating script to version 190...")
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
		ShowOptions_CharacterSetup(0)
	Else

	EndIf
EndEvent








; === Page display functions ===--

Function ShowOptions_CharacterSetup(Int aiLeftRight)
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	SetCursorPosition(aiLeftRight)

	OPTION_MENU_CHAR_PICKER = AddMenuOption("$Settings for",CurrentCharacterName)

	If !CurrentCharacterName
		DebugTrace("No CharacterName selected!")
		Return
	EndIf

	String[] sSIDs = vMYC_API_Character.GetSIDsByName(CurrentCharacterName)
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

	; === Begin info column ===--
	
	SetCursorPosition(aiLeftRight + 6)
	
	String[] sSex 	= New String[2]
	sSex[0] 		= "Male"
	sSex[1] 		= "Female"

	AddTextOption("Level " + (vMYC_API_Character.GetCharacterLevel(CurrentSID) as Int) + " " + (vMYC_API_Character.GetCharacterStr(CurrentSID,".Info.RaceText")) + " " + sSex[vMYC_API_Character.GetCharacterSex(CurrentSID)],"",OPTION_FLAG_DISABLED)

	AddTextOption("Health: " + (vMYC_API_Character.GetCharacterAV(CurrentSID,"Health") as Int) + \
					", Stamina:" + (vMYC_API_Character.GetCharacterAV(CurrentSID,"Stamina") as Int) + \
					", Magicka:" + (vMYC_API_Character.GetCharacterAV(CurrentSID,"Magicka") as Int), "",OPTION_FLAG_DISABLED)

	String sWeaponName = vMYC_API_Item.GetItemName(vMYC_API_Character.GetCharacterEquippedFormID(CurrentSID,1))
	String sLWeaponName = vMYC_API_Item.GetItemName(vMYC_API_Character.GetCharacterEquippedFormID(CurrentSID,0))
	If sLWeaponName && sLWeaponName != sWeaponName
		sWeaponName += " and " + sLWeaponName
	ElseIf sLWeaponName && sLWeaponName == sWeaponName
		sWeaponName += " (Both)"
	EndIf
	AddTextOption("Wielding " + sWeaponName,"",OPTION_FLAG_DISABLED)
	AddEmptyOption()
	String sActorBaseString = "Not loaded"
	String sActorString 	= "Not loaded"
	Actor kActor = vMYC_API_Doppelganger.GetActorForSID(CurrentSID)
	If kActor 
		sActorBaseString 	= GetFormIDString(kActor.GetActorBase())
		sActorString 		= GetFormIDString(kActor)
	EndIf
	AddTextOption("ActorBase: " + sActorBaseString,"",OPTION_FLAG_DISABLED)
	AddTextOption("Actor: " + sActorString,"",OPTION_FLAG_DISABLED)
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

EndFunction

Function ShowOptions_SIDPicker(Int aiLeftRight, Bool abDisabled = False)
	SetCursorPosition(aiLeftRight + 2)
	OPTION_MENU_SID_PICKER = AddMenuOption("$Choose session:",CurrentSID,abDisabled as Int)
EndFunction

Event OnOptionSelect(Int Option)

EndEvent

Event OnOptionMenuOpen(int a_option)
	If a_option == OPTION_MENU_CHAR_PICKER
		CHAR_PICKER_MO(a_option)
	EndIf
EndEvent

Event OnOptionMenuAccept(int a_option, int a_index)
	If a_option == OPTION_MENU_CHAR_PICKER
		CHAR_PICKER_MA(a_option, a_index)
	EndIf
EndEvent

; == Menu: Character Picker ===--

Function CHAR_PICKER_MO(Int aiOption)
	SetMenuDialogOptions(CharacterNames)
	Int iCharacterNameIdx = CharacterNames.Find(CurrentCharacterName)
	If iCharacterNameIdx < 0
		iCharacterNameIdx = 0
	EndIf
	SetMenuDialogStartIndex(iCharacterNameIdx)
	SetMenuDialogDefaultIndex(iCharacterNameIdx)
EndFunction

Function CHAR_PICKER_MA(Int aiOption, Int aiIndex)
{Character picker menu}
	String sCharacterName = CharacterNames[aiIndex]
	If sCharacterName
		CurrentCharacterName = sCharacterName
	Else
		DebugTrace("CHAR_PICKER_MA: No character name found for index " + aiIndex + "!")
	EndIf
	ForcePageReset()
EndFunction









Function DoInit()
	FillEnums()
	CharacterNames = vMYC_API_Character.GetAllNames()

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
	ENUM_GLOBAL_FILE_LOCATION[0]			= "$Data/vMYC"
	ENUM_GLOBAL_FILE_LOCATION[1]			= "$My Games/Skyrim"
	
EndFunction

; === Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/MCMPanel: " + sDebugString,iSeverity)
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
