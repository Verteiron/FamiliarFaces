Scriptname vMYC_ShrineActivatorScript extends ObjectReference  
{Handle shrine activation/deactivation effects}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int	Property ShrineIndex Hidden
{Which shrine am I?}
	Int Function Get()
		Return _iShrineIndex
	EndFunction
	Function Set(Int iShrineIndex)
		_iShrineIndex = iShrineIndex
		Debug.Trace("MYC: " + Self + " I am Shrine #" + _iShrineIndex + "!")
		RegisterForSingleUpdate(1)
	EndFunction
EndProperty

String	Property CharacterName Hidden
{Which Character lives here?}
	String Function Get()
		Return _sCharacterName
	EndFunction
	Function Set(String sCharacterName)
		RegisterForModEvent("vMYC_SetShrineCharacterName","OnSetShrineCharacterName")
		SendModEvent("vMYC_SetShrineCharacterName",sCharacterName)
	EndFunction
EndProperty

Int Property ShrineLightState Hidden 
{0 = Dark, 1 = FullLight, 2 = TorchLight}
	Int Function Get()
		Return _iShrineLightState
	EndFunction
	Function Set(Int iShrineLightState)
		RegisterForModEvent("vMYC_ShrineLightStateChange","OnShrineLightStateChange")
		SendModEvent("vMYC_ShrineLightStateChange","",iShrineLightState)
	EndFunction
EndProperty


vMYC_CharacterManagerScript 	Property CharacterManager 	Auto
vMYC_ShrineOfHeroesQuestScript 	Property ShrineOfHeroes 	Auto
vMYC_ShrinePortalScript 		Property Portal				Auto

Actor 			Property 	PlayerREF					Auto

Activator		Property	vMYC_PerkGlow				Auto

ActorBase		Property	vMYC_InvisibleMActor		Auto
ActorBase		Property	vMYC_InvisibleFActor		Auto

Bool			Property	CharacterSummoned			Auto Hidden

EffectShader 	Property 	vMYC_BlindingLight					Auto
EffectShader 	Property 	vMYC_BlindingLightGold				Auto
EffectShader 	Property 	vMYC_BlindingLightSkinOnly			Auto
EffectShader	Property	vMYC_BlindingLightInwardParticles	Auto

Explosion		Property	vMYC_BookDustExplosion				Auto

Formlist		Property	vMYC_TrophyKeywords					Auto

VisualEffect	Property	MAGDragonPowerAbsorbEffect 			Auto
VisualEffect	Property	MAGDragonPowerAbsorbManEffect 		Auto
VisualEffect	Property 	AbsorbCastVFX01						Auto
VisualEffect	Property 	AbsorbTargetVFX01					Auto
VisualEffect	Property 	AbsorbBlueCastVFX01					Auto
VisualEffect	Property 	AbsorbBlueTargetVFX01				Auto
VisualEffect	Property 	AbsorbGreenCastVFX01				Auto
VisualEffect	Property 	AbsorbGreenTargetVFX01				Auto
VisualEffect	Property 	vMYC_SpellAbsorbTargetVFX			Auto
VisualEffect	Property 	DA02SummonValorTargetFX				Auto
VisualEffect	Property	vMYC_ValorFX						Auto

Keyword 		Property 	vMYC_ShrineBook				Auto
Keyword 		Property 	vMYC_ShrineFog 				Auto
Keyword 		Property 	vMYC_ShrineFurnishing 		Auto
Keyword 		Property 	vMYC_ShrineLight 			Auto
Keyword 		Property 	vMYC_ShrineLightingMaster	Auto
Keyword 		Property 	vMYC_ShrineTorches 			Auto
Keyword			Property	vMYC_ShrineCurtain			Auto

Keyword 		Property 	vMYC_ShrineTrophyHero			Auto
Keyword 		Property 	vMYC_ShrineTrophyBard			Auto
Keyword 		Property 	vMYC_ShrineTrophyBlade			Auto
Keyword 		Property 	vMYC_ShrineTrophyCompanion		Auto
Keyword 		Property 	vMYC_ShrineTrophyGreybeard		Auto
Keyword 		Property 	vMYC_ShrineTrophyImperial		Auto
Keyword 		Property 	vMYC_ShrineTrophyMage			Auto
Keyword 		Property 	vMYC_ShrineTrophyStormcloak		Auto
Keyword 		Property 	vMYC_ShrineTrophyThief			Auto
Keyword 		Property 	vMYC_ShrineTrophyDBRestored		Auto
Keyword 		Property 	vMYC_ShrineTrophyDBDestroyed	Auto

Keyword 		Property 	vMYC_ShrineTrophyThaneDawnstar	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneFalkreath	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneMarkarth	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneMorthal	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneWhiterun	Auto

Keyword 		Property 	vMYC_ShrineTrophyVampireSymbol	Auto
Keyword 		Property 	vMYC_ShrineTrophyWerewolfSymbol	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Dawnguard	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Vampire	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Complete	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC2Miraak		Auto

Idle			Property	IdleStaticPoseA				Auto
Idle			Property	AscendMale					Auto
Idle			Property	AscendFemale				Auto
Idle			Property	IdleStop_loose				Auto
Idle			Property	IdleSnapToAttention			Auto
Idle			Property	IdleSilentBow				Auto
Idle			Property	IdleSalute					Auto
Idle			Property	CombatIdleStretching		Auto

ImageSpaceModifier	Property	vMYC_ShrineLightISMD			Auto
ImageSpaceModifier	Property	vMYC_ShrineLightWhiteoutISMD	Auto

Weather			Property	vMYC_ShrineStars			Auto

;MRh_AimedConcentration
;OffsetCarryPot
;OffsetWoodPosture
;Sneak1HM_Idle

SoundCategory	Property	AudioCategorySFX			Auto

;Sound			Property	QSTTG09BeamAbilitiesColumnLPM			Auto
Sound			Property	QSTMG07MagnusStormCollegeMediumLPM		Auto
Sound			Property	QSTMG07MagnusStormCollegeMediumRelease	Auto
Sound			Property	QSTBeamMeridiaStatueLP					Auto
Sound			Property	QSTDA09LightBeamOn						Auto
Sound			Property	QSTDA09LightBeamOff						Auto
Sound			Property	vMYC_QSTTG09BeamAbilitiesColumnLPSM		Auto
Sound			Property	vMYC_QSTTG09BeamAbilitiesColumnStartSM	Auto
Sound			Property	QSTMQ206TimeTravel2DSound				Auto

;--=== Variables ===--

Actor 			_kCharacter
Actor			_kInvisibleActor
Actor[]			_kInvisibleActors

Bool 			_bLoaded
Bool			_bActivateOnLoad
Bool			_bPlayerIsSaving
Bool			_bPoseCharacter
Bool			_bFreezeCharacter
Bool			_bCharacterReady
Bool			_bForceSave

ObjectReference	_FogBlowing
ObjectReference	_FogEmpty

ObjectReference	_StatueMarker

vMYC_CharacterBookActiScript	_Book

ObjectReference	_Light

ObjectReference _Torches

ObjectReference	_Curtain

Int				_iShrineIndex = -1
Int				_iInvisibleActorIndex
Int				_iShrineLightState = 0 ; 0 = empty, 1 = lights on

Float 			_LightX
Float 			_LightY
Float 			_LightZ

ObjectReference	_LightAmbientTarget

String			_sCharacterName

Int				_iQSTMG07MagnusStormCollegeMediumLPM
Int				_iQSTBeamMeridiaStatueLP

Int 			_iShrineToSwap = -1

;--=== Events ===--

Event OnInit()
	_FogEmpty = GetLinkedRef(vMYC_ShrineFog)
	_FogBlowing = _FogEmpty.GetLinkedRef(vMYC_ShrineFog)
	_Light = GetLinkedRef(vMYC_ShrineLight)
	_LightAmbientTarget	= _Light.GetLinkedRef()
	_Torches = GetLinkedRef(vMYC_ShrineTorches)
	_StatueMarker = GetLinkedRef(vMYC_ShrineFurnishing)
	_Curtain = GetLinkedRef(vMYC_ShrineCurtain)
	_kInvisibleActors = New Actor[32]
	_iInvisibleActorIndex = _kInvisibleActors.Length
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_LightX = _Light.GetPositionX()
	_LightY = _Light.GetPositionY()
	_LightZ = _Light.GetPositionZ()
	_LightAmbientTarget	= _Light.GetLinkedRef()
	_Light = GetLinkedRef(vMYC_ShrineLight)
	_Light.MoveTo(_LightAmbientTarget)
EndEvent

Event OnLoad()
	;Debug.Trace("MYC: " + Self + " OnLoad!")
	;Wait(RandomFloat(2,3))
	If _bActivateOnLoad
		_bActivateOnLoad = False
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Has activation queued! Activating!")
		OnActivate(Self)
	EndIf
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	If !CharacterName
		SendModEvent("vMYC_ShrineStatusUpdate",0)
	EndIf
	RegisterForModEvent("vMYC_ShrineLightingPriority","OnShrineLightingPriority")
	;vMYC_ShrineStars.SetActive(True,True)
EndEvent

Event OnShrineLightingPriority(string eventName, string strArg, float numArg, Form sender)
	;strArg = numArg = ShrineIndex of sender
	Int iRequestingIndex = numArg as Int
	If iRequestingIndex != ShrineIndex
		_Light.Disable()
		Wait(5)
		_Light.Enable()
	EndIf
	
EndEvent

Event OnSetShrineCharacterName(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	String sCharacterName = strArg
	If _sCharacterName && sCharacterName && sCharacterName != _sCharacterName ; FIXME: Swap characters
		Debug.Trace("MYC: " + Self + " OnSetShrineCharacterName - Shrine" + _iShrineIndex + ": CharacterName changed from " + _sCharacterName + " to " + sCharacterName + "!",1)
		WaitForCharacterReady()
		HideTrophies()
		Wait(1)
		Actor kNewCharacter = CharacterManager.GetCharacterActorByName(_sCharacterName)
		_sCharacterName = sCharacterName
		kNewCharacter.MoveTo(_StatueMarker)
		ShowTrophies()
		Wait(5)
		_kCharacter = kNewCharacter
	ElseIf !_sCharacterName && sCharacterName
		Debug.Trace("MYC: " + Self + " OnSetShrineCharacterName - Shrine" + _iShrineIndex + ": CharacterName changed from empty to " + sCharacterName + "!")
		_sCharacterName = sCharacterName
		ShrineOfHeroes.SetShrineCharacterName(_iShrineIndex,_sCharacterName)
		OnActivate(Self)
	ElseIf _sCharacterName && !sCharacterName
		Debug.Trace("MYC: " + Self + " OnSetShrineCharacterName - Shrine" + _iShrineIndex + ": CharacterName changed from " + _sCharacterName + " to empty!")
		_sCharacterName = sCharacterName
		ShrineLightState = 0
		HideTrophies()
		_kCharacter.Disable(True)
		_kCharacter = None
		ShrineOfHeroes.SetShrineCharacterName(_iShrineIndex,_sCharacterName)
		OnActivate(Self)
	Else
		;No change
	EndIf
EndEvent
	
Event OnCellAttach()
EndEvent

Event OnAttachedToCell()
EndEvent

Event OnUpdate()
	;Debug.Trace("MYC: " + Self + " Checking if ShrineOfHeroes is ready...")
	If ShrineOfHeroes.Ready
		;Debug.Trace("MYC: " + Self + " ShrineOfHeroes is ready! :D")
		CharacterName = ShrineOfHeroes.GetShrineCharacterName(ShrineIndex)
		If !_Book
			_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
		EndIf
		_Book.ShrineIndex = ShrineIndex
		InitTrophies()
	Else
		;Debug.Trace("MYC: " + Self + " ShrineOfHeroes is NOT ready, will try again in a second :(")
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

Event OnUnload()
EndEvent

Event OnShrineLightStateChange(string eventName, string strArg, float numArg, Form sender)
{numArg: 0 = Dark, 1 = Full light, 2 = Torch light}
	If sender != Self || numArg as Int == _iShrineLightState
		Return
	EndIf
	Bool bUseTranslation = True
	If !Is3DLoaded()
		bUseTranslation = False
	EndIf
	Debug.Trace("MYC: " + Self + " Setting light state to " + numArg as Int + ", current state is " + _iShrineLightState)
	Int iOldLightState = _iShrineLightState
	Int iLightState = numArg as Int
	_LightAmbientTarget	= _Light.GetLinkedRef()
	
	If _Light.IsDisabled() && iLightState > 0
		_Light.Enable()
		Int iSafety = 0
		While !_Light.Is3DLoaded() && iSafety < 4
			iSafety += 1
			Wait(0.1)
		EndWhile
	EndIf

	If iLightState != 1
		_Curtain.DisableNoWait(True)
	EndIf

	If iLightState != 2
		_Torches.DisableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).DisableNoWait(True)
	Else
		_Torches.EnableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).EnableNoWait(True)
	EndIf
	
	If iLightState == 1 && _Light.GetDistance(_LightAmbientTarget) < 10
		If bUseTranslation
			_Light.TranslateTo(_LightX,_LightY,_LightZ,0,0,0,150)
		Else
			_Light.SetPosition(_LightX,_LightY,_LightZ)
		EndIf
	ElseIf iLightState == 0 || iLightState == 2
		If _iQSTMG07MagnusStormCollegeMediumLPM
			Sound.StopInstance(_iQSTMG07MagnusStormCollegeMediumLPM)
			_iQSTMG07MagnusStormCollegeMediumLPM = 0
		EndIf
		If bUseTranslation
			QSTMG07MagnusStormCollegeMediumRelease.Play(_Light)
			_Light.TranslateToRef(_LightAmbientTarget,300)
		Else
			_Light.MoveTo(_LightAmbientTarget)
		EndIf
	EndIf
	
	If iLightState == 2
		_FogEmpty.Disable(True)
		_FogBlowing.DisableNoWait(True)
	Else
		_FogEmpty.Enable(True)
		_FogBlowing.EnableNoWait(True)
	EndIf
	
	If iLightState == 1
		Wait(1.5)
		If !_iQSTMG07MagnusStormCollegeMediumLPM && bUseTranslation
			_iQSTMG07MagnusStormCollegeMediumLPM = QSTMG07MagnusStormCollegeMediumLPM.Play(_Light)
		EndIf
		Wait(1.5)
		_Curtain.EnableNoWait(True)
	EndIf

	If iLightState == 0
		Wait(2)
		_Light.DisableNoWait()
	EndIf
	
	If !Is3DLoaded() && bUseTranslation ;We got unloaded mid-transition, probably because the player is naughty. Rerun with bUseTranslation off!
		OnShrineLightStateChange(eventName, strArg, numArg, sender)
	EndIf
	_iShrineLightState = iLightState ; Set internal property value 
EndEvent

Function SavePlayer(Bool abForceSave = False)
	_bForceSave = abForceSave
	_bPlayerIsSaving = True
	RegisterForModEvent("vMYC_PerksSaveBegin","OnPerksSaveBegin")
	RegisterForModEvent("vMYC_PerkSaved","OnPerkSaved")
	RegisterForModEvent("vMYC_PerksSaveEnd","OnPerksSaveEnd")
	RegisterForModEvent("vMYC_SpellsSaveBegin","OnSpellsSaveBegin")
	RegisterForModEvent("vMYC_SpellSaved","OnSpellSaved")
	RegisterForModEvent("vMYC_SpellsSaveEnd","OnSpellsSaveEnd")
	RegisterForModEvent("vMYC_EquipmentSaveBegin","OnEquipmentSaveBegin")
	RegisterForModEvent("vMYC_EquipmentSaved","OnEquipmentSaved")
	RegisterForModEvent("vMYC_EquipmentSaveEnd","OnEquipmentSaveEnd")
	RegisterForModEvent("vMYC_InventorySaveBegin","OnInventorySaveBegin")
	RegisterForModEvent("vMYC_ItemSaved","OnItemSaved")
	RegisterForModEvent("vMYC_InventorySaveEnd","OnInventorySaveEnd")
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_Book.IsOpen = True
	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": SavePlayer!")
	Wait(0.25)
	DisablePlayerControls(abCamSwitch = True)
	ForceThirdPerson()
	ShrineLightState = 1
	SendModEvent("vMYC_ShrineLightingPriority","On",ShrineIndex)
	Wait(0.5)
	DisablePlayerControls(abCamSwitch = True)
	;vMYC_BlindingLightGold.Play(PlayerREF,-1)
	RegisterForAnimationEvent(PlayerREF,"T02Ascend")
	Idle kAscendIdle 
	If !PlayerREF.GetActorBase().GetSex()
		kAscendIdle = AscendMale
	Else
		kAscendIdle = AscendFemale
	EndIf
	PlayerREF.PlayIdle(kAscendIdle)
	Int i = _kInvisibleActors.Length
	While i > 0
		i -= 1
		If !PlayerREF.GetActorBase().GetSex()
			;vMYC_InvisibleMActor.SetHeight(PlayerREF.GetActorBase().GetHeight())
			_kInvisibleActors[i] = _StatueMarker.PlaceActorAtMe(vMYC_InvisibleMActor)
		Else
			;vMYC_InvisibleFActor.SetHeight(PlayerREF.GetActorBase().GetHeight())
			_kInvisibleActors[i] = _StatueMarker.PlaceActorAtMe(vMYC_InvisibleFActor)
		EndIf
		_kInvisibleActors[i].BlockActivation(True)
		;_kInvisibleActors[i].SetAlpha(0.01)
		;_kInvisibleActors[i].SetScale(1.05)
		;_kInvisibleActors[i].UnequipAll()
	EndWhile
	i = _kInvisibleActors.Length
	AudioCategorySFX.SetFrequency(0.1) ; This hides the "whoosh" sound from the Ascend animation on the invisible actors
	While i > 0
		i -= 1
		_kInvisibleActors[i].PlayIdle(kAscendIdle)
	EndWhile
	Wait(1.0)
	vMYC_ShrineLightISMD.ApplyCrossFade(8.0)
	AudioCategorySFX.SetFrequency(1.0) ; Restore sound to normal
	;Finish in OnAnimationEvent
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": AnimationEvent " + asEventName)
	;---=== this stuff is for my attempt at making the poses more interesting. Doesn't work reliably because Bethesda. Fix it later
	;If asEventName == "PickNewIdle" && _bPoseCharacter
	;	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": PickNewIdle caught with _bPoseCharacter = true")
	;	_bPoseCharacter = False
	;	_bFreezeCharacter = True
	;	;UnregisterForAnimationEvent(_kCharacter,"PickNewIdle")
	;ElseIf asEventName == "IdleStop" && _bPoseCharacter && _bFreezeCharacter
	;	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": IdleStop caught with _bFreezeCharacter = true")
	;	_bFreezeCharacter = False
	;	_bPoseCharacter = False
	;	;actor is standing in normal combat pose
	;	UnregisterForAnimationEvent(_kCharacter,"IdleStop")
	;	UnregisterForAnimationEvent(_kCharacter,"PickNewIdle")
	;	;Debug.SendAnimationEvent(_kCharacter,"IdleStaticPoseCStart")
	;	;Wait(0.5)
	;	_kCharacter.EnableAI(False)
	;	ShrineLightState = 2
	;	
	If asEventName == "T02Ascend"
		UnregisterForAnimationEvent(PlayerREF,"T02Ascend")
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Player is floating!")
		Debug.ToggleCollisions()
		vMYC_QSTTG09BeamAbilitiesColumnStartSM.Play(PlayerREF)
		vMYC_ValorFX.Play(PlayerREF,-1)
		vMYC_BlindingLightSkinOnly.Play(PlayerREF,-1)
		_Book.IsGlowing = True
		_Book.FlipPages = True
		PlayerRef.TranslateToRef(_Book.GetLinkedRef(vMYC_ShrineBook),100) ; book is linked to player target through this keyword
		Wait(1)
		MAGDragonPowerAbsorbEffect.Play(PlayerREF,8,_StatueMarker)
		;NIOverride.AddOverrideFloat(_kInvisibleActor,PlayerREF.GetActorBase().getSex(),_kInvisibleActor.GetActorBase().GetSkin(),_kInvisibleActor.GetActorBase().GetSkin().GetNthArmorAddon(0),"",8,0,0.0,False)
		;Function AddOverrideFloat(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, float value, bool persist) native global
		_Curtain.EnableNoWait(True)
		vMYC_SpellAbsorbTargetVFX.Play(PlayerREF,-1,_StatueMarker)
		CharacterManager.SaveCurrentPlayer(bForceSave = _bForceSave)
		_bForceSave = False
		vMYC_SpellAbsorbTargetVFX.Stop(PlayerREF)
		Wait(1.0)
		_Book.FlipPages = False
		_Book.IsGlowing = False
		ShrineOfHeroes.SetShrineCharacterName(_iShrineIndex,PlayerREF.GetActorBase().GetName())
		RegisterForSingleUpdate(0.1)
		vMYC_ShrineLightISMD.PopTo(vMYC_ShrineLightWhiteoutISMD) ; white out in 2.5 seconds 
		SendModEvent("vMYC_ForceBookUpdate","",ShrineIndex)
		QSTMQ206TimeTravel2DSound.Play(_Book)
		Wait(2.0)
		vMYC_BlindingLightSkinOnly.Stop(PlayerREF)
		PlayerRef.TranslateToRef(_Book.GetLinkedRef(vMYC_ShrineBook).GetLinkedRef(),999999)
		Wait(0.1)
		PlayerREF.PlayIdle(IdleStop_loose)
		Wait(0.1)
		vMYC_ValorFX.Stop(PlayerREF)
		PlayerREF.StopTranslation()
		Wait(0.1)
		Debug.ToggleCollisions()
		Debug.SendAnimationEvent(PlayerREF,"IdleStaticPoseAStart")
		Debug.SendAnimationEvent(PlayerREF,"BleedOutStart")
		Wait(3.0)
		EnablePlayerControls()
		Debug.SendAnimationEvent(PlayerREF,"BleedOutStop")
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Player should be released, shrine should be loaded/loading!")
		Wait(3.0)
		_Book.IsOpen = False
	EndIf
EndEvent

Event OnEquipmentSaveEnd(string eventName, string strArg, float numArg, Form sender)
	Wait(6.0)
	Int i = _kInvisibleActors.Length
	While i > 0
		i -= 1
		_kInvisibleActors[i].StopTranslation()
		_kInvisibleActors[i].Delete()
	EndWhile
EndEvent

Event OnEquipmentSaved(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnEquipmentSaved(" + eventName + "," + sender + "," + strArg + "," + numArg + ")")
	If _bPlayerIsSaving && ((sender as Armor) || (sender as Weapon))
		_iInvisibleActorIndex -= 1
		Int iThisIndex = _iInvisibleActorIndex
		;_kInvisibleActors[iThisIndex].TranslateToRef(PlayerREF,999999)
		_kInvisibleActors[iThisIndex].SetAlpha(0,False)
		_kInvisibleActors[iThisIndex].MoveTo(PlayerREF)
		Wait(RandomFloat(0.5,3))
		;MAGDragonPowerAbsorbEffect.Play(PlayerREF,8,_kInvisibleActors[iThisIndex])
		If sender as Weapon && numArg == 2
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].UnequipItemEx(sender,1,True)
			Wait(0.1)
		Else
			_kInvisibleActors[iThisIndex].EquipItem(sender)
		EndIf
		;_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX() + RandomFloat(-100,100),PlayerREF.GetPositionY() + RandomFloat(-100,100),PlayerREF.GetPositionZ() + RandomFloat(0,100),PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),100)
		If (sender as Armor)
			Armor kArmor = sender as Armor
			If kArmor.IsHelmet() || kArmor.IsClothingHead()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() + 30,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			ElseIf kArmor.IsBoots() || kArmor.IsClothingFeet()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() - 30,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			ElseIf kArmor.IsGauntlets() || kArmor.IsClothingHands()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() - 20,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			EndIf
		Else
			_kInvisibleActors[iThisIndex].TranslateToRef(_StatueMarker,30,1)
		EndIf
		Wait(0.1)
		_kInvisibleActors[iThisIndex].SetAlpha(1,True)
		vMYC_BlindingLightGold.Play(_kInvisibleActors[iThisIndex],0.1)
		Wait(RandomFloat(1.0,2.0))
		_kInvisibleActors[iThisIndex].SplineTranslateToRef(_StatueMarker,RandomFloat(350,800),250,10)
		;Wait(5)
		;_kInvisibleActors[iThisIndex].Disable(True)
	EndIf
EndEvent

Event OnPerkSaved(string eventName, string strArg, float numArg, Form sender)
	If _bPlayerIsSaving ;&& (sender as Armor)
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnPerkSaved(" + eventName + "," + sender + ")")
		ObjectReference PerkGlow = PlayerREF.PlaceAtMe(vMYC_PerkGlow,abInitiallyDisabled = True)
		PerkGlow.SetScale(0.5)
		PerkGlow.MoveToNode(PlayerRef,"NPC Head [Head]")
		PerkGlow.SetAngle(RandomInt(-10,10),RandomInt(-10,10),RandomInt(0,359))
		PerkGlow.EnableNoWait(True)
		Wait(0.5)
		;PerkGlow.PlayGamebryoAnimation("animTrans01")
		Wait(1.0)
		PerkGlow.SplineTranslateTo(_StatueMarker.GetPositionX(),_StatueMarker.GetPositionY(),_StatueMarker.GetPositionZ() + 50,RandomFloat(-180,180),RandomFloat(-180,180),RandomFloat(-180,180),RandomFloat(500,800),RandomFloat(350,450))
	EndIf
EndEvent

Event OnSpellSaved(string eventName, string strArg, float numArg, Form sender)
	If _bPlayerIsSaving ;&& (sender as Armor)
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnSpellSaved(" + eventName + "," + sender + ")")
		ObjectReference PerkGlow = PlayerREF.PlaceAtMe(vMYC_PerkGlow,abInitiallyDisabled = True)
		PerkGlow.SetScale(0.5)
		If RandomInt(0,1)
			PerkGlow.MoveToNode(PlayerRef,"NPC L Hand [LHnd]")
		Else
			PerkGlow.MoveToNode(PlayerRef,"NPC R Hand [RHnd]")
		EndIf
;		PerkGlow.MoveTo(PerkGlow,0,0,-20)
		PerkGlow.EnableNoWait(True)
		Wait(1.0)
		PerkGlow.SplineTranslateToRef(_StatueMarker,RandomFloat(500,800),RandomFloat(350,450))
	EndIf
EndEvent

Event OnItemSaved(string eventName, string strArg, float numArg, Form sender)
	If _bPlayerIsSaving ;&& (sender as Armor)
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnItemSaved(" + eventName + "," + sender + ")")
;		ObjectReference PerkGlow = _StatueMarker.PlaceAtMe(sender,abInitiallyDisabled = True)
;		PerkGlow.EnableNoWait(True)
;		Wait(0.1)
;		PerkGlow.SetMotionType(PerkGlow.Motion_Keyframed)
;		PerkGlow.MoveTo(PlayerREF,0,0,50)
;		vMYC_BlindingLightGold.Play(PerkGlow,0.1)
;		PerkGlow.SplineTranslateToRef(_StatueMarker,RandomFloat(500,800),RandomFloat(350,450))
;		Wait(3.0)
;		PerkGlow.StopTranslation()
;		PerkGlow.Delete()
	EndIf
EndEvent

Function SummonCharacter()
{Summon the character from Shrine into Tamriel}
	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": SummonCharacter!")
	GoToState("Busy")
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_Book.IsOpen = True
	;_kCharacter.SetActorValue("Variable10",0)
	Wait(0.5)
	_kCharacter.EnableAI(True)
	Wait(0.5)
	;If RandomInt(0,1)
		;_kCharacter.PlayIdle(IdleSnapToAttention)
	;Else
	;EndIf
	vMYC_ValorFX.Play(_kCharacter,5)
	Wait(0.5)
	_kCharacter.PlayIdle(IdleSilentBow)	
	Wait(0.5)
	DA02SummonValorTargetFX.Play(_kCharacter,8)
	Wait(0.5)
	_kCharacter.SetAlpha(0.01,True)
	Wait(5.0)
	_kCharacter.Disable()
	_kCharacter.SetScale(1.0)
	_kCharacter.SetGhost(False)
	_kCharacter.MoveToMyEditorLocation()
	_kCharacter.EnableNoWait()
	CharacterManager.SetCharacterTracking(CharacterName,True)
	_kCharacter.EvaluatePackage()
	CharacterManager.SetLocalInt(_sCharacterName,"InShrine",0)
	_kCharacter.MoveToPackageLocation()
	Wait(1.0)
	_kCharacter.SetAlpha(1.0)
	SendModEvent("vMYC_ShrineStatusUpdate",3)
	GoToState("Active")
EndFunction

Bool Function WaitFor3DLoad(Form kForm, Int iSafety = 20)
	While !_kCharacter.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction

Function BanishCharacter()
{Banish the character from Tamriel back to the Shrine}
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": BanishCharacter!")
	GoToState("Busy")
	_Book.IsOpen = False
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Disabling character tracking...")
	CharacterManager.SetCharacterTracking(CharacterName,False)
	;_kCharacter.DisableNoWait(False)
	Wait(0.25)
	_kCharacter.SetScale(0.01)
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Moving character to staging area...")
	CharacterManager.SetLocalInt(_sCharacterName,"InShrine",1)
	_kCharacter.MoveTo(_StatueMarker)
	WaitForCharacterReady()
	If WaitFor3DLoad(_kCharacter)
		_kCharacter.SetAlpha(0.01,False)
	EndIf
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Moving character to shrine...")
	_kCharacter.SetGhost(True)
	_kCharacter.SetScale(1.2)
	If WaitFor3DLoad(_kCharacter)
;		_kCharacter.SetAlpha(0.01,False)
		DA02SummonValorTargetFX.Play(_kCharacter,8)
		Wait(1.0)
	EndIf
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Fading in character...")
	_kCharacter.SetAlpha(1.0,True)
	Wait(3.0)
	_kCharacter.PlayIdle(IdleStaticPoseA)
	;_kCharacter.DrawWeapon()
	Wait(0.25)
	Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Freezing character!")
	_kCharacter.EnableAI(False)
	SendModEvent("vMYC_ShrineStatusUpdate",2)
	GoToState("Active")
EndFunction

Function WaitForCharacterReady(Int iSafety = 30)
	_bCharacterReady = False
	RegisterForModEvent("vMYC_CharacterReady","OnCharacterReady")
	While !_bCharacterReady && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
EndFunction

Function UpdateShrine()
	;GotoState("Inactive")
	ShrineLightState = 1
	String sCharacterName = CharacterName
	EraseShrine(abNoLightChange = True)
	Wait(0.1)
	CharacterManager.EraseCharacter(sCharacterName,True)
	;Wait(0.1)
	;CharacterName = ""
;	Wait(0.1)
	SavePlayer(True)
	;GoToState("Active")
EndFunction

Function EraseShrine(Bool abNoLightChange = False)
	If !abNoLightChange
		ShrineLightState = 0
	EndIf
	String sCharacterName = CharacterName
	CharacterName = ""
	;Wait(0.1)
	SendModEvent("vMYC_ForceBookUpdate","",ShrineIndex)
	SendModEvent("vMYC_ShrineStatusUpdate",0)
EndFunction

Function PlayerActivate()
	;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Got PlayerActivate in null state!")
EndFunction

Function InitTrophies()
	Int i = vMYC_TrophyKeywords.GetSize()
	While i > 0
		i -= 1
		vMYC_ShrineTrophyFXScript kTrophy = GetLinkedRef(vMYC_TrophyKeywords.GetAt(i) as Keyword) as vMYC_ShrineTrophyFXScript
		If kTrophy
			kTrophy.ShrineIndex = ShrineIndex
		EndIf
	EndWhile
EndFunction

Function HideTrophies()
	Int i = vMYC_TrophyKeywords.GetSize()
	While i > 0
		i -= 1
		vMYC_ShrineTrophyFXScript kTrophy = GetLinkedRef(vMYC_TrophyKeywords.GetAt(i) as Keyword) as vMYC_ShrineTrophyFXScript
		If kTrophy
			kTrophy.DisableNoWait()
		EndIf
	EndWhile
;		GetLinkedRef(vMYC_ShrineTrophyHero).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyCompanion).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyMage).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyThief).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDBRestored).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDBDestroyed).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyImperial).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyStormcloak).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyBard).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyGreybeard).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyBlade).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyWerewolfSymbol).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyVampireSymbol).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDLC1Vampire).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDLC1Dawnguard).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDLC1Complete).DisableNoWait(True)
;		GetLinkedRef(vMYC_ShrineTrophyDLC2Miraak).DisableNoWait(True)
EndFunction

Function ShowTrophies()
	String[] sSpawnPoints = CharacterManager.GetCharacterSpawnPoints(_sCharacterName)
	;Int i = 0
	;While i < sSpawnPoints.Length
		;;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Spawnpoint[" + i + "] is " + sSpawnPoints[i])
		;sSpawnPoints[i]
		;i += 1
	;EndWhile
	If sSpawnPoints.Find("Hero") > -1
		GetLinkedRef(vMYC_ShrineTrophyHero).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Companion") > -1
		GetLinkedRef(vMYC_ShrineTrophyCompanion).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Mage") > -1
		GetLinkedRef(vMYC_ShrineTrophyMage).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Thief") > -1
		GetLinkedRef(vMYC_ShrineTrophyThief).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DarkBrotherhoodRestored") > -1
		GetLinkedRef(vMYC_ShrineTrophyDBRestored).EnableNoWait()
	ElseIf sSpawnPoints.Find("DarkBrotherhoodDestroyed") > -1
		GetLinkedRef(vMYC_ShrineTrophyDBDestroyed).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Imperial") > -1
		GetLinkedRef(vMYC_ShrineTrophyImperial).EnableNoWait()
	ElseIf sSpawnPoints.Find("Stormcloak") > -1
		GetLinkedRef(vMYC_ShrineTrophyStormcloak).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Bard") > -1
		GetLinkedRef(vMYC_ShrineTrophyBard).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Greybeard") > -1
		GetLinkedRef(vMYC_ShrineTrophyGreybeard).EnableNoWait()
	ElseIf sSpawnPoints.Find("Blade") > -1
		GetLinkedRef(vMYC_ShrineTrophyBlade).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Werewolf") > -1
		GetLinkedRef(vMYC_ShrineTrophyWerewolfSymbol).EnableNoWait()
	ElseIf sSpawnPoints.Find("VampireLord") > -1
		GetLinkedRef(vMYC_ShrineTrophyVampireSymbol).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("VampireFaction") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Vampire).EnableNoWait()
	ElseIf sSpawnPoints.Find("DawnguardFaction") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Dawnguard).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DLC1Completed") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Complete).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DLC2KilledMiraak") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC2Miraak).EnableNoWait()
	EndIf
EndFunction

Event OnCharacterReady(string eventName, string strArg, float numArg, Form sender)
	If strArg == _sCharacterName
		_bCharacterReady = True
	EndIf
	If strArg == _sCharacterName && _bPoseCharacter
		_bPoseCharacter = False
		Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Character reports they are ready!")	
		vMYC_BlindingLightInwardParticles.Play(_kCharacter,0.5)
		;---=== using SendAnimationevent instead of PlayIdle because PlayIdle doesn't actually work off-camera
		Debug.SendAnimationEvent(_kCharacter,"IdleStaticPoseAStart") ;_kCharacter.PlayIdle(IdleStaticPoseA)
		Wait(0.25)
		_kCharacter.SetGhost(True)
		_kCharacter.EnableAI(False)
		;_kCharacter.SheatheWeapon()
		GotoState("Active")
		
		
		;---=== this stuff is for my attempt at making the poses more interesting. Doesn't work reliably because Bethesda. Fix it later
		;If CharacterManager.GetLocalInt(_sCharacterName,"BowEquipped") == 1
			;_kCharacter.SetActorValue("Variable10",2)
		;Else
			;_kCharacter.SetActorValue("Variable10",1)
		;EndIf
		
		;RegisterForAnimationEvent(_kCharacter,"PickNewIdle")
		;RegisterForAnimationEvent(_kCharacter,"IdleStop")
		;Debug.SendAnimationEvent(_kCharacter,"PickNewIdle")
		_kCharacter.EvaluatePackage()
		;ShrineLightState = 2
		;Wait(1.0)
		;RegisterForAnimationEvent(_kCharacter,"PickNewIdle")
		;RegisterForAnimationEvent(_kCharacter,"IdleStop")
		;_bPoseCharacter = True
		;While _bPoseCharacter
			;If _kCharacter.PlayIdle(CombatIdleStretching)
				;_bFreezeCharacter = True
			;EndIf
			;Wait(1.0)
		;EndWhile
	EndIf
EndEvent

Auto State Inactive

	Event OnActivate(ObjectReference akActivatorRef)
		If !_sCharacterName
			;;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Activated but has no character living in it. Aborting!")
			SendModEvent("vMYC_ShrineStatusUpdate",0)
			Return
		EndIf
		If !_FogEmpty
			;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Wants to activate but isn't loaded! Queuing activation for later!")
			_bActivateOnLoad = True
			Return
		EndIf
		GotoState("Busy")
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnActivate(" + akActivatorRef + ")")
		SendModEvent("vMYC_ShrineStatusUpdate",1)
		ShrineLightState = 1
		If !CharacterManager.LoadCharacter(_sCharacterName)
			SendModEvent("vMYC_ShrineStatusUpdate",4)
			While ShrineLightState != 1
				Wait(1.0)
			EndWhile
			ShrineLightState = 0
			Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": " + _sCharacterName + " could not be loaded from CharacterManager.",1)
			CharacterName = ""
			GotoState("Inactive")
			Return
		EndIf
		CharacterManager.SetLocalInt(_sCharacterName,"InShrine",1)
		;Wait(2.0)
		If !_kCharacter
			_kCharacter = CharacterManager.GetCharacterActorByName(_sCharacterName)
		EndIf
		_kCharacter.SetGhost(True)
		_kCharacter.SetScale(1.2)
		Wait(0.01)
		_kCharacter.EnableAI(True)
		Wait(0.01)
		_kCharacter.Moveto(_StatueMarker)
		Wait(0.01)
		_kCharacter.Enable()
		Wait(0.01)
		ShowTrophies()
		_bPoseCharacter = True
		RegisterForModEvent("vMYC_CharacterReady","OnCharacterReady")
		SendModEvent("vMYC_ShrineStatusUpdate",2)
	EndEvent

	Function PlayerActivate()
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Got PlayerActivate in Inactive state!")
	EndFunction
	
EndState

State Active 

	Event OnBeginState()
		ShrineLightState = 2
		JDB.WriteToFile("data/vMYC/jdb.json")
		;Weather.ReleaseOverride()
		SendModEvent("vMYC_ShrineStatusUpdate",2)
	EndEvent

	Event OnActivate(ObjectReference akActivatorRef)
		GotoState("Busy")
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": OnActivate(" + akActivatorRef + ")")
		If _kCharacter
			_kCharacter.DisableNoWait(True)
		EndIf
		GotoState("Inactive")
	EndEvent

	Function PlayerActivate()
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Got PlayerActivate in Active state!")
	EndFunction

EndState

State Busy

	Event OnActivate(ObjectReference akActivatorRef)
	EndEvent

	Function PlayerActivate()
		;Debug.Trace("MYC: " + Self + " Shrine" + _iShrineIndex + ": Got PlayerActivate in busy state!")
	EndFunction

	
EndState