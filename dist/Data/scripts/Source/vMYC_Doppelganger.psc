Scriptname vMYC_Doppelganger extends Actor
{Apply character appearance, handle inventory import, etc.}

; === [ vMYC_Doppelganger.psc ] ===========================================---
; When assigned a character ID, set up this Actor's appearance, inventory, 
; name, ActorValues, etc based on that character's stored data.
; Handles:
;   Setting up Actor appearance
;   Setting up Actor's inventory and equipment (including custom equipment)
;   Setting up Actor's spells, shouts, perks, and actorvalues
;   Tracking the Actor adding/removing spells, items, etc as needed.
; Usage:
;   When in the Available state, call AssignCharacter and the script will
;   take care of everything else.
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_Session
Import vMYC_API_Doppelganger

;=== Constants ===--

;=== Properties ===--

Bool Property IsAvailable Hidden
{Return whether this actor has been assigned a character.}
	Bool Function Get()
		If GetState() == "Available"
			Return True
		Else
			Return False
		EndIf
	EndFunction
EndProperty

String Property ScriptState Hidden
{Return this actor's script state.}
	String Function Get()
		Return GetState()
	EndFunction
EndProperty

ActorBase			Property MyActorBase							Auto Hidden

vMYC_DataManager	Property DataManager							Auto

Bool 				Property NeedAppearance	= False 				Auto Hidden
Bool 				Property NeedStats		= False 				Auto Hidden
Bool 				Property NeedPerks		= False 				Auto Hidden
Bool 				Property NeedSpells		= False 				Auto Hidden
Bool 				Property NeedShouts		= False 				Auto Hidden
Bool 				Property NeedEquipment	= False 				Auto Hidden
Bool 				Property NeedInventory	= False 				Auto Hidden
Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden
Bool 				Property IsCharGenBusy	= False 				Auto Hidden
Bool 				Property IsInCity		= False 				Auto Hidden
Bool				Property IsRaceInvalid	= False					Auto Hidden

String 				Property CharacterName	= ""					Auto Hidden
String 				Property CharacterUUID	= ""					Auto Hidden
String 				Property SID			= ""					Auto Hidden
Race				Property CharacterRace	= None					Auto Hidden

Actor 				Property PlayerREF 									Auto
Armor 				Property vMYC_DummyArmor							Auto
EffectShader 		Property vMYC_BlindingLightGold						Auto
EffectShader 		Property vMYC_BlindingLightOutwardParticles 		Auto
Explosion 			Property vMYC_CharacterDeathExplosion				Auto
VisualEffect		Property vMYC_ValorFX								Auto
VisualEffect		Property DA02SummonValorTargetFX					Auto
ImageSpaceModifier	Property ISMDwhiteoutFULLthenFade					Auto
Sound				Property NPCDragonDeathFX2D							Auto
Sound				Property NPCDragonDeathSequenceExplosion			Auto
FormList 			Property vMYC_CombatStyles 							Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Safe 		Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Unsafe 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Healing 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Armor 		Auto
Formlist 			Property vMYC_ModCompatibility_PerkList_Unsafe 		Auto
{A list of Perks that are known to be unsafe or unnecessary to load on NPCs.}

Message 			Property vMYC_VoiceTypeNoFollower 					Auto
Message 			Property vMYC_VoiceTypeNoSpouse						Auto

Int					Property _jCharacterData							Auto Hidden

Faction 			Property CurrentFollowerFaction						Auto
Faction 			Property PotentialFollowerFaction					Auto
Faction 			Property PotentialMarriageFaction					Auto
Faction 			Property vMYC_CharacterPlayerEnemyFaction			Auto

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

Event OnInit()
	MyActorBase = GetActorBase()
	MyActorBase.SetEssential(True)
EndEvent

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

Event OnLoad()

EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	NeedStats = True
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	NeedStats = True
EndEvent

Event OnEnterBleedout()
	If GetSessionBool("Characters." + SID + ".Config.VanishOnDeath")
		BlockActivation(True)
		vMYC_ValorFX.Play(Self,8)
		KillEssential(PlayerREF)
		Wait(1)
		vMYC_BlindingLightOutwardParticles.Play(Self,1)
		Wait(6)
		SetAlpha(0.01,True)
		Wait(1.3)
		NPCDragonDeathSequenceExplosion.Play(Self)
		PlaceAtMe(vMYC_CharacterDeathExplosion)
		NPCDragonDeathFX2D.Play(Self)
		vMYC_API_Doppelganger.UnregisterActor(Self,SID)
		Wait(7)
		Disable()
		Delete()
	EndIf
EndEvent


Auto State Available
	Event OnLoad()
		;Clear out because we shouldn't be loaded
	EndEvent
	
	Function AssignCharacter(String asSID)
	{This is the biggie, calling this in Available state will transform the character into the target in asSID.}
		GoToState("Busy")
		_jCharacterData = GetRegObj("Characters." + asSID)
		_sCharacterInfo = "Characters." + asSID + ".Info."
		SaveSession()
		If !_jCharacterData
			DebugTrace("AssignCharacter(" + asSID + ") was called in Available state, but there's no data for that UUID!")
			GotoState("Available")
			Return
		EndIf
		SID = asSID
		DebugTrace("AssignCharacter(" + asSID + ") was called in Available state, transforming into " + GetRegStr(_sCharacterInfo + "Name") + "!")
		CharacterName = GetRegStr(_sCharacterInfo + "Name")
		CharacterRace = GetRegForm(_sCharacterInfo + "Race") as Race

		vMYC_API_Doppelganger.RegisterActor(Self)

		MyActorBase.SetName(CharacterName)
		FFUtils.SetLevel(MyActorBase,JValue.SolveInt(_jCharacterData,".Stats.Level"))
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
		UpdateNINodes()
	EndEvent
	
EndState

State Busy

EndState

Function AssignCharacter(String asSID)
{This is the biggie, calling this in Available state will transform the character into the target in asSID.}
	DebugTrace("AssignCharacter(" + asSID + ") was called outside of Available state, doing nothing!",1)
EndFunction

Function EraseCharacter()
{This will blank out this character, delete the Actor and release the Actorbase back into the pool.}
	;FIXME: Do something!
	SID = ""
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game. Sets the name and such.}
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	IsBusy = True
	;DebugTrace("MYC/Actor/" + CharacterName + ": Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	If IsRaceInvalid 
		; Reset the race during upkeep in case the needed mod has been installed
		CharacterRace = None
		IsRaceInvalid = False
	EndIf
	;CheckVars()
	;SyncCharacterData()
	If !HasSessionKey(CharacterName + ".Shouts.Allow")
		SetSessionBool(CharacterName + ".Shouts.Allow",True) ; allow shouts by default
	EndIf
;	SetNonpersistent()
	If _iCharGenVersion == 3
;		RefreshMeshNewCG()
	EndIf
;	_bWarnedVoiceTypeNoFollower = False
	;_bWarnedVoiceTypeNoSpouse = False
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	;DebugTrace("MYC/Actor/" + CharacterName + ": finished upkeep!")
	If !PlayerREF.HasLos(Self)
		RegisterForSingleLOSGain(PlayerREF,Self)
	EndIf
EndFunction

Function SetNameIfNeeded(Bool abForce = False)
	If (CharacterName && MyActorBase.GetName() != CharacterName) || abForce
		DebugTrace("Setting actorbase name!")
		MyActorBase.SetName(CharacterName)
		SetName(CharacterName)
		;FIXME: This will need to be reenabled, just disabling now to simply things
		;Int i = GetNumReferenceAliases()
		;While i > 0
		;	i -= 1
		;	ReferenceAlias kThisRefAlias = GetNthReferenceAlias(i)
		;	;If kThisRefAlias.GetOwningQuest() != CharacterManager && kThisRefAlias.GetOwningQuest() != ShrineOfHeroes
		;		DebugTrace("Resetting RefAlias " + kThisRefAlias + "!")
		;		kThisRefAlias.TryToClear()
		;		kThisRefAlias.ForceRefIfEmpty(Self)
		;	;EndIf
		;EndWhile
		SendModEvent("vMYC_UpdateXFLPanel")
	EndIf
EndFunction

;=== Disposition and configuration functions ===--
Int Function UpdateDisposition()
	Bool bIsFriend 	= GetSessionBool("Characters." + SID + ".Config.IsFriend")
 	Bool bIsFoe 	= GetSessionBool("Characters." + SID + ".Config.IsFoe")
 	Bool bCanMarry 	= GetSessionBool("Characters." + SID + ".Config.CanMarry")

 	If bIsFoe
 		;FIXME: Avoid Gopher's bug, make sure they are NOT a follower before making them a baddie!
 		;FIXME: Also make sure the player didn't just make an enemy of their spouse!
 		DebugTrace("I hate the player! What a jerk!")
		RemoveFromFaction(CurrentFollowerFaction)
		RemoveFromFaction(PotentialFollowerFaction)
		RemoveFromFaction(PotentialMarriageFaction)
		SetFactionRank(vMYC_CharacterPlayerEnemyFaction,0)
		SetActorValue("Aggression",1)
		SetRelationshipRank(PlayerREF,-4)
	ElseIf bIsFriend
		DebugTrace("The player's a pretty good friend of mine!")
		If GetFactionRank(PotentialFollowerFaction) <= -2 || GetRelationshipRank(PlayerREF) == 0
			RemoveFromFaction(vMYC_CharacterPlayerEnemyFaction)
			SetFactionRank(PotentialFollowerFaction,0)
			SetFactionRank(CurrentFollowerFaction,-1)
			SetRelationshipRank(PlayerREF,3)
			SetActorValue("Aggression",0)
		EndIf
		Int iSafetyTimer = 10
		While IsInCombat() && GetCombatTarget() == PlayerREF && iSafetyTimer
			iSafetyTimer -= 1
			StopCombat()
			Wait(0.5)
		EndWhile
		If bCanMarry && GetFactionRank(PotentialMarriageFaction) <= -2
			Debug.Trace("... and I'd marry them if given the chance!")
			SetFactionRank(PotentialMarriageFaction,0)
		EndIf
	EndIf
	Return 1
EndFunction

;=== Appearance functions ===--

Int Function UpdateAppearance()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateAppearance called outside Assigned state!")
		Return -2
	EndIf
	Return vMYC_API_Doppelganger.UpdateAppearance(SID,Self)
EndFunction

Int Function UpdateNINodes()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateAppearance called outside Assigned state!")
		Return -2
	EndIf

	Return vMYC_API_Doppelganger.UpdateNINodes(SID,Self)
EndFunction

Int Function UpdateNIOverlays()
	If !ScriptState == "Assigned"
		DebugTrace("UpdateNIOverlays called outside Assigned state!")
		Return -2
	EndIf
	Return vMYC_API_Doppelganger.UpdateNIOverlays(SID,Self)
EndFunction

Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName)
	If !ScriptState == "Assigned"
		DebugTrace("CharGenLoadCharacter called outside Assigned state!")
		Return False
	EndIf
	Return vMYC_API_Doppelganger.CharGenLoadCharacter(akActor,akRace,asCharacterName)
EndFunction

;=== Equipment and inventory functions ===--

Int Function EquipDefaultGear(Bool abLockEquip = False)
{Re-equip the gear this character was saved with, optionally locking it in place.
 abLockEquip: (Optional) Lock equipment in place, so AI cannot remove it automatically.
 Returns: Number of items processed.}
;FIXME: This may fail to equip the correct item if character has both the base 
;and a customized version of the same item in their inventory

	Return vMYC_API_Doppelganger.EquipDefaultGear(SID,Self,abLockEquip)

EndFunction

Int Function UpdateArmor(Bool abReplaceMissing = True, Bool abFullReset = False)
{Setup equipped Armor based on the saved character data.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdateArmor called outside Assigned state!",1)
		Return -2
	EndIf
	
	Return vMYC_API_Doppelganger.UpdateArmor(SID,Self,abReplaceMissing,abFullReset)

EndFunction

Int Function UpdateWeapons(Bool abReplaceMissing = True, Bool abFullReset = False)
{Setup equipped Weapons and Ammo based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdateWeapons called outside Assigned state!",1)
		Return -2
	EndIf
	Return vMYC_API_Doppelganger.UpdateWeapons(SID,Self,abReplaceMissing,abFullReset)
EndFunction

Int Function UpdateInventory(Bool abReplaceMissing = True, Bool abFullReset = False)
{Setup Inventory items based on the saved character data.
 abReplaceMissing: (Optional) If an item has been removed, replace it. May lead to item duplication.
 abFullReset: (Optional) Remove ALL items and replace with originals. May cause loss of inventory items.
 Returns: Number of items processed.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdateInventory called outside Assigned state!",1)
		Return -2
	EndIf
	Return vMYC_API_Doppelganger.UpdateInventory(SID,Self,abReplaceMissing,abFullReset)
EndFunction

;=== Stats ===--

Int Function UpdateStats(Bool abForceValues = False)
{Apply AVs and other stats like health. 
 abForceValues: (Optional) Set values absolutely, ignoring any buffs or nerfs from enchantments/magiceffects.
 Returns: -1 for generic failure.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdatePerks called outside Assigned state!",1)
		Return -2
	EndIf

	Return vMYC_API_Doppelganger.UpdateStats(SID,Self,abForceValues)
	
EndFunction

;=== Perks ===--

Int Function UpdatePerks()
{Apply perks.
 Returns:  for failure, or number of perks applied for success.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdatePerks called outside Assigned state!",1)
		Return -2
	EndIf
	
	Return vMYC_API_Doppelganger.UpdatePerks(SID,Self)
EndFunction

;=== Shouts ===--

Int Function UpdateShouts()
{Apply shouts to named character. Needed because AddShout causes savegame corruption.
 Returns: -1 for failure, or number of shouts applied for success.}
;FIXME: I bet this could be done with FFUtils and avoid using the FormList.
	If !ScriptState == "Assigned"
		DebugTrace("UpdateShouts called outside Assigned state!",1)
		Return -2
	EndIf

	RegisterForAnimationEvent(Self,"BeginCastVoice")
	RegisterForAnimationEvent(Self,"MT_Shout_Exhale")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleLong")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleMedium")
	RegisterForAnimationEvent(Self,"MT_Shout_ExhaleSlowTime")
	RegisterForAnimationEvent(Self,"MT_Shout_Inhale")
	RegisterForAnimationEvent(Self,"shoutStop")
	RegisterForAnimationEvent(Self,"Sneak1HM_Shout_Inhale")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_Exhale")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleLong")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleMedium")
	RegisterForAnimationEvent(Self,"SneakMT_Shout_ExhaleSlowTime")
	RegisterForAnimationEvent(Self,"Voice_SpellFire_Event")
	RegisterForAnimationEvent(Self,"CombatReady_ShoutExhaleMedium")
	RegisterForAnimationEvent(Self,"MC_shoutStart")
	RegisterForAnimationEvent(Self,"NPCshoutStart")
	RegisterForAnimationEvent(Self,"shoutLoopingRelease")
	RegisterForAnimationEvent(Self,"shoutRelease")
	RegisterForAnimationEvent(Self,"shoutReleaseSlowTime")
	RegisterForAnimationEvent(Self,"ShoutSprintLongestStart")
	RegisterForAnimationEvent(Self,"ShoutSprintLongStart")
	RegisterForAnimationEvent(Self,"ShoutSprintMediumStart")
	RegisterForAnimationEvent(Self,"ShoutSprintShortStart")
	RegisterForAnimationEvent(Self,"shoutStart")
	RegisterForAnimationEvent(Self,"shoutStop")
	
	Return vMYC_API_Doppelganger.UpdateShouts(SID,Self)

EndFunction

Function RemoveCharacterShouts(String sCharacterName)
{Remove all shouts from named character. Needed because RemoveShout causes savegame corruption.}
	DebugTrace("Character is not allowed to use shouts, removing them!")
	Return vMYC_API_Doppelganger.RemoveCharacterShouts(SID,Self)
EndFunction


;=== Spell functions ===--

Int Function UpdateSpells()
{Apply Spells. 
 Returns: -1 for failure, or number of Spells applied for success.}
	If !ScriptState == "Assigned"
		DebugTrace("UpdateSpells called outside Assigned state!",1)
		Return -2
	EndIf
	Return vMYC_API_Doppelganger.UpdateSpells(SID,Self)
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	If CharacterName
		Debug.Trace("MYC/Doppelganger/" + _sFormID + "(" + CharacterName + "): " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	Else
		Debug.Trace("MYC/Doppelganger/" + _sFormID + ": " + sDebugString,iSeverity)
		FFUtils.TraceConsole(sDebugString)
	EndIf
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
