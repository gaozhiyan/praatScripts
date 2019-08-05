form Vocoder
	positive Frequency_(Hz) 130.81
	optionmenu Carrier_waveform 1
		option Pulse train
		option Sawtooth
		option Square
		option Triangle
		option Hum
		option Phonation
		option White noise
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

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
		dur = Get total duration
		sf = Get sampling frequency

		runScript: "createwaveform.praat", dur, sf, frequency, 0.2, 0, "no", carrier_waveform$, "no"
		carrier = selected("Sound")
		Scale intensity: int

		if play
			selectObject: pre
		else
			selectObject: s
		endif
		tmp = Copy: "tmp"
		plusObject: carrier

		runScript: "copyvocoder.praat"
		result = selected("Sound")

		if play
			nowarn Fade in: 0, 0, 0.025, "yes"
			nowarn Fade out: 0, play_dur, -0.025, "yes"
			Play
			selectObject: s
			removeObject: trimmed, pre, carrier, tmp, result
		else
			Rename: s$ + "-vocoder_" + carrier_waveform$
			removeObject: carrier, tmp
		endif
	else
		if not play
			Copy: s$ + "-vocoder_" + carrier_waveform$
		endif
	endif
endproc
