form Breathiness
	real Breathiness_(%) 25
endform

breathiness = min(max(breathiness, 0), 100)

include batch.praat

procedure action
	s$ = selected$("Sound")

	if breathiness <> 0
		wrk = Copy: "wrk"
		runScript: "whisper.praat"
		whisper = selected("Sound")
		plusObject: wrk
		runScript: "copymix.praat", breathiness
		runScript: "fixdc.praat"
		removeObject: wrk, whisper
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-breathiness_" + string$(breathiness)
endproc
