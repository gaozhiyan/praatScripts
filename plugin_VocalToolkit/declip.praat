include batch.praat

procedure action
	clip = Get absolute extremum: 0, 0, "None"
	if clip = undefined
		clip = 0
	endif
	clip = number(fixed$(clip, 4))
	if clip >= 1
		Scale peak: 0.99
	endif
endproc
