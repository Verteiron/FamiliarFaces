Scriptname vFFC_CompatBase extends vFFC_BaseQuest  
{Base for compatibility modules. Don't modify this script! Extend it and modify that.}

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry

;=== Properties ===--

String			Property	ModuleName						Auto

Bool			Property	Enabled							Auto Hidden

;=== Variables ===--

;=== Events/Functions ===--

Event OnGameReload()
	CheckVars()
	RegisterForModEvent("vFFC_CompatCheck","OnCompatCheck")
	RegisterForModEvent("vFFC_CompatSelfMessage" + ModuleName,"OnCompatSelfMessage")
	Int iResult = UpkeepModule()
	If iResult != 1
		DebugTrace("Upkeep failed with error " + iResult + "!",1)
	EndIf
EndEvent

Event OnInit()
	RegisterForModEvent("vFFC_CompatCheck","OnCompatCheck")
	RegisterForModEvent("vFFC_CompatSelfMessage" + ModuleName,"OnCompatSelfMessage")
	If IsRunning()
		DoInit()
	EndIf
EndEvent

Event OnCompatCheck(Form akSender)
	SetRegBool("Config.Compat." + ModuleName + ".Enabled",Enabled)
	Bool bIsRequired = _IsRequired()
	If bIsRequired && !Enabled
		_StartModule()
	ElseIf !bIsRequired && Enabled
		_StopModule()
	EndIf
	Int iHandle = ModEvent.Create("vFFC_CompatReport")
	If iHandle
		ModEvent.PushString(iHandle,ModuleName)
		ModEvent.PushForm(iHandle,Self)
		ModEvent.PushBool(iHandle,bIsRequired)
		ModEvent.PushBool(iHandle,Enabled)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send CompatReport!",1)
	EndIf
EndEvent

Event OnCompatSelfMessage(String asMessage)
	
EndEvent

Event OnUpdate()
	
EndEvent

Function DoInit()
	CheckVars()
EndFunction

Bool Function _IsRequired()
	Bool bIsRequired = IsRequired()
	SetRegBool("Config.Compat." + ModuleName + ".Required",bIsRequired)
	Return bIsRequired
EndFunction

Bool Function IsRequired()
{Return true if the mod that this module supports is installed.}

	Return False
EndFunction

Int Function StartModule()
{User code for startup.}
	Return 1
EndFunction

Int Function StopModule()
{User code for shutdown.}
	Return 1
EndFunction

Int Function UpkeepModule()
{User code for upkeep.}
	Return 1
EndFunction

Function _StartModule()
	DebugTrace("Starting...")
	Int iResult = StartModule()
	If iResult == 1
		Enabled = True
		SetRegBool("Config.Compat." + ModuleName + ".Enabled",True)
		DebugTrace("Succeeded!")
	Else
		SetRegBool("Config.Compat." + ModuleName + ".Enabled",False)
		DebugTrace("Failed with error " + iResult + "!",1)
	EndIf
EndFunction

Function _StopModule()
	DebugTrace("Stopping...")
	Int iResult = StopModule()
	If iResult == 1
		Enabled = False
		SetRegBool("Config.Compat." + ModuleName + ".Enabled",False)
	Else
		DebugTrace("Failed with error " + iResult + "!",1)
	EndIf
EndFunction

Int Function RestartModule()
	DebugTrace("Restarting...")
	StopModule()
	StartModule()
	Return 1
EndFunction

Function CheckVars()

EndFunction

Function DoShutdown()
	UnregisterForUpdate()
EndFunction

Function SendSelfMessage(String asMessage)
	Int iHandle = ModEvent.Create("vFFC_CompatSelfMessage" + ModuleName)
	If iHandle
		ModEvent.PushString(iHandle,asMessage)
		ModEvent.Send(iHandle)
	Else
		DebugTrace("WARNING: Couldn't send self message!",1)
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/Compat/" + ModuleName + ": " + sDebugString,iSeverity)
EndFunction
