Scriptname vMYC_AlcoveBook extends ObjectReference
{Handle book animation and communicate with AlcoveController.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

;=== Properties ===--

Activator						Property	vMYC_AlcoveControllerActivator				Auto
vMYC_AlcoveController			Property	AlcoveController							Auto Hidden
	
Actor							Property	PlayerREF									Auto
	
EffectShader					Property	GlowFXS										Auto

Explosion						Property	vMYC_BookDustExplosion						Auto

Form							Property	vMYC_BookGlow								Auto ;MovableStatic

Message							Property 	vMYC_ShrineBookSelfNewSaveMenu				Auto
Message							Property 	vMYC_ShrineBookSelfUpdateSaveMenu			Auto
Message							Property 	vMYC_ShrineBookSelfUpdateSaveConfirmMenu	Auto
Message							Property 	vMYC_ShrineBookSelfEraseConfirmMenu			Auto
Message							Property 	vMYC_ShrineBookSelfWrongShrineMenu			Auto
Message							Property 	vMYC_ShrineBookAltTakeItMenu				Auto
Message							Property 	vMYC_ShrineBookAltReturnItMenu				Auto
Message							Property	vMYC_ShrineBookAltReturnItConfirmMenu		Auto

Sound 							Property	vMYC_BookSlamSM 							Auto
Sound 							Property 	vMYC_BookWhooshSM							Auto

Static 							Property	HighPolySkyrimBook							Auto

Bool Property FlipPages Hidden
{Start or stop flipping pages.}
	Bool Function Get()
		Return _bFlipPages
	EndFunction
	Function Set(Bool bFlipPages)
		_bFlipPages = bFlipPages
		RegisterForSingleUpdate(0.1)
	EndFunction
EndProperty

Bool Property IsGlowing Hidden
{Glow or unglow book.}
	Bool Function Get()
		Return _bIsGlowing
	EndFunction
	Function Set(Bool bIsGlowing)
		_bWantGlowing = bIsGlowing
		If _bWantGlowing && !_bIsGlowing && _kBookStatic.Is3DLoaded()
			GlowFXS.Play(_kBookStatic,-1)
			_bIsGlowing = _bWantGlowing
		ElseIf !_bWantGlowing && _bIsGlowing && _kBookStatic.Is3DLoaded()
			GlowFXS.Stop(_kBookStatic)
			_bIsGlowing = _bWantGlowing
		EndIf
	EndFunction
EndProperty

Bool Property IsOpen Hidden
{Open or close book, with appropriate animations.}
	Bool Function Get()
		Return _bIsOpen
	EndFunction
	Function Set(Bool bIsOpen)
		_bWantOpen = bIsOpen
		If _bWantOpen && !_bIsOpen && _kBookStatic.Is3DLoaded()
			OpenBook()
			_bIsOpen = _bWantOpen
		ElseIf !_bWantOpen && _bIsOpen && _kBookStatic.Is3DLoaded()
			CloseBook()
			_bIsOpen = _bWantOpen
		EndIf
	EndFunction
EndProperty

;=== Variables ===--

Bool	_bIsOpen
Bool	_bWantOpen
Bool	_bIsGlowing
Bool	_bWantGlowing
Bool	_bFlipPages

String _sFormID

ObjectReference	_kBookShine
ObjectReference	_kBookStatic

;=== Events and Functions ===--

Function CheckVars()
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
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

Event OnCellAttach()
	DebugTrace("OnCellAttach!")
EndEvent
	
Event OnActivate(ObjectReference akTriggerRef)
	GoToState("Busy")
	IsOpen = !IsOpen
	GoToState("")
EndEvent

State Busy
	Event OnActivate(ObjectReference akTriggerRef)
	EndEvent
EndState
	
Function CheckObjects()
	If !AlcoveController
		FindObjects()
	EndIf
	If !_kBookStatic
		_kBookStatic = PlaceAtMe(HighPolySkyrimBook,abInitiallyDisabled = True)
		_kBookStatic.EnableNoWait(False)
	EndIf
	If !_kBookShine
		_kBookShine = PlaceAtMe(vMYC_BookGlow,abInitiallyDisabled = True)
		_kBookShine.SetAngle(-15.0000,0,GetAngleZ())
		_kBookShine.SetScale(0.2300)
	EndIf
EndFunction

Function FindObjects()
	AlcoveController = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveControllerActivator,Self,1500) as vMYC_AlcoveController
	
	DebugTrace("AlcoveController is " + AlcoveController + "!")
EndFunction

Function OpenBook()
	Debug.SendAnimationEvent(_kBookStatic,"Open")
	Wait(0.25)
	_kBookStatic.PlaceAtMe(vMYC_BookDustExplosion)
	Wait(0.25)
	vMYC_BookWhooshSM.Play(_kBookStatic)
	_kBookShine.EnableNoWait(True)
EndFunction

Function CloseBook()
	_kBookShine.DisableNoWait(True)
	Wait(0.25)
	Debug.SendAnimationEvent(_kBookStatic,"Close")
	Wait(0.25)
	_kBookStatic.PlaceAtMe(vMYC_BookDustExplosion)
	Wait(0.5)
	vMYC_BookSlamSM.Play(_kBookStatic)
	Wait(0.25)
	ShakeCamera(Self,0.1,0.25)
EndFunction
	
;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/AlcoveBook/" + _sFormID + ": " + sDebugString,iSeverity)
	;FFUtils.TraceConsole(sDebugString)
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
