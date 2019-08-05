include batch.praat

procedure action
	s$ = selected$("Sound")
	Copy: s$ + "-normalized"
	Scale peak: 0.99
endproc
