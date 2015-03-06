Scriptname vMYC_ShrineManager extends vMYC_ManagerBase
{Handle registration and tracking of Shrine.Alcove.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--


;=== Properties ===--

Actor 				Property PlayerRef 								Auto
{The Player, duh.}

vMYC_DataManager	Property DataManager							Auto

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
	RegisterForModEvent("vMYC_DataManagerReady","OnDataManagerReady")
EndFunction

Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
	UnregisterForModEvent("vMYC_DataManagerReady")
	RegisterForSingleUpdate(3)
EndEvent

Event OnUpdate()
	SendShrineManagerReady()
EndEvent

Event OnAlcoveRegister(Int aiAlcoveIndex, Form akAlcoveForm)
	DebugTrace("Registering Alcove " + aiAlcoveIndex + " " + akAlcoveform + "...")
	vMYC_AlcoveController kAlcove = akAlcoveForm as vMYC_AlcoveController
	Int jAlcove = JMap.Object()
	JMap.SetInt(jAlcove,"Index",aiAlcoveIndex)
	JMap.SetForm(jAlcove,"Form",akAlcoveForm)
	JMap.SetStr(jAlcove,"UUID",GetUUID())
	SetRegObj("Shrine.Alcove" + aiAlcoveIndex,jAlcove)
	DebugTrace("Registered!")
EndEvent

Event OnAlcoveSync(Int aiAlcoveIndex, Form akAlcoveForm)
	DebugTrace("Synchronizing Alcove " + aiAlcoveIndex + " " + akAlcoveform + "...")
	vMYC_AlcoveController kAlcove = akAlcoveForm as vMYC_AlcoveController
	String sScalesLikeFireID = "A68F7820-A7DD-4B5c-B8cB-47B2ccFe7492"
	String sKmiruID = "09D1DF7A-4c77-4c77-9e39-351eA4407B3A"
	String sMagrazID = "c1c644e7-61e0-44DB-A0c7-A5D15DF3B1e6"  ;"A348AA31-33AF-45D5-8736-BBD9AB120EE3"
	kAlcove.AlcoveCharacterID = sKmiruID
	kAlcove.CheckForCharacterActor()
EndEvent

Function SendShrineManagerReady()
	DebugTrace("Checking Alcoves!")
	RegisterForModEvent("vMYC_AlcoveRegister","OnAlcoveRegister")
	RegisterForModEvent("vMYC_AlcoveSync","OnAlcoveSync")
	Int iHandle = ModEvent.Create("vMYC_ShrineManagerReady")
	If iHandle
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING! Could not send vMYC_AlcoveRegister event!",1)
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/ShrineManager: " + sDebugString,iSeverity)
EndFunction
