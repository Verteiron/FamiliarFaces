Scriptname vFFC_MCMPanelNav extends SKI_ConfigBase
{MCM config script for Familiar Faces 2.0.}

String[] 	Property 	PanelStates		Auto Hidden
String[] 	Property 	PanelNames		Auto Hidden
String[] 	Property 	PanelParents	Auto Hidden


String[]	Property 	PanelStack 		Auto Hidden

String		Property 	PanelLeft 		Auto Hidden
String		Property 	PanelRight		Auto Hidden

Event OnInit()
	PanelStack		= New String[128]
	
	PanelStates 	= New String[128]
	PanelNames	 	= New String[128]
	PanelParents	= New String[128]
	
	Parent.OnInit()
EndEvent

String Function GetPanelName(String asPanelState)
	Int idx = PanelStates.Find(asPanelState)
	If idx >= 0 
		Return PanelNames[idx]
	EndIf
	Return ""
EndFunction

String Function GetPanelParent(String asPanelState)
	Int idx = PanelStates.Find(asPanelState)
	If idx >= 0 
		Return PanelParents[idx]
	EndIf
	Return ""
EndFunction

Function CreatePanel(String asPanelState, String asPanelName, String asPanelParent = "")
	Int idx = PanelStates.Find(asPanelState)
	If idx >= 0 ; Panel already exists
		PanelNames[idx] 	= asPanelName
		PanelParents[idx] 	= asPanelParent
		Return
	Else
		idx = PanelStates.Find("") ; return empty slot
		PanelStates[idx] = asPanelState
		PanelNames[idx] = asPanelName
		PanelParents[idx] = asPanelParent
	EndIf
EndFunction

Function PushPanel(String asPanelState)
	Int idx = PanelStack.Find("")
	PanelStack[idx] = asPanelState
	PrintPanels()
EndFunction

String Function PopPanel()
	Int idx = PanelStack.Find("")
	If idx <= 0
		Return ""
	EndIf
	String sRet = PanelStack[idx - 1]
	PanelStack[idx - 1] = ""
	PrintPanels()
	Return sRet
EndFunction

String Function TopPanel(Int aiBack = 0)
	Int idx = PanelStack.Find("")
	If idx <= 0 || idx - (aiBack + 1) < 0
		Return ""
	EndIf
	String sRet = PanelStack[idx - (aiBack + 1)]
	PrintPanels()
	Return sRet
EndFunction

Function PrintPanels()
	Int i = 0
	String sPrint = "Panel stack: "
	String sArrow = ""
	While i < PanelStack.Length && PanelStack[i] 
		sPrint += sArrow + PanelStack[i]
		sArrow = "->"
		i += 1
	EndWhile
	DebugTrace(sPrint)
EndFunction

Function DisplayPanels()
	String sPanelLeft 	= TopPanel(1)
	String sPanelRight 	= TopPanel()
	If sPanelLeft
		PanelLeft = sPanelLeft
	EndIf
	If sPanelRight
		PanelRight = sPanelRight
	EndIf
	AddPanel(PanelLeft,0)
	AddPanel(PanelRight,1)
EndFunction

Function AddPanel(String asPanelState, Int aiLeftRight)
	String sPrevState = GetState()
	GotoState(asPanelState)
	OnPanelAdd(aiLeftRight)
	If TopPanel(2) && aiLeftRight == 0
		SetCursorPosition(22)
		AddTextOptionST("OPTION_TEXT_BACK","$Back_button", GetPanelName(TopPanel(2)))
	EndIf
	GoToState(sPrevState)
EndFunction

Function AddPanelLinkOption(String asPanelState, String asOptionText, Int aiOptionFlags = 0)
	String sOptionValue = "$More_button"
	If PanelRight == asPanelState
		aiOptionFlags = OPTION_FLAG_DISABLED
		sOptionValue	= "$Back_button"
	EndIf
	AddTextOptionST(asPanelState, asOptionText, sOptionValue, aiOptionFlags)
EndFunction

Event OnSelectST()
	String sState = GetState()
	If !sState ; Really called outside state, pass up and do nothing
		Parent.OnSelectST()
		Return
	EndIf
	Int idx = PanelStates.Find(sState)
	If idx >= 0 ; Called from a PanelLink
		String sPanelParent = GetPanelParent(sState)
		If TopPanel() != sPanelParent
			PopPanel()
		EndIf
		PushPanel(sState)
		ForcePageReset()
	Else 
		Parent.OnSelectST()
	EndIf
EndEvent

Function AddBackButton()

EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/PanelNav: " + sDebugString,iSeverity)
EndFunction

Event OnPanelAdd(Int aiLeftRight)
	DebugTrace("OnPanelAdd called on parent script!")
EndEvent

; == Panel: Go back ===--
State OPTION_TEXT_BACK

	Event OnSelectST()
		PopPanel()
		ForcePageReset()
	EndEvent

EndState