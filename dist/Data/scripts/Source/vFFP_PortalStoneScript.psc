Scriptname vFFP_PortalStoneScript extends ObjectReference
{Warp player to the Shrine of Heroes.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

;vFFP_HangoutManager Property HangoutManager Auto

Actor Property PlayerRef Auto

Cell Property	vFFP_ShrineOfHeroes	Auto

VisualEffect	Property	vFFP_ValorFX				Auto
VisualEffect	Property	DA02SummonValorTargetFX		Auto

ImageSpaceModifier	Property	FadeToWhiteImod	Auto
ImageSpaceModifier	Property	FadeToWhiteHoldImod	Auto
ImageSpaceModifier	Property	FadeToWhiteBackImod	Auto

;vFFP_ShrinePortalScript	Property	PortalRef					Auto
ObjectReference	Property	COCMarkerRef				Auto

ObjectReference Property vFFP_PortalReturnMarker Auto

FormList	Property	vFFP_LocationAnchorsList	Auto

Message Property vFFP_PortalStoneUseMSG Auto

LocationAlias	Property	kLastPlayerLocation Auto

Bool Property FirstUse = True Auto Hidden

;=== Variables ===--

;=== Events ===--

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
	If PlayerREF.GetParentCell() == vFFP_ShrineOfHeroes
		Debug.Notification("You can't use that. You're already here.")
		Return
	EndIf
	If !FirstUse
		Int iResponse = vFFP_PortalStoneUseMSG.Show()
		;0 = Warp
		;1 = Create Hangout
		;2 = Cancel
		If iResponse == 1
			HangoutManager.CreateHangoutHere(akActor)
			Return
		ElseIf iResponse == 2
			Return
		EndIf
	Else
		HangoutManager.CreateHangoutHere(akActor)
	EndIf

	If akActor == PlayerREF
		FirstUse = False
		DisablePlayerControls(abMovement = false, abFighting = true, abCamSwitch = true, abLooking = false, abSneaking = true, abMenu = true, abActivate = true, abJournalTabs = false)
		ForceThirdPerson()
		Game.SetHudCartMode()
		Wait(0.25)
		vFFP_PortalReturnMarker.MoveTo(PlayerREF)
		vFFP_ValorFX.Play(PlayerREF,3)
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
		vFFP_ValorFX.Play(PlayerREF,4)
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
