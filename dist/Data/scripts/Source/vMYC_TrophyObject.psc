Scriptname vMYC_TrophyObject extends ObjectReference
{Object that acts as a base point for a trophy.}

;--=== Imports ===--

Import Utility
Import Game
Import Math

;=== Constants ===--

;--=== Properties ===--

EffectShader	Property	TrophyFadeInFXS		= None		Auto
{Shader that should play when the trophy first appears.}

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
;--=== Variables ===--

Int					_TrophyVersion

ObjectReference[]	_DisplayedObjects

ObjectReference[]	_TemplateObjects

;--=== Events/Functions ===--

Event OnInit()
	If !vMYC_TrophyEmptyBase
		vMYC_TrophyEmptyBase = GetFormFromFile(0x0203055F,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	If !vMYC_TrophyObjectBase
		vMYC_TrophyObjectBase = GetFormFromFile(0x02033E5C,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	RegisterForModEvents()
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
	PlaceTrophyForm(akTarget as ObjectReference, abInitiallyDisabled)
EndEvent

ObjectReference Function PlaceTrophyForm(ObjectReference akTarget, Bool abInitiallyDisabled = False)

	Float[] fRelativePos = GetRelativePosition(TrophyOrigin,Self)
	Float[] fOriginAng = New Float[3]

	fRelativePos[3] = AngleX + FormAngleX
	fRelativePos[4] = AngleY + FormAngleY
	fRelativePos[5] = AngleZ + FormAngleZ
	
	fOriginAng[0] = akTarget.GetAngleX()
	fOriginAng[1] = akTarget.GetAngleY()
	fOriginAng[2] = akTarget.GetAngleZ() 


	;If LocalRotation
	TrophyObject = PlaceAtMeRelative(akTarget, TrophyForm, fOriginAng, fRelativePos, 0, 0, 0, fOriginAng[2], 0, false, abInitiallyDisabled, false, false, LocalRotation)
	;Else
	;	TrophyObject = PlaceAtMeRelative(akTarget, TrophyForm, fOriginAng, fRelativePos, 0, 0, 0, 0, 0, false, false, false, false, LocalRotation)
	;EndIf
	If FormScale != 1
		TrophyObject.SetScale(FormScale)
	ElseIf Scale != 1
		TrophyObject.SetScale(Scale)
	EndIf
	
	If !abInitiallyDisabled
		While !TrophyObject.Is3DLoaded()
			Wait(0.1)
		EndWhile
		TrophyFadeInFXS.Play(TrophyObject,0)
	EndIf

	;DebugTrace("Original is at X:\t" + (AngleX + FormAngleX) + ", Y:\t" + (AngleY + FormAngleY) + ", Z:\t" + (AngleZ + FormAngleZ) + ", S:\t" + Scale)
	;DebugTrace(" Target set to X:\t" + TrophyObject.GetAngleX() + ", Y:\t" + TrophyObject.GetAngleY() + ", Z:\t" + TrophyObject.GetAngleZ() + ", S:\t" + TrophyObject.GetScale())
	;RotateLocal(TrophyObject,0,0,akTarget.GetAngleZ())	
	Return TrophyObject
EndFunction

Function SetParentObject(vMYC_TrophyBase kTrophyBase)
	TrophyBase = kTrophyBase
	SetPositionData(TrophyBase.BaseX, TrophyBase.BaseY, TrophyBase.BaseZ, TrophyBase.AngleX, TrophyBase.AngleY, TrophyBase.AngleZ, TrophyBase.Scale)
	;TrophyForm = TrophyBase.akForm
	TrophyName = TrophyBase.TrophyName
	TrophyFadeInFXS = TrophyBase.TrophyFadeInFXS
	;TrophyIndex = idx
	TrophyOrigin = TrophyBase.TrophyOrigin
	LocalRotation = True ; LocalRotation method is now used for EVERYTHING
	RegisterForModEvent("vMYC_TrophyDisplay" + TrophyName,"OnTrophyDisplay")	
EndFunction

Function SetPositionData(Float afBaseX = 0.0, Float afBaseY = 0.0, Float afBaseZ = 0.0, \
							Float afAngleX = 0.0, Float afAngleY = 0.0, Float afAngleZ = 0.0, \
							Float afScale = 1.0)
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

;=== The following functions are blatantly stolen from Chesko. Thanks bud! ===--

float[] function GetPosXYZRotateAroundRef(ObjectReference akOrigin, ObjectReference akObject, float fAngleX, float fAngleY, float fAngleZ)

	;-----------\
	;Description \ 
	;----------------------------------------------------------------
	;Rotates a 3D position (akObject) offset from the center of 
	;rotation (akOrigin) by the supplied degrees fAngleX, fAngleY,
	;fAngleZ, and returns the new 3D position of the point.
	
	;-------------\
	;Return Values \
	;----------------------------------------------------------------
	;		fNewPos[0]	= 	The new X position of the point
	;		fNewPos[1]	= 	The new Y position of the point
	;		fNewPos[2]	= 	The new Z position of the point

	;				|1			0			0		|
	;Rx(t) = 		|0			cos(t)		-sin(t)	|
	;				|0			sin(t)		cos(t)	|
	;
	;				|cos(t)		0			sin(t)	|
	;Ry(t) =		|0			1			0		|
	;				|-sin(t)	0			cos(t)	|
	;
	;				|cos(t)		-sin(t)		0		|
	;Rz(t) = 		|sin(t)		cos(t)		0		|
	;				|0			0			1		|
	
	;R * v = Rv, where R = rotation matrix, v = column vector of point [ x y z ], Rv = column vector of point after rotation
		
	fAngleX = -(fAngleX)
	fAngleY = -(fAngleY)
	fAngleZ = -(fAngleZ)
	
	float myOriginPosX = akOrigin.GetPositionX()
	float myOriginPosY = akOrigin.GetPositionY()
	float myOriginPosZ = akOrigin.GetPositionZ()
	
	float fInitialX = akObject.GetPositionX() - myOriginPosX
	float fInitialY = akObject.GetPositionY() - myOriginPosY
	float fInitialZ = akObject.GetPositionZ() - myOriginPosZ
	
	float fNewX
	float fNewY
	float fNewZ
	
	;Objects in Skyrim are rotated in order of Z, Y, X, so we will do that here as well.
	
	;Z-axis rotation matrix
	float fVectorX = fInitialX
	float fVectorY = fInitialY
	float fVectorZ = fInitialZ
	fNewX = (fVectorX * cos(fAngleZ)) + (fVectorY * sin(-fAngleZ)) + (fVectorZ * 0)
	fNewY = (fVectorX * sin(fAngleZ)) + (fVectorY * cos(fAngleZ)) + (fVectorZ * 0)
	fNewZ = (fVectorX * 0) + (fVectorY * 0) + (fVectorZ * 1)	
	
	;Y-axis rotation matrix
	fVectorX = fNewX
	fVectorY = fNewY
	fVectorZ = fNewZ
	fNewX = (fVectorX * cos(fAngleY)) + (fVectorY * 0) + (fVectorZ * sin(fAngleY))
	fNewY = (fVectorX * 0) + (fVectorY * 1) + (fVectorZ * 0)
	fNewZ = (fVectorX * sin(-fAngleY)) + (fVectorY * 0) + (fVectorZ * cos(fAngleY))
	
	;X-axis rotation matrix
	fVectorX = fNewX
	fVectorY = fNewY
	fVectorZ = fNewZ	
	fNewX = (fVectorX * 1) + (fVectorY * 0) + (fVectorZ * 0)
	fNewY = (fVectorX * 0) + (fVectorY * cos(fAngleX)) + (fVectorZ * sin(-fAngleX))
	fNewZ = (fVectorX * 0) + (fVectorY * sin(fAngleX)) + (fVectorZ * cos(fAngleX))
	
	;Return result
	float[] fNewPos = new float[3]
	fNewPos[0] = fNewX
	fNewPos[1] = fNewY
	fNewPos[2] = fNewZ
	return fNewPos 
endFunction

float[] function GetRelativePosition(ObjectReference akOrigin, ObjectReference akObject)
	float[] myRelativePosition = new float[6]
	myRelativePosition[0] = akObject.GetPositionX() - akOrigin.GetPositionX()
	myRelativePosition[1] = akObject.GetPositionY() - akOrigin.GetPositionY()
	myRelativePosition[2] = akObject.GetPositionZ() - akOrigin.GetPositionZ()
	myRelativePosition[3] = akObject.GetAngleX()
	myRelativePosition[4] = akObject.GetAngleY()
	myRelativePosition[5] = akObject.GetAngleZ()
	
	return myRelativePosition
endFunction

ObjectReference Function PlaceAtMeRelative(ObjectReference akOrigin, Form akFormToPlace, Float[] fOriginAng, \
										   Float[] fRelativePos, Float fZGlobalAngAdjust = 0.0, Float fXLocalAngAdjust = 0.0,  \
										   Float fYLocalAngAdjust = 0.0, Float fZLocalAngAdjust = 0.0, Float fZHangingOffset = 0.0, \
										   Bool abInvertedLocalY = false, Bool abInitiallyDisabled = false, Bool abIsPropped = false, \
										   Bool abIsHanging = false, Bool abUseSetLocal = false)

	ObjectReference myObject
    ObjectReference myTempMarker = akOrigin.PlaceAtMe(vMYC_TrophyEmptyBase, abInitiallyDisabled = True)
	myTempMarker.MoveTo(myTempMarker, fRelativePos[0], fRelativePos[1], fRelativePos[2])
    
	Float[] myNewPos = new Float[3]
    myNewPos = GetPosXYZRotateAroundRef(akOrigin, myTempMarker, fOriginAng[0], fOriginAng[1], fOriginAng[2] + fZGlobalAngAdjust)
    myTempMarker.MoveTo(akOrigin, myNewPos[0], myNewPos[1], myNewPos[2])
	if abIsPropped
		if abInvertedLocalY
			myTempMarker.SetAngle(fXLocalAngAdjust, -(fOriginAng[2] + fYLocalAngAdjust), fZLocalAngAdjust)
		else
			myTempMarker.SetAngle(fXLocalAngAdjust, fOriginAng[2] + fYLocalAngAdjust, fZLocalAngAdjust)
		endif
	elseif abIsHanging
		myTempMarker.MoveTo(myTempMarker, afZOffset = fZHangingOffset)
		myTempMarker.SetAngle(0.0, 0.0, myTempMarker.GetAngleZ() + fRelativePos[5] + fZLocalAngAdjust)
	else
		if abUseSetLocal

			fXLocalAngAdjust += fRelativePos[3]
			fYLocalAngAdjust += fRelativePos[4]
			
			DebugTrace("akObject is at AngleX:\t" + fRelativePos[3] + ", AngleY:\t" + fRelativePos[4] + ", AngleZ:\t" + fRelativePos[5] + "!")
			DebugTrace("akObject will be rotated by: X:\t" + fRelativePos[3] + ", Y:\t" + fYLocalAngAdjust + ", Z:\t" + fZLocalAngAdjust + "!")
			Float fAngleX = fRelativePos[3] * Math.Cos(fZLocalAngAdjust) + fYLocalAngAdjust * Math.Sin(fZLocalAngAdjust)
			Float fAngleY = fYLocalAngAdjust * Math.Cos(fZLocalAngAdjust) - fRelativePos[3] * Math.Sin(fZLocalAngAdjust)
			DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + (fRelativePos[5] + fZLocalAngAdjust) + "!")
			myTempMarker.SetAngle(fAngleX, fAngleY, fRelativePos[5] + fZLocalAngAdjust)
		
		else
			myTempMarker.SetAngle(myTempMarker.GetAngleX() + fRelativePos[3] + fXLocalAngAdjust, \
								myTempMarker.GetAngleY() + fRelativePos[4] + fYLocalAngAdjust, \
								myTempMarker.GetAngleZ() + fRelativePos[5] + fZLocalAngAdjust)
		endif
	endif
	
	if abInitiallyDisabled
		myObject = myTempMarker.PlaceAtMe(akFormToPlace, abInitiallyDisabled = true)
	else
		myObject = myTempMarker.PlaceAtMe(akFormToPlace)
	endif
    
    myTempMarker.Delete()

    return myObject
EndFunction

Function SetLocalAngle(ObjectReference akObject, Float afLocalX, Float afLocalY, Float afLocalZ)
	Float fOAngleX = akObject.GetAngleX()
	Float fOAngleY = akObject.GetAngleY()
	Float fOAngleZ = akObject.GetAngleZ()

	DebugTrace("akObject is at AngleX:\t" + fOAngleX + ", AngleY:\t" + fOAngleY + ", AngleZ:\t" + fOAngleZ + "!")
	DebugTrace("akObject will be rotated by: X:\t" + afLocalX + ", Y:\t" + afLocalY + ", Z:\t" + afLocalZ + "!")
	Float fAngleX = afLocalX * Math.Cos(afLocalZ) + afLocalY * Math.Sin(afLocalZ)
	Float fAngleY = afLocalY * Math.Cos(afLocalZ) - afLocalX * Math.Sin(afLocalZ)
	DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + (afLocalZ) + "!")
	akObject.SetAngle(fAngleX, fAngleY, afLocalZ)
EndFunction

Int[] Function RotateLocal(ObjectReference akObject, Float afAngleX, Float afAngleY, Float afAngleZ) 
	Float fOAngleX = akObject.GetAngleX()
	Float fOAngleY = akObject.GetAngleY()
	Float fOAngleZ = akObject.GetAngleZ()

	DebugTrace("akObject is at AngleX:\t" + fOAngleX + ", AngleY:\t" + fOAngleY + ", AngleZ:\t" + fOAngleZ + "!")
	DebugTrace("akObject will be rotated by: X:\t" + afAngleX + ", Y:\t" + afAngleY + ", Z:\t" + afAngleZ + "!")
	afAngleX += fOAngleX
	afAngleY += fOAngleY
	;afAngleZ += fOAngleZ
	
	DebugTrace("akObject's angle sum is: X:\t" + afAngleX + ", Y:\t" + afAngleY + ", Z:\t" + afAngleZ + "!")
	
	Float fAngleX = afAngleX * Math.Cos(afAngleZ) + afAngleY * Math.Sin(afAngleZ)
	Float fAngleY = afAngleY * Math.Cos(afAngleZ) - afAngleX * Math.Sin(afAngleZ)
	DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + (fOAngleZ + afAngleZ) + "!")
	akObject.SetAngle(fAngleX, fAngleY, fOAngleZ + afAngleZ)
EndFunction

