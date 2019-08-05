include batch.praat

procedure action
	s = selected("Sound")
	dur1 = Get total duration
	ch = Get number of channels

	stt = Get start time
	if stt <> 0
		Scale times to: 0, dur1
	endif

	if dur1 > 5
		tmp1 = Extract part: 0, 5, "rectangular", 1, "no"
	endif

	if ch > 1
		tmp2 = Extract one channel: 1
	endif

	last_sel = selected("Sound")
	trimmed = nowarn nocheck Trim silences: 0.08, "no", 100, 0, -35, 0.1, 0.05, "no", "trimmed"
	if trimmed = last_sel
		tmp3 = Copy: "tmp3"
		dur2 = Get total duration
	else
		tmp3 = trimmed
		dur2 = Get total duration
		stt = Get start time
		if stt <> 0
			Scale times to: 0, dur2
		endif
	endif

	tmp4 = Filter (stop Hann band): 20, 0, 20

	tmp5 = Extract part: 0, dur2, "Gaussian2", 1, "no"
	int = Get intensity (dB)

	if dur1 > 5
		removeObject: tmp1
	endif
	if ch > 1
		removeObject: tmp2
	endif
	removeObject: tmp3, tmp4, tmp5

	selectObject: s

	if int > 10
		Subtract mean
		tmp6 = Filter (stop Hann band): 0, 60, 20
		if dur1 > 0.5
			Fade in: 0, 0, 0.005, "yes"
			Fade out: 0, dur1, -0.005, "yes"
		endif
		selectObject: s
		Formula: "object[tmp6]"
		removeObject: tmp6
	endif

	runScript: "declip.praat"
endproc
