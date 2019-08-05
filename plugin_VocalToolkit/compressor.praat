form Compressor
	real Compression_(%) 25
endform

compression = min(max(compression, 0), 100)

include batch.praat

procedure action
	s$ = selected$("Sound")
	int = Get intensity (dB)

	if compression <> 0 and int <> undefined
		runScript: "workpre.praat"
		wrk = selected("Sound")

		intensity = noprogress To Intensity: 400, 0, "no"
		Formula: "-self * compression / 100"

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

	Rename: s$ + "-compressor_" + string$(compression)
endproc
