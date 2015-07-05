Scriptname vFF_PlacementUtils Hidden


;=== The following functions are blatantly stolen from Chesko. Thanks bud! ===--

float[] function GetPosXYZRotateAroundRef(ObjectReference akOrigin, ObjectReference akObject, float fAngleX, float fAngleY, float fAngleZ) Global

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
	;Rx(t) = 		|0			Math.cos(t)		-Math.sin(t)	|
	;				|0			Math.sin(t)		Math.cos(t)	|
	;
	;				|Math.cos(t)		0			Math.sin(t)	|
	;Ry(t) =		|0			1			0		|
	;				|-Math.sin(t)	0			Math.cos(t)	|
	;
	;				|Math.cos(t)		-Math.sin(t)		0		|
	;Rz(t) = 		|Math.sin(t)		Math.cos(t)		0		|
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
	fNewX = (fVectorX * Math.cos(fAngleZ)) + (fVectorY * Math.sin(-fAngleZ)) + (fVectorZ * 0)
	fNewY = (fVectorX * Math.sin(fAngleZ)) + (fVectorY * Math.cos(fAngleZ)) + (fVectorZ * 0)
	fNewZ = (fVectorX * 0) + (fVectorY * 0) + (fVectorZ * 1)	
	
	;Y-axis rotation matrix
	fVectorX = fNewX
	fVectorY = fNewY
	fVectorZ = fNewZ
	fNewX = (fVectorX * Math.cos(fAngleY)) + (fVectorY * 0) + (fVectorZ * Math.sin(fAngleY))
	fNewY = (fVectorX * 0) + (fVectorY * 1) + (fVectorZ * 0)
	fNewZ = (fVectorX * Math.sin(-fAngleY)) + (fVectorY * 0) + (fVectorZ * Math.cos(fAngleY))
	
	;X-axis rotation matrix
	fVectorX = fNewX
	fVectorY = fNewY
	fVectorZ = fNewZ	
	fNewX = (fVectorX * 1) + (fVectorY * 0) + (fVectorZ * 0)
	fNewY = (fVectorX * 0) + (fVectorY * Math.cos(fAngleX)) + (fVectorZ * Math.sin(-fAngleX))
	fNewZ = (fVectorX * 0) + (fVectorY * Math.sin(fAngleX)) + (fVectorZ * Math.cos(fAngleX))
	
	;Return result
	float[] fNewPos = new float[3]
	fNewPos[0] = fNewX
	fNewPos[1] = fNewY
	fNewPos[2] = fNewZ
	return fNewPos 
endFunction

float[] function GetRelativePosition(ObjectReference akOrigin, ObjectReference akObject) Global
	float[] myRelativePosition = new float[6]
	myRelativePosition[0] = akObject.GetPositionX() - akOrigin.GetPositionX()
	myRelativePosition[1] = akObject.GetPositionY() - akOrigin.GetPositionY()
	myRelativePosition[2] = akObject.GetPositionZ() - akOrigin.GetPositionZ()
	myRelativePosition[3] = akObject.GetAngleX()
	myRelativePosition[4] = akObject.GetAngleY()
	myRelativePosition[5] = akObject.GetAngleZ()
	
	return myRelativePosition
endFunction

;=== This has been modified to apply a local rotation because I never could get it to work on objects with Y rotation. ===--
ObjectReference Function PlaceAtMeRelative(ObjectReference akOrigin, Form akFormToPlace, Float[] fOriginAng, \
										   Float[] fRelativePos, Float fZGlobalAngAdjust = 0.0, Float fXLocalAngAdjust = 0.0,  \
										   Float fYLocalAngAdjust = 0.0, Float fZLocalAngAdjust = 0.0, Float fZHangingOffset = 0.0, \
										   Bool abInvertedLocalY = false, Bool abInitiallyDisabled = false, Bool abIsPropped = false, \
										   Bool abIsHanging = false, Bool abUseSetLocal = false) Global

    ObjectReference myObject = akOrigin.PlaceAtMe(akFormToPlace, abInitiallyDisabled = True)
	myObject.MoveTo(myObject, fRelativePos[0], fRelativePos[1], fRelativePos[2])
    
	Float[] myNewPos = new Float[3]
    myNewPos = GetPosXYZRotateAroundRef(akOrigin, myObject, fOriginAng[0], fOriginAng[1], fOriginAng[2] + fZGlobalAngAdjust)
    myObject.MoveTo(akOrigin, myNewPos[0], myNewPos[1], myNewPos[2])
	if abIsPropped
		if abInvertedLocalY
			myObject.SetAngle(fXLocalAngAdjust, -(fOriginAng[2] + fYLocalAngAdjust), fZLocalAngAdjust)
		else
			myObject.SetAngle(fXLocalAngAdjust, fOriginAng[2] + fYLocalAngAdjust, fZLocalAngAdjust)
		endif
	elseif abIsHanging
		myObject.MoveTo(myObject, afZOffset = fZHangingOffset)
		myObject.SetAngle(0.0, 0.0, myObject.GetAngleZ() + fRelativePos[5] + fZLocalAngAdjust)
	else
		if abUseSetLocal

			fXLocalAngAdjust += fRelativePos[3]
			fYLocalAngAdjust += fRelativePos[4]
			
			;DebugTrace("akObject is at AngleX:\t" + fRelativePos[3] + ", AngleY:\t" + fRelativePos[4] + ", AngleZ:\t" + fRelativePos[5] + "!")
			;DebugTrace("akObject will be rotated by: X:\t" + fRelativePos[3] + ", Y:\t" + fYLocalAngAdjust + ", Z:\t" + fZLocalAngAdjust + "!")
			Float fAngleX = fRelativePos[3] * Math.cos(fZLocalAngAdjust) + fYLocalAngAdjust * Math.sin(fZLocalAngAdjust)
			Float fAngleY = fYLocalAngAdjust * Math.cos(fZLocalAngAdjust) - fRelativePos[3] * Math.sin(fZLocalAngAdjust)
			Float fAngleZ = fRelativePos[5] + fZLocalAngAdjust
			fAngleX = ReduceAngle(fAngleX)
			fAngleY = ReduceAngle(fAngleY)
			fAngleZ = ReduceAngle(fAngleZ)
			;DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + fAngleZ + "!")
			myObject.SetAngle(fAngleX, fAngleY, fAngleZ)
		
		else
			myObject.SetAngle(myObject.GetAngleX() + fRelativePos[3] + fXLocalAngAdjust, \
								myObject.GetAngleY() + fRelativePos[4] + fYLocalAngAdjust, \
								myObject.GetAngleZ() + fRelativePos[5] + fZLocalAngAdjust)
		endif
	endif
	
	if !abInitiallyDisabled
		myObject.EnableNoWait(True)
	endif
    
    return myObject
EndFunction

Float Function ReduceAngle(Float afAngle) Global
	While afAngle >= 360
		afAngle -= 360
	EndWhile
	If afAngle < 0
		afAngle += 360
	EndIf
	Return afAngle
EndFunction

Function SetLocalAngle(ObjectReference akObject, Float afLocalX, Float afLocalY, Float afLocalZ) Global
	Float fOAngleX = akObject.GetAngleX()
	Float fOAngleY = akObject.GetAngleY()
	Float fOAngleZ = akObject.GetAngleZ()

	;DebugTrace("akObject is at AngleX:\t" + fOAngleX + ", AngleY:\t" + fOAngleY + ", AngleZ:\t" + fOAngleZ + "!")
	;DebugTrace("akObject will be rotated by: X:\t" + afLocalX + ", Y:\t" + afLocalY + ", Z:\t" + afLocalZ + "!")
	Float fAngleX = afLocalX * Math.cos(afLocalZ) + afLocalY * Math.sin(afLocalZ)
	Float fAngleY = afLocalY * Math.cos(afLocalZ) - afLocalX * Math.sin(afLocalZ)
	;DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + (afLocalZ) + "!")
	akObject.SetAngle(fAngleX, fAngleY, afLocalZ)
EndFunction

Int[] Function RotateLocal(ObjectReference akObject, Float afAngleX, Float afAngleY, Float afAngleZ) Global
	Float fOAngleX = akObject.GetAngleX()
	Float fOAngleY = akObject.GetAngleY()
	Float fOAngleZ = akObject.GetAngleZ()

	;DebugTrace("akObject is at AngleX:\t" + fOAngleX + ", AngleY:\t" + fOAngleY + ", AngleZ:\t" + fOAngleZ + "!")
	;DebugTrace("akObject will be rotated by: X:\t" + afAngleX + ", Y:\t" + afAngleY + ", Z:\t" + afAngleZ + "!")
	afAngleX += fOAngleX
	afAngleY += fOAngleY
	;afAngleZ += fOAngleZ
	
	;DebugTrace("akObject's angle sum is: X:\t" + afAngleX + ", Y:\t" + afAngleY + ", Z:\t" + afAngleZ + "!")
	
	Float fAngleX = afAngleX * Math.cos(afAngleZ) + afAngleY * Math.sin(afAngleZ)
	Float fAngleY = afAngleY * Math.cos(afAngleZ) - afAngleX * Math.sin(afAngleZ)
	;DebugTrace("akObject's new angle will be: X:\t" + fAngleX + ", Y:\t" + fAngleY + ", Z:\t" + (fOAngleZ + afAngleZ) + "!")
	akObject.SetAngle(fAngleX, fAngleY, fOAngleZ + afAngleZ)
EndFunction

