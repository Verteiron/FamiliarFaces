Scriptname vFFP_AlcoveController extends ObjectReference
{Handle alcove data and appearance.}

; === [ vFFP_AlcoveController.psc ] =======================================---
; Handles:
;   Alcove statue placement
;   Commanding AlcoveLightingController
;   Special effects for character saving and statue appearing
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry
Import vFF_PlacementUtils

;=== Constants ===--  

;=== Properties ===--

Activator						Property	vFFP_AlcoveLightingControllerActivator	Auto
Activator						Property	vFFP_AlcoveStatueMarker					Auto

vFFC_DataManager				Property 	DataManager								Auto

vFFP_AlcoveLightingController	Property	LightingController						Auto Hidden
vFFP_ShrineManager				Property	ShrineManager							Auto Hidden
vFFP_TrophyManager				Property	TrophyManager							Auto

Actor							Property	PlayerREF								Auto

EffectShader					Property	vFFP_BlindingLightInwardParticles		Auto

Int								Property 	AlcoveIndex 							Auto

ActorBase						Property	AlcoveActorBase							Auto Hidden
Actor							Property	AlcoveActor								Auto Hidden

String							Property	AlcoveCharacterID						Auto Hidden

ObjectReference					Property	AlcoveStatueMarker						Auto

Sound							Property	vFFP_AlcoveStatueHarmonicLPSM			Auto
Sound							Property	vFFP_AlcoveStatueAppearLPSM				Auto
Sound							Property	QSTMG07MagnusStormCollegeMediumLPM		Auto
Sound							Property	QSTMG07MagnusStormCollegeMediumRelease	Auto

Activator						Property	vFFP_CharacterGlow						Auto

Bool 							Property	DisplayTrophiesOnLoad					Auto Hidden

;=== Variables ===--

String _sFormID

;=== Events and Functions ===--

Function CheckVars()
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	CheckObjects()
	If DisplayTrophiesOnLoad
		DisplayTrophiesOnLoad = False
		TrophyManager.DisplayTrophies(AlcoveStatueMarker,AlcoveCharacterID,False)
	EndIf
EndFunction

Event OnInit()
	DebugTrace("OnInit!")
	CheckVars()
	RegisterForModEvents()
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
	CheckVars()
	RegisterForSingleUpdate(2)
EndEvent

Event OnCellAttach()
	DebugTrace("OnCellAttach!")
	RegisterForSingleUpdate(2)
EndEvent

Event OnUpdate()
	CheckObjects()
	If Is3DLoaded()
		RegisterForSingleUpdate(10)
	Else
		DebugTrace("Unloaded, halting validation loop.")
	EndIf
EndEvent

Event OnShrineManagerReady(Form akSender)
{Event sent by ShrineManager when it's ready for Alcoves to register themselves.}
	If !ShrineManager && akSender as vFFP_ShrineManager
		ShrineManager = akSender as vFFP_ShrineManager
		;DebugTrace("I am " + Self + ", registry reports Shrine.Alcove" + AlcoveIndex + ".UUID is " + GetRegStr("Shrine.Alcove" + AlcoveIndex + ".UUID") + "!")
		If GetRegForm("Shrine.Alcove" + AlcoveIndex + ".Form") != Self
			DebugTrace("Not present in the registry, registering for the first time...")
			SendRegisterEvent()
		Else
			DebugTrace("Already registered at index " + GetRegInt("Shrine.Alcove" + AlcoveIndex + ".Index") + "!")
			SendSyncEvent()
		EndIf
		If !DataManager
			DataManager = ShrineManager.DataManager
		EndIf
	EndIf
EndEvent

Function SendRegisterEvent()
{Send vFF_AlcoveRegister event.}
	Int iHandle = ModEvent.Create("vFF_AlcoveRegister")
	If iHandle
		ModEvent.PushInt(iHandle,AlcoveIndex)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vFF_AlcoveRegister!",1)
	EndIf
	
EndFunction

Function SendSyncEvent()
{Send vFF_AlcoveSync event.}
	Int iHandle = ModEvent.Create("vFF_AlcoveSync")
	If iHandle
		ModEvent.PushInt(iHandle,AlcoveIndex)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vFF_AlcoveSync!",1)
	EndIf
EndFunction

Function RegisterForModEvents()
	RegisterForModEvent("vFF_ShrineManagerReady","OnShrineManagerReady")
EndFunction

Function CheckObjects()
{Make sure all objects we need are assigned to the right variables.}
	If !LightingController || !AlcoveStatueMarker
		FindObjects()
	EndIf
	vFFP_CharacterMannequin kStatueScript = AlcoveActor as vFFP_CharacterMannequin
	If kStatueScript
		If kStatueScript.IsAIEnabled()
			;kStatueScript.EnableAI(False)
		EndIf
	EndIf
EndFunction

Function FindObjects()
{Find and assign the objects we control to the right variables.}
	;LightingController = FindClosestReferenceOfTypeFromRef(vFFP_AlcoveLightingControllerActivator,Self,1500) as vFF_AlcoveLightingController
	LightingController = GetLinkedRef(Keyword.GetKeyword("vFF_LightingControllerKW")) as vFFP_AlcoveLightingController
	;AlcoveStatueMarker = FindClosestReferenceOfTypeFromRef(vFFP_AlcoveStatueMarker,Self,1500)
	AlcoveStatueMarker = GetLinkedRef(Keyword.GetKeyword("vFFP_AlcoveStatueMarkerKW")) 
	DebugTrace("LightingController is " + LightingController + "!")
	DebugTrace("AlcoveStatueMarker is " + AlcoveStatueMarker + "!")
EndFunction


Function CheckForCharacterActor()
{Make sure that if we have been assigned a character, that the actor statue is present and set up correctly.}
	While !TrophyManager.ReadyToDisplay
		Wait(2)
	EndWhile
	If !AlcoveActor && AlcoveCharacterID
		If Is3DLoaded()
			ShowCharacterStatue(True)
		Else
			ShowCharacterStatue(False)
		EndIf
	EndIf
	;Wait(15)
	;TrophyManager.DeleteTrophies(AlcoveStatueMarker)
EndFunction
	
Function ShowCharacterStatue(Bool abFullEffects = True)
{Place the character statue, tell it to set itself up, and play special effects.}
	DebugTrace("ShowCharacterStatue(abFullEffects = " + abFullEffects + ")")
	Int iStatueSound
	If abFullEffects
		iStatueSound = vFFP_AlcoveStatueAppearLPSM.Play(AlcoveStatueMarker)
	EndIf
	LightingController.DesiredLightState = 1
	DebugTrace("AlcoveActor not found! We should create one!")
	Int iSex = GetRegInt("Characters." + AlcoveCharacterID + ".Info.Sex")
	If iSex ;Female
		AlcoveActor = GetLinkedRef(Keyword.GetKeyword("vFFP_AlcoveStatueF")) as Actor
	Else ;Male
		AlcoveActor = GetLinkedRef(Keyword.GetKeyword("vFFP_AlcoveStatueM")) as Actor
	EndIf
	
	;Int iAlcoveSound = QSTMG07MagnusStormCollegeMediumLPM.Play(Self)		
	
	AlcoveActor.MoveTo(AlcoveStatueMarker)
	AlcoveActorBase = AlcoveActor.GetActorBase()
	vFFP_CharacterMannequin kStatueScript = AlcoveActor as vFFP_CharacterMannequin

	
	Int i = 0
	
	Float fMultX
	Float fMultY
	Int iHarmonicSound
	ObjectReference kGlowSuper
	ObjectReference[] kGlows
	
	If abFullEffects
		fMultX = Math.sin(AlcoveStatueMarker.GetAngleZ())
		fMultY = -Math.cos(AlcoveStatueMarker.GetAngleZ())
		
		iHarmonicSound = vFFP_AlcoveStatueHarmonicLPSM.Play(Self)
		
		kGlowSuper = AlcoveStatueMarker.PlaceAtMe(vFFP_CharacterGlow,AbInitiallyDisabled = True)
		kGlowSuper.SetScale(10)
		kGlowSuper.MoveTo(AlcoveStatueMarker,fMultX * -80, fMultY * -80, 100)
		kGlows = New ObjectReference[8]
		
		While i < kGlows.Length
			kGlows[i] = AlcoveStatueMarker.PlaceAtMe(vFFP_CharacterGlow,AbInitiallyDisabled = True)
			If i % 2
				kGlows[i].MoveTo(AlcoveStatueMarker,fMultX * -25,fMultY * -25,130 - (i*12))
			Else
				kGlows[i].MoveTo(AlcoveStatueMarker,fMultX * -25,fMultY * -25,100 - (i*6))
			EndIf
			kGlows[i].SetScale(0.1 * i)
			kGlows[i].EnableNoWait(True)
			i += 1
		EndWhile
	EndIf
	
	kStatueScript.AssignCharacter(AlcoveCharacterID)	
	kStatueScript.EnableNoWait(True)
	
	If abFullEffects
		TrophyManager.PlaceTrophies(AlcoveStatueMarker,AlcoveCharacterID)
	Else
		DisplayTrophiesOnLoad = True
		LightingController.AlcoveLightState = 2
	EndIf
	
	If abFullEffects
		While !kStatueScript.Is3DLoaded()
			Wait(0.1)
		EndWhile
		kStatueScript.SetAlpha(0.01,False)
		vFFP_BlindingLightInwardParticles.Play(AlcoveActor,1)
		While kStatueScript.NeedAppearance && kStatueScript.NeedEquipment
			DebugTrace("Waiting for statue to be ready...")
			Wait(0.5)
		EndWhile
		LightingController.DesiredLightState = 2
		kGlowSuper.EnableNoWait(False)
		kStatueScript.SetAlpha(1,True)
		;kStatueScript.EnableAI(False)
		If iStatueSound
			Sound.StopInstance(iStatueSound)
			iStatueSound = 0
		EndIf
		i = kGlows.Length
		While i > 0
			i -= 1
			kGlows[i].DisableNoWait(True)
			;Wait(0.88)
		EndWhile
		TrophyManager.SendDisplayAllEvent(AlcoveStatueMarker)
		kGlowSuper.DisableNoWait(True)
		If iHarmonicSound
			Sound.StopInstance(iHarmonicSound)
			iHarmonicSound = 0
		EndIf
	EndIf

EndFunction
;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/AlcoveController/" + _sFormID + ": " + sDebugString,iSeverity)
	;FFUtils.TraceConsole(sDebugString)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
{Wait for kObjectRef to load, timing out after iSafety/10 seconds.
 Returns: True when object loads, or false if it timed out without loading.}
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction
