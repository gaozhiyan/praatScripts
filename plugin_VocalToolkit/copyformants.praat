form Copy formants
	comment The mean F1-F5 frequencies will be shifted to match those of the first Sound.
	comment Formant determination
	positive Maximum_formant_first_Sound_(Hz) 5500 (= adult female)
	positive Maximum_formant_second_Sound_(Hz) 5500 (= adult female)
	comment Set 5000 Hz for men, 5500 Hz for women or up to 8000 Hz for children.
	boolean Process_only_voiced_parts 1
	boolean Retrieve_intensity_contour 1
endform

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)
s2or = s2

selectObject: s1
int1 = Get intensity (dB)

selectObject: s2
int2 = Get intensity (dB)

if int1 <> undefined and int2 <> undefined
	if process_only_voiced_parts
		selectObject: s1, s2
		@extractUV
		selectObject: extractUV.s1_v
		int_v1 = Get intensity (dB)
		selectObject: extractUV.s2_v
		int_v2 = Get intensity (dB)
		if int_v1 <> undefined and int_v2 <> undefined
			s1 = extractUV.s1_v
			s2 = extractUV.s2_v
			int2 = int_v2
		else
			process_only_voiced_parts = 0
			removeObject: extractUV.s1_u, extractUV.s1_v, extractUV.s2_u, extractUV.s2_v
		endif
	endif

	selectObject: s1
	runScript: "workpre.praat"
	wrk1 = selected("Sound")

	selectObject: s2
	runScript: "workpre.praat"
	wrk2 = selected("Sound")

	selectObject: wrk1
	runScript: "extractvowels.praat", "no"
	vow1_tmp = selected("Sound")

	runScript: "workpre.praat"
	vow1 = selected("Sound")

	selectObject: wrk2
	runScript: "extractvowels.praat", "no"
	vow2_tmp = selected("Sound")

	runScript: "workpre.praat"
	vow2 = selected("Sound")

	selectObject: vow1
	formant1 = noprogress nowarn To Formant (robust): 0.005, 5, maximum_formant_first_Sound, 0.025, 50, 1.5, 5, 0.000001
	s1f1 = Get mean: 1, 0, 0, "hertz"
	s1f2 = Get mean: 2, 0, 0, "hertz"
	s1f3 = Get mean: 3, 0, 0, "hertz"
	s1f4 = Get mean: 4, 0, 0, "hertz"
	s1f5 = Get mean: 5, 0, 0, "hertz"

	selectObject: vow2
	formant2 = noprogress nowarn To Formant (robust): 0.005, 5, maximum_formant_second_Sound, 0.025, 50, 1.5, 5, 0.000001
	s2f1 = Get mean: 1, 0, 0, "hertz"
	s2f2 = Get mean: 2, 0, 0, "hertz"
	s2f3 = Get mean: 3, 0, 0, "hertz"
	s2f4 = Get mean: 4, 0, 0, "hertz"
	s2f5 = Get mean: 5, 0, 0, "hertz"

	if s1f1 = undefined
		s1f1 = 0
	endif
	if s1f2 = undefined
		s1f2 = 0
	endif
	if s1f3 = undefined
		s1f3 = 0
	endif
	if s1f4 = undefined
		s1f4 = 0
	endif
	if s1f5 = undefined
		s1f5 = 0
	endif
	if s2f1 = undefined
		s2f1 = 0
	endif
	if s2f2 = undefined
		s2f2 = 0
	endif
	if s2f3 = undefined
		s2f3 = 0
	endif
	if s2f4 = undefined
		s2f4 = 0
	endif
	if s2f5 = undefined
		s2f5 = 0
	endif
	df1 = s1f1 - s2f1
	df2 = s1f2 - s2f2
	df3 = s1f3 - s2f3
	df4 = s1f4 - s2f4
	df5 = s1f5 - s2f5

	selectObject: wrk2
	sf1 = Get sampling frequency
	hf = Filter (pass Hann band): maximum_formant_second_Sound, 0, 100

	selectObject: wrk2
	sf2 = maximum_formant_second_Sound * 2
	rs1 = Resample: sf2, 10

	formant3 = noprogress nowarn To Formant (robust): 0.005, 5, maximum_formant_second_Sound, 0.025, 50, 1.5, 5, 0.000001

	lpc1 = noprogress To LPC: sf2
	plusObject: rs1
	source = Filter (inverse)

	selectObject: formant3
	filtr = Copy: "filtr"

	if abs(df1) < 1000
		Formula (frequencies): "if row = 1 then self + df1 else self fi"
	endif
	if abs(df2) < 2500
		Formula (frequencies): "if row = 2 then self + df2 else self fi"
	endif
	if abs(df3) < 2500
		Formula (frequencies): "if row = 3 then self + df3 else self fi"
	endif
	if abs(df4) < 2500
		Formula (frequencies): "if row = 4 then self + df4 else self fi"
	endif
	if abs(df5) < 2500
		Formula (frequencies): "if row = 5 then self + df5 else self fi"
	endif

	lpc2 = noprogress To LPC: sf2
	plusObject: source
	tmp = Filter: "no"

	rs2 = Resample: sf1, 10
	Formula: "self + object[hf]"

	runScript: "workpost.praat"
	Scale intensity: int2
	runScript: "declip.praat"

	if process_only_voiced_parts
		@mixUV
	endif

	if retrieve_intensity_contour
		tmp3 = selected("Sound")
		plusObject: s2or
		runScript: "copyintensitycontour.praat"
		removeObject: tmp3
	endif
	dur = Get total duration
	if dur > 0.5
		Fade in: 0, 0, 0.005, "yes"
		Fade out: 0, dur, -0.005, "yes"
	endif

	Rename: s2$ + "-copyformants-" + s1$
	removeObject: wrk1, wrk2, vow1_tmp, vow1, vow2_tmp, vow2, formant1, formant2, hf, rs1, formant3, lpc1, source, filtr, lpc2, tmp, rs2
else
	Copy: s2$ + "-copyformants-" + s1$
endif

procedure extractUV
	runScript: "voicedunvoiced.praat", "no"
	select all
	.s1_u = selected("Sound", -4)
	.s1_v = selected("Sound", -3)
	.s2_u = selected("Sound", -2)
	.s2_v = selected("Sound", -1)
endproc

procedure mixUV
	.sel_tmp = selected("Sound")
	plusObject: extractUV.s2_u
	runScript: "copymix.praat", 50
	removeObject: extractUV.s1_u, extractUV.s1_v, extractUV.s2_u, extractUV.s2_v, .sel_tmp
endproc
