Scriptname vMYC_ShrinePortalScript extends ObjectReference  
{Handle portal activation/deactivation effects}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Bool Property IsOpen Hidden 
{0 = Close, 1 = Open}
	Bool Function Get()
		If _bPortalOpen || _bPortalOpening || _bPortalClosing
			Return True
		Else
			Return False
		EndIf
	EndFunction
	Function Set(Bool bPortalOpen)
		If _bPortalOpening || _bPortalClosing
			Return
		EndIf
		_bPortalWantsOpen = bPortalOpen
		RegisterForSingleUpdate(0)
	EndFunction
EndProperty

Int Property PortalState Hidden 
{0 = Closed, 1 = Opening, 2 = Open, 3 = Closing}
	Int Function Get()
		If _bPortalOpening
			Return 1
		ElseIf _bPortalClosing
			Return 3
		ElseIf _bPortalOpen
			Return 2
		Else 
			Return 0
		EndIf
	EndFunction
EndProperty


Actor	Property	PlayerREF	Auto

ImageSpaceModifier	Property	FadeToWhiteImod	Auto
ImageSpaceModifier	Property	FadeToWhiteHoldImod	Auto
ImageSpaceModifier	Property	FadeToWhiteBackImod	Auto

ObjectReference Property PortalFX Auto
ObjectReference Property Seal Auto
ObjectReference Property Water Auto
ObjectReference Property WaterChurn Auto
ObjectReference Property WaterFog Auto
ObjectReference Property PortalStoneStatic Auto
ObjectReference Property PortalReturnMarker Auto
ObjectReference Property PortalTrigger Auto
;Int Property _jMYC Auto

Sound Property QSTSovengardePortalOn2DLPM auto
Sound Property QSTSovengardePortalOnMonoLPM auto
Sound Property QSTSovengardePortalOpen auto
Sound Property QSTSovengardePortalClose auto

VisualEffect	Property	vMYC_ValorFX				Auto

;--=== Config variables ===--

;--=== Variables ===--

Bool	_bPortalWantsOpen

Bool 	_bPortalOpen
Bool 	_bPortalOpening
Bool 	_bPortalClosing
Bool	_bPortalBusy

Float 	_fWaterZ
Float 	_fWaterFogZ

Int		_iPortalSound1
Int		_iPortalSound2
;--=== Events ===--

Event OnInit()
	_fWaterZ = Water.GetPositionZ()
	_fWaterFogZ = WaterFog.GetPositionZ()
EndEvent

Event OnLoad()
	Wait(1)
	IsOpen = False
EndEvent

Event OnCellAttach()

EndEvent

Event OnActivate(ObjectReference akTriggerRef)
	DisablePlayerControls(abMovement = True, abFighting = true, abCamSwitch = true, abLooking = false, abSneaking = true, abMenu = true, abActivate = true, abJournalTabs = false)
	PortalOpen()
	Wait(2.5)
	FadeToWhiteImod.Apply()
	PlayerREF.SetAlpha(0.01,True)
	Wait(2.75)
	PlayerREF.MoveTo(PortalReturnMarker)
	FadeToWhiteImod.PopTo(FadeToWhiteHoldImod)
	vMYC_ValorFX.Play(PlayerREF,4)
	Wait(1.5)
	FadeToWhiteHoldImod.PopTo(FadeToWhiteBackImod)
	EnablePlayerControls()
	PlayerREF.SetAlpha(1.0,True)
	PortalClose()
EndEvent

Event OnUpdate()
	If _bPortalWantsOpen && !_bPortalOpen
		PortalOpen()
	ElseIf !_bPortalWantsOpen && _bPortalOpen
		PortalClose()
	EndIf
EndEvent

;--=== Functions ===--

Function PortalOpen(Bool abQuickOpen = False)
	While _bPortalBusy
		Wait(0.5)
	EndWhile
	If _bPortalOpening || _bPortalOpen
		Return
	EndIf
	_bPortalBusy = True
	_bPortalOpening = True
	Debug.Trace("MYC/ShrinePortalScript: Moving water...")
	If abQuickOpen
		Water.SetPosition(Water.X,Water.Y,_fWaterZ - 1000)
	Else
		WaterChurn.SetScale(2.5)
		WaterChurn.SetPosition(WaterChurn.X,WaterChurn.Y,_fWaterZ - 300)
		WaterChurn.Enable()
		QSTSovengardePortalOpen.Play(Seal)
		WaterChurn.TranslateTo(WaterChurn.X,WaterChurn.Y,_fWaterZ + 40,0,0,0,10)
		Wait(1.0)
	EndIf
	Debug.Trace("MYC/ShrinePortalScript: Disabling PortalStoneStatic...")
	PortalStoneStatic.DisableNoWait(True)
	Debug.Trace("MYC/ShrinePortalScript: PlayAnim02")
	PortalFX.PlayAnimation("PlayAnim02")
	If abQuickOpen
		Seal.PlayAnimation("StartOpen")
	Else
		Int iTimer = 10
		While !Seal.Is3DLoaded() && iTimer > 0
			iTimer -= 1
			Wait(0.1)
		EndWhile
		Seal.PlayAnimation("Open")
		WaterChurn.TranslateTo(WaterChurn.X,WaterChurn.Y,_fWaterZ + 40,0,0,0,70)
	EndIf
	Debug.Trace("MYC/ShrinePortalScript: Play sound fx...")
	_iPortalSound1 = QSTSovengardePortalOn2DLPM.Play(Seal)
	_iPortalSound2 = QSTSovengardePortalOnMonoLPM.Play(Seal)
	If abQuickOpen
		WaterChurn.SetPosition(WaterChurn.X,WaterChurn.Y,_fWaterZ - 1000)
	Else
		Wait(1.0)
		Water.TranslateTo(Water.X,Water.Y,_fWaterZ - 1000,Water.GetAngleX(),Water.GetAngleY(),Water.GetAngleZ(),250)	
		WaterChurn.TranslateTo(WaterChurn.X,WaterChurn.Y,_fWaterZ - 1000,0,0,0,250)
	EndIf
	WaterFog.DisableNoWait(True)
	_bPortalOpen = True
	_bPortalOpening = False
	_bPortalBusy = False
EndFunction

Function PortalClose()
	While _bPortalBusy
		Wait(0.5)
	EndWhile
	If _bPortalClosing || !_bPortalOpen
		Return
	EndIf
	_bPortalBusy = True
	_bPortalClosing = True
	PortalTrigger.DisableNoWait()
	WaterFog.SetPosition(WaterFog.X,WaterFog.Y,WaterFog.Z - 200)
	WaterFog.EnableNoWait(True)
	WaterChurn.SetScale(2.5)
	WaterChurn.EnableNoWait()
	WaterChurn.SetPosition(WaterChurn.X,WaterChurn.Y,_fWaterZ - 200)
	Int iTimer = 20
	While !Seal.Is3DLoaded() && iTimer > 0
		iTimer -= 1
		Wait(0.1)
	EndWhile
	PortalFX.PlayAnimation("PlayAnim01")
	Seal.PlayAnimation("Close")
	QSTSovengardePortalClose.Play(Seal)
	Sound.StopInstance(_iPortalSound1)
	Sound.StopInstance(_iPortalSound2)
	If Is3DLoaded()
		Water.TranslateTo(Water.X,Water.Y,_fWaterZ,Water.GetAngleX(),Water.GetAngleY(),Water.GetAngleZ(),215)
	Else
		Water.SetPosition(Water.X,Water.Y,_fWaterZ)
	EndIf
	Wait(4.2)
	_bPortalClosing = False
	_bPortalOpen = False
	WaterChurn.Disable(True)	
	WaterChurn.SetPosition(WaterChurn.X,WaterChurn.Y,_fWaterZ)
	If Is3DLoaded()
		WaterFog.TranslateTo(WaterFog.X,WaterFog.Y,WaterFog.Z + 200,0,0,0,5)
	Else
		WaterFog.SetPosition(WaterFog.X,WaterFog.Y,WaterFog.Z + 200)
	EndIf
	PortalStoneStatic.EnableNoWait(True)
	PortalTrigger.EnableNoWait()
	_bPortalBusy = False
EndFunction
