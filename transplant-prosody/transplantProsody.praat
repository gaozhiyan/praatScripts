form Provide sentence label, path to TextGrids, and path to output folder
	comment Sentence label
	text sentence_label CV1
	comment Path to files
	text textgrids_path /Users/tim/Dropbox/Perception_Study/Pilot/original
	comment Path to output folder
	text output_path /Users/tim/Documents/sound_files/auto_output
endform

# Syllable detection

textgrids = Create Strings as file list: "list", textgrids_path$ + "/" + sentence_label$ + "-*.TextGrid"
number_of_files = Get number of strings
for i to number_of_files
	selectObject: textgrids
	file_name$ = Get string: i
	Read from file: textgrids_path$ + "/" + file_name$
	object_name$ = selected$("TextGrid")
	speaker_id$ = right$ (object_name$, length (object_name$) - (length (sentence_label$) + 1))

	if i == 1
		num_words = Get number of intervals: 1
		col_names$ = "speaker"
		for j to num_words
			word_label$ = Get label of interval: 1, j
			if length (word_label$) > 0
				col_names$ = col_names$ + " " + word_label$
			endif
		endfor
		Create Table with column names: sentence_label$, number_of_files, col_names$
	endif

	selectObject: "Table " + sentence_label$
	Set string value: i, "speaker", speaker_id$
	selectObject: "TextGrid " + object_name$
	col_num = 1
	num_words = Get number of intervals: 1
	for k to num_words
		selectObject: "TextGrid " + object_name$
		word_label$ = Get label of interval: 1, k
		if length (word_label$) > 0
			col_num = col_num + 1
			word_start = Get starting point: 1, k
			word_end = Get end point: 1, k
			first_syl = Get high interval at time: 4, word_start
			last_syl = Get high interval at time: 4, word_end
			num_syl = last_syl - first_syl
			selectObject: "Table " + sentence_label$
			col_lab$ = Get column label: col_num
			Set numeric value: i, col_lab$, num_syl
		endif
	endfor
endfor

# Syllable comparison and selection

selectObject: "Table " + sentence_label$
num_cols = Get number of columns
Extract rows where column (text): "speaker", "starts with", "L1"
Create Table with column names: sentence_label$ + "_var_words", 0, "word syl"

for l from 2 to num_cols
	selectObject: "Table " + sentence_label$
	col_lab$ = Get column label: l
	min_syl = Get minimum: col_lab$
	max_syl = Get maximum: col_lab$
	if min_syl <> max_syl
		selectObject: "Table " + sentence_label$
		# Taking the median is a really ugly solution because it assumes only 2 different values. Also, it doesn't actually compare different combinations of values.
		median_syl = Get quantile: col_lab$, 0.5
		selectObject: "Table " + sentence_label$ + "_var_words"
		Append row
		num_new_rows = Get number of rows
		Set string value: num_new_rows, "word", col_lab$
		Set numeric value: num_new_rows, "syl", median_syl
	endif
endfor

selectObject: "Table " + sentence_label$ + "_var_words"
num_rows = Get number of rows
if num_rows == 0
	selectObject: "Table " + sentence_label$
	Rename: sentence_label$ + "_sylchecked"
else
	for m to num_rows
		word$ = Get value: m, "word"
		maj_syl_n = Get value: m, "syl"
		if m == 1
			formula_string$ = "self$[""" + word$ + """]=""" + string$ (maj_syl_n) + """"
		else
			formula_string$ = formula_string$ + "and self$[""" + word$ + """]=""" + string$ (maj_syl_n) + """"
		endif
	endfor
	selectObject: "Table " + sentence_label$
	Extract rows where: formula_string$
	Rename: sentence_label$ + "_sylchecked"
endif

# Pause detection

selectObject: "Table " + sentence_label$ + "_sylchecked"
n_words = num_cols - 1
max_intervals = n_words * 2 + 1
n_speakers = Get number of rows
col_nms$ = "speaker 1"
pause_num = 1
for cl from 2 to num_cols
	cl_lb$ = Get column label: cl
	pause_num = pause_num + 2
	col_nms$ = col_nms$ + " " + cl_lb$ + " " + string$ (pause_num)
endfor
Create Table with column names: sentence_label$ + "_pauses", n_speakers, col_nms$
for spkr to n_speakers
	selectObject: "Table " + sentence_label$ + "_sylchecked"
	spkr_lab$ = Get value: spkr, "speaker"
	selectObject: "Table " + sentence_label$ + "_pauses"
	Set string value: spkr, "speaker", spkr_lab$
	selectObject: "TextGrid " + sentence_label$ + "-" + spkr_lab$
	n_word_ints = Get number of intervals: 1
	index_counter = 0
	for word_int to n_word_ints
		index_counter = index_counter + 1
		selectObject: "TextGrid " + sentence_label$ + "-" + spkr_lab$
		wrd_lab$ = Get label of interval: 1, word_int
		if index_counter mod 2 <> 0 and length (wrd_lab$) <> 0
			selectObject: "Table " + sentence_label$ + "_pauses"
			Set numeric value: spkr, string$ (index_counter), 0
			index_counter = index_counter + 1
		elsif index_counter mod 2 <> 0 and length (wrd_lab$) == 0
			selectObject: "Table " + sentence_label$ + "_pauses"
			Set numeric value: spkr, string$ (index_counter), 1
		endif
		if index_counter <> max_intervals and word_int == n_word_ints
			index_counter = index_counter + 1
			selectObject: "Table " + sentence_label$ + "_pauses"
			Set numeric value: spkr, string$ (index_counter), 0
		endif
	endfor
endfor

# Combine Pause and Syllable tables

for s to n_speakers
	for w from 2 to num_cols
		selectObject: "Table " + sentence_label$ + "_sylchecked"
		w_lab$ = Get column label: w
		n_syls = Get value: s, w_lab$
		selectObject: "Table " + sentence_label$ + "_pauses"
		Set numeric value: s, w_lab$, n_syls
	endfor
endfor

# Get table of problematic pauses

selectObject: "Table " + sentence_label$ + "_pauses"
Create Table with column names: sentence_label$ + "_var_pauses", 0, "pause_index"

for pz to max_intervals
	if pz mod 2 <> 0
		selectObject: "Table " + sentence_label$ + "_pauses"
		pz_lb$ = string$ (pz)
		min_int = Get minimum: pz_lb$
		max_int = Get maximum: pz_lb$
		if min_int <> max_int
			selectObject: "Table " + sentence_label$ + "_var_pauses"
			Append row
			n_new_rows = Get number of rows
			Set string value: n_new_rows, "pause_index", pz_lb$
		endif
	endif
endfor

# Create dummy pauses where necessary
selectObject: "Table " + sentence_label$ + "_var_pauses"
n_prob_pz = Get number of rows
for sp to n_speakers
	for pr to n_prob_pz
		selectObject: "Table " + sentence_label$ + "_var_pauses"
		pr_lab$ = Get value: pr, "pause_index"
		selectObject: "Table " + sentence_label$ + "_pauses"
		sp_lab$ = Get value: sp, "speaker"
		pr_n_syl = Get value: sp, pr_lab$
		if pr_n_syl == 0
			pr_index = Get column index: pr_lab$
			cumul_wrd = 0
			for prev from 2 to pr_index - 1
				if prev mod 2 == 0
					prev_lab$ = Get column label: prev
					wrd_count = Get value: sp, prev_lab$
					cumul_wrd = cumul_wrd + wrd_count
				elsif prev mod 2 <> 0
					cumul_wrd = cumul_wrd + 1
				endif
			endfor
			selectObject: "TextGrid " + sentence_label$ + "-" + sp_lab$
			target_time = Get end point: 1, cumul_wrd
			boundary_shift = 0.01
			Insert boundary: 4, target_time - boundary_shift
			next_int_ind = Get high interval at time: 4, target_time - boundary_shift
			next_int_end = Get end point: 4, next_int_ind
			next_int_dur = next_int_end - (target_time - boundary_shift)
			if next_int_dur > (boundary_shift * 1.1)
				Insert boundary: 4, target_time
				fckd_lab$ = Get label of interval: 4, next_int_ind - 1
				Set interval text: 4, next_int_ind + 1, fckd_lab$
				Set interval text: 4, next_int_ind - 1, ""
				Remove left boundary: 4, next_int_ind - 1
			endif
		endif
	endfor
endfor

# Mode Selection

speaker_mode$ = "Manual"

beginPause: "Mode Selection"
	comment: "Select transplantation parameters manually or automatically?"
#	optionMenu: "Speaker mode", 1
#		option: "Manual"
#		option: "Auto"
	optionMenu: "Prosody mode", 2
		option: "Manual"
		option: "Auto"
	comment: "Note: In auto prosody mode, all possible combinations will be generated."
endPause: "Continue", 1

# Speaker Selection

if speaker_mode$ == "Manual"
	selectObject: "Table " + sentence_label$ + "_pauses"
	View & Edit
	beginPause: "Speaker selection"
		comment: "Provide receiver and donor IDs (see 'Speaker' column in table)."
		comment: "Receiver ID:"
		text: "Receiver id", "L1_3"
		comment: "Donor ID:"
		text: "Donor id", "L2_C1_1"
	endPause: "Continue", 1
elsif speaker_mode$ == "Auto"
	beginPause: "Speaker selection: Auto mode"
		comment: "Choose mother tongue of receiver"
		optionMenu: "Receiver id", 1
			option: "L1"
			option: "L2"
	endPause: "Continue", 1
	if receiver_id$ == "L1"
		donor_id$ = "L2"
	else
		donor_id$ = "L1"
	endif
endif

# Prosody Selection
intonation = 0

if prosody_mode$ == "Manual"
	beginPause: "Prosody selection: Manual mode"
		comment: "Choose which prosodic cues you would like to transplant"
		optionMenu: "Speech rate", 2
			option: "Yes"
			option: "No"
		optionMenu: "Duration", 2
			option: "Yes"
			option: "No"
		optionMenu: "Intonation", 2
			option: "Yes"
			option: "No"
	endPause: "Continue", 1
	num_loops = 1
elif prosody_mode$ == "Auto"
	num_loops = 7
endif

# Intonation parameters
rec_frame_length = 0.01
rec_minimum_pitch = 75
rec_maximum_pitch = 600
don_frame_length = 0.01
don_minimum_pitch = 75
don_maximum_pitch = 600
if speaker_mode$ == "Manual"
	beginPause: "Intonation parameters"
		comment: "Pitch analysis of receiver"
		positive: "Rec frame length", 0.01
		positive: "Rec minimum pitch", 75
		positive: "Rec maximum pitch", 600
		comment: "Pitch analysis of donor"
		positive: "Don frame length", 0.01
		positive: "Don minimum pitch", 75
		positive: "Don maximum pitch", 600
	endPause: "Continue", 1
endif

# Transplant Prosody

selectObject: "Table " + sentence_label$ + "_pauses"
Extract rows where column (text): "speaker", "starts with", receiver_id$
n_rec_spkr = Get number of rows
selectObject: "Table " + sentence_label$ + "_pauses"
Extract rows where column (text): "speaker", "starts with", donor_id$
n_don_spkr = Get number of rows

for rec_spkr to n_rec_spkr
	selectObject: "Table " + sentence_label$ + "_pauses" + "_" + receiver_id$
	receiver_lab$ = Get value: rec_spkr, "speaker"
	receiver_name$ = sentence_label$ + "-" + receiver_lab$
	selectObject: "TextGrid " + receiver_name$
	num_receiver_syl = Get number of intervals: 4
	for don_spkr to n_don_spkr

		# Transplantation loops 2 to 7 are activated if auto manipulation of prosody is selected
		for lp from 1 to num_loops
			if lp == 1 and prosody_mode$ = "Auto"
				intonation = 1
				duration = 2
				speech_rate = 2
			elif lp == 2
				intonation = 1
				duration = 1
				speech_rate = 2
			elif lp == 3
				intonation = 1
				duration = 2
				speech_rate = 1
			elif lp == 4
				intonation = 1
				duration = 1
				speech_rate = 1
			elif lp == 5
				intonation = 2
				duration = 1
				speech_rate = 2
			elif lp == 6
				intonation = 2
				duration = 1
				speech_rate = 1
			elif lp == 7
				intonation = 2
				duration = 2
				speech_rate = 1
			endif

			Read from file: textgrids_path$ + "/" + receiver_name$ + ".wav"
			selectObject: "Table " + sentence_label$ + "_pauses" + "_" + donor_id$
			donor_lab$ = Get value: don_spkr, "speaker"
			donor_name$ = sentence_label$ + "-" + donor_lab$
			Read from file: textgrids_path$ + "/" + donor_name$ + ".wav"
			selectObject: "TextGrid " + donor_name$
			num_donor_syl = Get number of intervals: 4
			if num_receiver_syl <> num_donor_syl
				appendInfoLine: "Unequal syllable count in " + receiver_name$ + " and " + donor_name$
			endif

			# Extract prosodic tiers
			selectObject: "Sound " + receiver_name$
			To Manipulation: rec_frame_length, rec_minimum_pitch, rec_maximum_pitch
			Extract duration tier
			selectObject: "Manipulation " + receiver_name$
			Extract pitch tier
			selectObject: "Sound " + donor_name$
			To Manipulation: don_frame_length, don_minimum_pitch, don_maximum_pitch
			Extract pitch tier

			# Get info for speech rate manipulation and duration
			selectObject: "TextGrid " + receiver_name$
			receiver_onset = Get end point: 4, 1
			receiver_offset = Get starting point: 4, num_receiver_syl
			receiver_dur = receiver_offset - receiver_onset
			selectObject: "TextGrid " + donor_name$
			donor_onset = Get end point: 4, 1
			donor_offset = Get starting point: 4, num_donor_syl
			donor_dur = donor_offset - donor_onset
			global_coeff = donor_dur / receiver_dur

			# Set boundary offset for duration tier
			boundary_offset = 0.001

			# Get mean intonation of receiver and donor
			selectObject: "PitchTier " + receiver_name$
			mean_rec_hz = Get mean (points): receiver_onset, receiver_offset
			mean_rec_erb = 16.7 * log10(1 + mean_rec_hz / 165.4)
			selectObject: "PitchTier " + donor_name$
			mean_don_hz = Get mean (points): donor_onset, donor_offset
			mean_don_erb = 16.7 * log10(1 + mean_don_hz / 165.4)

			# Transplantation

			for i from 2 to (num_receiver_syl - 1)
				selectObject: "TextGrid " + receiver_name$
				rec_syl_start = Get starting point: 4, i
				rec_syl_end = Get end point: 4, i
				rec_syl_dur = rec_syl_end - rec_syl_start
				selectObject: "TextGrid " + donor_name$
				don_syl_start = Get starting point: 4, i
				don_syl_end = Get end point: 4, i
				don_syl_dur = don_syl_end - don_syl_start

				# Transplantation of intonation contour
				if intonation == 1
					dur_coeff = rec_syl_dur / don_syl_dur
					selectObject: "PitchTier " + receiver_name$
					Remove points between: rec_syl_start, rec_syl_end
					selectObject: "PitchTier " + donor_name$
					first_index = Get high index from time: don_syl_start
					last_index = Get low index from time: don_syl_end
					if last_index >= first_index
						for j from first_index to last_index
							selectObject: "PitchTier " + donor_name$
							don_index_freq = Get value at index: j

							# ERB algorithm that compensates for mean pitch difference between donor and receiver
							don_index_erb = 16.7 * log10(1 + don_index_freq / 165.4)
							erb_diff = don_index_erb - mean_don_erb
							rec_index_erb = mean_rec_erb + erb_diff
							rec_index_freq = 165.4 * (10^(0.06*rec_index_erb) - 1)

							don_index_time = Get time from index: j
							don_onset_time = don_index_time - don_syl_start
							rec_onset_time = don_onset_time * dur_coeff
							rec_index_time = rec_syl_start + rec_onset_time
							selectObject: "PitchTier " + receiver_name$
							Add point: rec_index_time, rec_index_freq
						endfor
					endif
				endif

				# Transplantation of relative syllable duration and/or speech rate
				if duration == 1 or speech_rate == 1
					rel_dur_coeff = (don_syl_dur / donor_dur) * (receiver_dur / rec_syl_dur)
					if duration == 1 and speech_rate == 1
						fin_dur_coeff = rel_dur_coeff * global_coeff
					elsif duration == 1 and speech_rate == 2
						fin_dur_coeff = rel_dur_coeff
					elsif duration == 2 and speech_rate == 1
						fin_dur_coeff = global_coeff
					endif
					selectObject: "DurationTier " + receiver_name$
					if i == 2
						first_dur_point = receiver_onset - boundary_offset
						start_coeff = fin_dur_coeff
						Add point: first_dur_point, fin_dur_coeff
					endif
					if i == (num_receiver_syl - 1)
						last_dur_point = receiver_offset + boundary_offset
						Add point: last_dur_point, fin_dur_coeff
					endif
					start_dur_point = rec_syl_start + boundary_offset
					end_dur_point = rec_syl_end - boundary_offset
					Add point: start_dur_point, fin_dur_coeff
					Add point: end_dur_point, fin_dur_coeff
				endif
			endfor

			selectObject: "Manipulation " + receiver_name$
			plusObject: "PitchTier " + receiver_name$
			Replace pitch tier
			selectObject: "Manipulation " + receiver_name$
			plusObject: "DurationTier " + receiver_name$
			Replace duration tier
			selectObject: "Manipulation " + receiver_name$
			if speech_rate + duration + intonation == 6
				new_name_ending$ = "_resyn"
			else
				new_name_ending$ = "_" + right$ (donor_name$, 4)
			endif
			if intonation == 1
				new_name_ending$ = new_name_ending$ + "-int"
			endif
			if duration == 1
				new_name_ending$ = new_name_ending$ + "-dur"
			endif
			if speech_rate == 1
				new_name_ending$ = new_name_ending$ + "-rate"
			endif
			Get resynthesis (overlap-add)
			if duration == 1 and speech_rate == 2
				start_sound = receiver_onset * start_coeff
				end_sound = start_sound + receiver_dur
			elsif speech_rate == 1
				start_sound = receiver_onset * start_coeff
				end_sound = start_sound + (receiver_dur * global_coeff)
			else
				start_sound = receiver_onset
				end_sound = receiver_offset
			endif
			Extract part: start_sound, end_sound, "rectangular", 1, "no"
			new_name$ = receiver_name$ + new_name_ending$
			Rename: new_name$

			# Normalise Sound Pressure Level (dB) and reduce echo
			if duration == 1 and speech_rate == 1
				selectObject: "TextGrid " + donor_name$
				Extract part: donor_onset, donor_offset, "no"
				Rename: new_name$
			elsif duration == 1 and speech_rate == 2
				selectObject: "TextGrid " + donor_name$
				Extract part: donor_onset, donor_offset, "no"
				Scale times by: 1 / global_coeff
				Rename: new_name$
			elsif duration == 2 and speech_rate == 1
				selectObject: "TextGrid " + receiver_name$
				Extract part: receiver_onset, receiver_offset, "no"
				Scale times by: global_coeff
				Rename: new_name$
			elsif duration == 2 and speech_rate == 2
				selectObject: "TextGrid " + receiver_name$
				Extract part: receiver_onset, receiver_offset, "no"
				Rename: new_name$
			endif
			selectObject: "TextGrid " + new_name$
			num_total_syl = Get number of intervals: 4
			selectObject: "Sound " + new_name$
			To Intensity: 75, 0, "yes"
			Down to IntensityTier
			cumul_spl = 0
			num_points = 0
			for k from 1 to num_total_syl
				selectObject: "TextGrid " + new_name$
				syl_label$ = Get label of interval: 4, k
				rec_syl_start = Get starting point: 4, k
				rec_syl_end = Get end point: 4, k
				if length (syl_label$) > 0
					selectObject: "IntensityTier " + new_name$
					first_index = Get high index from time: rec_syl_start
					last_index = Get low index from time: rec_syl_end
					if last_index >= first_index
						for l from first_index to last_index
							current_spl = Get value at index: l
							cumul_spl = cumul_spl + current_spl
							num_points = num_points + 1
						endfor
					endif
				endif
			endfor
			mean_spl = cumul_spl / num_points
			spl_norm = 64 - mean_spl
			selectObject: "Sound " + new_name$
			total_dur = Get end time
			Create IntensityTier: new_name$ + "_norm", 0, total_dur
			for m from 1 to num_total_syl
				selectObject: "TextGrid " + new_name$
				syl_label$ = Get label of interval: 4, m
				rec_syl_start = Get starting point: 4, m
				rec_syl_end = Get end point: 4, m
				rec_syl_dur = rec_syl_end - rec_syl_start
				selectObject: "IntensityTier " + new_name$
				first_index = Get high index from time: rec_syl_start
				last_index = Get low index from time: rec_syl_end
				if last_index >= first_index
					for n from first_index to last_index
						selectObject: "IntensityTier " + new_name$
						if length (syl_label$) > 0 or rec_syl_dur < 0.015
							spl_shift = spl_norm
						elsif length (syl_label$) == 0 and rec_syl_dur > 0.015
							old_spl = Get value at index: n
							spl_shift = 40 - old_spl
						endif
						spl_point_time = Get time from index: n
						selectObject: "IntensityTier " + new_name$ + "_norm"
						Add point: spl_point_time, spl_shift
					endfor
				endif
			endfor
			selectObject: "Sound " + new_name$
			plusObject: "IntensityTier " + new_name$ + "_norm"
			Multiply: "no"
			selectObject: "Sound " + new_name$
			Remove
			selectObject: "Sound " + new_name$ + "_int"
			Rename: new_name$

			Save as WAV file: output_path$ + "/" + new_name$ + ".wav"

			# Clean up Object list

			selectObject: "Sound " + receiver_name$
			Remove
			selectObject: "PitchTier " + donor_name$
			Remove
			selectObject: "Manipulation " + donor_name$
			Remove
			selectObject: "PitchTier " + receiver_name$
			Remove
			selectObject: "DurationTier " + receiver_name$
			Remove
			selectObject: "Manipulation " + receiver_name$
			Rename: new_name$
			selectObject: "Sound " + receiver_name$
			Remove
			selectObject: "IntensityTier " + new_name$ + "_norm"
			Remove
			selectObject: "IntensityTier " + new_name$
			Remove
			selectObject: "Intensity " + new_name$
			Remove
			selectObject: "Sound " + donor_name$
			Remove
		endfor
	endfor
endfor
