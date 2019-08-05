form Cut pauses
	boolean Only_at_start_and_end 0
endform

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	ch = Get number of channels
	if ch = 1
		wrk = Copy: "wrk"
	else
		wrk = Extract one channel: 1
	endif
	runScript: "fixdc.praat"

	trimmed = nowarn nocheck Trim silences: 0.08, only_at_start_and_end, 100, 0, -35, 0.1, 0.05, "no", "trimmed"
	if trimmed = wrk
		Copy: "tmp"
	else
		stt = Get start time
		if stt <> 0
			dur = Get total duration
			Scale times to: 0, dur
		endif
	endif

	if ch <> 1
		tmp = selected("Sound")
		Convert to stereo
		removeObject: tmp
	endif
	Rename: s$ + "-cutpauses"

	removeObject: wrk
endproc
