form EQ preset
	optionmenu Preset 3
include eqpresetslist.inc
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	sf = Get sampling frequency
	sf_max = max(sf, 44100)
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
			pre = Extract part: 0, play_dur, "rectangular", 1, "no"
		endif

		eq_ir_file = Read from file: "eq/" + preset$ + ".Sound"
		eq_ir_sf = Get sampling frequency
		if eq_ir_sf <> sf_max
			eq_ir = Resample: sf_max, 50
		else
			eq_ir = Copy: "eq_ir"
		endif

		if play
			selectObject: pre
		else
			selectObject: s
		endif

		if sf <> sf_max
			wrk_tmp = Resample: sf_max, 1
			runScript: "workpre.praat"
			wrk = selected("Sound")
			removeObject: wrk_tmp
		else
			runScript: "workpre.praat"
			wrk = selected("Sound")
		endif
		dur1 = Get total duration

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

		plusObject: eq_ir
		pulse_eq_tmp = Convolve: "sum", "zero"

		pulse_eq = Extract part: 0.025, 0.075, "Hanning", 1, "no"
		Scale peak: 0.99

		plusObject: wrk
		tmp3 = Convolve: "sum", "zero"

		tmp4 = Extract part: 0.025, dur1 + 0.025, "rectangular", 1, "no"

		runScript: "workpost.praat"
		Scale intensity: int
		runScript: "declip.praat"
		dur2 = Get total duration
		if dur2 > 0.5
			Fade in: 0, 0, 0.005, "yes"
			Fade out: 0, dur2, -0.005, "yes"
		endif

		if sf <> sf_max
			tmp5 = selected("Sound")
			Resample: sf, 50
			removeObject: tmp5
		endif

		result = selected("Sound")
		removeObject: eq_ir_file, eq_ir, wrk, sp, sp_smooth, tmp1, tmp2, pulse_inv, pulse_eq_tmp, pulse_eq, tmp3, tmp4

		if play
			nowarn Fade in: 0, 0, 0.025, "yes"
			nowarn Fade out: 0, play_dur, -0.025, "yes"
			Play
			selectObject: s
			removeObject: trimmed, pre, result
		else
			Rename: s$ + "-EQpreset_" + preset$
		endif
	else
		if not play
			Copy: s$ + "-EQpreset_" + preset$
		endif
	endif
endproc
