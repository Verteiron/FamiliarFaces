Scriptname vMYC_ShrineOfHeroesQuestScript extends Quest
{Handle reservations of the various Alcoves, and assign characters to them. Data stored separately from characters.}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int	Property ShrineDataSerial Auto Hidden

Bool Property Ready Auto Hidden

vMYC_CharacterManagerScript Property CharacterManager Auto
{Character manager}

Quest 			 Property vMYC_PortalStoneQuest	Auto

ReferenceAlias[] Property Alcoves Auto

ReferenceAlias	 Property ShrineOwner Auto
ReferenceAlias	 Property ShrineBook Auto

vMYC_ShrineAlcoveController[] Property AlcoveControllers Auto

Int[]			 Property AlcoveState Auto
{0 = Empty, 1 = Loading, 2 = Ready, 3 = Summoned, 4 = Error}

Actor Property PlayerRef Auto
{The Player, duh}

;--=== Config variables ===--

;--=== Variables ===--

Int		_jShrineData
Int		_jMYC

Int		_iShrineDataSerial

Bool	_bDoInit
Bool	_bDoUpkeep
Bool 	_bReady

Bool 	_bNeedSync

Bool	_bShrineNeedsUpdate = False

Bool	_bNoTick = False
;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_AlcoveStatusUpdate","OnAlcoveStatusUpdate")
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
	If _bShrineNeedsUpdate
		_bShrineNeedsUpdate = False
		SendModEvent("vMYC_AlcoveValidateState")
	EndIf
	SendModEvent("vMYC_RequestLatencyCheck","",10)
	RegisterForSingleUpdate(10) ; Make sure alcoves aren't stuck
EndEvent

Event OnAlcoveStatusUpdate(string eventName, string strArg, float numArg, Form sender)
	If !AlcoveState
		Return
	EndIf
	If !AlcoveControllers[(sender as vMYC_ShrineAlcoveController).AlcoveIndex]
		AlcoveControllers[(sender as vMYC_ShrineAlcoveController).AlcoveIndex] = sender as vMYC_ShrineAlcoveController
	EndIf
	If AlcoveState[(sender as vMYC_ShrineAlcoveController).AlcoveIndex] != strArg as Int
		AlcoveState[(sender as vMYC_ShrineAlcoveController).AlcoveIndex] = strArg as Int
		SyncShrineData()
	EndIf
EndEvent

;--=== Functions ===--

Function DoUpkeep(Bool bInBackground = True)
	If bInBackground
		;Debug.Trace("MYC/Shrine: DoUpkeep will launch in a separate thread.")
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.1)
		Return
	EndIf
	SendModEvent("vMYC_UpkeepBegin")
	RegisterForModEvent("vMYC_AlcovestatusUpdate","OnAlcovestatusUpdate")
	RegisterForModEvent("vMYC_ShrineNeedsUpdate","OnShrineNeedsUpdate")
	Bool bUpdateNames = SyncShrineData()
	Int i = AlcoveControllers.Length
	While i > 0
		i -= 1
		If AlcoveControllers[i]
			AlcoveControllers[i].DoUpkeep()
		EndIf
	EndWhile
	If bUpdateNames
		SendModEvent("vMYC_AlcoveValidateState")
	EndIf
	StartPortalStoneQuestIfNeeded()
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Event OnShrineNeedsUpdate(string eventName, string strArg, float numArg, Form sender)
	_bShrineNeedsUpdate = True
	RegisterForSingleUpdate(1)
EndEvent

String Function GetAlcoveCharacterName(Int iAlcoveIndex)
	Return JValue.solveStr(_jShrineData,".Alcove" + iAlcoveIndex + ".CharacterName")
EndFunction

Int Function GetAlcoveIndex(String asCharacterName)
	Int i = 0
	Int iCount = JMap.Count(_jShrineData)
	While i < iCount
		String sCharacterName = JValue.solveStr(_jShrineData,".Alcove" + i + ".CharacterName")
		If sCharacterName == asCharacterName
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

vMYC_ShrineAlcoveController Function GetAlcoveByIndex(Int iAlcoveIndex)
	Return JValue.solveForm(_jShrineData,".Alcove" + iAlcoveIndex + ".Controller") as vMYC_ShrineAlcoveController
EndFunction

Function SanityCheck()
{Read through the alcoves and remove duplicate names.}
	Int i = 0
	String[] sUsedNames = New String[32]
	While i < AlcoveControllers.Length
		String sName = JValue.solveStr(_jShrineData,".Alcove" + i + ".CharacterName")
		If sName
			If sUsedNames.Find(sName) < 0
				sUsedNames[i] = sName
			Else
				Debug.Trace("MYC/Shrine: WARNING! Duplicate name '" + sName + "' detected in Alcove " + i + "! Clearing it.",1)
				JValue.solveStrSetter(_jShrineData,".Alcove" + i + ".CharacterName","")
			EndIf
		EndIf
		i += 1
	EndWhile

EndFunction

Bool Function SyncShrineData(Bool abForceLoadFile = False, Bool abRewriteFile = False)
	GotoState("SyncLocked")
	Bool bShrineDataUpdated = False
	
	Int jShrineFileData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
	Int DataSerial = ShrineDataSerial ;JMap.getInt(_jShrineData,"DataSerial")
	JMap.SetInt(_jShrineData,"DataSerial",ShrineDataSerial)
	
	Int DataFileSerial = JMap.getInt(jShrineFileData,"DataSerial")
	;Debug.Trace("MYC/Shrine: DataSerial is " + DataSerial + ", DataFileSerial is " + DataFileSerial)
	If !jShrineFileData && DataSerial
		Debug.Trace("MYC/Shrine: Shrine data file was deleted, blanking out the Shrine...")
		InitShrineData()
		JMap.setObj(_jMYC,"ShrineOfHeroes",_jShrineData)
		ShrineDataSerial += 1
		DataSerial = ShrineDataSerial
	EndIf
	If DataSerial > DataFileSerial
		Debug.Trace("MYC/Shrine: Our data is newer than the saved file, overwriting it!")
		JValue.WriteToFile(_jShrineData,"Data/vMYC/_ShrineOfHeroes.json")
		Debug.Trace("MYC/Shrine: File should be written now!")
	ElseIf DataSerial < DataFileSerial
		Debug.Trace("MYC/Shrine: Our data is older than the saved file, loading it!")
		_jShrineData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
		JMap.SetObj(_jMYC,"ShrineOfHeroes",_jShrineData)
		ShrineDataSerial = DataFileSerial
		bShrineDataUpdated = True
	Else
		;Already synced. Sunc?
	EndIf
	If bShrineDataUpdated
		SanityCheck()
	EndIf
	GotoState("")
	Return bShrineDataUpdated
	
;	JMap.setInt(_jShrineData,"DataSerial",ShrineDataSerial)
;	Int jSavedShrineData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
;	JValue.Retain(jSavedShrineData)
;	Int iSavedDataSerial
;	If jSavedShrineData
;		;Debug.Trace("MYC/Shrine: Found saved data!")
;		If JMap.hasKey(jSavedShrineData,"DataSerial")
;			iSavedDataSerial = JMap.getInt(jSavedShrineData,"DataSerial")
;		Else
;			;Debug.Trace("MYC/Shrine: Shrine data is from an older version, forcing an update...")
;			abForceLoadFile = True
;			abRewriteFile = True
;		EndIf
;		;Debug.Trace("MYC/Shrine: Saved data serial is " + iSavedDataSerial + ", our data serial is " + ShrineDataSerial)
;		If abForceLoadFile
;			Debug.Trace("MYC/Shrine: ForceLoadFile set, loading from file regardless...",1)
;			iSavedDataSerial = ShrineDataSerial + 1
;		EndIf
;		If iSavedDataSerial > ShrineDataSerial
;			;Debug.Trace("MYC/Shrine: Our data is old, updating it to saved version!")
;			JMap.setObj(_jMYC,"ShrineOfHeroes",jSavedShrineData)
;			_jShrineData = JMap.getObj(_jMYC,"ShrineOfHeroes")
;		ElseIf iSavedDataSerial < ShrineDataSerial
;			;Debug.Trace("MYC/Shrine: Our data is newer than the saved data, so we'll save it to the file.")
;			JValue.WriteToFile(_jShrineData,"Data/vMYC/_ShrineOfHeroes.json")
;			iSavedDataSerial = ShrineDataSerial
;		Else
;			;Debug.Trace("MYC/Shrine: Data is already synced. Sunc?")
;		EndIf
;	ElseIf JValue.hasPath(_jMYC,".ShrineOfHeroes")
;		If GetState() == "SyncLocked"
;			Return False
;		EndIf
;		GotoState("SyncLocked")
;		Debug.Trace("MYC/Shrine: No saved data, but found data in _jMYC! This means the file was deleted, so we'll blank out the shrine.",1)
;		Int iShrineDataSerial = ShrineDataSerial
;		Int i = 0
;		Int iCount = AlcoveControllers.Length
;		While i < iCount
;			Debug.Trace("MYC/Shrine: Resetting alcove " + i,1)
;			AlcoveControllers[i].ResetAlcove()
;			SetAlcoveInt(i,"State",0)
;			SetAlcoveStr(i,"CharacterName","")
;			i += 1
;		EndWhile
;		ShrineDataSerial = iShrineDataSerial + 1
;		JMap.setInt(_jShrineData,"DataSerial",ShrineDataSerial)
;		JValue.WriteToFile(_jShrineData,"Data/vMYC/_ShrineOfHeroes.json")
;		GotoState("")
;		i = 0
;		While i < iCount
;		;	Debug.Trace("MYC/Shrine: Activating alcove " + i,1)
;		;	AlcoveControllers[i].ActivateAlcove()
;			i += 1
;		EndWhile
;		iSavedDataSerial = ShrineDataSerial
;		JValue.WriteToFile(_jMYC,"Data/vMYC/_jMYC_postreset.json")
;		Return False
;	EndIf
;	If abRewriteFile
;		TickDataSerial()
;		JValue.WriteToFile(_jShrineData,"Data/vMYC/_ShrineOfHeroes.json")
;	EndIf
;	JValue.Release(jSavedShrineData)
;	If ShrineDataSerial != iSavedDataSerial
;		;Debug.Trace("MYC/Shrine: Data serial mismatch, Alcoves need to be updated!")
;		ShrineDataSerial = iSavedDataSerial
;		Return True
;	EndIf
	Return False
EndFunction

Function StartPortalStoneQuestIfNeeded()
	Int iCount = AlcoveState.Length
	Bool bAllReady = True
	Int i = 0
	While i < iCount
		If AlcoveState[i] == 1 ; Shrine is loading
			bAllReady = False
		EndIf
		i += 1
	EndWhile
	If bAllReady && ShrineDataSerial > 0
		SendModEvent("vMYC_AllAlcovesReady",1,CharacterManager.CharacterNames.Length)
		;Debug.Trace("MYC: ====================== DINGDINGDINGDINGDINGDINGDING ALL Alcoves READY W00pw00pw00pw00p! ===============")
		vMYC_PortalStoneQuest.Start()
	Else
		SendModEvent("vMYC_AllAlcovesReady",0)
		;Debug.Trace("MYC: ====================== W00pw00pw00pw00p Alcoves NOT READY :(((((((((((((((( ===============")
	EndIf
EndFunction

Function TickDataSerial(Bool abForceSync = False)
	If _bNoTick
		Return
	EndIf
	ShrineDataSerial += 1
	JMap.setInt(_jShrineData,"DataSerial",ShrineDataSerial)
	;Debug.Trace("MYC/Shrine: Ticking Shrine Data from " + (ShrineDataSerial - 1) + " to " + ShrineDataSerial)
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
	AlcoveControllers = New vMYC_ShrineAlcoveController[12]
	_jMYC = CharacterManager.jMYC
	Bool bSyncResult = SyncShrineData()
	If _jShrineData && abForce
		Debug.Trace("MYC/Shrine: abForce == True, data exists but will be overwritten!",1)
	EndIf
	If !_jShrineData || abForce
		;Debug.Trace("MYC/Shrine: No saved data, initializing from scratch!")
		InitShrineData()
	EndIf
	JMap.setObj(_jMYC,"ShrineOfHeroes",_jShrineData)
	TickDataSerial(True)
	UpdateAlcoveControllers()
	StartPortalStoneQuestIfNeeded()
EndFunction

Function InitShrineData()
	_jShrineData = JMap.Object()
	Int jAlcoveRefs = JArray.Object()
	JMap.setObj(_jShrineData,"AlcoveForms",jAlcoveRefs)
	Int i
	Int iCount = Alcoves.Length
	_bNoTick = True
	While i < iCount
		JArray.addForm(jAlcoveRefs,Alcoves[i].GetReference() as vMYC_ShrineAlcoveController)
		SetAlcoveInt(i,"Index",i)
		SetAlcoveInt(i,"State",0)
		SetAlcoveForm(i,"Controller",Alcoves[i].GetReference() as vMYC_ShrineAlcoveController)
		SetAlcoveStr(i,"CharacterName","")
		(Alcoves[i].GetReference() as vMYC_ShrineAlcoveController).AlcoveIndex = i
		i += 1
	EndWhile
	_bNoTick = False
	;SetAlcoveCharacterNames()
EndFunction

Function UpdateAlcoveControllers()
	Int jAlcoveRefs = JMap.getObj(_jShrineData,"AlcoveForms")
	Int iCount = Alcoves.Length
	If iCount != JArray.count(jAlcoveRefs)
		Debug.Trace("MYC/Shrine: Current Alcove count doesn't equal saved count!",1)
		;FIXME: Handle this gracefully!
	EndIf
	;Debug.Trace("MYC/Shrine: Setting Alcove data...")
	Int i = 0
	While i < iCount
		vMYC_ShrineAlcoveController kAlcove = GetAlcoveForm(i,"Controller") as vMYC_ShrineAlcoveController
		kAlcove.AlcoveIndex = GetAlcoveInt(i,"Index")
		kAlcove.CharacterName = GetAlcoveStr(i,"CharacterName")
		i += 1
	EndWhile
EndFunction

;==== Generic functions for get/setting alcove-specific data

Int Function CreateAlcoveDataIfMissing(Int aiAlcoveIndex)
	TickDataSerial()
	Int jAlcove = JMap.getObj(_jShrineData,"Alcove" + aiAlcoveIndex)
	If jAlcove
		Return jAlcove
	EndIf
	;Debug.Trace("MYC: (" + aiAlcoveIndex + ") First Alcove data access, creating AlcoveData key!")
	jAlcove = JMap.Object()
	JMap.setObj(_jShrineData,"Alcove" + aiAlcoveIndex,jAlcove)
	Return jAlcove
EndFunction

Function SetAlcoveStr(Int aiAlcoveIndex, String asPath, String asString)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setStr(jAlcove,asPath,asString)
EndFunction

String Function GetAlcoveStr(Int aiAlcoveIndex, String asPath)
	Return JValue.solveStr(_jShrineData,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveInt(Int aiAlcoveIndex, String asPath, Int aiInt)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setInt(jAlcove,asPath,aiInt)
EndFunction

Int Function GetAlcoveInt(Int aiAlcoveIndex, String asPath)
	Return JValue.solveInt(_jShrineData,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveFlt(Int aiAlcoveIndex, String asPath, Float afFloat)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setFlt(jAlcove,asPath,afFloat)
EndFunction

Float Function GetAlcoveFlt(Int aiAlcoveIndex, String asPath)
	Return JValue.solveFlt(_jShrineData,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveForm(Int aiAlcoveIndex, String asPath, Form akForm)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setForm(jAlcove,asPath,akForm)
EndFunction

Form Function GetAlcoveForm(Int aiAlcoveIndex, String asPath)
	Return JValue.solveForm(_jShrineData,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

Function SetAlcoveObj(Int aiAlcoveIndex, String asPath, Int ajObj)
	Int jAlcove = CreateAlcoveDataIfMissing(aiAlcoveIndex)
	JMap.setObj(jAlcove,asPath,ajObj)
EndFunction

Int Function GetAlcoveObj(Int aiAlcoveIndex, String asPath)
	Return JValue.solveObj(_jShrineData,".Alcove" + aiAlcoveIndex + "." + asPath)
EndFunction

State SyncLocked

	Bool Function SyncShrineData(Bool abForceLoadFile = False, Bool abRewriteFile = False)
		Return False
	EndFunction

EndState
