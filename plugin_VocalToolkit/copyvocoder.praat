s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
int1 = Get intensity (dB)
dur1 = Get total duration

selectObject: s2
int2 = Get intensity (dB)

if int1 <> undefined and int2 <> undefined
	stt = Get start time
	s2dur = Extract part: stt, stt + dur1, "rectangular", 1, "no"

	selectObject: s1
	wrk1 = Copy: "wrk1"
	Scale peak: 0.99

	selectObject: s2dur
	wrk2 = Copy: "wrk2"
	Scale peak: 0.99
	Formula: "self + randomUniform(-0.00001, 0.00001)"

	plusObject: wrk1

	sf1 = 1 / object[wrk1].dx
	sf2 = 1 / object[wrk2].dx
	if sf1 <> sf2
		selectObject: wrk1
		ss1 = Resample: sf2, 10
		ss2 = wrk2
	else
		ss1 = selected("Sound")
		ss2 = selected("Sound", 2)
	endif

	selectObject: ss1
	pred_order = round((1 / object[ss1].dx) / 1000) + 2
	lpc1 = noprogress To LPC (burg): pred_order, 0.025, 0.01, 50
	plusObject: ss1
	source = Filter (inverse)

	selectObject: ss2
	lpc2 = noprogress To LPC (burg): pred_order, 0.025, 0.01, 50

	plusObject: source
	lpcsource = nowarn Filter: "yes"

	plusObject: ss2
	runScript: "copyintensitycontour.praat"
	tmp = selected("Sound")

	runScript: "gate.praat", -40, 0.1, 0.05, "no", "no"
	Scale intensity: int2
	runScript: "declip.praat"
	Rename: s2$ + "-vocoder-" + s1$

	removeObject: s2dur, wrk1, wrk2, lpc1, source, lpc2, lpcsource, tmp
	if sf1 <> sf2
		removeObject: ss1
	endif
else
	Copy: s2$ + "-vocoder-" + s1$
endif
