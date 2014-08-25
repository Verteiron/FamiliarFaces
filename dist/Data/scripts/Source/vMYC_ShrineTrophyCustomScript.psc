Scriptname vMYC_ShrineTrophyCustomScript extends ObjectReference  
{Place objects at self apply effects to them.}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int				Property	AlcoveIndex		Auto Hidden

Static[] 	 	Property 	TrophyStatics		Auto
Activator[] 	Property 	TrophyActivators 	Auto
VisualEffect[] 	Property 	TrophyVFXs			Auto
EffectShader[] 	Property 	TrophyFXSs			Auto

Float 			Property	StartDelay =  3.0	Auto
Float 			Property	ShaderTime =  5.0	Auto
Float 			Property	VFXTime    = 10.0	Auto
Float 			Property	FXActiTime =  5.0	Auto

;--=== Variables ===--

Bool	_bCellAttached
Bool	_bIsLight
String 	_sCharacterName
Int		_iAlcoveIndex
ObjectReference _kFXActi

ObjectReference[]	_kTrophyObjects

Cell	_kMycell

Int 	_iNumObjects

;--=== Events ===--

Event OnInit()
	_kMycell = GetParentCell()
	_kTrophyObjects = New ObjectReference[16]
EndEvent

Auto State Unloaded
	Event OnLoad()
		;Debug.Trace("MYC: " + Self + " OnLoad!")
		GoToState("Loaded")
		RegisterForModEvent("vMYC_AlcoveLightingPriority","OnAlcoveLightingPriority")
		Wait(StartDelay)
		ShowTrophies()
	EndEvent
EndState

State Loaded
	Event OnLoad()
		RegisterForModEvent("vMYC_AlcoveLightingPriority","OnAlcoveLightingPriority")
		UpdatePosition()
	EndEvent
EndState

Event OnAlcoveLightingPriority(string eventName, string strArg, float numArg, Form sender)
	;strArg = numArg = AlcoveIndex of sender
	Int iRequestingIndex = numArg as Int
	If iRequestingIndex != AlcoveIndex && strArg == "Request"
		HideTrophies()
	ElseIf iRequestingIndex != AlcoveIndex && strArg == "Release"
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
	; Otherwise the trophy animation will play every time the player enters the Shrine.
	; Any unload we get while the cell is attached has to be the player resetting the Alcove.
	If _bCellAttached
		HideTrophies()
	EndIf
	UnRegisterForModEvent("vMYC_AlcoveLightingPriority")
EndEvent

Function UpdatePosition()
	If !Is3DLoaded()
		Return
	EndIf
	Int i = _kTrophyObjects.Length
	While i > 0
		i -= 1
		If _kTrophyObjects[i]
			If _kTrophyObjects[i].GetDistance(Self) || _kTrophyObjects[i].GetHeadingAngle(Self)
				_kTrophyObjects[i].MoveTo(Self)
			EndIf
		EndIf
	EndWhile
EndFunction

Function HideTrophies()
	Int i = _kTrophyObjects.Length
	While i > 0
		i -= 1
		If _kTrophyObjects[i]
			_kTrophyObjects[i].DisableNoWait(True)
		EndIf
	EndWhile
EndFunction

Function ShowTrophies(Bool abPlayFX = True)
	_iNumObjects = TrophyStatics.Length
	Int i = 0
	Int iSafety = 20
	While i < _iNumObjects
		;Debug.Trace("MYC: " + Self + " AlcoveTrophyFX: kLinkedObject is " + kLinkedObject)
		If TrophyStatics[i]
			_kTrophyObjects[i] = PlaceAtMe(TrophyStatics[i])
		ElseIf TrophyActivators[i]
			_kTrophyObjects[i] = PlaceAtMe(TrophyActivators[i])
		EndIf
		If TrophyFXSs[i]
			Int iLoadSafety = 100
			While !_kTrophyObjects[i].Is3DLoaded() && iLoadSafety > 0
				iLoadSafety -= 1
				Wait(0.1)
			EndWhile
			TrophyFXSs[i].Play(_kTrophyObjects[i])
		EndIf
		i += 1
	EndWhile
	;Debug.Trace("MYC: " + Self + " Done!")
EndFunction
