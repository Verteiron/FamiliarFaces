Scriptname vMYC_MCMQuestScript extends SKI_ConfigBase  

vMYC_MetaQuestScript Property MetaQuestScript Auto
vMYC_CharacterManagerScript Property CharacterManager Auto

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto


Bool _Changed 
Bool _Shutdown

String[] _sCharacterNames

String[] _sVoiceTypesFollower
String[] _sVoiceTypesAll

VoiceType[] _kVoiceTypesFollower
VoiceType[] _kVoiceTypesAll

Int		_iCurrentCharacter

Int		_iCurrentCharacterOption

Int		_iCharacterEnabledOption
Bool[]	_bCharacterEnabled

Int		_iVoiceTypeOption
Int[]	_iVoiceTypeSelections

Int		_iAliasOption
Int[]	_iAliasSelections
ReferenceAlias[]	_kHangoutRefAliases
String[]	_sHangoutNames

Int 	_iClassOption
Int 	_iClassSelection
String[] _sClassNames

Int		_iWarpOption

Event OnConfigInit()
	ModName = "$Familiar Faces"
	Pages = New String[2]
	Pages[0] = "$Character Options"
	Pages[1] = "$Global Options"
	
	_bCharacterEnabled	= New Bool[128]
	_sCharacterNames = New String[128]
	_iVoiceTypeSelections = New Int[128]
	_sVoiceTypesFollower = New String[128]
	_kVoiceTypesFollower = New VoiceType[128]
	_iAliasSelections = New Int[128]
	Int i = 0
	Int idx = 1
	Int iListSize = CharacterManager.vMYC_VoiceTypesFollowerList.GetSize()
	_sVoiceTypesFollower[0] = "Default"
	While i < iListSize
		_kVoiceTypesFollower[idx] = CharacterManager.vMYC_VoiceTypesFollowerList.GetAt(i) as VoiceType
		_sVoiceTypesFollower[idx] = _kVoiceTypesFollower[idx] as String
		_sVoiceTypesFollower[idx] = StringUtil.SubString(_sVoiceTypesFollower[idx],0,StringUtil.Find(_sVoiceTypesFollower[idx],">") - 10)
		_sVoiceTypesFollower[idx] = StringUtil.SubString(_sVoiceTypesFollower[idx],StringUtil.Find(_sVoiceTypesFollower[idx],"<") + 1)
		Debug.Trace("MYC: MCM: _kVoiceTypesFollower[ " + idx + "] is " + _kVoiceTypesFollower[idx] + " named " + _sVoiceTypesFollower[idx])
		i += 1
		idx += 1
	EndWhile
	
EndEvent

event OnGameReload()
    parent.OnGameReload()
endEvent

event OnPageReset(string a_page)
	String sKey = "vMYC."
	UpdateSettings()
	If a_page == "$Character Options"
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		_iCurrentCharacterOption = AddMenuOption("$Settings for",_sCharacterNames[_iCurrentCharacter])
		String sCharacterName = _sCharacterNames[_iCurrentCharacter]
		;ActorBase kCharacterDummy = CharacterManager.GetCharacterDummy(_sCharacterNames[_iCurrentCharacter])
		Int OptionFlags = 0
		_bCharacterEnabled[_iCurrentCharacter] = CharacterManager.GetLocalInt(sCharacterName,"Enabled") as Bool
		If !_bCharacterEnabled[_iCurrentCharacter]
			OptionFlags = OPTION_FLAG_DISABLED
		EndIf
		AddHeaderOption(sCharacterName)
		_iCharacterEnabledOption = AddToggleOption("$Enable this character",_bCharacterEnabled[_iCurrentCharacter])
		
		VoiceType kCharVoiceType = CharacterManager.GetCharacterVoiceType(sCharacterName)
		Debug.Trace("MYC: MCM: kCharVoiceType for " + sCharacterName + " is " + kCharVoiceType)
		If kCharVoiceType == None
			Debug.Trace("MYC: MCM: kCharVoiceType is None, selecting option 0")
			_iVoiceTypeSelections[_iCurrentCharacter] = 0
		Else
			Int iVoiceTypeIndex = _kVoiceTypesFollower.Find(kCharVoiceType)
			Debug.Trace("MYC: MCM: kCharVoiceType is set, selecting option " + iVoiceTypeIndex)
			_iVoiceTypeSelections[_iCurrentCharacter] = iVoiceTypeIndex
		EndIf
		_iVoiceTypeOption = AddMenuOption("$VoiceType",_sVoiceTypesFollower[_iVoiceTypeSelections[_iCurrentCharacter]],OptionFlags)

		_iAliasSelections[_iCurrentCharacter] = CharacterManager.GetLocalInt(sCharacterName,"HangoutIndex")
		_iAliasOption = AddMenuOption("$Hangout",_sHangoutNames[_iAliasSelections[_iCurrentCharacter]],OptionFlags)

		_iClassSelection = CharacterManager.kClasses.Find(CharacterManager.GetLocalForm(sCharacterName,"Class") as Class)
		_iClassOption = AddMenuOption("$Class",_sClassNames[_iClassSelection],OptionFlags)
		AddEmptyOption()
		
		_iWarpOption = AddTextOption("$Warp to character","",OptionFlags)
		
		; Begin info column
		
		SetCursorPosition(1)
		AddEmptyOption()
		AddEmptyOption()
		
		String[] sSex = New String[2]
		sSex[0] = "Male"
		sSex[1] = "Female"
		
		AddTextOption("Level " + (CharacterManager.GetCharacterStat(sCharacterName,"Level") as Int) + " " + CharacterManager.GetCharacterMetaString(sCharacterName,"RaceText") + " " + sSex[CharacterManager.GetCharacterInt(sCharacterName,"Sex")],"",OPTION_FLAG_DISABLED)

		AddTextOption("Health: " + (CharacterManager.GetCharacterAV(sCharacterName,"Health") as Int) + \
						", Stamina:" + (CharacterManager.GetCharacterAV(sCharacterName,"Stamina") as Int) + \
						", Magicka:" + (CharacterManager.GetCharacterAV(sCharacterName,"Magicka") as Int), "",OPTION_FLAG_DISABLED)
		
		Form kRightWeapon = CharacterManager.GetCharacterForm(sCharacterName,"Equipment.Right.Form")
		Form kLeftWeapon = CharacterManager.GetCharacterForm(sCharacterName,"Equipment.Left.Form")
		String sWeaponName = CharacterManager.GetCharacterEquipmentName(sCharacterName,"Right")
		If kLeftWeapon && kLeftWeapon != kRightWeapon
			sWeaponName += " and " + CharacterManager.GetCharacterEquipmentName(sCharacterName,"Left")
		EndIf
		AddTextOption("Wielding " + sWeaponName,"",OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("ActorBase: " + GetFormIDString(CharacterManager.GetCharacterDummy(sCharacterName)),"",OPTION_FLAG_DISABLED)
		AddTextOption("Actor: " + GetFormIDString(CharacterManager.GetCharacterActorByName(sCharacterName)),"",OPTION_FLAG_DISABLED)
		
	EndIf
	
EndEvent

Event OnOptionSelect(Int Option)
	Debug.Trace("MYC: MCM: OnOptionSelect(" + Option + ")")
	If Option == _iCharacterEnabledOption
		_bCharacterEnabled[_iCurrentCharacter] = !_bCharacterEnabled[_iCurrentCharacter]
		CharacterManager.SetCharacterEnabled(_sCharacterNames[_iCurrentCharacter],_bCharacterEnabled[_iCurrentCharacter])

		SetOptionFlags(_iVoiceTypeOption, Math.LogicalAnd(OPTION_FLAG_DISABLED,_bCharacterEnabled[_iCurrentCharacter] as Int),True)
		SetOptionFlags(_iAliasOption, Math.LogicalAnd(OPTION_FLAG_DISABLED,_bCharacterEnabled[_iCurrentCharacter] as Int),True)

		SetToggleOptionValue(Option,_bCharacterEnabled[_iCurrentCharacter])		
		;ForcePageReset()
	ElseIf Option == _iWarpOption
		Bool bResult = ShowMessage("$Really warp?",True)
		If bResult
			Game.GetPlayer().MoveTo(CharacterManager.GetCharacterActor(CharacterManager.GetCharacterDummy(_sCharacterNames[_iCurrentCharacter])))
		EndIf
	EndIf

EndEvent

Event OnOptionMenuOpen(Int Option)
	Debug.Trace("MYC: MCM: OnOptionMenuOpen(" + Option + ")")
	If Option == _iVoiceTypeOption
		SetMenuDialogOptions(_sVoiceTypesFollower)
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
	EndIf
EndEvent

Event OnOptionMenuAccept(int option, int index)
	Debug.Trace("MYC: MCM: OnOptionMenuOAccept(" + Option + "," + index + ")")
	If Option == _iVoiceTypeOption
		_iVoiceTypeSelections[_iCurrentCharacter] = index
		SetMenuOptionValue(_iVoiceTypeOption,_sVoiceTypesFollower[index])
		CharacterManager.SetCharacterVoiceType(_sCharacterNames[_iCurrentCharacter],_kVoiceTypesFollower[index])
	ElseIf Option == _iAliasOption
		_iAliasSelections[_iCurrentCharacter] = index
		SetMenuOptionValue(_iAliasOption,_sHangoutNames[index])
		CharacterManager.SetCharacterHangout(_sCharacterNames[_iCurrentCharacter],_kHangoutRefAliases[index])
	ElseIf Option == _iCurrentCharacterOption
		_iCurrentCharacter = index
		ForcePageReset()
	ElseIf Option == _iClassOption
		_iClassSelection = index
		SetMenuOptionValue(_iClassOption,_sClassNames[index])
		CharacterManager.SetCharacterClass(_sCharacterNames[_iCurrentCharacter],CharacterManager.kClasses[index])
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
