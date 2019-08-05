include batch.praat

procedure action
	s$ = selected$("Sound")
	runScript: "changepitch.praat", 0, -100
	Rename: s$ + "-invertpitch"
endproc
