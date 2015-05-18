Scriptname vFFC_DeleteOnUnload extends ObjectReference

Event OnUnload()
	Utility.Wait(1)
	;Debug.Trace("vFF/" + Self + " /DeleteOnUnload: Deleting myself! :(")
	Delete()
EndEvent
