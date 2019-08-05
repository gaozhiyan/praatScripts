include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	result = Copy: s$ + "-markpitch"
	runScript: "fixdc.praat"

	wrk = Copy: "wrk"
	Scale peak: 0.99

	intensity = noprogress To Intensity: 40, 0.01, "yes"

	selectObject: wrk
include minmaxf0.praat

	pitch_tmp = noprogress To Pitch (ac): 0.01, minF0, 15, "no", 0.05, 0.45, 0.01, 0.35, 0.16, maxF0

	smoothedpitch = Smooth: 60

	pitchtier = Down to PitchTier
	Stylize: 0.5, "Semitones"

	selectObject: smoothedpitch
	pointprocess = noprogress To PointProcess

	tg = noprogress To TextGrid (vuv): 0.02, 0.01
	Rename: s$ + "-markpitch"
	Set tier name: 1, "Medians (Hz)"
	@markSemitones
	@optimizeTimes
	@optimizeTimes
	@getPitchValues
	@optimizeSemitones
	@joinUnvoiced
	@splitEqualNotes
	@optimizeTimes
	@setPitchValues

	removeObject: wrk, intensity, pitch_tmp, smoothedpitch, pitchtier, pointprocess

	plusObject: result
	View & Edit
endproc

procedure markSemitones
	selectObject: tg
	.n_intervals = Get number of intervals: 1
	for .i to .n_intervals
		.interval_label$ = Get label of interval: 1, .i
		if .interval_label$ = "V"
			Set interval text: 1, .i, ""
			.start_time = Get start time of interval: 1, .i
			.end_time = Get end time of interval: 1, .i

			selectObject: pitchtier
			.start_index = Get nearest index from time: .start_time
			.end_index = Get nearest index from time: .end_time
			for .j from .start_index to .end_index
				.index_time[.j] = Get time from index: .j
			endfor

			selectObject: tg
			for .j from .start_index + 1 to .end_index - 1
				Insert boundary: 1, .index_time[.j]
				.n_intervals += 1
				.i += 1
			endfor
		endif
	endfor
endproc

procedure optimizeTimes
	selectObject: tg
	.i = Get number of intervals: 1
	while .i > 1
		.current_label$ = Get label of interval: 1, .i
		.prev_label$ = Get label of interval: 1, .i - 1
		.n_intervals = Get number of intervals: 1
		if .i < .n_intervals
			.next_label$ = Get label of interval: 1, .i + 1
		else
			.next_label$ = "U"
		endif
		.start_time = Get start time of interval: 1, .i
		.end_time = Get end time of interval: 1, .i
		.interval_time = number(fixed$(.end_time - .start_time, 2))
		if .current_label$ <> "U" and .prev_label$ <> "U" and .next_label$ <> "U" and .interval_time < 0.12
			selectObject: intensity
			.min_time = Get time of minimum: .start_time, .end_time, "Parabolic"
			selectObject: tg
			Remove boundary at time: 1, .start_time
			Remove boundary at time: 1, .end_time
			Insert boundary: 1, .min_time
		endif
		if .current_label$ <> "U" and .prev_label$ <> "U" and .next_label$ = "U" and .interval_time < 0.12
			Remove boundary at time: 1, .start_time
		endif
		if .current_label$ <> "U" and .prev_label$ = "U" and .next_label$ <> "U" and .interval_time < 0.12
			Remove boundary at time: 1, .end_time
		endif
		if .current_label$ <> "U" and .prev_label$ = "U" and .next_label$ = "U" and .interval_time < 0.075
			Set interval text: 1, .i - 1, ""
			Remove boundary at time: 1, .start_time
			Remove boundary at time: 1, .end_time
		endif
		if .current_label$ = "U" and .interval_time < 0.075 and .i < .n_intervals
			selectObject: intensity
			.min_time = Get time of minimum: .start_time, .end_time, "Parabolic"
			selectObject: tg
			Set interval text: 1, .i, ""
			Remove boundary at time: 1, .start_time
			Remove boundary at time: 1, .end_time
			Insert boundary: 1, .min_time
		endif
		.i -= 1
	endwhile
endproc

procedure getPitchValues
	selectObject: tg
	.n_intervals = Get number of intervals: 1
	for .i to .n_intervals
		.start_time[.i] = Get start time of interval: 1, .i
		.end_time[.i] = Get end time of interval: 1, .i
	endfor

	selectObject: smoothedpitch
	for .i to .n_intervals
		.interval_time[.i] = .end_time[.i] - .start_time[.i]
		.interval_semitone[.i] = Get quantile: .start_time[.i], .end_time[.i], 0.5, "semitones re 440 Hz"
		if .interval_time[.i] > 0.17
			.interval_semitone_first[.i] = Get quantile: .start_time[.i], .start_time[.i] + 0.17, 0.5, "semitones re 440 Hz"
			.interval_semitone_last[.i] = Get quantile: .end_time[.i] - 0.17, .end_time[.i], 0.5, "semitones re 440 Hz"
		else
			.interval_semitone_first[.i] = Get quantile: .start_time[.i], .end_time[.i], 0.5, "semitones re 440 Hz"
			.interval_semitone_last[.i] = Get quantile: .start_time[.i], .end_time[.i], 0.5, "semitones re 440 Hz"
		endif
	endfor
endproc

procedure optimizeSemitones
	selectObject: tg
	.i = Get number of intervals: 1
	while .i > 1
		.current_label$ = Get label of interval: 1, .i
		.prev_label$ = Get label of interval: 1, .i - 1
		if .current_label$ <> "U"
			if getPitchValues.interval_semitone[.i - 1] <> undefined and .prev_label$ <> "U"
				.diff_semitones = number(fixed$(abs(getPitchValues.interval_semitone_first[.i] - getPitchValues.interval_semitone_last[.i - 1]), 1))
			else
				.diff_semitones = 0.7
			endif
			if .diff_semitones < 0.7
				.start_time = Get start time of interval: 1, .i
				Remove boundary at time: 1, .start_time
				Set interval text: 1, .i - 1, .prev_label$
			endif
		endif
		.i -= 1
	endwhile
endproc

procedure joinUnvoiced
	selectObject: tg
	.i = Get number of intervals: 1
	.i -= 1
	while .i > 1
		.current_label$ = Get label of interval: 1, .i
		.prev_label$ = Get label of interval: 1, .i - 1
		.next_label$ = Get label of interval: 1, .i + 1
		.start_time = Get start time of interval: 1, .i
		.end_time = Get end time of interval: 1, .i
		.interval_time = number(fixed$(.end_time - .start_time, 2))
		if .current_label$ = "U" and .interval_time <= 0.3
			.mid_point = (.start_time + .end_time) / 2
			Set interval text: 1, .i, ""
			Remove boundary at time: 1, .start_time
			Remove boundary at time: 1, .end_time
			Insert boundary: 1, .mid_point
			Set interval text: 1, .i - 1, .prev_label$
			Set interval text: 1, .i, .next_label$
		endif
		.i -= 1
	endwhile
endproc

procedure splitEqualNotes
	selectObject: tg
	.i = Get number of intervals: 1
	.i -= 1
	while .i > 1
		.current_label$ = Get label of interval: 1, .i
		.start_time = Get start time of interval: 1, .i
		.end_time = Get end time of interval: 1, .i
		.interval_time = .end_time - .start_time
		.interval_margin = number(fixed$(.interval_time / 3, 3))
		if .current_label$ <> "U" and .interval_time > 0.6
			selectObject: intensity
			.min_time = Get time of minimum: .start_time + .interval_margin, .end_time - .interval_margin, "Parabolic"
			.intensity_sd = Get standard deviation: .start_time + .interval_margin, .end_time - .interval_margin
			selectObject: tg
			if .intensity_sd > 3
				Insert boundary: 1, .min_time
			endif
		endif
		.i -= 1
	endwhile
endproc

procedure setPitchValues
	selectObject: tg
	.n_intervals = Get number of intervals: 1
	for .i to .n_intervals
		.start_time[.i] = Get start time of interval: 1, .i
		.end_time[.i] = Get end time of interval: 1, .i
	endfor

	selectObject: smoothedpitch
	for .i to .n_intervals
		.interval_semitone[.i] = Get quantile: .start_time[.i], .end_time[.i], 0.5, "Hertz"
	endfor

	selectObject: tg
	for .i to .n_intervals
		Set interval text: 1, .i, fixed$(.interval_semitone[.i], 2)
	endfor
endproc
