Scriptname vMYC_CharacterBookActiScript extends ObjectReference  
{Linked to Shrine activator, handle player interaction}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

vMYC_CharacterManagerScript 	Property CharacterManager 	Auto
vMYC_ShrineOfHeroesQuestScript 	Property ShrineOfHeroes 	Auto
vMYC_ShrineAlcoveController		Property AlcoveController	Auto Hidden

Actor 			Property 	PlayerREF					Auto

EffectShader	Property	GlowFXS						Auto

Explosion		Property	vMYC_BookDustExplosion		Auto

Keyword			Property	vMYC_ShrineLight			Auto

Message			Property 	vMYC_ShrineBookSelfNewSaveMenu				Auto
Message			Property 	vMYC_ShrineBookSelfUpdateSaveMenu			Auto
Message			Property 	vMYC_ShrineBookSelfUpdateSaveConfirmMenu	Auto
Message			Property 	vMYC_ShrineBookSelfEraseConfirmMenu			Auto
Message			Property 	vMYC_ShrineBookSelfWrongShrineMenu			Auto
Message			Property 	vMYC_ShrineBookAltTakeItMenu				Auto
Message			Property 	vMYC_ShrineBookAltReturnItMenu				Auto
Message			Property	vMYC_ShrineBookAltReturnItConfirmMenu		Auto

Sound 			Property	vMYC_BookSlamSM 	Auto
Sound 			Property 	vMYC_BookWhooshSM	Auto

Static 			Property	HighPolySkyrimBook			Auto

Int	Property AlcoveIndex Hidden
{Which Alcove do I belong to?}
	Int Function Get()
		Return _iAlcoveIndex
	EndFunction
	Function Set(Int iAlcoveIndex)
		_iAlcoveIndex = iAlcoveIndex
	EndFunction
EndProperty

Bool Property FlipPages Hidden
{Start or stop flipping pages}
	Bool Function Get()
		Return _bFlipPages
	EndFunction
	Function Set(Bool bFlipPages)
		_bFlipPages = bFlipPages
		RegisterForSingleUpdate(0.1)
	EndFunction
EndProperty

Bool Property IsGlowing Hidden
{Glow or unglow book}
	Bool Function Get()
		Return _bIsGlowing
	EndFunction
	Function Set(Bool bIsGlowing)
		If bIsGlowing && !_bIsGlowing
			GlowFXS.Play(_BookStatic,-1)
		ElseIf !bIsGlowing && _bIsGlowing
			GlowFXS.Stop(_BookStatic)
		EndIf
		_bIsGlowing = bIsGlowing
	EndFunction
EndProperty

Bool Property IsOpen Hidden
{Open or close book, with appropriate animations}
	Bool Function Get()
		Return _bIsOpen
	EndFunction
	Function Set(Bool bIsOpen)
		If bIsOpen && !_bIsOpen
			OpenBook()
		ElseIf !bIsOpen && _bIsOpen
			CloseBook()
		EndIf
		_bIsOpen = bIsOpen
	EndFunction
EndProperty

;--=== Variables ===--

Bool	_bIsOpen
Bool	_bIsGlowing
Bool	_bFlipPages

String 	_sCharacterName
Int		_iAlcoveIndex

ObjectReference		_BookShine
ObjectReference		_BookStatic

;--=== Events ===--

Event OnInit()
EndEvent

Event OnLoad()
	;Debug.Trace("MYC: " + Self + " OnLoad!")
	If !AlcoveController
		AlcoveController = GetLinkedRef() as vMYC_ShrineAlcoveController
	EndIf
	BlockActivation(True)
	If !_BookStatic
		_BookStatic = PlaceAtMe(HighPolySkyrimBook,abInitiallyDisabled = True)
		_BookStatic.EnableNoWait(False)
		SetScale(0.5)
	EndIf
	If !_BookShine
		_BookShine = GetLinkedRef(vMYC_ShrineLight)
	EndIf
EndEvent

Event OnActivate(ObjectReference akTriggerRef)
	If !AlcoveController
		AlcoveController = GetLinkedRef() as vMYC_ShrineAlcoveController
	EndIf
	_iAlcoveIndex = AlcoveController.AlcoveIndex
	_sCharacterName = AlcoveController.CharacterName
	If _sCharacterName
		ShrineOfHeroes.ShrineOwner.ForceRefTo(CharacterManager.GetCharacterActorByName(_sCharacterName))
	EndIf
	If !_sCharacterName
		Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Activated but has no character living in shrine. Were we activated by the player?")
		If akTriggerRef == PlayerREF
			Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": ... yeap, it was the player. Okay, so does the player already have his character saved somewhere?")
			If ShrineOfHeroes.GetAlcoveIndex(PlayerREF.GetActorBase().GetName()) == -1
				Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Apparently not! Soooo... we'll save the current player to this shrine!")
				Int iResult = vMYC_ShrineBookSelfNewSaveMenu.Show()
				If iResult == 0
					AlcoveController.SavePlayer()
				EndIf
				Return
			Else
				Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Yeap, so we'll tell them to bug off!")
				vMYC_ShrineBookSelfWrongShrineMenu.Show()
				Return
			EndIf
		Else
			Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Nope. This is probably the init activation, but we have no-one home. Oh well. Aborting!")
		EndIf
		Return
	ElseIf _sCharacterName && akTriggerRef == PlayerREF
		Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Activated by the Player and we have a character living here! Is this the Player's shrine?")
		If _sCharacterName == PlayerREF.GetActorBase().GetName()
			Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Yeap! So we'll ask the player if they want to update their shrine.")
			;FIXME: Update shrine info
			Int iResult = vMYC_ShrineBookSelfUpdateSaveMenu.Show()
			If iResult == 0 ; Update it!
				If vMYC_ShrineBookSelfUpdateSaveConfirmMenu.Show() == 0
					AlcoveController.UpdateAlcove()
				EndIf
			ElseIf iResult == 1 ;Leave it alone
				;Do nothing
			ElseIf iResult == 2 ;erase it!
				If vMYC_ShrineBookSelfEraseConfirmMenu.Show() == 0
					AlcoveController.EraseAlcove()
				EndIf
			EndIf
		Else
			Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Nope. So we'll tell them about THIS shrine's character!")
			If !IsOpen
				Int iResult = vMYC_ShrineBookAltTakeItMenu.Show()
				If iResult == 0 ; Open the book
					AlcoveController.SummonCharacter()
				Else ; leave it
					;Do nothing 
				EndIf
			Else ;Book is already open
				Int iResult = vMYC_ShrineBookAltReturnItMenu.Show()
				If iResult == 1 ; Close the book
					AlcoveController.BanishCharacter()
				Else ; leave it
					;Do nothing 
				EndIf
			EndIf
		EndIf
		Return
	Else
		Debug.Trace("MYC: " + Self + " AlcoveBook" + _iAlcoveIndex + ": Activated by a non-player. This should only happen at init, so we'll proceed...")
	EndIf
EndEvent

Event OnCellAttach()
EndEvent

Event OnAttachedToCell()
EndEvent

Event OnUpdate()
	If _bFlipPages
		If _bIsOpen
			Debug.SendAnimationEvent(_BookStatic,"PageForward")
		EndIf
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

Event OnUnload()
EndEvent

Function OpenBook()
	Debug.SendAnimationEvent(_BookStatic,"Open")
	Wait(0.25)
	_BookStatic.PlaceAtMe(vMYC_BookDustExplosion)
	Wait(0.25)
	vMYC_BookWhooshSM.Play(_BookStatic)
	_BookShine.EnableNoWait(True)
EndFunction

Function CloseBook()
	_BookShine.DisableNoWait(True)
	Wait(0.25)
	Debug.SendAnimationEvent(_BookStatic,"Close")
	Wait(0.25)
	_BookStatic.PlaceAtMe(vMYC_BookDustExplosion)
	Wait(0.5)
	vMYC_BookSlamSM.Play(_BookStatic)
EndFunction