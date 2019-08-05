form Dynamic time warping (DTW)
	choice Slope_constraint 3
		button no restriction
		button 1/3 < slope < 3
		button 1/2 < slope < 2
		button 2/3 < slope < 3/2
endform

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
int1 = Get intensity (dB)

selectObject: s2
int2 = Get intensity (dB)

if int1 <> undefined and int2 <> undefined
	sf2 = Get sampling frequency

	runScript: "workpre.praat"
	wrk1 = selected("Sound")
	dur1 = Get total duration

	selectObject: s1
	sf1 = Get sampling frequency

	runScript: "workpre.praat"
	if sf1 <> sf2
		tmp1 = selected("Sound")
		Resample: sf2, 50
		removeObject: tmp1
	endif
	wrk2 = selected("Sound")
	dur2 = Get total duration

	plusObject: wrk1
	time_step = 0.005
	dtw = noprogress To DTW: 0.015, time_step, 0.1, slope_constraint$

	n_frames = ceiling(dur2 / time_step)
	x_time = 0
	for i to n_frames
		time_start[i] = Get y time from x time: x_time
		time_end[i] = Get y time from x time: x_time + time_step
		time_r[i] = time_step / (time_end[i] - time_start[i])
		x_time += time_step
	endfor

	durationtier = Create DurationTier: "tmp", 0, dur1
	for i to n_frames
		if i = 1
			Add point: time_start[i], time_r[i]
		else
			if number(fixed$(time_r[i], 6)) <> number(fixed$(time_r[i - 1], 6))
				Add point: time_start[i] + 0.00000000001, time_r[i]
			endif
		endif
		if i = n_frames
			Add point: time_end[i], time_r[i]
		else
			if number(fixed$(time_r[i], 6)) <> number(fixed$(time_r[i + 1], 6))
				Add point: time_end[i], time_r[i]
			endif
		endif
	endfor

	selectObject: wrk1
include minmaxf0.praat

	pitch = noprogress To Pitch (ac): time_step, minF0, 15, "no", 0.02, 0.25, 0.01, 0.35, 0.14, maxF0

	plusObject: wrk1
	manipulation = noprogress To Manipulation

	plusObject: durationtier
	Replace duration tier

	selectObject: manipulation
	res = Get resynthesis (overlap-add)
	dur3 = Get total duration
	if dur3 <> dur2
		tmp2 = Extract part: 0, dur2, "rectangular", 1, "no"
	endif

	runScript: "workpost.praat"
	runScript: "declip.praat"
	Rename: s2$ + "-dtw-" + s1$

	removeObject: wrk1, wrk2, dtw, durationtier, pitch, manipulation, res
	if dur3 <> dur2
		removeObject: tmp2
	endif
else
	Copy: s2$ + "-dtw-" + s1$
endif
