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

Int				Property	TROPHY_RADIUS_TINY		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_RADIUS_SMALL		= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_RADIUS_MEDIUM	= 0x00000002		AutoReadOnly Hidden
Int				Property	TROPHY_RADIUS_LARGE		= 0x00000004		AutoReadOnly Hidden
Int				Property	TROPHY_RADIUS_HUGE		= 0x00000008		AutoReadOnly Hidden

Int				Property	TROPHY_HEIGHT_SHORT		= 0x00000000		AutoReadOnly Hidden
Int				Property	TROPHY_HEIGHT_MEDIUM	= 0x00000001		AutoReadOnly Hidden
Int				Property	TROPHY_HEIGHT_TALL		= 0x00000002		AutoReadOnly Hidden

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

;--=== Variables ===--

Int					_TrophyVersion

vMYC_TrophyManager	_TrophyManager

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
EndFunction

Event OnTrophySelfMessage(String asMessage)
	
EndEvent

Event OnUpdate()
	
EndEvent

Function DoInit()
	CheckVars()
EndFunction

Bool Function _IsAvailable()
	Bool bIsAvailable = IsAvailable()
	Return bIsAvailable
EndFunction

Bool Function IsAvailable()
{Return true if this trophy is available to the current player.}

	Return False
EndFunction

Int Function Display()
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
	Int iResult = Display()
	If iResult == 1
		Enabled = True
		DebugTrace("Succeeded!")
	Else
		DebugTrace("Failed with error " + iResult + "!",1)
	EndIf
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
