Scriptname vFFP_AlcoveTorchShadowTrigScript extends ObjectReference
{Handle shrine shadow torch activation when player gets close.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Activator		Property vFFP_AlcoveTorchShadowEnableParent		Auto
Activator		Property vFFP_AlcoveTorchNShadowEnableParent	Auto
Activator		Property vFFP_AlcoveLightingControllerActivator Auto

Actor			Property PlayerREF	Auto

ObjectReference	Property TorchNS Auto
ObjectReference	Property TorchS  Auto

Keyword 		Property vFFP_AlcoveTorchesNS		Auto
Keyword 		Property vFFP_AlcoveTorchesS		Auto
Keyword			Property vFFP_LightingControllerKW	Auto

vFFP_AlcoveLightingController	Property AlcoveLightingController	Auto

;=== Variables ===--

Bool	_bShadowsEnabled = False

;=== Events ===--

Event OnLoad()
	CheckObjects()
	If !AlcoveLightingController
		TorchS.DisableNoWait(False)
		TorchNS.DisableNoWait(False)
		Return
	EndIf
	If AlcoveLightingController.AlcoveLightState > 0
		TorchS.DisableNoWait(False)
		TorchNS.EnableNoWait(False)
	Else
		TorchS.DisableNoWait(False)
		TorchNS.DisableNoWait(False)
	EndIf
EndEvent

Event OnTriggerEnter(ObjectReference akActionRef)
	If akActionRef == PlayerREF
		_bShadowsEnabled = True
		If !TorchS
			DebugTrace("OnTriggerEnter fired before Torch objects were set!",1)
			Return
		EndIf
		TorchS.EnableNoWait(False)
		Wait(0)
		TorchNS.DisableNoWait(False)
	EndIf
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
	If akActionRef == PlayerREF
		_bShadowsEnabled = False
		Wait(1.0)
		If _bShadowsEnabled
			Return
		EndIf
		If !TorchS
			DebugTrace("OnTriggerLeave fired before Torch objects were set!",1)
			Return
		EndIf
		TorchNS.EnableNoWait(False)
		Wait(0)
		TorchS.DisableNoWait(False)
	EndIf
EndEvent

Function CheckObjects()
	If !TorchNS || !TorchS || !AlcoveLightingController
		FindObjects()
	EndIf
EndFunction

Function FindObjects()
	TorchNS 				 = GetLinkedRef(vFFP_AlcoveTorchesNS)
	TorchS 					 = GetLinkedRef(vFFP_AlcoveTorchesS)
	AlcoveLightingController = GetLinkedRef(vFFP_LightingControllerKW) as vFFP_AlcoveLightingController
	;If !AlcoveLightingController.AlcoveTorchTriggerBox
	;	AlcoveLightingController.AlcoveTorchTriggerBox = Self
	;EndIf
	DebugTrace("TorchNS is " + TorchNS + ", TorchS is " + TorchS + ", LightingController is " + AlcoveLightingController)
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/ShrineTorchTrigger/" + Self + ": " + sDebugString,iSeverity)
	FFUtils.TraceConsole(sDebugString)
EndFunction
