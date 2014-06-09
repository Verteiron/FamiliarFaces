Scriptname vMYC_ShrineOfHeroesQuestScript extends Quest  
{Handle reservations of the various shrines, and assign characters to them. Data stored separately from characters.}

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

ReferenceAlias[] Property Shrines Auto
ReferenceAlias	 Property ShrineOwner Auto
ReferenceAlias	 Property ShrineBook Auto

Int[]			 Property ShrineState Auto 
{0 = Empty, 1 = Loading, 2 = Ready, 3 = Summoned, 4 = Error}

Actor Property PlayerRef Auto
{The Player, duh}

;--=== Config variables ===--

;--=== Variables ===--

Int		_jShrinesData
Int		_jMYC

Int		_iShrineDataSerial

Bool	_bDoInit
Bool	_bDoUpkeep
Bool 	_bReady

;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_ShrineStatusUpdate","OnShrineStatusUpdate")
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
EndEvent

Event OnShrineStatusUpdate(string eventName, string strArg, float numArg, Form sender)
	ShrineState[(sender as vMYC_ShrineActivatorScript).ShrineIndex] = strArg as Int
	Int i = ShrineState.Length
	Bool bAllReady = True
	While i > 0
		i -= 1
		If ShrineState[i] == 1 ; Shrine is loading 
			bAllReady = False
		EndIf
	EndWhile
	If bAllReady
		SendModEvent("vMYC_AllShrinesReady",1,CharacterManager.CharacterNames.Length)
		Debug.Trace("MYC: ====================== DINGDINGDINGDINGDINGDINGDING ALL SHRINES READY W00pw00pw00pw00p! ===============")
		vMYC_PortalStoneQuest.Start()
	Else 
		SendModEvent("vMYC_AllShrinesReady",0)
		;Debug.Trace("MYC: ====================== W00pw00pw00pw00p Shrines NOT READY :(((((((((((((((( ===============")
	EndIf
	JValue.WriteToFile(_jShrinesData,"Data/vMYC/_ShrineOfHeroes.json")
EndEvent

;--=== Functions ===--

Function DoUpkeep(Bool bInBackground = True)
	If bInBackground
		Debug.Trace("MYC/ShrineOfHeroes: DoUpkeep will launch in a separate thread.")
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.1)
		Return
	EndIf
	SendModEvent("vMYC_UpkeepBegin")
	RegisterForModEvent("vMYC_ShrineStatusUpdate","OnShrineStatusUpdate")
	SyncShrineData()
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Function SetShrineCharacterName(Int iShrineIndex, String sCharacterName)
	Debug.Trace("MYC/ShrineOfHeroes: Setting Shrine #" + iShrineIndex + " to character " + sCharacterName + "!")
	Int jShrine = JValue.solveObj(_jMYC,".ShrineOfHeroes.Shrine" + iShrineIndex)
	String sOldName = JMap.getStr(jShrine,"CharacterName")
	JMap.setStr(jShrine,"CharacterName",sCharacterName)
	If sCharacterName != sOldName
		TickDataSerial()
	EndIf
EndFunction

String Function GetShrineCharacterName(Int iShrineIndex)
	Return JValue.solveStr(_jShrinesData,".Shrine" + iShrineIndex + ".CharacterName")
EndFunction

Int Function GetShrineIndex(String asCharacterName)
	Int i = JMap.Count(_jShrinesData)
	While i > 0
		i -= 1
		String sCharacterName = JValue.solveStr(_jShrinesData,".Shrine" + i + ".CharacterName")
		If sCharacterName == asCharacterName
			Return i
		EndIf
	EndWhile
	Return -1
EndFunction

Function SyncShrineData(Bool abForceLoadFile = False)
	JMap.setInt(_jShrinesData,"DataSerial",ShrineDataSerial)
	Int jSavedShrineData = JValue.ReadFromFile("Data/vMYC/_ShrineOfHeroes.json")
	Int iSavedDataSerial
	If jSavedShrineData 
		Debug.Trace("MYC/ShrineOfHeroes: Found saved data!")
		iSavedDataSerial = JMap.getInt(jSavedShrineData,"DataSerial")
		Debug.Trace("MYC/ShrineOfHeroes: Saved data serial is " + iSavedDataSerial + ", our data serial is " + ShrineDataSerial)
		If abForceLoadFile
			Debug.Trace("MYC/ShrineOfHeroes: ForceLoadFile set, loading from file regardless...")
			iSavedDataSerial = ShrineDataSerial + 1
		EndIf
		If iSavedDataSerial > ShrineDataSerial
			Debug.Trace("MYC/ShrineOfHeroes: Our data is old, updating it to saved version!")
			_jShrinesData = jSavedShrineData
		ElseIf iSavedDataSerial < ShrineDataSerial
			Debug.Trace("MYC/ShrineOfHeroes: Our data is newer than the saved data, so we'll save it to the file.")
			JValue.WriteToFile(_jShrinesData,"Data/vMYC/_ShrineOfHeroes.json")
		Else
			Debug.Trace("MYC/ShrineOfHeroes: Data is already synced. Sunc?")
		EndIf
	ElseIf JValue.hasPath(_jMYC,".ShrineOfHeroes")
		Debug.Trace("MYC/ShrineOfHeroes: No saved data, but found data in _jMYC!",1)
		_jShrinesData = JValue.solveObj(_jMYC,".ShrineOfHeroes")
		JValue.WriteToFile(_jShrinesData,"Data/vMYC/_ShrineOfHeroes.json")
	EndIf
	If ShrineDataSerial != iSavedDataSerial
		Debug.Trace("MYC/ShrineOfHeroes: Data serial mismatch, updating shrine alcoves...")
		SetShrineCharacterNames()
		ShrineDataSerial = iSavedDataSerial
	EndIf
EndFunction

Function TickDataSerial()
	ShrineDataSerial += 1
	JMap.setInt(_jShrinesData,"DataSerial",ShrineDataSerial)
	SyncShrineData()
EndFunction

Function DoInit(Bool abForce = False)
	ShrineState = New Int[12]
	_jMYC = CharacterManager.jMYC
	SyncShrineData()
	If _jShrinesData && abForce
		Debug.Trace("MYC/ShrineOfHeroes: abForce == True, data exists but will be overwritten!",1)
	EndIf
	If !_jShrinesData || abForce
		Debug.Trace("MYC/ShrineOfHeroes: No saved data, initializing from scratch!")	
		InitShrineData()
	EndIf
	JMap.setObj(_jMYC,"ShrineOfHeroes",_jShrinesData)
	UpdateShrineRefs()
	TickDataSerial()
	JValue.WriteToFile(_jMYC,"Data/vMYC/_jMYC.json")
EndFunction

Function UpdateShrineRefs()
	Int jShrineRefs = JMap.getObj(_jShrinesData,"ShrineForms")
	Int i = Shrines.Length
	If i != JArray.count(jShrineRefs)
		Debug.Trace("MYC/ShrineOfHeroes: Current Shrine count doesn't equal saved count!",1)
		;FIXME: Handle this gracefully!
	EndIf
	Debug.Trace("MYC/ShrineOfHeroes: Setting initial shrine data...")
	i = Shrines.Length
	While i > 0
		i -= 1
		(JArray.getForm(jShrineRefs,i) as vMYC_ShrineActivatorScript).ShrineIndex = JValue.solveInt(_jShrinesData,".Shrine" + i + ".Index")
	EndWhile
EndFunction

Function SetShrineCharacterNames()
	String[] sCharacterNames = CharacterManager.CharacterNames
	Int i = Shrines.Length
	If i > sCharacterNames.Length
		i = sCharacterNames.Length
	EndIf
	While i > 0
		i -= 1
		Int jShrine = JValue.solveObj(_jMYC,".ShrineOfHeroes.Shrine" + i)
		JMap.setStr(jShrine,"CharacterName",sCharacterNames[i])
		vMYC_ShrineActivatorScript kShrineAlcove = JMap.getForm(jShrine,"Form") as vMYC_ShrineActivatorScript
		If kShrineAlcove.CharacterName != sCharacterNames[i]
			kShrineAlcove.CharacterName = sCharacterNames[i]
		EndIf
	EndWhile
EndFunction

Function InitShrineData()
	_jShrinesData = JMap.Object()
	Int jShrineRefs = JArray.Object()
	JMap.setObj(_jShrinesData,"ShrineForms",jShrineRefs)
	Int i = Shrines.Length
	While i > 0
		i -=1
		JArray.addForm(jShrineRefs,Shrines[i].GetReference())
		Int jShrine = JMap.Object()
		JMap.setInt(jShrine,"Index",i)
		JMap.setInt(jShrine,"State",0)
		JMap.setForm(jShrine,"Form",Shrines[i].GetReference())
		JMap.setStr(jShrine,"CharacterName","")
		JMap.setObj(_jShrinesData,"Shrine" + i,jShrine)
	EndWhile
	SetShrineCharacterNames()
EndFunction
