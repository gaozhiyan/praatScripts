# Parts of this script were adapted from the script "VTchange" by Chris Darwin, https://uk.groups.yahoo.com/neo/groups/praat-users/files/Darwin%20scripts/

form Change vocal tract size
	positive Formant_shift_ratio 1.2
endform

formant_shift_ratio = min(formant_shift_ratio, 3)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	if formant_shift_ratio <> 1
		runScript: "workpre.praat"
		wrk = selected("Sound")
		dur1 = Get total duration
		sf = Get sampling frequency

include minmaxf0.praat

		if formant_shift_ratio > 1
			formula$ = "self / formant_shift_ratio"
			rdur = formant_shift_ratio
			rsf = sf / formant_shift_ratio
		elsif formant_shift_ratio < 1
			maxF0 = maxF0 + 200
			formula$ = "self * (1 - formant_shift_ratio + 1)"
			rdur = 1 / (1 - formant_shift_ratio + 1)
			rsf = sf * (1 - formant_shift_ratio + 1)
		endif

		pitch = noprogress To Pitch: 0.01, minF0, maxF0
		f0 = Get quantile: 0, 0, 0.50, "Hertz"

		if f0 <> undefined
			plusObject: wrk
			manipulation = noprogress To Manipulation

			selectObject: pitch
			Formula: formula$

			pitchtier = Down to PitchTier
			plusObject: manipulation
			Replace pitch tier

			durationtier = Create DurationTier: "tmp", 0, dur1
			Add point: 0, rdur
			plusObject: manipulation
			Replace duration tier

			selectObject: manipulation
			res = Get resynthesis (overlap-add)

			rs = Resample: rsf, 10
			Override sampling frequency: sf
			dur2 = Get total duration
			if dur2 <> dur1
				tmp = Extract part: 0, dur1, "rectangular", 1, "no"
			endif

			runScript: "workpost.praat"
			removeObject: wrk, pitch, pitchtier, durationtier, res, manipulation, rs
			if dur2 <> dur1
				removeObject: tmp
			endif
		else
			selectObject: s
			Copy: "tmp"
			removeObject: wrk, pitch
		endif
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-changevtsize_" + string$(formant_shift_ratio)
endproc
