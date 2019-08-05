form Extract voiced and unvoiced
	boolean Create_TextGrid 0
endform

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	dur = Get total duration

	runScript: "workpre.praat"
	wrk = selected("Sound")
include minmaxf0.praat

	pointprocess = noprogress To PointProcess (periodic, cc): minF0, maxF0

	tg_wrk = noprogress To TextGrid (vuv): 0.02, 0.01
	n_intervals = Get number of intervals: 1
	for i to n_intervals
		int_label$[i] = Get label of interval: 1, i
		start_time[i] = Get start time of interval: 1, i
		end_time[i] = Get end time of interval: 1, i
	endfor

	selectObject: wrk
	unvoiced_wrk = Copy: "unvoiced_wrk"
	for i to n_intervals
		if int_label$[i] = "V"
			if start_time[i] + 0.005 < end_time[i] - 0.005
				Set part to zero: start_time[i] + 0.005, end_time[i] - 0.005, "at exactly these times"
			endif
		elsif int_label$[i] = "U"
			Fade in: 0, start_time[i] - 0.005, 0.01, "no"
			Fade out: 0, end_time[i] + 0.005, -0.01, "no"
		endif
	endfor

	runScript: "workpost.praat"
	Rename: s$ + "-unvoiced"

	selectObject: wrk
	voiced_wrk = Copy: "voiced_wrk"
	for i to n_intervals
		if int_label$[i] = "U"
			if start_time[i] + 0.005 < end_time[i] - 0.005
				Set part to zero: start_time[i] + 0.005, end_time[i] - 0.005, "at exactly these times"
			endif
		elsif int_label$[i] = "V"
			Fade in: 0, start_time[i] - 0.005, 0.01, "no"
			Fade out: 0, end_time[i] + 0.005, -0.01, "no"
		endif
	endfor

	runScript: "workpost.praat"
	Rename: s$ + "-voiced"

	removeObject: wrk, pointprocess, unvoiced_wrk, voiced_wrk

	if create_TextGrid
		selectObject: s
		result = Copy: s$ + "-vuv"
		runScript: "fixdc.praat"

		tg = Create TextGrid: 0, dur, "vuv", ""
		Rename: s$ + "-vuv"
		int_n = 0
		for i to n_intervals - 1
			if end_time[i] - 0.025 > 0 and end_time[i] - 0.025 < dur
				Insert boundary: 1, end_time[i] - 0.025
				int_n += 1
				Set interval text: 1, int_n, int_label$[i]
			endif
		endfor
		int_n += 1
		stt_int = Get start time of interval: 1, int_n

		selectObject: tg_wrk
		int_tim = Get interval at time: 1, stt_int + 0.025
		last_label$ = Get label of interval: 1, int_tim

		selectObject: tg
		Set interval text: 1, int_n, last_label$
		plusObject: result
		View & Edit
	endif

	removeObject: tg_wrk
endproc
