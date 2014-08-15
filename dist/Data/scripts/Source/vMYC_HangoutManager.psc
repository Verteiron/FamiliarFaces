Scriptname vMYC_HangoutManager extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

String[] Property HangoutNames Hidden
{List of Hangout names}
	String[] Function Get()
		Int jHangoutNames = JMap.allKeys(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP))
		JValue.Retain(jHangoutNames,"vMYC_HOM")
		String[] sHangoutNames = New String[128]
		Int i = 0 
		Int iCount = JArray.Count(jHangoutNames)
		;Debug.Trace("MYC/HOM: iCount is " + iCount)
		Int iNameCount = 0
		While i < iCount
			String sHangoutName = JArray.getStr(jHangoutNames,i)
			If IsHangoutEnabled(sHangoutName)
				sHangoutNames[iNameCount] = sHangoutName
				iNameCount += 1
			EndIf
			i += 1
		EndWhile
		JValue.Release(jHangoutNames)
		Return sHangoutNames
	EndFunction
EndProperty

String[] Property HangoutNamesDisabled Hidden
{List of Hangout names}
	String[] Function Get()
		Int jHangoutNames = JMap.allKeys(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP))
		String[] sHangoutNames = New String[128]
		Int i = 0 
		Int iCount = JArray.Count(jHangoutNames)
		;Debug.Trace("MYC/HOM: iCount is " + iCount)
		While i < iCount
			String sHangoutName = JArray.getStr(jHangoutNames,i)
			sHangoutNames[i] = sHangoutName
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
Keyword				Property	vMYC_Wanderer				Auto

String				Property	DataPath					Auto Hidden

;--=== Constants ===--

Int		Property	MAX_LOCATIONS = 24		AutoReadOnly


String	Property	JKEY_LOCALCONFIG		= "Hangouts_"					AutoReadOnly
String	Property	JKEY_LOCATION_NAME_FMAP = "CustomLocationNameMap"		AutoReadOnly
String	Property	JKEY_HANGOUTQUEST_FMAP 	= "HangoutQuestMap"				AutoReadOnly
String	Property	JKEY_HANGOUT_MAP	 	= "Hangouts"					AutoReadOnly
String 	Property	JKEY_HANGOUT_POOL		= "HangoutPool"					AutoReadOnly

;--=== Config variables ===--

;--=== Variables ===--

Int _jMYC 
Int _jHangoutData

Bool _bNeedSync
Bool _bNeedHangoutUpdate

;--=== Events ===--

Event OnInit()
	Debug.Trace("MYC/HOM: Initializing!")
	_jMYC = CharacterManager.jMYC
EndEvent

Event OnSetCustomHangout(String sCharacterName, String sLocationName, Form kLocation, Form kCell, Form kAnchor1, Form kAnchor2, Form kAnchor3, Form kAnchor4, Form kAnchor5, Float fPlayerX, Float fPlayerY, Float fPlayerZ)
	Debug.Trace("MYC/HOM: Received custom hangout event!")
	If !sLocationName
		Return
	EndIf
	Int jHangoutData = JMap.Object()
	JMap.setStr(jHangoutData,"LocationName",sLocationName) ;For compatibility
	JMap.setStr(jHangoutData,"HangoutName",sLocationName) ;For compatibility
	JMap.setForm(jHangoutData,"Location",kLocation as Location)
	JMap.setForm(jHangoutData,"Cell",kCell as Cell)
	Int jHangoutAnchors = JArray.Object()
	JMap.setObj(jHangoutData,"Anchors",jHangoutAnchors)
	JArray.AddForm(jHangoutAnchors,kAnchor1)
	JArray.AddForm(jHangoutAnchors,kAnchor2)
	JArray.AddForm(jHangoutAnchors,kAnchor3)
	JArray.AddForm(jHangoutAnchors,kAnchor4)
	JArray.AddForm(jHangoutAnchors,kAnchor5)
	Int jPlayerPos = JValue.objectFromPrototype("{ \"x\": " + fPlayerX + ", \"y\": " + fPlayerY + ", \"z\": " + fPlayerZ + " }")
	JMap.setObj(jHangoutData,"Position",jPlayerPos)
	JMap.setStr(jHangoutData,"Source",sCharacterName)
	ImportCharacterHangout(jHangoutData,sCharacterName)
EndEvent

Event OnUpdate()
	If _bNeedSync
		_bNeedSync = False
		SyncHangoutData()
	EndIf
	If _bNeedHangoutUpdate
		AssignActorHangouts()
		_bNeedHangoutUpdate = False
	EndIf
EndEvent

Event OnHangoutQuestRegister(Form akSendingQuest, Form akActor, Form akLocation, Form akMapMarker, Form akCenterMarker, String asHangoutName)
	Debug.Trace("MYC/HOM: Registering HangoutQuest " + akSendingQuest + " with actor " + (akActor as Actor).GetActorBase().GetName() + ", LocationCenter: " + ((akSendingQuest as Quest).GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference() + ", Inn: " + ((akSendingQuest as Quest).GetAliasByName("HangoutInn0") as LocationAlias).GetLocation().GetName() + "!")
	;SetHangoutForm(asHangoutName,"Quest",akSendingQuest)
	TickDataSerial()
EndEvent

Event OnShrineReady(string eventName, string strArg, float numArg, Form sender)
	If numArg ;&& CharacterManager.GetCharacterActorByName("Kmiru")
		;AssignActorToHangout(CharacterManager.GetCharacterActorByName("Kmiru"),"Ansilvund")
		;AssignActorToHangout(CharacterManager.GetCharacterActorByName("Magraz"),"Blackreach")
		SendHangoutPing()
	EndIf
EndEvent

Event OnHangoutPong(Form akHangout, Form akLocation, String asHangoutName)
	Debug.Trace("MYC/HOM: Got HangoutPong from " + akHangout + "!")
	vMYC_HangoutQuestScript kHangout = akHangout as vMYC_HangoutQuestScript
	If !kHangout
		Debug.Trace("MYC/HOM: " + akHangout + " sent us a Pong but isn't the right type of object.")
		Return
	EndIf
	Int jHangoutQuestMap = JMap.GetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
	JFormMap.SetStr(jHangoutQuestMap,kHangout,asHangoutName)
	If asHangoutName
		SetHangoutForm(asHangoutName,"Location",akLocation)
		SetHangoutForm(asHangoutName,"Quest",akHangout)
		Debug.Trace("MYC/HOM: " + akHangout + " is a preset named " + asHangoutName + " for location " + akLocation)
		SetHangoutInt(asHangoutName,"Preset",1)
	Else
		Int jHangoutPool = JMap.GetObj(_jHangoutData,JKEY_HANGOUT_POOL)
		If JArray.FindForm(jHangoutPool,kHangout) < 0
			JArray.AddForm(jHangoutPool,kHangout)
			Debug.Trace("MYC/HOM: Added " + kHangout + " to the Hangout pool!")
		EndIf
	EndIf
	If !((kHangout.GetAliasByName("HangoutActor") as ReferenceAlias).GetReference())
		Debug.Trace("MYC/HOM: Stopping HangoutQuest " + kHangout + " because no Actor is assigned to it.")
		(akHangout as vMYC_HangoutQuestScript).DoShutdown()
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
	If !JMap.HasKey(_jHangoutData,JKEY_LOCATION_NAME_FMAP)
		JMap.SetObj(_jHangoutData,JKEY_LOCATION_NAME_FMAP,JFormMap.Object())
	EndIf
	If !JMap.HasKey(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
		JMap.SetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP,JFormMap.Object())
	EndIf
	If !JMap.HasKey(_jHangoutData,JKEY_HANGOUT_MAP)
		JMap.SetObj(_jHangoutData,JKEY_HANGOUT_MAP,JMap.Object())
	EndIf
	If !JMap.HasKey(_jHangoutData,JKEY_HANGOUT_POOL)
		JMap.SetObj(_jHangoutData,JKEY_HANGOUT_POOL,JArray.Object())
	EndIf
	RegisterForModEvents()
	SyncHangoutData()
	SendHangoutPing()
EndFunction

Function DoUpkeep()
	CleanupTempJContainers()
	RegisterForModEvents()
	Int jCustomLocationsMap = JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_FMAP)
	Int i = CustomLocations.Length
	While i > 0
		i -= 1
		String sLocationName = JFormMap.GetStr(jCustomLocationsMap,CustomLocations[i])
		If sLocationName
			CustomLocations[i].SetName(sLocationName)
		EndIf
	EndWhile
	Int jHangoutQuestMap = JMap.GetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
	If !jHangoutQuestMap 
		jHangoutQuestMap = JFormMap.Object()
		JMap.SetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP,jHangoutQuestMap)
	EndIf
	Int jQuestList = JFormMap.AllKeys(jHangoutQuestMap)
	i = JArray.Count(jQuestList)
	While i > 0
		i -= 1
		vMYC_HangoutQuestScript kHangout = JArray.GetForm(jQuestList,i) as vMYC_HangoutQuestScript
		If kHangout
			kHangout.DoUpkeep()
		EndIf
	EndWhile
	SendHangoutPing()
EndFunction

Function DoShutdown()
	Int i = 0
	UnregisterForUpdate()
	UnregisterForModEvent("vMYC_HangoutQuestRegister")
	UnregisterForModEvent("vMYC_ShrineReady")
	UnregisterForModEvent("vMYC_SetCustomHangout")
	WaitMenuMode(1)
	UnregisterForUpdate()
	CleanupTempJContainers()
	Int jHangoutQuestMap = JMap.GetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
	If !jHangoutQuestMap 
		jHangoutQuestMap = JFormMap.Object()
		JMap.SetObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP,jHangoutQuestMap)
	EndIf
	Int jQuestList = JFormMap.AllKeys(jHangoutQuestMap)

	;Cancel all hangouts
	String[] sCharacterNames = CharacterManager.CharacterNames
	i = sCharacterNames.Length
	While i > 0
		i -= 1
		If sCharacterNames[i]
			Actor kActor = CharacterManager.GetCharacterActorByName(sCharacterNames[i])
			If kActor
				CancelActorHangout(kActor)
			EndIf
		EndIf
	EndWhile

	;Shutdown hangout quests
	i = JArray.Count(jQuestList)
	While i > 0
		i -= 1
		vMYC_HangoutQuestScript kHangout = JArray.GetForm(jQuestList,i) as vMYC_HangoutQuestScript
		If kHangout
			kHangout.DoShutdown()
		EndIf
	EndWhile
	
	;Delete map markers
	i = CustomMapMarkers.Length
	While i > 0 
		i -= 1
		If CustomMapMarkers[i]
			CustomMapMarkers[i].Delete()
		EndIf
	EndWhile

EndFunction

Function RegisterForModEvents()
	RegisterForModEvent("vMYC_HangoutQuestRegister","OnHangoutQuestRegister")
	RegisterForModEvent("vMYC_ShrineReady","OnShrineReady")
	RegisterForModEvent("vMYC_SetCustomHangout","OnSetCustomHangout")
EndFunction

Function ImportCharacterHangout(Int ajLocationData, String asSourceActorName, String asHangoutName = "")
	JValue.Retain(ajLocationData,"vMYC_HOM")
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

Function DeleteHangout(String sHangoutName)
	If HasHangoutKey(sHangoutName,"MarkerIndex")
		Int iMarkerIndex = GetHangoutInt(sHangoutName,"MarkerIndex")
		Int iNumRefs = CustomMapMarkers[iMarkerIndex].GetNumReferenceAliases()
		While iNumRefs > 0
			iNumRefs -= 1
			Quest kHangoutQuest = CustomMapMarkers[iMarkerIndex].GetNthReferenceAlias(iNumRefs).GetOwningQuest()
			If kHangoutQuest
				Debug.Trace("MYC/HOM/" + sHangoutName + ": Stopping " + kHangoutQuest + "...",1)
				Actor kHangoutActor = (kHangoutQuest.GetAliasByName("HangoutActor") as ReferenceAlias).GetReference() as Actor
				If kHangoutActor
					Debug.Trace("MYC/HOM/" + sHangoutName + ": * This will orphan " + kHangoutActor.GetName() + " " + kHangoutActor + "!",1)
					AssignActorToHangout(kHangoutActor,"")
				EndIf
				(kHangoutQuest as vMYC_HangoutQuestScript).DoShutdown()
			EndIf
		EndWhile
		SetHangoutInt(sHangoutName,"MarkerIndex",-1)
		CustomMapMarkers[iMarkerIndex].Delete()
		CustomMapMarkers[iMarkerIndex] = None
	EndIf
EndFunction

Function PlaceHangoutMarker(String sHangoutName)
	Int iFreeMarker = -1
	If HasHangoutKey(sHangoutName,"MarkerIndex")
		iFreeMarker = GetHangoutInt(sHangoutName,"MarkerIndex")
		If CustomMapMarkers[iFreeMarker]
			Debug.Trace("MYC/HOM/" + sHangoutName + ": Previous marker " + CustomMapMarkers[iFreeMarker] + " exists!",1)
			Return
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
			If kAnchor.IsEnabled()
				kSpawnObject = kAnchor ; Counting backward should get us the objects closest to the player
			EndIf
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

ObjectReference Function GetHangoutMarker(String asHangoutName)
	If HasHangoutKey(asHangoutName,"MarkerIndex") 
		If CustomMapMarkers[GetHangoutInt(asHangoutName,"MarkerIndex")] as ObjectReference
			Return CustomMapMarkers[GetHangoutInt(asHangoutName,"MarkerIndex")] as ObjectReference
		EndIf
	Else
		vMYC_HangoutQuestScript kHangout = GetHangoutQuest(asHangoutName)
		ObjectReference kMarker = (kHangout.GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference()
		If !kMarker
			kMarker = (kHangout.GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference()
		EndIf
		Return kMarker
	EndIf
	Return None
EndFunction

vMYC_HangoutQuestScript Function GetHangoutQuest(String asHangoutName)
	vMYC_HangoutQuestScript kHangout = GetHangoutForm(asHangoutName,"Quest") as vMYC_HangoutQuestScript
	If !kHangout
		Int jHangoutQuestMap = JMap.getObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
		Int jAssignedQuests = JFormMap.AllKeys(jHangoutQuestMap)
		Int i = JArray.Count(jAssignedQuests)
		While i > 0
			i -= 1
			kHangout = JArray.GetForm(jAssignedQuests,i) as vMYC_HangoutQuestScript
			If JFormMap.GetStr(jHangoutQuestMap,kHangout) == asHangoutName
				Return kHangout
			EndIf
		EndWhile
	EndIf
	Return kHangout
EndFunction

Function SetLocationName(Location kLocation, String sHangoutName)
	JFormMap.SetStr(JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_FMAP),kLocation,sHangoutName)
	
EndFunction

Int Function GetFreeLocationIndex()
	Int jCustomLocationsMap = JMap.GetObj(_jHangoutData,JKEY_LOCATION_NAME_FMAP)
	Int i = 0
	While i < CustomLocations.Length
		If !JFormMap.GetStr(jCustomLocationsMap,CustomLocations[i])
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

vMYC_HangoutQuestScript Function GetFreeHangoutFromPool()
	Int jHangoutPool = JMap.GetObj(_jHangoutData,JKEY_HANGOUT_POOL)
	Int i = JArray.Count(jHangoutPool)
	While i > 0
		i -= 1
		vMYC_HangoutQuestScript kHangout = JArray.GetForm(jHangoutPool,i) as vMYC_HangoutQuestScript
		If kHangout
			If !kHangout.IsRunning() && !kHangout.IsStarting()
				Return kHangout
			EndIf
		EndIf
	EndWhile
	Return None
EndFunction

Event OnAssignActorToHangout(Form akActorForm, String asHangoutName)
	
	;SendHangoutPing()
EndEvent

Function AssignActorHangouts()
	Int jPendingActors = GetLocalConfigObj(JKEY_LOCALCONFIG + "PendingActors")
	Int iCount = JArray.Count(jPendingActors)
	Int i = iCount
	While i > 0
		i -= 1
		Actor kActor = JArray.GetForm(jPendingActors,i) as Actor
		If kActor
			CancelActorHangout(kActor)
		EndIf
	EndWhile
	;SendHangoutPing()
	i = 0
	While i < iCount
		Actor kActor = JArray.GetForm(jPendingActors,i) as Actor
		If kActor
			String sCharacterName = kActor.GetActorBase().GetName()
			String sHangoutName = CharacterManager.GetLocalString(sCharacterName,"HangoutName")
			AssignActorToHangout(kActor,sHangoutName,False)
		EndIf
		i += 1
	EndWhile
	JArray.Clear(jPendingActors)
	SetLocalConfigObj(JKEY_LOCALCONFIG + "PendingActors",JArray.Object())
EndFunction

Function AssignActorToHangout(Actor akActor, String asHangoutName, Bool abDefer = True)
	If !akActor 
		Debug.Trace("MYC/HOM: AssignActorToHangout received empty Actor parameter, aborting!")
		Return
	EndIf
	String sCharacterName = akActor.GetActorBase().GetName()
	CharacterManager.SetLocalString(sCharacterName,"HangoutName",asHangoutName)
	
	If abDefer
		Debug.Trace("MYC/HOM/" + asHangoutName + ": Queuing " + akActor + " for this Hangout...")
		If !HasLocalConfigKey(JKEY_LOCALCONFIG + "PendingActors")
			SetLocalConfigObj(JKEY_LOCALCONFIG + "PendingActors",JArray.Object())
		EndIf
		Int jPendingActors = GetLocalConfigObj(JKEY_LOCALCONFIG + "PendingActors")
		If JArray.FindForm(jPendingActors,akActor) < 0
			JArray.AddForm(jPendingActors,akActor)
		EndIf
		_bNeedHangoutUpdate = True
		RegisterForSingleUpdate(3)
	Else
		If CharacterManager.GetLocalString(sCharacterName,"HangoutName") != asHangoutName
			Debug.Trace("MYC/HOM/" + asHangoutName + ": Not " + akActor + "'s Hangout, aborting!")
			Return
		EndIf
		
		If asHangoutName
			Debug.Trace("MYC/HOM/" + asHangoutName + ": Assigning " + akActor + " to this Hangout!")
			PlaceHangoutMarker(asHangoutName)
			ObjectReference kMarkerObject
			If HasHangoutKey(asHangoutName,"MarkerIndex")
				kMarkerObject = CustomMapMarkers[GetHangoutInt(asHangoutName,"MarkerIndex")]
			EndIf
			Debug.Trace("MYC/HOM/" + asHangoutName + ": Sending story event with Actor: " + akActor.GetActorBase().GetName() + ", Location: " + (GetHangoutForm(asHangoutName,"Location") as Location).GetName() + ", MarkerIndex: " + GetHangoutInt(asHangoutName,"MarkerIndex"))
			If vMYC_Hangout.SendStoryEventAndWait(GetHangoutForm(asHangoutName,"Location") as Location,kMarkerObject,akActor)
				Debug.Trace("MYC/HOM/" + asHangoutName + ": Started the quest successfully!")
				SetLocalHangoutInt(asHangoutName,"ActorCount",GetLocalHangoutInt(asHangoutName,"ActorCount") + 1)
				akActor.EvaluatePackage()
				EnableTracking(akActor,CharacterManager.GetLocalInt(sCharacterName,"TrackingEnabled") as Bool)
			Else
				Debug.Trace("MYC/HOM/" + asHangoutName + ": Could not find an available HangoutQuest!")
			EndIf
		Else 
			Debug.Trace("MYC/HOM/None: Assigning " + akActor + " to Wander!")
		;No HangoutName, set to wander
			If vMYC_Wanderer.SendStoryEventAndWait(akRef1 = akActor)
				Debug.Trace("MYC/HOM: Sent story event to begin wandering!")
				akActor.EvaluatePackage()
				EnableTracking(akActor,CharacterManager.GetLocalInt(sCharacterName,"TrackingEnabled") as Bool)
			Else
				Debug.Trace("MYC/HOM: Couldn't send story event to resume wandering!")
			EndIf
		EndIf
	EndIf
EndFunction

Function MoveActorToHangout(Actor akActor, String asHangoutName)
	If !asHangoutName
		If vMYC_Wanderer.SendStoryEventAndWait(akRef1 = akActor)
			Debug.Trace("MYC/HOM: Sent story event to begin wandering!")
			akActor.EvaluatePackage()
			akActor.MoveToPackageLocation()
			Return
		Else
			Debug.Trace("MYC/HOM: Couldn't send story event to resume wandering!")
		EndIf
	EndIf
	akActor.EvaluatePackage()
	akActor.MoveToPackageLocation()
	If akActor.GetCurrentLocation() != GetHangoutForm(asHangoutName,"Location")
		Debug.Trace("MYC/HOM/" + asHangoutName + ": Actor's AI package didn't send them to the right place!",1)
		ObjectReference kMarker = GetHangoutMarker(asHangoutName)
		If kMarker
			Debug.Trace("MYC/HOM/" + asHangoutName + ": Moving Actor " + akActor.GetName() + " " + akActor + " to " + kMarker + "!")
			akActor.MoveTo(kMarker)
		Else
			Debug.Trace("MYC/HOM/" + asHangoutName + ": Couldn't find anything to moving the Actor to! MoveActorToHangout failed!",1)
		EndIf
	Else
		Debug.Trace("MYC/HOM/" + asHangoutName + ": Actor's AI package appears to have sent them to the right place.")
	EndIf
EndFunction

Function CancelActorHangout(Actor akActor)
	Int i = akActor.GetNumReferenceAliases()
	While i > 0
		i -= 1
		ReferenceAlias kRefAlias = akActor.GetNthReferenceAlias(i)
		If kRefAlias
			Quest kQuest = kRefAlias.GetOwningQuest()
			If kQuest as vMYC_HangoutQuestScript
				vMYC_HangoutQuestScript kHangout = kQuest as vMYC_HangoutQuestScript
				Int jHangoutQuestMap = JMap.getObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
				String sHangoutName = JFormMap.GetStr(jHangoutQuestMap,kHangout)
				Debug.Trace("MYC/HOM/" + sHangoutName + ": Stopping " + kHangout + "...",1)
				JFormMap.RemoveKey(jHangoutQuestMap,kHangout)
				kHangout.EnableTracking(False)
				kHangout.DoShutdown()
				SetLocalHangoutInt(sHangoutName,"ActorCount",GetLocalHangoutInt(sHangoutName,"ActorCount") - 1)
				Int iSafetyCounter = 50
				sHangoutName = kHangout.HangoutName
				While !kHangout.IsStopped() && iSafetyCounter
					iSafetyCounter -= 1
					Wait(0.1)
				EndWhile
				If !iSafetyCounter
					Debug.Trace("MYC/HOM/" + sHangoutName + ": Safety timer expired before " + kHangout + " was stopped.",1)
				EndIf
				If !sHangoutName
					Int jHangoutPool = JMap.GetObj(_jHangoutData,JKEY_HANGOUT_POOL)
					If JArray.FindForm(jHangoutPool,kHangout) < 0
						JArray.AddForm(jHangoutPool,kHangout)
						Debug.Trace("MYC/HOM: Added " + kHangout + " to the Hangout pool!")
					EndIf
				EndIf
			ElseIf kQuest as vMYC_WanderQuestScript
				Debug.Trace("MYC/HOM/WQ: Stopping " + kQuest + " on " + akActor + "...",1)
				(kQuest as vMYC_WanderQuestScript).DoShutdown()
			EndIf
		EndIf
	EndWhile
;	Int jHangoutQuestMap = JMap.getObj(_jHangoutData,JKEY_HANGOUTQUEST_FMAP)
;	Int jAssignedQuests = JFormMap.AllKeys(jHangoutQuestMap)
;	Int i = JArray.Count(jAssignedQuests)
;	While i > 0
;		i -= 1
;		Quest kHangoutQuest = JArray.GetForm(jAssignedQuests,i) as Quest
;		If kHangoutQuest
;			If (kHangoutQuest.GetAliasByName("HangoutActor") as ReferenceAlias).GetReference() == akActor
;				Debug.Trace("MYC/HOM/" + JFormMap.GetStr(jHangoutQuestMap,kHangoutQuest) + ": Stopping " + kHangoutQuest + "...",1)
;				(kHangoutQuest as vMYC_HangoutQuestScript).EnableTracking(False)
;				((kHangoutQuest as vMYC_HangoutQuestScript).GetAliasByName("HangoutActor") as ReferenceAlias).Clear()
;				kHangoutQuest.Stop()
;				JFormMap.RemoveKey(jHangoutQuestMap,kHangoutQuest)
;			EndIf
;		EndIf
;	EndWhile
EndFunction

Actor Function GetHangoutActor(String sHangoutName)
	


EndFunction

Function EnableTracking(Actor akActor, Bool abTracking = True)
	Debug.Trace("MYC/HOM: Set Tracking for " + akActor.GetActorBase().GetName() + " to " + abTracking)
	Int i = akActor.GetNumReferenceAliases()
	While i > 0
		i -= 1
		ReferenceAlias kRefAlias = akActor.GetNthReferenceAlias(i)
		If kRefAlias
			Quest kQuest = kRefAlias.GetOwningQuest()
			Debug.Trace("MYC/HOM:   " + akActor.GetActorBase().GetName() + "'s HangoutQuest is " + kQuest)
			If kQuest as vMYC_HangoutQuestScript
				(kQuest as vMYC_HangoutQuestScript).EnableTracking(abTracking)
			ElseIf kQuest as vMYC_WanderQuestScript
				(kQuest as vMYC_WanderQuestScript).EnableTracking(abTracking)
			EndIf
		EndIf
	EndWhile
EndFunction

Int[] Function GetHangoutStats()
{Return [iNumHangouts,iNumPresets,iNumQuestsRunning,iNumQuestsAvailable}
	String[] sHangoutNames = HangoutNames
	Int i = 0
	Int iNumHangouts = 0
	Int iNumPresets = 0
	Int iNumQuestsRunning = 0
	Int iNumQuestsAvailable = 0
	While i < sHangoutNames.Length
		If sHangoutNames[i]
			iNumHangouts += 1
			vMYC_HangoutQuestScript kHangout = GetHangoutQuest(sHangoutNames[i])
			If kHangout
				If kHangout.IsRunning()
					iNumQuestsRunning += 1
				EndIf
				If kHangout.HangoutName || kHangout.IsPreset
					iNumPresets += 1
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	iNumQuestsAvailable = JArray.Count(JMap.GetObj(_jHangoutData,JKEY_HANGOUT_POOL)) + iNumPresets - iNumQuestsRunning
	Int[] iReturn = New Int[4]
	iReturn[0] = iNumHangouts
	iReturn[1] = iNumPresets
	iReturn[2] = iNumQuestsRunning
	iReturn[3] = iNumQuestsAvailable
	Return iReturn
EndFunction

Int Function GetFullHangoutObj(String asHangoutName)
	Return JMap.getObj(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),asHangoutName)
EndFunction

Int Function GetHangoutObjBySourceCharacter(String asCharacterName)
	String[] sHangoutNames = HangoutNames
	Int i = 0
	While i < sHangoutNames.Length
		If sHangoutNames[i]
			If asCharacterName == GetHangoutStr(sHangoutNames[i],"SourceCharacter")
				Return JMap.getObj(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),sHangoutNames[i])
			EndIf
		EndIf
		i += 1
	EndWhile
	Return 0
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
	
	Int jHangoutFileData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
	If !jHangoutFileData
		jHangoutFileData = JValue.ReadFromFile("Data/vMYC/vMYC_Hangouts.json")
		JValue.WriteToFile(_jHangoutData,JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
	EndIf
	Int DataSerial = JMap.getInt(_jHangoutData,"DataSerial")
	Int DataFileSerial = JMap.getInt(jHangoutFileData,"DataSerial")
	If DataSerial > DataFileSerial
		Debug.Trace("MYC/HOM: Our data is newer than the saved file, overwriting it!")
		;JValue.WriteToFile(_jHangoutData,"Data/vMYC/vMYC_Hangouts.json")
		JValue.WriteToFile(_jHangoutData,JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
	ElseIf DataSerial < DataFileSerial
		Debug.Trace("MYC/HOM: Our data is older than the saved file, loading it!")
		_jHangoutData = JValue.Release(_jHangoutData)
		_jHangoutData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
		JMap.SetObj(_jMYC,"Hangouts",_jHangoutData)
		bUpdated = True
	Else
		;Already synced. Sunc?
	EndIf
	Return bUpdated
EndFunction

Function LoadHangouts() 
	Int jHangoutData = JDB.solveObj(".vMYC.Hangouts")
	_jHangoutData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
EndFunction

Function SaveHangouts() 
	Int jHangoutData = JDB.solveObj(".vMYC.Hangouts")
	JMap.setInt(jHangoutData,"DataSerial",JMap.getInt(jHangoutData,"DataSerial") + 1)
	JValue.WriteToFile(jHangoutData,JContainers.userDirectory() + "vMYC/vMYC_Hangouts.json")
EndFunction

Function AssignHangout()
	
EndFunction

Function SendHangoutPing()
	RegisterForModEvent("vMYC_HangoutPong","OnHangoutPong")
	Int iHandle = ModEvent.Create("vMYC_HangoutPing")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	EndIf
EndFunction

Int Function GetNumActorsInHangout(String asHangoutName)
	Return GetLocalHangoutInt(asHangoutName,"ActorCount")
EndFunction

Function SetHangoutEnabled(String asHangoutName, Bool abEnabled)
	SetLocalHangoutInt(asHangoutName,"IsEnabled",abEnabled as Int)
EndFunction

Bool Function IsHangoutEnabled(String asHangoutName)
	;Hangouts are enabled by default so return true if there's no entry
	If HasLocalHangoutKey(asHangoutName,"IsEnabled") 
		Return GetLocalHangoutInt(asHangoutName,"IsEnabled") as Bool
	EndIf
	Return True
EndFunction

;==== Generic functions for get/setting Hangout-specific data

Int Function CreateHangoutDataIfMissing(String asHangoutName)
	If !asHangoutName
		Debug.Trace("MYC/HOM: SetHangoutData function called without HangoutName specified!")
		Return 0
	EndIf
	TickDataSerial()
	Int jHangout = JMap.getObj(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),asHangoutName)
	If jHangout
		Return jHangout
	EndIf
	Debug.Trace("MYC/HOM/" + asHangoutName + ": First Hangout data access, creating HangoutData key!")
	jHangout = JMap.Object()
	JMap.setObj(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),asHangoutName,jHangout)
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
	Return JValue.solveStr(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutInt(String asHangoutName, String asPath, Int aiInt)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setInt(jHangout,asPath,aiInt)
EndFunction

Int Function GetHangoutInt(String asHangoutName, String asPath)
	Return JValue.solveInt(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutFlt(String asHangoutName, String asPath, Float afFloat)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setFlt(jHangout,asPath,afFloat)
EndFunction

Float Function GetHangoutFlt(String asHangoutName, String asPath)
	Return JValue.solveFlt(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutForm(String asHangoutName, String asPath, Form akForm)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setForm(jHangout,asPath,akForm)
EndFunction

Form Function GetHangoutForm(String asHangoutName, String asPath)
	Return JValue.solveForm(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),"." + asHangoutName + "." + asPath)
EndFunction

Function SetHangoutObj(String asHangoutName, String asPath, Int ajObj)
	Int jHangout = CreateHangoutDataIfMissing(asHangoutName)
	JMap.setObj(jHangout,asPath,ajObj)
EndFunction

Int Function GetHangoutObj(String asHangoutName, String asPath)
	Return JValue.solveObj(JMap.getObj(_jHangoutData,JKEY_HANGOUT_MAP),"." + asHangoutName + "." + asPath)
EndFunction


Int Function CreateLocalHangoutDataIfMissing(String asLocalHangoutName)
	If !asLocalHangoutName
		Debug.Trace("MYC/HOM: SetLocalHangoutData function called without LocalHangoutName specified!")
		Return 0
	EndIf
	Int jLocalHangout = GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName)
	If jLocalHangout
		Return jLocalHangout
	EndIf
	Debug.Trace("MYC/HOM/" + asLocalHangoutName + ": First LocalHangout data access, creating LocalHangoutData key!")
	jLocalHangout = JMap.Object()
	SetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName,jLocalHangout)
	Return jLocalHangout
EndFunction

Bool Function HasLocalHangoutKey(String asLocalHangoutName, String asPath)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	Return JMap.HasKey(jLocalHangout,asPath)
EndFunction

Function SetLocalHangoutStr(String asLocalHangoutName, String asPath, String asString)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	JMap.setStr(jLocalHangout,asPath,asString)
EndFunction

String Function GetLocalHangoutStr(String asLocalHangoutName, String asPath)
	Return JValue.solveStr(GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName),"." + asPath)
EndFunction

Function SetLocalHangoutInt(String asLocalHangoutName, String asPath, Int aiInt)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	JMap.setInt(jLocalHangout,asPath,aiInt)
EndFunction

Int Function GetLocalHangoutInt(String asLocalHangoutName, String asPath)
	Return JValue.solveInt(GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName),"." + asPath)
EndFunction

Function SetLocalHangoutFlt(String asLocalHangoutName, String asPath, Float afFloat)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	JMap.setFlt(jLocalHangout,asPath,afFloat)
EndFunction

Float Function GetLocalHangoutFlt(String asLocalHangoutName, String asPath)
	Return JValue.solveFlt(GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName),"." + asPath)
EndFunction

Function SetLocalHangoutForm(String asLocalHangoutName, String asPath, Form akForm)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	JMap.setForm(jLocalHangout,asPath,akForm)
EndFunction

Form Function GetLocalHangoutForm(String asLocalHangoutName, String asPath)
	Return JValue.solveForm(GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName),"." + asPath)
EndFunction

Function SetLocalHangoutObj(String asLocalHangoutName, String asPath, Int ajObj)
	Int jLocalHangout = CreateLocalHangoutDataIfMissing(asLocalHangoutName)
	JMap.setObj(jLocalHangout,asPath,ajObj)
EndFunction

Int Function GetLocalHangoutObj(String asLocalHangoutName, String asPath)
	Return JValue.solveObj(GetLocalConfigObj(JKEY_LOCALCONFIG + asLocalHangoutName),"." + asPath)
EndFunction

Function CleanupTempJContainers()
	JValue.ReleaseObjectsWithTag("vMYC_HOM")
EndFunction
