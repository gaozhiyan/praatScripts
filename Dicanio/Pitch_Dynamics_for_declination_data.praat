# Pitch Dynamics script.
# This script provides duration and F0 values for all files in a directory with an interval label. In addition to providing these, the
# F0 maxima and minima and their locations are also calculated. The location of the F0 maxima and minima are normalized. The
# value reflects the relative location (as a percentage) of these values across the interval, starting from the beginning. For instance,
# a value of .3 for an F0 maximum means that the F0 maximum occurred 30% into the interval duration. All results are written to a 
# textfile.

# The pitch window threshold is the buffer size for tracking F0. For example, with a value of 0.03 means for a 100 ms window, F0 tracking 
# starts at 30 ms before the window and ends 30 ms after (160 ms total). Only those values within the specified window are reported, however.
# Copyright Christian DiCanio, Haskins Laboratories, July 2012.

# Updated in November 2015 to include contextual information for working with corpora. This version of the script requires that all
# segments to be analyzed by on a separate tier.

# Updated in July 2016 to fix an issue pertaining to ensuring that the right window size is specified for F0 extraction and for fixing
# some redundant code. Thanks to Paul Boersma for this help.

# Added code in December 2016 to include utterance information. Note that the utterance (repetition) must encompass items the labeled tier,
# which is the target tier, e.g. the target label must be within an utterance that is labelled.

#Number of intervals you wish to extract from.

form Extract Pitch data from labelled intervals
   sentence Directory_name: /Linguistics/Mixteco/Grabaciones_Mixteco/Declinacion_Posicion_June-2016/Declinacion_2016/JDB_Declinacion_2016/ACG_Declination/
   sentence Log_file foo4
   positive Numintervals 5
   positive Utterance_tier_number 2
   positive Extra_tier_number 5
   positive Lexeme_tier_number 4
   positive Syllable_tier_number 6
   positive Labeled_tier_number 7
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   comment F0 Settings:
   positive F0_minimum 100
   positive F0_maximum 450
   positive Octave_jump 0.10
   positive Voicing_threshold 0.65
   positive Pitch_window_threshold 0.03
endform

# If your sound files are in a different format, you can insert that format instead of wav below.

Create Strings as file list... list 'directory_name$'/*.wav
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	soundID1$ = selected$("Sound")
	soundID2 = selected("Sound")
	Read from file... 'directory_name$'/'soundID1$'.TextGrid
	textGridID = selected("TextGrid")
	num_labels = Get number of intervals... labeled_tier_number

fileappend 'directory_name$''log_file$'.txt label'tab$'seg'tab$'syll'tab$'lex'tab$'extra'tab$'utt'tab$'start'tab$'end'tab$'cdur'tab$'dur'tab$'Sylldur'tab$'

for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'val_F0'tab$'
endfor
fileappend 'directory_name$''log_file$'.txt min'tab$'max'tab$'locmin'tab$'locmax
fileappend 'directory_name$''log_file$'.txt 'newline$'

	for i to num_labels
	select 'textGridID'
	label$ = Get label of interval... labeled_tier_number i

		if label$ <> ""
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'
      		intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)

			syll_num = do ("Get interval at time...", syllable_tier_number, intvl_start)
			syll_start = Get starting point: syllable_tier_number, syll_num
			syll_end = Get end point: syllable_tier_number, syll_num
			sylldur = syll_end - syll_start
			syll$ = do$ ("Get label of interval...", syllable_tier_number, syll_num)

			lex_num = do ("Get interval at time...", lexeme_tier_number, intvl_start)
			lex$ = do$ ("Get label of interval...", lexeme_tier_number, lex_num)

			ext_num = do ("Get interval at time...", extra_tier_number, intvl_start)
			ext$ = do$ ("Get label of interval...", extra_tier_number, ext_num)

			utt_num = do ("Get interval at time...", utterance_tier_number, intvl_start)
			utt$ = do$ ("Get label of interval...", utterance_tier_number, utt_num)

			select 'soundID2'
			Extract part... intvl_start intvl_end Rectangular 1 no
			intID = selected("Sound")
			dur = Get total duration
			cdur = sylldur - dur
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''syll$''tab$''lex$''tab$''ext$''tab$''utt$''tab$''intvl_start''tab$''intvl_end''tab$''cdur''tab$''dur''tab$''sylldur''tab$'

			pstart = intvl_start - pitch_window_threshold
			pend = intvl_end + pitch_window_threshold

#Pitch analysis
			select 'intID'
				if dur < 0.05
					size = dur/numintervals
					for q to numintervals
						start = (q-1) * size
						end = q * size
						val_F0  = 0
						fileappend 'directory_name$''log_file$'.txt 'val_F0''tab$'
					endfor
					min = 0
					max = 0
					locmin = 0
					locmax = 0
					fileappend 'directory_name$''log_file$'.txt 'min''tab$''max''tab$''locmin''tab$''locmax''tab$'
					fileappend 'directory_name$''log_file$'.txt 'newline$'
				else

				select 'soundID2'
				Extract part... pstart pend Rectangular 1 no
				soundID3 = selected("Sound")
				To Pitch (ac)... 0 f0_minimum 15 yes 0.03 voicing_threshold octave_jump 0.35 0.14 f0_maximum
				pitchID = selected("Pitch")

				select 'pitchID'
				size = dur/numintervals
				for h to numintervals
					start = (((h-1) * size) + pitch_window_threshold)
					end = h * size + pitch_window_threshold
					val_F0  = Get mean: start, end, "Hertz"
					if val_F0 = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'
						else
							fileappend 'directory_name$''log_file$'.txt 'val_F0''tab$'
					endif
				endfor

				select 'soundID3'
				ostart = Get start time
				oend = Get end time
				start = ostart + pitch_window_threshold
				end = oend - pitch_window_threshold
				dur2 = end - start
				select 'pitchID'

				min = Get minimum... start end Hertz Parabolic
					if min = undefined
					fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'min''tab$'
					endif	
				max = Get maximum... start end Hertz Parabolic
					if max = undefined
					fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'max''tab$'
					endif
				locmin2 = Get time of minimum... start end Hertz Parabolic
					if locmin2 = undefined
					fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						locmin = (locmin2-pitch_window_threshold)/dur2
						fileappend 'directory_name$''log_file$'.txt 'locmin''tab$'
					endif
				locmax2 = Get time of maximum... start end Hertz Parabolic
					if locmax2 = undefined
					fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						locmax = (locmax2-pitch_window_threshold)/dur2
						fileappend 'directory_name$''log_file$'.txt 'locmax''tab$'
					endif
				fileappend 'directory_name$''log_file$'.txt 'newline$'

			select 'pitchID'
			Remove
		endif
		else
		#do nothing
   		endif
	endfor
select 'textGridID'
Remove
select 'intID'
Remove
endfor
select all
Remove
