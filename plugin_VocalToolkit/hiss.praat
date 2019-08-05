form Hiss filter (low-pass)
	real Frequency_(1000-20000_Hz) 7500
endform

frequency = min(max(frequency, 1000), 20000)

include batch.praat

procedure action
	s$ = selected$("Sound")
	wrk = Copy: "wrk"
	runScript: "fixdc.praat"
	Filter (pass Hann band): 0, frequency, 100
	Rename: s$ + "-hissfilter_" + string$(frequency)
	runScript: "fixdc.praat"
	removeObject: wrk
endproc
