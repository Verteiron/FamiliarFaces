Scriptname vMYC_AlcoveController extends ObjectReference
{Handle alcove data and appearance.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_PlacementUtils

;=== Constants ===--  

;=== Properties ===--

Activator						Property	vMYC_AlcoveLightingControllerActivator	Auto
Activator						Property	vMYC_AlcoveStatueMarker					Auto

vMYC_AlcoveLightingController	Property	LightingController						Auto Hidden
vMYC_ShrineManager				Property	ShrineManager							Auto Hidden
vMYC_DataManager				Property 	DataManager								Auto

Actor							Property	PlayerREF								Auto

EffectShader					Property	vMYC_BlindingLightInwardParticles		Auto

Int								Property 	AlcoveIndex 							Auto

ActorBase						Property	AlcoveActorBase							Auto Hidden
Actor							Property	AlcoveActor								Auto Hidden

String							Property	AlcoveCharacterID						Auto Hidden

ObjectReference					Property	AlcoveStatueMarker						Auto

Form							Property	vMYC_CharacterGlow							Auto
;=== Variables ===--

String _sFormID

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
	RegisterForModEvents()
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
	CheckVars()
EndEvent

Event OnCellAttach()
	DebugTrace("OnCellAttach!")
	CheckObjects()
EndEvent

Event OnShrineManagerReady(Form akSender)
	If !ShrineManager && akSender as vMYC_ShrineManager
		ShrineManager = akSender as vMYC_ShrineManager
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
	Int iHandle = ModEvent.Create("vMYC_AlcoveRegister")
	If iHandle
		ModEvent.PushInt(iHandle,AlcoveIndex)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vMYC_AlcoveRegister!",1)
	EndIf
EndFunction

Function SendSyncEvent()
	Int iHandle = ModEvent.Create("vMYC_AlcoveSync")
	If iHandle
		ModEvent.PushInt(iHandle,AlcoveIndex)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vMYC_AlcoveSync!",1)
	EndIf
EndFunction

Function RegisterForModEvents()
	RegisterForModEvent("vMYC_ShrineManagerReady","OnShrineManagerReady")
EndFunction

Function CheckObjects()
	If !LightingController || !AlcoveStatueMarker
		FindObjects()
	EndIf
EndFunction

Function FindObjects()
	LightingController = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveLightingControllerActivator,Self,1500) as vMYC_AlcoveLightingController
	AlcoveStatueMarker = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveStatueMarker,Self,1500)
	DebugTrace("LightingController is " + LightingController + "!")
	DebugTrace("AlcoveStatueMarker is " + AlcoveStatueMarker + "!")
EndFunction


Function CheckForCharacterActor()
	If !AlcoveActor
		LightingController.DesiredLightState = 2
		DebugTrace("AlcoveActor not found! We should create one!")
		Int iSex = GetRegInt("Characters." + AlcoveCharacterID + ".Info.Sex")
		If iSex ;Female
			AlcoveActor = GetLinkedRef(Keyword.GetKeyword("vMYC_AlcoveStatueF")) as Actor
		Else ;Male
			AlcoveActor = GetLinkedRef(Keyword.GetKeyword("vMYC_AlcoveStatueM")) as Actor
		EndIf
		
		
		AlcoveActor.MoveTo(AlcoveStatueMarker)
		AlcoveActorBase = AlcoveActor.GetActorBase()
		vMYC_CharacterMannequin kStatueScript = AlcoveActor as vMYC_CharacterMannequin

		Float fMultX = Math.sin(AlcoveStatueMarker.GetAngleZ())
		Float fMultY = -Math.cos(AlcoveStatueMarker.GetAngleZ())
		
		ObjectReference[] kGlows = New ObjectReference[8]
		Int i = 0
		While i < kGlows.Length
			kGlows[i] = AlcoveStatueMarker.PlaceAtMe(vMYC_CharacterGlow,AbInitiallyDisabled = True)
			kGlows[i].MoveTo(AlcoveStatueMarker,fMultX * -25,fMultY * -25,100 - (i*2.5))
			;kGlows[i].SetAngle(0,0,AlcoveStatueMarker.GetAngleZ())
			kGlows[i].SetScale(0.1 * i)
			kGlows[i].EnableNoWait(True)
			i += 1
		EndWhile

		kStatueScript.AssignCharacter(AlcoveCharacterID)	
		kStatueScript.EnableNoWait(True)

		While !kStatueScript.Is3DLoaded()
			Wait(0.1)
		EndWhile
		kStatueScript.SetAlpha(0.01,False)
		vMYC_BlindingLightInwardParticles.Play(AlcoveActor,1)
		Wait(1)
		kStatueScript.SetAlpha(1,True)
		kStatueScript.EnableAI(False)
		i = kGlows.Length
		While i > 0
			i -= 1
			kGlows[i].DisableNoWait(True)
			Wait(0.88)
		EndWhile
	EndIf
EndFunction
	
;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/AlcoveController/" + _sFormID + ": " + sDebugString,iSeverity)
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
