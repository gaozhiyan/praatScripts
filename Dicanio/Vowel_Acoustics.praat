# Extracts mean formant values, the first four spectral moments, and F0 dynamically across a duration defined by the textgrid. 
# Also extracts vowel duration.
# The number of interval values extracted is equal to numintervals below.
# Writes results to a textfile.
# Copyright Christian DiCanio, Haskins Laboratories, 2012.

numintervals = 3
#Number of intervals you wish to extract from.

form Extract Formant data from labelled points
   sentence Directory_name: /Forced_Alignment/FA_Penn/CTB501Lista001/
   sentence Log_file Vowel_CTB_v1
   sentence Interval_label v1
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   comment F0 Settings:
   positive F0_minimum 80
   positive F0_maximum 300
   comment Formant Settings:
   positive Analysis_time_step 0.005
   positive Maximum_formant 5500
   positive Number_formants 5
   positive Number_tracks 3
   positive F1_ref 620
   positive F2_ref 1862
   positive F3_ref 3100
   positive F4_ref 4344
   positive F5_ref 5585
   positive Window_length 0.005
endform

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

fileappend 'directory_name$''log_file$'.txt label'tab$'dur'tab$'

for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'val_F0'tab$'
endfor
for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'cgrav'tab$''i'sdev'tab$''i'skew'tab$''i'kurt'tab$''i'F1'tab$''i'F2'tab$''i'F3'tab$'
endfor
fileappend 'directory_name$''log_file$'.txt 'newline$'


for i to num_labels
	select 'textGridID'
	label$ = Get label of interval... labeled_tier_number i
		if label$ = interval_label$
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'
      			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			select 'soundID2'
			Extract part... intvl_start intvl_end Rectangular 1 no
			intID = selected("Sound")
			dur = Get total duration
			fileappend 'directory_name$''log_file$'.txt 'dur''tab$'
			chunkID  = (intvl_end-intvl_start)/numintervals

			#Pitch analysis
			select 'intID'	
			To Pitch... 0 f0_minimum f0_maximum
			pitchID = selected("Pitch")
			size = dur/numintervals
			for q to numintervals
					start = (q-1) * size
					end = q * size
					val_F0  = Get mean... start end Hertz
					if val_F0 = undefined
					fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
					fileappend 'directory_name$''log_file$'.txt 'val_F0''tab$'
					endif	
			endfor
			select 'pitchID'
			Remove

			#Getting formants and frequency boundaries 10% away from them. Writing to data file.
			for j to numintervals
				select 'intID'
				Extract part... (j-1)*chunkID j*chunkID Rectangular 1 no
				chunk_part = selected("Sound")
				spect_part = To Spectrum... yes
				grav = Get centre of gravity... 2
				sdev = Get standard deviation... 2
				skew = Get skewness... 2
				kurt = Get kurtosis... 2

				select 'chunk_part'
				form_chunk = To Formant (burg)... 0 'number_formants' 'maxf' 'window_length' 50
				formantID_bf = selected("Formant")
				Track... 'number_tracks' 'f1_ref' 'f2_ref' 'f3_ref' 'f4_ref' 'f5_ref' 1 1 1
				formantID = selected("Formant")
				f1 = Get mean... 1 0 0 Hertz
				f1_a = f1-(f1/10)
				f1_b = f1+(f1/10)
				f2 = Get mean... 2 0 0 Hertz
				f2_a = f2-(f2/10)
				f2_b = f2+(f2/10)
				f3 = Get mean... 3 0 0 Hertz
				f3_a = f3-(f3/10)
				f3_b = f3+(f3/10)
					if j = numintervals
					fileappend 'directory_name$''log_file$'.txt
 	           			... 'grav''tab$''sdev''tab$''skew''tab$''kurt''tab$''f1''tab$''f2''tab$''f3''newline$'
					else
					fileappend 'directory_name$''log_file$'.txt
   	         			... 'grav''tab$''sdev''tab$''skew''tab$''kurt''tab$''f1''tab$''f2''tab$''f3''tab$'
					endif
				select 'formantID_bf'
				Remove
				select 'formantID'
				Remove
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
