Scriptname vMYC_ShrineTorchShadowTrigScript extends ObjectReference
{Handle shrine shadow torch activation when player gets close.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Activator		Property vMYC_AlcoveTorchShadowEnableParent		Auto
Activator		Property vMYC_AlcoveTorchNShadowEnableParent	Auto
Activator		Property vMYC_AlcoveLightingControllerActivator Auto

Actor			Property PlayerREF	Auto

ObjectReference	Property TorchNS Auto
ObjectReference	Property TorchS  Auto

Keyword 		Property vMYC_AlcoveTorchesNS		Auto
Keyword 		Property vMYC_AlcoveTorchesS		Auto
Keyword			Property vMYC_LightingControllerKW	Auto

vMYC_AlcoveLightingController	Property AlcoveLightingController	Auto

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
	TorchNS 				 = GetLinkedRef(vMYC_AlcoveTorchesNS)
	TorchS 					 = GetLinkedRef(vMYC_AlcoveTorchesS)
	AlcoveLightingController = GetLinkedRef(vMYC_LightingControllerKW) as vMYC_AlcoveLightingController
	;If !AlcoveLightingController.AlcoveTorchTriggerBox
	;	AlcoveLightingController.AlcoveTorchTriggerBox = Self
	;EndIf
	DebugTrace("TorchNS is " + TorchNS + ", TorchS is " + TorchS + ", LightingController is " + AlcoveLightingController)
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/ShrineTorchTrigger/" + Self + ": " + sDebugString,iSeverity)
	FFUtils.TraceConsole(sDebugString)
EndFunction
