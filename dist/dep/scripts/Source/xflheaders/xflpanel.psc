Scriptname XFLPanel extends SKI_WidgetBase  

XFLScript XFLMain = None

float _scale = 1.0
int _maxEntries = 5
float _fadeInDuration = 250.0
float _fadeOutDuration = 750.0
float _moveDuration = 1000.0
float _removeDuration = 15000.0

string function GetWidgetSource()
	return "skyui/followerpanel.swf"
endFunction

string function GetWidgetType()
	return "XFLPanel"
endFunction

int function GetVersion()
	return 1
endFunction

float property Scale
	float function get()
		return _scale
	endFunction
	
	function set(float a_val)
		_scale = a_val
		if (Ready)
			UpdateWidgetScale()
		endIf
	endFunction
endProperty

int Property MaxEntries
	int function get()
		return _maxEntries
	endFunction
	
	function set(int a_val)
		_maxEntries = a_val
		if (Ready)
			UpdateMaxEntries()
		endIf
	endFunction
endProperty

float property FadeInDuration
	float function get()
		return _fadeInDuration
	endFunction
	
	function set(float a_val)
		_fadeInDuration = a_val
		if (Ready)
			UpdateFadeInDuration()
		endIf
	endFunction
endProperty

float property FadeOutDuration
	float function get()
		return _fadeOutDuration
	endFunction
	
	function set(float a_val)
		_fadeOutDuration = a_val
		if (Ready)
			UpdateFadeOutDuration()
		endIf
	endFunction
endProperty

float property MoveDuration
	float function get()
		return _moveDuration
	endFunction
	
	function set(float a_val)
		_moveDuration = a_val
		if (Ready)
			UpdateMoveDuration()
		endIf
	endFunction
endProperty

float property RemoveDuration
	float function get()
		return _removeDuration
	endFunction
	
	function set(float a_val)
		_removeDuration = a_val
		if (Ready)
			UpdateRemoveDuration()
		endIf
	endFunction
endProperty

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()
	UpdateWidgetScale()
	UpdateMaxEntries()
	UpdateFadeInDuration()
	UpdateFadeOutDuration()
	UpdateMoveDuration()
	UpdateRemoveDuration()

	XFLMain = (Game.GetFormFromFile(0x48C9, "XFLMain.esm") as XFLScript)
	if XFLMain
		AddActors(XFLMain.XFL_FollowerList)
	endIf
endEvent

Function UpdateWidgetScale()
	UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setScale", _scale * 100.0)
EndFunction

Function UpdateMaxEntries()
	UI.InvokeInt(HUD_MENU, WidgetRoot + ".setEntryCount", _maxEntries)
EndFunction

Function UpdateFadeInDuration()
	UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setFadeInDuration", _fadeInDuration / 1000.0)
EndFunction

Function UpdateFadeOutDuration()
	UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setFadeOutDuration", _fadeOutDuration / 1000.0)
EndFunction

Function UpdateMoveDuration()
	UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setMoveDuration", _moveDuration / 1000.0)
EndFunction

Function UpdateRemoveDuration()
	UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setRemoveDuration", _removeDuration)
EndFunction

Function AddActors(Form aForm)
	UI.InvokeForm(HUD_MENU, WidgetRoot + ".addPanelActors", aForm)
EndFunction

Function RemoveActors(Form aForm)
	UI.InvokeForm(HUD_MENU, WidgetRoot + ".removePanelActors", aForm)
EndFunction