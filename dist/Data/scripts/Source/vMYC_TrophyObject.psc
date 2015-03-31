Scriptname vMYC_TrophyObject extends ObjectReference
{Object that acts as a base point for a trophy.}

; === [ vMYC_TrophyObject.psc ] ===============================================---
; Special ObjectReference that positions and enables a Trophy form when it 
; receives the right ModEvent. 
; Handles:
;  Placement and display of individual Trophy forms
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import Math
Import vMYC_PlacementUtils

;=== Constants ===--

;=== Properties ===--
EffectShader	Property	TrophyFadeInFXS		= None		Auto
{Shader that should play when the trophy first appears.}

Activator		Property	vMYC_BrightGlow					Auto 
{Glowy!.}

Form			Property	TrophyForm			= None		Auto Hidden
ObjectReference	Property	TrophyObject		= None		Auto Hidden

;The following are used to place the object in absolute terms if a preset position is not being used. The origin is the base of the player statue
Float			Property	BaseX					= 0.0		Auto Hidden
Float			Property	BaseY					= 0.0		Auto Hidden
Float			Property	BaseZ					= 0.0		Auto Hidden

Float			Property	AngleX					= 0.0		Auto Hidden
Float			Property	AngleY					= 0.0		Auto Hidden
Float			Property	AngleZ					= 0.0		Auto Hidden
Float			Property	Scale					= 1.0		Auto Hidden

;The following are used to place the object relative to its "base", that is the origin of its position
Float			Property	FormX					= 0.0		Auto Hidden
Float			Property	FormY					= 0.0		Auto Hidden
Float			Property	FormZ					= 0.0		Auto Hidden
Float			Property	FormAngleX				= 0.0		Auto Hidden
Float			Property	FormAngleY				= 0.0		Auto Hidden
Float			Property	FormAngleZ				= 0.0		Auto Hidden
Float			Property	FormScale				= 1.0		Auto Hidden

String			Property	TrophyName					Auto Hidden
Int				Property	TrophyIndex					Auto Hidden

ObjectReference	Property	TrophyOrigin				Auto Hidden

Activator 		Property	vMYC_TrophyEmptyBase		Auto
{Base Activator to be placed as a base object if none other is defined.}

Activator 		Property	vMYC_TrophyObjectBase		Auto
{Base Activator to be placed as a base object if none other is defined.}

vMYC_TrophyBase Property	TrophyBase					Auto

Bool			Property	LocalRotation				Auto

Bool			Property	OnLoadQueued				Auto
ObjectReference Property	OnLoadTarget				Auto

Sound			Property	vMYC_TrophyAppearSM			Auto

;=== Variables ===--

Int					_TrophyVersion

ObjectReference[]	_DisplayedObjects

ObjectReference[]	_TemplateObjects

;=== Events/Functions ===--

Event OnInit()
	If !vMYC_TrophyEmptyBase
		vMYC_TrophyEmptyBase = GetFormFromFile(0x0203055F,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	If !vMYC_TrophyObjectBase
		vMYC_TrophyObjectBase = GetFormFromFile(0x02033E5C,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	RegisterForModEvents()
EndEvent

Event OnCellAttach()
	If OnLoadQueued
		OnLoadQueued = False
		OnTrophyDisplay(OnLoadTarget, False)
	EndIf
EndEvent

Function RegisterForModEvents()
	;RegisterForModEvent("vMYC_TrophyDisplayObject","OnTrophyDisplayObject")
EndFunction

Function UpdatePosition()
	MoveTo(TrophyOrigin,BaseX + FormX,BaseY + FormY,BaseZ + FormZ)
	;No use in SetAngle since angles don't get updated in unloaded cells
	;SetAngle(AngleX,AngleY,AngleZ) 
EndFunction

Event OnTrophyDisplay(Form akTarget, Bool abInitiallyDisabled)
{Event sent by TrophyManager or TrophyBase to tell TrophyObject to display itself at akTarget.}
	UnregisterForModEvent("vMYC_TrophyDisplayObject" + TrophyName + GetFormIDString(akTarget))
	;DebugTrace("UNRegistering " + Self + " for event vMYC_TrophyDisplay" + TrophyName + GetFormIDString(akTarget) + "!")
	If !(akTarget as ObjectReference).Is3DLoaded()
		OnLoadQueued = True
		OnLoadTarget = akTarget as ObjectReference
		Return
	EndIf
	ObjectReference kTrophyObject = PlaceTrophyForm(akTarget as ObjectReference, abInitiallyDisabled)
	If kTrophyObject
		TrophyBase.TrophyManager.RegisterTrophyObject(kTrophyObject,akTarget as ObjectReference)
	EndIf
EndEvent

ObjectReference Function PlaceTrophyForm(ObjectReference akTarget, Bool abInitiallyDisabled = False)
{Place an instance of TrophyForm at akTarget with the same offset and angle as the original.}
	If !akTarget || !TrophyForm
		Return None
	EndIf
	Float[] fRelativePos = GetRelativePosition(TrophyOrigin,Self)
	Float[] fOriginAng = New Float[3]

	fRelativePos[3] = AngleX + FormAngleX
	fRelativePos[4] = AngleY + FormAngleY
	fRelativePos[5] = AngleZ + FormAngleZ
	
	fOriginAng[0] = akTarget.GetAngleX()
	fOriginAng[1] = akTarget.GetAngleY()
	fOriginAng[2] = akTarget.GetAngleZ() 

	;If LocalRotation
	TrophyObject = PlaceAtMeRelative(akTarget, TrophyForm, fOriginAng, fRelativePos, 0, 0, 0, fOriginAng[2], 0, false, True, false, false, LocalRotation)
	;Else
	;	TrophyObject = PlaceAtMeRelative(akTarget, TrophyForm, fOriginAng, fRelativePos, 0, 0, 0, 0, 0, false, false, false, false, LocalRotation)
	;EndIf
	If FormScale != 1
		TrophyObject.SetScale(FormScale)
	ElseIf Scale != 1
		TrophyObject.SetScale(Scale)
	EndIf
	Float fScale = TrophyObject.GetScale()
	
	If TrophyObject as vMYC_TrophyObject
		;This object needs to know its parents!
		(TrophyObject as vMYC_TrophyObject).SetParentObject(TrophyBase)
	EndIf
	
	ObjectReference kGlow = TrophyObject.PlaceAtMe(vMYC_BrightGlow,abInitiallyDisabled = True)
	kGlow.SetScale(TrophyObject.GetScale() * 3)
	kGlow.EnableNoWait(True)
	While !kGlow.Is3DLoaded()
		Wait(0.1)
	EndWhile
	vMYC_TrophyAppearSM.Play(kGlow)	

	If !abInitiallyDisabled
		TrophyObject.EnableNoWait(True)
		While !TrophyObject.Is3DLoaded()
			Wait(0.1)
		EndWhile
		TrophyFadeInFXS.Play(TrophyObject,0)
	EndIf
	kGlow.DisableNoWait(True)

	Return TrophyObject
EndFunction

Function DeleteTrophyForm()
{Delete the placed Form (now an ObjectReference).}
	TrophyObject.Delete()
EndFunction

Function SetParentObject(vMYC_TrophyBase kTrophyBase)
{Set the TrophyBase that this TrophyObject belongs to, initializing most of the important data at the same time.}
	TrophyBase = kTrophyBase
	SetPositionData(TrophyBase.BaseX, TrophyBase.BaseY, TrophyBase.BaseZ, TrophyBase.AngleX, TrophyBase.AngleY, TrophyBase.AngleZ, TrophyBase.Scale)
	;TrophyForm = TrophyBase.akForm
	TrophyName = TrophyBase.TrophyName
	TrophyFadeInFXS = TrophyBase.TrophyFadeInFXS
	;TrophyIndex = idx
	TrophyOrigin = TrophyBase.TrophyOrigin
	LocalRotation = True ; LocalRotation method is now used for EVERYTHING
	;RegisterForModEvent("vMYC_TrophyDisplay" + TrophyName,"OnTrophyDisplay")	
EndFunction

Function SetPositionData(Float afBaseX = 0.0, Float afBaseY = 0.0, Float afBaseZ = 0.0, \
							Float afAngleX = 0.0, Float afAngleY = 0.0, Float afAngleZ = 0.0, \
							Float afScale = 1.0)
{Set the basic position and angle data for this TrophyObject.}
	BaseX =  afBaseX
	BaseY =  afBaseY 
	BaseZ =  afBaseZ 
	AngleX = afAngleX
	AngleY = afAngleY
	AngleZ = afAngleZ
	Scale =  afScale
EndFunction

Function SetFormData(Form akForm, Float afFormBaseX = 0.0, Float afFormBaseY = 0.0, Float afFormBaseZ = 0.0, \
					Float afFormAngleX = 0.0, Float afFormAngleY = 0.0, Float afFormAngleZ = 0.0, \
					Float afFormScale = 0.0)
{Set the basic position and angle data for the Form provided by this TrophyObject.
 This will be offset from the TrophyObject's position data.}
	TrophyForm = akForm
	FormX =  afFormBaseX
	FormY =  afFormBaseY 
	FormZ =  afFormBaseZ 
	FormAngleX = afFormAngleX
	FormAngleY = afFormAngleY
	FormAngleZ = afFormAngleZ
	If afFormScale
		FormScale = afFormScale
	Else
		FormScale = Scale
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/TrophyObject/" + TrophyName + "/" + TrophyIndex + ": " + sDebugString,iSeverity)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
