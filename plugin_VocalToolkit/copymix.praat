# Parts of this script were adapted from the script "Add2_variable" by Chris Darwin, https://uk.groups.yahoo.com/neo/groups/praat-users/files/Darwin%20scripts/

form Mix
	real Mix_(%) 50
endform

mix = min(max(mix, 0), 100)
amp1 = min((100 - mix) / 50, 1)
amp2 = min(mix / 50, 1)

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

sf1 = 1 / object[s1].dx
sf2 = 1 / object[s2].dx
sf_max = max(sf1, sf2)

selectObject: s1
dur1 = Get total duration
nch1 = Get number of channels

if sf1 = sf_max
	wrk1 = Copy: "wrk1"
else
	wrk1 = Resample: sf_max, 1
endif

runScript: "fixdc.praat"

selectObject: s2
dur2 = Get total duration
nch2 = Get number of channels

if sf2 = sf_max
	wrk2 = Copy: "wrk2"
else
	wrk2 = Resample: sf_max, 1
endif

runScript: "fixdc.praat"
dur_max = max(dur1, dur2)
ch_max = max(nch1, nch2)

Create Sound from formula: s2$ + "-mix-" + s1$, ch_max, 0, dur_max, sf_max, "(object[wrk1] * amp1) + (object[wrk2] * amp2)"
runScript: "declip.praat"

removeObject: wrk1, wrk2
