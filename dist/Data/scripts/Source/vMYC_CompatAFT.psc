Scriptname vMYC_CompatAFT extends Quest  
{Module for AFT compatibility. Mostly disables FF functionality to avoid conflict, since AFT doesn't appear to provide a method to enable/disable its features.}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

vMYC_CharacterManagerScript Property CharacterManager Auto

GlobalVariable	Property	vMYC_Compat_AFT_Enable		Auto
GlobalVariable	Property	vMYC_Compat_AFT_Loaded		Auto

Message 		Property	vMYC_zCompat_AFT_EnabledMSG	Auto

;Properties from AFT
Faction			Property 	TweakPotentialFollowerFaction	Auto
Faction 		Property 	TweakIgnoreFaction				Auto
Faction 		Property 	TweakImportFaction				Auto
Faction			Property	TweakDisableMagic				Auto
Quest			Property	TweakFollower					Auto

;--=== Variables ===--

;--=== Events/Functions ===--

Event OnGameReloaded()
	If IsRunning()
		CheckVars()
		RegisterForSingleUpdate(5)
	EndIf
EndEvent

Event OnInit()
	If IsRunning()
		Debug.Trace("MYC/CompatAFT: Initializing!")
		DoInit()
		RegisterForSingleUpdate(1)
		vMYC_zCompat_AFT_EnabledMSG.Show()
	EndIf
EndEvent

Event OnUpdate()
	String[] sCharacterNames = CharacterManager.CharacterNames
	Int i = sCharacterNames.Length
	While i > 0
		i -= 1
		If sCharacterNames[i]
			If CharacterManager.GetLocalInt(sCharacterNames[i],"IsSummoned")
				Actor kActor = CharacterManager.GetCharacterActorByName(sCharacterNames[i])
				If kActor
					If IsTweakedFollower(kActor)
						CharacterManager.SetLocalInt(sCharacterNames[i],"Compat_AFT_Tweaked",1)
						CharacterManager.SetLocalInt(sCharacterNames[i],"Compat_AFT_MagicDisabled",kActor.IsInFaction(TweakDisableMagic) as Int)
					Else
						CharacterManager.SetLocalInt(sCharacterNames[i],"Compat_AFT_Tweaked",0)
					EndIf
				EndIf
			EndIf
		EndIf
	EndWhile
	If IsRunning()
		RegisterForSingleUpdate(15)
	EndIf
EndEvent

Bool Function IsTweakedFollower(Actor akActor)
	If !IsRunning()
		Return False
	EndIf
	Int i = akActor.GetNumReferenceAliases()
	While i > 0
		i -= 1
		If akActor.GetNthReferenceAlias(i).GetOwningQuest() == TweakFollower && !akActor.IsInFaction(TweakIgnoreFaction)
	;If (akActor.IsInFaction(TweakPotentialFollowerFaction) || akActor.IsInFaction(TweakImportFaction)) ;&& akActor.IsInFaction(TweakIgnoreFaction) == -2
			Debug.Trace("MYC/CompatAFT: " + akActor.GetActorBase().GetName() + " is Tweaked!")
			Return True
		EndIf
	EndWhile
	Debug.Trace("MYC/CompatAFT: " + akActor.GetActorBase().GetName() + " is NOT Tweaked!")
	Return False
EndFunction

Function DoInit()
	CheckVars()
EndFunction

Function CheckVars()
	TweakPotentialFollowerFaction 	= GetFormFromFile(0x02033cf9,"AmazingFollowerTweaks.esp") as Faction
	TweakIgnoreFaction 				= GetFormFromFile(0x020229c3,"AmazingFollowerTweaks.esp") as Faction
	TweakImportFaction				= GetFormFromFile(0x020362b8,"AmazingFollowerTweaks.esp") as Faction
	TweakDisableMagic				= GetFormFromFile(0x0200eb22,"AmazingFollowerTweaks.esp") as Faction
	
	TweakFollower					= GetFormFromFile(0x020012ce,"AmazingFollowerTweaks.esp") as Quest
EndFunction

Function DoShutdown()
	UnregisterForUpdate()
	String[] sCharacterNames = CharacterManager.CharacterNames
	Int i = sCharacterNames.Length
	While i > 0
		i -= 1
		If sCharacterNames[i]
			Actor kActor = CharacterManager.GetCharacterActorByName(sCharacterNames[i])
			If kActor
				CharacterManager.SetLocalInt(sCharacterNames[i],"Compat_AFT_Tweaked",0)
				CharacterManager.SetLocalInt(sCharacterNames[i],"Compat_AFT_MagicDisabled",0)
			EndIf
		EndIf
	EndWhile
	
EndFunction
