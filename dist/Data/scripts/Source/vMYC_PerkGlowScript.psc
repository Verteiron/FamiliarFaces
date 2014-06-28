Scriptname vMYC_PerkGlowScript extends ObjectReference

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor Property PlayerREF Auto

String Property StartNode Auto Hidden

ObjectReference Property Target Hidden
	ObjectReference Function Get()
		Return _kTarget
	EndFunction
	Function Set(ObjectReference kTarget)
		_kTarget = kTarget
		DoFlight()
	EndFunction
EndProperty

;--=== Globals ===--

ObjectReference _kTarget

;--=== Events/Function ===--

Event OnLoad()
	RegisterForSingleUpdate(RandomFloat(1,3))
EndEvent

Event OnUpdate()
	If !Is3DLoaded()
		Wait(2)
	EndIf
	If Is3DLoaded()
		SplineTranslateTo(_kTarget.GetPositionX(),_kTarget.GetPositionY(),_kTarget.GetPositionZ() + 50,RandomFloat(-180,180),RandomFloat(-180,180),RandomFloat(-180,180),RandomFloat(500,800),RandomFloat(350,450))
	Else
		Delete()
	EndIf
EndEvent

Function DoFlight()
	SetScale(0.5)
	If StartNode && PlayerREF.HasNode(StartNode)
		MoveToNode(PlayerRef,StartNode)
	Else
		MoveTo(PlayerREF)
	EndIf
	SetAngle(RandomInt(-10,10),RandomInt(-10,10),RandomInt(0,359))
	Wait(RandomFloat(0,6))
	EnableNoWait(True)
EndFunction