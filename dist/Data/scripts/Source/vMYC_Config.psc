Scriptname vMYC_Config Hidden

Function SetConfigDefaults() Global
	Debug.Trace("MYC/Config: Setting defaults!")
	SetConfigInt("MagicAllowHealing",True as Int)
	SetConfigInt("MagicAllowDefensive",True as Int)
EndFunction

Function SendConfigEvent(String asPath) Global
	Int iHandle = ModEvent.Create("vMYC_ConfigUpdate")
	If iHandle
		ModEvent.PushString(iHandle,asPath)
		ModEvent.Send(iHandle)
	EndIf
EndFunction

Int Function CreateConfigDataIfMissing() Global
	Int jConfigData = JDB.solveObj(".vMYC._ConfigData")
	If jConfigData
		Return jConfigData
	EndIf
	Debug.Trace("MYC/Config: First Config data access, creating ConfigData key!")
	jConfigData = JMap.Object()
	Int _jMYC = JDB.solveObj(".vMYC")
	JMap.setObj(_jMYC,"_ConfigData",jConfigData)
	Return jConfigData
EndFunction

Bool Function HasConfigKey(String asPath) Global
	Int jConfig = CreateConfigDataIfMissing()
	Return JMap.hasKey(jConfig,asPath)
EndFunction

Function SetConfigString(String asPath, String asString) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setStr(jConfig,asPath,asString)
EndFunction

String Function GetConfigString(String asPath) Global
	Return JDB.solveStr(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigInt(String asPath, Int aiInt) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setInt(jConfig,asPath,aiInt)
	SendConfigEvent(asPath)
EndFunction

Int Function GetConfigInt(String asPath) Global
	Return JDB.solveInt(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigFlt(String asPath, Float afFloat) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setFlt(jConfig,asPath,afFloat)
	SendConfigEvent(asPath)
EndFunction

Float Function GetConfigFlt(String asPath) Global
	Return JDB.solveFlt(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigForm(String asPath, Form akForm) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setForm(jConfig,asPath,akForm)
	SendConfigEvent(asPath)
EndFunction

Form Function GetConfigForm(String asPath) Global
	Return JDB.solveForm(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigObj(String asPath, Int ajObj) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setObj(jConfig,asPath,ajObj)
	SendConfigEvent(asPath)
EndFunction

Int Function GetConfigObj(String asPath) Global
	Return JDB.solveObj(".vMYC._ConfigData." + asPath)
EndFunction
