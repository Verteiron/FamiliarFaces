Scriptname vMYC_MCMQuestScript extends SKI_ConfigBase  

vMYC_MetaQuestScript Property MetaQuestScript Auto
vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto

GlobalVariable Property vMYC_CFG_Changed Auto
GlobalVariable Property vMYC_CFG_Shutdown Auto


Bool _Changed 
Bool _Shutdown

String 	_sCurrentPage

String[] _sCharacterNames

String[] _sVoiceTypesFollower
String[] _sVoiceTypesAll

VoiceType[] _kVoiceTypesFollower
VoiceType[] _kVoiceTypesAll

Int		_iCurrentCharacter
String	_sCharacterName

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

Int[]		_iAlcoveIndices
Int[]		_iAlcoveStates
String[]	_sAlcoveStateEnum
String[] 	_sAlcoveCharacterNames
Int[] 		_iAlcoveCharacterOption
Int[]		_iAlcoveResetOption

Event OnConfigInit()
	ModName = "$Familiar Faces"
	Pages = New String[3]
	Pages[0] = "$Character Setup"
	Pages[1] = "$Shrine of Heroes"
	Pages[2] = "$Global Options"
	
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
	
EndEvent

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

		
		;===== Character selection menu =====----
		_iCurrentCharacterOption = AddMenuOption("$Settings for",_sCharacterName)
		;====================================----

		
		;===== Set flags if disabled ========----
		Int OptionFlags = 0
		_bCharacterEnabled[_iCurrentCharacter] = CharacterManager.GetLocalInt(_sCharacterName,"Enabled") as Bool
		If !_bCharacterEnabled[_iCurrentCharacter]
			OptionFlags = OPTION_FLAG_DISABLED
		EndIf
		;====================================----
		

		;===== Character header =============----
		AddHeaderOption(_sCharacterName)
		;====================================----
		

		;===== Character enable option ======----
		_iCharacterEnabledOption = AddToggleOption("$Enable this character",_bCharacterEnabled[_iCurrentCharacter])
		;====================================----
		

		;===== Character voicetype option ==----
		VoiceType kCharVoiceType = CharacterManager.GetCharacterVoiceType(_sCharacterName)

		If kCharVoiceType == None ; If no voicetype is set, pick the "default" option
			_iVoiceTypeSelections[_iCurrentCharacter] = 0
		Else
			Int iVoiceTypeIndex = _kVoiceTypesFollower.Find(kCharVoiceType)
			_iVoiceTypeSelections[_iCurrentCharacter] = iVoiceTypeIndex
		EndIf

		_iVoiceTypeOption = AddMenuOption("$VoiceType",_sVoiceTypesFollower[_iVoiceTypeSelections[_iCurrentCharacter]],OptionFlags)
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
		
		;===== Character warp DEBUG option ==----
		_iWarpOption = AddTextOption("$Warp to character","",OptionFlags)
		;====================================----
		
		
		;===== Begin info column ============----
		
		SetCursorPosition(1)
		AddEmptyOption()
		AddEmptyOption()
		
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
	
	Else

	EndIf

	
EndEvent

Event OnAlcoveStatusUpdate(string eventName, string strArg, float numArg, Form sender)
	If _sCurrentPage == "$Shrine of Heroes"
		ForcePageReset()
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
