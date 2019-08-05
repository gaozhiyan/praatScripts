include batch.praat

procedure action
	s$ = selected$("Sound")
	int = Get intensity (dB)

	if int <> undefined
		runScript: "workpre.praat"
		tmp1 = selected("Sound")
		sf = Get sampling frequency
		dur = Get total duration
		Scale peak: 0.99

		runScript: "gate.praat", -40, 0.1, 0.05, "no", "no"
		tmp2 = selected("Sound")
		Formula: "self + randomUniform(-0.00001, 0.00001)"

		pred_order = round(sf / 1000) + 2
		lpc = noprogress To LPC (burg): pred_order, 0.025, 0.01, 50

		noise = Create Sound from formula: "noise", 1, 0, dur, sf, "randomUniform(-1, 1)"
		plusObject: lpc
		tmp3 = Filter: "yes"

		runScript: "workpost.praat"
		tmp4 = selected("Sound")

		runScript: "eq10bands.praat", -24, -24, -24, -24, 12, 24, 24, 12, 12, -6, "no"
		tmp5 = selected("Sound")

		runScript: "gate.praat", -90, 0.1, 0.05, "no", "no"
		tmp6 = selected("Sound")

		Scale peak: 0.99
		runScript: "limiter.praat", 85
		runScript: "fixdc.praat"
		Scale intensity: int
		runScript: "declip.praat"

		removeObject: tmp1, tmp2, lpc, noise, tmp3, tmp4, tmp5, tmp6
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-whisper"
endproc
