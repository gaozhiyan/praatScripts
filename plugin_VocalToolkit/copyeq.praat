s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
sf1 = Get sampling frequency
int1 = Get intensity (dB)

selectObject: s2
sf2 = Get sampling frequency
sf_max = max(sf2, 44100)
int2 = Get intensity (dB)

if int1 <> undefined and int2 <> undefined
	selectObject: s1
	if sf1 <> sf_max
		wrk1 = Resample: sf_max, 50
	else
		wrk1 = Copy: "wrk1"
	endif

	selectObject: s2
	if sf2 <> sf_max
		wrk2_tmp = Resample: sf_max, 1
		runScript: "workpre.praat"
		wrk2 = selected("Sound")
		removeObject: wrk2_tmp
	else
		runScript: "workpre.praat"
		wrk2 = selected("Sound")
	endif
	dur2 = Get total duration

	selectObject: wrk1
	runScript: "ireq.praat"
	pulse_wrk1 = selected("Sound")

	selectObject: wrk2
	sp = noprogress To Spectrum: "yes"
	Formula: "if row = 1 then if self[1, col] = 0 then self[1, col - 1] else 1 / self[1, col] fi else self fi"

	sp_smooth = Cepstral smoothing: 100
	Filter (pass Hann band): 80, 0, 20
	Filter (pass Hann band): 0, 20000, 100

	tmp1 = noprogress To Sound
	samples = Get number of samples

	tmp2 = Create Sound from formula: "tmp2", 1, 0, 0.05, sf_max, "0"
	Formula: "if col > sf_max / 40 and col <= sf_max / 20 then object[tmp1][col - (sf_max / 40)] else object[tmp1][col + (samples - (sf_max / 40))] fi"

	pulse_inv = Extract part: 0, 0.05, "Hanning", 1, "no"
	Scale peak: 0.99

	plusObject: pulse_wrk1
	pulse_eq_tmp = Convolve: "sum", "zero"

	pulse_eq = Extract part: 0.025, 0.075, "Hanning", 1, "no"
	Scale peak: 0.99

	plusObject: wrk2
	tmp3 = Convolve: "sum", "zero"

	tmp4 = Extract part: 0.025, dur2 + 0.025, "rectangular", 1, "no"

	runScript: "workpost.praat"
	Scale intensity: int2
	runScript: "declip.praat"
	dur = Get total duration
	if dur > 0.5
		Fade in: 0, 0, 0.005, "yes"
		Fade out: 0, dur, -0.005, "yes"
	endif

	if sf2 <> sf_max
		tmp5 = selected("Sound")
		Resample: sf2, 50
		removeObject: tmp5
	endif
	removeObject: wrk1, wrk2, pulse_wrk1, sp, sp_smooth, tmp1, tmp2, pulse_inv, pulse_eq_tmp, pulse_eq, tmp3, tmp4
else
	Copy: "tmp"
endif

Rename: s2$ + "-copyeqcurve-" + s1$
