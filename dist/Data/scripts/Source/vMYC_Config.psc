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

Function InitConfig() Global
	Int jConfigData = CreateConfigDataIfMissing()
EndFunction

Function LoadConfig() Global

EndFunction

Function SaveConfig() Global
	Int jConfigData = JDB.solveObj(".vMYC._ConfigData")
	JMap.setInt(jConfigData,"DataSerial",JMap.getInt(jConfigData,"DataSerial") + 1)
	JValue.WriteToFile(jConfigData,"Data/vMYC/vMYC_config.json")
EndFunction

Int Function CreateConfigDataIfMissing() Global
	Int jConfigData = JDB.solveObj(".vMYC._ConfigData")
	If jConfigData
		Return jConfigData
	EndIf
	Debug.Trace("MYC/Config: First ConfigData access, creating JDB key!")
	Int _jMYC = JDB.solveObj(".vMYC")
	jConfigData = JValue.ReadFromFile("Data/vMYC/vMYC_config.json")	
	If jConfigData
		Debug.Trace("MYC/Config: Loaded config file!")
	Else
		Debug.Trace("MYC/Config: No config file found, creating new ConfigData data!")
		jConfigData = JMap.Object()
		JMap.setInt(jConfigData,"DataSerial",0)
	EndIf
	JMap.setObj(_jMYC,"_ConfigData",jConfigData)
	Return jConfigData
EndFunction

Bool Function HasConfigKey(String asPath) Global
	Int jConfig = CreateConfigDataIfMissing()
	Return JMap.hasKey(jConfig,asPath)
EndFunction

Function SetConfigStr(String asPath, String asString, Bool abDeferSave = False) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setStr(jConfig,asPath,asString)
	If !abDeferSave
		SaveConfig()
	EndIf
EndFunction

String Function GetConfigStr(String asPath) Global
	Return JDB.solveStr(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigInt(String asPath, Int aiInt, Bool abDeferSave = False) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setInt(jConfig,asPath,aiInt)
	SendConfigEvent(asPath)
	If !abDeferSave
		SaveConfig()
	EndIf
EndFunction

Int Function GetConfigInt(String asPath) Global
	Return JDB.solveInt(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigFlt(String asPath, Float afFloat, Bool abDeferSave = False) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setFlt(jConfig,asPath,afFloat)
	SendConfigEvent(asPath)
	If !abDeferSave
		SaveConfig()
	EndIf
EndFunction

Float Function GetConfigFlt(String asPath) Global
	Return JDB.solveFlt(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigForm(String asPath, Form akForm, Bool abDeferSave = False) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setForm(jConfig,asPath,akForm)
	SendConfigEvent(asPath)
	If !abDeferSave
		SaveConfig()
	EndIf
EndFunction

Form Function GetConfigForm(String asPath) Global
	Return JDB.solveForm(".vMYC._ConfigData." + asPath)
EndFunction

Function SetConfigObj(String asPath, Int ajObj, Bool abDeferSave = False) Global
	Int jConfig = CreateConfigDataIfMissing()
	JMap.setObj(jConfig,asPath,ajObj)
	SendConfigEvent(asPath)
	If !abDeferSave
		SaveConfig()
	EndIf
EndFunction

Int Function GetConfigObj(String asPath) Global
	Return JDB.solveObj(".vMYC._ConfigData." + asPath)
EndFunction
