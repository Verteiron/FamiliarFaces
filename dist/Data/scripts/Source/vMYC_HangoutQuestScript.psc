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
	;FIXME: Temporary change to avoid log errors
	Int iObjective = 0
	If kHangoutMarker
		If kHangoutMarker.IsInInterior() || IsPreset
			iObjective = 0
		EndIf
	ElseIf IsPreset
		iObjective = 0
	EndIf
	SetObjectiveDisplayed(iObjective,abTracking)
EndFunction
