form Limiter
	real Threshold_(dB) 80
endform

threshold = min(max(threshold, 0), 100)

include batch.praat

procedure action
	s$ = selected$("Sound")
	int = Get intensity (dB)

	if int <> undefined
		runScript: "workpre.praat"
		wrk = selected("Sound")

		intensity = noprogress To Intensity: 400, 0, "no"
		Formula: "if round(self) = 0 then 0 else if self > threshold then 1 / self - (self - threshold) else 1 / self fi fi"

		intensitytier = Down to IntensityTier
		plusObject: wrk
		tmp = Multiply: "yes"

		runScript: "workpost.praat"
		Scale intensity: int
		runScript: "declip.praat"

		removeObject: wrk, intensity, intensitytier, tmp
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-limiter_" + string$(threshold)
endproc
