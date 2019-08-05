form Pitch smoothing
	real Pitch_smoothing_(%) 50
endform

pitch_smoothing = min(max(pitch_smoothing, 0), 100)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	if pitch_smoothing <> 0
		runScript: "workpre.praat"
		wrk = selected("Sound")
include minmaxf0.praat

		pitch = noprogress To Pitch: 0.01, minF0, maxF0
		f0 = Get quantile: 0, 0, 0.50, "Hertz"

		if f0 <> undefined
			plusObject: wrk
			manipulation = noprogress To Manipulation

			selectObject: pitch
			smoothedpitch = Smooth: -6 * ln(pitch_smoothing / 10) + 15

			pitchtier = Down to PitchTier
			plusObject: manipulation
			Replace pitch tier

			selectObject: manipulation
			res = Get resynthesis (overlap-add)
			runScript: "workpost.praat"

			removeObject: wrk, pitch, manipulation, smoothedpitch, pitchtier, res
		else
			selectObject: s
			Copy: "tmp"
			removeObject: wrk, pitch
		endif
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-pitchsmoothing_" + string$(pitch_smoothing)
endproc
