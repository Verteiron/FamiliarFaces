Scriptname vMYC_TrophyBase extends vMYC_BaseQuest  
{Base for trophy plugins. Don't modify this script! Extend it and modify that.}

;--=== Imports ===--

Import Utility
Import Game
Import Math

;=== Constants ===--

Int				Property	TROPHY_TYPE_OBJECT		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_TYPE_BANNER		= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_TYPE_SEAL		= 0x00000002		AutoReadOnly Hidden
Int				Property	TROPHY_TYPE_DECAL		= 0x00000004		AutoReadOnly Hidden
Int				Property	TROPHY_TYPE_CUSTOM		= 0x00000008		AutoReadOnly Hidden

Int				Property	TROPHY_SIZE_SMALL		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_SIZE_MEDIUM		= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_SIZE_LARGE		= 0x00000002		AutoReadOnly Hidden

Int				Property	TROPHY_LOC_PLINTH		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_PLINTHBASE	= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_WALLBACK		= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_WALLSIDES	= 0x00000002		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_ENTRYINNER	= 0x00000004		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_ENTRYHALL	= 0x00000008		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_ENTRYOUTER	= 0x00000010		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_ENTRYLINTEL	= 0x00000020		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_SHRINEWALL	= 0x00000040		AutoReadOnly Hidden
Int				Property	TROPHY_LOC_CUSTOM		= 0x00000080		AutoReadOnly Hidden

Int				Property	TROPHY_EXTRAS_NONE		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_EXTRAS_ACTIVATOR	= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_EXTRAS_HASHAVOK	= 0x00000002		AutoReadOnly Hidden
Int				Property	TROPHY_EXTRAS_HASLIGHT	= 0x00000004		AutoReadOnly Hidden
Int				Property	TROPHY_EXTRAS_NOSPACE	= 0x00000008		AutoReadOnly Hidden

;--=== Properties ===--

Activator		Property	TrophyActivator		= None		Auto
{The trophy activator object. More items can be added by creating additional properties but custom code will be needed in the Display function.}

String			Property	TrophyName			= "Trophy"	Auto
{Name of the trophy to be used by scripts. Same rules as a Papyrus variable name.}

String			Property	TrophyFullName		= "Demo"	Auto
{Name of the trophy for display purposes.}

EffectShader	Property	TrophyFadeInFXS		= None		Auto
{Shader that should play when the trophy first appears.}

Int				Property	TrophyPriority		= 100		Auto
{How great/unique of an achievement is this? LOWER IS BETTER! DLC (or large mod such as Falskaar) completion is 2, Faction completion is 4. See docs for more info!}

Int				Property	TrophyType			= 0			Auto
Int				Property	TrophySize			= 0			Auto
Int				Property	TrophyLoc			= 0			Auto
Int				Property	TrophyExtras		= 0			Auto

Int				Property	TrophyFlags			= 0			Auto
{See TROPHY enums above}

Int				Property	TrophyVersion					Auto
{Increment this if the trophy's requirements or mesh have changed.}

String[]		Property	TrophyExclusionList				Auto
{If this trophy is displayed, prevent these trophies from being displayed. Use with caution!}

Int				Property	Available			= 0			Auto Hidden
Bool			Property	Enabled				= True		Auto Hidden

Bool			Property	DoNotRegister		= False		Auto

ObjectReference	Property	TrophyBaseObject	= None 		Auto
{The base object that defines the trophy's location in the alcove. If missing, it will be placed at the coordinates defined in the Base value below.}

;The following are used to place the object in absolute terms if a preset position is not being used. The origin is the base of the player statue
Float			Property	BaseX					= 0.0		Auto
Float			Property	BaseY					= 0.0		Auto
Float			Property	BaseZ					= 0.0		Auto

;The following are used to place the object relative to its "base", that is the origin of its position
Float			Property	OffsetX			= 0.0		Auto
Float			Property	OffsetY			= 0.0		Auto
Float			Property	OffsetZ			= 0.0		Auto
Float			Property	AngleX			= 0.0		Auto
Float			Property	AngleY			= 0.0		Auto
Float			Property	AngleZ			= 0.0		Auto
Float			Property	Scale			= 1.0		Auto

Bool			Property	LocalRotation	= False		Auto 
{Use this if your object isn't getting rotated correctly!}

Activator 		Property	vMYC_TrophyEmptyBase		Auto
{Base Activator to be placed as a base object if none other is defined.}

Float			Property	AngleDelta		= 0.0		Auto Hidden

ObjectReference	Property	TrophyOrigin				Auto Hidden

vMYC_TrophyManager	Property	TrophyManager			Auto Hidden

;--=== Variables ===--

Int					_TrophyVersion

Int[]				_TemplatesToDisplay

ObjectReference[]	_DisplayedObjects

ObjectReference[]	_TemplateObjects

;--=== Events/Functions ===--

Event OnGameReload()
	CheckVars()
	If !TrophyName
		If IsRunning()
			Stop()
		EndIf
		Return
	EndIf
	RegisterForModEvents()
EndEvent

Event OnInit()
	If !IsRunning()
		Return
	EndIf

	If !_DisplayedObjects
		_DisplayedObjects = New ObjectReference[128]
	EndIf

	If !_TemplateObjects
		_TemplateObjects = New ObjectReference[128]
	EndIf

	If !_TemplatesToDisplay
		_TemplatesToDisplay = New Int[16]
	EndIf
	
	CheckVars()
	If !TrophyName
		If IsRunning()
			Stop()
		EndIf
		Return
	EndIf
	If !TrophyFlags
		SetTrophyFlags(TrophyType,TrophySize,TrophyLoc,TrophyExtras)
	EndIf
	RegisterForModEvents()
	DoInit()
	
EndEvent

Function RegisterForModEvents()
	If DoNotRegister
		Return
	EndIf
	RegisterForModEvent("vMYC_TrophyManagerReady","OnTrophyManagerReady")
	RegisterForModEvent("vMYC_TrophyCheckAvailable","OnTrophyCheckAvailable")
	RegisterForModEvent("vMYC_TrophySelfMessage" + TrophyName,"OnTrophySelfMessage")
EndFunction

Event OnTrophyManagerReady(Form akSender)
	Int iAvailable = _IsAvailable()
	If !TrophyManager && akSender as vMYC_TrophyManager
		TrophyManager = akSender as vMYC_TrophyManager
		SendRegisterEvent()
	EndIf

	If _TrophyVersion != TrophyVersion 
		_TrophyVersion = TrophyVersion
	EndIf
	If iAvailable != Available
		Available = iAvailable
	EndIf
EndEvent

Function SendRegisterEvent()
	Int iHandle = ModEvent.Create("vMYC_TrophyRegister")
	If iHandle
		ModEvent.PushString(iHandle,TrophyName)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vMYC_TrophyRegister!",1)
	EndIf
	TrophyOrigin = TrophyManager.GetTrophyOrigin()
	If !vMYC_TrophyEmptyBase
		vMYC_TrophyEmptyBase = GetFormFromFile(0x0203055F,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	Wait(1)
	_CreateTemplates()
	ObjectReference kOffsetOrigin = TrophyManager.GetTrophyOffsetOrigin()
	If TrophyName
		_DisplayedObjects = New ObjectReference[128]
		_Display(kOffsetOrigin,0xFFFFFFFF)
	EndIf
	;If TrophyName == "DLC02"
	;	ObjectReference newOrigin = TrophyOrigin.PlaceAtMe(vMYC_TrophyEmptyBase)
	;	Int i = 0
	;	While i < 360
	;		newOrigin.SetAngle(0,0,i)
	;		_DisplayedObjects = New ObjectReference[128]
	;		_Display(newOrigin,7)
	;		i += 30
	;	EndWhile
	;EndIf
EndFunction

Event OnTrophyCheckAvailable(Form akSender)
	If TrophyManager
		SendAvailableEvent(_IsAvailable())
	EndIf
EndEvent

Function SendAvailableEvent(Int aiAvailable = 0)
	Int iHandle = ModEvent.Create("vMYC_TrophyAvailable")
	If iHandle
		ModEvent.PushString(iHandle,TrophyName)
		ModEvent.PushInt(iHandle,aiAvailable)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send vMYC_TrophyAvailable!",1)
	EndIf
EndFunction

Event OnTrophySelfMessage(String asMessage)
	
EndEvent

Event OnUpdate()
	
EndEvent

Event OnTrophyInit()

EndEvent

Function DoInit()
	OnTrophyInit()
EndFunction

Int Function _IsAvailable()
	Int iAvailable = IsAvailable()
	;FIXME - Always return >0 for testing!
	;If !iAvailable
	;	iAvailable = 1
	;EndIf
	Return iAvailable
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}

	Return 0
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display}
	
EndEvent

Int Function Remove()
{User code for hide}
	Return 1
EndFunction

Int Function RefreshTrophy()
{User code for refresh}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation}
	Return 1
EndFunction

Function CheckVars()

EndFunction

Function DoShutdown()
	UnregisterForUpdate()
EndFunction

Event OnSetTemplate()
	;User event
EndEvent

Int Function CreateTemplate(Form akForm, Float afOffsetX = 0.0, Float afOffsetY = 0.0, Float afOffsetZ = 0.0, Float afAngleX = 0.0, Float afAngleY = 0.0, Float afAngleZ = 0.0, Float afScale = 1.0)
	Int idx = _TemplateObjects.Find(None)
	_TemplateObjects[idx] = TrophyBaseObject.PlaceAtMe(akForm,abInitiallyDisabled = True)
	If afOffsetX || afOffsetY || afOffsetZ
		_TemplateObjects[idx].MoveTo(TrophyBaseObject,afOffsetX,afOffsetY,afOffsetZ)
	EndIf
	If afAngleX || afAngleY || afAngleZ
		_TemplateObjects[idx].SetAngle(AngleX + afAngleX, AngleY + afAngleY, AngleZ + afAngleZ)
	EndIf
	If afScale
		_TemplateObjects[idx].SetScale(afScale)
	ElseIf Scale != 1
		_TemplateObjects[idx].SetScale(Scale)
	EndIf
	_TemplateObjects[idx].EnableNoWait(False)
	Return idx
EndFunction

Int Function SetTemplate(ObjectReference akTargetObject)
	Int idx = _TemplateObjects.Find(None)
	_TemplateObjects[idx] = akTargetObject
	akTargetObject.EnableNoWait(False)
	Return idx
EndFunction

Int[] Function SetTemplateArray(ObjectReference[] akTargetObjects)
	Int idx = 0
	Int i = 0
	Int iCount = akTargetObjects.Length
	Int[] iResult = New Int[128]
	While i < iCount
		If akTargetObjects[i]
			iResult[i] = SetTemplate(akTargetObjects[i])
		EndIf
		i += 1
	EndWhile
	Return iResult
EndFunction

Function SendSelfMessage(String asMessage)
	Int iHandle = ModEvent.Create("vMYC_TrophySelfMessage" + TrophyName)
	If iHandle
		ModEvent.PushString(iHandle,asMessage)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send self message!",1)
	EndIf
EndFunction

Function SetTrophyFlags(Int aiTrophyType, Int aiTrophySize, Int aiTrophyLocation, Int aiTrophyExtras)
	TrophyFlags = 0
	TrophyFlags = Math.LogicalOr(TrophyFlags, aiTrophyType)
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophySize,8))
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophyLocation,16))
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophyExtras,24))
EndFunction

Function DisplayForm(Int aiTemplateID)
	Int idx = _TemplatesToDisplay.Find(0)
	_TemplatesToDisplay[idx] = aiTemplateID
EndFunction

Function DisplayFormArray(Int[] aiTemplateIDs)
	Int i = 0
	Int iCount = aiTemplateIDs.Length
	While i < iCount
		If aiTemplateIDs[i]
			DisplayForm(aiTemplateIDs[i])
		EndIf
		i += 1
	EndWhile
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/Trophy/" + TrophyName + ": " + sDebugString,iSeverity)
EndFunction

Function _CreateTemplates()
	If !TrophyBaseObject
		TrophyBaseObject = TrophyOrigin.PlaceAtMe(vMYC_TrophyEmptyBase, abInitiallyDisabled = True)
		TrophyBaseObject.MoveTo(TrophyOrigin,BaseX,BaseY,BaseZ)
		TrophyBaseObject.SetAngle(AngleX,AngleY,AngleZ)
		TrophyBaseObject.SetScale(Scale)
	EndIf
	If !_TemplateObjects[0]
		_TemplateObjects[0] = TrophyBaseObject
	EndIf
	OnSetTemplate()
EndFunction

Function _Display(ObjectReference akTarget = None, Int aiTrophyFlags = 0)
	If !akTarget
		akTarget = TrophyManager.GetTrophyOrigin()
	EndIf
	_TemplatesToDisplay = New Int[16]
	DebugTrace("Displaying...")
	If !TrophyBaseObject
		DebugTrace("WARNING! TrophyBaseObject not set, terrible things are about to happen :(",1)
	EndIf
	OnDisplayTrophy(aiTrophyFlags)
	If !TrophyFadeInFXS
		TrophyFadeInFXS = GetFormFromFile(0x0200a2bd,"vMYC_MeetYourCharacters.esp") as EffectShader
	EndIf
	Int i = 0
	Int iLen = _TemplatesToDisplay.Length
	DebugTrace("TemplatesToDisplay: " + iLen)
	While i < iLen && _TemplatesToDisplay[i]
		Int idx = _TemplatesToDisplay[i]
		If _TemplateObjects[idx]
			If _TemplateObjects[idx].GetBaseObject()
				_DisplayObject(akTarget,_TemplateObjects[idx])
			EndIf
		EndIf
		i += 1
	EndWhile
	
	i = 0
	iLen = _DisplayedObjects.Length
	DebugTrace("DisplayedObjects: " + iLen)
	While i < iLen && _DisplayedObjects[i]
		If !_DisplayedObjects[i].IsEnabled()
			DebugTrace("Enabling " + _DisplayedObjects[i] + "!")
			_DisplayedObjects[i].EnableNoWait(True)
		EndIf
		i += 1
	EndWhile
EndFunction

Function _DisplayObject(ObjectReference akTarget, ObjectReference akTemplate)
	;ObjectReference function PlaceAtMeRelative(ObjectReference akOrigin, Form akFormToPlace, float[] fOriginAng, \
	;									   float[] fRelativePos, float fZGlobalAngAdjust = 0.0, float fXLocalAngAdjust = 0.0,  \
	;									   float fYLocalAngAdjust = 0.0, float fZLocalAngAdjust = 0.0, float fZHangingOffset = 0.0, \
	;									   bool abInvertedLocalY = false, bool abInitiallyDisabled = false, bool abIsPropped = false, \
	;									   bool abIsHanging = false, bool abUseLocalRotation = false)
	
	DebugTrace("_DisplayObject(" + akTarget + ", " + akTemplate + ")")
	
	Int idx = _DisplayedObjects.Find(None)
	
	Float[] fRelativePos = GetRelativePosition(TrophyOrigin,akTemplate)
	Float[] fOriginAng = New Float[3]
	;Float[] fObjectAng = New Float[3]

	fOriginAng[0] = 0 ;akTarget.GetAngleX()
	fOriginAng[1] = 0 ;akTarget.GetAngleY()
	fOriginAng[2] = akTarget.GetAngleZ() ;akTarget.GetAngleZ()

	;fObjectAng[0] = akTemplate.GetAngleX()
	;fObjectAng[1] = akTemplate.GetAngleY()
	;fObjectAng[2] = akTemplate.GetAngleZ()

	If LocalRotation
		_DisplayedObjects[idx] = PlaceAtMeRelative(akTarget, akTemplate.GetBaseObject(), fOriginAng, fRelativePos, 0, 0, 0, fOriginAng[2], 0, false, false, false, false, LocalRotation)
	Else
		_DisplayedObjects[idx] = PlaceAtMeRelative(akTarget, akTemplate.GetBaseObject(), fOriginAng, fRelativePos, 0, 0, 0, 0, 0, false, false, false, false, LocalRotation)
	EndIf
	_DisplayedObjects[idx].SetScale(akTemplate.GetScale())
	
	DebugTrace("Template is " + akTemplate + ", Position is X:\t" + akTemplate.GetAngleX() + ", Y:\t" + akTemplate.GetAngleY() + ", Z:\t" + akTemplate.GetAngleZ())
	DebugTrace("  Target is " + _DisplayedObjects[idx] + ", Position is X:\t" + _DisplayedObjects[idx].GetAngleX() + ", Y:\t" + _DisplayedObjects[idx].GetAngleY() + ", Z:\t" + _DisplayedObjects[idx].GetAngleZ())
	;RotateLocal(_DisplayedObjects[idx],0,0,akTarget.GetAngleZ())
EndFunction

Function _Remove()
	DebugTrace("Hiding...")
	Int iResult = Remove()
	If iResult == 1
		Enabled = False
	Else
		DebugTrace("Failed with error " + iResult + "!",1)
	EndIf
EndFunction

Int Function _ActivateTrophy()
	DebugTrace("Activating...")
	Int iResult = ActivateTrophy()
	
	Return 1
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

ObjectReference function PlaceAtMeRelative(ObjectReference akOrigin, Form akFormToPlace, float[] fOriginAng, \
										   float[] fRelativePos, float fZGlobalAngAdjust = 0.0, float fXLocalAngAdjust = 0.0,  \
										   float fYLocalAngAdjust = 0.0, float fZLocalAngAdjust = 0.0, float fZHangingOffset = 0.0, \
										   bool abInvertedLocalY = false, bool abInitiallyDisabled = false, bool abIsPropped = false, \
										   bool abIsHanging = false, bool abUseSetLocal = false)

	ObjectReference myObject
    ObjectReference myTempMarker = akOrigin.PlaceAtMe(vMYC_TrophyEmptyBase)
	myTempMarker.MoveTo(myTempMarker, fRelativePos[0], fRelativePos[1], fRelativePos[2])
    
	float[] myNewPos = new float[3]
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
			float fAngleX = fRelativePos[3] * Math.Cos(fZLocalAngAdjust) + fYLocalAngAdjust * Math.Sin(fZLocalAngAdjust)
			float fAngleY = fYLocalAngAdjust * Math.Cos(fZLocalAngAdjust) - fRelativePos[3] * Math.Sin(fZLocalAngAdjust)
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
endFunction

Function SetLocalAngle(ObjectReference akObject, Float afLocalX, Float afLocalY, Float afLocalZ)
	Float fOAngleX = akObject.GetAngleX()
	Float fOAngleY = akObject.GetAngleY()
	Float fOAngleZ = akObject.GetAngleZ()

	DebugTrace("akObject is at AngleX:\t" + fOAngleX + ", AngleY:\t" + fOAngleY + ", AngleZ:\t" + fOAngleZ + "!")
	DebugTrace("akObject will be rotated by: X:\t" + afLocalX + ", Y:\t" + afLocalY + ", Z:\t" + afLocalZ + "!")
	float fAngleX = afLocalX * Math.Cos(afLocalZ) + afLocalY * Math.Sin(afLocalZ)
	float fAngleY = afLocalY * Math.Cos(afLocalZ) - afLocalX * Math.Sin(afLocalZ)
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

