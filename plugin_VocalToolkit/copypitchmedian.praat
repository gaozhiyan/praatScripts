form Copy pitch median
	boolean Copy_also_pitch_variation 0
	boolean Show_info 1
endform

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

if show_info
	if copy_also_pitch_variation
		appendInfoLine: newline$, "Copy pitch median and variation..."
	else
		appendInfoLine: newline$, "Copy pitch median..."
	endif
endif

selectObject: s1
runScript: "workpre.praat"
wrk1 = selected("Sound")
include minmaxf0.praat

pitch_1 = noprogress To Pitch: 0.01, minF0, maxF0
f0_1 = Get quantile: 0, 0, 0.50, "Hertz"
sd_1 = Get standard deviation: 0, 0, "semitones"

if show_info
	appendInfoLine: tab$, s1, ". Sound ", s1$
	appendInfoLine: tab$, tab$, "Median pitch: ", number(fixed$(f0_1, 3)), " Hz"
	if copy_also_pitch_variation
		appendInfoLine: tab$, tab$, "Standard deviation: ", number(fixed$(sd_1, 3)), " semitones"
	endif
endif

if f0_1 <> undefined
	selectObject: s2
	runScript: "workpre.praat"
	wrk2 = selected("Sound")
	dur = Get total duration
include minmaxf0.praat

	pitch_2 = noprogress To Pitch: 0.01, minF0, maxF0
	f0_2 = Get quantile: 0, 0, 0.50, "Hertz"
	sd_2 = Get standard deviation: 0, 0, "semitones"

	if show_info
		appendInfoLine: newline$, tab$, s2, ". Sound ", s2$
		appendInfoLine: tab$, tab$, "Median pitch: ", number(fixed$(f0_2, 3)), " Hz"
		if copy_also_pitch_variation
			appendInfoLine: tab$, tab$, "Standard deviation: ", number(fixed$(sd_2, 3)), " semitones"
		endif
	endif

	if f0_2 <> undefined
		if number(fixed$(f0_1, 2)) <> number(fixed$(f0_2, 2)) or number(fixed$(sd_1, 2)) <> number(fixed$(sd_2, 2))
			plusObject: wrk2
			manipulation = noprogress To Manipulation

			pitchtier = Extract pitch tier

			durationtier = Create DurationTier: "tmp", 0, dur
			Add point: 0, 1
			plusObject: manipulation
			Replace duration tier

			selectObject: pitchtier
			f0_f = f0_1 / f0_2
			Formula: "self * f0_f"

			if copy_also_pitch_variation
				sd_f = sd_1 / sd_2
				if round(sd_f * 100) <> 100
					fref_st = 12 * ln(f0_1 / 100) / ln(2)
					Formula: "if self <> undefined then 100 * exp((fref_st + 12 * ln(self / f0_1) / ln(2) * sd_f) * ln(2) / 12) else self fi"
				endif
			endif

			plusObject: manipulation
			Replace pitch tier

			selectObject: manipulation
			res = Get resynthesis (overlap-add)
			runScript: "workpost.praat"
			Rename: s2$ + "-copypitchmedian-" + s1$

			removeObject: wrk1, pitch_1, wrk2, pitch_2, manipulation, pitchtier, durationtier, res
		else
			if copy_also_pitch_variation
				sd_f = 1
			endif
			selectObject: s2
			Copy: s2$ + "-copypitchmedian-" + s1$
			removeObject: wrk1, pitch_1, wrk2, pitch_2
		endif

		if show_info
			appendInfoLine: newline$, tab$, "New pitch median: ", number(fixed$(f0_1, 3)), " Hz"
			if copy_also_pitch_variation
				appendInfoLine: tab$, "Pitch variation applied: ", round(sd_f * 100), "%   (", number(fixed$(sd_1, 3)), " semitones / ", number(fixed$(sd_2, 3)), " semitones)"
			endif
		endif
	else
		selectObject: s2
		Copy: s2$ + "-copypitchmedian-" + s1$
		removeObject: wrk1, pitch_1, wrk2, pitch_2

		if show_info
			appendInfoLine: newline$, tab$, "There were no voiced segments found."
		endif
	endif
else
	selectObject: s2
	Copy: s2$ + "-copypitchmedian-" + s1$
	removeObject: wrk1, pitch_1

	if show_info
		appendInfoLine: newline$, tab$, "There were no voiced segments found."
	endif
endif
