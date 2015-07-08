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
	Int jAlcoveMap = GetRegObj("Shrine")
	String sKey = JMap.NextKey(jAlcoveMap)
	DebugTrace("sKey is " + sKey + "!")
	While sKey
		vFFP_AlcoveController AlcoveController = GetRegForm("Shrine." + sKey + ".Form") as vFFP_AlcoveController
		AlcoveController.OnGameReload()
		sKey = JMap.NextKey(jAlcoveMap,sKey)
		DebugTrace("sKey is " + sKey + "!")
	EndWhile
	SendShrineManagerReady()
EndEvent

Function RegisterForModEvents()
	RegisterForModEvent("vFF_DataManagerReady","OnDataManagerReady")
EndFunction

Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
	If !DataManager && (sender as vFFC_DataManager)
		DebugTrace("Setting DataManager to " + sender + "!")
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
	String sTestID = vFF_API_Character.GetSIDsByName("Ciara")[0]
	kAlcove.AlcoveCharacterID = sTestID
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
