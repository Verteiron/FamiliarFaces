Scriptname vMYC_CompatEFF extends Quest  
{Module for EFF compatibility. Updates EFF's widgets with the correct character name.}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Event OnGameReloaded()
	If IsRunning()
		SetConfigInt("Compat_EFF_Enabled",1)
	Else
		SetConfigInt("Compat_EFF_Enabled",0)
	EndIf
	RegisterForModEvent("vMYC_UpdateXFLPanel","OnUpdateXFLPanel")
	Debug.Trace("MYC/CompatEFF: Registered for vMYC_UpdateXFLPanel!")
EndEvent

Event OnInit()
	RegisterForModEvent("vMYC_UpdateXFLPanel","OnUpdateXFLPanel")
	Debug.Trace("MYC/CompatEFF: Registered for vMYC_UpdateXFLPanel!")
EndEvent

Event OnUpdateXFLPanel(string eventName, string strArg, float numArg, Form sender)
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnUpdate()
	DoXFLPanelUpdate()
EndEvent

Function DoXFLPanelUpdate()
		;This updates the character's name in EFF's widget, if it's installed
		;Expired has said he'll add a ModEvent we can use to do this in future, which should be much simpler
		Debug.Trace("MYC/CompatEFF: Updating XFLPanel names!")
		Int i = 0
		If GetModByName("XFLMain.esm") != 255 && GetModByName("XFLPanel.esp") != 255
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
		EndIf
EndFunction
