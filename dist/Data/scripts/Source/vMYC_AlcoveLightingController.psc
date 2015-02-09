Scriptname vMYC_AlcoveLightingController extends ObjectReference
{Handle alcove activation/deactivation effects}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--
Int Property ALCOVE_LIGHTS_OFF	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_BUSY		= 1 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_ON	 	= 2 AutoReadOnly Hidden

;=== Properties ===--

Bool Property TorchShadows = False	Auto

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

;=== Base forms to find objects with ===--

;enableparents
Activator		Property vMYC_AlcoveTorchShadowEnableParent		Auto
Activator		Property vMYC_AlcoveTorchNShadowEnableParent	Auto

;lights
Light			Property vMYC_ShrineActiveLight					Auto
Light			Property vMYC_ShrineActiveTorchLightS			Auto
Light			Property vMYC_ShrineActiveTorchLightNS			Auto
Light			Property vMYC_ShrineAmbientLight				Auto

;Fogs
Activator		Property vMYC_EmptyShrineFog					Auto
;Declared as form since MovableStatic isn't allowed
Form			Property FXAmbBeamSlowFogBig_Dim03				Auto
Form			Property FXFogRollingFacing01					Auto
Form			Property FXAmbBlowingFog01						Auto

;Torch glow
Static			Property FXGlowFillRoundBrt						Auto

;=== Objects ===--

ObjectReference Property AlcoveLightTorchNSPar	Auto 
{Torch noshadowlight parent}
ObjectReference Property AlcoveLightTorchSPar	Auto 
{Torch shadowlight parent}
ObjectReference Property AlcoveLightTorchAmb	Auto
{Torch ambiance (no shadow)}
ObjectReference Property AlcoveLightShrineAmb	Auto
{Shrine ambient light (blue)}
ObjectReference Property AlcoveFogDense			Auto
{Dense fog for filling alcove}
ObjectReference Property AlcoveFogFloor			Auto
{Floor mist}
ObjectReference Property AlcoveFogCurtain		Auto
{Fog wall for blocking alcove}
ObjectReference Property AlcoveFogLit			Auto
{Light rays shining from lit alcove}
ObjectReference Property AlcoveTorchTriggerBox	Auto
{Triggerbox for torch shadows, will be filled by vMYC_ShrineTorchShadowTrigScript.psc}

;=== Variables ===--

String _sFormID

Int _iAlcoveLightState = 0
Int _iDesiredLightState = 0

;=== Events and Functions ===--

Function CheckVars()
	CheckObjects()
EndFunction

Event OnInit()
	DebugTrace("OnInit!")
	CheckVars()
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
	CheckVars()
EndEvent

Function SetLightState(Int aiDesiredLightState, Bool abForce = False)
{Set lights to desired state. abForce skips the transition.}
	;CheckObjects()
	DebugTrace("SetLightState(" + aiDesiredLightState + "," + abForce + ")")
	DebugTrace("AlcoveTorchTriggerBox is " + AlcoveTorchTriggerBox)
	_iDesiredLightState = aiDesiredLightState
	If !Is3DLoaded()
		abForce = True ; Always skip transition if we're not loaded
	EndIf
	If abForce
		DebugTrace("FORCING Lightstate to " + _iDesiredLightState + "!")
		If _iDesiredLightState == ALCOVE_LIGHTS_OFF
			AlcoveTorchTriggerBox.Disable(False)
			AlcoveLightTorchNSPar.DisableNoWait()
			AlcoveLightTorchSPar.DisableNoWait()
			AlcoveLightTorchAmb.DisableNoWait()
			;AlcoveLightTorchAmb.SetPosition(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,1000)
			ShowFog(True)
		Else
			AlcoveTorchTriggerBox.EnableNoWait(False)
			AlcoveLightTorchNSPar.EnableNoWait()
			;AlcoveLightTorchAmb.SetPosition(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-448)
			AlcoveLightTorchAmb.EnableNoWait()
			ShowFog(True)
		EndIf
		If _iDesiredLightState == ALCOVE_LIGHTS_ON
			AlcoveLightTorchNSPar.EnableNoWait()
			ShowFog(False)
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
		ShowFog(True)
		AlcoveFogCurtain.EnableNoWait(True)
		AlcoveTorchTriggerBox.DisableNoWait()
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		If AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.DisableNoWait()
		EndIf
		AlcoveLightTorchAmb.DisableNoWait(True)
		;DebugTrace("Want lights OFF! Diff: " + Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 250))
		;If Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 250) > 10 && AlcoveLightTorchAmb.IsEnabled()
			;AlcoveLightTorchAmb.TranslateTo(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-250,0,0,0,500)
			;RegisterForSingleUpdate(0.5)
		;Else
			;AlcoveLightTorchAmb.StopTranslation()
			;AlcoveLightTorchAmb.DisableNoWait()
			_iAlcoveLightState = ALCOVE_LIGHTS_OFF
			DebugTrace("Lights are now OFF!")
		;EndIf
		If AlcoveFogLit.IsEnabled()
			AlcoveFogLit.DisableNoWait(True)
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		AlcoveTorchTriggerBox.EnableNoWait(False)
		If !AlcoveLightTorchAmb.IsEnabled()
			AlcoveLightTorchAmb.EnableNoWait()
			WaitFor3DLoad(AlcoveLightTorchAmb)
		EndIf
		AlcoveLightTorchAmb.EnableNoWait(True)
		;DebugTrace("Want lights ON! Diff: " + Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 448))
		;If Math.Abs(AlcoveLightTorchAmb.GetPositionZ() + 448) > 10
		;	AlcoveLightTorchAmb.TranslateTo(AlcoveLightTorchAmb.X,AlcoveLightTorchAmb.Y,-448,0,0,0,500)
		;	RegisterForSingleUpdate(0.5)
		;Else
			If !AlcoveLightTorchNSPar.IsEnabled() && !AlcoveLightTorchSPar.IsEnabled() 
				AlcoveLightTorchNSPar.EnableNoWait()
			EndIf
			AlcoveFogCurtain.DisableNoWait(True)
			ShowFog(False)
			_iAlcoveLightState = ALCOVE_LIGHTS_ON
			DebugTrace("Lights are now ON!")
		;EndIf
		If !AlcoveFogLit.IsEnabled()
			AlcoveFogLit.EnableNoWait(True)
		EndIf
	EndIf
EndEvent

Function ShowFog(Bool abShowFog = True)
	If abShowFog
		AlcoveFogDense.EnableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogFloor.EnableNoWait(True)
	Else
		AlcoveFogDense.DisableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogFloor.DisableNoWait(True)
	EndIf
EndFunction

Function CheckObjects()
	If !AlcoveLightTorchNSPar || !AlcoveFogCurtain
		FindObjects()
	EndIf
EndFunction

Function FindObjects()
	AlcoveLightTorchNSPar = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveTorchNShadowEnableParent,Self,800)
	AlcoveLightTorchSPar = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveTorchShadowEnableParent,Self,800)
	AlcoveLightTorchAmb =  FindClosestReferenceOfTypeFromRef(vMYC_ShrineActiveLight,Self,800)
	AlcoveLightShrineAmb =  FindClosestReferenceOfTypeFromRef(vMYC_ShrineAmbientLight,Self,800)
	AlcoveFogDense =  FindClosestReferenceOfTypeFromRef(vMYC_EmptyShrineFog,Self,800)
	
	FXAmbBlowingFog01 = GetFormFromFile(0x00035267,"Skyrim.esm")
	FXFogRollingFacing01 = GetFormFromFile(0x00034DB6,"Skyrim.esm")
	FXAmbBeamSlowFogBig_Dim03 = GetFormFromFile(0x000A6C4D,"Skyrim.esm")
	
	AlcoveFogFloor =  FindClosestReferenceOfTypeFromRef(FXAmbBlowingFog01,Self,800)
	AlcoveFogCurtain =  FindClosestReferenceOfTypeFromRef(FXFogRollingFacing01,Self,800)
	AlcoveFogLit =  FindClosestReferenceOfTypeFromRef(FXAmbBeamSlowFogBig_Dim03,Self,800)
	
	DebugTrace("AlcoveFogCurtain is " + AlcoveFogCurtain + ", AlcoveLightTorchSPar is " + AlcoveLightTorchSPar)
EndFunction

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
