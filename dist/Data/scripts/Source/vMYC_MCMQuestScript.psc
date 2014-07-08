Scriptname vMYC_MCMQuestScript extends SKI_ConfigBase

vMYC_MetaQuestScript Property MetaQuestScript Auto
vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto

Int Property	VOICETYPE_NOFILTER = 0	AutoReadOnly Hidden
Int Property	VOICETYPE_FOLLOWER = 1	AutoReadOnly Hidden
Int Property	VOICETYPE_SPOUSE 	= 2	AutoReadOnly Hidden
Int Property	VOICETYPE_ADOPT 	= 4	AutoReadOnly Hidden
Int Property	VOICETYPE_GENDER	= 8 AutoReadOnly Hidden

Int Property	OPTION_TOGGLE_TRACKING					Auto Hidden

Int Property	OPTION_TOGGLE_MAGICALLOW_AUTOSELECT		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_ALTERATION		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_CONJURATION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_ILLUSION		Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_DESTRUCTION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_RESTORATION	Auto Hidden
Int Property	OPTION_TOGGLE_MAGICALLOW_OTHER			Auto Hidden

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

Int		_iCurrentCharacterOption

Int		_iCharacterEnabledOption
Bool[]	_bCharacterEnabled

Int		_iCharacterIsFoeOption

Int		_iCharacterCanMarryOption

Int		_iVoiceTypeOption
Int[]	_iVoiceTypeSelections

Int		_iAliasOption
Int[]	_iAliasSelections
ReferenceAlias[]	_kHangoutRefAliases
String[]	_sHangoutNames

Int 	_iClassOption
Int 	_iClassSelection
String[] _sClassNames

Int		_iMagicAutoSelectOption
Int[]	_iMagicSchoolOptions

Int		_iWarpOption

Int[]		_iAlcoveIndices
Int[]		_iAlcoveStates
String[]	_sAlcoveStateEnum
String[] 	_sAlcoveCharacterNames
Int[] 		_iAlcoveCharacterOption
Int[]		_iAlcoveResetOption

Int		_iShowDebugOption

Int Function GetVersion()
    return 4 ; Default version
EndFunction

Event OnVersionUpdate(int a_version)
	If (a_version >= 2 && CurrentVersion < 2)
		Debug.Trace("MYC/MCM: Updating script to version 2...")
        FilterVoiceTypes(VOICETYPE_NOFILTER)
	ElseIf (a_version >= 3 && CurrentVersion < 3)
		Debug.Trace("MYC/MCM: Updating script to version 3...")
		_iMagicSchoolOptions = New Int[6]
	ElseIf (a_version >= 4 && CurrentVersion < 4)
		Debug.Trace("MYC/MCM: Updating script to version 4...")
		OnConfigInit()
	EndIf

EndEvent

Event OnConfigInit()
	ModName = "$Familiar Faces"
	Pages = New String[2]
	Pages[0] = "$Character Setup"
	Pages[1] = "$Shrine of Heroes"
	;Pages[2] = "$Global Options"

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

	_iAlcoveCharacterOption	= New Int[12]
	_iAlcoveResetOption		= New Int[12]

	FilterVoiceTypes(VOICETYPE_NOFILTER)

EndEvent

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
		_iVoiceTypeOption = AddMenuOption("$VoiceType",sShortVoiceType,OptionFlags)

		;====================================----


		;===== Character hangout option =====----
		_iAliasSelections[_iCurrentCharacter] = CharacterManager.GetLocalInt(_sCharacterName,"HangoutIndex")
		_iAliasOption = AddMenuOption("$Hangout",_sHangoutNames[_iAliasSelections[_iCurrentCharacter]],OptionFlags)
		;====================================----

		;===== Character class option =======----
		_iClassSelection = CharacterManager.kClasses.Find(CharacterManager.GetLocalForm(_sCharacterName,"Class") as Class)
		_iClassOption = AddMenuOption("$Class",_sClassNames[_iClassSelection],OptionFlags)
		AddEmptyOption()
		;====================================----

		;===== Character faction options ====----
		Bool bIsFoe = CharacterManager.GetLocalInt(_sCharacterName,"IsFoe")
		Bool bCanMarry = CharacterManager.GetLocalInt(_sCharacterName,"CanMarry")
		_iCharacterIsFoeOption = AddToggleOption("$IsFoe",bIsFoe,Math.LogicalOR(OptionFlags,bCanMarry as Int))
		_iCharacterCanMarryOption = AddToggleOption("$CanMarry",bCanMarry,Math.LogicalOR(OptionFlags,bIsFoe as Int))
		;====================================----

		;===== Character magic option =======----
		AddHeaderOption("Magic")
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


		;====================================----

		If _bShowDebugOptions
			AddEmptyOption()
			AddHeaderOption("Debug")
			;===== Character warp DEBUG option ==----
			_iWarpOption = AddTextOption("$Warp to character","",OptionFlags)
			;====================================----
		EndIf

		;===== Begin info column ============----

		SetCursorPosition(1)

		;===== Character selection menu =====----
		_iCurrentCharacterOption = AddMenuOption("$Settings for",_sCharacterName)
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

		;===== END info column =============----

	;===== END Character Setup page =====----

	ElseIf a_page == "$Shrine of Heroes"

	;===== Shrine of Heroes page =====----
		RegisterForModEvent("vMYC_AlcoveStatusUpdate","OnAlcoveStatusUpdate")
		SetCursorFillMode(TOP_TO_BOTTOM)

		Int i = 0
		Int iAlcoveCount = ShrineOfHeroes.Alcoves.Length
		Int iAddedCount = 0

		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption("$Active Alcoves")
		AddHeaderOption("$Inactive Alcoves")
		Int iActivePos = 0
		Int iInactivePos = 1
		SetCursorFillMode(TOP_TO_BOTTOM)
		While i < iAlcoveCount
			vMYC_ShrineAlcoveController kThisAlcove = ShrineOfHeroes.AlcoveControllers[i]
			Int iAlcoveIndex = kThisAlcove.AlcoveIndex
			_iAlcoveIndices[iAlcoveIndex] = iAlcoveIndex
			_iAlcoveStates[iAlcoveIndex] = kThisAlcove.AlcoveState
			_sAlcoveCharacterNames[iAlcoveIndex] = ShrineOfHeroes.GetAlcoveStr(i,"CharacterName")

			If _iAlcoveStates[iAlcoveIndex] == 0
				iInactivePos += 2
				SetCursorPosition(iInactivePos)
			Else
				iActivePos += 2
				SetCursorPosition(iActivePos)
			EndIf
			_iAlcoveCharacterOption[iAlcoveIndex] = AddMenuOption("Alcove {" + (iAlcoveIndex + 1) + "}: {" + _sAlcoveStateEnum[_iAlcoveStates[iAlcoveIndex]] + "}",_sAlcoveCharacterNames[iAlcoveIndex])
			i += 1
		EndWhile


	;===== END Shrine of Heroes page =====----

	ElseIf a_page == "$Global Options"

	;===== Global Options page =====----

		_iShowDebugOption = AddToggleOption("Show debug options",_bShowDebugOptions)
		AddEmptyOption()
		AddTextOption("More options will go here","")
	;===== END Global Options page =----
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
	ElseIf Option == _iCharacterIsFoeOption
		Bool bIsFoe = CharacterManager.GetLocalInt(_sCharacterName,"IsFoe") as Bool
		bIsFoe = !bIsFoe
		CharacterManager.SetLocalInt(_sCharacterName,"IsFoe",bIsFoe as Int)
		If bIsFoe
			CharacterManager.SetLocalInt(_sCharacterName,"CanMarry",0)
			SetToggleOptionValue(_iCharacterCanMarryOption,False,True)
			SetOptionFlags(_iCharacterCanMarryOption, OPTION_FLAG_DISABLED,True)
		Else
			SetOptionFlags(_iCharacterCanMarryOption, OPTION_FLAG_NONE,True)
		EndIf
		SetToggleOptionValue(Option,bIsFoe)
		(CharacterManager.GetCharacterActorByName(_sCharacterName) as vMYC_CharacterDummyActorScript).SetFactions()
	ElseIf Option == _iCharacterCanMarryOption
		Bool bCanMarry = CharacterManager.GetLocalInt(_sCharacterName,"CanMarry") as Bool
		bCanMarry = !bCanMarry
		CharacterManager.SetLocalInt(_sCharacterName,"CanMarry",bCanMarry as Int)
		If bCanMarry
			CharacterManager.SetLocalInt(_sCharacterName,"IsFoe",0)
			SetToggleOptionValue(_iCharacterIsFoeOption,False,True)
			SetOptionFlags(_iCharacterIsFoeOption, OPTION_FLAG_DISABLED,True)
		Else
			SetOptionFlags(_iCharacterIsFoeOption, OPTION_FLAG_NONE,True)
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
	ElseIf Option == _iWarpOption
		Bool bResult = ShowMessage("$Really warp?",True)
		If bResult
			Game.GetPlayer().MoveTo(CharacterManager.GetCharacterActor(CharacterManager.GetCharacterDummy(_sCharacterNames[_iCurrentCharacter])))
		EndIf
	ElseIf Option == _iShowDebugOption
		_bShowDebugOptions = !_bShowDebugOptions
		SetToggleOptionValue(_iShowDebugOption,_bShowDebugOptions)
	EndIf

EndEvent

Event OnOptionMenuOpen(Int Option)
	;Debug.Trace("MYC: MCM: OnOptionMenuOpen(" + Option + ")")
	If Option == _iVoiceTypeOption
		SetMenuDialogOptions(_sVoiceTypesFiltered)
		SetMenuDialogStartIndex(_iVoiceTypeSelections[_iCurrentCharacter])
		SetMenuDialogDefaultIndex(0)
	ElseIf Option == _iAliasOption
		SetMenuDialogOptions(_sHangoutNames)
		SetMenuDialogStartIndex(_iAliasSelections[_iCurrentCharacter])
		SetMenuDialogDefaultIndex(_iAliasSelections[_iCurrentCharacter])
	ElseIf Option == _iCurrentCharacterOption
		SetMenuDialogOptions(_sCharacterNames)
		SetMenuDialogStartIndex(_iCurrentCharacter)
		SetMenuDialogDefaultIndex(_iCurrentCharacter)
	ElseIf Option == _iClassOption
		SetMenuDialogOptions(_sClassNames)
		SetMenuDialogStartIndex(_iClassSelection)
		SetMenuDialogDefaultIndex(_iClassSelection)
	ElseIf _iAlcoveCharacterOption.Find(Option) > -1
		Int iAlcove = _iAlcoveCharacterOption.Find(Option)
		Int iCN = _sCharacterNames.Find("")
		String[] sCharacterNamesPlusEmpty = New String[128]
		sCharacterNamesPlusEmpty[0] = "$Empty"
		Int i = 0
		While i < _sCharacterNames.Length
			sCharacterNamesPlusEmpty[i + 1] = _sCharacterNames[i]
			i += 1
		EndWhile
		SetMenuDialogOptions(sCharacterNamesPlusEmpty)
		If _sAlcoveCharacterNames[iAlcove]
			SetMenuDialogStartIndex(sCharacterNamesPlusEmpty.Find(_sAlcoveCharacterNames[iAlcove]))
			SetMenuDialogDefaultIndex(sCharacterNamesPlusEmpty.Find(_sAlcoveCharacterNames[iAlcove]))
		Else
			SetMenuDialogStartIndex(0)
			SetMenuDialogDefaultIndex(0)
		EndIf
	EndIf
EndEvent

Event OnOptionMenuAccept(int option, int index)
	;Debug.Trace("MYC: MCM: OnOptionMenuOAccept(" + Option + "," + index + ")")
	If Option == _iVoiceTypeOption
		_iVoiceTypeSelections[_iCurrentCharacter] = index
		String sShortVoiceType = StringUtil.Substring(_sVoiceTypesFiltered[index],0,StringUtil.Find(_sVoiceTypesFiltered[index]," "))
		SetMenuOptionValue(_iVoiceTypeOption,sShortVoiceType)
		CharacterManager.SetCharacterVoiceType(_sCharacterNames[_iCurrentCharacter],_kVoiceTypesFiltered[index])
	ElseIf Option == _iAliasOption
		_iAliasSelections[_iCurrentCharacter] = index
		If CharacterManager.SetCharacterHangout(_sCharacterNames[_iCurrentCharacter],_kHangoutRefAliases[index])
			SetMenuOptionValue(_iAliasOption,_sHangoutNames[index])
		Else
			Debug.MessageBox("Sorry, but " + StringUtil.SubString(_sHangoutNames[index],1) + " is already in use by " + (_kHangoutRefAliases[index].GetReference() as Actor).GetActorBase().GetName() + "!")
		EndIf
	ElseIf Option == _iCurrentCharacterOption
		_iCurrentCharacter = index
		ForcePageReset()
	ElseIf Option == _iClassOption
		_iClassSelection = index
		SetMenuOptionValue(_iClassOption,_sClassNames[index])
		CharacterManager.SetCharacterClass(_sCharacterNames[_iCurrentCharacter],CharacterManager.kClasses[index])
	ElseIf _iAlcoveCharacterOption.Find(Option) > -1
		index -= 1 ; Adjust because we added "Empty" to the beginning of the other list
		Int iAlcove = _iAlcoveCharacterOption.Find(Option)
		If index < 0
			SetMenuOptionValue(_iAlcoveCharacterOption[iAlcove],"")
			ShrineOfHeroes.SetAlcoveStr(iAlcove,"CharacterName","")
		Else
			Int iOIndex = ShrineOfHeroes.GetAlcoveIndex(_sCharacterNames[index])
			If iOIndex > -1
				ShrineOfHeroes.SetAlcoveStr(iOIndex,"CharacterName","")
				SetMenuOptionValue(_iAlcoveCharacterOption[iOIndex],"")
			EndIf
			SetMenuOptionValue(_iAlcoveCharacterOption[iAlcove],_sCharacterNames[index])
			ShrineOfHeroes.SetAlcoveStr(iAlcove,"CharacterName",_sCharacterNames[index])
		EndIf
		SendModEvent("vMYC_ShrineNeedsUpdate")
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
endEvent

Function UpdateSettings()
	_Changed  = (vMYC_CFG_Changed.GetValue() as Int) As Bool
	_Shutdown = (vMYC_CFG_Shutdown.GetValue() as Int) As Bool

	_sCharacterNames = CharacterManager.CharacterNames
	_kHangoutRefAliases = CharacterManager.kHangoutRefAliases
	_sHangoutNames = CharacterManager.sHangoutNames

	_sClassNames = CharacterManager.sClassNames
EndFunction

function ApplySettings()
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
