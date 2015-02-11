Scriptname vMYC_CharacterMannequin extends vMYC_Doppelganger
{Removes functions that Shrine mannequins will never need.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

;=== Properties ===--

;=== Variables ===--
		
Bool 		_bFirstLoad 				= True
				
String[] 	_sSkillNames

Float 		_fDecapitationChance

Int 		_iMagicUpdateCounter

Float 		_fOrphanedTime
Bool 		_bOrphaned

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int 		_iCharGenVersion

;Int			_jCharacterData

String 		_sCharacterInfo

String		_sFormID
;=== Events ===--

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
EndEvent

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	DebugTrace("AnimationEvent:" + asEventName)
	;If asEventName == "BeginCastVoice"
	;	Wait(0.1)
	;	InterruptCast()
	;EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
EndEvent

;=== Function from vMYC_Doppelganger that are altered ===--

Auto State Available
	Event OnLoad()
		;Clear out because we shouldn't be loaded
	EndEvent
	
	Function AssignCharacter(String sUUID)
	{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
		GoToState("Busy")
		_jCharacterData = GetRegObj("Characters." + sUUID)
		_sCharacterInfo = "Characters." + sUUID + ".Info."
		SaveSession()
		If !_jCharacterData
			DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, but there's no data for that UUID!")
			GotoState("Available")
			Return
		EndIf
		DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, transforming into " + GetRegStr(_sCharacterInfo + "Name") + "!")
		SetRegForm("Mannequins.Preferred." + sUUID + ".ActorBase",MyActorBase)
		SetSessionForm("Mannequins." + sUUID + ".ActorBase",MyActorBase)
		SetSessionForm("Mannequins." + sUUID + ".Actor",Self as Actor)
		CharacterName = GetRegStr(_sCharacterInfo + "Name")
		CharacterRace = GetRegForm(_sCharacterInfo + "Race") as Race
		MyActorBase.SetName(CharacterName)
		NeedAppearance	= True
		NeedStats		= True
		NeedPerks		= True
		NeedSpells		= True
		NeedShouts		= True
		NeedEquipment	= True
		NeedInventory	= True
		NeedRefresh 	= True
		NeedUpkeep		= True
		GotoState("Assigned")
	EndFunction
EndState

State Assigned
	Event OnBeginState()
		DebugTrace("Entered Assigned state! CharacterName is " + CharacterName + ". Will update appearance, etc in just a sec...")
		RegisterForSingleUpdate(1)
		SetNameIfNeeded()
	EndEvent

	Event OnUpdate()
		If NeedAppearance
			If UpdateAppearance() == 0 ; No error
				UpdateNINodes()
				UpdateNIOverlays()
				NeedAppearance = False
			EndIf
		EndIf
		If NeedInventory 
			If UpdateInventory() >= 0
				NeedInventory = False
			EndIf
			; Adding items usually makes the target unequip gear, so make sure it's back on.
			If !NeedEquipment
				EquipDefaultGear() 
			EndIf
		EndIf
		If NeedEquipment
			Int bResultArmor = UpdateArmor()
			Int bResultWeapons = UpdateWeapons()
			If bResultArmor >= 0 && bResultWeapons >= 0 ; No error
				NeedEquipment = False
			EndIf
		EndIf
		If NeedStats
			If UpdateStats() >= 0
				NeedStats = False
			EndIf
		EndIf
		If NeedPerks
			If UpdatePerks() >= 0 ; No error
				NeedPerks = False
			EndIf
		EndIf
		If NeedShouts
			If UpdateShouts() >= 0 ; No error
				NeedShouts = False
			EndIf
		EndIf
		If NeedSpells
			If UpdateSpells() >= 0 ; No error
				NeedSpells = False
			EndIf
		EndIf
		;ReportStats()
	EndEvent

	Event OnLoad()
	EndEvent
	
EndState

State Busy

EndState

Function AssignCharacter(String sUUID)
{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
	DebugTrace("AssignCharacter(" + sUUID + ") was called outside of Available state, doing nothing!",1)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game. Sets the name and such.}
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	IsBusy = True
	;DebugTrace("MYC/Actor/" + CharacterName + ": Starting upkeep...")
	If IsRaceInvalid 
		; Reset the race during upkeep in case the needed mod has been installed
		CharacterRace = None
		IsRaceInvalid = False
	EndIf
	RegisterForSingleUpdate(0.1)
	If !PlayerREF.HasLos(Self)
		RegisterForSingleLOSGain(PlayerREF,Self)
	EndIf
EndFunction

;=== Appearance functions ===--
; Unchanged
;=== Equipment and inventory functions ===--

Int Function EquipDefaultGear(Bool abLockEquip = False)
	Return 1
EndFunction

Int Function UpdateInventory(Bool abReplaceMissing = True, Bool abFullReset = False)
	Return 1
EndFunction

;=== Stats ===--

Int Function UpdateStats(Bool abForceValues = False)
	Return 1
EndFunction

;=== Perks ===--

Int Function UpdatePerks()
	Return 1
EndFunction

;=== Shouts ===--

Int Function UpdateShouts()
	Return 1
EndFunction

Function RemoveCharacterShouts(String sCharacterName)
EndFunction


;=== Spell functions ===--

Int Function UpdateSpells()
	Return 1
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	If CharacterName
		Debug.Trace("MYC/Mannequin/" + _sFormID + "(" + CharacterName + "): " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	Else
		Debug.Trace("MYC/Mannequin/" + _sFormID + ": " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	EndIf
EndFunction
