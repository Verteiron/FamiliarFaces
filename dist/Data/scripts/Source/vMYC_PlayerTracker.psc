Scriptname vMYC_PlayerTracker extends ReferenceAlias
{Tracks player's inventory, stats, etc in the background to save time while saving.}
;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_Session

;=== Properties ===--

Int					Property	MaxThreadCount = 8 	AutoReadOnly Hidden

Bool				Property	Busy				Auto	Hidden

Actor 				Property	PlayerREF			Auto

Formlist 			Property	vMYC_InventoryList	Auto
Formlist 			Property	vMYC_PerkList		Auto

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
		GotoState("Refreshing")
		RegisterForModEvent("vMYC_DataManagerReady","OnDataManagerReady")
		Busy = True
		_bRefreshed = False
	EndIf
EndEvent

Event OnUpdate()
	If PlayerREF.IsInCombat() ; Don't do this while in combat, it may slow down other more important scripts
		RegisterForSingleUpdate(5)
		Return
	EndIf
	
	If !_bRefreshed
		_bRefreshed = True
		;SendModEvent("vMYC_BackgroundFunction","SavePlayerAchievements")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerMiscStats")
		;SendModEvent("vMYC_BackgroundFunction","SavePlayerNINodeInfo")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerPerks")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerInventory")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerSpells")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerShouts")
		SendModEvent("vMYC_BackgroundFunction","SavePlayerEquipment")
		SetSessionInt("SpellCount",PlayerRef.GetSpellCount())
		SetSessionInt("PerkPoints",GetPerkPoints())
		SendModEvent("vMYC_TrackerReady")
	EndIf
	If GetPerkPoints() != GetSessionInt("PerkPoints")
		_bNeedPerkScan = True
	EndIf
	If _bNeedEquipmentScan
		_bNeedEquipmentScan = False
		SendModEvent("vMYC_BackgroundFunction","ScanPlayerEquipment")
	EndIf
	If _bNeedSpellScan
		_bNeedSpellScan = False
		SendModEvent("vMYC_BackgroundFunction","ScanPlayerSpells")
	EndIf
	If _bNeedPerkScan
		_bNeedPerkScan = False
		SendModEvent("vMYC_BackgroundFunction","ScanPlayerPerks")
	EndIf
	SetSessionInt("SpellCount",PlayerRef.GetSpellCount())
	SetSessionInt("PerkPoints",GetPerkPoints())
	Busy = False
	RegisterForSingleUpdate(5)
;	JValue.WriteToFile(_jInventory,"Data/vMYC/_PlayerInventory.json")
EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvent("vMYC_DataManagerReady","OnDataManagerReady")
EndEvent

Event OnDataManagerReady(string eventName, string strArg, float numArg, Form sender)
	UnregisterForModEvent("vMYC_DataManagerReady")
	RegisterForSingleUpdate(1)
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

State Overloaded

	Event OnBeginState()
		Busy = True
		RegisterForSingleUpdate(5.0)
		;Debug.Trace("MYC: " + Self + " Too many items moving around at once, suspending item tracking...")
	EndEvent

	Event OnUpdate()
		;Debug.Trace("MYC: " + Self + " Resuming item tracking...")
		GoToState("")
		_iThreadCount = 0
		_bRefreshed = False
		RegisterForSingleUpdate(0.1)
	EndEvent

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

EndState

State Refreshing

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent

EndState

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
	Debug.Trace("MYC/PlayerTracker: " + sDebugString,iSeverity)
EndFunction
