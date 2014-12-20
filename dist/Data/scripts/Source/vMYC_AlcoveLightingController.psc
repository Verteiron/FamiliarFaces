Scriptname vMYC_AlcoveLightingController extends ObjectReference
{Handle alcove activation/deactivation effects}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;--=== Constants ===--
Int Property ALCOVE_LIGHTS_OFF	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_BUSY		= 1 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_ON	 	= 2 AutoReadOnly Hidden

;--=== Properties ===--

Int Property AlcoveLightState Hidden
	Int Function Get()
		Return _iAlcoveLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState,True)
	EndFunction
EndProperty

Int Property DesiredLightState Hidden
	Int Function Get()
		Return _iDesiredLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState)
	EndFunction
EndProperty

Bool 			Property TorchShadows = False	Auto

ObjectReference Property AlcoveLightTorchSPar	Auto 
{Torch shadowlight parent}
ObjectReference Property AlcoveLightTorchLS		Auto
{L torch shadowlight}
ObjectReference Property AlcoveLightTorchRS		Auto
{R torch shadowlight}
ObjectReference Property AlcoveLightTorchAmb	Auto
{Torch ambience (no shadow)}

ObjectReference Property AlcoveLightShrineAmb	Auto
{Shrine ambient light (blue)}

;--=== Variables ===--

String _sFormID

Int _iAlcoveLightState = 0
Int _iDesiredLightState = 0

;--=== Events and Functions ===--

Function CheckVars()

EndFunction

Event OnInit()
	DebugTrace("OnInit!")
	CheckVars()
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
	CheckVars()
	Wait(10)
	SetLightState(ALCOVE_LIGHTS_ON)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_OFF)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_ON)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_OFF)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_ON)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_OFF)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_ON)
	Wait(5)
	SetLightState(ALCOVE_LIGHTS_OFF)
EndEvent

Function SetLightState(Int aiDesiredLightState, Bool abForce = False)
{Set lights to desired state. abForce skips the transition.}
	DebugTrace("SetLightState(" + aiDesiredLightState + "," + abForce + ")")
	_iDesiredLightState = aiDesiredLightState
	If !Is3DLoaded()
		abForce = True ; Always skip transition if we're not loaded
	EndIf
	If abForce
		DebugTrace("FORCING Lightstate to " + _iDesiredLightState + "!")
		If _iDesiredLightState == ALCOVE_LIGHTS_OFF
			AlcoveLightTorchSPar.DisableNoWait()
			AlcoveLightTorchAmb.DisableNoWait()
			AlcoveLightTorchAmb.SetPosition(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,1000)
		Else
			AlcoveLightTorchAmb.SetPosition(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-638)
			AlcoveLightTorchAmb.EnableNoWait()
		EndIf
		If _iDesiredLightState == ALCOVE_LIGHTS_ON
			AlcoveLightTorchSPar.EnableNoWait()
		EndIf
		_iAlcoveLightState = _iDesiredLightState
		Return ; No need to continue, everything is set.
	EndIf
	
	If _iDesiredLightState == _iAlcoveLightState
		Return ; Nothing to do
	EndIf
	
	RegisterForSingleUpdate(0.1)
			
EndFunction

Event OnUpdate()
	DebugTrace("OnUpdate - _iDesiredLightState:" + _iDesiredLightState + " _iAlcoveLightState" + _iAlcoveLightState + "!")
	If _iDesiredLightState == _iAlcoveLightState
		Return ; Nothing to do
	EndIf
	If _iDesiredLightState == ALCOVE_LIGHTS_OFF
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		DebugTrace("Want lights OFF! Diff: " + Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 250))
		If Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 250) > 10
			AlcoveLightTorchAmb.TranslateTo(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-250,0,0,0,500)
			RegisterForSingleUpdate(0.5)
		Else
			AlcoveLightTorchAmb.StopTranslation()
			AlcoveLightTorchAmb.DisableNoWait()
			_iAlcoveLightState = ALCOVE_LIGHTS_OFF
			DebugTrace("Lights are now OFF!")
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		If !AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.EnableNoWait()
		EndIf
		If !AlcoveLightTorchAmb.IsEnabled()
			AlcoveLightTorchAmb.EnableNoWait()
			WaitFor3DLoad(AlcoveLightTorchAmb)
		EndIf
		DebugTrace("Want lights ON! Diff: " + Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 638))
		If Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 638) > 10
			AlcoveLightTorchAmb.TranslateTo(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-638,0,0,0,500)
			RegisterForSingleUpdate(0.5)
		Else
			_iAlcoveLightState = ALCOVE_LIGHTS_ON
			DebugTrace("Lights are now ON!")
		EndIf
	EndIf
EndEvent

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	Debug.Trace("MYC/AlcoveLightingController/" + _sFormID + ": " + sDebugString,iSeverity)
	FFUtils.TraceConsole(sDebugString)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction
