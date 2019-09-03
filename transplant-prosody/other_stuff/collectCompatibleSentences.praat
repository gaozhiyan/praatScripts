form Provide sentence label, path to TextGrids, and path to output folder
	comment Sentence label
	text sentence_label CV1
	comment Path to files
	text textgrids_path /Users/tim/Dropbox/Perception_Study/Alle_NL_bestanden/zinnen_NL
	comment Path to output folder
	text output_path /Users/tim/Dropbox/Perception_Study/Pilot
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

beginPause: "Selection parameters"
	optionMenu: "Majority match", 1
		option: "all"
		option: "L1"
endPause: "Continue", 1
if majority_match$ == "all"
    table_name$ = sentence_label$
elsif majority_match$ == "L1"
    table_name$ = sentence_label$ + "_L1"
endif

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
		selectObject: "Table " + table_name$
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

# Make output file

if sentence_label$ == "CV1"
	writeFileLine: output_path$ + "/sentence_compatibility.csv", ",L1_1,L1_2,L1_3,L1_4,L1_5,L2_A1_1,L2_A1_2,L2_A1_3,L2_A1_4,L2_A1_5,L2_A2_1,L2_A2_2,L2_A2_3,L2_A2_4,L2_A2_5,L2_B1_1,L2_B1_2,L2_B1_3,L2_B1_4,L2_B1_5,L2_B2_1,L2_B2_2,L2_B2_3,L2_B2_4,L2_B2_5,L2_C1_1,L2_C1_2,L2_C1_3,L2_C1_4,L2_C1_5,L2_C2_1,L2_C2_2,L2_C2_3,L2_C2_4,L2_C2_5"
endif

appendFile: output_path$ + "/sentence_compatibility.csv", sentence_label$

selectObject: "Table " + sentence_label$
num_speakers = Get number of rows
for spkr to num_speakers
	selectObject: "Table " + sentence_label$
	spkr_lbl$ = Get value: spkr, "speaker"
	selectObject: "Table " + sentence_label$ + "_sylchecked"
	spkr_presence = Search column: "speaker", spkr_lbl$
	if spkr_presence <> 0
		appendFile: output_path$ + "/sentence_compatibility.csv", ",X"
	elsif spkr_presence == 0
		appendFile: output_path$ + "/sentence_compatibility.csv", ","
	endif
endfor

appendFileLine: output_path$ + "/sentence_compatibility.csv", ""
