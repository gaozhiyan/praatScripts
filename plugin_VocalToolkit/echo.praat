# Parts of this script were adapted from the script "echo.praat" by Ingmar Steiner included in "Automatic Speech Data Processing with Praat", http://www.coli.uni-saarland.de/~steiner/teaching/2006/winter/praat/lecturenotes.pdf

form Echo
	positive Delay_(s) 0.5
	positive Amplitude_(Pa) 0.5
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

delay = min(max(delay, 0.01), 10)
amplitude = min(max(amplitude, 0.1), 0.9)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	int = Get intensity (dB)

	if int <> undefined
		if play
			trimmed_tmp = nowarn nocheck Trim silences: 0.08, "yes", 100, 0, -35, 0.1, 0.05, "no", "trimmed"
			if trimmed_tmp = s
				trimmed = Copy: "tmp"
			else
				trimmed = trimmed_tmp
			endif
			trimmed_dur = Get total duration
			stt = Get start time
			if stt <> 0
				Scale times to: 0, trimmed_dur
			endif
			play_dur = min(3, trimmed_dur)
			pre1 = Extract part: 0, play_dur, "rectangular", 1, "no"
			nowarn Fade in: 0, 0, 0.025, "yes"
		endif
		dur = Get total duration

		wrk = Copy: "wrk"
		runScript: "fixdc.praat"
		tt = dur + (delay * (amplitude * 2)) * 10

		result = Extract part: 0, tt, "rectangular", 1, "no"
		Formula: "self + amplitude * self(x - delay)"
		Fade out: 0, tt, -(tt - dur), "yes"
		runScript: "declip.praat"

		removeObject: wrk

		if play
			pre2 = Extract part: 0, play_dur, "rectangular", 1, "no"
			nowarn Fade out: 0, play_dur, -0.025, "yes"
			Play
			selectObject: s
			removeObject: trimmed, pre1, result, pre2
		else
			Rename: s$ + "-echo"
		endif
	else
		if not play
			Copy: s$ + "-echo"
		endif
	endif
endproc
