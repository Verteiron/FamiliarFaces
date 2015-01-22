Scriptname vMYC_TrophyBase extends vMYC_BaseQuest  
{Base for trophy plugins. Don't modify this script! Extend it and modify that.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int				Property	TROPHY_TYPE_BANNER		= 1		AutoReadOnly
Int				Property	TROPHY_TYPE_PEDESTAL	= 2		AutoReadOnly
Int				Property	TROPHY_TYPE_FLOORSMALL	= 3		AutoReadOnly
Int				Property	TROPHY_TYPE_FLOORLARGE	= 4		AutoReadOnly
Int				Property	TROPHY_TYPE_WALLMOUNT	= 5		AutoReadOnly

;--=== Properties ===--

Activator		Property	TrophyActivator					Auto
{The trophy activator object. More items can be added by creating additional properties but custom code will be needed in the Display function.}

String			Property	TrophyName						Auto
{Name of the trophy that should be displayed when the player examines it.}

EffectShader	Property	TrophyFadeInFXS					Auto
{Shader that should play when the trophy first appears.}

Int				Property	TrophyPriority					Auto
{How great/unique of an achievement is this? LOWER IS BETTER! DLC (or large mod such as Falskaar) completion is 2, Faction completion is 4. See docs for more info!}

Int				Property	TrophyType						Auto
{1 = Banner, 2 = small item on a pedestal or shelf, 3 = small item that sits on the floor, 4 = large item that requires a tall space, 5 = wall-mounted item}

Int				Property	TrophyVersion					Auto
{Increment this if the trophy's requirements or mesh have changed.}

Bool			Property	Available						Auto Hidden
Bool			Property	Enabled							Auto Hidden

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

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/Trophy/" + TrophyName + ": " + sDebugString,iSeverity)
EndFunction
