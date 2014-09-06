Scriptname vMYC_MCMQuestScript extends SKI_ConfigBase

Import vMYC_Config

vMYC_MetaQuestScript Property MetaQuestScript Auto
vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto
vMYC_HangoutManager	Property HangoutManager Auto

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto

Int Property	VOICETYPE_NOFILTER  = 0	AutoReadOnly Hidden
Int Property	VOICETYPE_FOLLOWER  = 1	AutoReadOnly Hidden
Int Property	VOICETYPE_SPOUSE 	= 2	AutoReadOnly Hidden
Int Property	VOICETYPE_ADOPT 	= 4	AutoReadOnly Hidden
Int Property	VOICETYPE_GENDER	= 8 AutoReadOnly Hidden

Int Property	OPTION_TEXT_MODREQREPORT				Auto Hidden

Int Property	OPTION_TOGGLE_DISABLE_AUTOLEVEL			Auto Hidden

Int Property	OPTION_TOGGLE_TRACKING					Auto Hidden

Int Property 	OPTION_MENU_CHARACTER_HANGOUT			Auto Hidden

Int Property	OPTION_TOGGLE_MAGICALLOW_AUTOSELECT		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_ALTERATION		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_CONJURATION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_ILLUSION		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_DESTRUCTION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_RESTORATION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_OTHER			Auto Hidden

Int Property	OPTION_TOGGLE_SHOUTSALLOW_MASTER			Auto Hidden

Int Property	OPTION_MENU_HANGOUT_SELECT					Auto Hidden
Int Property	OPTION_TOGGLE_HANGOUT_ENABLE				Auto Hidden
Int Property	OPTION_TOGGLE_HANGOUT_CLEAR					Auto Hidden
Int Property	OPTION_TOGGLE_HANGOUT_CLEARALL				Auto Hidden
Int Property	OPTION_TOGGLE_HANGOUT_PARTY					Auto Hidden

Int[] Property	OPTION_MENU_ALCOVE_CHARACTER				Auto Hidden
Int[] Property	OPTION_TOGGLE_ALCOVE_SUMMONED				Auto Hidden

Int Property	OPTION_TOGGLE_GLOBAL_TRACKBYDEFAULT			Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_TRACK_STOPONRECRUIT	Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_SWAP_FOLLOWER_VOICE	Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_AUTOLEVEL_CHARACTERS	Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_WARNING_MISSINGMOD		Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_DELETE_MISSING			Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS		Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_SHOUTS_DISABLE_CITIES	Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED	Auto Hidden
Int Property	OPTION_TOGGLE_GLOBAL_MCM_REMEMBER_PAGE		Auto Hidden

Int Property	OPTION_TEXT_GLOBAL_MAGIC_OVERRIDES			Auto Hidden
Int Property	OPTION_TEXT_GLOBAL_MAGIC_HANDLING			Auto Hidden
Int Property	OPTION_TEXT_GLOBAL_MAGIC_ALLOWFROMMODS		Auto Hidden
Int Property	OPTION_TEXT_GLOBAL_SHOUTS_HANDLING			Auto Hidden
Int Property	OPTION_TEXT_GLOBAL_FILE_LOCATION			Auto Hidden

String[] Property	ENUM_GLOBAL_MAGIC_OVERRIDES				Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS		    Auto Hidden
String[] Property	ENUM_GLOBAL_SHOUTS_HANDLING			    Auto Hidden
String[] Property	ENUM_GLOBAL_FILE_LOCATION			    Auto Hidden
					
Int Property	OPTION_DEBUG_SHUTDOWN						Auto Hidden
Int Property	OPTION_DEBUG_CHARACTER_FORCEREFRESH			Auto Hidden
Int Property	OPTION_DEBUG_HANGOUTS_RESETQUESTS			Auto Hidden
Int Property	OPTION_DEBUG_SHRINE_RESET					Auto Hidden
Int Property	OPTION_DEBUG_SHRINE_DISABLE_BG_VALIDATION	Auto Hidden


Bool _Changed
Bool _Shutdown

Bool _bShowDebugOptions

String 	_sCurrentPage

String[] _sCharacterNames

String[] _sVoiceTypesFiltered
Int		 _iVoiceTypeFilter

String[] _sVoiceTypesAll

VoiceType[] _kVoiceTypesFiltered
VoiceType[] _kVoiceTypesAll

Int		_iCurrentCharacter
String	_sCharacterName

Int		OPTION_MENU_CHAR_PICKER

Int		_iCharacterEnabledOption
Bool[]	_bCharacterEnabled

Int		OPTION_TOGGLE_CHAR_ISFOE

Int		OPTION_TOGGLE_CHAR_CANMARRY

Int		OPTION_MENU_CHAR_VOICETYPE
Int[]	_iVoiceTypeSelections

Int[]	_iAliasSelections
ReferenceAlias[]	_kHangoutRefAliases
String[]	_sHangoutNames
String[]	_sHangoutNamesPlusWanderer
String[]	_sHangoutNamesDisabled
Int		_iCurrentHangout
String	_sHangoutName

Int 	OPTION_MENU_CHAR_CLASS
Int 	_iClassSelection
String[] _sClassNames

Int		_iMagicAutoSelectOption
Int[]	_iMagicSchoolOptions

Int		OPTION_WARPTOCHARACTER

Int[]		_iAlcoveIndices
Int[]		_iAlcoveStates
String[]	_sAlcoveStateEnum
String[] 	_sAlcoveCharacterNames
Int[]		_iAlcoveResetOption

Int		OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS

Int 	_iCurrentHangoutOption

Bool 	_bConfigClosed

Int Function GetVersion()
    return 12 ; Default version
EndFunction

Event OnVersionUpdate(int a_version)
	If CurrentVersion < 12
		OnConfigInit()
		;Debug.Trace("MYC/MCM: Updating script to version 12...")
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

	_bCharacterEnabled	= New Bool[128]
	_sCharacterNames = New String[128]
	_iVoiceTypeSelections = New Int[128]
	_iAliasSelections = New Int[128]

	_iMagicSchoolOptions = New Int[6]

	_iAlcoveIndices 		= New Int[12]
	_iAlcoveStates			= New Int[12]
	_sAlcoveCharacterNames	= New String[12]

	_sAlcoveStateEnum		= New String[5]
	_sAlcoveStateEnum[0]	= "$Empty"
	_sAlcoveStateEnum[1]	= "$Busy"
	_sAlcoveStateEnum[2] 	= "$Ready"
	_sAlcoveStateEnum[3] 	= "$Summoned"
	_sAlcoveStateEnum[4] 	= "$Error"

	OPTION_MENU_ALCOVE_CHARACTER	= New Int[12]
	OPTION_TOGGLE_ALCOVE_SUMMONED	= New Int[12]
	_iAlcoveResetOption		= New Int[12]

	FilterVoiceTypes(VOICETYPE_NOFILTER)
	FillEnums()
EndEvent

Function FillEnums()

	ENUM_GLOBAL_MAGIC_OVERRIDES	= New String[3]
	ENUM_GLOBAL_MAGIC_OVERRIDES[0]	= "$None"
	ENUM_GLOBAL_MAGIC_OVERRIDES[1]	= "$Healing"
	ENUM_GLOBAL_MAGIC_OVERRIDES[2]	= "$Healing/Defense"

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

Function FilterVoiceTypes(Int iVoiceTypeFilter = 0)
	_sVoiceTypesFiltered = New String[128]
	_kVoiceTypesFiltered = New VoiceType[128]
	Int i = 0
	Int idx = 1
	Int iListSize = CharacterManager.vMYC_VoiceTypesAllList.GetSize()
	_sVoiceTypesFiltered[0] = "Default"
	While i < iListSize
		String sFilterLegend = ""
		VoiceType kThisVoiceType = CharacterManager.vMYC_VoiceTypesAllList.GetAt(i) as VoiceType
		Bool bInclude = False
		If CharacterManager.vMYC_VoiceTypesFollowerList.Find(kThisVoiceType) > -1
			sFilterLegend = sFilterLegend + "Follower"
			bInclude = True
		EndIf
		If CharacterManager.vMYC_VoiceTypesSpouseList.Find(kThisVoiceType) > -1
			If sFilterLegend
				sFilterLegend = sFilterLegend + ","
			EndIf
			sFilterLegend = sFilterLegend + "Spouse"
			bInclude = True
		EndIf
		If CharacterManager.vMYC_VoiceTypesAdoptList.Find(kThisVoiceType) > -1
			If sFilterLegend
				sFilterLegend = sFilterLegend + ","
			EndIf
			sFilterLegend = sFilterLegend + "Adoption"
			bInclude = True
		EndIf

		If !iVoiceTypeFilter || iVoiceTypeFilter == VOICETYPE_NOFILTER
			bInclude = True
		EndIf

		If bInclude
			_kVoiceTypesFiltered[idx] = kThisVoiceType
			_sVoiceTypesFiltered[idx] = _kVoiceTypesFiltered[idx] as String
			_sVoiceTypesFiltered[idx] = StringUtil.SubString(_sVoiceTypesFiltered[idx],0,StringUtil.Find(_sVoiceTypesFiltered[idx],">") - 10)
			_sVoiceTypesFiltered[idx] = StringUtil.SubString(_sVoiceTypesFiltered[idx],StringUtil.Find(_sVoiceTypesFiltered[idx],"<") + 1)
			If sFilterLegend
				_sVoiceTypesFiltered[idx] = _sVoiceTypesFiltered[idx] + " (" + sFilterLegend + ")"
			EndIf
			;Debug.Trace("MYC: MCM: _kVoiceTypesFiltered[ " + idx + "] is " + _kVoiceTypesFiltered[idx] + " named " + _sVoiceTypesFiltered[idx])
			idx += 1
		EndIf
		i += 1
	EndWhile
	;Debug.Trace("MYC/MCM: Displaying " + idx + "/" + i + " voicetypes")
EndFunction

event OnGameReload()
    parent.OnGameReload()
endEvent

event OnPageReset(string a_page)
	String sKey = "vMYC."

	If _sCurrentPage && !a_page && GetConfigBool("MCM_REMEMBER_PAGE")
		SetTitleText(_sCurrentPage)
		a_page = _sCurrentPage
	EndIf	
	
	_sCurrentPage = a_page
	UpdateSettings()

	If (a_page == "")
        LoadCustomContent("vMYC_fflogo.dds")
        Return
    Else
        UnloadCustomContent()
    EndIf

	If a_page == "$Character Setup"

		;===== Character Setup page =====

		SetCursorFillMode(TOP_TO_BOTTOM)

		_sCharacterName = _sCharacterNames[_iCurrentCharacter]


		Int OptionFlags = 0
		;====================================----


		;===== Character header =============----
		AddHeaderOption(_sCharacterName)
		;====================================----


		;===== Character enable option ======----
		OPTION_TOGGLE_TRACKING = AddToggleOption("$Track this character",CharacterManager.GetLocalInt(_sCharacterName,"TrackingEnabled"))
		;====================================----


		;===== Character voicetype option ==----
		VoiceType kCharVoiceType = CharacterManager.GetCharacterVoiceType(_sCharacterName)

		If kCharVoiceType == None ; If no voicetype is set, pick the "default" option
			_iVoiceTypeSelections[_iCurrentCharacter] = 0
		Else
			Int iVoiceTypeIndex = _kVoiceTypesFiltered.Find(kCharVoiceType)
			_iVoiceTypeSelections[_iCurrentCharacter] = iVoiceTypeIndex
		EndIf
		String sShortVoiceType = _sVoiceTypesFiltered[_iVoiceTypeSelections[_iCurrentCharacter]]
		sShortVoiceType = StringUtil.Substring(sShortVoiceType,0,StringUtil.Find(sShortVoiceType," "))
		OPTION_MENU_CHAR_VOICETYPE = AddMenuOption("$VoiceType",sShortVoiceType,OptionFlags)

		;====================================----


		;===== Character hangout option =====----
		String sHangoutName = CharacterManager.GetLocalString(_sCharacterName,"HangoutName")
		If !sHangoutName
			sHangoutName = "$Wanderer"
		EndIf
		OPTION_MENU_CHARACTER_HANGOUT = AddMenuOption("$Hangout",sHangoutName,OptionFlags)
		;====================================----

		;===== Character class option =======----
		Bool bCharDisableAutoLevel = CharacterManager.GetLocalInt(_sCharacterName,"DisableAutoLevel")
		_iClassSelection = CharacterManager.kClasses.Find(CharacterManager.GetLocalForm(_sCharacterName,"Class") as Class)
		If CharacterManager.GetLocalInt(_sCharacterName,"Compat_AFT_Tweaked")
			OPTION_MENU_CHAR_CLASS = AddMenuOption("$Class","$Using AFT",OPTION_FLAG_DISABLED)
		ElseIf bCharDisableAutoLevel
			OPTION_MENU_CHAR_CLASS = AddMenuOption("$Class",_sClassNames[_iClassSelection],OPTION_FLAG_DISABLED)
		Else
			OPTION_MENU_CHAR_CLASS = AddMenuOption("$Class",_sClassNames[_iClassSelection],OptionFlags)
		EndIf
		If CharacterManager.GetLocalInt(_sCharacterName,"Compat_AFT_Tweaked")
			OPTION_TOGGLE_DISABLE_AUTOLEVEL = AddTextOption("$Disable autolevel","$Using AFT",OPTION_FLAG_DISABLED)
		Else
			OPTION_TOGGLE_DISABLE_AUTOLEVEL = AddToggleOption("$Disable autolevel",bCharDisableAutoLevel,OptionFlags)
		EndIf
		AddEmptyOption()
		;====================================----

		
		;===== Character faction options ====----
		Bool bIsFoe = CharacterManager.GetLocalInt(_sCharacterName,"IsFoe")
		Bool bCanMarry = CharacterManager.GetLocalInt(_sCharacterName,"CanMarry")
		Int iIsFoeOptionFlags = 0
		Int iCanMarryOptionFlags = 0
		If bCanMarry 
			iIsFoeOptionFlags = OPTION_FLAG_DISABLED
		ElseIf CharacterManager.IsCharacterFollower(_sCharacterName)
			iIsFoeOptionFlags = OPTION_FLAG_DISABLED
		EndIf
		If bIsFoe
			iCanMarryOptionFlags = OPTION_FLAG_DISABLED
		EndIf
		OPTION_TOGGLE_CHAR_ISFOE = AddToggleOption("$IsFoe",bIsFoe,iIsFoeOptionFlags)
		OPTION_TOGGLE_CHAR_CANMARRY = AddToggleOption("$CanMarry",bCanMarry,iCanMarryOptionFlags)
		;====================================----

		AddEmptyOption()
		;===== Character skill options ======----
		AddHeaderOption("$Skill settings")
		OPTION_TOGGLE_SHOUTSALLOW_MASTER = AddToggleOption("{$Allow} {$Shouts}",CharacterManager.GetLocalInt(_sCharacterName,"ShoutsAllowMaster") as Bool,OptionFlags)
		AddEmptyOption()
		
		If !CharacterManager.GetLocalInt(_sCharacterName,"Compat_AFT_Tweaked")
			Bool bAutoMagic = CharacterManager.GetLocalInt(_sCharacterName,"MagicAutoSelect") as Bool
			OPTION_TOGGLE_MAGICALLOW_AUTOSELECT		= AddToggleOption("$Auto select spells by perks",bAutoMagic,OptionFlags)
			OPTION_TOGGLE_MAGICALLOW_ALTERATION		= AddToggleOption(" {$Allow} {$Alteration}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowAlteration") as Bool,Math.LogicalOR(OptionFlags,bAutoMagic as Int))
			OPTION_TOGGLE_MAGICALLOW_CONJURATION	= AddToggleOption(" {$Allow} {$Conjuration}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowConjuration") as Bool,Math.LogicalOR(OptionFlags,bAutoMagic as Int))
			OPTION_TOGGLE_MAGICALLOW_DESTRUCTION	= AddToggleOption(" {$Allow} {$Destruction}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowDestruction") as Bool,Math.LogicalOR(OptionFlags,bAutoMagic as Int))
			OPTION_TOGGLE_MAGICALLOW_ILLUSION		= AddToggleOption(" {$Allow} {$Illusion}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowIllusion") as Bool,Math.LogicalOR(OptionFlags,bAutoMagic as Int))
			OPTION_TOGGLE_MAGICALLOW_RESTORATION	= AddToggleOption(" {$Allow} {$Restoration}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowRestoration") as Bool,Math.LogicalOR(OptionFlags,bAutoMagic as Int))
			;OPTION_TOGGLE_MAGICALLOW_OTHER			= AddToggleOption(" {$Allow} {$Other}",CharacterManager.GetLocalInt(_sCharacterName,"MagicAllowOther") as Bool)

			_iMagicSchoolOptions[0] = OPTION_TOGGLE_MAGICALLOW_ALTERATION
			_iMagicSchoolOptions[1] = OPTION_TOGGLE_MAGICALLOW_CONJURATION
			_iMagicSchoolOptions[2] = OPTION_TOGGLE_MAGICALLOW_DESTRUCTION
			_iMagicSchoolOptions[3] = OPTION_TOGGLE_MAGICALLOW_ILLUSION
			_iMagicSchoolOptions[4] = OPTION_TOGGLE_MAGICALLOW_RESTORATION
			;_iMagicSchoolOptions[5] = OPTION_TOGGLE_MAGICALLOW_OTHER
		Else
			AddMenuOption("$Auto select spells by perks","$Using AFT",OPTION_FLAG_DISABLED)
			AddMenuOption(" {$Allow} {$Alteration}","$Using AFT",OPTION_FLAG_DISABLED)
			AddMenuOption(" {$Allow} {$Conjuration}","$Using AFT",OPTION_FLAG_DISABLED)
			AddMenuOption(" {$Allow} {$Destruction}","$Using AFT",OPTION_FLAG_DISABLED)
			AddMenuOption(" {$Allow} {$Illusion}","$Using AFT",OPTION_FLAG_DISABLED)
			AddMenuOption(" {$Allow} {$Restoration}","$Using AFT",OPTION_FLAG_DISABLED)		
		EndIf
		If _bShowDebugOptions
			AddEmptyOption()
			AddHeaderOption("Debug")
			;===== Character warp DEBUG option ==----
			OPTION_WARPTOCHARACTER = AddTextOption("$Warp to character","",OptionFlags)
			;====================================----
		EndIf

		;===== Begin info column ============----

		SetCursorPosition(1)

		;===== Character selection menu =====----
		OPTION_MENU_CHAR_PICKER = AddMenuOption("$Settings for",_sCharacterName)
		;====================================----

		String[] sSex = New String[2]
		sSex[0] = "Male"
		sSex[1] = "Female"

		AddTextOption("Level " + (CharacterManager.GetCharacterStat(_sCharacterName,"Level") as Int) + " " + CharacterManager.GetCharacterMetaString(_sCharacterName,"RaceText") + " " + sSex[CharacterManager.GetCharacterInt(_sCharacterName,"Sex")],"",OPTION_FLAG_DISABLED)

		AddTextOption("Health: " + (CharacterManager.GetCharacterAV(_sCharacterName,"Health") as Int) + \
						", Stamina:" + (CharacterManager.GetCharacterAV(_sCharacterName,"Stamina") as Int) + \
						", Magicka:" + (CharacterManager.GetCharacterAV(_sCharacterName,"Magicka") as Int), "",OPTION_FLAG_DISABLED)

		Form kRightWeapon = CharacterManager.GetCharacterForm(_sCharacterName,"Equipment.Right.Form")
		Form kLeftWeapon = CharacterManager.GetCharacterForm(_sCharacterName,"Equipment.Left.Form")
		String sWeaponName = CharacterManager.GetCharacterEquipmentName(_sCharacterName,"Right")
		If kLeftWeapon && kLeftWeapon != kRightWeapon
			sWeaponName += " and " + CharacterManager.GetCharacterEquipmentName(_sCharacterName,"Left")
		EndIf
		AddTextOption("Wielding " + sWeaponName,"",OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("ActorBase: " + GetFormIDString(CharacterManager.GetCharacterDummy(_sCharacterName)),"",OPTION_FLAG_DISABLED)
		AddTextOption("Actor: " + GetFormIDString(CharacterManager.GetCharacterActorByName(_sCharacterName)),"",OPTION_FLAG_DISABLED)
		Int MissingReqs = CharacterManager.CheckModReqs(_sCharacterName)
		If MissingReqs == 3
			AddEmptyOption()
			OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$critical} {$mods} !","$Report")
		ElseIf MissingReqs == 2
			AddEmptyOption()
			OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$equipment} {$mods} !","$Report")
		ElseIf MissingReqs == 1
			AddEmptyOption()
			OPTION_TEXT_MODREQREPORT = AddTextOption("{$Missing} {$minor} {$mods} !","$Report")
		Else
			AddEmptyOption()
			OPTION_TEXT_MODREQREPORT = AddTextOption("{$View mod requirements}","$Report")
		EndIf
		;===== END info column =============----

	;===== END Character Setup page =====----

	ElseIf a_page == "$Shrine of Heroes"

	;===== Shrine of Heroes page =====----
	
		RegisterForModEvent("vMYC_AlcoveStatusUpdate","OnAlcoveStatusUpdate")

		Int i = 0
		Int iAlcoveCount = ShrineOfHeroes.Alcoves.Length
		Int iAddedCount = 0

		SetCursorFillMode(LEFT_TO_RIGHT)
		While i < iAlcoveCount
			vMYC_ShrineAlcoveController kThisAlcove = ShrineOfHeroes.AlcoveControllers[i]
			Int iAlcoveIndex = kThisAlcove.AlcoveIndex
			_iAlcoveIndices[iAlcoveIndex] = iAlcoveIndex
			_iAlcoveStates[iAlcoveIndex] = kThisAlcove.AlcoveState
			_sAlcoveCharacterNames[iAlcoveIndex] = ShrineOfHeroes.GetAlcoveStr(i,"CharacterName")
			OPTION_MENU_ALCOVE_CHARACTER[iAlcoveIndex] = AddMenuOption("Alcove {" + (iAlcoveIndex + 1) + "}: {" + _sAlcoveStateEnum[_iAlcoveStates[iAlcoveIndex]] + "}",_sAlcoveCharacterNames[iAlcoveIndex])
			Int iSummonedOptionFlags = 0
			If !_sAlcoveCharacterNames[iAlcoveIndex] || _sAlcoveCharacterNames[iAlcoveIndex] == "Empty"
				iSummonedOptionFlags = OPTION_FLAG_DISABLED
			EndIf
			If !HasLocalConfigKey("AlcoveToggleSummoned" + iAlcoveIndex)
				SetLocalConfigInt("AlcoveToggleSummoned" + iAlcoveIndex,kThisAlcove.CharacterSummoned as Int)
			EndIf
			OPTION_TOGGLE_ALCOVE_SUMMONED[iAlcoveIndex] = AddToggleOption("$Summoned",GetLocalConfigInt("AlcoveToggleSummoned" + iAlcoveIndex),iSummonedOptionFlags)
			i += 1
		EndWhile

		

	;===== END Shrine of Heroes page =====----

	ElseIf a_page == "$Hangout Manager"

	;===== Hangout Manager page =====----

		SetCursorFillMode(TOP_TO_BOTTOM)

		_sHangoutName = _sHangoutNames[_iCurrentHangout]


		Int OptionFlags = 0
		;====================================----

		
		;===== Global Hangout options =====----
		Int HangoutPartyOptionFlags = 0
		Int HangoutClearAllOptionFlags = 0
		If GetConfigBool("HANGOUT_CLEARALL") || !HangoutManager.IsHangoutEnabled(_sHangoutName)
			HangoutPartyOptionFlags = OPTION_FLAG_DISABLED
		ElseIf GetConfigBool("HANGOUT_PARTY") 
			HangoutClearAllOptionFlags = OPTION_FLAG_DISABLED
		EndIf

		AddHeaderOption("$Global Hangout options")
		OPTION_TOGGLE_HANGOUT_CLEARALL = AddToggleOption("$Clear all Hangouts",GetConfigBool("HANGOUT_CLEARALL"),HangoutClearAllOptionFlags)
		
		SetCursorPosition(1)
;		AddHeaderOption("$Stats")
;		Int[] iHangoutStats = HangoutManager.GetHangoutStats()
;		;[iNumHangouts,iNumPresets,iNumQuestsRunning,iNumQuestsAvailable]
;		AddTextOption("{$Hangouts}: " + iHangoutStats[1] + " presets and " + (iHangoutStats[0] - iHangoutStats[1]) + " custom.","",OPTION_FLAG_DISABLED)
;		AddTextOption("{$Running}: " + iHangoutStats[2] + "/" + (iHangoutStats[1] + iHangoutStats[3]) + ", " + iHangoutStats[3] + " remaining.","",OPTION_FLAG_DISABLED)

		;====================================----
		SetCursorPosition(8)
		;===== Hangout header =============----
		AddHeaderOption(_sHangoutName)
		;====================================----


		;===== Hangout enable option ======----
		OPTION_TOGGLE_HANGOUT_ENABLE = AddToggleOption("$Enable this Hangout",HangoutManager.IsHangoutEnabled(_sHangoutName))
		;====================================----
		OPTION_TOGGLE_HANGOUT_PARTY = AddToggleOption("$Assign all characters here",GetConfigBool("HANGOUT_PARTY"),HangoutPartyOptionFlags)
		;===== Begin info column ============----

		SetCursorPosition(9)

		;===== Hangout selection menu =====----
		OPTION_MENU_HANGOUT_SELECT = AddMenuOption("{$Settings for} ",_sHangoutName)
		;====================================----

		AddTextOption("{$Number of characters}: " + HangoutManager.GetNumActorsInHangout(_sHangoutName),"",OPTION_FLAG_DISABLED)
		AddEmptyOption()
		Form kLocation = HangoutManager.GetHangoutForm(_sHangoutName,"Location")
		String sLocationString = "N/A"
		If kLocation
			sLocationString = kLocation.GetName() + "(" + GetformIDString(kLocation) + ")"
		EndIf
		String sSourceString = HangoutManager.GetHangoutStr(_sHangoutName,"SourceCharacter")
		If !sSourceString
			sSourceString = "Preset"
		EndIf
		Form kCell = HangoutManager.GetHangoutForm(_sHangoutName,"Cell")
		String sCellString = "Not loaded"
		If sSourceString == "Preset"
			sCellString = "N/A"
		EndIf
		If kCell
			sCellString = kCell.GetName() + "(" + GetformIDString(kCell) + ")"
		EndIf
		ObjectReference kMarkerRef = HangoutManager.GetHangoutMarker(_sHangoutName)
		String sMarkerString = "N/A"
		If kMarkerRef
			sMarkerString = GetFormIDString(kMarkerRef)
		EndIf
		AddTextOption("{$Source}: " + sSourceString,"",OPTION_FLAG_DISABLED)
		AddTextOption("{$Parent location}: " + sLocationString,"",OPTION_FLAG_DISABLED)
		AddTextOption("{$Cell}: " + sCellString,"",OPTION_FLAG_DISABLED)
		AddTextOption("{$Marker}: " + sMarkerString,"",OPTION_FLAG_DISABLED)


	
;	Int i = 0
;	While i < _sHangoutNames.Length
;		AddHeaderOption(_sHangoutNames[i])
;		AddTextOption("Actor count",HangoutManager.GetNumActorsInHangout(_sHangoutNames[i]))
;		
;		i += 1
;	EndWhile
	
	;===== END Hangout Manager page =====----

	ElseIf a_page == "$Global Options"

	;===== Global Options page =====----
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("$Character options")
		OPTION_TOGGLE_GLOBAL_TRACKBYDEFAULT			= AddToggleOption("$Track characters by default",									 GetConfigBool(	"TRACKBYDEFAULT"		))
		OPTION_TOGGLE_GLOBAL_TRACK_STOPONRECRUIT	= AddToggleOption("$Stop tracking when recruited",									 GetConfigBool(	"TRACK_STOPONRECRUIT"	))
;		OPTION_TOGGLE_GLOBAL_SWAP_FOLLOWER_VOICE	= AddToggleOption("$Always use Follower voicetypes",								 GetConfigBool(	"SWAP_FOLLOWER_VOICE"	))
		OPTION_TOGGLE_GLOBAL_AUTOLEVEL_CHARACTERS	= AddToggleOption("$Use level scaling",												 GetConfigBool(	"AUTOLEVEL_CHARACTERS"	))
;		OPTION_TOGGLE_GLOBAL_DELETE_MISSING			= AddToggleOption("$Disable characters with missing data",							 GetConfigBool(	"DELETE_MISSING"		))
		AddEmptyOption()
		AddHeaderOption("$Magic and Shout options")
		OPTION_TEXT_GLOBAL_MAGIC_OVERRIDES			= AddTextOption("$Always allow",			ENUM_GLOBAL_MAGIC_OVERRIDES				[GetConfigInt("MAGIC_OVERRIDES")		])
		OPTION_TEXT_GLOBAL_MAGIC_ALLOWFROMMODS		= AddTextOption("$Allow magic from mods",	ENUM_GLOBAL_MAGIC_ALLOWFROMMODS			[GetConfigInt("MAGIC_ALLOWFROMMODS")	])
		OPTION_TEXT_GLOBAL_SHOUTS_HANDLING			= AddTextOption("$Allow shouts",			ENUM_GLOBAL_SHOUTS_HANDLING				[GetConfigInt("SHOUTS_HANDLING")		])
		OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED	= AddToggleOption("$Block unlearned Shouts",										 GetConfigBool("SHOUTS_BLOCK_UNLEARNED"	))
		OPTION_TOGGLE_GLOBAL_SHOUTS_DISABLE_CITIES	= AddToggleOption("$Disable Shouts in cities",										 GetConfigBool("SHOUTS_DISABLE_CITIES"	))
		
		SetCursorPosition(1)
		AddHeaderOption("$Data and other options")
;		OPTION_TEXT_GLOBAL_FILE_LOCATION			= AddTextOption("$Location of JSON files",	ENUM_GLOBAL_FILE_LOCATION				[GetConfigInt("FILE_LOCATION")			])
		OPTION_TOGGLE_GLOBAL_WARNING_MISSINGMOD		= AddToggleOption("$Warn about missing mod files on startup",						 GetConfigBool(	"WARNING_MISSINGMOD"	))
		OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS 	= AddToggleOption("$Show debug options",											 GetConfigBool(	"SHOW_DEBUG_OPTIONS"	))
		AddEmptyOption()
		OPTION_TOGGLE_GLOBAL_MCM_REMEMBER_PAGE		= AddToggleOption("$Remember last MCM page",										 GetConfigBool(	"MCM_REMEMBER_PAGE"		))
		
;		OPTION_DEBUG_SHUTDOWN						
;		OPTION_DEBUG_CHARACTER_FORCEREFRESH			
;		OPTION_DEBUG_HANGOUTS_RESETQUESTS			
;		OPTION_DEBUG_SHRINE_RESET					
;		OPTION_DEBUG_SHRINE_RESET					
		






		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	;===== END Global Options page =----
	
	ElseIf a_page == "$Debugging"

	;===== Debug Options page =====----
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("$Performance tweaks")
		OPTION_DEBUG_SHRINE_DISABLE_BG_VALIDATION = AddToggleOption("$Disable background validation",GetConfigBool("DEBUG_SHRINE_DISABLE_BG_VALIDATION"))
		AddEmptyOption()
		AddHeaderOption("$Repair or reset")
		OPTION_DEBUG_CHARACTER_FORCEREFRESH = AddToggleOption("$Force character refresh",GetConfigBool("DEBUG_CHARACTER_FORCEREFRESH"))
		OPTION_DEBUG_SHRINE_RESET = AddToggleOption("$Reset all Shrine alcoves",GetConfigBool("DEBUG_SHRINE_RESET"))
		OPTION_DEBUG_HANGOUTS_RESETQUESTS = AddToggleOption("$Reset Hangout quests",GetConfigBool("DEBUG_HANGOUTS_RESETQUESTS"))
		SetCursorPosition(1)
		AddHeaderOption("$Uninstall")
		OPTION_DEBUG_SHUTDOWN = AddToggleOption("$Shutdown the mod",GetConfigBool("DEBUG_SHUTDOWN"))
		
	;===== END Debug Options page =----
	EndIf
	
EndEvent

Event OnAlcoveStatusUpdate(string eventName, string strArg, float numArg, Form sender)
	If _sCurrentPage == "$Shrine of Heroes"
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionSelect(Int Option)
	;Debug.Trace("MYC: MCM: OnOptionSelect(" + Option + ")")
	If Option == OPTION_TOGGLE_TRACKING
		Bool bEnabled = CharacterManager.GetLocalInt(_sCharacterName,"TrackingEnabled") as Bool
		bEnabled = !bEnabled
		CharacterManager.SetCharacterTracking(_sCharacterName, bEnabled)
		SetToggleOptionValue(Option,bEnabled)
		;ForcePageReset()
	ElseIf Option == OPTION_TOGGLE_CHAR_ISFOE
		Bool bIsFoe = CharacterManager.GetLocalInt(_sCharacterName,"IsFoe") as Bool
		bIsFoe = !bIsFoe
		CharacterManager.SetLocalInt(_sCharacterName,"IsFoe",bIsFoe as Int)
		If bIsFoe
			CharacterManager.SetLocalInt(_sCharacterName,"CanMarry",0)
			SetToggleOptionValue(OPTION_TOGGLE_CHAR_CANMARRY,False,True)
			SetOptionFlags(OPTION_TOGGLE_CHAR_CANMARRY, OPTION_FLAG_DISABLED,True)
		Else
			SetOptionFlags(OPTION_TOGGLE_CHAR_CANMARRY, OPTION_FLAG_NONE,True)
		EndIf
		SetToggleOptionValue(Option,bIsFoe)
		(CharacterManager.GetCharacterActorByName(_sCharacterName) as vMYC_CharacterDummyActorScript).SetFactions()
	ElseIf Option == OPTION_TOGGLE_CHAR_CANMARRY
		Bool bCanMarry = CharacterManager.GetLocalInt(_sCharacterName,"CanMarry") as Bool
		bCanMarry = !bCanMarry
		CharacterManager.SetLocalInt(_sCharacterName,"CanMarry",bCanMarry as Int)
		If bCanMarry
			CharacterManager.SetLocalInt(_sCharacterName,"IsFoe",0)
			SetToggleOptionValue(OPTION_TOGGLE_CHAR_ISFOE,False,True)
			SetOptionFlags(OPTION_TOGGLE_CHAR_ISFOE, OPTION_FLAG_DISABLED,True)
		Else
			SetOptionFlags(OPTION_TOGGLE_CHAR_ISFOE, OPTION_FLAG_NONE,True)
		EndIf
		SetToggleOptionValue(Option,bCanMarry)
		(CharacterManager.GetCharacterActorByName(_sCharacterName) as vMYC_CharacterDummyActorScript).SetFactions()
	ElseIf Option == OPTION_TOGGLE_MAGICALLOW_AUTOSELECT
		Bool bAutoMagic = CharacterManager.GetLocalInt(_sCharacterName,"MagicAutoSelect") as Bool
		bAutoMagic = !bAutoMagic
		CharacterManager.SetLocalInt(_sCharacterName,"MagicAutoSelect",bAutoMagic as Int)
		Int i = _iMagicSchoolOptions.Length
		While i > 0
			i -= 1
			SetOptionFlags(_iMagicSchoolOptions[i],Math.LogicalAnd(OPTION_FLAG_DISABLED,bAutoMagic as Int),True)
		EndWhile
		SetToggleOptionValue(Option,bAutoMagic)
		SendModEvent("vMYC_UpdateCharacterSpellList",_sCharacterName,Utility.GetCurrentRealTime())
	ElseIf Option == OPTION_TOGGLE_SHOUTSALLOW_MASTER 
		Bool bAllowShouts = CharacterManager.GetLocalInt(_sCharacterName,"ShoutsAllowMaster") as Bool
		bAllowShouts = !bAllowShouts
		CharacterManager.SetLocalInt(_sCharacterName,"ShoutsAllowMaster",bAllowShouts as Int)
		SetToggleOptionValue(OPTION_TOGGLE_SHOUTSALLOW_MASTER,bAllowShouts)
		SendModEvent("vMYC_UpdateCharacterSpellList",_sCharacterName,Utility.GetCurrentRealTime())
	ElseIf Option == OPTION_TEXT_MODREQREPORT
		ShowMessage(CharacterManager.GetModReqReport(_sCharacterName),False)
	ElseIf Option == OPTION_TOGGLE_DISABLE_AUTOLEVEL
		Bool bDisableAutoLevel = CharacterManager.GetLocalInt(_sCharacterName,"DisableAutoLevel") as Bool
		bDisableAutoLevel = !bDisableAutoLevel
		CharacterManager.SetLocalInt(_sCharacterName,"DisableAutoLevel",bDisableAutoLevel as Int)
		SetToggleOptionValue(Option,bDisableAutoLevel)
		(CharacterManager.GetCharacterActorByName(_sCharacterName) as vMYC_CharacterDummyActorScript).DoUpkeep(True)
	ElseIf Option == OPTION_WARPTOCHARACTER
		Bool bResult = ShowMessage("$Really warp?",True)
		If bResult
			Game.GetPlayer().MoveTo(CharacterManager.GetCharacterActor(CharacterManager.GetCharacterDummy(_sCharacterNames[_iCurrentCharacter])))
		EndIf
	ElseIf OPTION_TOGGLE_ALCOVE_SUMMONED.Find(Option) > -1
		Int iAlcoveIndex = OPTION_TOGGLE_ALCOVE_SUMMONED.Find(Option)
		vMYC_ShrineAlcoveController kThisAlcove = ShrineOfHeroes.AlcoveControllers[iAlcoveIndex]
		Bool bAlcoveToggleSummoned = GetLocalConfigInt("AlcoveToggleSummoned" + iAlcoveIndex) as Bool
		bAlcoveToggleSummoned = !bAlcoveToggleSummoned
		SetLocalConfigInt("AlcoveToggleSummoned" + iAlcoveIndex,bAlcoveToggleSummoned as Int)
		SetToggleOptionValue(OPTION_TOGGLE_ALCOVE_SUMMONED[iAlcoveIndex],bAlcoveToggleSummoned)
	ElseIf Option == OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS
		SetConfigBool("SHOW_DEBUG_OPTIONS",!GetConfigBool("SHOW_DEBUG_OPTIONS"))
		SetToggleOptionValue(OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS,GetConfigBool("SHOW_DEBUG_OPTIONS"))
	ElseIf Option == OPTION_TOGGLE_HANGOUT_ENABLE
		Bool bHangoutEnabled = HangoutManager.IsHangoutEnabled(_sHangoutName)
		bHangoutEnabled = !bHangoutEnabled
		HangoutManager.SetHangoutEnabled(_sHangoutName, bHangoutEnabled)
		SetToggleOptionValue(OPTION_TOGGLE_HANGOUT_ENABLE,bHangoutEnabled)
	ElseIf Option == OPTION_TOGGLE_HANGOUT_PARTY
		SetConfigStr("HANGOUT_PARTY_TARGET",_sHangoutName)
		SetConfigBool("HANGOUT_PARTY",!GetConfigBool("HANGOUT_PARTY"))
		SetToggleOptionValue(Option,GetConfigBool("HANGOUT_PARTY"))
		If GetConfigBool("HANGOUT_PARTY")
			SetOptionFlags(OPTION_TOGGLE_HANGOUT_CLEARALL,OPTION_FLAG_DISABLED)
		Else
			SetOptionFlags(OPTION_TOGGLE_HANGOUT_CLEARALL,0)
		EndIf
	ElseIf Option == OPTION_TOGGLE_HANGOUT_CLEARALL
		SetConfigStr("HANGOUT_PARTY_TARGET","")
		SetConfigBool("HANGOUT_CLEARALL",!GetConfigBool("HANGOUT_CLEARALL"))
		SetToggleOptionValue(Option,GetConfigBool("HANGOUT_CLEARALL"))
		If GetConfigBool("HANGOUT_CLEARALL")
			SetOptionFlags(OPTION_TOGGLE_HANGOUT_PARTY,OPTION_FLAG_DISABLED)
		Else
			SetOptionFlags(OPTION_TOGGLE_HANGOUT_PARTY,0)
		EndIf
	ElseIf _iMagicSchoolOptions.Find(Option) > -1
		String sSchool
		If Option == OPTION_TOGGLE_MAGICALLOW_ALTERATION
			sSchool = "Alteration"
		ElseIf Option == OPTION_TOGGLE_MAGICALLOW_CONJURATION
			sSchool = "Conjuration"
		ElseIf Option == OPTION_TOGGLE_MAGICALLOW_DESTRUCTION
			sSchool = "Destruction"
		ElseIf Option == OPTION_TOGGLE_MAGICALLOW_ILLUSION
			sSchool = "Illusion"
		ElseIf Option == OPTION_TOGGLE_MAGICALLOW_RESTORATION
			sSchool = "Restoration"
		ElseIf Option == OPTION_TOGGLE_MAGICALLOW_OTHER
			sSchool = "Other"
		EndIf
		Bool bAllowed = CharacterManager.GetLocalInt(_sCharacterName,"MagicAllow" + sSchool) as Bool
		bAllowed = !bAllowed
		CharacterManager.SetLocalInt(_sCharacterName,"MagicAllow" + sSchool,bAllowed as Int)
		SetToggleOptionValue(Option,bAllowed)
		SendModEvent("vMYC_UpdateCharacterSpellList",_sCharacterName,Utility.GetCurrentRealTime())
	ElseIf Option == OPTION_DEBUG_SHUTDOWN
		SetConfigBool("DEBUG_SHUTDOWN",!GetConfigBool("DEBUG_SHUTDOWN"))
		SetToggleOptionValue(Option,GetConfigBool("DEBUG_SHUTDOWN"))
	ElseIf Option == OPTION_DEBUG_CHARACTER_FORCEREFRESH
		SetConfigBool("DEBUG_CHARACTER_FORCEREFRESH",!GetConfigBool("DEBUG_CHARACTER_FORCEREFRESH"))
		SetToggleOptionValue(Option,GetConfigBool("DEBUG_CHARACTER_FORCEREFRESH"))
	ElseIf Option == OPTION_DEBUG_HANGOUTS_RESETQUESTS
		SetConfigBool("DEBUG_HANGOUTS_RESETQUESTS",!GetConfigBool("DEBUG_HANGOUTS_RESETQUESTS"))
		SetToggleOptionValue(Option,GetConfigBool("DEBUG_HANGOUTS_RESETQUESTS"))
	ElseIf Option == OPTION_DEBUG_SHRINE_RESET
		SetConfigBool("DEBUG_SHRINE_RESET",!GetConfigBool("DEBUG_SHRINE_RESET"))
		SetToggleOptionValue(Option,GetConfigBool("DEBUG_SHRINE_RESET"))
	ElseIf Option == OPTION_DEBUG_SHRINE_DISABLE_BG_VALIDATION
		SetConfigBool("DEBUG_SHRINE_DISABLE_BG_VALIDATION",!GetConfigBool("DEBUG_SHRINE_DISABLE_BG_VALIDATION"))
		SetToggleOptionValue(Option,GetConfigBool("DEBUG_SHRINE_DISABLE_BG_VALIDATION"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_TRACKBYDEFAULT
		SetConfigBool("TRACKBYDEFAULT",!GetConfigBool("TRACKBYDEFAULT"))
		Bool bSetAll = False
		If GetConfigBool("TRACKBYDEFAULT")
			bSetAll = ShowMessage("$TRACKBYDEFAULT_Enable_Message",True)
		Else
			bSetAll = ShowMessage("$TRACKBYDEFAULT_Disable_Message",True)
		EndIf
		SetToggleOptionValue(Option,GetConfigBool("TRACKBYDEFAULT"))
		If bSetAll
			CharacterManager.SetAllCharacterTracking(GetConfigBool("TRACKBYDEFAULT"))
		EndIf
	ElseIf Option == OPTION_TOGGLE_GLOBAL_TRACK_STOPONRECRUIT	
		SetConfigBool("TRACK_STOPONRECRUIT",!GetConfigBool("TRACK_STOPONRECRUIT"))
		SetToggleOptionValue(Option,GetConfigBool("TRACK_STOPONRECRUIT"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_SWAP_FOLLOWER_VOICE	
		SetConfigBool("SWAP_FOLLOWER_VOICE",!GetConfigBool("SWAP_FOLLOWER_VOICE"))
		SetToggleOptionValue(Option,GetConfigBool("SWAP_FOLLOWER_VOICE"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_AUTOLEVEL_CHARACTERS
		SetConfigBool("AUTOLEVEL_CHARACTERS",!GetConfigBool("AUTOLEVEL_CHARACTERS"))
		SetToggleOptionValue(Option,GetConfigBool("AUTOLEVEL_CHARACTERS"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_WARNING_MISSINGMOD	
		SetConfigBool("WARNING_MISSINGMOD",!GetConfigBool("WARNING_MISSINGMOD"))
		SetToggleOptionValue(Option,GetConfigBool("WARNING_MISSINGMOD"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_DELETE_MISSING	
		SetConfigBool("DELETE_MISSING",!GetConfigBool("DELETE_MISSING"))
		SetToggleOptionValue(Option,GetConfigBool("DELETE_MISSING"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED	
		SetConfigBool("SHOUTS_BLOCK_UNLEARNED",!GetConfigBool("SHOUTS_BLOCK_UNLEARNED"))
		SetToggleOptionValue(Option,GetConfigBool("SHOUTS_BLOCK_UNLEARNED"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_SHOUTS_DISABLE_CITIES
		SetConfigBool("SHOUTS_DISABLE_CITIES",!GetConfigBool("SHOUTS_DISABLE_CITIES"))
		SetToggleOptionValue(Option,GetConfigBool("SHOUTS_DISABLE_CITIES"))
	ElseIf Option == OPTION_TOGGLE_GLOBAL_MCM_REMEMBER_PAGE
		SetConfigBool("MCM_REMEMBER_PAGE",!GetConfigBool("MCM_REMEMBER_PAGE"))
		SetToggleOptionValue(Option,GetConfigBool("MCM_REMEMBER_PAGE"))
	ElseIf Option == OPTION_TEXT_GLOBAL_MAGIC_OVERRIDES
		Int iSetting = GetConfigInt("MAGIC_OVERRIDES")
		iSetting += 1
		If iSetting >= ENUM_GLOBAL_MAGIC_OVERRIDES.Length
			iSetting = 0
		EndIf
		SetConfigInt("MAGIC_OVERRIDES",iSetting)
		SetTextOptionValue(Option,ENUM_GLOBAL_MAGIC_OVERRIDES[iSetting])
	ElseIf Option == OPTION_TEXT_GLOBAL_MAGIC_ALLOWFROMMODS	
		Int iSetting = GetConfigInt("MAGIC_ALLOWFROMMODS")
		iSetting += 1
		If iSetting >= ENUM_GLOBAL_MAGIC_ALLOWFROMMODS.Length
			iSetting = 0
		EndIf
		SetConfigInt("MAGIC_ALLOWFROMMODS",iSetting)
		SetTextOptionValue(Option,ENUM_GLOBAL_MAGIC_ALLOWFROMMODS[iSetting])
	ElseIf Option == OPTION_TEXT_GLOBAL_SHOUTS_HANDLING	
		Int iSetting = GetConfigInt("SHOUTS_HANDLING")
		iSetting += 1
		If iSetting >= ENUM_GLOBAL_SHOUTS_HANDLING.Length
			iSetting = 0
		EndIf
		SetConfigInt("SHOUTS_HANDLING",iSetting)
		SetTextOptionValue(Option,ENUM_GLOBAL_SHOUTS_HANDLING[iSetting])
	ElseIf Option == OPTION_TEXT_GLOBAL_FILE_LOCATION	
		Int iSetting = GetConfigInt("FILE_LOCATION")
		iSetting += 1
		If iSetting >= ENUM_GLOBAL_FILE_LOCATION.Length
			iSetting = 0
		EndIf
		SetConfigInt("FILE_LOCATION",iSetting)
		SetTextOptionValue(Option,ENUM_GLOBAL_FILE_LOCATION[iSetting])
	EndIf

EndEvent

Event OnOptionMenuOpen(Int Option)
	;Debug.Trace("MYC: MCM: OnOptionMenuOpen(" + Option + ")")
	If Option == OPTION_MENU_CHAR_VOICETYPE
		SetMenuDialogOptions(_sVoiceTypesFiltered)
		SetMenuDialogStartIndex(_iVoiceTypeSelections[_iCurrentCharacter])
		SetMenuDialogDefaultIndex(0)
	ElseIf Option == OPTION_MENU_CHARACTER_HANGOUT
		SetMenuDialogOptions(_sHangoutNamesPlusWanderer)
		String sHangoutName = CharacterManager.GetLocalString(_sCharacterName,"HangoutName")
		If index < 0 || !sHangoutName
			sHangoutName = "$Wanderer"
		EndIf
		Int index = _sHangoutNames.Find(sHangoutName)
		SetMenuDialogStartIndex(index)
		SetMenuDialogDefaultIndex(index)
	ElseIf Option == OPTION_MENU_CHAR_PICKER
		SetMenuDialogOptions(_sCharacterNames)
		SetMenuDialogStartIndex(_iCurrentCharacter)
		SetMenuDialogDefaultIndex(_iCurrentCharacter)
	ElseIf Option == OPTION_MENU_CHAR_CLASS
		SetMenuDialogOptions(_sClassNames)
		SetMenuDialogStartIndex(_iClassSelection)
		SetMenuDialogDefaultIndex(_iClassSelection)
	ElseIf OPTION_MENU_ALCOVE_CHARACTER.Find(Option) > -1
		Int iAlcove = OPTION_MENU_ALCOVE_CHARACTER.Find(Option)
		Int iCN = _sCharacterNames.Find("")
		String[] sCharacterNamesPlusEmpty = New String[128]
		sCharacterNamesPlusEmpty[0] = "$Empty"
		Int i = 0
		Int iAdded = 1
		While i < _sCharacterNames.Length
			If _sCharacterNames[i]
				sCharacterNamesPlusEmpty[i + 1] = _sCharacterNames[i]
				iAdded += 1
			EndIf
			i += 1
		EndWhile
		sCharacterNamesPlusEmpty[iAdded] = "*{$Reset}*"
		SetMenuDialogOptions(sCharacterNamesPlusEmpty)
		If _sAlcoveCharacterNames[iAlcove]
			SetMenuDialogStartIndex(sCharacterNamesPlusEmpty.Find(_sAlcoveCharacterNames[iAlcove]))
			SetMenuDialogDefaultIndex(sCharacterNamesPlusEmpty.Find(_sAlcoveCharacterNames[iAlcove]))
		Else
			SetMenuDialogStartIndex(0)
			SetMenuDialogDefaultIndex(0)
		EndIf
	ElseIf Option == OPTION_MENU_HANGOUT_SELECT
		SetMenuDialogOptions(_sHangoutNamesDisabled)
		String sHangoutName = _sHangoutName
		Int index = _sHangoutNamesDisabled.Find(sHangoutName)
		SetMenuDialogStartIndex(index)
		SetMenuDialogDefaultIndex(index)
	EndIf
EndEvent

Event OnOptionMenuAccept(int option, int index)
	;Debug.Trace("MYC: MCM: OnOptionMenuOAccept(" + Option + "," + index + ")")
	If Option == OPTION_MENU_CHAR_VOICETYPE
		_iVoiceTypeSelections[_iCurrentCharacter] = index
		String sShortVoiceType = StringUtil.Substring(_sVoiceTypesFiltered[index],0,StringUtil.Find(_sVoiceTypesFiltered[index]," "))
		SetMenuOptionValue(OPTION_MENU_CHAR_VOICETYPE,sShortVoiceType)
		CharacterManager.SetCharacterVoiceType(_sCharacterNames[_iCurrentCharacter],_kVoiceTypesFiltered[index])
	ElseIf Option == OPTION_MENU_CHARACTER_HANGOUT
		SetMenuOptionValue(OPTION_MENU_CHARACTER_HANGOUT,_sHangoutNamesPlusWanderer[index])
		Index -= 1
		If Index < 0
			HangoutManager.AssignActorToHangout(CharacterManager.GetCharacterActorByName(_sCharacterName),"")
		Else
			HangoutManager.AssignActorToHangout(CharacterManager.GetCharacterActorByName(_sCharacterName),_sHangoutNames[index])
		EndIf
	ElseIf Option == OPTION_MENU_CHAR_PICKER
		_iCurrentCharacter = index
		ForcePageReset()
	ElseIf Option == OPTION_MENU_CHAR_CLASS
		_iClassSelection = index
		SetMenuOptionValue(OPTION_MENU_CHAR_CLASS,_sClassNames[index])
		CharacterManager.SetCharacterClass(_sCharacterNames[_iCurrentCharacter],CharacterManager.kClasses[index])
	ElseIf OPTION_MENU_ALCOVE_CHARACTER.Find(Option) > -1
		index -= 1 ; Adjust because we added "Empty" to the beginning of the other list
		Int iAlcove = OPTION_MENU_ALCOVE_CHARACTER.Find(Option)
		If index < 0
			SetMenuOptionValue(OPTION_MENU_ALCOVE_CHARACTER[iAlcove],"")
			ShrineOfHeroes.SetAlcoveStr(iAlcove,"CharacterName","")
		ElseIf _sCharacterNames[index] == "" 
			;"Reset" was chosen
			SetMenuOptionValue(OPTION_MENU_ALCOVE_CHARACTER[iAlcove],"$Reset")
			SetOptionFlags(OPTION_MENU_ALCOVE_CHARACTER[iAlcove],OPTION_FLAG_DISABLED)
			ShrineOfHeroes.AlcoveControllers[iAlcove].ResetAlcove()
		Else
			Int iOIndex = ShrineOfHeroes.GetAlcoveIndex(_sCharacterNames[index])
			If iOIndex > -1
				ShrineOfHeroes.SetAlcoveStr(iOIndex,"CharacterName","")
				SetMenuOptionValue(OPTION_MENU_ALCOVE_CHARACTER[iOIndex],"")
			EndIf
			SetMenuOptionValue(OPTION_MENU_ALCOVE_CHARACTER[iAlcove],_sCharacterNames[index])
			ShrineOfHeroes.SetAlcoveStr(iAlcove,"CharacterName",_sCharacterNames[index])
		EndIf
		SendModEvent("vMYC_ShrineNeedsUpdate")
	ElseIf Option == OPTION_MENU_HANGOUT_SELECT
		_iCurrentHangout = index 
		_sHangoutName = _sHangoutNamesDisabled[_iCurrentHangout]
		SetMenuOptionValue(OPTION_MENU_HANGOUT_SELECT,_sHangoutNamesDisabled[_iCurrentHangout])
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionHighlight(Int option)

	If option == OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED
		SetInfoText("$SHOUTS_BLOCK_UNLEARNED_HELP")
	EndIf
	If option == OPTION_TOGGLE_TRACKING
		SetInfoText("$OPTION_TOGGLE_TRACKING_HELP")
	EndIf
	If option == OPTION_TOGGLE_CHAR_ISFOE
		SetInfoText("$OPTION_TOGGLE_CHAR_ISFOE_HELP")
	EndIf
	If option == OPTION_TOGGLE_CHAR_CANMARRY
		SetInfoText("$OPTION_TOGGLE_CHAR_CANMARRY_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_AUTOSELECT
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_AUTOSELECT_HELP")
	EndIf
	If option == OPTION_TOGGLE_SHOUTSALLOW_MASTER
		SetInfoText("$OPTION_TOGGLE_SHOUTSALLOW_MASTER_HELP")
	EndIf
	If option == OPTION_TEXT_MODREQREPORT
		SetInfoText("$OPTION_TEXT_MODREQREPORT_HELP")
	EndIf
	If option == OPTION_TOGGLE_DISABLE_AUTOLEVEL
		SetInfoText("$OPTION_TOGGLE_DISABLE_AUTOLEVEL_HELP")
	EndIf
	If option == OPTION_WARPTOCHARACTER
		SetInfoText("$OPTION_WARPTOCHARACTER_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS
		SetInfoText("$OPTION_TOGGLE_GLOBAL_SHOW_DEBUG_OPTIONS_HELP")
	EndIf
	If option == OPTION_TOGGLE_HANGOUT_ENABLE
		SetInfoText("$OPTION_TOGGLE_HANGOUT_ENABLE_HELP")
	EndIf
	If option == OPTION_TOGGLE_HANGOUT_PARTY
		SetInfoText("$OPTION_TOGGLE_HANGOUT_PARTY_HELP")
	EndIf
	If option == OPTION_TOGGLE_HANGOUT_CLEARALL
		SetInfoText("$OPTION_TOGGLE_HANGOUT_CLEARALL_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_ALTERATION
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_ALTERATION_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_CONJURATION
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_CONJURATION_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_DESTRUCTION
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_DESTRUCTION_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_ILLUSION
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_ILLUSION_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_RESTORATION
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_RESTORATION_HELP")
	EndIf
	If option == OPTION_TOGGLE_MAGICALLOW_OTHER
		SetInfoText("$OPTION_TOGGLE_MAGICALLOW_OTHER_HELP")
	EndIf
	If option == OPTION_DEBUG_CHARACTER_FORCEREFRESH
		SetInfoText("$OPTION_DEBUG_CHARACTER_FORCEREFRESH_HELP")
	EndIf
	If option == OPTION_DEBUG_HANGOUTS_RESETQUESTS
		SetInfoText("$OPTION_DEBUG_HANGOUTS_RESETQUESTS_HELP")
	EndIf
	If option == OPTION_DEBUG_SHRINE_RESET
		SetInfoText("$OPTION_DEBUG_SHRINE_RESET_HELP")
	EndIf
	If option == OPTION_DEBUG_SHRINE_DISABLE_BG_VALIDATION
		SetInfoText("$OPTION_DEBUG_SHRINE_DISABLE_BG_VALIDATION_HELP")
	EndIf
	If option == OPTION_DEBUG_SHUTDOWN
		SetInfoText("$OPTION_DEBUG_SHUTDOWN_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_TRACKBYDEFAULT
		SetInfoText("$OPTION_TOGGLE_GLOBAL_TRACKBYDEFAULT_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_TRACK_STOPONRECRUIT
		SetInfoText("$OPTION_TOGGLE_GLOBAL_TRACK_STOPONRECRUIT_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_SWAP_FOLLOWER_VOICE
		SetInfoText("$OPTION_TOGGLE_GLOBAL_SWAP_FOLLOWER_VOICE_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_AUTOLEVEL_CHARACTERS
		SetInfoText("$OPTION_TOGGLE_GLOBAL_AUTOLEVEL_CHARACTERS_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_WARNING_MISSINGMOD
		SetInfoText("$OPTION_TOGGLE_GLOBAL_WARNING_MISSINGMOD_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_DELETE_MISSING
		SetInfoText("$OPTION_TOGGLE_GLOBAL_DELETE_MISSING_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED
		SetInfoText("$OPTION_TOGGLE_GLOBAL_SHOUTS_BLOCK_UNLEARNED_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_SHOUTS_DISABLE_CITIES
		SetInfoText("$OPTION_TOGGLE_GLOBAL_SHOUTS_DISABLE_CITIES_HELP")
	EndIf
	If option == OPTION_TOGGLE_GLOBAL_MCM_REMEMBER_PAGE
		SetInfoText("$OPTION_TOGGLE_GLOBAL_MCM_REMEMBER_PAGE_HELP")
	EndIf
	If option == OPTION_TEXT_GLOBAL_MAGIC_OVERRIDES
		SetInfoText("$OPTION_TEXT_GLOBAL_MAGIC_OVERRIDES_HELP")
	EndIf
	If option == OPTION_TEXT_GLOBAL_MAGIC_ALLOWFROMMODS
		SetInfoText("$OPTION_TEXT_GLOBAL_MAGIC_ALLOWFROMMODS_HELP")
	EndIf
	If option == OPTION_TEXT_GLOBAL_SHOUTS_HANDLING
		SetInfoText("$OPTION_TEXT_GLOBAL_SHOUTS_HANDLING_HELP")
	EndIf
	If option == OPTION_TEXT_GLOBAL_FILE_LOCATION
		SetInfoText("$OPTION_TEXT_GLOBAL_FILE_LOCATION_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_VOICETYPE
		SetInfoText("$OPTION_MENU_CHAR_VOICETYPE_HELP")
	EndIf
	If option == OPTION_MENU_CHARACTER_HANGOUT
		SetInfoText("$OPTION_MENU_CHARACTER_HANGOUT_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_PICKER
		SetInfoText("$OPTION_MENU_CHAR_PICKER_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_CLASS
		SetInfoText("$OPTION_MENU_CHAR_CLASS_HELP")
	EndIf
	If option == OPTION_MENU_HANGOUT_SELECT
		SetInfoText("$OPTION_MENU_HANGOUT_SELECT_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_VOICETYPE
		SetInfoText("$OPTION_MENU_CHAR_VOICETYPE_HELP")
	EndIf
	If option == OPTION_MENU_CHARACTER_HANGOUT
		SetInfoText("$OPTION_MENU_CHARACTER_HANGOUT_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_PICKER
		SetInfoText("$OPTION_MENU_CHAR_PICKER_HELP")
	EndIf
	If option == OPTION_MENU_CHAR_CLASS
		SetInfoText("$OPTION_MENU_CHAR_CLASS_HELP")
	EndIf
	If option == OPTION_MENU_HANGOUT_SELECT
		SetInfoText("$OPTION_MENU_HANGOUT_SELECT_HELP")
	EndIf
EndEvent

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

event OnConfigOpen()
	UpdateSettings()


endEvent

event OnConfigClose()
	ApplySettings()
	_bConfigClosed = True
endEvent

Function UpdateSettings()
	_Changed  = (vMYC_CFG_Changed.GetValue() as Int) As Bool
	_Shutdown = (vMYC_CFG_Shutdown.GetValue() as Int) As Bool

	_sCharacterNames = CharacterManager.CharacterNames
	_sHangoutNames = HangoutManager.HangoutNames
	_sHangoutNamesPlusWanderer = HangoutManager.HangoutNamesPlusWanderer
	_sHangoutNamesDisabled = HangoutManager.HangoutNamesDisabled
	
	_sClassNames = CharacterManager.sClassNames
	SetConfigBool("DEBUG_CHARACTER_FORCEREFRESH",False,abNoEvent = True)	
	SetConfigBool("DEBUG_HANGOUTS_RESETQUESTS",False,abNoEvent = True)	
	SetConfigBool("DEBUG_SHUTDOWN",False,abNoEvent = True)
	FillEnums()
EndFunction

Function ApplySettings()
	Int iAlcoveIndex = ShrineOfHeroes.AlcoveControllers.Length
	While iAlcoveIndex > 0
		iAlcoveIndex -= 1
		If _sAlcoveCharacterNames[iAlcoveIndex] && _sAlcoveCharacterNames[iAlcoveIndex] != "Empty"
			Int iHandle = ModEvent.Create("vMYC_AlcoveToggleSummoned")
			If iHandle	
				ModEvent.PushInt(iHandle,iAlcoveIndex)
				ModEvent.PushBool(iHandle,GetLocalConfigInt("AlcoveToggleSummoned" + iAlcoveIndex) as Bool)
				ModEvent.Send(iHandle)
			EndIf
		EndIf
	EndWhile

	vMYC_CFG_Shutdown.SetValue(_Shutdown as Int)

	vMYC_CFG_Changed.SetValue(1)

	;If _Shutdown && MetaQuestScript.ModVersion > 0
		;MetaQuestScript.DoShutdown()
	;ElseIf !_Shutdown && MetaQuestScript.ModVersion == 0
		;MetaQuestScript.DoUpkeep(False)
	;EndIf

EndFunction

State CFG_Shutdown

	Event OnSelectST()
		_Shutdown = !_Shutdown
		vMYC_CFG_Shutdown.SetValue(_Shutdown as Int)
		SetToggleOptionValueST(!_Shutdown)
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
		_Shutdown	= False
		SetToggleOptionValueST(_Shutdown)
		vMYC_CFG_Shutdown.SetValue(_Shutdown as Int)
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Enable combat tracking engine")
	EndEvent

EndState
