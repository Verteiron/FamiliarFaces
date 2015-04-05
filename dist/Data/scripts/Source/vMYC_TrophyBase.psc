Scriptname vMYC_TrophyBase extends vMYC_BaseQuest  
{Base for trophy plugins. Don't modify this script! Extend it and modify that.}

;=== [ vMYC_TrophyBase.psc ] ==============================================---
; Base for Trophy plugin files. Extend this into your own file.
; Handles:
;  Creation and registration of Trophy templates
;  Placement and display of Trophy forms
;========================================================---

;=== Imports ===--

Import Utility
Import Game
Import Math
Import vMYC_PlacementUtils
Import vMYC_Registry
Import vMYC_Session

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

;=== Properties ===--

Activator		Property	TrophyActivator		= None		Auto Hidden
{The trophy activator object. More items can be added by creating additional properties but custom code will be needed in the Display Function.}

String			Property	TrophyName			= "Trophy"	Auto
{Name of the trophy to be used by scripts. Same rules as a Papyrus variable name.}

String			Property	TrophyFullName		= "Demo"	Auto
{Name of the trophy for display purposes.}

EffectShader	Property	TrophyFadeInFXS		= None		Auto
{Shader that should play when the trophy first appears.}

Int				Property	TrophyPriority		= 100		Auto
{How great/unique of an achievement is this? LOWER IS BETTER! DLC (or large mod such as Falskaar) completion is 2, Faction completion is 4. See docs for more info!.}

Int				Property	TrophyType			= 0			Auto Hidden
Int				Property	TrophySize			= 0			Auto Hidden
Int				Property	TrophyLoc			= 0			Auto Hidden
Int				Property	TrophyExtras		= 0			Auto Hidden

Int				Property	TrophyFlags			= 0			Auto Hidden
{See TROPHY enums above.}

Int				Property	TrophyVersion					Auto Hidden
{Increment this if the trophy's requirements or mesh have changed.}

String[]		Property	TrophyExclusionList				Auto Hidden
{If this trophy is displayed, prevent these trophies from being displayed. Use with caution!.}

Int				Property	Available			= -1		Auto Hidden
Bool			Property	Enabled				= True		Auto Hidden

Bool			Property	DoNotRegister		= False		Auto

ObjectReference	Property	TrophyBaseObject	= None 		Auto Hidden
{The base object that defines the trophy's location in the alcove. If missing, it will be placed at the coordinates defined in the Base value below.}

ObjectReference	Property	TrophyTemplate		= None		Auto Hidden
{An empty property used to force a new template into high memory long enough for it to be rotated and scaled.}

;The following are used to place the object in absolute terms if a preset position is not being used. The origin is the base of the player statue
Float			Property	BaseX					= 0.0		Auto Hidden
Float			Property	BaseY					= 0.0		Auto Hidden
Float			Property	BaseZ					= 0.0		Auto Hidden

;The following are used to place the object relative to its "base", that is the origin of its position
Float			Property	OffsetX			= 0.0		Auto Hidden
Float			Property	OffsetY			= 0.0		Auto Hidden
Float			Property	OffsetZ			= 0.0		Auto Hidden
Float			Property	AngleX			= 0.0		Auto Hidden
Float			Property	AngleY			= 0.0		Auto Hidden
Float			Property	AngleZ			= 0.0		Auto Hidden
Float			Property	Scale			= 1.0		Auto Hidden

Bool			Property	LocalRotation	= False		Auto Hidden
{Use this if your object isn't getting rotated correctly!.}

Activator 		Property	vMYC_TrophyEmptyBase		Auto
{Base Activator to be placed as a base object if none other is defined.}

Activator 		Property	vMYC_TrophyObjectBase		Auto
{Activator to be placed as a Template, since unloaded objects don't get rotated.}

Float			Property	AngleDelta		= 0.0		Auto Hidden

ObjectReference	Property	TrophyOrigin				Auto Hidden

vMYC_TrophyManager	Property	TrophyManager			Auto Hidden

String			Property	CharacterID					Auto Hidden
{FIXME: Set during display, unset afterward. NOT THREAD SAFE!.}

;=== Variables ===--

Int					_TrophyVersion

Int[]				_TemplatesToDisplay

Int[]				_BannersToDisable

Form[]				_BannersToDisplay

ObjectReference[]	_DisplayedObjects

ObjectReference[]	_TemplateObjects

Int 				_FIXMEImpBannerID

;=== Public/user functions ===--

;=== These should be overridden by the user's script

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}

	Return 0
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	
EndEvent

Int Function Remove()
{User code for hide.}
	Return 1
EndFunction

Int Function RefreshTrophy()
{User code for refresh.}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation.}
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
{Create a new Trophy template from akForm, with the specified offset, angle and scale.
 Returns: Index of the new template to be used with other functions.}

	;DebugTrace("Creating template from " + akForm + ", X:\t" + afOffsetX + ", Y:\t" + afOffsetY + ", Z:\t" + afOffsetZ + ", aX:\t" + afAngleX + ", aY:\t" + afAngleY + ", aZ:\t" + afAngleZ + ", S:\t" + afScale)
	Int idx = _TemplateObjects.Find(None)
	_TemplateObjects[idx] = TrophyBaseObject.PlaceAtMe(vMYC_TrophyObjectBase, abInitiallyDisabled = True)
	vMYC_TrophyObject TrophyObject = _TemplateObjects[idx] as vMYC_TrophyObject
	TrophyObject.SetParentObject(Self)
	TrophyObject.SetFormData(akForm, afOffsetX, afOffsetY, afOffsetZ, afAngleX, afAngleY, afAngleZ, afScale)
	TrophyObject.UpdatePosition()
	;DebugTrace("Object is at X:\t" + TrophyObject.GetPositionX() + ", Y:\t" + TrophyObject.GetPositionY() + ", Z:\t" + TrophyObject.GetPositionZ() + ", aX:\t" + TrophyObject.GetAngleX() + ", aY:\t" + TrophyObject.GetAngleY() + ", aZ:\t" + TrophyObject.GetAngleZ() + ", S:\t" + TrophyObject.GetScale())
	;If akForm.GetFormID() == 0x000c5699
	;	DebugTrace("THIS IS THE BANNER GUYS! " + idx)
	;	_FIXMEImpBannerID = idx
	;EndIf
	Return idx
EndFunction

Int Function SetTemplate(ObjectReference akTargetObject)
{Create a Trophy template from an existing objects placed in the AlcoveLayout cell.
 Returns: Index of the template to be used with other functions.}
	If !akTargetObject 
		Return 0
	EndIf
	akTargetObject.EnableNoWait(False)
	Return CreateTemplate(akTargetObject.GetBaseObject(), akTargetObject.GetPositionX(), akTargetObject.GetPositionY(), akTargetObject.GetPositionZ(), akTargetObject.GetAngleX(), akTargetObject.GetAngleY(), akTargetObject.GetAngleZ(), akTargetObject.GetScale())
EndFunction

Int[] Function SetTemplateArray(ObjectReference[] akTargetObjects)
{An array version of SetTemplate. 
 Returns: Int array of template indexes to be used with other functions.}
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
{Set flags for this trophy based on enums at the top of the file.}
	TrophyFlags = 0
	TrophyFlags = Math.LogicalOr(TrophyFlags, aiTrophyType)
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophySize,8))
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophyLocation,16))
	TrophyFlags = Math.LogicalOr(TrophyFlags, Math.LeftShift(aiTrophyExtras,24))
EndFunction

Function ReserveBanner(Int aiBannerPosition, String asBannerType = "Standing")
{Prevent any banners being placed at aiBannerPosition.
 Used to prevent trophy from clipping or blocking a dynamicly placed banner.}
	Int idx = _BannersToDisable.Find(-1)
	_BannersToDisable[idx] = aiBannerPosition
	If idx + 1 < _BannersToDisable.Length
		_BannersToDisable[idx + 1] = -1
	EndIf
EndFunction

Function DisplayBanner(Form akBannerForm)
{Display akBannerForm as a banner at the first available banner position.}
	Int idx = _BannersToDisplay.Find(None)
	_BannersToDisplay[idx] = akBannerForm
EndFunction

Function DisplayForm(Int aiTemplateID)
{Display the specified form template.}
	Int idx = _TemplatesToDisplay.Find(0)
	_TemplatesToDisplay[idx] = aiTemplateID
EndFunction

Function DisplayFormArray(Int[] aiTemplateIDs)
{Array version of DisplayForm.}
	Int i = 0
	Int iCount = aiTemplateIDs.Length
	While i < iCount
		If aiTemplateIDs[i]
			DisplayForm(aiTemplateIDs[i])
		EndIf
		i += 1
	EndWhile
EndFunction

;=== Functions for the user to store custom trophy-related data ===--

Int Function LoadIntValue(String asDataName = "CustomInt")
	Return GetSessionInt("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
EndFunction

Int[] Function LoadIntArray(Int[] aiArray,String asDataName = "CustomIntArr")
	Int jIntArray = GetSessionObj("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
	Int i = 0
	Int iCount = JArray.Count(jIntArray)
	Int[] iResult = CreateIntArray(iCount)
	While i < 0
		iResult[i] = JArray.GetInt(jIntArray,i)
		i += 1
	EndWhile
	Return iResult
EndFunction

Float Function LoadFloatValue(String asDataName = "CustomFloat")
	Return GetSessionFlt("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
EndFunction

Float[] Function LoadFloatArray(String asDataName = "CustomFloatArr")
	Int jFloatArray = GetSessionObj("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
	Int i = 0
	Int iCount = JArray.Count(jFloatArray)
	Float[] fResult = CreateFloatArray(iCount)
	While i < 0
		fResult[i] = JArray.GetFlt(jFloatArray,i)
		i += 1
	EndWhile
	Return fResult
EndFunction

String Function LoadStringValue(String asDataName = "CustomString")
	Return GetSessionStr("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
EndFunction

String[] Function LoadStringArray(String asDataName = "CustomStringArr")
	Int jStringArray = GetSessionObj("Characters." + CharacterID + ".TrophyData." + TrophyName + "." + asDataName)
	Int i = 0
	Int iCount = JArray.Count(jStringArray)
	String[] sResult = CreateStringArray(iCount)
	While i < 0
		sResult[i] = JArray.GetStr(jStringArray,i)
		i += 1
	EndWhile
EndFunction

Function SaveIntValue(Int aiValue,String asDataName = "CustomInt")
	SetSessionInt("TrophyData." + TrophyName + "." + asDataName,aiValue)
EndFunction

Function SaveIntArray(Int[] aiArray,String asDataName = "CustomIntArr")
	SetSessionObj("TrophyData." + TrophyName + "." + asDataName,JArray.objectWithInts(aiArray))
EndFunction

Function SaveFloatValue(Float afValue,String asDataName = "CustomFloat")
	SetSessionFlt("TrophyData." + TrophyName + "." + asDataName,afValue)
EndFunction

Function SaveFloatArray(Float[] afArray,String asDataName = "CustomFloatArr")
	SetSessionObj("TrophyData." + TrophyName + "." + asDataName,JArray.objectWithFloats(afArray))
EndFunction

Function SaveStringValue(String asValue,String asDataName = "CustomString")
	SetSessionStr("TrophyData." + TrophyName + "." + asDataName,asValue)
EndFunction

Function SaveStringArray(String[] asArray,String asDataName = "CustomStringArr")
	SetSessionObj("TrophyData." + TrophyName + "." + asDataName,JArray.objectWithStrings(asArray))
EndFunction

;=== Events/Functions ===--

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

	If !_BannersToDisplay
		_BannersToDisplay = New Form[128]
	EndIf
	
	If !_BannersToDisable
		_BannersToDisable = New Int[16]
		_BannersToDisable[0] = -1
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
	If !TrophyManager && akSender as vMYC_TrophyManager
		TrophyManager = akSender as vMYC_TrophyManager
	;	TrophyManager.ThreadCount += 1
	;	While TrophyManager.ThreadCount > TrophyManager.ThreadMax 
	;		DebugTrace("TrophyManager.ThreadCount is " + TrophyManager.ThreadCount + ", waiting for threadscount to drop...")
	;		WaitMenuMode(RandomFloat(0.25,1))
	;	EndWhile
		SendRegisterEvent()
	;	TrophyManager.ThreadCount -= 1
	EndIf
	If _TrophyVersion != TrophyVersion 
		_TrophyVersion = TrophyVersion
	EndIf
	If Available < 0
		Int iAvailable = _IsAvailable()
		If iAvailable != Available
			Available = iAvailable
		EndIf
	EndIf
	If TrophyManager && !_TemplateObjects[0]
		_CreateTemplates()
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
	If !vMYC_TrophyObjectBase
		vMYC_TrophyObjectBase = GetFormFromFile(0x02033e5c,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	If !TrophyFadeInFXS
		TrophyFadeInFXS = GetFormFromFile(0x0200a2bd,"vMYC_MeetYourCharacters.esp") as EffectShader
	EndIf
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

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/Trophy/" + TrophyName + ": " + sDebugString,iSeverity)
EndFunction

Int Function _IsAvailable()
	Int iAvailable = IsAvailable()
	;FIXME - Always return >0 for testing!
	;If !iAvailable
	;	iAvailable = 1
	;EndIf
	Return iAvailable
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

Function _Place(ObjectReference akTarget = None, Int aiTrophyFlags = 0, String asCharacterID = "")
	If !akTarget
		akTarget = TrophyManager.GetTrophyOrigin()
	EndIf
	_TemplatesToDisplay = New Int[16]
	;DebugTrace("Displaying...")
	If !TrophyBaseObject
		DebugTrace("WARNING! TrophyBaseObject not set, terrible things are about to happen :(",1)
	EndIf

	CharacterID = asCharacterID	
	DebugTrace("Calling OnDisplayTrophy with aiTrophyFlags: " + aiTrophyFlags + "...")
	
	;Despite its name, this merely fills _TemplatesToDisplay with the TemplateIDs that will be placed
	OnDisplayTrophy(aiTrophyFlags)
	CharacterID = ""
	
	Int i
	Int iLen

	;FIXME: With the new Alcove layout, banners will probably not get blocked like they used to.
	;i = 0
	;iLen = _BannersToDisable.Find(-1)
	;If iLen
	;	DebugTrace("BannersToDisable: " + iLen)
	;endIf
	;While i < iLen 
	;	TrophyManager.DisableBannerPosition(akTarget,_BannersToDisable[i])
	;	i += 1
	;EndWhile
	
	i = 0
	iLen = _BannersToDisplay.Find(None)
	If iLen
		DebugTrace("BannersToDisplay: " + iLen)
	EndIf
	While i < iLen && _BannersToDisplay[i]
		If _BannersToDisplay[i]
			_DisplayBanner(akTarget,_BannersToDisplay[i])
		EndIf
		i += 1
	EndWhile
	
	i = 0
	iLen = _TemplatesToDisplay.Find(0)
	If iLen
		DebugTrace("TemplatesToDisplay: " + iLen)
	EndIf
	String sTargetFormID = GetFormIDString(akTarget)
	While i < iLen && _TemplatesToDisplay[i]
		Int idx = _TemplatesToDisplay[i]
		If _TemplateObjects[idx]
			;If _TemplateObjects[idx].GetBaseObject().GetFormID() == 0x000c5699
			;	DebugTrace("THIS IS THE BANNER GUYS! " + _TemplateObjects[idx])
			;EndIf
			;If _TemplateObjects[idx].GetBaseObject()
				;DebugTrace("Registering template " + idx + " - " + _TemplateObjects[idx] + " for event vMYC_TrophyDisplay" + TrophyName + sTargetFormID + "!")
				(_TemplateObjects[idx] as vMYC_TrophyObject).TrophyIndex = idx
				_TemplateObjects[idx].RegisterForModEvent("vMYC_TrophyDisplay" + TrophyName + sTargetFormID,"OnTrophyDisplay")	
			;EndIf
		EndIf
		i += 1
	EndWhile

	;i = 0
	;iLen = _DisplayedObjects.Length
	DebugTrace("Placed " + iLen + " objects for target " + akTarget)
	;While i < iLen && _DisplayedObjects[i]
	;	If !_DisplayedObjects[i].IsEnabled()
	;		DebugTrace("Enabling " + _DisplayedObjects[i] + "!")
	;		_DisplayedObjects[i].EnableNoWait(True)
	;	EndIf
	;	i += 1
	;EndWhile
	
EndFunction

Function _Display(ObjectReference akTarget = None)
	If !akTarget
		akTarget = TrophyManager.GetTrophyOrigin()
	EndIf
	
	SendDisplayEvent(akTarget)
EndFunction

Function SendDisplayEvent(ObjectReference akTarget)
	String sTargetFormID = GetFormIDString(akTarget)
	Int iHandle = ModEvent.Create("vMYC_TrophyDisplay" + TrophyName + sTargetFormID)
	If iHandle
		ModEvent.PushForm(iHandle,akTarget)
		ModEvent.PushBool(iHandle,False)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING, couldn't send vMYC_TrophyDisplay" + TrophyName + sTargetFormID + " event!",1)
	EndIf
EndFunction

Function _DisplayObject(ObjectReference akTarget, ObjectReference akTemplate)
	;ObjectReference Function PlaceAtMeRelative(ObjectReference akOrigin, Form akFormToPlace, Float[] fOriginAng, \
	;									   Float[] fRelativePos, Float fZGlobalAngAdjust = 0.0, Float fXLocalAngAdjust = 0.0,  \
	;									   Float fYLocalAngAdjust = 0.0, Float fZLocalAngAdjust = 0.0, Float fZHangingOffset = 0.0, \
	;									   Bool abInvertedLocalY = false, Bool abInitiallyDisabled = false, Bool abIsPropped = false, \
	;									   Bool abIsHanging = false, Bool abUseLocalRotation = false)
	
	DebugTrace("_DisplayObject(" + akTarget + ", " + akTemplate + ")")
	
	If akTemplate as vMYC_TrophyObject
		(akTemplate as vMYC_TrophyObject).PlaceTrophyForm(akTarget)
		Return
	EndIf
	Int idx = _DisplayedObjects.Find(None)
	
	Float[] fRelativePos = GetRelativePosition(TrophyOrigin,akTemplate)
	Float[] fOriginAng = New Float[3]
	;Float[] fObjectAng = New Float[3]

	fOriginAng[0] = akTarget.GetAngleX()
	fOriginAng[1] = akTarget.GetAngleY()
	fOriginAng[2] = akTarget.GetAngleZ()

	;fObjectAng[0] = akTemplate.GetAngleX()
	;fObjectAng[1] = akTemplate.GetAngleY()
	;fObjectAng[2] = akTemplate.GetAngleZ()

	;If LocalRotation
		_DisplayedObjects[idx] = PlaceAtMeRelative(akTarget, akTemplate.GetBaseObject(), fOriginAng, fRelativePos, 0, 0, 0, fOriginAng[2], 0, false, false, false, false, True)
	;Else
		;_DisplayedObjects[idx] = PlaceAtMeRelative(akTarget, akTemplate.GetBaseObject(), fOriginAng, fRelativePos, 0, 0, 0, 0, 0, false, false, false, false, LocalRotation)
	;EndIf
	_DisplayedObjects[idx].SetScale(akTemplate.GetScale())

	DebugTrace("Placed form " + akTemplate.GetBaseObject() + " relative to " + akTarget + "====--\n" + \
		       " Template is at X:\t" + akTemplate.GetPositionX() + ", Y:\t" + akTemplate.GetPositionY() + ", Z:\t" + akTemplate.GetPositionZ() + ", aX:\t" + akTemplate.GetAngleX() + ", aY:\t" + akTemplate.GetAngleY() + ", aZ:\t" + akTemplate.GetAngleZ() + ", S:\t" + akTemplate.GetScale() + "\n" + \
			   "   Origin is at X:\t" + akTarget.GetPositionX() + ", Y:\t" + akTarget.GetPositionY() + ", Z:\t" + akTarget.GetPositionZ() + ", aX:\t" + akTarget.GetAngleX() + ", aY:\t" + akTarget.GetAngleY() + ", aZ:\t" + akTarget.GetAngleZ() + ", S:\t" + akTarget.GetScale() + "\n" + \
			   "PlacedObj is at X:\t" + _DisplayedObjects[idx].GetPositionX() + ", Y:\t" + _DisplayedObjects[idx].GetPositionY() + ", Z:\t" + _DisplayedObjects[idx].GetPositionZ() + ", aX:\t" + _DisplayedObjects[idx].GetAngleX() + ", aY:\t" + _DisplayedObjects[idx].GetAngleY() + ", aZ:\t" + _DisplayedObjects[idx].GetAngleZ() + ", S:\t" + _DisplayedObjects[idx].GetScale() + "\n" + \
			   "   fRelativePos 0:\t" + fRelativePos[0] + ", 1:\t" + fRelativePos[1] + ", 2:\t" + fRelativePos[2] + ", 3:\t" + fRelativePos[3] + ", 4:\t" + fRelativePos[4] + ", 5:\t" + fRelativePos[5] + "\n" + \
			   "=====---")
	
	;DebugTrace("Template is " + akTemplate + ", Position is X:\t" + akTemplate.GetAngleX() + ", Y:\t" + akTemplate.GetAngleY() + ", Z:\t" + akTemplate.GetAngleZ())
	;DebugTrace("  Target is " + _DisplayedObjects[idx] + ", Position is X:\t" + _DisplayedObjects[idx].GetAngleX() + ", Y:\t" + _DisplayedObjects[idx].GetAngleY() + ", Z:\t" + _DisplayedObjects[idx].GetAngleZ())
	;RotateLocal(_DisplayedObjects[idx],0,0,akTarget.GetAngleZ())
EndFunction

ObjectReference Function _GetBannerTemplate(ObjectReference akTarget, String asBannerType = "Standing")
	Int iBannerIndex = TrophyManager.GetFreeBannerForTarget(akTarget,asBannerType)
	Keyword kBannerKeyword = Keyword.GetKeyword("vMYC_Banner" + asBannerType + iBannerIndex)
	Return TrophyOrigin.GetLinkedRef(kBannerKeyword)
EndFunction

Function _DisplayBanner(ObjectReference akTarget, Form akBannerForm, String asBannerType = "Standing")
	ObjectReference kBannerTarget = _GetBannerTemplate(akTarget,asBannerType)
	If !kBannerTarget && asBannerType == "Standing"
		; Standing banners are smaller than wall banners so if we run out of space, try to hang it instead
		asBannerType = "Hanging" 
		kBannerTarget = _GetBannerTemplate(akTarget,asBannerType)
	EndIf
	If !kBannerTarget
		DebugTrace("WARNING, 404 BannerTarget not found. Even tried multi.",1)
		Return 
	EndIf
	ObjectReference kBanner = kBannerTarget.PlaceAtMe(akBannerForm, abInitiallyDisabled = True)
	ObjectReference kAnchor = kBannerTarget.GetLinkedRef()
	;DebugTrace("Banner is " + kBanner + ", Anchor is " + kAnchor)
	If kAnchor
		DisplayForm(SetTemplate(kAnchor))
	EndIf
	DisplayForm(SetTemplate(kBanner))
	kBanner.Delete()
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

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction
