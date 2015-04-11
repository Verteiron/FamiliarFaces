Scriptname vMYC_CompatAFT extends vMYC_CompatBase
{Base for compatibility modules.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_Session

;=== Properties ===--

Message 		Property	NotificationMessage				Auto

;Properties from AFT
Faction			Property 	TweakPotentialFollowerFaction	Auto
Faction 		Property 	TweakIgnoreFaction				Auto
Faction 		Property 	TweakImportFaction				Auto
Faction			Property	TweakDisableMagic				Auto
Quest			Property	TweakFollower					Auto

;=== Variables ===--

;=== Events/Functions ===--

Bool Function IsRequired()
{Return true if the mod that this module supports is installed.}

	Return False
EndFunction

Int Function StartModule()
{User code for startup.}
	RegisterForSingleUpdate(1)
	NotificationMessage.Show()
	Return 1
EndFunction

Int Function StopModule()
{User code for shutdown.}
	UnregisterForUpdate()
	WaitMenuMode(1)
	UpdateAFTSettings(abForceRemove = True)
	Return 1
EndFunction

Int Function UpkeepModule()
{User code for upkeep.}
	RegisterForSingleUpdate(5)
	Return 1
EndFunction

Function CheckVars()
{Any extra variables that might need setting up during OnInit. Will also be run OnGameLoad.}

	TweakPotentialFollowerFaction 	= GetFormFromFile(0x02033cf9,"AmazingFollowerTweaks.esp") as Faction
	TweakIgnoreFaction 				= GetFormFromFile(0x020229c3,"AmazingFollowerTweaks.esp") as Faction
	TweakImportFaction				= GetFormFromFile(0x020362b8,"AmazingFollowerTweaks.esp") as Faction
	TweakDisableMagic				= GetFormFromFile(0x0200eb22,"AmazingFollowerTweaks.esp") as Faction
	
	TweakFollower					= GetFormFromFile(0x020012ce,"AmazingFollowerTweaks.esp") as Quest

EndFunction

Event OnUpdate()
	UpdateAFTSettings()
	If Enabled
		RegisterForSingleUpdate(15)
	EndIf
EndEvent

Function UpdateAFTSettings(Bool abForceRemove = False)
	Int jCIDs = JMap.AllKeys(GetSessionObj("Doppelgangers"))
	Int i = JMap.Count(jCIDs)
	While i > 0
		i -= 1
		String sCID = JArray.GetStr(jCIDs,i)
		If GetSessionBool("Doppelgangers." + sCID + ".Summoned")
			String sCharacterName = GetRegStr("Characters." + sCID + ".Info.Name")
			If !abForceRemove
				Actor kActor = GetSessionForm("Doppelgangers." + sCID + ".Actor") as Actor
				If kActor
					If IsTweakedFollower(kActor) && !HasSessionKey("Doppelgangers." + sCID + ".Actor.Compat.AFT")
						DebugTrace("Adding " + kActor + " (" + sCharacterName + ") to AFT list.")
						SetSessionBool("Doppelgangers." + sCID + ".Compat.AFT.Enabled",True)
						SetSessionBool("Doppelgangers." + sCID + ".Compat.AFT.ForceMagicDisabled",kActor.IsInFaction(TweakDisableMagic))
					ElseIf HasSessionKey("Doppelgangers." + sCID + ".Compat.AFT")
						DebugTrace("Removing " + kActor + " (" + sCharacterName + ") from AFT list.")
						ClearSessionKey("Doppelgangers." + sCID + ".Compat.AFT")
					EndIf
				EndIf
			Else ; Force removal, presumably for uninstall
				DebugTrace("Forcing removal of " + sCharacterName + " from AFT list.")
				ClearSessionKey("Doppelgangers." + sCID + ".Compat.AFT")
			EndIf
		EndIf
	EndWhile
EndFunction

Bool Function IsTweakedFollower(Actor akActor)
	If !Enabled
		Return False
	EndIf
	Int i = akActor.GetNumReferenceAliases()
	While i > 0
		i -= 1
		If akActor.GetNthReferenceAlias(i).GetOwningQuest() == TweakFollower && !akActor.IsInFaction(TweakIgnoreFaction)
			DebugTrace(akActor.GetActorBase().GetName() + " is Tweaked!")
			Return True
		EndIf
	EndWhile
	DebugTrace(akActor.GetActorBase().GetName() + " is NOT Tweaked!")
	Return False
EndFunction

