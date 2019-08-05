form Change duration
	positive New_duration_(s) 3.0
	choice Method 1
		button Stretch
		button Cut or add time
endform

include batch.praat

procedure action
	s$ = selected$("Sound")
	dur = Get total duration

	if dur <> new_duration
		if method = 1
			wrk = Copy: "wrk"
			runScript: "fixdc.praat"
include minmaxf0.praat

			factor = min(new_duration / dur, 3)
			noprogress Lengthen (overlap-add): minF0, maxF0, factor
			tmp_dur = Get total duration
			if number(fixed$(tmp_dur, 6)) <> number(fixed$(new_duration, 6))
				repeat
					tmp = selected("Sound")
					factor = min(new_duration / tmp_dur, 3)
					noprogress Lengthen (overlap-add): minF0, maxF0, factor
					tmp_dur = Get total duration
					removeObject: tmp
				until tmp_dur >= new_duration
			endif
			runScript: "fixdc.praat"

			removeObject: wrk
		elsif method = 2
			stt = Get start time
			Extract part: stt, stt + new_duration, "rectangular", 1, "no"
		endif
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-changeduration_" + method$ + "__" + string$(new_duration)
endproc
