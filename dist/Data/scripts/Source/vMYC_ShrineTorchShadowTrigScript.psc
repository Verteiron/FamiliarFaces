Scriptname vMYC_ShrineTorchShadowTrigScript extends ObjectReference  
{Handle shrine shadow torch activation when player gets close}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor			Property PlayerREF	Auto

ObjectReference	Property TorchNS Auto
ObjectReference	Property TorchS  Auto

;--=== Variables ===--

Bool	_bShadowsEnabled = False

;--=== Events ===--

Event OnTriggerEnter(ObjectReference akActionRef)
	If akActionRef == PlayerREF
		_bShadowsEnabled = True
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
		TorchNS.EnableNoWait(False)
		Wait(0)
		TorchS.DisableNoWait(False)
	EndIf
EndEvent