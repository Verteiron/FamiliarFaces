Scriptname vFFP_AlcoveLightingController extends ObjectReference
{Handle alcove activation/deactivation effects.}

; === [ vFFP_AlcoveLightingController.psc ] ===============================---
; Rearrange and enable/disable Alcove lights and fog. One per Alcove.
; Handles:
;   Alcove lighting and fog.
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_Session

;=== Constants ===--
Int Property ALCOVE_LIGHTS_OFF	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_BUSY		= 1 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_ON	 	= 2 AutoReadOnly Hidden

;=== Properties ===--

Bool Property TorchShadows = False	Auto

Bool Property FogEnabled	= False			Auto

Int Property AlcoveLightState Hidden
{Set this to immediately force the Alcove into the target lighting state.}
	Int Function Get()
		Return _iAlcoveLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState,True)
	EndFunction
EndProperty

Int Property DesiredLightState Hidden
{Set this to start transitioning the Alcove into the target lighting state.}
	Int Function Get()
		Return _iDesiredLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState)
	EndFunction
EndProperty

;=== Keywords ===--

Keyword Property vFFP_AlcoveAmbientBlue		Auto
Keyword Property vFFP_AlcoveAmbientTorch	Auto
Keyword Property vFFP_AlcoveFogFill			Auto
Keyword Property vFFP_AlcoveFogLow			Auto
Keyword Property vFFP_AlcoveFogWall			Auto
Keyword Property vFFP_AlcoveFogLit			Auto
Keyword Property vFFP_AlcoveTorchesNS		Auto
Keyword Property vFFP_AlcoveTorchesS		Auto
Keyword Property vFFP_AlcoveTorchesTrig		Auto

;=== Base forms to find objects with ===--

;enableparents
Activator		Property vFFP_AlcoveTorchShadowEnableParent		Auto
Activator		Property vFFP_AlcoveTorchNShadowEnableParent	Auto

;lights
Light			Property vFFP_ShrineActiveLight					Auto
Light			Property vFFP_ShrineActiveTorchLightS			Auto
Light			Property vFFP_ShrineActiveTorchLightNS			Auto
Light			Property vFFP_ShrineAmbientLight				Auto

;Fogs
Activator		Property vFFP_EmptyShrineFog					Auto
;Declared as form since MovableStatic isn't allowed
Form			Property FXAmbBeamSlowFogBig_Dim03				Auto
Form			Property FXFogRollingFacing01					Auto
Form			Property FXAmbBlowingFog01						Auto

;Torch glow
Static			Property FXGlowFillRoundBrt						Auto

;=== Objects ===--

ObjectReference Property AlcoveLightTorchNSPar	Auto 
{Torch noshadowlight parent.}
ObjectReference Property AlcoveLightTorchSPar	Auto 
{Torch shadowlight parent.}
ObjectReference Property AlcoveLightTorchAmb	Auto
{Torch ambiance (no shadow).}
ObjectReference Property AlcoveLightShrineAmb	Auto
{Shrine ambient light (blue).}
ObjectReference Property AlcoveFogDense			Auto
{Dense fog for filling alcove.}
ObjectReference Property AlcoveFogFloor			Auto
{Floor mist.}
ObjectReference Property AlcoveFogCurtain		Auto
{Fog wall for blocking alcove.}
ObjectReference Property AlcoveFogLit			Auto
{Light rays shining from lit alcove.}
ObjectReference Property AlcoveTorchTriggerBox	Auto
{Triggerbox for torch shadows, will be filled by vFFP_ShrineTorchShadowTrigScript.psc.}

;=== Variables ===--

String _sFormID

Int _iAlcoveLightState = -1
Int _iDesiredLightState = -1

Bool _bForceLightState = False

;=== Events and Functions ===--

Function CheckVars()
	CheckObjects()
	If GetParentCell().IsAttached() && ( _iAlcoveLightState < 0 || _iDesiredLightState < 0 )
		SetLightState(ALCOVE_LIGHTS_OFF,True)
	EndIf
	If !ValidateLightState()
		_bForceLightState = True
		RegisterForSingleUpdate(1)
	EndIf
EndFunction

Event OnInit()
	DebugTrace("OnInit!")
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
EndEvent

Event OnCellAttach()
	DebugTrace("OnCellAttach!")
	CheckVars()
EndEvent

Function SetLightState(Int aiDesiredLightState, Bool abForce = False)
{Set lights to desired state. abForce skips the transition.}
	;CheckObjects()
	DebugTrace("SetLightState(" + aiDesiredLightState + "," + abForce + ")")
	DebugTrace("AlcoveTorchTriggerBox is " + AlcoveTorchTriggerBox)
	_iDesiredLightState = aiDesiredLightState
	_bForceLightState = abForce
	If !Is3DLoaded()
		abForce = True ; Always skip transition if we're not loaded
	EndIf
	If abForce
		DebugTrace("FORCING Lightstate to " + _iDesiredLightState + "!")
		_bForceLightState = True
		SetupLightsAndFog(abForce)
		Return ; No need to continue, everything is set.
	EndIf
	RegisterForSingleUpdate(0.1)
EndFunction

Function SetupLightsAndFog(Bool abForce = False)
{Function to handle the process of enabling/disabling lights and fog.}
	DebugTrace("SetupLightsAndFog - _iDesiredLightState:" + _iDesiredLightState + " _iAlcoveLightState" + _iAlcoveLightState + "!")
	If !AlcoveFogLit
		CheckObjects()
	EndIf
	If _iDesiredLightState == _iAlcoveLightState && !abForce
		Return ; Nothing to do
	EndIf
	If abForce
		_bForceLightState = False
		DebugTrace("SetupLightsAndFog will FORCE the lighting setup!")
	EndIf
	If _iDesiredLightState == ALCOVE_LIGHTS_OFF
		ShowFog(True)
		AlcoveTorchTriggerBox.DisableNoWait()
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		If AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.DisableNoWait()
		EndIf
		AlcoveLightTorchAmb.DisableNoWait(True)
		_iAlcoveLightState = ALCOVE_LIGHTS_OFF
		DebugTrace("Lights are now OFF!")
		If AlcoveFogLit.IsEnabled()
			AlcoveFogLit.DisableNoWait(True)
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_BUSY
		If !FogEnabled
			ShowFog(True)
		EndIf
		If !AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.EnableNoWait()
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		AlcoveTorchTriggerBox.DisableNoWait(False)
		If !AlcoveLightTorchAmb.IsEnabled()
			AlcoveLightTorchAmb.EnableNoWait(True)
		EndIf
		If AlcoveFogLit.IsEnabled()
			AlcoveFogLit.DisableNoWait(True)
		EndIf
		_iAlcoveLightState = ALCOVE_LIGHTS_BUSY
		DebugTrace("Lights are now BUSY!")
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		AlcoveLightTorchAmb.EnableNoWait(True)
		If !AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.EnableNoWait()
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		ShowFog(False)
		If !AlcoveFogLit.IsEnabled()
			AlcoveFogLit.EnableNoWait(True)
		EndIf
		AlcoveTorchTriggerBox.EnableNoWait(False)
		_iAlcoveLightState = ALCOVE_LIGHTS_ON
		DebugTrace("Lights are now ON!")
	EndIf
EndFunction

Bool Function ValidateLightState()
{Make sure the lights and fog actually match the lighting state.
 Returns: False if anything fails validation, otherwise True.}
	If AlcoveLightState == ALCOVE_LIGHTS_OFF
		If !AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchNSPar.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_BUSY
		If !AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			Return False
		EndIf
		If !AlcoveLightTorchNSPar.IsEnabled()
			Return False
		EndIf
		If !AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		If AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If !AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If !(AlcoveLightTorchNSPar.IsEnabled() || AlcoveLightTorchSPar.IsEnabled()) ; either shadow or no-shadow lights should be on
			Return False
		EndIf
		If !AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	EndIf
	Return True
EndFunction

Event OnUpdate()
	DebugTrace("OnUpdate - _iDesiredLightState:" + _iDesiredLightState + " _iAlcoveLightState" + _iAlcoveLightState + "!")
	SetupLightsAndFog(_bForceLightState)
EndEvent

Function ShowFog(Bool abShowFog = True)
{Turns fog on or off.}
	If abShowFog
		FogEnabled = True
		AlcoveFogCurtain.EnableNoWait(True)
		AlcoveFogDense.EnableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogFloor.EnableNoWait(True)
	Else
		FogEnabled = False
		AlcoveFogDense.DisableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogCurtain.DisableNoWait(True)
		AlcoveFogFloor.DisableNoWait(True)
	EndIf
EndFunction

Function CheckObjects()
	If !AlcoveLightTorchNSPar || !AlcoveFogCurtain
		FindObjects()
	EndIf
EndFunction

Function FindObjects()
{Sets up and assigns all the required objects.}
	;AlcoveLightTorchNSPar = FindClosestReferenceOfTypeFromRef(vFFP_AlcoveTorchNShadowEnableParent,Self,800)
	;AlcoveLightTorchSPar = FindClosestReferenceOfTypeFromRef(vFFP_AlcoveTorchShadowEnableParent,Self,800)
	;AlcoveLightTorchAmb =  FindClosestReferenceOfTypeFromRef(vFFP_ShrineActiveLight,Self,800)
	;AlcoveLightShrineAmb =  FindClosestReferenceOfTypeFromRef(vFFP_ShrineAmbientLight,Self,800)
	;AlcoveFogDense =  FindClosestReferenceOfTypeFromRef(vFFP_EmptyShrineFog,Self,800)
	;
	;FXAmbBlowingFog01 = GetFormFromFile(0x00035267,"Skyrim.esm")
	;FXFogRollingFacing01 = GetFormFromFile(0x00034DB6,"Skyrim.esm")
	;FXAmbBeamSlowFogBig_Dim03 = GetFormFromFile(0x000A6C4D,"Skyrim.esm")
	;
	;AlcoveFogFloor =  FindClosestReferenceOfTypeFromRef(FXAmbBlowingFog01,Self,800)
	;AlcoveFogCurtain =  FindClosestReferenceOfTypeFromRef(FXFogRollingFacing01,Self,800)
	;AlcoveFogLit =  FindClosestReferenceOfTypeFromRef(FXAmbBeamSlowFogBig_Dim03,Self,800)
	;
	;While !AlcoveTorchTriggerBox
	;	DebugTrace("Waiting for AlcoveTorchTriggerBox...")
	;	Wait(1)
	;EndWhile

;Keyword Property vFFP_AlcoveAmbientBlue		Auto
;Keyword Property vFFP_AlcoveAmbientTorch	Auto
;Keyword Property vFFP_AlcoveFogFill			Auto
;Keyword Property vFFP_AlcoveFogLow			Auto
;Keyword Property vFFP_AlcoveFogWall			Auto
;Keyword Property vFFP_AlcoveFogLit			Auto
;Keyword Property vFFP_AlcoveTorchesNS		Auto
;Keyword Property vFFP_AlcoveTorchesS		Auto
;Keyword Property vFFP_AlcoveTorchesTrig		Auto

	GetLinkedRef(vFFP_AlcoveAmbientBlue)

	
	AlcoveLightTorchNSPar 	= GetLinkedRef(vFFP_AlcoveTorchesNS)
	AlcoveLightTorchSPar 	= GetLinkedRef(vFFP_AlcoveTorchesS)
	AlcoveLightTorchAmb 	= GetLinkedRef(vFFP_AlcoveAmbientTorch)
	AlcoveLightShrineAmb 	= GetLinkedRef(vFFP_AlcoveAmbientBlue)
	AlcoveFogDense 			= GetLinkedRef(vFFP_AlcoveFogFill)
	AlcoveFogFloor 			= GetLinkedRef(vFFP_AlcoveFogLow)
	AlcoveFogCurtain 		= GetLinkedRef(vFFP_AlcoveFogWall)
	AlcoveFogLit 			= GetLinkedRef(vFFP_AlcoveFogLit)
	AlcoveTorchTriggerBox	= GetLinkedRef(vFFP_AlcoveTorchesTrig)
	
	DebugTrace("AlcoveFogCurtain is " + AlcoveFogCurtain + ", AlcoveLightTorchSPar is " + AlcoveLightTorchSPar + ", AlcoveTorchTriggerBox is " + AlcoveTorchTriggerBox)
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	Debug.Trace("vFF/AlcoveLightingController/" + _sFormID + ": " + sDebugString,iSeverity)
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
