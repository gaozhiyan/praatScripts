include batch.praat

procedure action
	s$ = selected$("Sound")
	runScript: "changepitch.praat", 0, 0
	Rename: s$ + "-monotone"
endproc
