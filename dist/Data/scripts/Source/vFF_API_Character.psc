Scriptname vFF_API_Character extends vFF_APIBase Hidden
{Save and restore character data.}

; === [ vFF_API_Character.psc ] ==========================================---
; Main API for managing character-related data. 
; Interface for reading and writing Character data in the Registry. If you want
; to find a saved Character's Destruction level, or add extra data to one of 
; their Trophy achievements, this is what you use. This can also be used to 
; retrieve and apply a Character's appearance, stats, and gear to a target CharacterBase.
; 
; Because of Reasons, Character data is never directly found via name, but by a
; UUID called the Session ID (SID) that is generated when they are created or 
; first loaded after installing Familiar Faces. 
; 
; The Character API deals strictly with the Character data that exists in the 
; Registry. For messing around with the character data after it has been applied 
; to an Character, use either the usual Actor/ActorBase functions or the Doppelganger API.
; ========================================================---

Import vFF_Registry
Import vFF_Session

;=== Generic Functions ===--

Int Function GetCharacterJMap(String asSID) Global
	Int iRet = -2 ; SID not present
	String sRegKey = "Characters." + asSID
	Int jCharacterData = GetRegObj(sRegKey)
	If jCharacterData
		Return jCharacterData
	EndIf
	Return iRet
EndFunction

Int Function GetCharacterObj(String asSID, String asKey) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if nothing is found
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		If JValue.hasPath(jCharacterData,asKey)
			Return JValue.SolveObj(jCharacterData,asKey)
		EndIf
	EndIf
	Return iRet
EndFunction

Int Function GetCharacterInt(String asSID, String asKey) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if nothing is found
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		If JValue.hasPath(jCharacterData,asKey)
			Return JValue.SolveInt(jCharacterData,asKey)
		EndIf
	EndIf
	Return iRet
EndFunction

Float Function GetCharacterFlt(String asSID, String asKey) Global
	asKey = MakePath(asKey)
	Float fRet = -1.0 ; Default error if nothing is found
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData as Float
	Else
		If JValue.hasPath(jCharacterData,asKey)
			Return JValue.SolveFlt(jCharacterData,asKey)
		EndIf
	EndIf
	Return fRet
EndFunction

String Function GetCharacterStr(String asSID, String asKey) Global
	asKey = MakePath(asKey)
	String sRet = "-1" ; Default error if nothing is found
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		If JValue.hasPath(jCharacterData,asKey)
			Return JValue.SolveStr(jCharacterData,asKey)
		EndIf
	EndIf
	Return sRet
EndFunction

Form Function GetCharacterForm(String asSID, String asKey) Global
	asKey = MakePath(asKey)
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData
		Return JValue.SolveForm(jCharacterData,asKey)
	EndIf
	Return None
EndFunction

;=== Generic Write Functions ===--

Int Function SetCharacterObj(String asSID, String asKey, Int ajValue) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if write fails
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		iRet = 1
		JValue.SolveObjSetter(jCharacterData,asKey,ajValue,True)
		SendSessionEvent(asSID + asKey)
	EndIf
	Return iRet
EndFunction

Int Function SetCharacterInt(String asSID, String asKey, Int aiValue) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if write fails
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		iRet = 1
		JValue.SolveIntSetter(jCharacterData,asKey,aiValue,True)
		SendSessionEvent(asSID + asKey)
	EndIf
	Return iRet
EndFunction

Int Function SetCharacterFlt(String asSID, String asKey, Float afValue) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if write fails
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		iRet = 1
		JValue.SolveFltSetter(jCharacterData,asKey,afValue,True)
		SendSessionEvent(asSID + asKey)
	EndIf
	Return iRet
EndFunction

Int Function SetCharacterStr(String asSID, String asKey, String asValue) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if write fails
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		iRet = 1
		JValue.SolveStrSetter(jCharacterData,asKey,asValue,True)
		SendSessionEvent(asSID + asKey)
	EndIf
	Return iRet
EndFunction

Int Function SetCharacterForm(String asSID, String asKey, Form akValue) Global
	asKey = MakePath(asKey)
	Int iRet = -1 ; Default error if write fails
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		iRet = 1
		JValue.SolveFormSetter(jCharacterData,asKey,akValue,True)
		SendSessionEvent(asSID + asKey)
	EndIf
	Return iRet
EndFunction

;=== Character Config Get/Set Functions ===--
; These will try to read from Character-specific configs, then fall back to 
; more general defaults.

Int Function GetCharConfigObj(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	Int jRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		jRet = GetSessionObj(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		jRet = GetConfigObj(asKey)
	EndIf

	Return jRet
EndFunction

Int Function GetCharConfigInt(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	Int iRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		iRet = GetSessionInt(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		iRet = GetConfigInt(asKey)
	EndIf

	Return iRet
EndFunction

Bool Function GetCharConfigBool(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	Bool bRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		bRet = GetSessionBool(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		bRet = GetConfigBool(asKey)
	EndIf

	Return bRet
EndFunction

Float Function GetCharConfigFlt(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	Float fRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		fRet = GetSessionFlt(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		fRet = GetConfigFlt(asKey)
	EndIf

	Return fRet
EndFunction

String Function GetCharConfigStr(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	String sRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		sRet = GetSessionStr(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		sRet = GetConfigStr(asKey)
	EndIf

	Return sRet
EndFunction

Form Function GetCharConfigForm(String asSID, String asKey) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	Form kRet
	If HasSessionKey(sRegKey) || HasRegKey(sRegKey)
		;DebugTraceAPIChar("Session has this key!")
		kRet = GetSessionForm(sRegKey,abUseDefault = True)
	Else
		;DebugTraceAPIChar("Session does NOT have this key!")
		kRet = GetConfigForm(asKey)
	EndIf

	Return kRet
EndFunction

Function SetCharConfigObj(String asSID, String asKey, Int ajValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	SetSessionObj(sRegKey,ajValue,abMakeDefault)
EndFunction

Function SetCharConfigInt(String asSID, String asKey, Int aiValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	DebugTraceAPIChar("Setting " + sRegKey + " to " + aiValue)
	SetSessionInt(sRegKey,aiValue,abMakeDefault)
EndFunction

Function SetCharConfigBool(String asSID, String asKey, Bool abValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	SetSessionBool(sRegKey,abValue,abMakeDefault)
EndFunction

Function SetCharConfigFlt(String asSID, String asKey, Float afValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	SetSessionFlt(sRegKey,afValue,abMakeDefault)
EndFunction

Function SetCharConfigStr(String asSID, String asKey, String asValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	SetSessionStr(sRegKey,asValue,abMakeDefault)
EndFunction

Function SetCharConfigForm(String asSID, String asKey, Form akValue, Bool abMakeDefault = False) Global
	String sRegKey = "Characters." + asSID + ".Config." + asKey
	SetSessionForm(sRegKey,akValue,abMakeDefault)
EndFunction

Bool Function ToggleCharConfigBool(String asSID, String asKey, Bool abMakeDefault = False) Global
	Bool bToggleValue = !GetCharConfigBool(asSID,asKey)
	SetCharConfigBool(asSID,asKey,bToggleValue,abMakeDefault)
	Return bToggleValue
EndFunction

;=== API Character/SessionID functions

;Retrieve all SIDs in the Registry.
String[] Function GetAllSIDs() Global
	Int jSIDList = JMap.AllKeys(GetRegObj("Characters"))
	String[] sResults = Utility.CreateStringArray(JArray.Count(jSidList))
	Int i = JArray.Count(jSIDList)
	While i > 0
		i -= 1
		sResults[i] = JArray.GetStr(jSIDList,i)
	EndWhile
	Return sResults
EndFunction

;Retrieve all character names in the Registry.
String[] Function GetAllNames() Global
	Int jNameList = JMap.AllKeys(GetRegObj("Names"))
	String[] sResults = Utility.CreateStringArray(JArray.Count(jNameList))
	Int i = JArray.Count(jNameList)
	DebugTraceAPIChar("Found " + i + " names in the list!")
	While i > 0
		i -= 1
		sResults[i] = JArray.GetStr(jNameList,i)
		DebugTraceAPIChar("Adding " + sResults[i] + " to the name list!")
	EndWhile
	Return sResults
EndFunction

;Retrieve matching SIDs for asCharacterName.
String[] Function GetSIDsByName(String asCharacterName) Global
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + asCharacterName))
	String[] sResults = Utility.CreateStringArray(JArray.Count(jSidList))
	Int i = JArray.Count(jSIDList)
	While i > 0
		i -= 1
		sResults[i] = JArray.GetStr(jSIDList,i)
	EndWhile
	Return sResults
EndFunction

;Return the SID of a session that matches the passed name and playtime.
String Function MatchSession(String asCharacterName, Float afPlayTime)
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + asCharacterName))
	If jSIDList
		Int iSID = JArray.Count(jSIDList)
		While iSID > 0
			iSID -= 1
			String sSID = JArray.GetStr(jSIDList,iSID)
			If Math.ABS(GetRegFlt("Characters." + sSID + ".Info.PlayTime") - afPlayTime) < 0.1
				Return sSID
			EndIf
		EndWhile
	EndIf
	Return ""
EndFunction

;=== API Get Functions ===--

;Returns the level of the saved character
Float Function GetCharacterLevel(String asSID) Global
	String sKey = ".Info.Level"
	Return vFF_API_Character.GetCharacterFlt(asSID,sKey)
EndFunction

;Returns the specified ActorValue for the character 
Float Function GetCharacterAV(String asSID, String asValueName) Global
	String sKey = ".Stats.AV." + asValueName
	Return vFF_API_Character.GetCharacterFlt(asSID,sKey)
EndFunction

;Return this character's Race
Race Function GetCharacterRace(String asSID) Global
	String sKey = ".Info.Race"
	Return vFF_API_Character.GetCharacterForm(asSID,sKey) as Race
EndFunction

; Returns this Character's name.
String Function GetCharacterName(String asSID) Global
	String sKey = ".Info.Name"
	Return vFF_API_Character.GetCharacterStr(asSID,sKey)
EndFunction

; Returns this Character's sex. Values for sex are:
; -1 - None
; 0 - Male
; 1 - Female
Int Function GetCharacterSex(String asSID) Global
	String sKey = ".Info.Sex"
	Return vFF_API_Character.GetCharacterInt(asSID,sKey)
EndFunction

; Get the Class of the Character
Class Function GetCharacterClass(String asSID) Global
	String sKey = ".Class"
	Return vFF_API_Character.GetCharacterForm(asSID,sKey) as Class
EndFunction

; Get the VoiceType of the Character
VoiceType Function GetCharacterVoiceType(String asSID) Global
	String sKey = ".VoiceType"
	Return vFF_API_Character.GetCharacterForm(asSID,sKey) as VoiceType
EndFunction

; Get the CombatStyle of the Character
CombatStyle Function GetCharacterCombatStyle(String asSID) Global
	String sKey = ".Class"
	Return vFF_API_Character.GetCharacterForm(asSID,sKey) as CombatStyle
EndFunction

; Return an array of all perks on a saved character. 
Form[] Function GetCharacterPerks(String asSID) Global
	String sKey = ".Perks"
	Int jPerksArray = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jPerksArray > 0 && JValue.IsArray(jPerksArray)
		Form[] kPerkArray = Utility.CreateFormArray(JArray.Count(jPerksArray), None)
		Int i = JArray.Count(jPerksArray)
		While i > 0
			i -= 1
			kPerkArray[i] = JArray.GetForm(jPerksArray,i) as Perk
		EndWhile
		Return kPerkArray
	EndIf
	Return New Form[1]
EndFunction

; Return an array of all Spells on a saved character. 
Form[] Function GetCharacterSpells(String asSID) Global
	String sKey = ".Spells"
	Int jSpellsArray = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jSpellsArray > 0 && JValue.IsArray(jSpellsArray)
		Form[] kSpellArray = Utility.CreateFormArray(JArray.Count(jSpellsArray), None)
		Int i = JArray.Count(jSpellsArray)
		While i > 0
			i -= 1
			kSpellArray[i] = JArray.GetForm(jSpellsArray,i) as Spell
		EndWhile
		Return kSpellArray
	EndIf
	Return New Form[1]
EndFunction

; Return an array of all Shouts on a saved character. 
Form[] Function GetCharacterShouts(String asSID) Global
	String sKey = ".Shouts"
	Int jShoutsArray = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jShoutsArray > 0 && JValue.IsArray(jShoutsArray)
		Form[] kShoutArray = Utility.CreateFormArray(JArray.Count(jShoutsArray), None)
		Int i = JArray.Count(jShoutsArray)
		While i > 0
			i -= 1
			kShoutArray[i] = JArray.GetForm(jShoutsArray,i) as Shout
		EndWhile
		Return kShoutArray
	EndIf
	Return New Form[1]
EndFunction

; Return an array of all inventory items of type aiType on a saved character. 
Form[] Function GetCharacterInventory(String asSID, Int aiType) Global
	String sKey = ".Inventory." + aiType
	Int jInventoryFormMap = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jInventoryFormMap > 0 && JValue.IsFormMap(jInventoryFormMap)
		Int jInventoryItems = JFormMap.AllKeys(jInventoryFormMap)
		Form[] kInventoryArray = New Form[128] ;FIXME: utililty.CreateFormArray causes "Cannot access an element of a None array" in the while loop
		Int i = JArray.Count(jInventoryItems)
		If i > 128
			i = 128
		EndIf
		While i > 0
			i -= 1
			kInventoryArray[i] = JArray.GetForm(jInventoryItems,i)
		EndWhile
		Return kInventoryArray
	EndIf
	Return New Form[1]
EndFunction

; Return an array of all item counts of type aiType on a saved character. Order will be the same as GetCharacterInventory
Int[] Function GetCharacterInventoryCounts(String asSID, Int aiType) Global
	String sKey = ".Inventory." + aiType
	Int jInventoryFormMap = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jInventoryFormMap > 0 && JValue.IsFormMap(jInventoryFormMap)
		Int jInventoryCounts = JFormMap.AllValues(jInventoryFormMap)
		Int[] iInventoryCounts = New Int[128] ;FIXME: utililty.CreateFormArray causes "Cannot access an element of a None array" in the while loop
		Int i = JArray.Count(jInventoryCounts)
		If i > 128
			i = 128
		EndIf
		While i > 0
			i -= 1
			iInventoryCounts[i] = JArray.GetInt(jInventoryCounts,i)
		EndWhile
		Return iInventoryCounts
	EndIf
	Return New Int[1]
EndFunction

; Return an array of all BASE armor equipped by a saved character. To recreate customized forms, use GetCharacterObjectID and ItemAPI.LoadSerializedEquipment.
Form[] Function GetCharacterArmor(String asSID) Global
	String sKey = ".Equipment.Armor"
	Int jArmorsArray = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jArmorsArray > 0 && JValue.IsArray(jArmorsArray)
		Form[] kArmorArray = Utility.CreateFormArray(JArray.Count(jArmorsArray), None)
		Int i = JArray.Count(jArmorsArray)
		While i > 0
			i -= 1
			kArmorArray[i] = JArray.GetForm(jArmorsArray,i) as Armor
		EndWhile
		Return kArmorArray
	EndIf
	Return New Form[1]
EndFunction

; Returns the base form equipped in the saved character's specified location
; 0 - left hand
; 1 - right hand
; 2 - shout
Form Function GetCharacterEquippedForm(String asSID, Int aiLocation) Global
	String sLocation = "Left"
	If aiLocation == 1
		sLocation = "Right"
	ElseIf aiLocation == 2
		sLocation = "Voice"
	EndIf
	String sKey = ".Equipment." + sLocation + ".Form"
	Return vFF_API_Character.GetCharacterForm(asSID,sKey)
EndFunction

;=== Functions for use with ItemAPI

; Return an array of all armor IDs equipped by a saved character. 
Int[] Function GetCharacterArmorIDs(String asSID) Global
	String sKey = ".Equipment.ArmorInfo"
	Int jArmorsArray = vFF_API_Character.GetCharacterObj(asSID,sKey)
	If jArmorsArray > 0 && JValue.IsArray(jArmorsArray)
		Int[] iArmorArray = Utility.CreateIntArray(JArray.Count(jArmorsArray), 0)
		Int i = JArray.Count(jArmorsArray)
		While i > 0
			i -= 1
			iArmorArray[i] = JArray.GetObj(jArmorsArray,i)
		EndWhile
		Return iArmorArray
	EndIf
	Return New Int[1]
EndFunction

; Returns the JMap of the item equipped in the saved character's specified location
; 0 - left hand
; 1 - right hand
; 2 - shout
Int Function GetCharacterEquippedFormObj(String asSID, Int aiLocation) Global
	String sLocation = "Left"
	If aiLocation == 1
		sLocation = "Right"
	ElseIf aiLocation == 2
		sLocation = "Voice"
	EndIf
	String sKey = ".Equipment." + sLocation
	Return vFF_API_Character.GetCharacterObj(asSID,sKey)
EndFunction

; Returns the ItemID of the item equipped in the saved character's specified location
; 0 - left hand
; 1 - right hand
; 2 - shout
String Function GetCharacterEquippedFormID(String asSID, Int aiLocation) Global
	String sLocation = "Left"
	If aiLocation == 1
		sLocation = "Right"
	ElseIf aiLocation == 2
		sLocation = "Voice"
	EndIf
	String sKey = ".Equipment." + sLocation + ".UUID"
	Return vFF_API_Character.GetCharacterStr(asSID,sKey)
EndFunction

;=============================---
; API Set Functions 
;=============================---

;Set the level of the saved character
Int Function SetCharacterLevel(String asSID, Float afValue) Global
	String sKey = ".Info.Level"
	Return vFF_API_Character.SetCharacterFlt(asSID,sKey,afValue)
EndFunction

;Set the specified ActorValue for the character 
Int Function SetCharacterAV(String asSID, String asValueName, Float afValue) Global
	String sKey = ".Stats.AV." + asValueName
	Return vFF_API_Character.SetCharacterFlt(asSID,sKey,afValue)
EndFunction

;Set this character's Race
Int Function SetCharacterRace(String asSID, Race akValue) Global
	String sKey = ".Info.Race"
	Return vFF_API_Character.SetCharacterForm(asSID,sKey,akValue)
EndFunction

; Returns this Character's name.
Int Function SetCharacterName(String asSID, String asValue) Global
	String sKey = ".Info.Name"
	Return vFF_API_Character.SetCharacterStr(asSID,sKey,asValue)
EndFunction

; Returns this Character's sex. Values for sex are:
; -1 - None
; 0 - Male
; 1 - Female
Int Function SetCharacterSex(String asSID, Int aiValue) Global
	String sKey = ".Info.Sex"
	Return vFF_API_Character.SetCharacterInt(asSID,sKey,aiValue)
EndFunction

; Set the Class of the Character
Int Function SetCharacterClass(String asSID, Class akValue) Global
	String sKey = ".Class"
	Return vFF_API_Character.SetCharacterForm(asSID,sKey,akValue)
EndFunction

; Set the VoiceType of the Character
Int Function SetCharacterVoiceType(String asSID, VoiceType akValue) Global
	String sKey = ".VoiceType"
	Return vFF_API_Character.SetCharacterForm(asSID,sKey,akValue)
EndFunction

; Set the CombatStyle of the Character
Int Function SetCharacterCombatStyle(String asSID, CombatStyle akValue) Global
	String sKey = ".CombatStyle"
	Return vFF_API_Character.SetCharacterForm(asSID,sKey, akValue)
EndFunction

; Set an array of all perks on a saved character. 
Int Function SetCharacterPerks(String asSID, Form[] akArray) Global
	String sKey = ".Perks"
	Int i = akArray.Length
	Int jNewArray = JArray.ObjectWithSize(i)
	While i > 0
		i -= 1
		JArray.SetForm(jNewArray,i,akArray[i])
	EndWhile
	Return vFF_API_Character.SetCharacterObj(asSID,sKey,jNewArray)
EndFunction

; Set an array of all Spells on a saved character. 
Int Function SetCharacterSpells(String asSID, Form[] akArray) Global
	String sKey = ".Spells"
	Int i = akArray.Length
	Int jNewArray = JArray.ObjectWithSize(i)
	While i > 0
		i -= 1
		JArray.SetForm(jNewArray,i,akArray[i])
	EndWhile
	Return vFF_API_Character.SetCharacterObj(asSID,sKey,jNewArray)
EndFunction

; Set an array of all Shouts on a saved character. 
Int Function SetCharacterShouts(String asSID, Form[] akArray) Global
	String sKey = ".Shouts"
	Int i = akArray.Length
	Int jNewArray = JArray.ObjectWithSize(i)
	While i > 0
		i -= 1
		JArray.SetForm(jNewArray,i,akArray[i])
	EndWhile
	Return vFF_API_Character.SetCharacterObj(asSID,sKey,jNewArray)
EndFunction

;=============================---
; API Serialization Functions 
;=============================---

String Function SerializeActor(Actor akActor) Global


EndFunction

; FIXME: These should probably never exist. Equipment should always be set from a real actor, otherwise it's too easy to lose data

;; Set an array of all BASE armor equipped by a saved character. 
;Int Function SetCharacterArmor(String asSID, Form[] akArray) Global
;	String sKey = ".Equipment.Armor"
;	Int i = akArray.Length
;	Int jNewArray = JArray.ObjectWithSize(i)
;	While i > 0
;		i -= 1
;		JArray.SetForm(jNewArray,i,akArray[i])
;	EndWhile
;	Return vFF_API_Character.SetCharacterObj(asSID,sKey,jNewArray)
;EndFunction
;
;; Set the form equipped in the saved character's specified location
;; 0 - left hand
;; 1 - right hand
;; 2 - shout
;Int Function SetCharacterEquippedForm(String asSID, Int aiLocation, Form akValue) Global
;	String sLocation = "Left"
;	If aiLocation == 1
;		sLocation = "Right"
;	ElseIf aiLocation == 2
;		sLocation = "Voice"
;	EndIf
;	String sKey = ".Equipment." + sLocation + ".Form"
;	Return vFF_API_Character.SetCharacterForm(asSID,sKey,akValue)
;EndFunction


;=============================---
; API Advanced Functions 
;=============================---

;Delete a saved character from the registry. Use with caution!
Int Function DeleteCharacter(String asSID)
	Int iRet = -1 ; Default error if nothing is found
	Int jCharacterData = vFF_API_Character.GetCharacterJMap(asSID)
	If jCharacterData <= 0
		Return jCharacterData
	Else
		jCharacterData = 0
		String sRegKey = "Characters." + asSID
		SetRegObj(sRegKey,0)
		Return 1
	EndIf
	Return iRet
EndFunction

Function DebugTraceAPIChar(String sDebugString, Int iSeverity = 0) Global
	Debug.Trace("vFF/API/Character: " + sDebugString,iSeverity)
EndFunction
