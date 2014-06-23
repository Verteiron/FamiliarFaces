Scriptname vMYC_UpdateXFLActorScript extends Actor
{Updates EFF's widgets with the correct character name}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Event OnInit()
	RegisterForModEvent("vMYC_UpdateXFLPanel","OnUpdateXFLPanel")
EndEvent

Event OnLoad()
	RegisterForModEvent("vMYC_UpdateXFLPanel","OnUpdateXFLPanel")
EndEvent

Event OnUpdateXFLPanel(string eventName, string strArg, float numArg, Form sender)
	DoXFLPanelUpdate()
EndEvent

Event OnRaceSwitchComplete()
	DoXFLPanelUpdate()
EndEvent

Function DoUpkeep()
	RegisterForModEvent("vMYC_UpdateXFLPanel","OnUpdateXFLPanel")
EndFunction

Function DoXFLPanelUpdate()
		;This updates the character's name in EFF's widget, if it's installed
		;    Expired has said he'll add a ModEvent we can use to do this in future, which should be much simpler
		Int i = 0
		If GetModByName("XFLMain.esm") != 255 && GetModByName("XFLPanel.esp") != 255
			SKI_WidgetManager WidgetManager = GetFormFromFile(0x00000824,"SkyUI.esp") as SKI_WidgetManager
			XFLScript XFLMain = (Game.GetFormFromFile(0x48C9, "XFLMain.esm") as XFLScript)
			If XFLMain.XFL_FollowerList.HasForm(Self) ; check if we're being tracked by EFF
				SKI_WidgetBase[] WidgetList = WidgetManager.GetWidgets()
				i = WidgetList.Length
				While i > 0
					i -= 1
					If WidgetList[i]
						If WidgetList[i].getWidgetType() == "XFLPanel"
							If XFLMain
								(WidgetList[i] as xflpanel).RemoveActors(XFLMain.XFL_FollowerList)
								(WidgetList[i] as xflpanel).AddActors(XFLMain.XFL_FollowerList)
							EndIf
						EndIf
					EndIf
				EndWhile
			EndIf
		EndIf
EndFunction
