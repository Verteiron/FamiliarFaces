Scriptname vMYC_HangoutQuestScript extends Quest  
{Manage custom hangouts and player locations}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

String Property HangoutName Auto

ReferenceAlias Property HangoutActor Auto 
LocationAlias Property HangoutLocation Auto
ReferenceAlias Property HangoutMarker Auto
ReferenceAlias Property HangoutCenter Auto
LocationAlias Property HangoutInn0 Auto
LocationAlias Property HangoutStore0 Auto
LocationAlias Property HangoutStore1 Auto
LocationAlias Property HangoutStore2 Auto
LocationAlias Property HangoutDwelling0 Auto
LocationAlias Property HangoutGuildDwelling0 Auto
LocationAlias Property HangoutTownDwelling0 Auto
LocationAlias Property HangoutTemple0 Auto
LocationAlias Property HangoutDungeon0 Auto
ReferenceAlias Property HangoutDungeonBoss0 Auto
ReferenceAlias Property HangoutFriendMarker0 Auto

;--=== Events ===--

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, Int aiValue1, Int aiValue2)
	If IsRunning()
		HangoutName = akRef1.GetName()
		;OnHangoutQuestRegister(Form akSendingQuest, Form akActor, Form akLocation, Form akMapMarker, Form akCenterMarker)
		Int iEventHandle = ModEvent.Create("vMYC_HangoutQuestRegister")
		If iEventHandle
			ModEvent.PushForm(iEventHandle,Self)
			ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutActor") as ReferenceAlias).GetReference())
			ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutLocation") as LocationAlias).GetLocation())
			ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutMarker") as ReferenceAlias).GetReference())
			ModEvent.PushForm(iEventHandle,(GetAliasByName("HangoutCenter") as ReferenceAlias).GetReference())
			ModEvent.PushString(iEventHandle,(GetAliasByName("HangoutLocation") as LocationAlias).GetLocation().GetName())
			ModEvent.Send(iEventHandle)
		EndIf
	EndIf
EndEvent
