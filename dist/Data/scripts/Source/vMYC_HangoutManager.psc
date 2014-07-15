Scriptname vMYC_HangoutManager extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

String[] Property HangoutNames Hidden
{List of Hangout names}
	String[] Function Get()
		Int jHangoutNames = JMap.allKeys(JValue.solveObj(_jMYC,".Hangouts"))
		String[] sHangoutNames = New String[128]
		Int i = JArray.Count(jHangoutNames)
		While i > 0
			i -= 1
			sHangoutNames[i] = JArray.getStr(jHangoutNames,i)
		EndWhile
		Return sHangoutNames
	EndFunction
EndProperty

vMYC_CharacterManagerScript Property CharacterManager Auto
{Character manager}

ReferenceAlias[]	Property	HangoutActors		Auto
ReferenceAlias[]	Property	HangoutAnchors		Auto
ReferenceAlias[]	Property	HangoutCells		Auto
ReferenceAlias[]	Property	HangoutMarkers		Auto
LocationAlias[]		Property	HangoutLocations	Auto


Location[]			Property	CustomLocations		Auto


FormList			Property	vMYC_LocationAnchorsList	Auto

Activator 			Property 	vMYC_CustomMapMarker		Auto

;--=== Constants ===--

Int		Property	MAX_LOCATIONS = 24		AutoReadOnly


String	Property	JKEY_LOCATION_NAME_MAP = "CustomLocationNameMap"		AutoReadOnly

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

;--=== Functions ===--

Function DoInit()
	If !_jHangoutData
		_jHangoutData = JMap.Object()
		JMap.SetObj(_jMYC,"Hangouts",_jHangoutData)
		JMap.SetObj(_jHangoutData,"DataSerial",1)
	EndIf
	Int jCustomLocationsMap = JFormMap.Object()
	JMap.SetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP,jCustomLocationsMap)
	Int i = 0
	While i < CustomLocations.Length
		JFormMap.SetInt(jCustomLocationsMap,CustomLocations[i],i)
		i += 1
	EndWhile
	SyncHangoutData()
EndFunction

Function DoUpkeep()
	Int jCustomLocationsMap = JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_MAP)
	Int i = CustomLocations.Length
	While i > 0
		i -= 1
		String sLocationName = JFormMap.GetStr(jCustomLocationsMap,CustomLocations[i])
		If sLocationName
			CustomLocations[i].SetName(sLocationName)
		EndIf
	EndWhile
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
			String sHangoutName = jMap.getStr(jLocationData,"LocationName")
			Debug.Trace("MYC/HOM: * " + sCharacterNames[i] + " has " + sHangoutName + ", importing it...")
			SetHangoutStr(sHangoutName,"SourceCharacter",sCharacterNames[i])
			Location kLocation = JMap.GetForm(jLocationData,"Location") as Location
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
			SetHangoutForm(sHangoutName,"Cell",JMap.GetForm(jLocationData,"Cell"))
			Int jAnchors = JArray.Object()
			JArray.AddFromArray(jAnchors,JMap.GetObj(jLocationData,"Anchors"))
			SetHangoutObj(sHangoutName,"Anchors",jAnchors)
			Int jPosition = JMap.Object()
			JMap.SetFlt(jPosition,"X",JValue.SolveFlt(jLocationData,".Position.X"))
			JMap.SetFlt(jPosition,"Y",JValue.SolveFlt(jLocationData,".Position.Y"))
			JMap.SetFlt(jPosition,"Z",JValue.SolveFlt(jLocationData,".Position.Z"))
			SetHangoutObj(sHangoutName,"Position",jPosition)
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
	While i < CustomLocations.Length
		
		i += 1
	EndWhile
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





;==== Generic functions for get/setting Hangout-specific data

Int Function CreateHangoutDataIfMissing(String asHangoutName)
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
	Return JValue.solveStr(_jHangoutData,asHangoutName + "." + asPath)
EndFunction

Function SetHangoutInt(String asHangoutName, String asPath, Int aiInt)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setInt(jHangout,asPath,aiInt)
EndFunction

Int Function GetHangoutInt(String asHangoutName, String asPath)
	Return JValue.solveInt(_jHangoutData,asHangoutName + "." + asPath)
EndFunction

Function SetHangoutFlt(String asHangoutName, String asPath, Float afFloat)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setFlt(jHangout,asPath,afFloat)
EndFunction

Float Function GetHangoutFlt(String asHangoutName, String asPath)
	Return JValue.solveFlt(_jHangoutData,asHangoutName + "." + asPath)
EndFunction

Function SetHangoutForm(String asHangoutName, String asPath, Form akForm)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setForm(jHangout,asPath,akForm)
EndFunction

Form Function GetHangoutForm(String asHangoutName, String asPath)
	Return JValue.solveForm(_jHangoutData,asHangoutName + "." + asPath)
EndFunction

Function SetHangoutObj(String asHangoutName, String asPath, Int ajObj)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setObj(jHangout,asPath,ajObj)
EndFunction

Int Function GetHangoutObj(String asHangoutName, String asPath)
	Return JValue.solveObj(_jHangoutData,asHangoutName + "." + asPath)
EndFunction


