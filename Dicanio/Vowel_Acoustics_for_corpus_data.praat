# Extracts mean formant values, the first four spectral moments dynamically across a duration defined by the textgrid. 
# Also extracts vowel duration.
# The number of interval values extracted is equal to numintervals below.
# This particular script also includes the preceding and following interval labels on the current tier and information from a lexical tier.
# Writes results to a textfile.
# Copyright Christian DiCanio, Haskins Laboratories, 2013.

numintervals = 3
#Number of intervals you wish to extract from.

form Extract Formant data from labelled points
   sentence Directory_name: /Linguistics/Mixteco/Vowel_data/Running_speech_fixed/CTB_Yolox_Cuent_CTB501_Aventuras-del-conejo_2008-11-15-a/
   sentence Log_file ctb_u'un
   sentence Interval_label u'un
   positive Labeled_tier_number 1
   positive Lexical_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   comment Formant Settings:
#   positive Analysis_time_step 0.005
   positive Maximum_formant 5500
   positive Number_formants 5
   positive F1_ref 517
   positive F2_ref 1553
   positive F3_ref 2588
   positive F4_ref 3624
   positive F5_ref 4660
#   positive Window_length 0.005
endform

# male F1 = 517, F2 = 1553, F3 = 2588, F4 = 3624, F5 = 4660
# female F1 = 620, F2 = 1862, F3 = 3103, F4 = 4344, F5 = 5585
maxf = maximum_formant

# If your sound files are in a different format, you can insert that format instead of wav below.
# Resampling done for LPC analysis.

Create Strings as file list... list 'directory_name$'/*.wav
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	soundID1$ = selected$("Sound")
	Resample... 16000 50
	soundID2 = selected("Sound")
	Read from file... 'directory_name$'/'soundID1$'.TextGrid
	textGridID = selected("TextGrid")
	num_labels = Get number of intervals... labeled_tier_number

fileappend 'directory_name$''log_file$'.txt label 'tab$'seg'tab$'seg_bf'tab$'seg_aft'tab$'lex'tab$'intvl_start'tab$'intvl_end'tab$'dur'tab$'

for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'F1'tab$''i'F2'tab$''i'F3'tab$'
endfor
for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'cgrav'tab$''i'sdev'tab$''i'skew'tab$''i'kurt'tab$'
endfor
fileappend 'directory_name$''log_file$'.txt 'newline$'

for i to num_labels
	select 'textGridID'
	label$ = Get label of interval... labeled_tier_number i
		if label$ = interval_label$
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'
      			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)
			segbf$ = do$ ("Get label of interval...", labeled_tier_number, (i-1))
			segaft$ = do$ ("Get label of interval...", labeled_tier_number, (i+1))
			lex_num = do ("Get interval at time...", lexical_tier_number, intvl_start)
			lex$ = do$ ("Get label of interval...", lexical_tier_number, lex_num)

			select 'soundID2'
			Extract part... intvl_start intvl_end Rectangular 1 no
			intID = selected("Sound")
			dur = Get total duration
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''segbf$''tab$''segaft$''tab$''lex$''tab$''intvl_start''tab$''intvl_end''tab$''dur''tab$'
			chunkID  = (intvl_end-intvl_start)/numintervals

			#Getting formants. Writing to data file.
			
			lpc = do ("To LPC (covariance)...", 16, 0.015, 0.005, 50)
			do ("To Formant")
			formantID_bf = selected("Formant")
				numform = do ("Get minimum number of formants")
					if numform = 2
						number_tracks = 2
					else
						number_tracks = 3
					endif
			Track... number_tracks 'f1_ref' 'f2_ref' 'f3_ref' 'f4_ref' 'f5_ref' 1 1 1
			formantID = selected("Formant")
				for k to numintervals
				f1 = Get mean... 1 (k-1)*chunkID k*chunkID Hertz
					if f1 = undefined
						f1 = 0
					endif
				f2 = Get mean... 2 (k-1)*chunkID k*chunkID Hertz
					if f2 = undefined
						f2 = 0
					endif
				f3 = Get mean... 3 (k-1)*chunkID k*chunkID Hertz
					if f3 = undefined
						f3 = 0
					endif

					fileappend 'directory_name$''log_file$'.txt
   	         			... 'f1''tab$''f2''tab$''f3''tab$'
				endfor

			select 'lpc'
			Remove
			select 'formantID_bf'
			Remove
			select 'formantID'
			Remove

			#Getting spectral moments. Writing to data file.
			for j to numintervals
				select 'intID'
				Extract part... (j-1)*chunkID j*chunkID Rectangular 1 no
				chunk_part = selected("Sound")
				spect_part = To Spectrum... yes
				grav = Get centre of gravity... 2
				sdev = Get standard deviation... 2
				skew = Get skewness... 2
				kurt = Get kurtosis... 2

					if j = numintervals
					fileappend 'directory_name$''log_file$'.txt
 	           			... 'grav''tab$''sdev''tab$''skew''tab$''kurt''newline$'
					else
					fileappend 'directory_name$''log_file$'.txt
   	         			... 'grav''tab$''sdev''tab$''skew''tab$''kurt''tab$'
					endif
				select 'chunk_part'
				Remove
				select 'spect_part'
				Remove
			endfor
			select 'intID'
			Remove
		else
			#do nothing
   		endif
	endfor
select 'textGridID'
Remove
select 'soundID2'
Remove
endfor
select all
Remove
