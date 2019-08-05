form EQ 10 bands
	real Band_1.__31.5_Hz_(dB) -24
	real Band_2.__63_Hz_(dB) -24
	real Band_3.__125_Hz_(dB) -24
	real Band_4.__250_Hz_(dB) -24
	real Band_5.__500_Hz_(dB) 24
	real Band_6.__1000_Hz_(dB) 24
	real Band_7.__2000_Hz_(dB) 24
	real Band_8.__4000_Hz_(dB) -24
	real Band_9.__8000_Hz_(dB) -24
	real Band_10.__16000_Hz_(dB) -24
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

band_1.__31.5_Hz = min(max(round(band_1.__31.5_Hz), -24), 24)
band_2.__63_Hz = min(max(round(band_2.__63_Hz), -24), 24)
band_3.__125_Hz = min(max(round(band_3.__125_Hz), -24), 24)
band_4.__250_Hz = min(max(round(band_4.__250_Hz), -24), 24)
band_5.__500_Hz = min(max(round(band_5.__500_Hz), -24), 24)
band_6.__1000_Hz = min(max(round(band_6.__1000_Hz), -24), 24)
band_7.__2000_Hz = min(max(round(band_7.__2000_Hz), -24), 24)
band_8.__4000_Hz = min(max(round(band_8.__4000_Hz), -24), 24)
band_9.__8000_Hz = min(max(round(band_9.__8000_Hz), -24), 24)
band_10.__16000_Hz = min(max(round(band_10.__16000_Hz), -24), 24)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
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

		runScript: "workpre.praat"
		wrk = selected("Sound")
		sf = Get sampling frequency
		dur1 = Get total duration

		pointprocess = Create empty PointProcess: "pulse", 0, 0.05
		Add point: 0.025

		pulse = noprogress To Sound (pulse train): sf, 1, 0.05, 2000

		sp_pulse = noprogress To Spectrum: "no"

		buffer = Copy: "buffer"
		Formula: "0"

		sp_eq = Copy: "sp_eq"
		@eqBand: 0, 44.2, band_1.__31.5_Hz, 20
		@eqBand: 44.2, 88.4, band_2.__63_Hz, 20
		@eqBand: 88.4, 177, band_3.__125_Hz, 40
		@eqBand: 177, 354, band_4.__250_Hz, 80
		@eqBand: 354, 707, band_5.__500_Hz, 100
		@eqBand: 707, 1414, band_6.__1000_Hz, 100
		@eqBand: 1414, 2828, band_7.__2000_Hz, 100
		@eqBand: 2828, 5657, band_8.__4000_Hz, 100
		@eqBand: 5657, 11314, band_9.__8000_Hz, 100
		@eqBand: 11314, max(12000, sf / 2), band_10.__16000_Hz, 100
		Filter (pass Hann band): 80, 0, 20
		Filter (pass Hann band): 0, 20000, 100

		pulse_eq_tmp = noprogress To Sound
		dur2 = Get total duration

		pulse_eq = Extract part: (dur2 - 0.05) / 2, dur2 - ((dur2 - 0.05) / 2), "Hanning", 1, "no"
		Scale peak: 0.99
		pulse_sf = Get sampling frequency
		if pulse_sf <> sf
			Override sampling frequency: sf
		endif

		plusObject: wrk
		tmp1 = Convolve: "sum", "zero"

		tmp2 = Extract part: 0.025, dur1 + 0.025, "rectangular", 1, "no"

		runScript: "workpost.praat"
		Scale intensity: int
		runScript: "declip.praat"
		result = selected("Sound")
		dur3 = Get total duration
		if dur3 > 0.5
			Fade in: 0, 0, 0.005, "yes"
			Fade out: 0, dur3, -0.005, "yes"
		endif

		removeObject: wrk, pointprocess, pulse, sp_pulse, buffer, sp_eq, pulse_eq_tmp, pulse_eq, tmp1, tmp2

		if play
			nowarn Fade in: 0, 0, 0.025, "yes"
			nowarn Fade out: 0, play_dur, -0.025, "yes"
			Play
			selectObject: s
			removeObject: trimmed, pre, result
		else
			Rename: s$ + "-EQ10bands"
		endif
	else
		if not play
			Copy: s$ + "-EQ10bands"
		endif
	endif
endproc

procedure eqBand: .bnd1, .bnd2, .db, .smoothing
	.amp = 0.00002 * 10 ^ (.db / 20)
	selectObject: buffer
	Formula: "object[sp_pulse]"
	Filter (pass Hann band): .bnd1, .bnd2, .smoothing
	Formula: "self * .amp"
	selectObject: sp_eq
	Formula: "self + object[buffer]"
endproc
