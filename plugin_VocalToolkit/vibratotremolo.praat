form Vibrato and tremolo
	real Semitones_(0.5-12) 1.0
	real Pulses_per_second_(1-10) 5.5
endform

semitones = min(max(semitones, 0.5), 12)
pulses_per_second = min(max(pulses_per_second, 1), 10)
pulses = pi * (pulses_per_second * 2) / 100

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	int = Get intensity (dB)

	runScript: "workpre.praat"
	wrk = selected("Sound")
	dur = Get total duration
include minmaxf0.praat

	pitch = noprogress To Pitch: 0.01, minF0, maxF0
	f0 = Get quantile: 0, 0, 0.50, "Hertz"

	if f0 <> undefined
		plusObject: wrk
		manipulation = noprogress To Manipulation

		pitchtier = Extract pitch tier
		for i from 0 to dur * 100
			val[i] = Get value at time: i / 100
		endfor

		vibrato = Create PitchTier: "vibrato", 0, dur
		tremolo = Create IntensityTier: "tremolo", 0, dur
		@vibratoTremolo: round(dur * 100), semitones

		selectObject: manipulation, vibrato
		Replace pitch tier

		durationtier = Create DurationTier: "tmp", 0, dur
		Add point: 0, 1
		plusObject: manipulation
		Replace duration tier

		selectObject: manipulation
		res = Get resynthesis (overlap-add)

		plusObject: tremolo
		tmp = Multiply: "yes"

		runScript: "workpost.praat"
		Scale intensity: int
		runScript: "declip.praat"
		Rename: s$ + "-vibratotremolo"

		removeObject: wrk, pitch, manipulation, pitchtier, vibrato, tremolo, durationtier, res, tmp
	else
		selectObject: s
		Copy: s$ + "-vibratotremolo"

		removeObject: wrk, pitch
	endif
endproc

procedure vibratoTremolo: .tim, .vib
	selectObject: vibrato
	.ramp = 0
	for .i from 0 to .tim - 1
		if .vib <> 0
			if .i <= .tim - 25 and .ramp <= 1
				.ramp = .ramp + 0.04
				if .ramp > 1
					.ramp = 1
				endif
			else
				.ramp = .ramp - 0.04
				if .ramp < 0
					.ramp = 0
				endif
			endif
			.b = 12 * ln(val[.i] / 261.63) / ln(2)
			.c = .b + (.vib / 2) * sin(pulses * .i) * .ramp
			.c = 261.63 * exp(.c * ln(2) / 12)
		else
			.c = val[.i]
		endif
		Add point: .i / 100, .c
	endfor
	if .vib <> 0
		selectObject: tremolo
		.db = 90
		.ramp = 0
		for .i from 0 to .tim - 1
			if .i < 25 and .i < .tim - 25
				.ramp = number(fixed$(.ramp - 0.02, 2))
			endif
			if .i > .tim - 25
				.ramp = number(fixed$(.ramp + 0.02, 2))
			endif
			.newdb = .db + .ramp - (.ramp * sin(pulses * .i) + .ramp)
			Add point: .i / 100, .newdb
		endfor
	endif
endproc
