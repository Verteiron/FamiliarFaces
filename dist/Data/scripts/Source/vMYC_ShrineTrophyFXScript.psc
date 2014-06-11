Scriptname vMYC_ShrineTrophyFXScript extends ObjectReference  
{Enables and adds a glow to all linked references}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int				Property	ShrineIndex		Auto Hidden

Activator	 	Property 	TrophyFXActi	Auto
EffectShader 	Property 	TrophyShader 	Auto
VisualEffect 	Property 	TrophyVFX		Auto


Float 			Property	StartDelay =  3.0	Auto
Float 			Property	ShaderTime =  5.0	Auto
Float 			Property	VFXTime    = 10.0	Auto
Float 			Property	FXActiTime =  5.0	Auto

;--=== Variables ===--

Bool	_bCellAttached
Bool	_bIsLight
String 	_sCharacterName
Int		_iShrineIndex
ObjectReference _kFXActi

Cell	_kMycell

;--=== Events ===--

Event OnInit()
	_kMycell = GetParentCell()
EndEvent

Event OnLoad()
	;Debug.Trace("MYC: " + Self + " OnLoad!")
	RegisterForModEvent("vMYC_ShrineLightingPriority","OnShrineLightingPriority")
	Wait(StartDelay)
	ShowTrophies()
EndEvent

Event OnShrineLightingPriority(string eventName, string strArg, float numArg, Form sender)
	;strArg = numArg = ShrineIndex of sender
	Int iRequestingIndex = numArg as Int
	If iRequestingIndex != ShrineIndex
		HideTrophies()
		Wait(5)
		ShowTrophies(False)
	EndIf
EndEvent

Event OnActivate(ObjectReference akTriggerRef)
	
EndEvent

Event OnCellAttach()
	_bCellAttached = True
EndEvent

Event OnCellDetach()
	_bCellAttached = False
EndEvent

Event OnAttachedToCell()
EndEvent

Event OnUpdate()
	If _kFXActi.Is3DLoaded()
		_kFXActi.Disable(True)
		Wait(1)
	EndIf
	_kFXActi.Delete()
EndEvent

Event OnUnload()
	;Debug.Trace("MYC: " + Self + " OnUnload!")
	; Only hide trophies if unloaded while cell is attached. 
	; Otherwise the trophy animation will play every time the player enters the shrine. 
	; Any unload we get while the cell is attached has to be the player resetting the shrine.
	If _bCellAttached 
		HideTrophies()
	EndIf
EndEvent

Function HideTrophies()
	ObjectReference kLinkedObject
	kLinkedObject = GetLinkedRef()
	Int iSafety = 10
	While kLinkedObject && iSafety > 0
		iSafety -= 1
		;Debug.Trace("MYC: " + Self + " ShrineTrophyFX: kLinkedObject is " + kLinkedObject)
		kLinkedObject.DisableNoWait(True)
		kLinkedObject = kLinkedObject.GetLinkedRef()
	EndWhile
EndFunction

Function ShowTrophies(Bool abPlayFX = True)
	ObjectReference kLinkedObject
	kLinkedObject = GetLinkedRef()
	Int iSafety = 10
	While kLinkedObject && iSafety > 0
		;Debug.Trace("MYC: " + Self + " ShrineTrophyFX: kLinkedObject is " + kLinkedObject)
		_bIsLight = False
		If kLinkedObject.GetType() == 31 ; Light
			_bIsLight = True
		EndIf
		If TrophyFXActi && abPlayFX
			_kFXActi = kLinkedObject.PlaceAtMe(TrophyFXActi)
			RegisterForSingleUpdate(FXActiTime)
		EndIf
		kLinkedObject.EnableNoWait(True)
		Int iLoadSafety = 100
		While !kLinkedObject.Is3DLoaded() && iLoadSafety > 0
			iLoadSafety -= 1
			Wait(0.1)
		EndWhile
		kLinkedObject.SetMotionType(MOTION_KEYFRAMED)
		;Debug.Trace("MYC: " + Self + " ShrineTrophyFX: kLinkedObject took " + ((100.0 - iLoadSafety) / 10.0) + "s to load!")
		iSafety -= 1
		If TrophyVFX && abPlayFX
			TrophyVFX.Play(kLinkedObject,VFXTime)
		EndIf
		If TrophyShader && abPlayFX
			TrophyShader.Play(kLinkedObject,ShaderTime)
		EndIf
		kLinkedObject = kLinkedObject.GetLinkedRef()
	EndWhile
	If iSafety == 0
		;Debug.Trace("MYC: " + Self + " ShrineTrophyFX: Reached safety limit!",1)
	EndIf
	;Debug.Trace("MYC: " + Self + " Done!")
EndFunction
