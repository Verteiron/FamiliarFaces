Scriptname vMYC_ScriptLatencyCheck extends Quest  
{Test for script latency, to help troubleshooting and blame the end user :D}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

;--=== Config variables ===--

;--=== Variables ===--
Float _fTimeUpdMark
Float[] _fTimeUpdDeltas

Float _fTimeWaitMark
Float _fTimeWaitDelta

Float _fTimeEventMark
Float _fTimeEventDelta

Int _UpdCount = 0
Int _UpdSamples = 5

Bool _bTesting
;--=== Events ===--

Event OnInit()
	If !GetConfigBool("LatencyTestEnabled")
		Stop()
		Return
	EndIf
	_fTimeUpdDeltas = New Float[30]
	RegisterForModEvent("vMYC_RequestLatencyCheck","OnRequestLatencyCheck")
	Wait(5)
	If IsRunning()
		DoLatencyCheck()
	EndIf
EndEvent

Event OnRequestLatencyCheck(string eventName, string strArg, float numArg, Form sender)
	If !GetConfigBool("LatencyTestEnabled")
		Stop()
		Return
	EndIf
	Int iSamples = 5
	If numArg
		iSamples = numArg as Int
	EndIf
	If !_bTesting
		DoLatencyCheck(iSamples)
	EndIf
EndEvent

Event OnUpdate()
	If !GetConfigBool("LatencyTestEnabled")
		Stop()
		Return
	EndIf
	_fTimeUpdDeltas[_UpdCount] = GetCurrentRealTime() - _fTimeUpdMark
	_UpdCount += 1
	If _UpdCount < _UpdSamples
		RegisterForSingleUpdate(0)
		_fTimeUpdMark = GetCurrentRealTime()
	Else
		Float fTimeSum = 0.0
		Float fTimeMax = 0.0
		Float fTimeMin = 999999.0
		Int i = _UpdSamples
		While i > 0
			i -= 1
			fTimeSum += _fTimeUpdDeltas[i]
			If _fTimeUpdDeltas[i] > fTimeMax
				fTimeMax = _fTimeUpdDeltas[i]
			EndIf
			If _fTimeUpdDeltas[i] < fTimeMin
				fTimeMin = _fTimeUpdDeltas[i]
			EndIf
		EndWhile
		Debug.Trace("MYC/ScriptLatencyCheck: OnUpdate latency Avg[" + (fTimeSum / _UpdSamples * 1000.0) as Int + "] Min[" + (fTimeMin * 1000) as Int + "] Max[" + (fTimeMax * 1000) as Int + "]")
		Debug.Notification("OnUpdate latency Avg[" + (fTimeSum / _UpdSamples * 1000.0) as Int + "ms] Min[" + (fTimeMin * 1000) as Int + "ms] Max[" + (fTimeMax * 1000) as Int + "ms]")
		_bTesting = False
	EndIf
EndEvent

Function DoLatencyCheck(Int iSamples = 5)
	If !GetConfigBool("LatencyTestEnabled")
		Stop()
		Return
	EndIf
	Debug.Trace("MYC/ScriptLatencyCheck: Running latency checks...")
	DoUpdateCheck(iSamples)
EndFunction

Function DoUpdateCheck(Int iSamples = 5)
	If !GetConfigBool("LatencyTestEnabled")
		Stop()
		Return
	EndIf
	_bTesting = True
	If iSamples > 30
		iSamples = 30
	ElseIf iSamples < 1
		iSamples = 1
	EndIf
	_UpdSamples = iSamples
	_UpdCount = 0
	Debug.Trace("MYC/ScriptLatencyCheck: Testing OnUpdate latency...")
	RegisterForSingleUpdate(0)
	_fTimeUpdMark = GetCurrentRealTime()
EndFunction

