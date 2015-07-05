Scriptname vFFP_ShrineManager extends vFFC_ManagerBase
{Handle registration and tracking of Shrine.Alcove.}

; === [ vFF_ShrineManager.psc ] ==========================================---
; Handles:
;   Registering and tracking Alcoves
;   Central command for AlcoveControllers
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_Session

;=== Constants ===--


;=== Properties ===--

Actor 				Property PlayerRef 								Auto
{The Player, duh.}

vFFC_DataManager	Property DataManager							Auto

;=== Achievement test Properties ===--

;=== Variables ===--

;=== Events ===--

Event OnInit()
	If IsRunning()
		RegisterForModEvents()
	EndIf
EndEvent

Event OnGameReload()
	RegisterForModEvents()
EndEvent

Function RegisterForModEvents()
	RegisterForModEvent("vFF_DataManagerReady","OnDataManagerReady")
EndFunction

Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
	If !DataManager && (sender as vFFC_DataManager)
		DataManager = sender as vFFC_DataManager
	EndIf
	UnregisterForModEvent("vFF_DataManagerReady")
	RegisterForSingleUpdate(3)
EndEvent

Event OnUpdate()
	SendShrineManagerReady()
EndEvent

Event OnAlcoveRegister(Int aiAlcoveIndex, Form akAlcoveForm)
	DebugTrace("Registering Alcove " + aiAlcoveIndex + " " + akAlcoveform + "...")
	vFFP_AlcoveController kAlcove = akAlcoveForm as vFFP_AlcoveController
	Int jAlcove = JMap.Object()
	JMap.SetInt(jAlcove,"Index",aiAlcoveIndex)
	JMap.SetForm(jAlcove,"Form",akAlcoveForm)
	JMap.SetStr(jAlcove,"UUID",GetUUID())
	SetRegObj("Shrine.Alcove" + aiAlcoveIndex,jAlcove)
	DebugTrace("Registered!")
EndEvent

Event OnAlcoveSync(Int aiAlcoveIndex, Form akAlcoveForm)
	DebugTrace("Synchronizing Alcove " + aiAlcoveIndex + " " + akAlcoveform + "...")
	vFFP_AlcoveController kAlcove = akAlcoveForm as vFFP_AlcoveController
	String sScalesLikeFireID = "A68F7820-A7DD-4B5c-B8cB-47B2ccFe7492"
	String sKmiruID = "09D1DF7A-4c77-4c77-9e39-351eA4407B3A" ; "A3Ecc712-6F0A-40F0-B81F-B37c829B0E1A"
	String sMagrazID = "c1c644e7-61e0-44DB-A0c7-A5D15DF3B1e6"  ;"A348AA31-33AF-45D5-8736-BBD9AB120EE3"
	String sTagaerysID = "B1870CCA-A4AB-4946-AE08-FB50931BBB28"
	kAlcove.AlcoveCharacterID = sTagaerysID
	kAlcove.CheckForCharacterActor()
EndEvent

Function SendShrineManagerReady()
	DebugTrace("Checking Alcoves!")
	RegisterForModEvent("vFF_AlcoveRegister","OnAlcoveRegister")
	RegisterForModEvent("vFF_AlcoveSync","OnAlcoveSync")
	Int iHandle = ModEvent.Create("vFF_ShrineManagerReady")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING! Could not send vFF_AlcoveRegister event!",1)
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/ShrineManager: " + sDebugString,iSeverity)
EndFunction
