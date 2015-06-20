Scriptname vFFC_ConfigManager extends vFFC_ManagerBase
{Manage configuration and default data.}

; === [ vFFC_ConfigManager.psc ] ============================================---
; Main interface for managing configuration data and defaults.
; Handles:
;  Setting and returning defaults
;  Sending events when configuration data is changed
;  Timestamping configs for polling scripts
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_Session

;=== Constants ===--

String				Property META			= ".Info"				Auto Hidden

;=== Properties ===--

Bool Property IsBusy Auto Hidden
Bool Property NeedUpkeep Auto Hidden

;=== Variables ===--

Int _jConfigDefaults
Int _jConfigData

;=== Events ===--

Event OnInit()
	If IsRunning() && !IsBusy
		IsBusy = True
		DoUpkeep(False)
		RegisterForSingleUpdate(5.0)
		IsBusy = False
	EndIf
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
	SendModEvent("vFFC_ConfigManagerReady")
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnGameReload()
	DebugTrace("OnGameReload")
	DoUpkeep(False)
EndEvent

;=== Functions ===--

Function RegisterForModEvents()
	RegisterForModEvent("vFFC_SetConfigBool",	"OnSetConfigBool")
	RegisterForModEvent("vFFC_SetConfigInt",	"OnSetConfigInt")
	RegisterForModEvent("vFFC_SetConfigFloat",	"OnSetConfigFloat")
	RegisterForModEvent("vFFC_SetConfigString",	"OnSetConfigString")
	RegisterForModEvent("vFFC_SetConfigForm",	"OnSetConfigForm")
	RegisterForModEvent("vFFC_SetConfigBool",	"OnSetConfigBool")
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game.}
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	NeedUpkeep = False
	IsBusy = True
	DebugTrace("Starting upkeep...")
	SendModEvent("vFFC_UpkeepBegin")
	RegisterForModEvents()

	_jConfigDefaults = GetRegObj("Config")
	_jConfigData = GetSessionObj("Config")
	If !_jConfigDefaults
		_jConfigDefaults = CreateConfigDefaults()
		SaveReg()
	EndIf
	If !_jConfigData
		_jConfigData = JValue.DeepCopy(_jConfigDefaults)
	EndIf

	IsBusy = False
	DebugTrace("Finished upkeep!")
	SendModEvent("vFFC_UpkeepEnd")
EndFunction

Int Function CreateConfigDefaults()
	_jConfigDefaults = JMap.Object()

	DebugTrace("Setting Config defaults!")
	SetConfigBool("Compat.Enabled",True,abMakeDefault = True)
	SetConfigBool("Warnings.Enabled",True,abMakeDefault = True)
	SetConfigBool("Debug.Perf.Theads.Limit",False,abMakeDefault = True)
	SetConfigInt("Debug.Perf.Threads.Max",4,abMakeDefault = True)
	SetConfigBool("Magic.AutoByPerks",True,abMakeDefault = True)
	SetConfigBool("Magic.AllowOther",True,abMakeDefault = True)
	SetConfigBool("Magic.AllowHealing",True,abMakeDefault = True)
	SetConfigBool("Magic.AllowDefensive",True,abMakeDefault = True)

EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/ConfigManager: " + sDebugString,iSeverity)
EndFunction