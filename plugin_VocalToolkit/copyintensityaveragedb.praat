form Copy intensity (average dB)
	boolean Avoid_clipping 1
endform

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

selectObject: s1
int = Get intensity (dB)

selectObject: s2
Copy: s2$ + "-copyintensityaverage-" + s1$
Scale intensity: int

if avoid_clipping
	runScript: "declip.praat"
endif
