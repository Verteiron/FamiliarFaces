Scriptname vMYC_HangoutQuestScript extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

String Property HangoutName Auto

Bool Property IsPreset = False Auto

Bool Property Registered = False Auto

;--=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_HangoutPing","OnHangoutPing")
EndEvent

Event OnHangoutPing(Form akHangoutManager)
	Debug.Trace("MYC/HQ: Got HangoutPing from " + akHangoutManager + "!")
	Int iHandle = ModEvent.Create("vMYC_HangoutPong")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.PushForm(iHandle,(GetAliasByName("HangoutLocation") as LocationAlias).GetLocation())
		ModEvent.PushString(iHandle,HangoutName)
		ModEvent.Send(iHandle)
	EndIf
	If !Registered && (GetAliasByName("HangoutActor") as ReferenceAlias).GetReference()
		SendRegistrationEvent()
	EndIf
EndEvent

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, Int aiValue1, Int aiValue2)
	If IsRunning()
		If !HangoutName
			HangoutName = (GetAliasByName("HangoutLocation") as LocationAlias).GetLocation().GetName()
		EndIf
		RegisterForModEvent("vMYC_HangoutPing","OnHangoutPing")
		;OnHangoutQuestRegister(Form akSendingQuest, Form akActor, Form akLocation, Form akMapMarker, Form akCenterMarker)
		SendRegistrationEvent()
	EndIf
EndEvent

;--=== Functions ===--

Function SendRegistrationEvent()
	Int iEventHandle = ModEvent.Create("vMYC_HangoutQuestRegister")
	If iEventHandle
		ModEvent.PushForm(iEventHandle,Self)
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutActor") as ReferenceAlias).GetReference())
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutLocation") as LocationAlias).GetLocation())
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference())
		ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference())
		ModEvent.PushString(iEventHandle,HangoutName)
		ModEvent.Send(iEventHandle)
		Registered = True
	EndIf
EndFunction

Function EnableTracking(Bool abTracking = True)
	ObjectReference kHangoutMarker = (GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference()
	If !kHangoutMarker
		SetObjectiveDisplayed(0,abTracking)
	EndIf
	Int iObjective = 1
	If kHangoutMarker.IsInInterior() || IsPreset
		iObjective = 0
	EndIf
	SetObjectiveDisplayed(iObjective,abTracking)
EndFunction
