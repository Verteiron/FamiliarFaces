Scriptname vMYC_DataManager extends Quest
{Save and restore character and other data using the registry.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

String				Property META			= ".Info."				Auto Hidden

;=== Properties ===--

Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden

vMYC_HangoutManager Property HangoutManager 						Auto

Int 				Property SerializationVersion = 3 				Auto Hidden

Actor 				Property PlayerRef 								Auto
{The Player, duh}

;=== Variables ===--

;=== Events ===--

Event OnInit()
	If IsRunning()
		SetSessionID()
		DoUpkeep()
	EndIf
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
	RegisterForSingleUpdate(2)
EndEvent

;=== Functions - Startup ===--

Function DoUpkeep(Bool bInBackground = True)
	{Run whenever the player loads up the Game.}
	RegisterForModEvent("vMYC_SetCustomHangout","OnSetCustomHangout")
	If bInBackground
		NeedUpkeep = True
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	IsBusy = True
	DebugTrace("Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	InitReg()
	If !GetRegBool("Config.DefaultsSet")
		SetRegObj("Characters",JMap.Object(),True)
		SetRegObj("Hangouts",JMap.Object(),True)
		SetRegObj("Shrine",JMap.Object(),True)
		SetConfigDefaults()
	EndIf
	DebugTrace("Finished upkeep!")
	SendModEvent("vMYC_UpkeepEnd")
	SavePlayerData()
EndFunction

Function SetConfigDefaults(Bool abForce = False)
	If !GetRegBool("Config.DefaultsSet") || abForce
		DebugTrace("Setting Config defaults!")
		SetRegBool("Config.Enabled",True,True,True)
		SetRegBool("Config.Compat.Enabled",True,True,True)
		SetRegBool("Config.Warnings.Enabled",True,True,True)
		SetRegBool("Config.Debug.Perf.Threads.Limit",False,True,True)
		SetRegInt ("Config.Debug.Perf.Threads.Max",50,True,True)
		SetRegBool("Config.DefaultsSet",True)
	EndIf
EndFunction


;=== Functions - Character data ===--

Int Function SavePlayerData()
	GotoState("Busy")
	DebugTrace("Saving player data...")
	SetSessionID()
	String sSessionID = GetSessionStr("SessionID")
	
	ActorBase 	kPlayerBase 	= PlayerREF.GetActorBase()
	String 		sPlayerName 	= kPlayerBase.GetName()

	
	Int jSIDList = JMap.AllKeys(GetRegObj("Names." + sPlayerName))
	If jSIDList
		Int iSID = JArray.Count(jSIDList)
		While iSID > 0
			iSID -= 1
			String sSID = JArray.GetStr(jSIDList,iSID)
			DebugTrace("Checking current session against " + sSID + "...")
			If Math.ABS(GetRegFlt("Characters." + sSID + META + "PlayTime") - GetRealHoursPassed()) < 0.1
				sSessionID = sSID
				SetSessionID(sSID)
				DebugTrace("Current session matches " + sSID + "!")
			EndIf
		EndWhile
	EndIf

	
	String sRegKey = "Characters." + sSessionID
	Int jPlayerData = GetRegObj(sRegKey)
	
	If !jPlayerData
		DebugTrace("First save of " + sPlayerName + "(" + sSessionID + ")")
	Else
		DebugTrace("Will overwrite data of " + sPlayerName + " with playtime " + JValue.SolveFlt(jPlayerData,"_MYC.Playtime") + "!")
	EndIf

	;Clear/overwrite registry info for this character
	jPlayerData = JMap.Object()
	SetRegObj(sRegKey,jPlayerData)
	DebugTrace(sRegKey + META + "Name")
	SetRegFlt(sRegKey + META + "PlayTime",GetRealHoursPassed())
	SetRegStr(sRegKey + META + "Name",sPlayerName)
	SetRegInt(sRegKey + META + "Sex",kPlayerBase.GetSex())
	SetRegForm(sRegKey + META + "Race",kPlayerBase.GetRace())
	SetRegStr(sRegKey + META + "RaceText",kPlayerBase.GetRace().GetName())

	Int jPlayerModList = JArray.Object()
	Int iModCount = GetModCount()
	Int i = 0
	While i < iModCount
		JArray.AddStr(jPlayerModList,GetModName(i))
		i += 1
	EndWhile

	SetRegObj(sRegKey + META + "Modlist",jPlayerModList)
	SetRegObj(sRegKey,jPlayerData)

	SetRegObj("Names." + sPlayerName + "." + sSessionID,jPlayerData)
	
	GotoState("")
	Return 0 
EndFunction

;=== Functions - Utility ===--

Function SetSessionID(String sSessionID = "")
	If !sSessionID && !GetSessionStr("SessionID")
		SetSessionStr("SessionID",GetUUIDTrue())
		DebugTrace("Set SessionID: " + GetSessionStr("SessionID"))
	ElseIf !sSessionID && GetSessionStr("SessionID")
		DebugTrace("SessionID already set!")
	ElseIf sSessionID
		SetSessionStr("SessionID",sSessionID)
		DebugTrace("Forced SessionID: " + sSessionID)
	EndIf
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("MYC/DataManager: " + sDebugString,iSeverity)
EndFunction


;=== Functions - Busy state ===--

State Busy

	Function DoUpkeep(Bool bInBackground = True)
		DebugTrace("DoUpkeep called while busy!")
	EndFunction

	Int Function SavePlayerData()
		DebugTrace("SavePlayerData called while busy!")
		Return 1 ; Busy
	EndFunction

EndState
