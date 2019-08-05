form Fade
	real Fade_in_(s) 0.05
	real Fade_out_(s) 0 (= no change)
endform

include batch.praat

procedure action
	s$ = selected$("Sound")
	dur = Get total duration
	stt = Get start time
	et = Get end time
	fade_in = min(max(fade_in, 0), dur)
	fade_out = min(max(fade_out, 0), dur)

	Copy: s$ + "-fade"

	if fade_in > 0
		Fade in: 0, stt, fade_in, "yes"
	endif
	if fade_out > 0
		Fade out: 0, et, -fade_out, "yes"
	endif
endproc
