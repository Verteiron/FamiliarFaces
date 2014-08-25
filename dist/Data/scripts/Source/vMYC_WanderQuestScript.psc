Scriptname vMYC_WanderQuestScript extends Quest  
{Updates status of wander quest, stops it when necessary.}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

GlobalVariable 		Property 	GameHour 					Auto

Keyword 			Property 	LocTypeHabitation 			Auto
Keyword				Property	vMYC_Wanderer				Auto

Bool				Property	TrackingEnabled				Auto Hidden

;--=== Variables ===--

Actor 	 _WanderActor
Location _City
Location _Inn

;--=== Events ===--

Event OnInit()
	If IsRunning()
		UpdateVariables()
		Debug.Trace("MYC/WQ: " + Self + " Starting from OnInit with " + _WanderActor + " and " + _City + "!")
		RegisterForSingleUpdate(1)
	EndIf
EndEvent

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, Int aiValue1, Int aiValue2)
	If IsRunning()
		UpdateVariables()
		Debug.Trace("MYC/WQ: " + Self + " Starting from OnStoryScript with " + _WanderActor + " and " + _City + "!")
		RegisterForSingleUpdate(1)
	EndIf
EndEvent

Event OnUpdate()
	;Debug.Trace("MYC/WQ: OnUpdateGameTime!")
	UpdateVariables()
	UpdateObjective()
	If !_WanderActor
		DoShutdown()
		Return
	EndIf
	If IsObjectiveDisplayed(2) && GameHour.GetValue() > 6 && GameHour.GetValue() < 9
		If vMYC_Wanderer.SendStoryEventAndWait(akRef1 = _WanderActor)
			DoShutdown()
			Return
		Else
			Debug.Trace("MYC/WQ: Couldn't send story event to resume wandering, staying in " + _City + " for now!")
		EndIf
	EndIf
	If IsRunning()
		RegisterForSingleUpdate(30)
	EndIf
EndEvent

Event OnSetTrackingOnActor(Form akActor, Bool abEnableTracking)
	If _WanderActor == akActor
		EnableTracking(abEnableTracking)
	EndIf
EndEvent

;--=== Functions ===--

Function DoShutdown()
	UnregisterForUpdate()
	UnregisterForModEvent("vMYC_SetTrackingOnActor")
	SetObjectiveDisplayed(0,False)
	SetObjectiveDisplayed(1,False)
	SetObjectiveDisplayed(2,False)
	Stop()
EndFunction

Function UpdateObjective()
	UpdateVariables()
	If !_WanderActor
		Return
	EndIf
	If !_WanderActor.GetCurrentLocation()
		Return
	EndIf
	If !TrackingEnabled
		SetObjectiveDisplayed(0,False)
		SetObjectiveDisplayed(1,False)
		SetObjectiveDisplayed(2,False)
		Return
	EndIf
	If !_WanderActor.GetCurrentLocation().IsSameLocation(_City,LocTypeHabitation)
		SetObjectiveDisplayed(1,False)
		SetObjectiveDisplayed(2,False)
		If !IsObjectiveDisplayed(0)
			SetObjectiveDisplayed(0,TrackingEnabled)
		EndIf
	ElseIf GameHour.GetValue() > 8.0 && GameHour.GetValue() < 19.0 && _WanderActor.GetCurrentLocation().IsSameLocation(_City,LocTypeHabitation)
		SetObjectiveDisplayed(0,False)
		SetObjectiveDisplayed(2,False)
		If !IsObjectiveDisplayed(1)
			SetObjectiveDisplayed(1,TrackingEnabled)
		EndIf
	ElseIf _WanderActor.GetCurrentLocation().IsSameLocation(_City,LocTypeHabitation)
		SetObjectiveDisplayed(0,False)
		SetObjectiveDisplayed(1,False)
		If !IsObjectiveDisplayed(2)
			SetObjectiveDisplayed(2,TrackingEnabled)
		EndIf
	EndIf
EndFunction

Function UpdateVariables()
	If !IsRunning()
		Return
	EndIf
	_WanderActor = (GetAliasByName("WanderActor") as ReferenceAlias).GetReference() as Actor
	_City = (GetAliasByName("City") as LocationAlias).GetLocation()
	_Inn = (GetAliasByName("Inn") as LocationAlias).GetLocation()
	RegisterForModEvent("vMYC_SetTrackingOnActor","OnSetTrackingOnActor")
EndFunction

Function EnableTracking(Bool abTracking = True)
	TrackingEnabled = abTracking
	UpdateObjective()
EndFunction
