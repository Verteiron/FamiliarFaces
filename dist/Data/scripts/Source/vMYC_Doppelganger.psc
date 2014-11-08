Scriptname vMYC_Doppelganger extends Actor
{Apply character appearance, handle inventory import, etc.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

;=== Properties ===--

Bool Property IsAvailable Hidden
{Return whether this actor has been assigned a character.}
	Bool Function get()
		If GetState() == "Available"
			Return True
		Else
			Return False
		EndIf
	EndFunction
EndProperty

Bool 				Property NeedAppearance	= False 				Auto Hidden
Bool 				Property NeedPerks		= False 				Auto Hidden
Bool 				Property NeedSpells		= False 				Auto Hidden
Bool 				Property NeedEquipment	= False 				Auto Hidden
Bool 				Property NeedInventory	= False 				Auto Hidden
Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden
Bool 				Property IsInCity		= False 				Auto Hidden
Bool				Property IsRaceInvalid	= False					Auto Hidden

String 				Property CharacterName	= ""					Auto Hidden
String 				Property CharacterUUID	= ""					Auto Hidden
Race				Property CharacterRace	= None					Auto Hidden

Actor 				Property PlayerREF 									Auto
Armor 				Property vMYC_DummyArmor							Auto
EffectShader 		Property vMYC_BlindingLightGold						Auto
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
Message 			Property vMYC_VoiceTypeNoFollower 					Auto
Message 			Property vMYC_VoiceTypeNoSpouse						Auto

;=== Variables ===--

ActorBase 	_kActorBase 				= None
		
Bool 		_bFirstLoad 				= True
				
String[] 	_sSkillNames

Float 		_fDecapitationChance

Int 		_iMagicUpdateCounter

Float 		_fOrphanedTime
Bool 		_bOrphaned

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int 		_iCharGenVersion

;=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
EndEvent

Auto State Available
	Event OnLoad()
		;Clear out because we shouldn't be loaded
	EndEvent
	
EndState

State Assigned
	Event OnLoad()
		
	EndEvent
EndState

State Busy

EndState

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game. Sets the name and such.}
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	If bInBackground
		
		NeedUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	GotoState("Busy")
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
	GotoState("")
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If CharacterName
		Debug.Trace("MYC/Doppelganger/" + CharacterName + ": " + sDebugString,iSeverity)
	Else
		Debug.Trace("MYC/Doppelganger/" + Self.GetFormID() + ": " + sDebugString,iSeverity)
	EndIf
EndFunction
