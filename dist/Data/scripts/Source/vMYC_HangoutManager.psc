Scriptname vMYC_HangoutManager extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

String[] Property HangoutNames Hidden
{List of Hangout names}
	String[] Function Get()
		Int jHangoutNames = JMap.allKeys(_jHangoutData)
		String[] sHangoutNames = New String[128]
		Int i = 0 
		Int iCount = JArray.Count(jHangoutNames)
		Debug.Trace("MYC/HOM: iCount is " + iCount)
		While i < iCount
			sHangoutNames[i] = JArray.getStr(jHangoutNames,i)
			i += 1
		EndWhile
		Return sHangoutNames
	EndFunction
EndProperty

vMYC_CharacterManagerScript Property CharacterManager Auto
{Character manager}

ReferenceAlias[]	Property	HangoutActors		Auto
ReferenceAlias[]	Property	HangoutAnchors		Auto
ReferenceAlias[]	Property	HangoutMarkers		Auto
LocationAlias[]		Property	HangoutLocations	Auto


Location[]			Property	CustomLocations		Auto

ObjectReference[] 	Property	CustomMapMarkers 	Auto

FormList			Property	vMYC_LocationAnchorsList	Auto

Activator 			Property 	vMYC_CustomMapMarker		Auto

Keyword				Property	vMYC_Hangout				Auto

;--=== Constants ===--

Int		Property	MAX_LOCATIONS = 24		AutoReadOnly


String	Property	JKEY_LOCATION_NAME_MAP 	= "CustomLocationNameMap"		AutoReadOnly
String	Property	JKEY_HANGOUTQUEST_MAP 	= "HangoutQuestMap"				AutoReadOnly

;--=== Config variables ===--

;--=== Variables ===--

Int _jMYC 
Int _jHangoutData

Bool _bNeedSync

;--=== Events ===--

Event OnInit()
	Debug.Trace("MYC/HOM: Initializing!")
	_jMYC = CharacterManager.jMYC
EndEvent

Event OnSetCustomLocation(Form sender, String sLocationName, Form kLocation, Form kCell, Form kAnchor1, Form kAnchor2, Form kAnchor3, Form kAnchor4, Form kAnchor5, Float fPlayerX, Float fPlayerY, Float fPlayerZ)
	Debug.Trace("MYC/HOM: Received custom location event!")
	If !sLocationName
		Return
	EndIf
	;SetHangoutStr(sLocationName,"Name",
;	JMap.setStr(jHangoutData,"LocationName",sLocationName)
;	JMap.setForm(jHangoutData,"Location",kLocation as Location)
;	JMap.setForm(jHangoutData,"Cell",kCell as Cell)
;	Int jHangoutAnchors = JArray.Object()
;	JMap.setObj(jHangoutData,"Anchors",jHangoutAnchors)
;	JArray.AddForm(jHangoutAnchors,kAnchor1)
;	JArray.AddForm(jHangoutAnchors,kAnchor2)
;	JArray.AddForm(jHangoutAnchors,kAnchor3)
;	JArray.AddForm(jHangoutAnchors,kAnchor4)
;	JArray.AddForm(jHangoutAnchors,kAnchor5)
;	Int jPlayerPos = JValue.objectFromPrototype("{ \"x\": " + fPlayerX + ", \"y\": " + fPlayerY + ", \"z\": " + fPlayerZ + " }")
;	JMap.setObj(jHangoutData,"Position",jPlayerPos)
EndEvent

Event OnUpdate()
	If _bNeedSync
		_bNeedSync = False
		SyncHangoutData()
	EndIf
EndEvent

Event OnHangoutQuestRegister(Form akSendingQuest, Form akActor, Form akLocation, Form akMapMarker, Form akCenterMarker, String asHangoutName)
	Debug.Trace("MYC/HOM: Registering HangoutQuest " + akSendingQuest + " with actor " + akActor + "!")
	Int jHangoutQuestMap = JMap.GetObj(_jHangoutData,JKEY_HANGOUTQUEST_MAP)
	JFormMap.SetStr(jHangoutQuestMap,akSendingQuest,asHangoutName)
	SetHangoutForm(asHangoutName,"Quest",akSendingQuest)
	Wait(0.1)
	(akSendingQuest as Quest).SetActive(True)
	(akSendingQuest as Quest).SetObjectiveDisplayed(0,True)
	TickDataSerial()
EndEvent

Event OnShrineReady(string eventName, string strArg, float numArg, Form sender)
	If numArg && CharacterManager.GetCharacterActorByName("Kmiru")
		AssignActorToHangout(CharacterManager.GetCharacterActorByName("Kmiru"),"Ansilvund")
		AssignActorToHangout(CharacterManager.GetCharacterActorByName("Magraz"),"Blackreach")
	EndIf
EndEvent

;--=== Functions ===--

Function DoInit()
	If !_jHangoutData
		_jHangoutData = JMap.Object()
		JMap.SetObj(_jMYC,"Hangouts",_jHangoutData)
		JMap.SetObj(_jHangoutData,"DataSerial",1)
	EndIf
	SyncHangoutData()
	CustomMapMarkers = New ObjectReference[32]
	If !JMap.HasKey(_jHangoutData,JKEY_LOCATION_NAME_MAP)
		JMap.SetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP,JFormMap.Object())
	EndIf
	If !JMap.HasKey(_jHangoutData,JKEY_HANGOUTQUEST_MAP)
		JMap.SetObj(_jHangoutData,JKEY_HANGOUTQUEST_MAP,JFormMap.Object())
	EndIf
	RegisterForModEvents()
	SyncHangoutData()
EndFunction

Function DoUpkeep()
	RegisterForModEvents()
	Int jCustomLocationsMap = JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP)
	Int i = CustomLocations.Length
	While i > 0
		i -= 1
		String sLocationName = JFormMap.GetStr(jCustomLocationsMap,CustomLocations[i])
		If sLocationName
			CustomLocations[i].SetName(sLocationName)
		EndIf
	EndWhile
	Int jHangoutQuestMap = JMap.GetObj(_jHangoutData,JKEY_HANGOUTQUEST_MAP)
	If !jHangoutQuestMap 
		jHangoutQuestMap = JFormMap.Object()
	EndIf
EndFunction

Function RegisterForModEvents()
	RegisterForModEvent("vMYC_HangoutQuestRegister","OnHangoutQuestRegister")
	RegisterForModEvent("vMYC_ShrineReady","OnShrineReady")
EndFunction

Function ImportCharacterHangout(Int ajLocationData, String asSourceActorName, String asHangoutName = "")
	JValue.Retain(ajLocationData)
	String sHangoutName = asHangoutName
	If !sHangoutName
		sHangoutName = jMap.getStr(ajLocationData,"LocationName")
		If !sHangoutName
			JValue.Release(ajLocationData)
			Debug.Trace("MYC/HOM: Could not find a name for " + asSourceActorName + "'s Hangout. Aborting!",1)
			Return
		EndIf
	EndIf
	Debug.Trace("MYC/HOM: Importing " + sHangoutName + " from " + asSourceActorName + "...")
	SetHangoutStr(sHangoutName,"SourceCharacter",asSourceActorName)
	Location kLocation = JMap.GetForm(ajLocationData,"Location") as Location
	Int iLI = CustomLocations.Find(kLocation)
	If iLI < 0
		If HasHangoutKey(sHangoutName,"LocationIndex")
			Debug.Trace("MYC/HOM: * " + sHangoutName + " was already imported, overwriting!")
			iLI = GetHangoutInt(sHangoutName,"LocationIndex")
		Else
			iLI = GetFreeLocationIndex()
		EndIf
	EndIf
	If !kLocation && iLI > -1
		kLocation = CustomLocations[iLI]
		Debug.Trace("MYC/HOM: * " + sHangoutName + " location index will be " + iLI)
		SetHangoutInt(sHangoutName,"LocationIndex",iLI)
		SetHangoutStr(sHangoutName,"LocationOriginalName",kLocation.GetName())
		SetLocationName(kLocation,sHangoutName)
		Debug.Trace("MYC/HOM: * Using " + kLocation.GetName() + " " + kLocation + " for custom location \"" + sHangoutName + "\"")
		kLocation.SetName(sHangoutName)
	EndIf
	SetHangoutForm(sHangoutName,"Location",kLocation)			
	SetHangoutForm(sHangoutName,"Cell",JMap.GetForm(ajLocationData,"Cell"))
	Int jAnchors = JArray.Object()
	JArray.AddFromArray(jAnchors,JMap.GetObj(ajLocationData,"Anchors"))
	SetHangoutObj(sHangoutName,"Anchors",jAnchors)
	Int jPosition = JMap.Object()
	JMap.SetFlt(jPosition,"X",JValue.SolveFlt(ajLocationData,".Position.X"))
	JMap.SetFlt(jPosition,"Y",JValue.SolveFlt(ajLocationData,".Position.Y"))
	JMap.SetFlt(jPosition,"Z",JValue.SolveFlt(ajLocationData,".Position.Z"))
	SetHangoutObj(sHangoutName,"Position",jPosition)
	JValue.Release(ajLocationData)
EndFunction

Function ImportOldHangouts()
{Import the old hangouts and custom locations from CharacterManager}
	Debug.Trace("MYC/HOM: Importing Hangouts from previous versions...")
	String[] sCharacterNames = CharacterManager.CharacterNames
	String[] sHangoutNames = CharacterManager.sHangoutNames
	ReferenceAlias[] kHangoutRefAliases = CharacterManager.kHangoutRefAliases

	Int i
	
	i = 0
	While i < sCharacterNames.Length
		Debug.Trace("MYC/HOM: Checking " + sCharacterNames[i] + " for custom location data...")
		Int jLocationData = CharacterManager.GetCharacterObj(sCharacterNames[i],"LocationData")
		If jLocationData
			Debug.Trace("MYC/HOM: * " + sCharacterNames[i] + " has a custom location attached, importing it...")
			ImportCharacterHangout(jLocationData, sCharacterNames[i])
		EndIf
		i += 1
	EndWhile

	i = 0
	While i < sHangoutNames.Length
		String sHangoutName = sHangoutNames[i]
		If sHangoutName
			Debug.Trace("MYC/HOM: Importing " + sHangoutName + "...")
			If StringUtil.Find(sHangoutName,"$") > -1
				sHangoutName = StringUtil.SubString(sHangoutName,1)
			EndIf
			If StringUtil.Find(sHangoutName,"Custom") > -1
				sHangoutName = StringUtil.SubString(sHangoutName,0,StringUtil.Find(sHangoutName,"(") - 1)
				SetHangoutInt(sHangoutName,"IsCustom",1)
			EndIf
			Debug.Trace("MYC/HOM: * Renamed to " + sHangoutName + "")
			If kHangoutRefAliases[i]
				SetHangoutForm(sHangoutName,"CurrentActor",kHangoutRefAliases[i].GetReference())
				Debug.Trace("MYC/HOM: * Occupied by " + kHangoutRefAliases[i].GetReference() + "")
			EndIf
		EndIf
		i += 1
	EndWhile

	i = 0
	sHangoutNames = HangoutNames
	While i < sHangoutNames.Length
		If sHangoutNames[i]
			PlaceHangoutMarker(sHangoutNames[i])
		EndIf
		i += 1
	EndWhile
EndFunction

Function PlaceHangoutMarker(String sHangoutName)
	Int iFreeMarker = -1
	If HasHangoutKey(sHangoutName,"MarkerIndex")
		iFreeMarker = GetHangoutInt(sHangoutName,"MarkerIndex")
		If CustomMapMarkers[iFreeMarker]
			Debug.Trace("MYC/HOM/" + sHangoutName + ": Previous marker " + CustomMapMarkers[iFreeMarker] + " will be deleted!",1)
			CustomMapMarkers[iFreeMarker].Delete()
			CustomMapMarkers[iFreeMarker] = None
		EndIf
	EndIf
	Float TargetX = GetHangoutFlt(sHangoutName,"Position.X")
	Float TargetY = GetHangoutFlt(sHangoutName,"Position.Y")
	Float TargetZ = GetHangoutFlt(sHangoutName,"Position.Z")
	Int jAnchorObjects = GetHangoutObj(sHangoutName,"Anchors")
	If !jAnchorObjects
		Debug.Trace("MYC/HOM/" + sHangoutName + ": Can't place map marker because there are no anchor objects!",1)
		Return
	EndIf
	Int i = JArray.Count(jAnchorObjects)
	ObjectReference kSpawnObject
	While i > 0
		i -= 1
		ObjectReference kAnchor = JArray.GetForm(jAnchorObjects,i) as ObjectReference
		If kAnchor
			kSpawnObject = kAnchor ; Counting backward should get us the objects closest to the player
		EndIf
	EndWhile
	SetHangoutForm(sHangoutName,"SpawnObject",kSpawnObject)
	
	If iFreeMarker < 0
		iFreeMarker = CustomMapMarkers.Find(None)
		SetHangoutInt(sHangoutName,"MarkerIndex",iFreeMarker)
	EndIf
	CustomMapMarkers[iFreeMarker] = kSpawnObject.PlaceAtMe(vMYC_CustomMapMarker)
	CustomMapMarkers[iFreeMarker].SetPosition(TargetX, TargetY, TargetZ)
	CustomMapMarkers[iFreeMarker].SetName(sHangoutName)
	Debug.Trace("MYC/HOM/" + sHangoutName + ": Placed map marker " + CustomMapMarkers[iFreeMarker] + "!")
EndFunction

Function SetLocationName(Location kLocation, String sHangoutName)
	JFormMap.SetStr(JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP),kLocation,sHangoutName)
	
EndFunction

Int Function GetFreeLocationIndex()
	Int jCustomLocationsMap = JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP)
	Int i = 0
	While i < CustomLocations.Length
		If !JFormMap.GetStr(jCustomLocationsMap,CustomLocations[i])
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

Function AssignActorToHangout(Actor akActor, String sHangoutName)
	Debug.Trace("MYC/HOM/" + sHangoutName + ": Assigning " + akActor + " to this Hangout!")
	PlaceHangoutMarker(sHangoutName)
	If HasHangoutKey(sHangoutName,"MarkerIndex")
		CustomMapMarkers[GetHangoutInt(sHangoutName,"MarkerIndex")].SetName(sHangoutName)
		If vMYC_Hangout.SendStoryEventAndWait(GetHangoutForm(sHangoutName,"Location") as Location,CustomMapMarkers[GetHangoutInt(sHangoutName,"MarkerIndex")],akActor)
			Debug.Trace("MYC/HOM/" + sHangoutName + ": Sent story event successfully!")
		Else
			Debug.Trace("MYC/HOM/" + sHangoutName + ": Couldn't send story event!",1)
		EndIf
		;HangoutAnchors[0].ForceRefTo(GetHangoutForm(sHangoutName,"SpawnObject") as ObjectReference)
		;HangoutMarkers[0].ForceRefTo(CustomMapMarkers[GetHangoutInt(sHangoutName,"MarkerIndex")])
		;HangoutLocations[0].ForceLocationTo(GetHangoutForm(sHangoutName,"Location") as Location)
		akActor.EvaluatePackage()
	Else
		Debug.Trace("MYC/HOM/" + sHangoutName + ": Can't assign this location because there is no MapMarker!",1)
	EndIf
EndFunction

Actor Function GetHangoutActor(String sHangoutName)
	


EndFunction

;=== Data management ===----

Function SetHangoutDefaults() 
	Debug.Trace("MYC/HOM: Setting defaults!")
EndFunction

Function SendHangoutEvent(String asPath) 
	Int iHandle = ModEvent.Create("vMYC_HangoutUpdate")
	If iHandle
		ModEvent.PushString(iHandle,asPath)
		ModEvent.Send(iHandle)
	EndIf
EndFunction

Bool Function SyncHangoutData() 
	Bool bUpdated = False
	
	Int jHangoutFileData = JValue.ReadFromFile("Data/vMYC/vMYC_Hangouts.json")
	Int DataSerial = JMap.getInt(_jHangoutData,"DataSerial")
	Int DataFileSerial = JMap.getInt(jHangoutFileData,"DataSerial")
	If DataSerial > DataFileSerial
		Debug.Trace("MYC/HOM: Our data is newer than the saved file, overwriting it!")
		JValue.WriteToFile(_jHangoutData,"Data/vMYC/vMYC_Hangouts.json")
	ElseIf DataSerial < DataFileSerial
		Debug.Trace("MYC/HOM: Our data is older than the saved file, loading it!")
		_jHangoutData = JValue.Release(_jHangoutData)
		_jHangoutData = JValue.ReadFromFile("Data/vMYC/vMYC_Hangouts.json")
		JMap.SetObj(_jMYC,"Hangouts",_jHangoutData)
		bUpdated = True
	Else
		;Already synced. Sunc?
	EndIf
	Return bUpdated
EndFunction

Function LoadHangouts() 
	Int jHangoutData = JDB.solveObj(".vMYC.Hangouts")
	_jHangoutData = JValue.ReadFromFile("Data/vMYC/vMYC_Hangouts.json")
EndFunction

Function SaveHangouts() 
	Int jHangoutData = JDB.solveObj(".vMYC.Hangouts")
	JMap.setInt(jHangoutData,"DataSerial",JMap.getInt(jHangoutData,"DataSerial") + 1)
	JValue.WriteToFile(jHangoutData,"Data/vMYC/vMYC_Hangouts.json")
EndFunction

Function AssignHangout()
	
EndFunction

;==== Generic functions for get/setting Hangout-specific data

Int Function CreateHangoutDataIfMissing(String asHangoutName)
	If !asHangoutName
		Debug.Trace("MYC/HOM: SetHangoutData function called without HangoutName specified!")
		Return 0
	EndIf
	TickDataSerial()
	Int jHangout = JMap.getObj(_jHangoutData,asHangoutName)
	If jHangout
		Return jHangout
	EndIf
	Debug.Trace("MYC/HOM/" + asHangoutName + ": First Hangout data access, creating HangoutData key!")
	jHangout = JMap.Object()
	JMap.setObj(_jHangoutData,asHangoutName,jHangout)
	Return jHangout
EndFunction

Function TickDataSerial(Bool abForceSync = False)
	JMap.setInt(_jHangoutData,"DataSerial",JMap.getInt(_jHangoutData,"DataSerial") + 1)
	
	If abForceSync
		SyncHangoutData()
	Else
		_bNeedSync = True
		RegisterForSingleUpdate(5)
	EndIf
	;	SyncHangoutData()
EndFunction

Bool Function HasHangoutKey(String asHangoutName, String asPath)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	Return JMap.HasKey(jHangout,asPath)
EndFunction

Function SetHangoutStr(String asHangoutName, String asPath, String asString)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setStr(jHangout,asPath,asString)
EndFunction

String Function GetHangoutStr(String asHangoutName, String asPath)
	Return JValue.solveStr(_jHangoutData,"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutInt(String asHangoutName, String asPath, Int aiInt)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setInt(jHangout,asPath,aiInt)
EndFunction

Int Function GetHangoutInt(String asHangoutName, String asPath)
	Return JValue.solveInt(_jHangoutData,"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutFlt(String asHangoutName, String asPath, Float afFloat)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setFlt(jHangout,asPath,afFloat)
EndFunction

Float Function GetHangoutFlt(String asHangoutName, String asPath)
	Return JValue.solveFlt(_jHangoutData,"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutForm(String asHangoutName, String asPath, Form akForm)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setForm(jHangout,asPath,akForm)
EndFunction

Form Function GetHangoutForm(String asHangoutName, String asPath)
	Return JValue.solveForm(_jHangoutData,"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutObj(String asHangoutName, String asPath, Int ajObj)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setObj(jHangout,asPath,ajObj)
EndFunction

Int Function GetHangoutObj(String asHangoutName, String asPath)
	Return JValue.solveObj(_jHangoutData,"." + asHangoutName + "." + asPath)
EndFunction
