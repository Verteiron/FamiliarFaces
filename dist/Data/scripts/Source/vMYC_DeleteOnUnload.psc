Scriptname vMYC_DeleteOnUnload extends ObjectReference

Event OnUnload()
	Utility.Wait(0.1)
	Debug.Trace("MYC/" + Self + " /DeleteOnUnload: Deleting myself! :(")
	Delete()
EndEvent
