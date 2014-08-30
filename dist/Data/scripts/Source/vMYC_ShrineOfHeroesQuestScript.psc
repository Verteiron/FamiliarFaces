Scriptname vMYC_ShrineOfHeroesQuestScript extends Quest
{Handle reservations of the various Alcoves, and assign characters to them. Data stored separately from characters.}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

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

String	Property	DataPath	Auto Hidden

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

Bool	_bShrineNeedsReset = False

Bool	_bNoTick = False
;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_AlcoveStatusUpdate","OnAlcoveStatusUpdate")
	RegisterForModEvent("vMYC_ShrineReady","OnShrineReady")
	
	If IsRunning()
		_bDoInit = True
		RegisterForSingleUpdate(0.1)
	EndIf
EndEvent

Event OnUpdate()
	If _bShrineNeedsReset
		_bShrineNeedsReset = False
		Ready = False
		Int i = AlcoveControllers.Length
		While i > 0
			i -= 1
			AlcoveControllers[i].ResetAlcove()
		EndWhile
		JValue.WriteToFile(JMap.Object(),JContainers.userDirectory() + "vMYC/_ShrineOfHeroes.json")
		SyncShrineData()
		;DoInit(True)
		DoUpkeep(False)
	EndIf
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
	RegisterForSingleUpdate(10)
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
	UpdateShrineStatus()
EndEvent

Event OnConfigUpdate(String asConfigPath)
	Debug.Trace("MYC/Shrine: OnConfigUpdate(" + asConfigPath + ")")
	If asConfigPath == "DEBUG_SHRINE_RESET"
		_bShrineNeedsReset = GetConfigBool("DEBUG_SHRINE_RESET")
		RegisterForSingleUpdate(0.5)
	EndIf
EndEvent


;--=== Functions ===--

Function UpdateShrineStatus()
	Bool bReady = True
	Int i = AlcoveState.Length
	While i > 0
		i -= 1
		If !AlcoveControllers[i]
			bReady = False
		Else
			If AlcoveState[i] == 1 || AlcoveControllers[i].AlcoveIndex < 0
				bReady = False
			EndIf
		EndIf
	EndWhile
	If Ready != bReady
		Debug.Trace("MYC/Shrine: Ready: " + bReady)
		Ready = bReady
		SendModEvent("vMYC_ShrineReady","",bReady as Int)
	EndIf
EndFunction

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
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	Bool bUpdateNames = SyncShrineData()
	Int i = AlcoveControllers.Length
	While i > 0
		i -= 1
		If AlcoveControllers[i]
			AlcoveControllers[i].DoUpkeep()
		EndIf
	EndWhile
	SendModEvent("vMYC_AlcoveValidateState")
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Event OnShrineReady(string eventName, string strArg, float numArg, Form sender)
{When Shrine's ready state changes. numArg 0 or 1.}
	If numArg
		vMYC_PortalStoneQuest.Start()
	EndIf
EndEvent

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
	Bool bShrineDataUpdated = False
	
	Int jShrineFileData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/_ShrineOfHeroes.json")
	If !jShrineFileData
		jShrineFileData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
		JValue.WriteToFile(jShrineFileData,JContainers.userDirectory() + "vMYC/_ShrineOfHeroes.json")
	EndIf
	
	Int DataSerial = ShrineDataSerial ;JMap.getInt(_jShrineData,"DataSerial")
	JMap.SetInt(_jShrineData,"DataSerial",ShrineDataSerial)
	
	Int DataFileSerial = JMap.getInt(jShrineFileData,"DataSerial")
	;Debug.Trace("MYC/Shrine: DataSerial is " + DataSerial + ", DataFileSerial is " + DataFileSerial)
	If !jShrineFileData && DataSerial
		GotoState("SyncLocked")
		Debug.Trace("MYC/Shrine: Shrine data file was deleted, blanking out the Shrine...",1)
		InitShrineData()
		JMap.setObj(_jMYC,"ShrineOfHeroes",_jShrineData)
		ShrineDataSerial += 1
		DataSerial = ShrineDataSerial
		GotoState("")
	EndIf
	If DataSerial > DataFileSerial
		Debug.Trace("MYC/Shrine: Our data is newer than the saved file, overwriting it!")
		;JValue.WriteToFile(_jShrineData,"Data/vMYC/_ShrineOfHeroes.json")
		JValue.WriteToFile(_jShrineData,JContainers.userDirectory() + "vMYC/_ShrineOfHeroes.json")
	ElseIf DataSerial < DataFileSerial
		Debug.Trace("MYC/Shrine: Our data is older than the saved file, loading it!")
		_jShrineData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/_ShrineOfHeroes.json")
		JMap.SetObj(_jMYC,"ShrineOfHeroes",_jShrineData)
		ShrineDataSerial = DataFileSerial
		bShrineDataUpdated = True
	Else
		;Already synced. Sunc?
	EndIf
	If bShrineDataUpdated
		SanityCheck()
	EndIf
	Return bShrineDataUpdated
	
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
EndFunction

Function DoShutdown()
	UnregisterForUpdate()
	UnregisterForModEvent("vMYC_AlcoveStatusUpdate")
	UnregisterForModEvent("vMYC_ShrineReady")
	UnregisterForModEvent("vMYC_ConfigUpdate")
	Int i = AlcoveControllers.Length
	While i > 0
		i -= 1
		If AlcoveControllers[i].CharacterSummoned
			Int iHandle = ModEvent.Create("vMYC_AlcoveToggleSummoned")
			If iHandle	
				ModEvent.PushInt(iHandle,AlcoveControllers[i].AlcoveIndex)
				ModEvent.PushBool(iHandle,False)
				ModEvent.Send(iHandle)
			EndIf
		EndIf
	EndWhile
	WaitMenuMode(2)
	InitShrineData()
	i = AlcoveControllers.Length
	While i > 0
		i -= 1
		If AlcoveControllers[i].AlcoveActor
			AlcoveControllers[i].ReleaseActor()
		EndIf
	EndWhile
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
