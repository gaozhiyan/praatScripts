form Add noise
	real Volume_(dB) 40
	choice Type 1
		button White noise
		button Pink noise
		button Brown noise
endform

int = min(max(round(volume), 1), 100)

include batch.praat

procedure action
	s$ = selected$("Sound")
	result = Copy: s$ + "-add_" + type$ + "__" + string$(volume)
	runScript: "fixdc.praat"

	ch = Get number of channels
	if ch = 2
		ch$ = "yes"
	else
		ch$ = "no"
	endif
	dur = Get total duration
	sf = Get sampling frequency

	runScript: "createwaveform.praat", dur, sf, 140, 0.2, 0, ch$, type$, "no"
	noise = selected("Sound")
	Scale intensity: int

	selectObject: result
	Formula: "self + object[noise]"
	runScript: "declip.praat"
	removeObject: noise
endproc
