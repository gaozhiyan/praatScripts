form Reverb
	optionmenu Preset 1
		option Ambience
		option Bath
		option Church
		option Hall
		option Plate
		option Robot
		option Room Big
		option Room Medium
		option Room Small
		option Stadium
		option Studio
		option Vocal
	real Mix_(%) 50
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

mix = min(max(mix, 0), 100)

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
			pre1 = Extract part: 0, play_dur, "rectangular", 1, "no"
		endif

		wrk = Copy: "wrk"
		runScript: "fixdc.praat"

		reverb_ir = Read from file: "reverb/" + preset$ + ".flac"
		sf1 = 1 / object[wrk].dx
		sf2 = 1 / object[reverb_ir].dx

		selectObject: wrk
		if sf1 <> sf2
			rs = Resample: sf2, 50
		else
			rs = Copy: "tmp"
		endif

		plusObject: reverb_ir
		reverb = Convolve: "sum", "zero"
		Scale intensity: int

		plusObject: rs
		runScript: "copymix.praat", mix
		runScript: "declip.praat"
		result = selected("Sound")

		removeObject: wrk, reverb_ir, rs, reverb

		if play
			pre2 = Extract part: 0, play_dur, "rectangular", 1, "no"
			nowarn Fade in: 0, 0, 0.025, "yes"
			nowarn Fade out: 0, play_dur, -0.025, "yes"
			Play
			selectObject: s
			removeObject: trimmed, pre1, result, pre2
		else
			Rename: s$ + "-reverb_" + preset$ + "__" + string$(mix)
		endif
	else
		if not play
			Copy: "tmp"
			Rename: s$ + "-reverb_" + preset$ + "__" + string$(mix)
		endif
	endif
endproc
