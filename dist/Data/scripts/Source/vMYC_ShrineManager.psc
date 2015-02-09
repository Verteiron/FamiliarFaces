Scriptname vMYC_ShrineManager extends vMYC_ManagerBase
{Handle registration and tracking of Shrine.Alcove}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--


;=== Properties ===--

Actor 				Property PlayerRef 								Auto
{The Player, duh}

;=== Achievement test Properties ===--

;=== Variables ===--

;=== Events ===--

Event OnInit()
	If IsRunning()
		RegisterForSingleUpdate(3)
	EndIf
EndEvent

Event OnGameReload()
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

Function SendShrineManagerReady()
	DebugTrace("Checking Alcoves!")
	RegisterForModEvent("vMYC_AlcoveRegister","OnAlcoveRegister")
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
