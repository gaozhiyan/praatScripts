form Rumble filter (high-pass)
	real Frequency_(0-1000_Hz) 120
endform

frequency = min(max(frequency, 0), 1000)

include batch.praat

procedure action
	s$ = selected$("Sound")
	wrk = Copy: "wrk"
	runScript: "fixdc.praat"
	Filter (pass Hann band): frequency, 0, 100
	Rename: s$ + "-rumblefilter_" + string$(frequency)
	runScript: "fixdc.praat"
	removeObject: wrk
endproc
