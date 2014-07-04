Scriptname vMYC_PortalStoneScript extends ObjectReference
{Warp player to the Shrine of Heroes}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor Property PlayerRef Auto

Cell Property	vMYC_ShrineOfHeroes	Auto

VisualEffect	Property	vMYC_ValorFX				Auto
VisualEffect	Property	DA02SummonValorTargetFX		Auto

ImageSpaceModifier	Property	FadeToWhiteImod	Auto
ImageSpaceModifier	Property	FadeToWhiteHoldImod	Auto
ImageSpaceModifier	Property	FadeToWhiteBackImod	Auto

vMYC_ShrinePortalScript	Property	PortalRef					Auto
ObjectReference	Property	COCMarkerRef				Auto

ObjectReference Property vMYC_PortalReturnMarker Auto

FormList	Property	vMYC_LocationAnchorsList	Auto

Message Property vRDN_EndCombatMSG Auto

LocationAlias	Property	kLastPlayerLocation Auto

;--=== Variables ===--

;--=== Events ===--

Event OnInit()

EndEvent

Event OnLoad()
	;Debug.Trace("MYC/PortalStoneScript: PortalStone Loaded.")
EndEvent

Event OnUnload()
	;Debug.Trace("MYC/PortalStoneScript: PortalStone Unloaded.")
EndEvent

Event OnActivate(ObjectReference akActionRef)
	;Debug.Trace("MYC/PortalStoneScript: PortalStone activated by " + akActionRef)
EndEvent

Event OnEquipped(Actor akActor)
	;Debug.Trace("MYC/PortalStoneScript: PortalStone equipped by " + akActor)
	If PlayerREF.GetParentCell() == vMYC_ShrineOfHeroes
		Debug.Notification("You can't use that. You're already here.")
		Return
	EndIf
	Int iEventHandle = ModEvent.Create("vMYC_SetCustomLocation")
	If iEventHandle
		ModEvent.PushForm(iEventHandle,Self)

		String sLocationName
		If PlayerREF.GetCurrentLocation()
			sLocationName = PlayerREF.GetCurrentLocation().GetName()
		EndIf
		If !sLocationName
			sLocationName = PlayerREF.GetParentCell().GetName()
		EndIf
		If !sLocationName || sLocationName == "Wilderness"
			sLocationName = PlayerREF.GetActorBase().GetName() + "'s last location"
		EndIf
		ModEvent.PushString(iEventHandle,sLocationName)
		ModEvent.PushForm(iEventHandle,PlayerREF.GetCurrentLocation())
		ModEvent.PushForm(iEventHandle,PlayerREF.GetParentCell())
		Int i = 1
		While i < 6 ; Send 5 objects found within increasing range as 'anchors' to ensure that we can find SOMETHING to MoveTo when loading this location later
			ModEvent.PushForm(iEventHandle,Game.FindRandomReferenceOfAnyTypeInListFromRef(vMYC_LocationAnchorsList, PlayerREF, 2048 * i))
			i += 1
		EndWhile
		ModEvent.PushFloat(iEventHandle,PlayerREF.GetPositionX())
		ModEvent.PushFloat(iEventHandle,PlayerREF.GetPositionY())
		ModEvent.PushFloat(iEventHandle,PlayerREF.GetPositionZ())
		If ModEvent.Send(iEventHandle)
			;Debug.Trace("MYC/PortalStoneScript: Sent custom location data!")
		Else
			Debug.Trace("MYC/PortalStoneScript: WARNING, could not send custom location data!",1)
		EndIf
	EndIf

	If akActor == PlayerREF
		DisablePlayerControls(abMovement = false, abFighting = true, abCamSwitch = true, abLooking = false, abSneaking = true, abMenu = true, abActivate = true, abJournalTabs = false)
		ForceThirdPerson()
		Game.SetHudCartMode()
		Wait(0.25)
		vMYC_PortalReturnMarker.MoveTo(PlayerREF)
		vMYC_ValorFX.Play(PlayerREF,3)
		Wait(1.0)
		FadeToWhiteImod.Apply() ; Peaks at 2.5 seconds
		DA02SummonValorTargetFX.Play(PlayerREF,8)
		Wait(0.5)
		PlayerREF.SetAlpha(0.01,True)
		Wait(2.0)
		;Debug.Trace("MYC/PortalStoneScript: Moving player to COCMarker...")
		PlayerREF.MoveTo(COCMarkerRef)
		;Debug.Trace("MYC/PortalStoneScript: Moved player to COCMarker!")
		Wait(0.01)
		;Debug.Trace("MYC/PortalStoneScript: Popping to white")
		FadeToWhiteImod.PopTo(FadeToWhiteHoldImod)
		DisablePlayerControls(abMovement = True, abFighting = true, abCamSwitch = true, abLooking = false, abSneaking = true, abMenu = true, abActivate = true, abJournalTabs = false)
		Wait(0.01)
		;Debug.Trace("MYC/PortalStoneScript: Opening Portal...")
		PortalRef.PortalOpen(True) ; true = quickopen
		;Debug.Trace("MYC/PortalStoneScript: Disabling controls...")
		vMYC_ValorFX.Play(PlayerREF,4)
		Wait(0.5)
		;Debug.Trace("MYC/PortalStoneScript: PortalRef.PortalState is " + PortalRef.PortalState)
		While PortalRef.PortalState != 0 && PortalRef.PortalState != 3 ; Portal is neither closed nor closing, keep looping until it is
			;Debug.Trace("MYC/PortalStoneScript: PortalRef.PortalState is " + PortalRef.PortalState + ", waiting for portal to response to close command...")
			PortalRef.IsOpen = False
			Wait(1.0)
		EndWhile
		FadeToWhiteHoldImod.PopTo(FadeToWhiteBackImod)
		PlayerREF.SetAlpha(1.0,True)
		Wait(2.0)
		Game.SetHudCartMode(False)
		EnablePlayerControls()
		Return
	EndIf

EndEvent
