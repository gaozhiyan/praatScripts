####################################################################################################
# 
# Author: Thorsten Brato
# Mail: Thorsten.Brato@ur.de
# Script name: TB-Basic Vowel Analysis
# Version: 2.2 [2016:07:06]
# This script is distributed under the GNU General Public License 
# (http://www.gnu.org/licenses/gpl.txt).
# Copyright 14/07/2015 by Thorsten Brato.
#
####################################################################################################

########## Begin Description ##########
#
# Overview:
# This is a basic script for vowel formant analysis. The script goes through specified folders for
# sound files and TextGrids, searches for pairs, measures formants 1-3 (separated by monophthongs
# and diphthongs) and writes the results to a .txt file that can be read directly into NORM 
# (http://lvc.uoregon.edu/norm/norm1.php) or the 'vowels' package for R
# (http://cran.r-project.org/web/packages/vowels/) for normalisation and further analysis.
#
# Requirements:
# - Praat Version 5.3.62 or newer
# - Sound and TextGrid pairs (i.e. files with the same name, e.g. "speaker1.wav" and 
#   "speaker1.TextGrid") - Note that Praat is case-sensitive!
#  - The file extension for sound files must be ".wav". 
# - The file extension for TextGrids must be ".TextGrid".
# - The TextGrid must have at least two tiers(tiers 3 and above - if present -  will be ignored). 
#   Tier 1 must contain the "vowels" labels, tier 2 must contain the "context" labels.
# 
# Comment:
# The script is deliberately kept simple - allowing the user only limited options - and therefore
# uses some default settings that have proven to be reliable. The settings are summarised in the 
# following:
# - For the analysis stereo files are temporarily and on-the-fly converted to mono. This does
#   NOT affect the original files!
# - For the analysis the sampling rate is temporarily and on-the-fly downsampled to 16000 Hz,
#   i.e. formants up to 8000 Hz can be measured. This does NOT affect the original files!
# - The following (default) settings are used for the formant analysis:
#	Window length (s): 0.025
#	Preemphasis from (Hz): 50)
#   Formant time step: 0.0 (automatic)
#	Maximum number of formants: 5
# - Vowels labelled as monophthongs are measured at the midpoint, vowels labelled as diphthongs
#   are measured at the 20% and 80% time points.
#
########## End Description ##########

########## Begin Forms ##########

# This form is for the basic settings applying to all the data
form Basic vowel formant analysis for NORM
	comment Directory of sound files (top) and TextGrids (bottom) with final slash:
	# Never forget the trailing slash for the script to work!
	text sound_directory: E:\My Praat Data\
	text textGrid_directory E:\My Praat Data\
	
	comment Path to (existing) output file :
	text vowel_outputfile E:\My Praat Data\output_vowels.txt
	
	comment Overwrite existing output file append data to file?
	boolean Overwrite_output_files 0

	# The vowel labels
	# Remember: Praat is case-sensitive!
	comment Monophthong labels (do not forget the " "):
	text Monophthong_labels " kit dress trap lot strut foot bath cloth nurse fleece palm thought goose start north force happy letter comma horses use "
	
	comment Diphthong labels (do not forget the " "):
	text Diphthong_labels " face goat price choice mouth near square cure "
	
endform

# Make sure that vowel labels are used correctly
vowel_labels$ = monophthong_labels$ + diphthong_labels$
		
########## Begin Set up a couple of parameters ##########

# Set up the sound and TextGrid file extensions.
sound_file_extension$ = ".wav"
textGrid_file_extension$ = ".TextGrid"

# Set up the margin (as above)
margin = 0.05

########## End Set up a couple of parameters ##########

########## Begin Load the tables if they exist ##########
	
# Load the vowel output file or set it up. 

if fileReadable (vowel_outputfile$)
	do ("Read Table from tab-separated file...", vowel_outputfile$)
	
	table_vowel_file = selected ("Table")
	
	if overwrite_output_files = 1
	beginPause ("Overwrite output files")
	comment ("The vowel output file already exists.")
	comment ("Are you really sure you want to overwrite it.")
	overwrite_vowel_output = endPause ("Keep file and append new data", "Overwrite", 1)
	
		if overwrite_vowel_output = 2 
			deleteFile (vowel_outputfile$)
			selectObject (table_vowel_file)
			do ("Remove")
			
			# Create new table
			titleline$ = "Speaker Vowel Context f1 f2 f3 f1g f2g f3g"
			do ("Create Table with column names...", "output_vowels", 0, titleline$)
			table_vowel_file = selected ("Table")
		
		#endif overwrite_vowel_output = 2
		endif
	
	# endif overwrite_output_files = 1
	endif	

else

	# if the file does not exist, create table file

	titleline$ = "Speaker Vowel Context f1 f2 f3 f1g f2g f3g"
	do ("Create Table with column names...", "output_vowels", 0, titleline$)
	table_vowel_file = selected ("Table")

# endif fileReadable (vowel_outputfile$)
endif

########## End Load the tables if they exist ##########

# Index all sound files in the sound directory set up above
do ("Create Strings as file list...", "list", sound_directory$ + "*" + sound_file_extension$) 
string_of_sound_files = selected ("Strings")
number_of_files = do ("Get number of strings")

########## Begin Loop that goes through every file in the input directory ##########

# Note to user that analysis has started.

for file_number to number_of_files
	
	# Get the filename
	filename$ = do$ ("Get string...", file_number)
	
	# Open it as a long sound file
	do ("Open long sound file...", sound_directory$ + filename$)
	longsound = selected ("LongSound")
	
	#Extract the sound name
	speakername$ = replace$ (filename$, sound_file_extension$, "", 0)
	
	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''speakername$''textGrid_file_extension$'"
	
	if fileReadable (gridfile$)
		
	# Get maximum formant
	beginPause ("Provide the maximum formant!")
		comment ("Provide the maximum formant for filename: 'speakername$'.")
		comment ("5000 Hz is a typical value for males.")
		comment ("5500-6000 Hz is a typical value for females.")
		comment ("Values for children are usually considerably higher.")
		integer ("Maximum formant", 5000)
	gender_continue = endPause ("Continue", 1)
	if gender_continue = 1

		max_formant = maximum_formant
		
	endif
	
	########## Begin Go through the TextGrid and carry out analyses ##########
	
	# Open a TextGrid by the same name:
	#gridfile$ = "'textGrid_directory$''speakername$''textGrid_file_extension$'"
	
	#if fileReadable (gridfile$)
		do ("Read from file...", gridfile$)
		textgrid = selected ("TextGrid")
		
		# Get the number of tiers
		number_of_tiers = do ("Get number of tiers")
		
		# Get the name of and number of intervals on tier 1
		
		number_of_intervals_tier_1 = do ("Get number of intervals...", 1)
								
		########## Begin Carry out analyses based on tier 1 ##########
		
		# The following loop goes through intervals on tier 1
		for interval_tier_1 to number_of_intervals_tier_1
		
			# Get the label of the tier_1 interval
			tier_1_label$ = do$ ("Get label of interval...", 1, interval_tier_1)
			
			if index (vowel_labels$, " " + tier_1_label$ + " ")
			
				# Set up a temporary variable for monophthong or diphthong
				if index (monophthong_labels$, " " + tier_1_label$ + " ")
				
					monophthong = 1
					
				else 
					
					monophthong = 0
				
				#endif index (vowel_labels$, " " + tier_1_label$ + " ")
				endif
			
				# Set up some variables we'll need below
				segment_mono = 0
				segment_resampled = 0
								
				########## Begin Collect the relevant interval data ##########
				
				########## Begin Collect tier 1 interval data ##########
				
				# Get the start, end, duration (in ms) and centre of tier 1 intervals
				tier_1_start = do ("Get starting point...", 1, interval_tier_1)
				tier_1_end = do ("Get end point...", 1, interval_tier_1)
				tier_1_duration = (tier_1_end - tier_1_start)*1000
				tier_1_centre = (tier_1_start + tier_1_end)/2

				# Get the times at various places
				time_twenty = tier_1_start + 20*(tier_1_end-tier_1_start)/100
				time_fifty = tier_1_start + 50*(tier_1_end-tier_1_start)/100
				time_eighty = tier_1_start + 80*(tier_1_end-tier_1_start)/100

				########## End Collect tier 1 interval data ##########

				########## Begin Collect tier 2 interval data ##########

				if number_of_tiers > 1

					interval_tier_2 = do ("Get interval at time...", 2, tier_1_centre)
					
					# Get the label of the tier_2 interval
					tier_2_label$ = do$ ("Get label of interval...", 2, interval_tier_2)
					
				#endif number_of_tiers > 1	
				endif

				########## End Collect tier 2 interval data ##########
	
				########## End Collect the relevant interval data ##########
				
				########## Begin Change number of channels and change sampling frequency ##########
								
				selectObject (longsound)

				# Get the number of channels and sampling frequency
				long_soundinfo$ = Info
				number_of_channels$ = extractLine$(long_soundinfo$, "Number of channels: ")
				number_of_channels = number (number_of_channels$)
								
				sampling_frequency$ = extractLine$(long_soundinfo$, "Sampling frequency: ")
				sampling_frequency = number (sampling_frequency$)

				# Extract the segment on tier 1 for further analysis
				segment = do ("Extract part...", tier_1_start-margin, tier_1_end+margin, "yes")

				# Check if the segment is stereo and change to mono
				if number_of_channels = 2
					segment_mono = do ("Convert to mono")

				# endif number_of_channels = 2 and convert_to_mono = 1
				endif

				# If the sampling frequency is higher than 16000 Hz, downsample.
				if sampling_frequency > 16000
					
					current_segment = selected ("Sound")
					segment_resampled = do ("Resample...", 16000, 50)
					
					# if we resample, we remove the segment with the original sampling rate
					selectObject (current_segment)
					do ("Remove")
					selectObject (segment_resampled)
					
				# endif sampling_frequency > 16000
				endif
					
				########## End Change number of channels and change sampling frequency ##########
	
				########## Begin Collect a range of vowel measurements ##########
					
					# Get the number of the current sound to select below
					current_segment = selected ("Sound")
					
					# Get the formants and formant bandwidths 
					noprogress do ("To Formant (burg)...", 0.0, 5, max_formant, 0.025, 50)
					
					########## Begin Get formant measurements ##########

					# f1 values
					f1_twenty = do ("Get value at time...", 1, time_twenty, "Hertz", "Linear")
					f1_fifty = do ("Get value at time...", 1, time_fifty, "Hertz", "Linear")
					f1_eighty = do ("Get value at time...", 1, time_eighty, "Hertz", "Linear")
					
					# f2 values
					f2_twenty = do ("Get value at time...", 2, time_twenty, "Hertz", "Linear")
					f2_fifty = do ("Get value at time...", 2, time_fifty, "Hertz", "Linear")
					f2_eighty = do ("Get value at time...", 2, time_eighty, "Hertz", "Linear")
					
					# f3 values
					f3_twenty = do ("Get value at time...", 3, time_twenty, "Hertz", "Linear")
					f3_fifty = do ("Get value at time...", 3, time_fifty, "Hertz", "Linear")
					f3_eighty = do ("Get value at time...", 3, time_eighty, "Hertz", "Linear")
										
					# Remove sound and formant object
					plus current_segment
					do ("Remove")
					
					########## End Get formant measurements ##########
					
					########## Begin Write vowel measurements to tables ##########	
					
					selectObject (table_vowel_file)
					do ("Append row")
					last_row_vowels = do ("Get number of rows")
				
					# Write results to table
					if monophthong = 1
					
						do ("Set string value...", last_row_vowels, "Speaker", speakername$)
						do ("Set string value...", last_row_vowels, "Vowel", tier_1_label$)
						do ("Set string value...", last_row_vowels, "Context", tier_2_label$)
						do ("Set numeric value...", last_row_vowels, "f1", 'f1_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2", 'f2_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3", 'f3_fifty:0')
						do ("Set string value...", last_row_vowels, "f1g", " ")
						do ("Set string value...", last_row_vowels, "f2g", " ")
						do ("Set string value...", last_row_vowels, "f3g", " ")
						
					else
					
						do ("Set string value...", last_row_vowels, "Speaker", speakername$)
						do ("Set string value...", last_row_vowels, "Vowel", tier_1_label$)
						do ("Set string value...", last_row_vowels, "Context", tier_2_label$)
						do ("Set numeric value...", last_row_vowels, "f1", 'f1_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2", 'f2_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3", 'f3_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1g", 'f1_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f2g", 'f2_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f3g", 'f3_eighty:0')
						
					#endif monophthong = 1
					endif
										
				########## End Write vowel measurements to table ##########
			
				########## End Collect a range of vowel measurements ##########
							
				########## End Write measurements to tables ##########
				
			# endif index (vowel_labels$, " " + tier_1_label$ + " ")
			endif
			
			selectObject (textgrid)
		
		# endfor interval_tier_1 from 1 to number_of_intervals_tier_1
		endfor
		
		########## End Carry out analyses based on tier 1 ##########

		selectObject (textgrid)
		do ("Remove")
		
	# endif fileReadable (gridfile$)
	endif	
	
	selectObject (longsound)
	do ("Remove")
	
	# Select the next sound file
	selectObject (string_of_sound_files)
	
# endfor file_number to number_of_files
endfor

########## End loop that goes through every file in the input directory ##########	

# Write the result of the table object to a file

selectObject (table_vowel_file)
do ("Save as tab-separated file...", vowel_outputfile$)
do ("Remove")

selectObject (string_of_sound_files)
do ("Remove")

writeInfo ()
writeInfoLine ("Done!")
appendInfoLine ("")
appendInfoLine ("The results for the vowels analysis have been written to 'newline$''vowel_outputfile$'")
