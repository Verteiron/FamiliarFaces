Scriptname vMYC_Registry Hidden

Function SendRegEvent(String asPath) Global
	Int iHandle = ModEvent.Create("vMYC_RegUpdate")
	If iHandle
		ModEvent.PushString(iHandle,asPath)
		ModEvent.Send(iHandle)
	Else
		;Debug.Trace("MYC/Reg: Error sending RegUpdate event!",1)
	EndIf
EndFunction

Function SendSessionEvent(String asPath) Global
	Int iHandle = ModEvent.Create("vMYC_SessionUpdate")
	If iHandle
		ModEvent.PushString(iHandle,asPath)
		ModEvent.Send(iHandle)
	EndIf
EndFunction

Function InitReg() Global
	Int jRegData = CreateRegDataIfMissing()
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

Int Function CreateSessionDataIfMissing() Global
	Int jSessionData = JDB.solveObj(".vMYC.Session")
	If jSessionData
		Return jSessionData
	EndIf
	;Debug.Trace("MYC/Session: First SessionData access, creating JDB key!")
	Int _jMYC = JDB.solveObj(".vMYC")
	jSessionData = JMap.Object()
	JMap.setObj(_jMYC,"Session",jSessionData)
	Return jSessionData
EndFunction

Bool Function HasSessionKey(String asPath) Global
	Int jSession = CreateSessionDataIfMissing()
	Return JMap.hasKey(jSession,asPath)
EndFunction

Function SetSessionStr(String asPath, String asString) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveStrSetter(jSession,asPath,asString,True)
EndFunction

String Function GetSessionStr(String asPath) Global
	Return JDB.solveStr(".vMYC.Session." + asPath)
EndFunction

Function SetSessionBool(String asPath, Bool abBool) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveIntSetter(jSession,asPath,abBool as Int,True)
	SendSessionEvent(asPath)
EndFunction

Bool Function GetSessionBool(String asPath) Global
	Return JDB.solveInt(".vMYC.Session." + asPath) as Bool
EndFunction

Function SetSessionInt(String asPath, Int aiInt) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveIntSetter(jSession,asPath,aiInt,True)
	SendSessionEvent(asPath)
EndFunction

Int Function GetSessionInt(String asPath) Global
	Return JDB.solveInt(".vMYC.Session." + asPath)
EndFunction

Function SetSessionFlt(String asPath, Float afFloat) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveFltSetter(jSession,asPath,afFloat,True)
	SendSessionEvent(asPath)
EndFunction

Float Function GetSessionFlt(String asPath) Global
	Return JDB.solveFlt(".vMYC.Session." + asPath)
EndFunction

Function SetSessionForm(String asPath, Form akForm) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveFormSetter(jSession,asPath,akForm,True)
	SendSessionEvent(asPath)
EndFunction

Form Function GetSessionForm(String asPath) Global
	Return JDB.solveForm(".vMYC.Session." + asPath)
EndFunction

Function SetSessionObj(String asPath, Int ajObj) Global
	Int jSession = CreateSessionDataIfMissing()
	JValue.solveObjSetter(jSession,asPath,ajObj,True)
	SendSessionEvent(asPath)
EndFunction

Int Function GetSessionObj(String asPath) Global
	Return JDB.solveObj(".vMYC.Session." + asPath)
EndFunction

Function CreateRegFormLink(Form akForm1, Form akForm2, String asLinkName1 = "_links", String asLinkName2 = "_links") Global
{Creates many2many links between two forms based on string keys}
	Int jReg = CreateRegDataIfMissing()
	If !JMap.HasKey(jReg,"_FormLinks")
		JMap.SetObj(jReg,"_FormLinks",JFormMap.Object())
	EndIf
	Int jMasterFormLinkMap = JMap.getObj(jReg,"_FormLinks")
	
	If !JFormMap.HasKey(jMasterFormLinkMap,akForm1)
		JFormMap.SetObj(jMasterFormLinkMap,akForm1,JMap.Object())
	EndIf
	If !JFormMap.HasKey(jMasterFormLinkMap,akForm2)
		JFormMap.SetObj(jMasterFormLinkMap,akForm2,JMap.Object())
	EndIf
	Int jForm1LinkMap = JFormMap.GetObj(jMasterFormLinkMap,akForm1)
	Int jForm2LinkMap = JFormMap.GetObj(jMasterFormLinkMap,akForm2)

	If !JMap.HasKey(jForm1LinkMap,asLinkName1)
		JMap.SetObj(jForm1LinkMap,asLinkName1,JArray.Object())
	EndIf
	If !JMap.HasKey(jForm2LinkMap,asLinkName2)
		JMap.SetObj(jForm2LinkMap,asLinkName2,JArray.Object())
	EndIf
	Int jForm1Links = JMap.GetObj(jForm1LinkMap,asLinkName1)
	Int jForm2Links = JMap.GetObj(jForm2LinkMap,asLinkName2)
	
	If jArray.FindForm(jForm1Links,akForm2) < 0
		jArray.AddForm(jForm1Links,akForm2)
	EndIf
	If jArray.FindForm(jForm2Links,akForm1) < 0
		jArray.AddForm(jForm2Links,akForm1)
	EndIf
	SyncReg()
EndFunction

Int Function GetFormLinkArray(Form akForm, String asLinkName = "_links") Global
	Int jMasterFormLinkMap = JDB.solveObj(".vMYC.Registry._FormLinks")
	If !jMasterFormLinkMap
		Return 0
	EndIf
	
	If !JFormMap.HasKey(jMasterFormLinkMap,akForm)
		Return 0
	EndIf
	Int jFormLinkMap = JFormMap.GetObj(jMasterFormLinkMap,akForm)
	
	If !JMap.HasKey(jFormLinkMap,asLinkName)
		Return 0
	EndIf
		
	Return JMap.GetObj(jFormLinkMap,asLinkName)
EndFunction

Int Function CountFormLinks(Form akForm, String asLinkName = "_links") Global
	Int jFormLinks = GetFormLinkArray(akForm,asLinkName)
	If !jFormLinks
		Return 0
	Else
		Return JArray.Count(jFormLinks)
	EndIf
EndFunction

Form Function GetNthFormLink(Form akForm, String asLinkNAme = "_links", Int aiIndex = 0) Global
	Int jFormLinks = GetFormLinkArray(akForm,asLinkName)
	If !jFormLinks
		Return None
	Else
		Return JArray.GetForm(jFormLinks,aiIndex)
	EndIf
EndFunction

Function BreakRegFormLink(Form akForm1, Form akForm2, String asLinkName1 = "_links", String asLinkName2 = "_links") Global
	Int jFormLinks1 = GetFormLinkArray(akForm1,asLinkName1)
	Int jFormLinks2 = GetFormLinkArray(akForm2,asLinkName2)
	
	Int idx1 = JArray.FindForm(jFormLinks1,akForm2)
	Int idx2 = JArray.FindForm(jFormLinks2,akForm1)
	
	If idx1 > 0
		JArray.EraseIndex(jFormLinks1,idx1)
	EndIf
	If idx2 > 0
		JArray.EraseIndex(jFormLinks2,idx2)
	EndIf
EndFunction

Function ClearRegFormLinks(Form akForm) Global
	Int jMasterFormLinkMap = JDB.solveObj(".vMYC.Registry._FormLinks")
	If !jMasterFormLinkMap
		Return
	EndIf
	JFormMap.RemoveKey(jMasterFormLinkMap,akForm)
	Int jValues = JFormMap.allValues(jMasterFormLinkMap)
	If JArray.FindForm(jValues,akForm) > -1
		Debug.Trace("MYC/Reg: Warning! There are leftover links pointing at " + akForm + "!",1)
	EndIf
EndFunction

Function CreateRegObjLink(Int ajObj1, Int ajObj2, String asLinkName1 = "_links", String asLinkName2 = "_links") Global
{Creates many2many links between two JMaps based on string keys}
	If !JValue.IsMap(ajObj1) || !JValue.IsMap(ajObj2)
		Return
	EndIf
	
	If !JMap.HasKey(ajObj1,asLinkName1)
		JMap.SetObj(ajObj1,asLinkName1,JArray.Object())
	EndIf
	If !JMap.HasKey(ajObj2,asLinkName2)
		JMap.SetObj(ajObj2,asLinkName2,JArray.Object())
	EndIf
	
	Int jObj1Links = JMap.GetObj(ajObj1,asLinkName1)
	Int jObj2Links = JMap.GetObj(ajObj2,asLinkName2)
	
	If jArray.FindObj(jObj1Links,ajObj2) < 0
		jArray.AddObj(jObj1Links,ajObj2)
	EndIf
	If jArray.FindObj(jObj2Links,ajObj1) < 0
		jArray.AddObj(jObj2Links,ajObj1)
	EndIf
	SyncReg()
EndFunction

Int Function GetObjLinkArray(Int ajObj, String asLinkName = "_links") Global
	If !JMap.HasKey(ajObj,asLinkName)
		Return 0
	EndIf
		
	Return JMap.GetObj(ajObj,asLinkName)
EndFunction

Int Function CountObjLinks(Int ajObj, String asLinkName = "_links") Global
	Int jObjLinks = GetObjLinkArray(ajObj,asLinkName)
	If !jObjLinks
		Return 0
	Else
		Return JArray.Count(jObjLinks)
	EndIf
EndFunction

Int Function GetNthObjLink(Int ajObj, String asLinkNAme = "_links", Int aiIndex = 0) Global
	Int jObjLinks = GetObjLinkArray(ajObj,asLinkName)
	If !jObjLinks
		Return 0
	Else
		Return JArray.GetObj(jObjLinks,aiIndex)
	EndIf
EndFunction

Function BreakRegObjLink(Int ajObj1, Int ajObj2, String asLinkName1 = "_links", String asLinkName2 = "_links") Global
	Int jObjLinks1 = GetObjLinkArray(ajObj1,asLinkName1)
	Int jObjLinks2 = GetObjLinkArray(ajObj2,asLinkName2)
	
	Int idx1 = JArray.FindObj(jObjLinks1,ajObj2)
	Int idx2 = JArray.FindObj(jObjLinks2,ajObj1)
	
	If idx1 > 0
		JArray.EraseIndex(jObjLinks1,idx1)
	EndIf
	If idx2 > 0
		JArray.EraseIndex(jObjLinks2,idx2)
	EndIf
EndFunction

Function CreateRegForm2ObjLink(Form akForm, Int ajObj, String asLinkName1 = "_links", String asLinkName2 = "_links") Global
{Creates many2many links between a Form and a jObj based on string keys}
	If !JValue.IsMap(ajObj)
		Return
	EndIf
	
	Int jReg = CreateRegDataIfMissing()
	If !JMap.HasKey(jReg,"_FormLinks")
		JMap.SetObj(jReg,"_FormLinks",JFormMap.Object())
	EndIf
	Int jMasterFormLinkMap = JMap.getObj(jReg,"_FormLinks")
	
	If !JFormMap.HasKey(jMasterFormLinkMap,akForm)
		JFormMap.SetObj(jMasterFormLinkMap,akForm,JMap.Object())
	EndIf
	Int jFormLinkMap = JFormMap.GetObj(jMasterFormLinkMap,akForm)

	If !JMap.HasKey(jFormLinkMap,asLinkName1)
		JMap.SetObj(jFormLinkMap,asLinkName1,JArray.Object())
	EndIf
	If !JMap.HasKey(ajObj,asLinkName2)
		JMap.SetObj(ajObj,asLinkName2,JArray.Object())
	EndIf
	Int jFormLinks = JMap.GetObj(jFormLinkMap,asLinkName1)
	Int jObjLinks = JMap.GetObj(ajObj,asLinkName2)

	If jArray.FindObj(jFormLinks,ajObj) < 0
		jArray.AddObj(jFormLinks,ajObj)
	EndIf
	If jArray.FindForm(jObjLinks,akForm) < 0
		jArray.AddForm(jObjLinks,akForm)
	EndIf
	SyncReg()
EndFunction

String Function GetUUID(Bool abFast = True) Global
	If abFast
		Return GetUUIDFast()
	EndIf
	Return GetUUIDTrue()
EndFunction

String Function GetUUIDTrue() Global
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
