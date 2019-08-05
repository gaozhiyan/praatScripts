s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
runScript: "workpre.praat"
wrk1 = selected("Sound")
include minmaxf0.praat

pitch_1 = noprogress To Pitch: 0.01, minF0, maxF0
f0_1 = Get quantile: 0, 0, 0.50, "Hertz"

if f0_1 <> undefined
	pitchtier_1 = Down to PitchTier

	selectObject: s2
	runScript: "workpre.praat"
	wrk2 = selected("Sound")
	dur = Get total duration
include minmaxf0.praat

	pitch_2 = noprogress To Pitch: 0.01, minF0, maxF0
	f0_2 = Get quantile: 0, 0, 0.50, "Hertz"

	if f0_2 <> undefined
		plusObject: wrk2
		manipulation = noprogress To Manipulation
		plusObject: pitchtier_1
		Replace pitch tier

		durationtier = Create DurationTier: "tmp", 0, dur
		Add point: 0, 1
		plusObject: manipulation
		Replace duration tier

		selectObject: manipulation
		res = Get resynthesis (overlap-add)
		runScript: "workpost.praat"

		removeObject: wrk1, pitch_1, pitchtier_1, wrk2, pitch_2, manipulation, durationtier, res
	else
		selectObject: s2
		Copy: "tmp"
		removeObject: wrk1, pitch_1, pitchtier_1, wrk2, pitch_2
	endif
else
	selectObject: s2
	Copy: "tmp"
	removeObject: wrk1, pitch_1
endif

Rename: s2$ + "-copypitchcontour-" + s1$
