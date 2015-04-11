Scriptname vMYC_Registry Hidden
{Abstracted interface for JContainers that handles data synchronization between game saves.}

; === [ vMYC_Registry.psc ] ===============================================---
; Abstracted interface for JContainers that handles data synchronization 
; between game saves. Automatically saves/loads file based on incrementing
; serial number. Can also be used to link JContainer objects to forms.
; ========================================================---

Import vMYC_Session

Function SendRegEvent(String asPath) Global
	Int iHandle = ModEvent.Create("vMYC_RegUpdate")
	If iHandle
		ModEvent.PushString(iHandle,asPath)
		ModEvent.Send(iHandle)
	Else
		;Debug.Trace("MYC/Reg: Error sending RegUpdate event!",1)
	EndIf
EndFunction

Function InitReg() Global
	Int jRegData = CreateRegDataIfMissing()
	Int jSessionData = CreateSessionDataIfMissing()
	SyncReg()
EndFunction

Function SyncReg() Global
	Int jRegData = JDB.solveObj(".vMYC.Registry")
	If !jRegData
		jRegData = JMap.Object()
		JDB.solveObjSetter(".vMYC.Registry",jRegData,True)
	EndIf
	Int jRegFileData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_registry.json")
	Int DataSerial = JMap.getInt(jRegData,"DataSerial")
	Int DataFileSerial = JMap.getInt(jRegFileData,"DataSerial")
	;Debug.Trace("MYC/Reg: SyncReg called! Our DataSerial is " + DataSerial + ", file DataSerial is " + DataFileSerial)
	If DataSerial > DataFileSerial
		;Debug.Trace("MYC/Reg: Our data is newer than the saved file, overwriting it!")
		JValue.WriteToFile(jRegData,JContainers.userDirectory() + "vMYC/vMYC_registry.json")
	ElseIf DataSerial < DataFileSerial
		;Debug.Trace("MYC/Reg: Our data is older than the saved file, loading it!")
		JValue.Clear(jRegData)
		jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_registry.json")
		JDB.solveObjSetter(".vMYC.Registry",jRegData)
	Else
		;Already synced. Sunc?
	EndIf
EndFunction

Function LoadReg() Global
	;Debug.Trace("MYC/Reg: LoadReg called!")
	Int jRegData = JDB.solveObj(".vMYC.Registry")
	jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_registry.json")
EndFunction

Function SaveReg() Global
	;Debug.Trace("MYC/Reg: SaveReg called!")
	Int jRegData = JDB.solveObj(".vMYC.Registry")
	JMap.setInt(jRegData,"DataSerial",JMap.getInt(jRegData,"DataSerial") + 1)
	JValue.WriteToFile(jRegData,JContainers.userDirectory() + "vMYC/vMYC_registry.json")
EndFunction

Int Function CreateRegDataIfMissing() Global
	Int jRegData = JDB.solveObj(".vMYC.Registry")
	If jRegData
		JMap.setInt(jRegData,"DataSerial",JMap.getInt(jRegData,"DataSerial") + 1)
		Return jRegData
	EndIf
	;Debug.Trace("MYC/Reg: First RegData access, creating JDB key!")
	Int _jMYC = JDB.solveObj(".vMYC")
	jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/vMYC_registry.json")	
	If jRegData
		;Debug.Trace("MYC/Reg: Loaded Reg file!")
	Else
		;Debug.Trace("MYC/Reg: No Reg file found, creating new RegData data!")
		jRegData = JMap.Object()
		JMap.setInt(jRegData,"DataSerial",0)
	EndIf
	JMap.setObj(_jMYC,"Registry",jRegData)
	Return jRegData
EndFunction

Bool Function HasRegKey(String asPath) Global
	Int jReg = CreateRegDataIfMissing()
	Return JValue.hasPath(jReg,"." + asPath) || JMap.hasKey(jReg,asPath)
EndFunction

Function SetRegStr(String asPath, String asString, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveStrSetter(jReg,"." + asPath,asString,True)
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

String Function GetRegStr(String asPath) Global
	Return JDB.solveStr(".vMYC.Registry." + asPath)
EndFunction

Function SetRegBool(String asPath, Bool abBool, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveIntSetter(jReg,"." + asPath,abBool as Int,True)
	If !abNoEvent
		SendRegEvent(asPath)
	EndIf
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Bool Function GetRegBool(String asPath) Global
	Return JDB.solveInt(".vMYC.Registry." + asPath) as Bool
EndFunction

Function SetRegInt(String asPath, Int aiInt, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveIntSetter(jReg,"." + asPath,aiInt,True)
	If !abNoEvent
		SendRegEvent(asPath)
	EndIf
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Int Function GetRegInt(String asPath) Global
	Return JDB.solveInt(".vMYC.Registry." + asPath)
EndFunction

Function SetRegFlt(String asPath, Float afFloat, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveFltSetter(jReg,"." + asPath,afFloat,True)
	If !abNoEvent
		SendRegEvent(asPath)
	EndIf
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Float Function GetRegFlt(String asPath) Global
	Return JDB.solveFlt(".vMYC.Registry." + asPath)
EndFunction

Function SetRegForm(String asPath, Form akForm, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveFormSetter(jReg,"." + asPath,akForm,True)
	If !abNoEvent
		SendRegEvent(asPath)
	EndIf
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Form Function GetRegForm(String asPath) Global
	Return JDB.solveForm(".vMYC.Registry." + asPath)
EndFunction

Function SetRegObj(String asPath, Int ajObj, Bool abDeferSave = False, Bool abNoEvent = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveObjSetter(jReg,"." + asPath,ajObj,True)
	If !abNoEvent
		SendRegEvent(asPath)
	EndIf
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Int Function GetRegObj(String asPath) Global
	Return JDB.solveObj(".vMYC.Registry." + asPath)
EndFunction

String Function GetUUID(Bool abFast = True) Global
	If abFast
		Return GetUUIDFast()
	EndIf
	Return GetUUIDTrue()
EndFunction

String Function GetUUIDTrue() Global
{This should be identical to GetUUIDFast, but follows the proper procedure for generating the randoms.}
	Int[] iBytes = New Int[16]
	Int i = 0
	While i < 16
		iBytes[i] = Utility.RandomInt(0,255)
		i += 1
	EndWhile
	Int iVersion = iBytes[6]
	iVersion = Math.LogicalOr(Math.LogicalAnd(iVersion,0x0f),0x40)
	iBytes[6] = iVersion
	Int iVariant = iBytes[8]
	iVariant = Math.LogicalOr(Math.LogicalAnd(iVariant,0x3f),0x80)
	iBytes[8] = iVariant
	String sUUID = ""
	i = 0
	While i < 16
		If iBytes[i] < 16
			sUUID += "0"
		EndIf
		sUUID += GetHexString(iBytes[i])
		If i == 3 || i == 5 || i == 7 || i == 9
			sUUID += "-"
		EndIf
		i += 1
	EndWhile
	Return sUUID
EndFunction

String Function GetUUIDFast() Global
	String sUUID = ""
	sUUID += GetHexString(Utility.RandomInt(0,0xffff),4) + GetHexString(Utility.RandomInt(0,0xffff),4)
	sUUID += "-"
	sUUID += GetHexString(Utility.RandomInt(0,0xffff),4)
	sUUID += "-"
	sUUID += GetHexString(Math.LogicalOr(Math.LogicalAnd(Utility.RandomInt(0,0xffff),0x0fff),0x4000)) ; version
	sUUID += "-"
	sUUID += GetHexString(Math.LogicalOr(Math.LogicalAnd(Utility.RandomInt(0,0xffff),0x3fff),0x8000)) ; variant
	sUUID += "-"
	sUUID += GetHexString(Utility.RandomInt(0,0xffffff),6) + GetHexString(Utility.RandomInt(0,0xffffff),6)
	Return sUUID
EndFunction

String Function GetHexString(Int iDec, Int iPadLength = 0) Global
	If iDec < 0
		Return ""
	ElseIf iDec == 0
		Return "0"
	EndIf
	String[] sHexT = New String[6]
	sHexT[0] = "a"
	sHexT[1] = "b"
	sHexT[2] = "c"
	sHexT[3] = "d"
	sHexT[4] = "e"
	sHexT[5] = "f"
	String sHex = ""
	If iDec > 15
		sHex += GetHexString(iDec / 16)
		sHex += GetHexString(iDec % 16)
	ElseIf iDec > 9
		sHex = sHexT[iDec - 10]
	ElseIf iDec 
		sHex = iDec
	Else
		sHex = "0"
	EndIf
	If iPadLength
		Int iHexLen = StringUtil.GetLength(sHex)
		If iHexLen < iPadLength
			sHex = StringUtil.Substring("0000000000000000",0,iPadLength - iHexLen) + sHex
		EndIf
	EndIf
	Return sHex
EndFunction

Int Function GetVersionInt(Int iMajor, Int iMinor, Int iPatch)
	Return Math.LeftShift(iMajor,16) + Math.LeftShift(iMinor,8) + iPatch
EndFunction
