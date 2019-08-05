form Change semitones
	real Semitones_(-24_to_+24) 12
endform

semitones = min(max(semitones, -24), 24)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	if semitones <> 0
		runScript: "workpre.praat"
		wrk = selected("Sound")
include minmaxf0.praat

		pitch = noprogress To Pitch: 0.01, minF0, maxF0
		f0 = Get quantile: 0, 0, 0.50, "Hertz"

		if f0 <> undefined
			f0 = number(fixed$(f0, 3))
			hz = f0 * exp(semitones * ln(2) / 12)
			hz = number(fixed$(hz, 3))
			selectObject: s
			runScript: "changepitch.praat", hz, 100
		else
			selectObject: s
			Copy: "tmp"
		endif

		removeObject: wrk, pitch
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-changesemitones_" + string$(semitones)
endproc
