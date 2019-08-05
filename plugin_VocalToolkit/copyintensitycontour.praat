s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
int1 = Get intensity (dB)

runScript: "workpre.praat"
wrk1 = selected("Sound")

selectObject: s2
int2 = Get intensity (dB)

if int1 <> undefined and int2 <> undefined
	runScript: "workpre.praat"
	wrk2 = selected("Sound")

	selectObject: wrk1
	intensity_wrk1 = noprogress To Intensity: 100, 0.01, "no"
	intensitytier_wrk1 = Down to IntensityTier

	selectObject: wrk2
	intensity_wrk2 = noprogress To Intensity: 100, 0.01, "no"
	max1 = Get maximum: 0, 0, "Parabolic"
	Formula: "max1 - self"

	intensitytier_wrk2 = Down to IntensityTier
	plusObject: wrk2
	tmp1 = Multiply: "yes"
	plusObject: intensitytier_wrk1
	tmp2 = Multiply: "yes"

	runScript: "workpost.praat"
	Scale intensity: int1
	runScript: "declip.praat"

	removeObject: wrk1, wrk2, intensity_wrk1, intensitytier_wrk1, intensity_wrk2, intensitytier_wrk2, tmp1, tmp2
else
	Copy: "tmp"
	removeObject: wrk1
endif

Rename: s2$ + "-copyintensitycontour-" + s1$
