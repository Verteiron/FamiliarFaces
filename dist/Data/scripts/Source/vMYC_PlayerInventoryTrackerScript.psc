Scriptname vMYC_PlayerInventoryTrackerScript extends ReferenceAlias  
{Tracks player's inventory in the background to save time while saving}
;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int		Property	MaxThreadCount = 8 	AutoReadOnly Hidden

Bool	Property	Busy				Auto	Hidden

Actor 	Property	PlayerREF			Auto

vMYC_CharacterManagerScript 	Property CharacterManager 	Auto

;--=== Variables ===--

Bool	_bRefreshed

Int		_iThreadCount

Int 	_jMYC
Int		_jInventory

;--=== Events ===--

Event OnInit()
	If GetOwningQuest().IsRunning()
		Int iSafety = 10
		While iSafety > 0 && !_jMYC
			Wait(1)
			_jMYC = JDB.solveObj(".vMYC")
		EndWhile
		If _jMYC
			JMap.setObj(_jMYC,"PlayerInventory",JFormMap.Object())
			_jInventory = JMap.getObj(_jMYC,"PlayerInventory")
			RegisterForSingleUpdate(1.0)
		EndIf
	EndIf
EndEvent

Event OnUpdate()
	If !_bRefreshed
		RefreshInventory()
	EndIf
;	JValue.WriteToFile(_jInventory,"Data/vMYC/_PlayerInventory.json")
EndEvent

Event OnPlayerLoadGame()
	
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Busy = True
	If _iThreadCount == MaxThreadCount
		GotoState("Overloaded")
	EndIf
	_iThreadCount += 1
	;If akItemReference
		;JFormMap.setInt(_jInventory,akItemReference,JFormMap.getInt(_jInventory,akItemReference) + aiItemCount)
	;Else
	JFormMap.setInt(_jInventory,akBaseItem,JFormMap.getInt(_jInventory,akBaseItem) + aiItemCount)
	;EndIf
	;RegisterForSingleUpdate(1.0)
	_iThreadCount -= 1
	Busy = False
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	Busy = True
	If _iThreadCount == MaxThreadCount
		GotoState("Overloaded")
	EndIf
	_iThreadCount += 1
	;If akItemReference
	;	Int iCount = JFormMap.getInt(_jInventory,akItemReference)
	;	If iCount - aiItemCount < 1
	;		JFormMap.removeKey(_jInventory,akItemReference)
	;	Else
	;		JFormMap.setInt(_jInventory,akItemReference,iCount - aiItemCount)
	;	EndIf
	;Else
	Int iCount = JFormMap.getInt(_jInventory,akBaseItem)
	If iCount - aiItemCount < 1
		JFormMap.removeKey(_jInventory,akBaseItem)
	Else
		JFormMap.setInt(_jInventory,akBaseItem,iCount - aiItemCount)
	EndIf
	;EndIf
	;RegisterForSingleUpdate(1.0)
	_iThreadCount -= 1
	Busy = False
EndEvent

Function RefreshInventory()
	Busy = True
	_iThreadCount += 1
	Debug.Trace("MYC: " + Self + " Refreshing player inventory...")
	Float fStartTime = GetCurrentRealTime()
	JFormMap.clear(_jInventory)
	Int iItemCount = PlayerREF.GetNumItems()
	Int i = 0
	Int iAddedCount = 0
	While i < iItemCount
		Form kItem = PlayerREF.GetNthForm(i)
		JFormMap.setInt(_jInventory,kItem,PlayerREF.GetItemCount(kItem))
		i += 1
	EndWhile
	Debug.Trace("MYC: " + Self + " Refreshed player inventory! Got " + iItemcount + " items, took " + (GetCurrentRealTime() - fStartTime) + "s!")
	_bRefreshed = True
	_iThreadCount -= 1
	Busy = False
EndFunction

State Overloaded

	Event OnBeginState()
		Busy = True
		RegisterForSingleUpdate(5.0)
		Debug.Trace("MYC: " + Self + " Too many items moving around at once, suspending item tracking...")	
	EndEvent
	
	Event OnUpdate()
		Debug.Trace("MYC: " + Self + " Resuming item tracking...")
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