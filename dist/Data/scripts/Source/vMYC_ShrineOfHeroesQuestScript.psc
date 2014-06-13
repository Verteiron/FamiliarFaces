Scriptname vMYC_ShrineOfHeroesQuestScript extends Quest  
{Handle reservations of the various Alcoves, and assign characters to them. Data stored separately from characters.}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int	Property ShrineDataSerial Auto Hidden
;{Serial of the shrine data, ticked whenever data gets changed.}
;	Int Function Get()
;		Return _iShrineDataSerial
;	EndFunction
;	Function Set(Int iShrineDataSerial)
;		_iShrineDataSerial = iShrineDataSerial
;		SyncShrineData()
;	EndFunction
;EndProperty

Bool Property Ready Auto Hidden

vMYC_CharacterManagerScript Property CharacterManager Auto
{Character manager}

Quest 			 Property vMYC_PortalStoneQuest	Auto

ReferenceAlias[] Property Alcoves Auto
ReferenceAlias	 Property ShrineOwner Auto
ReferenceAlias	 Property ShrineBook Auto

Int[]			 Property AlcoveState Auto 
{0 = Empty, 1 = Loading, 2 = Ready, 3 = Summoned, 4 = Error}

Actor Property PlayerRef Auto
{The Player, duh}

;--=== Config variables ===--

;--=== Variables ===--

Int		_jAlcovesData
Int		_jMYC

Int		_iShrineDataSerial

Bool	_bDoInit
Bool	_bDoUpkeep
Bool 	_bReady

Bool 	_bNeedSync

;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_AlcoveshrineStatusUpdate","OnAlcoveshrineStatusUpdate")
	If IsRunning()
		_bDoInit = True
		RegisterForSingleUpdate(0.1)
	EndIf
EndEvent

Event OnUpdate()
	If _bDoInit
		_bDoInit = False
		DoInit()
		DoUpkeep(False)
		Ready = True
	EndIf
	If _bDoUpkeep
		_bDoUpkeep = False
		DoUpkeep(False)
	EndIf
	If _bNeedSync
		_bNeedSync = False
		SyncShrineData()
	EndIf
EndEvent

Event OnAlcoveshrineStatusUpdate(string eventName, string strArg, float numArg, Form sender)
	AlcoveState[(sender as vMYC_ShrineAlcoveController).AlcoveIndex] = strArg as Int
	Int i = AlcoveState.Length
	Bool bAllReady = True
	While i > 0
		i -= 1
		If AlcoveState[i] == 1 ; Shrine is loading 
			bAllReady = False
		EndIf
	EndWhile
	If bAllReady
		SendModEvent("vMYC_AllAlcovesReady",1,CharacterManager.CharacterNames.Length)
		Debug.Trace("MYC: ====================== DINGDINGDINGDINGDINGDINGDING ALL Alcoves READY W00pw00pw00pw00p! ===============")
		vMYC_PortalStoneQuest.Start()
	Else 
		SendModEvent("vMYC_AllAlcovesReady",0)
		;Debug.Trace("MYC: ====================== W00pw00pw00pw00p Alcoves NOT READY :(((((((((((((((( ===============")
	EndIf
	JValue.WriteToFile(_jAlcovesData,"Data/vMYC/_ShrineOfHeroes.json")
EndEvent

;--=== Functions ===--

Function DoUpkeep(Bool bInBackground = True)
	If bInBackground
		Debug.Trace("MYC/Shrine: DoUpkeep will launch in a separate thread.")
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.1)
		Return
	EndIf
	SendModEvent("vMYC_UpkeepBegin")
	RegisterForModEvent("vMYC_AlcovestatusUpdate","OnAlcovestatusUpdate")
	If SyncShrineData()
		UpdateShrineNames()
	EndIf
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Function SetShrineCharacterName(Int iAlcoveIndex, String sCharacterName)
	Debug.Trace("MYC/Shrine: Setting Shrine #" + iAlcoveIndex + " to character " + sCharacterName + "!")
	Int jShrine = JValue.solveObj(_jMYC,".ShrineOfHeroes.Shrine" + iAlcoveIndex)
	String sOldName = JMap.getStr(jShrine,"CharacterName")
	JMap.setStr(jShrine,"CharacterName",sCharacterName)
	If sCharacterName != sOldName
		TickDataSerial()
	EndIf
EndFunction

Function UpdateShrineNames()
	Int jShrineArray = JMap.getObj(_jAlcovesData,"ShrineForms")
	Int i = JArray.Count(jShrineArray)
	While i > 0
		i -= 1
		String sCharacterName = JValue.solveStr(_jAlcovesData,".Shrine" + i + ".CharacterName")
		Debug.Trace("MYC/Shrine: Alcove" + i + ".Form is " + JValue.solveForm(_jAlcovesData,".Shrine" + i + ".Form") + "!")
		JArray.getForm(jShrineArray,i)
		vMYC_ShrineAlcoveController kShrine = JArray.getForm(jShrineArray,i) as vMYC_ShrineAlcoveController
		Debug.Trace("MYC/Shrine: Alcove" + i + " CharacterName (from shrine) is " + kShrine.CharacterName + " and should be " + sCharacterName + "!")
		If sCharacterName != kShrine.CharacterName
			kShrine.CharacterName = sCharacterName
		EndIf
	EndWhile
EndFunction

String Function GetShrineCharacterName(Int iAlcoveIndex)
	Return JValue.solveStr(_jAlcovesData,".Shrine" + iAlcoveIndex + ".CharacterName")
EndFunction

Int Function GetAlcoveIndex(String asCharacterName)
	Int i = JMap.Count(_jAlcovesData)
	While i > 0
		i -= 1
		String sCharacterName = JValue.solveStr(_jAlcovesData,".Shrine" + i + ".CharacterName")
		If sCharacterName == asCharacterName
			Return i
		EndIf
	EndWhile
	Return -1
EndFunction

vMYC_ShrineAlcoveController Function GetAlcoveByIndex(Int iAlcoveIndex)
	Return JValue.solveForm(_jAlcovesData,".Shrine" + iAlcoveIndex + ".Form") as vMYC_ShrineAlcoveController
EndFunction

Bool Function SyncShrineData(Bool abForceLoadFile = False, Bool abRewriteFile = False)
	JMap.setInt(_jAlcovesData,"DataSerial",ShrineDataSerial)
	Int jSavedShrineData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
	JValue.Retain(jSavedShrineData)
	Int iSavedDataSerial
	If jSavedShrineData 
		Debug.Trace("MYC/Shrine: Found saved data!")
		If JMap.hasKey(jSavedShrineData,"DataSerial")
			iSavedDataSerial = JMap.getInt(jSavedShrineData,"DataSerial")
		Else
			Debug.Trace("MYC/Shrine: Shrine data is from an older version, forcing an update...")
			abForceLoadFile = True
			abRewriteFile = True
		EndIf
		Debug.Trace("MYC/Shrine: Saved data serial is " + iSavedDataSerial + ", our data serial is " + ShrineDataSerial)
		If abForceLoadFile
			Debug.Trace("MYC/Shrine: ForceLoadFile set, loading from file regardless...")
			iSavedDataSerial = ShrineDataSerial + 1
		EndIf
		If iSavedDataSerial > ShrineDataSerial
			Debug.Trace("MYC/Shrine: Our data is old, updating it to saved version!")
			JMap.setObj(_jMYC,"ShrineOfHeroes",jSavedShrineData)
			_jAlcovesData = JMap.getObj(_jMYC,"ShrineOfHeroes")
		ElseIf iSavedDataSerial < ShrineDataSerial
			Debug.Trace("MYC/Shrine: Our data is newer than the saved data, so we'll save it to the file.")
			JValue.WriteToFile(_jAlcovesData,"Data/vMYC/_ShrineOfHeroes.json")
			iSavedDataSerial = ShrineDataSerial
		Else
			Debug.Trace("MYC/Shrine: Data is already synced. Sunc?")
		EndIf
	ElseIf JValue.hasPath(_jMYC,".ShrineOfHeroes")
		Debug.Trace("MYC/Shrine: No saved data, but found data in _jMYC!",1)
		_jAlcovesData = JValue.solveObj(_jMYC,".ShrineOfHeroes")
		JValue.WriteToFile(_jAlcovesData,"Data/vMYC/_ShrineOfHeroes.json")
		iSavedDataSerial = ShrineDataSerial
	EndIf
	If abRewriteFile
		TickDataSerial()
		JValue.WriteToFile(_jAlcovesData,"Data/vMYC/_ShrineOfHeroes.json")
	EndIf
	JValue.Release(jSavedShrineData)
	If ShrineDataSerial != iSavedDataSerial
		Debug.Trace("MYC/Shrine: Data serial mismatch, Alcoves need to be updated!")
		ShrineDataSerial = iSavedDataSerial
		Return True
	EndIf
	Return False
EndFunction

Function TickDataSerial(Bool abForceSync = False)
	ShrineDataSerial += 1
	JMap.setInt(_jAlcovesData,"DataSerial",ShrineDataSerial)
	Debug.Trace("MYC/Shrine: Ticking Shrine Data from " + (ShrineDataSerial - 1) + " to " + ShrineDataSerial)
	If abForceSync
		SyncShrineData()
	Else
		_bNeedSync = True
		RegisterForSingleUpdate(5)
	EndIf
	;	SyncShrineData()
EndFunction

Function DoInit(Bool abForce = False)
	AlcoveState = New Int[12]
	_jMYC = CharacterManager.jMYC
	Bool bSyncResult = SyncShrineData()
	If _jAlcovesData && abForce
		Debug.Trace("MYC/Shrine: abForce == True, data exists but will be overwritten!",1)
	EndIf
	If !_jAlcovesData || abForce
		Debug.Trace("MYC/Shrine: No saved data, initializing from scratch!")	
		InitShrineData()
	EndIf
	JMap.setObj(_jMYC,"ShrineOfHeroes",_jAlcovesData)
	UpdateShrineRefs()
	TickDataSerial()
EndFunction

Function InitShrineData()
	_jAlcovesData = JMap.Object()
	Int jShrineRefs = JArray.Object()
	JMap.setObj(_jAlcovesData,"ShrineForms",jShrineRefs)
	Int i = Alcoves.Length
	While i > 0
		i -=1
		JArray.addForm(jShrineRefs,Alcoves[i].GetReference())
		
		Int jShrine = JMap.Object()
		JMap.setInt(jShrine,"Index",i)
		JMap.setInt(jShrine,"State",0)
		JMap.setForm(jShrine,"Form",Alcoves[i].GetReference())
		JMap.setStr(jShrine,"CharacterName","")
		JMap.setObj(_jAlcovesData,"Shrine" + i,jShrine)
	EndWhile
	SetShrineCharacterNames()
EndFunction

Function UpdateShrineRefs()
	Int jShrineRefs = JMap.getObj(_jAlcovesData,"ShrineForms")
	Int i = Alcoves.Length
	If i != JArray.count(jShrineRefs)
		Debug.Trace("MYC/Shrine: Current Shrine count doesn't equal saved count!",1)
		;FIXME: Handle this gracefully!
	EndIf
	Debug.Trace("MYC/Shrine: Setting initial shrine data...")
	i = Alcoves.Length
	While i > 0
		i -= 1
		(JArray.getForm(jShrineRefs,i) as vMYC_ShrineAlcoveController).AlcoveIndex = JValue.solveInt(_jAlcovesData,".Shrine" + i + ".Index")
	EndWhile
EndFunction

Function SetShrineCharacterNames()
	String[] sCharacterNames = CharacterManager.CharacterNames
	Int i = Alcoves.Length
	If i > sCharacterNames.Length
		i = sCharacterNames.Length
	EndIf
	While i > 0
		i -= 1
		Int jShrine = JValue.solveObj(_jMYC,".ShrineOfHeroes.Shrine" + i)
		JMap.setStr(jShrine,"CharacterName",sCharacterNames[i])
		vMYC_ShrineAlcoveController kAlcoveshrine = JMap.getForm(jShrine,"Form") as vMYC_ShrineAlcoveController
		If kAlcoveshrine.CharacterName != sCharacterNames[i]
			kAlcoveshrine.CharacterName = sCharacterNames[i]
		EndIf
	EndWhile
EndFunction

Int Function CreateAlcoveDataIfMissing(Int aiAlcoveIndex)
	Int jAlcove = JMap.getObj(_jAlcovesData,"Alcove" + aiAlcoveIndex)
	If jAlcove
		Return jAlcove
	EndIf
	;Debug.Trace("MYC: (" + aiAlcoveIndex + ") First Alcove data access, creating AlcoveData key!")
	jAlcove = JMap.Object()
	JMap.setObj(_jAlcovesData,"Alcove" + aiAlcoveIndex,jAlcove)
	Return jAlcove
EndFunction

Function SetAlcovestring(Int aiAlcoveIndex, String asPath, String asString)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setStr(jAlcove,asPath,asString)
EndFunction

String Function GetAlcovestring(Int aiAlcoveIndex, String asPath)
	Return JValue.solveStr(_jMYC,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveInt(Int aiAlcoveIndex, String asPath, Int aiInt)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setInt(jAlcove,asPath,aiInt)
EndFunction

Int Function GetAlcoveInt(Int aiAlcoveIndex, String asPath)
	Return JValue.solveInt(_jMYC,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveFlt(Int aiAlcoveIndex, String asPath, Float afFloat)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setFlt(jAlcove,asPath,afFloat)
EndFunction

Float Function GetAlcoveFlt(Int aiAlcoveIndex, String asPath)
	Return JValue.solveFlt(_jMYC,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveForm(Int aiAlcoveIndex, String asPath, Form akForm)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setForm(jAlcove,asPath,akForm)
EndFunction

Form Function GetAlcoveForm(Int aiAlcoveIndex, String asPath)
	Return JValue.solveForm(_jMYC,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveObj(Int aiAlcoveIndex, String asPath, Int ajObj)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setObj(jAlcove,asPath,ajObj)
EndFunction

Int Function GetAlcoveObj(Int aiAlcoveIndex, String asPath)
	Return JValue.solveObj(_jMYC,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction
