form Change pitch
	real New_pitch_median_(Hz) 0.0 (= no change)
	real Pitch_variation_(%) 100 (= no change)
endform

new_pitch_median = max(new_pitch_median, 0)
pitch_variation_factor = round(pitch_variation) / 100

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	if new_pitch_median <> 0 or pitch_variation_factor <> 1
		runScript: "workpre.praat"
		wrk = selected("Sound")
		dur = Get total duration
include minmaxf0.praat

		pitch = noprogress To Pitch: 0.01, minF0, maxF0
		f0 = Get quantile: 0, 0, 0.50, "Hertz"

		if f0 <> undefined
			if number(fixed$(f0, 2)) <> number(fixed$(new_pitch_median, 2)) or pitch_variation_factor <> 1
				plusObject: wrk
				manipulation = noprogress To Manipulation

				pitchtier = Extract pitch tier

				durationtier = Create DurationTier: "tmp", 0, dur
				Add point: 0, 1
				plusObject: manipulation
				Replace duration tier

				selectObject: pitchtier
				if new_pitch_median = 0
					pm = number(fixed$(f0, 3))
				else
					f0_f = new_pitch_median / f0
					Formula: "self * f0_f"
					pm = number(fixed$(new_pitch_median, 3))
				endif

				if pitch_variation_factor <> 1
					fref_st = 12 * ln(pm / 100) / ln(2)
					Formula: "if self <> undefined then 100 * exp((fref_st + 12 * ln(self / pm) / ln(2) * pitch_variation_factor) * ln(2) / 12) else self fi"
				endif

				plusObject: manipulation
				Replace pitch tier

				selectObject: manipulation
				res = Get resynthesis (overlap-add)
				runScript: "workpost.praat"

				removeObject: wrk, pitch, manipulation, pitchtier, durationtier, res
			else
				selectObject: s
				Copy: "tmp"
				removeObject: wrk, pitch
			endif
		else
			selectObject: s
			Copy: "tmp"
			removeObject: wrk, pitch
		endif
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-changepitchmedian_" + string$(new_pitch_median) + "__" + string$(pitch_variation)
endproc
