Scriptname vMYC_HangoutQuestScript extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

String Property HangoutName Auto

Bool Property IsPreset = False Auto

Location Property HangoutLocation = None Auto

ObjectReference Property MarkerObject = None Auto

Bool Property Registered = False Auto Hidden

Bool Property TrackingEnabled	Auto Hidden

;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_HangoutPing","OnHangoutPing")
	RegisterForModEvent("vMYC_SetTrackingOnActor","OnSetTrackingOnActor")
	RegisterForModEvent("vMYC_ShutdownHangoutQuests","OnShutdownHangoutQuests")
EndEvent

Event OnHangoutPing(Form akHangoutManager)
	;Debug.Trace("MYC/HQ: Got HangoutPing from " + akHangoutManager + "!")
	Int iHandle = ModEvent.Create("vMYC_HangoutPong")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		Location kLocation = (GetAliasByName("HangoutLocation") as LocationAlias).GetLocation()
		If !kLocation
			kLocation = HangoutLocation
		EndIf
		ModEvent.PushForm(iHandle,kLocation)
		ModEvent.PushString(iHandle,HangoutName)
		ModEvent.Send(iHandle)
	EndIf
EndEvent

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
	If !IsPreset
		;Presets should already have sleeplocations defined
		FillSleepLocation()
	EndIf
	RegisterForModEvent("vMYC_SetTrackingOnActor","OnSetTrackingOnActor")
	ReferenceAlias kMarkerRef = GetAliasByName("HangoutMarker") as ReferenceAlias
	ObjectReference kMarkerObj = kMarkerRef.GetReference()
	If !kMarkerObj
		;Debug.Trace("MYC/HQ: Missing HangoutMarker, using HangoutCenter!")
		kMarkerRef.ForceRefTo((GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference())
	EndIf
	SendRegistrationEvent()
	;EnableTracking(True)
EndEvent

Event OnSetTrackingOnActor(Form akActor, Bool abEnableTracking)
	If (GetAliasByName("HangoutActor") as ReferenceAlias).GetReference() == akActor
		EnableTracking(abEnableTracking)
	EndIf
EndEvent

Event OnShutdownHangouts(string eventName, string strArg, float numArg, Form sender)
	DoShutdown()
EndEvent

;--=== Functions ===--

Function DoUpkeep()
	RegisterForModEvent("vMYC_HangoutPing","OnHangoutPing")
	RegisterForModEvent("vMYC_SetTrackingOnActor","OnSetTrackingOnActor")
	RegisterForModEvent("vMYC_ShutdownHangouts","OnShutdownHangouts")
EndFunction

Function DoShutdown()
	UnregisterForUpdate()
	UnregisterForModEvent("vMYC_HangoutPing")
	UnregisterForModEvent("vMYC_SetTrackingOnActor")
	SetObjectiveDisplayed(0,False)
	SetObjectiveDisplayed(1,False)
	Stop()
EndFunction

Function FillSleepLocation()
	LocationAlias kHangoutLocation = GetAliasByName("HangoutLocation") as LocationAlias
	LocationAlias kInnLocation = GetAliasByName("HangoutInn0") as LocationAlias
	LocationAlias kGuildLocation = GetAliasByName("HangoutGuildDwelling0") as LocationAlias
	LocationAlias kDwellingLocation = GetAliasByName("HangoutDwelling0") as LocationAlias

	;Not much point in continuing if this doesn't exist
	If !kInnLocation
		Return
	EndIf
	
	;If the hangout is in a Guild, Dwelling, or Castle, use it for eating and sleeping instead of the Inn.
	If kHangoutLocation.GetLocation().HasKeywordString("LocTypeGuild") || kHangoutLocation.GetLocation().HasKeywordString("LocTypeCastle") || kHangoutLocation.GetLocation().HasKeywordString("LocTypeDwelling")
		kInnLocation.ForceLocationTo(kHangoutLocation.GetLocation())
	EndIf

	If !kInnLocation.GetLocation()
		kInnLocation.ForceLocationTo(kHangoutLocation.GetLocation())
	EndIf
	
EndFunction

Function SendRegistrationEvent()
	Location kLocation = (GetAliasByName("HangoutLocation") as LocationAlias).GetLocation()
	Int iEventHandle = ModEvent.Create("vMYC_HangoutQuestRegister")
	If iEventHandle
		ModEvent.PushForm(iEventHandle,Self)
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutActor") as ReferenceAlias).GetReference())
		ModEvent.PushForm(iEventHandle,kLocation)
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference())
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference())
		If HangoutName
			ModEvent.PushString(iEventHandle,HangoutName)
		Else
			If kLocation
				If kLocation.GetName()
					ModEvent.PushString(iEventHandle,kLocation.GetName())
				Else
					ModEvent.PushString(iEventHandle,"")
				EndIf
			Else
				ModEvent.PushString(iEventHandle,"")
			EndIf
		EndIf
		ModEvent.Send(iEventHandle)
		Registered = True
	EndIf
EndFunction

Function EnableTracking(Bool abTracking = True)
	TrackingEnabled = abTracking
	ObjectReference kHangoutMarker = (GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference()
	;FIXME: Temporary change to avoid log errors
	Int iObjective = 0
	If kHangoutMarker
		If kHangoutMarker.IsInInterior() || IsPreset
			iObjective = 0
		EndIf
	ElseIf IsPreset
		iObjective = 0
	EndIf
	SetActive(abTracking)
	If IsObjectiveDisplayed(iObjective) != abTracking
		SetObjectiveDisplayed(iObjective,abTracking)
	EndIf
EndFunction
