Scriptname vFFC_PlayerTracker extends ReferenceAlias
{Tracks player's inventory, stats, etc in the background to save time while saving.}
;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_Session

;=== Properties ===--

Int					Property	MaxThreadCount = 8 	AutoReadOnly Hidden

Bool				Property	Busy				Auto	Hidden

Actor 				Property	PlayerREF			Auto

Formlist 			Property	vFFC_InventoryList	Auto
Formlist 			Property	vFFC_PerkList		Auto

;=== Variables ===--

Bool	_bRefreshed
Bool	_bNeedEquipmentScan	=	False
Bool	_bNeedSpellScan		=	False
Bool	_bNeedPerkScan		=	False

Int		_iThreadCount

Int		_jInventory
Int		_jAVNames		= 0


;=== Events ===--

Event OnInit()
	If GetOwningQuest().IsRunning()
		GotoState("Sleeping")
		RegisterForModEvents()
		Busy = True
		_bRefreshed = False
	EndIf
EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvents()
EndEvent

Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OnPlayerTrackerStart(string eventName, string strArg, float numArg, Form sender)
	GoToState("Scanning")
EndEvent

Event OnPlayerTrackerStop(string eventName, string strArg, float numArg, Form sender)
	GoToState("Sleeping")
EndEvent

Function RegisterForModEvents()
	RegisterForModEvent("vFFC_DataManagerReady","OnDataManagerReady")
	RegisterForModEvent("vFFC_PlayerTrackerStart","OnPlayerTrackerStart")
	RegisterForModEvent("vFFC_PlayerTrackerStop","OnPlayerTrackerStop")
EndFunction

Auto State Sleeping

	Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
	EndEvent

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnUpdate()
	EndEvent

	Event OnPlayerTrackerStart(string eventName, string strArg, float numArg, Form sender)
		GoToState("Scanning")
	EndEvent

	Event OnPlayerTrackerStop(string eventName, string strArg, float numArg, Form sender)
	EndEvent

EndState

State Scanning

	Event OnBeginState()
		DebugTrace("Background scanning player data...")
		RegisterForSingleUpdate(0.1)
	EndEvent

	Event OnUpdate()
		If PlayerREF.IsInCombat() ; Don't do this while in combat, it may slow down other more important scripts
			RegisterForSingleUpdate(5)
			Return
		EndIf
		
		If !_bRefreshed
			_bRefreshed = True
			;SendModEvent("vFFC_BackgroundFunction","ScanPlayerAchievements")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerMiscStats")
			;SendModEvent("vFFC_BackgroundFunction","ScanPlayerNINodeInfo")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerPerks")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerInventory")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerSpells")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerShouts")
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerEquipment")
			SetSessionInt("SpellCount",PlayerRef.GetSpellCount())
			SetSessionInt("PerkPoints",GetPerkPoints())
			SendModEvent("vFFC_TrackerReady")
		EndIf
		If GetPerkPoints() != GetSessionInt("PerkPoints")
			_bNeedPerkScan = True
		EndIf
		If _bNeedEquipmentScan
			_bNeedEquipmentScan = False
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerEquipment")
		EndIf
		If _bNeedSpellScan
			_bNeedSpellScan = False
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerSpells")
		EndIf
		If _bNeedPerkScan
			_bNeedPerkScan = False
			SendModEvent("vFFC_BackgroundFunction","ScanPlayerPerks")
		EndIf
		SetSessionInt("SpellCount",PlayerRef.GetSpellCount())
		SetSessionInt("PerkPoints",GetPerkPoints())
		Busy = False
		RegisterForSingleUpdate(5)
	;	JValue.WriteToFile(_jInventory,"Data/vFFC/_PlayerInventory.json")
	EndEvent

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		Busy = True
		If _iThreadCount == MaxThreadCount
			GotoState("Overloaded")
		EndIf
		_iThreadCount += 1
		Int iType = akBaseItem.GetType()

		If aiItemCount > 0 
			Int jItemTypeFMap = JMap.getObj(_jInventory,iType)
			If !JValue.IsFormMap(jItemTypeFMap)
				jItemTypeFMap = JFormMap.Object()
				JMap.setObj(_jInventory,iType,jItemTypeFMap)
			EndIf
			JFormMap.SetInt(jItemTypeFMap,akBaseItem,JFormMap.GetInt(jItemTypeFMap,akBaseItem) + aiItemCount)
		EndIf

		_iThreadCount -= 1
		Busy = False
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
		Busy = True
		If _iThreadCount == MaxThreadCount
			GotoState("Overloaded")
		EndIf
		_iThreadCount += 1
		Int iType = akBaseItem.GetType()

		If aiItemCount > 0 
			Int jItemTypeFMap = JMap.getObj(_jInventory,iType)
			If !JValue.IsFormMap(jItemTypeFMap)
				jItemTypeFMap = JFormMap.Object()
				JMap.setObj(_jInventory,iType,jItemTypeFMap)
			EndIf
			JFormMap.SetInt(jItemTypeFMap,akBaseItem,JFormMap.GetInt(jItemTypeFMap,akBaseItem) - aiItemCount)
		EndIf

		_iThreadCount -= 1
		Busy = False
	EndEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		_bNeedEquipmentScan = True
		RegisterForSingleUpdate(1)
	EndEvent

	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
		_bNeedEquipmentScan = True
		RegisterForSingleUpdate(1)
	EndEvent

	Event OnPlayerTrackerStart(string eventName, string strArg, float numArg, Form sender)
	EndEvent

	Event OnPlayerTrackerStop(string eventName, string strArg, float numArg, Form sender)
		GoToState("Sleeping")
	EndEvent

EndState ;Scanning

State Overloaded 
; Switch to this if a ton of items are added at once, hopefully preventing a huge mass of threads

	Event OnBeginState()
		Busy = True
		RegisterForSingleUpdate(5.0)
		;Debug.Trace("vFF: " + Self + " Too many items moving around at once, suspending item tracking...")
	EndEvent

	Event OnUpdate()
		;Debug.Trace("vFF: " + Self + " Resuming item tracking...")
		GoToState("Scanning")
		_iThreadCount = 0
		_bRefreshed = False
		RegisterForSingleUpdate(0.1)
	EndEvent

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnPlayerTrackerStart(string eventName, string strArg, float numArg, Form sender)
	EndEvent

	Event OnPlayerTrackerStop(string eventName, string strArg, float numArg, Form sender)
		GoToState("Sleeping")
	EndEvent

EndState ;Overloaded

State Refreshing

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnPlayerTrackerStart(string eventName, string strArg, float numArg, Form sender)
		GoToState("Scanning")
	EndEvent

	Event OnPlayerTrackerStop(string eventName, string strArg, float numArg, Form sender)
		GoToState("Sleeping")
	EndEvent

EndState ; Refreshing

Function StartTimer(String sTimerLabel)
	Float fTime = GetCurrentRealTime()
	;Debug.Trace("TimerStart(" + sTimerLabel + ") " + fTime)
	SetSessionFlt("Timers." + sTimerLabel,fTime)
EndFunction

Function StopTimer(String sTimerLabel)
	Float fTime = GetCurrentRealTime()
	;Debug.Trace("TimerStop (" + sTimerLabel + ") " + fTime)
	DebugTrace("Timer: " + (fTime - GetSessionFlt("Timers." + sTimerLabel)) + " for " + sTimerLabel)
	ClearSessionKey("Timers." + sTimerLabel)
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/PlayerTracker: " + sDebugString,iSeverity)
EndFunction
