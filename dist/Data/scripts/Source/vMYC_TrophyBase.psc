Scriptname vMYC_TrophyBase extends vMYC_BaseQuest  
{Base for trophy plugins. Don't modify this script! Extend it and modify that.}

;--=== Imports ===--

Import Utility
Import Game

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
{Name of the trophy that should be displayed when the player examines it.}

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

Bool			Property	Available			= False		Auto Hidden
Bool			Property	Enabled				= True		Auto Hidden

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
Float			Property	Scale				= 1.0		Auto

Activator 		Property	vMYC_TrophyEmptyBase			Auto
{Base Activator to be placed as a base object if none other is defined.}

;--=== Variables ===--

Int					_TrophyVersion

vMYC_TrophyManager	_TrophyManager

ObjectReference[]	_DisplayedObjects

;--=== Events/Functions ===--

Event OnGameReload()
	CheckVars()
	If !TrophyName
		If IsRunning()
			Stop()
		EndIf
		Return
	EndIf
	RegisterForModEvent("vMYC_TrophyManagerReady","OnTrophyManagerReady")
	RegisterForModEvent("vMYC_TrophySelfMessage" + TrophyName,"OnTrophySelfMessage")
EndEvent

Event OnInit()
	If !IsRunning()
		Return
	EndIf

	If !_DisplayedObjects
		_DisplayedObjects = New ObjectReference[128]
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
	RegisterForModEvent("vMYC_TrophyManagerReady","OnTrophyManagerReady")
	RegisterForModEvent("vMYC_TrophySelfMessage" + TrophyName,"OnTrophySelfMessage")
	DoInit()
	
EndEvent

Event OnTrophyManagerReady(Form akSender)
	Bool bIsAvailable = _IsAvailable()
	If !_TrophyManager && akSender as vMYC_TrophyManager
		_TrophyManager = akSender as vMYC_TrophyManager
		SendRegisterEvent()
	EndIf

	If _TrophyVersion != TrophyVersion 
		_TrophyVersion = TrophyVersion
	EndIf
	If bIsAvailable != Available
		Available = bIsAvailable
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
	Wait(5)
	_Display()
EndFunction

Event OnTrophySelfMessage(String asMessage)
	
EndEvent

Event OnUpdate()
	
EndEvent

Function DoInit()
	CheckVars()
EndFunction

Int Function _IsAvailable()
	Int iAvailable = IsAvailable()
	;FIXME - Always return >0 for testing!
	If !iAvailable
		iAvailable = 1
	EndIf
	Return iAvailable
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}

	Return 0
EndFunction

Int Function Display(Int aiDisplayFlags = 0)
{User code for display}
	Return 1
EndFunction

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

Function _Display()
	DebugTrace("Displaying...")
	If !vMYC_TrophyEmptyBase
		vMYC_TrophyEmptyBase = GetFormFromFile(0x0203055F,"vMYC_MeetYourCharacters.esp") as Activator
	EndIf
	If !TrophyBaseObject
		DebugTrace("TrophyBaseObject is not defined! Trophy will be based around absolute coordinates.")
		ObjectReference kTrophyOrigin = _TrophyManager.GetTrophyOrigin()
		TrophyBaseObject = kTrophyOrigin.PlaceAtMe(vMYC_TrophyEmptyBase,abInitiallyDisabled = True)
		TrophyBaseObject.MoveTo(kTrophyOrigin,BaseX + OffsetX,BaseY + OffsetY,BaseZ + OffsetZ)
		TrophyBaseObject.SetAngle(AngleX,AngleY,AngleZ)
		TrophyBaseObject.SetScale(Scale)
		TrophyBaseObject.Enable(0)
	EndIf
	Int iResult = Display()
	If iResult == 1
		Enabled = True
		DebugTrace("Succeeded!")
	Else
		DebugTrace("Failed with error " + iResult + "!",1)
	EndIf
	If !TrophyFadeInFXS
		TrophyFadeInFXS = GetFormFromFile(0x0200a2bd,"vMYC_MeetYourCharacters.esp") as EffectShader
	EndIf
	Int i = _DisplayedObjects.Length
	While i > 0
		i -= 1
		If _DisplayedObjects[i]
			DebugTrace("Found object at index " + i + ": " + _DisplayedObjects[i])
			_DisplayedObjects[i].EnableNoWait(True)
			Wait(0.1)
			TrophyFadeInFXS.Play(_DisplayedObjects[i],1)
		EndIf
	EndWhile
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

Function CheckVars()

EndFunction

Function DoShutdown()
	UnregisterForUpdate()
EndFunction

Function PlaceTemplate(ObjectReference akTemplate)
	PlaceForm(akTemplate.GetBaseObject(), \
		akTemplate.GetPositionX(),akTemplate.GetPositionY(),akTemplate.GetPositionZ(), \
		akTemplate.GetAngleX(),akTemplate.GetAngleY(),akTemplate.GetAngleZ(), \
		akTemplate.GetScale())
EndFunction

Function PlaceForm(Form akForm, Float afOffsetX = 0.0, Float afOffsetY = 0.0, Float afOffsetZ = 0.0, Float afAngleX = 0.0, Float afAngleY = 0.0, Float afAngleZ = 0.0, Float afScale = 1.0)
	If !akForm
		Return
	EndIf
	Int idx = _DisplayedObjects.Find(None)
	_DisplayedObjects[idx] = TrophyBaseObject.PlaceAtMe(akForm,abInitiallyDisabled = True)
	If afOffsetX || afOffsetY || afOffsetZ
		_DisplayedObjects[idx].MoveTo(TrophyBaseObject,afOffsetX,afOffsetY,afOffsetZ)
	EndIf
	If afAngleX || afAngleY || afAngleZ
		_DisplayedObjects[idx].SetAngle(afAngleX,afAngleY,afAngleZ)
	EndIf
	If afScale != 1.0
		_DisplayedObjects[idx].SetScale(afScale)
	ElseIf Scale != 1.0
		_DisplayedObjects[idx].SetScale(Scale)
	EndIf
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

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/Trophy/" + TrophyName + ": " + sDebugString,iSeverity)
EndFunction
