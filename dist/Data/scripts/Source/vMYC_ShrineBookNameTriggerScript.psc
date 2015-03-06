Scriptname vMYC_ShrineBookNameTriggerScript extends ObjectReference
{Cheat the system by renaming the book when the player gets close.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor			Property PlayerREF	Auto

ReferenceAlias	Property ShrineOwner	Auto
ReferenceAlias	Property ShrineBook 	Auto

vMYC_CharacterManagerScript 	Property CharacterManager 	Auto
vMYC_ShrineOfHeroesQuestScript 	Property ShrineOfHeroes 	Auto

;=== Variables ===--

ObjectReference					_Book
vMYC_CharacterBookActiScript	_BookScript

;=== Events ===--

Event OnInit()
	RegisterForModEvent("vMYC_ForceBookUpdate","OnForceBookUpdate")
EndEvent

Event OnLoad()
	RegisterForModEvent("vMYC_ForceBookUpdate","OnForceBookUpdate")
EndEvent

Event OnForceBookUpdate(string eventName, string strArg, float numArg, Form sender)
	If !_Book
		_Book = GetLinkedRef()
		_BookScript = _Book as vMYC_CharacterBookActiScript
	EndIf
	Int iAlcoveIndex = _BookScript.AlcoveIndex
	If iAlcoveIndex == numArg
		OnTriggerEnter(PlayerREF)
	EndIf
EndEvent

Event OnTriggerEnter(ObjectReference akActionRef)
	_Book = GetLinkedRef()
	If akActionRef == PlayerREF && _Book
		_BookScript = _Book as vMYC_CharacterBookActiScript
		Int iAlcoveIndex = _BookScript.AlcoveIndex
		String sCharacterName = ShrineOfHeroes.GetAlcoveCharacterName(iAlcoveIndex)
		Actor kCharacterActor = CharacterManager.GetCharacterActorByName(sCharacterName)
		;Debug.Trace("MYC: " + Self + " I am Book #" + _BookScript.AlcoveIndex + ", shrine character is " + ShrineOfHeroes.GetAlcoveCharacterName(_BookScript.AlcoveIndex) + ", shrine actor is " + CharacterManager.GetCharacterActorByName(ShrineOfHeroes.GetAlcoveCharacterName(_BookScript.AlcoveIndex)) + "!")
		If kCharacterActor
			ShrineOwner.ForceRefTo(kCharacterActor)
			ShrineBook.ForceRefTo(_Book)
		EndIf
	EndIf
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
	If akActionRef == PlayerREF
	EndIf
EndEvent