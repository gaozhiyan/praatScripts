form Declick
	real Threshold_(%) 90
	real Sensitivity_(%) 80
	boolean Mark_detected_clicks_in_a_TextGrid 0
	choice Repair_method 1
		button Replace
		button Attenuate
	real Attenuation_(%) 90
endform

threshold = number(fixed$(min(max(threshold, 1), 100) / 100, 3))
prev_th = number(fixed$(2.0196 - 0.019596 * min(max(sensitivity, 1), 100), 2))
next_th = number(fixed$(min(max(prev_th - 0.2, 0.01), 0.25), 2))
attenuation = number(fixed$(min(max(attenuation, 1), 100) / 100, 3))

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	dur = Get total duration
	ch = Get number of channels
	int = Get intensity (dB)

	wrk1 = Copy: "wrk1"
	runScript: "fixdc.praat"

	if mark_detected_clicks_in_a_TextGrid
		tg = Create TextGrid: 0, dur, "clicks", "clicks"
		Rename: s$ + "-detected_clicks"
		selectObject: wrk1
	endif

	if int <> undefined
include minmaxf0.praat

		# pass 1
		@clickDetection: wrk1

		if clickDetection.n_clicks > 0
			if repair_method = 1
				@clickReplacement: wrk1
			elsif repair_method = 2
				@clickAttenuation: wrk1
			endif
			tmp1 = selected("Sound")

			if mark_detected_clicks_in_a_TextGrid
				selectObject: tg
				for i to clickDetection.n_clicks
					nocheck Insert point: 1, clickDetection.click_time[i], ""
				endfor
				selectObject: tmp1
			else
				removeObject: wrk1
			endif

			# pass 2
			wrk2 = Copy: "wrk2"
			@clickDetection: wrk2

			if clickDetection.n_clicks > 0
				if repair_method = 1
					@clickReplacement: wrk2
				elsif repair_method = 2
					@clickAttenuation: wrk2
				endif
				tmp2 = selected("Sound")

				if mark_detected_clicks_in_a_TextGrid
					selectObject: tg
					for i to clickDetection.n_clicks
						nocheck Insert point: 1, clickDetection.click_time[i], ""
					endfor
					selectObject: tmp2
				endif
				removeObject: tmp1, wrk2
			else
				selectObject: tmp1
				removeObject: wrk2
			endif

			result_tmp = selected("Sound")
		else
			selectObject: wrk1
		endif
	endif

	if mark_detected_clicks_in_a_TextGrid
		selectObject: tg
		npoints = Get number of points: 1
		for i to npoints
			Set point text: 1, i, string$(i)
		endfor

		selectObject: wrk1
		Rename: s$ + "-detected_clicks"
		plusObject: tg
		View & Edit

		if npoints > 0
			selectObject: result_tmp
			Rename: s$ + "-declicked"
		else
			selectObject: wrk1
			Copy: s$ + "-declicked"
		endif
	else
		Rename: s$ + "-declicked"
	endif
endproc

procedure clickDetection: .wrk
	selectObject: .wrk
	.int_or = Get intensity (dB)
	if ch > 1
		.ch1 = Extract one channel: 1
	endif

	.last_sel = selected("Sound")
	.trimmed = nowarn nocheck Trim silences: 0.08, "no", 100, 0, -35, 0.1, 0.05, "no", "trimmed"
	if .trimmed = .last_sel
		Copy: "tmp"
	endif
	.int_trim = Get intensity (dB)
	.int_dif = .int_trim - .int_or
	if ch > 1
		plusObject: .ch1
	endif
	Remove

	selectObject: .wrk
	.wrk_scaled = Copy: "wrk_scaled"
	Scale intensity: 70 - .int_dif

	.pitch = noprogress To Pitch (ac): 0, minF0, 15, "no", 0, 0, 0.01, 0.35, 0, maxF0
	plusObject: .wrk_scaled
	.pointprocess = noprogress To PointProcess (peaks): "yes", "yes"

	Remove points between: dur - 0.005, dur
	.meanp = Get mean period: 0, 0, 0.0001, 0.02, 1.3
	if .meanp = undefined
		.meanp = 0.005
	endif
	.meanp = max(.meanp, 0.003)
	Voice: .meanp, .meanp * 2

	.np = Get number of points
	while .np > 1
		.pt1 = Get time from index: .np
		.pt2 = Get time from index: .np - 1
		if .pt1 = .pt2
			Remove point: .np
		endif
		.np -= 1
	endwhile

	.np = Get number of points
	for .i to .np
		.pt[.i] = Get time from index: .i
	endfor
	removeObject: .pitch, .pointprocess

	.pt[.np + 1] = dur
	.tim[0] = 0
	.amp[0] = 0
	.n_points = 0

	selectObject: .wrk_scaled
	for .i to .np
		.mx = Get maximum: .pt[.i] - 0.001, .pt[.i + 1] - 0.001, "None"
		.mn = Get minimum: .pt[.i] - 0.001, .pt[.i + 1] - 0.001, "None"
		if .mx = undefined
			.mx = 0
		endif
		if .mn = undefined
			.mn = 0
		endif

		if abs(.mx) >= abs(.mn)
			.x_time = Get time of maximum: .pt[.i] - 0.001, .pt[.i + 1] - 0.001, "None"
		else
			.x_time = Get time of minimum: .pt[.i] - 0.001, .pt[.i + 1] - 0.001, "None"
		endif

		if .x_time - .tim[.n_points] > 0.001
			.n_points += 1
			.tim[.n_points] = .x_time
			.amp[.n_points] = abs(.mx - .mn)
			if repair_method = 1
				.ptime[.n_points] = .pt[.i]
			endif
		else
			if abs(.mx - .mn) > .amp[.n_points]
				.tim[.n_points] = .x_time
				.amp[.n_points] = abs(.mx - .mn)
				if repair_method = 1
					.ptime[.n_points] = .pt[.i]
				endif
			endif
		endif
	endfor
	Remove

	.amp[0] = 0
	.amp[.n_points + 1] = 0
	for .i to .n_points
		.prev_r[.i] = abs(.amp[.i] - .amp[.i - 1]) / ((.amp[.i] + .amp[.i - 1]) / 2)
		if .prev_r[.i] = undefined
			.prev_r[.i] = 0
		endif
		.next_r[.i] = abs(.amp[.i] - .amp[.i + 1]) / ((.amp[.i] + .amp[.i + 1]) / 2)
		if .next_r[.i] = undefined
			.next_r[.i] = 0
		endif
	endfor

	Create Table with column names: "tmp", 0, "Amp"
	.nrow = 0
	for .i to .n_points
		if .amp[.i] > 0.02
			Append row
			.nrow += 1
			Set numeric value: .nrow, "Amp", .amp[.i]
		endif
	endfor
	.th = Get quantile: "Amp", threshold
	Remove

	.prev_r[0] = 0
	.n_clicks = 0
	if repair_method = 1
		.ptime[.n_points + 1] = dur
		.ptime[.n_points + 2] = dur
		.ptime[.n_points + 3] = dur
	endif

	for .i to .n_points
		if .amp[.i] > number(fixed$(.th, 2))
			if .amp[.i] > .amp[.i - 1] and .amp[.i] > .amp[.i + 1]
				if (.prev_r[.i] > prev_th or .prev_r[.i - 1] > 1) and .next_r[.i] > next_th
					if .tim[.i] > 0.025 and .tim[.i] < dur - 0.025
						.n_clicks += 1
						.click_time[.n_clicks] = .tim[.i]
						if repair_method = 1
							.click_next_amp[.n_clicks] = .amp[.i + 1]
							.click_next_r[.n_clicks] = .next_r[.i]
							.offset1[.n_clicks] = .ptime[.i + 2] - .ptime[.i + 1]
							.offset2[.n_clicks] = .ptime[.i + 3] - .ptime[.i + 1]
						endif
					endif
				endif
			endif
		endif
	endfor
endproc

procedure clickReplacement: .wrk
	selectObject: .wrk
	.result_tmp = Copy: "result_tmp"

	for .i to clickDetection.n_clicks
		Fade out: 0, clickDetection.click_time[.i] - 0.005, 0.005, "no"
		Fade in: 0, clickDetection.click_time[.i] + 0.005, -0.005, "no"
	endfor

	rep# = zero# (clickDetection.n_clicks)
	for .i to clickDetection.n_clicks
		selectObject: .result_tmp
		if clickDetection.click_next_amp[.i] > number(fixed$(clickDetection.th, 2)) and clickDetection.click_next_r[.i] <= 0.6
			rep# [.i] = Extract part: clickDetection.offset2[.i], dur + clickDetection.offset2[.i], "rectangular", 1, "no"
		else
			rep# [.i] = Extract part: clickDetection.offset1[.i], dur + clickDetection.offset1[.i], "rectangular", 1, "no"
		endif
		Fade in: 0, clickDetection.click_time[.i] - 0.005, 0.005, "yes"
		Fade out: 0, clickDetection.click_time[.i] + 0.005, -0.005, "yes"
	endfor

	selectObject: .result_tmp
	for .i to clickDetection.n_clicks
		Formula: "self + object[rep# [.i]]"
	endfor

	selectObject: .result_tmp
	removeObject: rep#
endproc

procedure clickAttenuation: .wrk
	selectObject: .wrk
	Copy: "result_tmp"

	Set part to zero: 0, clickDetection.click_time[1] - 0.005, "at exactly these times"
	for .i to clickDetection.n_clicks
		Fade in: 0, clickDetection.click_time[.i] - 0.005, 0.005, "no"
		Fade out: 0, clickDetection.click_time[.i] + 0.005, -0.005, "no"
		if .i < clickDetection.n_clicks
			.t1 = clickDetection.click_time[.i] + 0.005
			.t2 = clickDetection.click_time[.i + 1] - 0.005
			if .t1 < .t2
				Set part to zero: .t1, .t2, "at exactly these times"
			endif
		else
			Set part to zero: clickDetection.click_time[.i] + 0.005, dur, "at exactly these times"
		endif
	endfor

	Formula: "(-self * attenuation) + object[.wrk]"
endproc
