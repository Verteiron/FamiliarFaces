Scriptname vFFC_CompatEFF3 extends vFFC_CompatBase
{Compatibility module for ExtensibleFollowerFramework 3 (and early betas of 4).}

;=== Imports ===--

Import Utility
Import Game
Import vFF_Registry

;=== Properties ===--

;=== Variables ===--

;=== Events/Functions ===--

Bool Function IsRequired()
{Return true if the mod that this module supports is installed.}
	If GetModByName("XFLMain.esm") != 255
		Return True
	EndIf
	Return False
EndFunction

Int Function StartModule()
{User code for startup.}
	RegisterForModEvent("vFFC_UpdateXFLPanel","OnUpdateXFLPanel")
	DebugTrace("Registered for vFFC_UpdateXFLPanel!")
	
	Return 1
EndFunction

Int Function UpkeepModule()
{User code for upkeep.}
	RegisterForModEvent("vFFC_UpdateXFLPanel","OnUpdateXFLPanel")
	DebugTrace("Registered for vFFC_UpdateXFLPanel!")

	Return 1
EndFunction

Int Function StopModule()
{User code for shutdown.}
	UnregisterForModEvent("vFFC_UpdateXFLPanel")
	Return 1
EndFunction

Event OnUpdateXFLPanel(string eventName, string strArg, float numArg, Form sender)
	;If already registered it will just push it back, so no matter what only one event should fire
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnUpdate()
	DoXFLPanelUpdate()
EndEvent

Function DoXFLPanelUpdate()
;FOR OLDER VERSIONS!
	;This updates the character's name in EFF's widget, if it's installed
	;Expired has said he'll add a ModEvent we can use to do this in future, which should be much simpler
	DebugTrace("Updating XFLPanel names!")
	Int i = 0
	SKI_WidgetManager WidgetManager = GetFormFromFile(0x00000824,"SkyUI.esp") as SKI_WidgetManager
	XFLScript XFLMain = (Game.GetFormFromFile(0x48C9, "XFLMain.esm") as XFLScript)
	SKI_WidgetBase[] WidgetList = WidgetManager.GetWidgets()
	i = WidgetList.Length
	While i > 0
		i -= 1
		If WidgetList[i]
			If WidgetList[i].getWidgetType() == "XFLPanel"
				If XFLMain
					(WidgetList[i] as xflpanel).RemoveActors(XFLMain.XFL_FollowerList)
					Wait(0.5)
					(WidgetList[i] as xflpanel).AddActors(XFLMain.XFL_FollowerList)
				EndIf
			EndIf
		EndIf
	EndWhile
EndFunction
