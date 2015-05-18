Scriptname vFFC_MCMPanelNav extends SKI_ConfigBase
{MCM config script for Familiar Faces 2.0.}

Int[] 		Property 	PanelIDs 		Auto Hidden
String[] 	Property 	PanelNames 		Auto Hidden

Int[]		Property 	MnuOpt_IDs 			Auto Hidden
String[] 	Property 	MnuOpt_Names 		Auto Hidden
String[] 	Property 	MnuOpt_Param_Text	Auto Hidden
String[] 	Property 	MnuOpt_Param_Value 	Auto Hidden
Int[] 		Property 	MnuOpt_Param_Flags 	Auto Hidden

Int[]		Property 	TogOpt_IDs 			Auto Hidden
String[] 	Property 	TogOpt_Names 		Auto Hidden
String[] 	Property 	TogOpt_Param_Text	Auto Hidden
Bool[] 		Property 	TogOpt_Param_Value 	Auto Hidden
Int[] 		Property 	TogOpt_Param_Flags 	Auto Hidden

Int[]		Property 	TxtOpt_IDs 			Auto Hidden
String[] 	Property 	TxtOpt_Names 		Auto Hidden
String[] 	Property 	TxtOpt_Param_Text	Auto Hidden
String[] 	Property 	TxtOpt_Param_Value 	Auto Hidden
Int[] 		Property 	TxtOpt_Param_Flags 	Auto Hidden

Int[]		Property 	HdrOpt_IDs 			Auto Hidden
String[] 	Property 	HdrOpt_Names 		Auto Hidden
String[] 	Property 	HdrOpt_Param_Text	Auto Hidden
String[] 	Property 	HdrOpt_Param_Value 	Auto Hidden
Int[] 		Property 	HdrOpt_Param_Flags 	Auto Hidden

Int[]		Property 	EmtOpt_IDs 			Auto Hidden
String[] 	Property 	EmtOpt_Names 		Auto Hidden

Int[] 		Property 	PanelOptionIDs 		Auto Hidden

Int[] 		Property 	PanelStack 		Auto Hidden

Event OnInit()
	PanelStack		= New Int[128]
	
	PanelIDs 		= New Int[128]	
	PanelNames 		= New String[128]
	
	PanelOptionIDs 	= New Int[128]	

	Parent.OnInit()
EndEvent

Int Function CreatePanel(String asPanelName)
	Int iPanelIdx = GetPanelID(asPanelName)
	If iPanelIdx >= 0
		Return iPanelIdx
	Else
		iPanelIdx = PanelStack.Find(0)
		If iPanelIdx <= 0
			Return 0
		Else
			Return iPanelIdx
		EndIf
	EndIf
EndFunction

Int Function GetPanelID(String asPanelName)
	Int iPanelIdx = PanelNames.Find(asPanelName)
	Return iPanelIdx
EndFunction

Int Function AddPanelMenuOption(Int aiPanelID, String asOptionName, string a_text, string a_value, int a_flags = 0)
	
EndFunction

Int Function AddPanelToggleOption(Int aiPanelID, String asOptionName, string a_text, bool a_checked, int a_flags = 0)

EndFunction

Int Function AddPanelTextOption(Int aiPanelID, String asOptionName, string a_text, string a_value, int a_flags = 0)

EndFunction

Int Function AddPanelHeaderOption(Int aiPanelID, string a_text, int a_flags = 0)

EndFunction

Function AddPanelEmptyOption(Int aiPanelID)

EndFunction

Function PushPanel(Int aiPanelID)
	Int idx = PanelStack.Find(0)
	PanelStack[idx] = aiPanelID
	PrintPanels()
EndFunction

Int Function PopPanel()
	Int idx = PanelStack.Find(0)
	If idx <= 0
		Return 0
	EndIf
	Int iRet = PanelStack[idx - 1]
	PanelStack[idx - 1] = 0
	PrintPanels()
	Return iRet
EndFunction

Int Function TopPanel(Int aiBack = 0)
	Int idx = PanelStack.Find(0)
	If idx <= 0 || idx - (aiBack + 1) < 0
		Return 0
	EndIf
	Int iRet = PanelStack[idx - (aiBack + 1)]
	PrintPanels()
	Return iRet
EndFunction

Function PrintPanels()
	Int i = 0
	String sPrint = "Panel stack: "
	While i < PanelStack.Length && PanelStack[i] 
		sPrint += PanelStack[i] + " "
		i += 1
	EndWhile
	DebugTrace(sPrint)
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vFF/PanelNav: " + sDebugString,iSeverity)
EndFunction