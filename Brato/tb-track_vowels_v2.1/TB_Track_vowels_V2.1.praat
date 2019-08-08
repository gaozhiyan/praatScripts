####################################################################################################
# 
# Author: Thorsten Brato
# Mail: Thorsten.Brato@ur
# Script name: TB-Track_vowels_V2.1
# Version: [2016:07:06]
# This script is distributed under the GNU General Public License 
# (http://www.gnu.org/licenses/gpl.txt).
# Copyright 21/03/2014 by Thorsten Brato.
#
####################################################################################################
#
########## Description ##########

# !!!!!!!!!!!!!!!!!!!! THIS DESCRIPTION IS TEMPORARY AND NOT QUITE CORRECT AT PRESENT !!!!!!!!!!!!!!!!!!!!
#
# This script was developed for vowel tracking in Ghanaian English. I tried to annotate it 
# extensively and use meaningful (i.e. user-friendly) variable names wherever possible, so that
# other users can adapt it to fit their needs more easily.
#
# Vowel tracking refers to taking a number of consecutive vowel formant measurements across the
# vowel's duration in order to find out more about the vowel formant dynamics (e.g. Fox & Jacewicz
# 2009) than would be possible by single (e.g. midpoint) or two-point (onset and glide) measurements
# alone. In the current script this is implemented in a number of ways and users can use the form
# to choose between four options: 
# 1) three-point (Onset (20%), Midpoint (50%), Glide (80%))
# 2) 11-point (10% intervals (0/10/20/30/40/50/60/70/80/90/100%) )cf. Hoffmann 2011)
# 3) 5-point (15% intervals (20/35/50/65/80%)) (cf. Fox & Jacewicz 2009)
# 4) 13-point (Combine options 2 and 3 (0/10/20/30/35/40/50/60/65/70/80/90/100%))
# 
# The following acoustic information is logged:
# Formants 1-3 at the points chosen
# Formant bandwidths 1-3 at the points chosen
#
########## Requirements ##########
#
# In order to work properly, the script requires Sound/TextGrid pairs, i.e. the sound file and 
# TextGrid must have the same filename, e.g. speaker1.wav/speaker1.TextGrid. Furthermore, it 
# assumes that the smallest unit (the vowel phoneme) is annotated on the first tier.



########## References ##########
#
# Fox, Robert A. & Ewa Jacewicz. 2009. “Cross-dialectal variation in formant dynamics of American
# English vowels”. Journal of the Acoustical Society of America 126 (5), 2603–2618.
# Hoffmann, Thomas. 2011. “The Black Kenyan English vowel system: An acoustic phonetic analysis”. 
# English World-Wide 32 (2), 147–173.


########## Begin Forms ##########

########## Begin Form 1 ##########

# This form is for the basic settings applying to all the data
form Basic settings
	comment Directory of sound files (top) and textgrids (bottom) with final slash:
	# never forget the trailing slash for the script to work!
	text sound_directory: E:\My Praat data\
	# See comment below the form.
	# comment Sound file extension:
	# sentence Sound_file_extension .wav
	
	#comment Directory of TextGrid files with final slash:			
	# never forget the trailing slash for the script to work!
	text textGrid_directory E:\My Praat data\
	# See comment below the form.
	# comment TextGrid file extension:
	# sentence TextGrid_file_extension .TextGrid
	
	comment Path to (existing) output file :
	text vowel_outputfile E:\My Praat data\output_vowels.txt
	
	comment Path to (existing) token file :
	text tokenfile E:\My Praat data\tokens.txt
	
	comment Overwrite existing output files or append?
	boolean Overwrite_output_files 0

	# Are the vowels labelled as lexical sets and do you want to use these?
	comment Use lexical set labels?
	boolean Use_lexical_sets 1
	
	# Ask the user if they want to convert stereo to mono.
	comment Convert stereo to mono?
	# Convert a stereo file to mono?
	boolean Convert_to_mono 1
	
	# When Praat loads the segment without a margin it cannot read the formants
	# If you want to set this in the form uncomment the lines and make sure you comment
	# the line below
	#comment ("Left and right margin to be used for extracting the segments")
	#real Margin_(s) 0.05

	# Analyser ID is used in the creation of the token file if filled.
	comment Who analysed the data?
	sentence Analyser TB
endform

########## End Form 1 ##########

if use_lexical_sets = 1

	vowel_labels$ = " kit dress trap lot strut foot bath cloth nurse fleece face palm thought goat goose price choice mouth near square start north force cure happy letter comma horses use "
	
else
	
	########## Begin Form 2 ##########
	
	# If the user chooses to not use lexical set labels show a form for inputting the labels.
	
	beginPause ("Vowel labels")
	
		comment ("Use the following format: label1 label2 label3 ...")
		text ("vowel_labels", "AH IJ ...")
		
	vowel_labels_continue = endPause ("Continue", 1)
	
	if vowel_labels_continue = 1
	
		vowel_labels$ = " " + vowel_labels$ + " "
	
	# endif vowel_labels_continue = 1
	endif
	
	########## End Form 2 ##########
	
# endif use_lexical_sets = 1
endif


	########## Begin Form 3 ##########
	
	beginPause ("Vowel settings 1")
		comment ("Set the vowel parameters.")
				
		comment ("Select at which temporal points the vowel measures are stored:")
		optionMenu ("Interval type", 1)
			# Option 1 measures at 20/50/80%
			option ("Onset (20%), Midpoint (50%), Glide (80%)")
			# Option 2 measures at 0/5/10/15/20/25/30/35/40/45/50/55/60/65/70/75/80/85/90/95/100%
			option ("5% intervals (0-100%)")
			# Option 3 measures at 0/10/20/30/40/50/60/70/80/90/100%
			option ("10% intervals (0-100%)")
			# Option 4 measures at 20/35/50/65/80%
			option ("15% intervals (20-80%)")
			
		# Change the sampling rate? The sampling rate should be at least
		# twice the maximum frequency chosen for analysis.
		comment ("Downsample prior to analysis?")
		comment ("(Only applies if the sampling rate is higher. Type in 0 to keep original sampling rate.)")
		integer ("Downsample vowels (Hz)", 11025)
		
		comment ("Formant analysis parameters")
		boolean ("Use the formant tracker", 1)
		
		positive ("Formant time step", 0.01)
		integer ("Maximum number of formants", 5)
		# Set the maximum formant: 
		# 5000 Hz is a typical value for adult males.
		# 5500 Hz is a typical value for adult females.
		# For children use higher values (6000-8000 Hz).
		# Before running the script inspect the data visually to make sure
		# formant values make sense.
		comment ("Maximum formant (males on the left; females on the right)")
		positive ("left Maximum formant (Hz)", 5000)
		positive ("right Maximum formant (Hz)", 5500)
		positive ("Window length (s)", 0.025)
		positive ("Preemphasis from (Hz)", 50)
						
		# Set up the pitch measurements
		comment ("Pitch settings")
		integer ("Pitch time step (0 = auto) ", 0)
		positive ("left Pitch range (Hz)", 100)
		positive ("right Pitch range (Hz)", 500)
	
	# endPause ("Vowel settings 1")	
	vowel_continue = endPause ("Continue", 1)

	########## End Form 3 ##########
		
	if vowel_continue = 1
		downsample_to = downsample_vowels
		use_the_formant_tracker = use_the_formant_tracker
		maximum_number_of_formants = maximum_number_of_formants
		maximum_formant_males = left_Maximum_formant
		maximum_formant_females = right_Maximum_formant
		vowel_interval_type = interval_type
		formant_time_step = formant_time_step
		window_length = window_length
		preemphasis_from = preemphasis_from
		pitch_time_step = pitch_time_step
		minimum_pitch_vowels = left_Pitch_range
		maximum_pitch_vowels = right_Pitch_range
	# endif vowel_continue = 1
	endif
	
	########## Begin Form 4 ##########

	if use_the_formant_tracker = 1
		beginPause ("Formant tracker settings")
		comment ("Settings for the vowel tracking algorithm (males on the left; females on the right)")
		positive ("Number of tracks", 3)
		positive ("left F1 reference", 500)
		positive ("right F1 reference", 550)
		positive ("left F2 reference", 1485)
		positive ("right F2 reference", 1650)
		positive ("left F3 reference", 2475)
		positive ("right F3 reference", 2750)
		positive ("left Frequency cost", 1)
		positive ("right Frequency cost", 1)
		positive ("left Bandwidth cost", 1)
		positive ("right Bandwidth cost", 1)
		positive ("left Transition cost", 1)
		positive ("right Transition cost", 1)
		
		# endPause ("Formant tracker settings")
		formant_tracker_continue = endPause ("Continue", 1)

	# endif use_the_formant_tracker = 1
	endif

	########## End Form 4 ##########
	
# endif analyse_vowels = 1
endif

########## End Forms ##########

########## Begin Set up a couple of parameters ##########

script_name$ = "TB-Track_vowels_V2.1"
version$ = "[2016:07:06]"
date$ = date$()
year$ = right$ (date$, 4)
month$ = mid$ (date$, 5, 3)
if month$ = "Jan"
	month$ = "01"
elsif month$ = "Feb"
	month$ = "02"
elsif month$ = "Mar"
	month$ = "03"
elsif month$ = "Apr"
	month$ = "04"	
elsif month$ = "May"
	month$ = "05"	
elsif month$ = "Jun"
	month$ = "06"
elsif month$ = "Jul"
	month$ = "07"	
elsif month$ = "Aug"
	month$ = "08"	
elsif month$ = "Sep"
	month$ = "09"	
elsif month$ = "Oct"
	month$ = "10"	
elsif month$ = "Nov"
	month$ = "11"	
elsif month$ = "Dec"
	month$ = "12"	

# endif month$ = "Jan"
endif
day$ = mid$ (date$, 9, 2)

date$ = year$ + "_" + month$ + "_" + day$

# Set up the sound and TextGrid file extensions. I only use .wav and .TextGrid so I like to save the space in my form. Uncomment the lines 'sentence Sound_file_extension .wav' and/or 'sentence TextGrid_file_extension .TextGrid' in the form above if you want to set these for every pair. In that case, don't forget to comment the two lines below.
sound_file_extension$ = ".wav"
textGrid_file_extension$ = ".TextGrid"

# Set up the margin (as above)
margin = 0.05

########## End Set up a couple of parameters ##########

########## Begin Load the tables if they exist. Otherwise set up the tokens table. ##########

# Load the token file or set it up. 
if  fileReadable (tokenfile$)
	do ("Read Table from tab-separated file...", tokenfile$)
else 
	do ("Create Table with column names...", "tokens", 1, "analyser token_no")
	do ("Set string value...", 1, "analyser", analyser$)
	do ("Set numeric value...", 1, "token_no", 1) 
	
# endif fileReadable (tokenfile$)
endif
table_tokens = selected ("Table")

# Get the current token number
token_no = do ("Get value...", 1, "token_no")
	
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
		
			# if the file was deleted, create dummy 
			table_vowel_file = 0
		
		#endif overwrite_vowel_output = 2
		endif
	
	# endif overwrite_output_files = 1
	endif	

else

	# if the file does not exist, create dummy 
	table_vowel_file = 0
	
# endif fileReadable (vowel_file$)
endif

########## End Load the tables if they exist. Otherwise set up the tokens table. ##########

# Index all sound files in the sound directory set up above
do ("Create Strings as file list...", "list", sound_directory$ + "*" + sound_file_extension$) 
string_of_sound_files = selected ("Strings")
number_of_files = do ("Get number of strings")

########## Begin Loop that goes through every file in the input directory ##########

# Note to user that analysis has started.
writeInfo ()
writeInfoLine ("Analysis started. Please be patient, this may take a while.")

for file_number to number_of_files

	
	# Get the filename
	filename$ = do$ ("Get string...", file_number)
	
	# Open it as a long sound file
	do ("Open long sound file...", sound_directory$ + filename$)
	longsound = selected ("LongSound")
	
	########## Begin Extract sound name, style, speaker and gender ##########
	 
# Load the extraction file data extraction script
include TB-file_data_extraction.praat
	
	########## End Extract sound name, style, speaker and gender ##########
	
	########## Begin Go through the textgrid and carry out analyses ##########
	
	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	
	if fileReadable (gridfile$)
		do ("Read from file...", gridfile$)
		textgrid = selected ("TextGrid")
		
		# Get the name of and number of intervals on tier 1
		tier_1_name$ = do$ ("Get tier name...", 1)
		number_of_intervals_tier_1 = do ("Get number of intervals...", 1)
		
		# Get the number of tiers
		number_of_tiers = do ("Get number of tiers")
		
		if number_of_tiers > 1
			tier_2_name$ = do$ ("Get tier name...", 2)
			number_of_intervals_tier_2 = do ("Get number of intervals...", 2)
		#endif number_of_tiers > 1
		endif
		if number_of_tiers > 2
			tier_3_name$ = do$ ("Get tier name...", 3)
			number_of_intervals_tier_3 = do ("Get number of intervals...", 3)
		#endif number_of_tiers > 2
		endif
		if number_of_tiers > 3
			tier_4_name$ = do$ ("Get tier name...", 4)
			number_of_intervals_tier_4 = do ("Get number of intervals...", 4)
		#endif number_of_tiers > 3
		endif
				
		########## Begin Carry out analyses based on tier 1 ##########
		
		# The following loop goes through intervals on tier 1
		for interval_tier_1 from 1 to number_of_intervals_tier_1
		
			# Get the label of the tier_1 interval
			tier_1_label$ = do$ ("Get label of interval...", 1, interval_tier_1)
			if tier_1_label$ = ""
				tier_1_label$ = "empty"
			# endif tier_1_label$ = ""
			endif
			
			#Extract the tier_1 label without the stress information
			tier_1_label_2$ = replace_regex$ (tier_1_label$,"[0-9]", "", 0)
			
			if index (vowel_labels$, " " + tier_1_label_2$ + " ")
			
				# Set up some variables we'll need below
				segment_mono = 0
				segment_resampled = 0
								
				########## Begin Collect the relevant interval data ##########
				
# Load the extraction file data extraction script
include TB-tier_data_extraction.praat
	
				########## End Collect the relevant interval data ##########
				
				
				########## Begin Change number of channels and change sampling frequency ##########
				
# Load the channel and sampling frequency script
include TB-change_channel_and_sampling_frequency.praat
				
				########## End Change number of channels and change sampling frequency ##########
	
				########## Begin Collect a range of vowel measurements ##########
					
					# Get the number of the current sound to select below
					current_segment = selected ("Sound")
					
					# Get the formants and formant bandwidths 
					if gender$ = "male"
						noprogress do ("To Formant (burg)...", formant_time_step, maximum_number_of_formants, maximum_formant_males, window_length, preemphasis_from)
					elsif gender$ = "female"
						noprogress do ("To Formant (burg)...", formant_time_step, maximum_number_of_formants, maximum_formant_females, window_length, preemphasis_from)
					#endif gender$ = "male"
					endif
					
					current_formant = selected ("Formant")
					
					if use_the_formant_tracker = 1 and gender$ = "male"
							
						nocheck do ("Track...", number_of_tracks, left_F1_reference, left_F2_reference, left_F3_reference, 3465, 4455, left_Frequency_cost, left_Bandwidth_cost, left_Transition_cost)
						formant_tracker$ = "yes"	
						
					elsif use_the_formant_tracker = 1 and gender$ = "female"
						
						nocheck do ("Track...", number_of_tracks, right_F1_reference, right_F2_reference, right_F3_reference, 3850, 4950, right_Frequency_cost, right_Bandwidth_cost, right_Transition_cost)
						formant_tracker$ = "yes"
											
					# endif use_the_formant_tracker = 1
					endif
					
					########## Begin Get formant measurements and bandwiths based on selection in the form ##########
					
					# 20/50/80%
					if vowel_interval_type = 1
					
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
						
						# f1 bandwidth
						f1_b_twenty = do ("Get bandwidth at time...", 1, time_twenty, "Hertz", "Linear")
						f1_b_fifty = do ("Get bandwidth at time...", 1, time_fifty, "Hertz", "Linear")
						f1_b_eighty = do ("Get bandwidth at time...", 1, time_eighty, "Hertz", "Linear")
						
						# f2 bandwidth
						f2_b_twenty = do ("Get bandwidth at time...", 2, time_twenty, "Hertz", "Linear")
						f2_b_fifty = do ("Get bandwidth at time...", 2, time_fifty, "Hertz", "Linear")
						f2_b_eighty = do ("Get bandwidth at time...", 2, time_eighty, "Hertz", "Linear")
						
						# f3 bandwidth
						f3_b_twenty = do ("Get bandwidth at time...", 3, time_twenty, "Hertz", "Linear")
						f3_b_fifty = do ("Get bandwidth at time...", 3, time_fifty, "Hertz", "Linear")
						f3_b_eighty = do ("Get bandwidth at time...", 3, time_eighty, "Hertz", "Linear")
						
					# 5% intervals
					elsif vowel_interval_type = 2
					
						# f1 values
						f1_zero = do ("Get value at time...", 1, time_zero, "Hertz", "Linear")
						f1_five = do ("Get value at time...", 1, time_five, "Hertz", "Linear")
						f1_ten = do ("Get value at time...", 1, time_ten, "Hertz", "Linear")
						f1_fifteen = do ("Get value at time...", 1, time_fifteen, "Hertz", "Linear")
						f1_twenty = do ("Get value at time...", 1, time_twenty, "Hertz", "Linear")
						f1_twenty_five = do ("Get value at time...", 1, time_twenty_five, "Hertz", "Linear")
						f1_thirty = do ("Get value at time...", 1, time_thirty, "Hertz", "Linear")
						f1_thirty_five = do ("Get value at time...", 1, time_thirty_five, "Hertz", "Linear")
						f1_forty = do ("Get value at time...", 1, time_forty, "Hertz", "Linear")
						f1_forty_five = do ("Get value at time...", 1, time_forty_five, "Hertz", "Linear")
						f1_fifty = do ("Get value at time...", 1, time_fifty, "Hertz", "Linear")
						f1_fifty_five = do ("Get value at time...", 1, time_fifty_five, "Hertz", "Linear")
						f1_sixty = do ("Get value at time...", 1, time_sixty, "Hertz", "Linear")
						f1_sixty_five = do ("Get value at time...", 1, time_sixty_five, "Hertz", "Linear")
						f1_seventy = do ("Get value at time...", 1, time_seventy, "Hertz", "Linear")
						f1_seventy_five = do ("Get value at time...", 1, time_seventy_five, "Hertz", "Linear")
						f1_eighty = do ("Get value at time...", 1, time_eighty, "Hertz", "Linear")
						f1_eighty_five = do ("Get value at time...", 1, time_eighty_five, "Hertz", "Linear")
						f1_ninety = do ("Get value at time...", 1, time_ninety, "Hertz", "Linear")
						f1_ninety_five = do ("Get value at time...", 1, time_ninety_five, "Hertz", "Linear")
						f1_hundred = do ("Get value at time...", 1, time_hundred, "Hertz", "Linear")
						
						# f2 values
						f2_zero = do ("Get value at time...", 2, time_zero, "Hertz", "Linear")
						f2_five = do ("Get value at time...", 2, time_five, "Hertz", "Linear")
						f2_ten = do ("Get value at time...", 2, time_ten, "Hertz", "Linear")
						f2_fifteen = do ("Get value at time...", 2, time_fifteen, "Hertz", "Linear")
						f2_twenty = do ("Get value at time...", 2, time_twenty, "Hertz", "Linear")
						f2_twenty_five = do ("Get value at time...", 2, time_twenty_five, "Hertz", "Linear")
						f2_thirty = do ("Get value at time...", 2, time_thirty, "Hertz", "Linear")
						f2_thirty_five = do ("Get value at time...", 2, time_thirty_five, "Hertz", "Linear")
						f2_forty = do ("Get value at time...", 2, time_forty, "Hertz", "Linear")
						f2_forty_five = do ("Get value at time...", 2, time_forty_five, "Hertz", "Linear")
						f2_fifty = do ("Get value at time...", 2, time_fifty, "Hertz", "Linear")
						f2_fifty_five = do ("Get value at time...", 2, time_fifty_five, "Hertz", "Linear")
						f2_sixty = do ("Get value at time...", 2, time_sixty, "Hertz", "Linear")
						f2_sixty_five = do ("Get value at time...", 2, time_sixty_five, "Hertz", "Linear")
						f2_seventy = do ("Get value at time...", 2, time_seventy, "Hertz", "Linear")
						f2_seventy_five = do ("Get value at time...", 2, time_seventy_five, "Hertz", "Linear")
						f2_eighty = do ("Get value at time...", 2, time_eighty, "Hertz", "Linear")
						f2_eighty_five = do ("Get value at time...", 2, time_eighty_five, "Hertz", "Linear")
						f2_ninety = do ("Get value at time...", 2, time_ninety, "Hertz", "Linear")
						f2_ninety_five = do ("Get value at time...", 2, time_ninety_five, "Hertz", "Linear")
						f2_hundred = do ("Get value at time...", 2, time_hundred, "Hertz", "Linear")
						
						# f3 values
						f3_zero = do ("Get value at time...", 3, time_zero, "Hertz", "Linear")
						f3_five = do ("Get value at time...", 3, time_five, "Hertz", "Linear")
						f3_ten = do ("Get value at time...", 3, time_ten, "Hertz", "Linear")
						f3_fifteen = do ("Get value at time...", 3, time_fifteen, "Hertz", "Linear")
						f3_twenty = do ("Get value at time...", 3, time_twenty, "Hertz", "Linear")
						f3_twenty_five = do ("Get value at time...", 3, time_twenty_five, "Hertz", "Linear")
						f3_thirty = do ("Get value at time...", 3, time_thirty, "Hertz", "Linear")
						f3_thirty_five = do ("Get value at time...", 3, time_thirty_five, "Hertz", "Linear")
						f3_forty = do ("Get value at time...", 3, time_forty, "Hertz", "Linear")
						f3_forty_five = do ("Get value at time...", 3, time_forty_five, "Hertz", "Linear")
						f3_fifty = do ("Get value at time...", 3, time_fifty, "Hertz", "Linear")
						f3_fifty_five = do ("Get value at time...", 3, time_fifty_five, "Hertz", "Linear")
						f3_sixty = do ("Get value at time...", 3, time_sixty, "Hertz", "Linear")
						f3_sixty_five = do ("Get value at time...", 3, time_sixty_five, "Hertz", "Linear")
						f3_seventy = do ("Get value at time...", 3, time_seventy, "Hertz", "Linear")
						f3_seventy_five = do ("Get value at time...", 3, time_seventy_five, "Hertz", "Linear")
						f3_eighty = do ("Get value at time...", 3, time_eighty, "Hertz", "Linear")
						f3_eighty_five = do ("Get value at time...", 3, time_eighty_five, "Hertz", "Linear")
						f3_ninety = do ("Get value at time...", 3, time_ninety, "Hertz", "Linear")
						f3_ninety_five = do ("Get value at time...", 3, time_ninety_five, "Hertz", "Linear")
						f3_hundred = do ("Get value at time...", 3, time_hundred, "Hertz", "Linear")
						
						# f1 bandwidths
						f1_b_zero = do ("Get bandwidth at time...", 1, time_zero, "Hertz", "Linear")
						f1_b_five = do ("Get bandwidth at time...", 1, time_five, "Hertz", "Linear")
						f1_b_ten = do ("Get bandwidth at time...", 1, time_ten, "Hertz", "Linear")
						f1_b_fifteen = do ("Get bandwidth at time...", 1, time_fifteen, "Hertz", "Linear")
						f1_b_twenty = do ("Get bandwidth at time...", 1, time_twenty, "Hertz", "Linear")
						f1_b_twenty_five = do ("Get bandwidth at time...", 1, time_twenty_five, "Hertz", "Linear")
						f1_b_thirty = do ("Get bandwidth at time...", 1, time_thirty, "Hertz", "Linear")
						f1_b_thirty_five = do ("Get bandwidth at time...", 1, time_thirty_five, "Hertz", "Linear")
						f1_b_forty = do ("Get bandwidth at time...", 1, time_forty, "Hertz", "Linear")
						f1_b_forty_five = do ("Get bandwidth at time...", 1, time_forty_five, "Hertz", "Linear")
						f1_b_fifty = do ("Get bandwidth at time...", 1, time_fifty, "Hertz", "Linear")
						f1_b_fifty_five = do ("Get bandwidth at time...", 1, time_fifty_five, "Hertz", "Linear")
						f1_b_sixty = do ("Get bandwidth at time...", 1, time_sixty, "Hertz", "Linear")
						f1_b_sixty_five = do ("Get bandwidth at time...", 1, time_sixty_five, "Hertz", "Linear")
						f1_b_seventy = do ("Get bandwidth at time...", 1, time_seventy, "Hertz", "Linear")
						f1_b_seventy_five = do ("Get bandwidth at time...", 1, time_seventy_five, "Hertz", "Linear")
						f1_b_eighty = do ("Get bandwidth at time...", 1, time_eighty, "Hertz", "Linear")
						f1_b_eighty_five = do ("Get bandwidth at time...", 1, time_eighty_five, "Hertz", "Linear")
						f1_b_ninety = do ("Get bandwidth at time...", 1, time_ninety, "Hertz", "Linear")
						f1_b_ninety_five = do ("Get bandwidth at time...", 1, time_ninety_five, "Hertz", "Linear")
						f1_b_hundred = do ("Get bandwidth at time...", 1, time_hundred, "Hertz", "Linear")
						
						# f2 bandwidths
						f2_b_zero = do ("Get bandwidth at time...", 2, time_zero, "Hertz", "Linear")
						f2_b_five = do ("Get bandwidth at time...", 2, time_five, "Hertz", "Linear")
						f2_b_ten = do ("Get bandwidth at time...", 2, time_ten, "Hertz", "Linear")
						f2_b_fifteen = do ("Get bandwidth at time...", 2, time_fifteen, "Hertz", "Linear")
						f2_b_twenty = do ("Get bandwidth at time...", 2, time_twenty, "Hertz", "Linear")
						f2_b_twenty_five = do ("Get bandwidth at time...", 2, time_twenty_five, "Hertz", "Linear")
						f2_b_thirty = do ("Get bandwidth at time...", 2, time_thirty, "Hertz", "Linear")
						f2_b_thirty_five = do ("Get bandwidth at time...", 2, time_thirty_five, "Hertz", "Linear")
						f2_b_forty = do ("Get bandwidth at time...", 2, time_forty, "Hertz", "Linear")
						f2_b_forty_five = do ("Get bandwidth at time...", 2, time_forty_five, "Hertz", "Linear")
						f2_b_fifty = do ("Get bandwidth at time...", 2, time_fifty, "Hertz", "Linear")
						f2_b_fifty_five = do ("Get bandwidth at time...", 2, time_fifty_five, "Hertz", "Linear")
						f2_b_sixty = do ("Get bandwidth at time...", 2, time_sixty, "Hertz", "Linear")
						f2_b_sixty_five = do ("Get bandwidth at time...", 2, time_sixty_five, "Hertz", "Linear")
						f2_b_seventy = do ("Get bandwidth at time...", 2, time_seventy, "Hertz", "Linear")
						f2_b_seventy_five = do ("Get bandwidth at time...", 2, time_seventy_five, "Hertz", "Linear")
						f2_b_eighty = do ("Get bandwidth at time...", 2, time_eighty, "Hertz", "Linear")
						f2_b_eighty_five = do ("Get bandwidth at time...", 2, time_eighty_five, "Hertz", "Linear")
						f2_b_ninety = do ("Get bandwidth at time...", 2, time_ninety, "Hertz", "Linear")
						f2_b_ninety_five = do ("Get bandwidth at time...", 2, time_ninety_five, "Hertz", "Linear")
						f2_b_hundred = do ("Get bandwidth at time...", 2, time_hundred, "Hertz", "Linear")
						
						# f3 bandwidths
						f3_b_zero = do ("Get bandwidth at time...", 3, time_zero, "Hertz", "Linear")
						f3_b_five = do ("Get bandwidth at time...", 3, time_five, "Hertz", "Linear")
						f3_b_ten = do ("Get bandwidth at time...", 3, time_ten, "Hertz", "Linear")
						f3_b_fifteen = do ("Get bandwidth at time...", 3, time_fifteen, "Hertz", "Linear")
						f3_b_twenty = do ("Get bandwidth at time...", 3, time_twenty, "Hertz", "Linear")
						f3_b_twenty_five = do ("Get bandwidth at time...", 3, time_twenty_five, "Hertz", "Linear")
						f3_b_thirty = do ("Get bandwidth at time...", 3, time_thirty, "Hertz", "Linear")
						f3_b_thirty_five = do ("Get bandwidth at time...", 3, time_thirty_five, "Hertz", "Linear")
						f3_b_forty = do ("Get bandwidth at time...", 3, time_forty, "Hertz", "Linear")
						f3_b_forty_five = do ("Get bandwidth at time...", 3, time_forty_five, "Hertz", "Linear")
						f3_b_fifty = do ("Get bandwidth at time...", 3, time_fifty, "Hertz", "Linear")
						f3_b_fifty_five = do ("Get bandwidth at time...", 3, time_fifty_five, "Hertz", "Linear")
						f3_b_sixty = do ("Get bandwidth at time...", 3, time_sixty, "Hertz", "Linear")
						f3_b_sixty_five = do ("Get bandwidth at time...", 3, time_sixty_five, "Hertz", "Linear")
						f3_b_seventy = do ("Get bandwidth at time...", 3, time_seventy, "Hertz", "Linear")
						f3_b_seventy_five = do ("Get bandwidth at time...", 3, time_seventy_five, "Hertz", "Linear")
						f3_b_eighty = do ("Get bandwidth at time...", 3, time_eighty, "Hertz", "Linear")
						f3_b_eighty_five = do ("Get bandwidth at time...", 3, time_eighty_five, "Hertz", "Linear")
						f3_b_ninety = do ("Get bandwidth at time...", 3, time_ninety, "Hertz", "Linear")
						f3_b_ninety_five = do ("Get bandwidth at time...", 3, time_ninety_five, "Hertz", "Linear")
						f3_b_hundred = do ("Get bandwidth at time...", 3, time_hundred, "Hertz", "Linear")
					
					# 10% intervals
					elsif vowel_interval_type = 3
					
						# f1 values
						f1_zero = do ("Get value at time...", 1, time_zero, "Hertz", "Linear")
						f1_ten = do ("Get value at time...", 1, time_ten, "Hertz", "Linear")
						f1_twenty = do ("Get value at time...", 1, time_twenty, "Hertz", "Linear")
						f1_thirty = do ("Get value at time...", 1, time_thirty, "Hertz", "Linear")
						f1_forty = do ("Get value at time...", 1, time_forty, "Hertz", "Linear")
						f1_fifty = do ("Get value at time...", 1, time_fifty, "Hertz", "Linear")
						f1_sixty = do ("Get value at time...", 1, time_sixty, "Hertz", "Linear")
						f1_seventy = do ("Get value at time...", 1, time_seventy, "Hertz", "Linear")
						f1_eighty = do ("Get value at time...", 1, time_eighty, "Hertz", "Linear")
						f1_ninety = do ("Get value at time...", 1, time_ninety, "Hertz", "Linear")
						f1_hundred = do ("Get value at time...", 1, time_hundred, "Hertz", "Linear")
						
						# f2 values
						f2_zero = do ("Get value at time...", 2, time_zero, "Hertz", "Linear")
						f2_ten = do ("Get value at time...", 2, time_ten, "Hertz", "Linear")
						f2_twenty = do ("Get value at time...", 2, time_twenty, "Hertz", "Linear")
						f2_thirty = do ("Get value at time...", 2, time_thirty, "Hertz", "Linear")
						f2_forty = do ("Get value at time...", 2, time_forty, "Hertz", "Linear")
						f2_fifty = do ("Get value at time...", 2, time_fifty, "Hertz", "Linear")
						f2_sixty = do ("Get value at time...", 2, time_sixty, "Hertz", "Linear")
						f2_seventy = do ("Get value at time...", 2, time_seventy, "Hertz", "Linear")
						f2_eighty = do ("Get value at time...", 2, time_eighty, "Hertz", "Linear")
						f2_ninety = do ("Get value at time...", 2, time_ninety, "Hertz", "Linear")
						f2_hundred = do ("Get value at time...", 2, time_hundred, "Hertz", "Linear")
						
						# f3 values
						f3_zero = do ("Get value at time...", 3, time_zero, "Hertz", "Linear")
						f3_ten = do ("Get value at time...", 3, time_ten, "Hertz", "Linear")
						f3_twenty = do ("Get value at time...", 3, time_twenty, "Hertz", "Linear")
						f3_thirty = do ("Get value at time...", 3, time_thirty, "Hertz", "Linear")
						f3_forty = do ("Get value at time...", 3, time_forty, "Hertz", "Linear")
						f3_fifty = do ("Get value at time...", 3, time_fifty, "Hertz", "Linear")
						f3_sixty = do ("Get value at time...", 3, time_sixty, "Hertz", "Linear")
						f3_seventy = do ("Get value at time...", 3, time_seventy, "Hertz", "Linear")
						f3_eighty = do ("Get value at time...", 3, time_eighty, "Hertz", "Linear")
						f3_ninety = do ("Get value at time...", 3, time_ninety, "Hertz", "Linear")
						f3_hundred = do ("Get value at time...", 3, time_hundred, "Hertz", "Linear")
						
						# f1 bandwidths
						f1_b_zero = do ("Get bandwidth at time...", 1, time_zero, "Hertz", "Linear")
						f1_b_ten = do ("Get bandwidth at time...", 1, time_ten, "Hertz", "Linear")
						f1_b_twenty = do ("Get bandwidth at time...", 1, time_twenty, "Hertz", "Linear")
						f1_b_thirty = do ("Get bandwidth at time...", 1, time_thirty, "Hertz", "Linear")
						f1_b_forty = do ("Get bandwidth at time...", 1, time_forty, "Hertz", "Linear")
						f1_b_fifty = do ("Get bandwidth at time...", 1, time_fifty, "Hertz", "Linear")
						f1_b_sixty = do ("Get bandwidth at time...", 1, time_sixty, "Hertz", "Linear")
						f1_b_seventy = do ("Get bandwidth at time...", 1, time_seventy, "Hertz", "Linear")
						f1_b_eighty = do ("Get bandwidth at time...", 1, time_eighty, "Hertz", "Linear")
						f1_b_ninety = do ("Get bandwidth at time...", 1, time_ninety, "Hertz", "Linear")
						f1_b_hundred = do ("Get bandwidth at time...", 1, time_hundred, "Hertz", "Linear")
						
						# f2 bandwidths
						f2_b_zero = do ("Get bandwidth at time...", 2, time_zero, "Hertz", "Linear")
						f2_b_ten = do ("Get bandwidth at time...", 2, time_ten, "Hertz", "Linear")
						f2_b_twenty = do ("Get bandwidth at time...", 2, time_twenty, "Hertz", "Linear")
						f2_b_thirty = do ("Get bandwidth at time...", 2, time_thirty, "Hertz", "Linear")
						f2_b_forty = do ("Get bandwidth at time...", 2, time_forty, "Hertz", "Linear")
						f2_b_fifty = do ("Get bandwidth at time...", 2, time_fifty, "Hertz", "Linear")
						f2_b_sixty = do ("Get bandwidth at time...", 2, time_sixty, "Hertz", "Linear")
						f2_b_seventy = do ("Get bandwidth at time...", 2, time_seventy, "Hertz", "Linear")
						f2_b_eighty = do ("Get bandwidth at time...", 2, time_eighty, "Hertz", "Linear")
						f2_b_ninety = do ("Get bandwidth at time...", 2, time_ninety, "Hertz", "Linear")
						f2_b_hundred = do ("Get bandwidth at time...", 2, time_hundred, "Hertz", "Linear")
						
						# f3 bandwidths
						f3_b_zero = do ("Get bandwidth at time...", 3, time_zero, "Hertz", "Linear")
						f3_b_ten = do ("Get bandwidth at time...", 3, time_ten, "Hertz", "Linear")
						f3_b_twenty = do ("Get bandwidth at time...", 3, time_twenty, "Hertz", "Linear")
						f3_b_thirty = do ("Get bandwidth at time...", 3, time_thirty, "Hertz", "Linear")
						f3_b_forty = do ("Get bandwidth at time...", 3, time_forty, "Hertz", "Linear")
						f3_b_fifty = do ("Get bandwidth at time...", 3, time_fifty, "Hertz", "Linear")
						f3_b_sixty = do ("Get bandwidth at time...", 3, time_sixty, "Hertz", "Linear")
						f3_b_seventy = do ("Get bandwidth at time...", 3, time_seventy, "Hertz", "Linear")
						f3_b_eighty = do ("Get bandwidth at time...", 3, time_eighty, "Hertz", "Linear")
						f3_b_ninety = do ("Get bandwidth at time...", 3, time_ninety, "Hertz", "Linear")
						f3_b_hundred = do ("Get bandwidth at time...", 3, time_hundred, "Hertz", "Linear")
						
					# 15% intervals
					elsif vowel_interval_type = 4
					
						# f1 values
						f1_twenty = do ("Get value at time...", 1, time_twenty, "Hertz", "Linear")
						f1_thirty_five = do ("Get value at time...", 1, time_thirty_five, "Hertz", "Linear")
						f1_thirty = do ("Get value at time...", 1, time_thirty, "Hertz", "Linear")
						f1_fifty = do ("Get value at time...", 1, time_fifty, "Hertz", "Linear")
						f1_sixty_five = do ("Get value at time...", 1, time_sixty_five, "Hertz", "Linear")
						f1_eighty = do ("Get value at time...", 1, time_eighty, "Hertz", "Linear")

						# f2 values
						f2_twenty = do ("Get value at time...", 2, time_twenty, "Hertz", "Linear")
						f2_thirty_five = do ("Get value at time...", 2, time_thirty_five, "Hertz", "Linear")
						f2_thirty = do ("Get value at time...", 2, time_thirty, "Hertz", "Linear")
						f2_fifty = do ("Get value at time...", 2, time_fifty, "Hertz", "Linear")
						f2_sixty_five = do ("Get value at time...", 2, time_sixty_five, "Hertz", "Linear")
						f2_eighty = do ("Get value at time...", 2, time_eighty, "Hertz", "Linear")
						
						# f3 values
						f3_twenty = do ("Get value at time...", 3, time_twenty, "Hertz", "Linear")
						f3_thirty_five = do ("Get value at time...", 3, time_thirty_five, "Hertz", "Linear")
						f3_thirty = do ("Get value at time...", 3, time_thirty, "Hertz", "Linear")
						f3_fifty = do ("Get value at time...", 3, time_fifty, "Hertz", "Linear")
						f3_sixty_five = do ("Get value at time...", 3, time_sixty_five, "Hertz", "Linear")
						f3_eighty = do ("Get value at time...", 3, time_eighty, "Hertz", "Linear")
						
						# f1 bandwidths
						f1_b_twenty = do ("Get bandwidth at time...", 1, time_twenty, "Hertz", "Linear")
						f1_b_thirty_five = do ("Get bandwidth at time...", 1, time_thirty_five, "Hertz", "Linear")
						f1_b_thirty = do ("Get bandwidth at time...", 1, time_thirty, "Hertz", "Linear")
						f1_b_fifty = do ("Get bandwidth at time...", 1, time_fifty, "Hertz", "Linear")
						f1_b_sixty_five = do ("Get bandwidth at time...", 1, time_sixty_five, "Hertz", "Linear")
						f1_b_eighty = do ("Get bandwidth at time...", 1, time_eighty, "Hertz", "Linear")
						
						# f2 bandwidths
						f2_b_twenty = do ("Get bandwidth at time...", 2, time_twenty, "Hertz", "Linear")
						f2_b_thirty_five = do ("Get bandwidth at time...", 2, time_thirty_five, "Hertz", "Linear")
						f2_b_thirty = do ("Get bandwidth at time...", 2, time_thirty, "Hertz", "Linear")
						f2_b_fifty = do ("Get bandwidth at time...", 2, time_fifty, "Hertz", "Linear")
						f2_b_sixty_five = do ("Get bandwidth at time...", 2, time_sixty_five, "Hertz", "Linear")
						f2_b_eighty = do ("Get bandwidth at time...", 2, time_eighty, "Hertz", "Linear")
						
						# f3 bandwidths
						f3_b_twenty = do ("Get bandwidth at time...", 3, time_twenty, "Hertz", "Linear")
						f3_b_thirty_five = do ("Get bandwidth at time...", 3, time_thirty_five, "Hertz", "Linear")
						f3_b_thirty = do ("Get bandwidth at time...", 3, time_thirty, "Hertz", "Linear")
						f3_b_fifty = do ("Get bandwidth at time...", 3, time_fifty, "Hertz", "Linear")
						f3_b_sixty_five = do ("Get bandwidth at time...", 3, time_sixty_five, "Hertz", "Linear")
						f3_b_eighty = do ("Get bandwidth at time...", 3, time_eighty, "Hertz", "Linear")
						
					#endif vowel_interval_type = 1
					endif
					
					# Remove formant object
					plusObject (current_formant)
					do ("Remove")
					
					# Get pitch
					selectObject (current_segment)
					noprogress do ("To Pitch...", pitch_time_step, minimum_pitch_vowels, maximum_pitch_vowels)
					
					
					vowel_mean_pitch = do ("Get mean...", time_zero, time_hundred, "Hertz")
					if  vowel_mean_pitch = undefined
						vowel_mean_pitch = -999
					endif
					vowel_minimum_pitch = do ("Get minimum...", time_zero, time_hundred, "Hertz", "Parabolic")
					if  vowel_minimum_pitch = undefined
						vowel_minimum_pitch = -999
					endif
					vowel_maximum_pitch = do ("Get maximum...", time_zero, time_hundred, "Hertz", "Parabolic")
					if  vowel_maximum_pitch = undefined
						vowel_maximum_pitch = -999
					endif
					
					#Remove pitch object
					do ("Remove")
					
					# Get intensity
					selectObject (current_segment)
					
					# According to Praat the duration of the sound in an intensity
					# analysis should be at least 6.4 divided by the minimum
					# pitch, therefore only measure intensity if this criterion 
					# is fulfilled. 100 Hz is the Praat standard setting.
					
					# Set up the dummy variable
					vowel_intensity_mean = -999
					
					if not tier_1_duration < 6.4/minimum_pitch_vowels
						do ("To Intensity...", 100, 0, "yes")
						vowel_intensity_mean = do ("Get mean...", time_zero, time_hundred, "dB")
								
					#endif not tier_1_duration < 6.4/minimum_pitch_consonants
					endif
					
					# Remove intensity object
					nocheck plus segment
					plus current_segment
					plus segment_resampled
					do ("Remove")
					
					########## Begin Write vowel measurements to tables ##########	
				
					# First check if a vowel output table exists, otherwise set it up.
				
					if table_vowel_file <> 0
					
						selectObject (table_vowel_file)
					
					# If the table does not exist, set it up.
					else
					
						########## Begin Setup the titlelines ##########
						
						titleline_bg_info_1$ = "token_id sound_name speaker_name style "
						
						titleline_tier_1_labels$ = "'tier_1_name$'_label stress 'tier_1_name$'_start 'tier_1_name$'_end 'tier_1_name$'_duration 'tier_1_name$'_left_1_label 'tier_1_name$'_left_1_duration 'tier_1_name$'_right_1_label 'tier_1_name$'_right_1_duration "
						
						# Set up dummies for the additional tiers to avoid error message
						titleline_tier_2_labels$ = ""
						titleline_tier_3_labels$ = ""
						titleline_tier_4_labels$ = ""
						
						if number_of_tiers > 1
							titleline_tier_2_labels$ = "'tier_2_name$'_label 'tier_2_name$'_start 'tier_2_name$'_end 'tier_2_name$'_duration 'tier_2_name$'_left_1_label 'tier_2_name$'_left_1_duration 'tier_2_name$'_right_1_label 'tier_2_name$'_right_1_duration "
						
						# endif number_of_tiers > 1
						endif
						
						if number_of_tiers > 2
							titleline_tier_3_labels$ = "'tier_3_name$'_label 'tier_3_name$'_start 'tier_3_name$'_end 'tier_3_name$'_duration 'tier_3_name$'_left_1_label 'tier_3_name$'_left_1_duration 'tier_3_name$'_right_1_label 'tier_3_name$'_right_1_duration "
						
						# endif number_of_tiers > 2
						endif
						
						if number_of_tiers > 3
							titleline_tier_4_labels$ = "'tier_4_name$'_label 'tier_4_name$'_start 'tier_4_name$'_end 'tier_4_name$'_duration 'tier_4_name$'_left_1_label 'tier_4_name$'_left_1_duration 'tier_4_name$'_right_1_label 'tier_4_name$'_right_1_duration "
						
						# endif number_of_tiers > 3
						endif
						
						titleline_bg_info_2$ = "analyser date script_name version"
					
						if vowel_interval_type = 1
							titleline_vowel_formants$ = "f1_twenty f1_fifty f1_eighty f2_twenty f2_fifty f2_eighty f3_twenty f3_fifty f3_eighty f1_b_twenty f1_b_fifty f1_b_eighty f2_b_twenty f2_b_fifty f2_b_eighty f3_b_twenty f3_b_fifty f3_b_eighty "
						elsif vowel_interval_type = 2
							titleline_vowel_formants$ = "f1_zero f1_five f1_ten f1_fifteen f1_twenty f1_twenty_five f1_thirty f1_thirty_five f1_forty f1_forty_five f1_fifty f1_fifty_five f1_sixty f1_sixty_five f1_seventy f1_seventy_five f1_eighty f1_eighty_five f1_ninety f1_ninety_five f1_hundred f2_zero f2_five f2_ten f2_fifteen f2_twenty f2_twenty_five f2_thirty f2_thirty_five f2_forty f2_forty_five f2_fifty f2_fifty_five f2_sixty f2_sixty_five f2_seventy f2_seventy_five f2_eighty f2_eighty_five f2_ninety f2_ninety_five f2_hundred f3_zero f3_five f3_ten f3_fifteen f3_twenty f3_twenty_five f3_thirty f3_thirty_five f3_forty f3_forty_five f3_fifty f3_fifty_five f3_sixty f3_sixty_five f3_seventy f3_seventy_five f3_eighty f3_eighty_five f3_ninety f3_ninety_five f3_hundred f1_b_zero f1_b_five f1_b_ten f1_b_fifteen f1_b_twenty f1_b_twenty_five f1_b_thirty f1_b_thirty_five f1_b_forty f1_b_forty_five f1_b_fifty f1_b_fifty_five f1_b_sixty f1_b_sixty_five f1_b_seventy f1_b_seventy_five f1_b_eighty f1_b_eighty_five f1_b_ninety f1_b_ninety_five f1_b_hundred f2_b_zero f2_b_five f2_b_ten f2_b_fifteen f2_b_twenty f2_b_twenty_five f2_b_thirty f2_b_thirty_five f2_b_forty f2_b_forty_five f2_b_fifty f2_b_fifty_five f2_b_sixty f2_b_sixty_five f2_b_seventy f2_b_seventy_five f2_b_eighty f2_b_eighty_five f2_b_ninety f2_b_ninety_five f2_b_hundred f3_b_zero f3_b_five f3_b_ten f3_b_fifteen f3_b_twenty f3_b_twenty_five f3_b_thirty f3_b_thirty_five f3_b_forty f3_b_forty_five f3_b_fifty f3_b_fifty_five f3_b_sixty f3_b_sixty_five f3_b_seventy f3_b_seventy_five f3_b_eighty f3_b_eighty_five f3_b_ninety f3_b_ninety_five f3_b_hundred "
						elsif vowel_interval_type = 3
							titleline_vowel_formants$ = "f1_zero f1_ten f1_twenty f1_thirty f1_forty f1_fifty f1_sixty f1_seventy f1_eighty f1_ninety f1_hundred f2_zero f2_ten f2_twenty f2_thirty f2_forty f2_fifty f2_sixty f2_seventy f2_eighty f2_ninety f2_hundred f3_zero f3_ten f3_twenty f3_thirty f3_forty f3_fifty f3_sixty f3_seventy f3_eighty f3_ninety f3_hundred f1_b_zero f1_b_ten f1_b_twenty f1_b_thirty f1_b_forty f1_b_fifty f1_b_sixty f1_b_seventy f1_b_eighty f1_b_ninety f1_b_hundred f2_b_zero f2_b_ten f2_b_twenty f2_b_thirty f2_b_forty f2_b_fifty f2_b_sixty f2_b_seventy f2_b_eighty f2_b_ninety f2_b_hundred f3_b_zero f3_b_ten f3_b_twenty f3_b_thirty f3_b_forty f3_b_fifty f3_b_sixty f3_b_seventy f3_b_eighty f3_b_ninety f3_b_hundred "
						elsif vowel_interval_type = 4
							titleline_vowel_formants$ = "f1_twenty f1_thirty_five f1_fifty f1_sixty_five f1_eighty f2_twenty f2_thirty_five f2_fifty f2_sixty_five f2_eighty f3_twenty f3_thirty_five f3_fifty f3_sixty_five f3_eighty f1_b_twenty f1_b_thirty_five f1_b_fifty f1_b_sixty_five f1_b_eighty f2_b_twenty f2_b_thirty_five f2_b_fifty f2_b_sixty_five f2_b_eighty f3_b_twenty f3_b_thirty_five f3_b_fifty f3_b_sixty_five f3_b_eighty "
							
						# endif vowel_interval_type = 1
						endif
						
						titleline_vowel_measurements$ = "vowel_mean_pitch vowel_minimum_pitch vowel_maximum_pitch vowel_intensity_mean "
						
						if use_the_formant_tracker = 1
							
							titleline_formant_tracker$ = "formant_tracker number_of_tracks f1_reference f2_reference f3_reference f4_reference f5_reference frequency_cost bandwidth_cost transition_cost "
							
						else	
						
							titleline_formant_tracker$ = "formant_tracker "
						
						# endif use_the_formant_tracker = 1
						endif
						
						header_vowels$ = titleline_bg_info_1$ + titleline_tier_1_labels$ + titleline_tier_2_labels$ + titleline_tier_3_labels$ + titleline_tier_4_labels$ + titleline_vowel_measurements$ + titleline_vowel_formants$ + titleline_formant_tracker$ + titleline_bg_info_2$
						
						########## End Setup the titlelines ##########
					
						do ("Create Table with column names...", "output_vowels", 0, header_vowels$)
						
						table_vowel_file = selected ("Table")
					
					# endif table_vowels_file = 0
					endif
					
					selectObject (table_vowel_file)
					do ("Append row")
					last_row_vowels = do ("Get number of rows")
				
					# Write bg_info_1
					do ("Set string value...", last_row_vowels, "token_id", string$(token_no) + "-" + analyser$)
					do ("Set string value...", last_row_vowels, "sound_name", soundname$)
					do ("Set string value...", last_row_vowels, "speaker_name", speakername$)
					do ("Set string value...", last_row_vowels, "style", style$)
					
					# Write tier_1_labels
					do ("Set string value...", last_row_vowels, "'tier_1_name$'_label", tier_1_label_2$)
					do ("Set numeric value...", last_row_vowels, "'tier_1_name$'_start", 'tier_1_start:3')
					do ("Set numeric value...", last_row_vowels, "'tier_1_name$'_end", 'tier_1_end:3')
					do ("Set numeric value...", last_row_vowels, "'tier_1_name$'_duration", 'tier_1_duration:1')
					do ("Set string value...", last_row_vowels, "'tier_1_name$'_left_1_label", tier_1_left_1_label_2$)
					do ("Set numeric value...", last_row_vowels, "'tier_1_name$'_left_1_duration", 'tier_1_left_1_duration:1')
					do ("Set string value...", last_row_vowels, "'tier_1_name$'_right_1_label", tier_1_right_1_label_2$)
					do ("Set numeric value...", last_row_vowels, "'tier_1_name$'_right_1_duration", 'tier_1_right_1_duration:1')
					
					if number_of_tiers > 1
					
						# Write tier_2_labels
						do ("Set string value...", last_row_vowels, "'tier_2_name$'_label", tier_2_label_2$)
						do ("Set numeric value...", last_row_vowels, "'tier_2_name$'_start", 'tier_2_start:3')
						do ("Set numeric value...", last_row_vowels, "'tier_2_name$'_end", 'tier_2_end:3')
						do ("Set numeric value...", last_row_vowels, "'tier_2_name$'_duration", 'tier_2_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_2_name$'_left_1_label", tier_2_left_1_label_2$)
						do ("Set numeric value...", last_row_vowels, "'tier_2_name$'_left_1_duration", 'tier_2_left_1_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_2_name$'_right_1_label", tier_2_right_1_label_2$)
						do ("Set numeric value...", last_row_vowels, "'tier_2_name$'_right_1_duration", 'tier_2_right_1_duration:1')
					
					# endif number_of_tiers > 1
					endif
					
					if number_of_tiers > 2
					
						# Write tier_3_labels
						do ("Set string value...", last_row_vowels, "'tier_3_name$'_label", tier_3_label_2$)
						do ("Set numeric value...", last_row_vowels, "'tier_3_name$'_start", 'tier_3_start:3')
						do ("Set numeric value...", last_row_vowels, "'tier_3_name$'_end", 'tier_3_end:3')
						do ("Set numeric value...", last_row_vowels, "'tier_3_name$'_duration", 'tier_3_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_3_name$'_left_1_label", tier_3_left_1_label$)
						do ("Set numeric value...", last_row_vowels, "'tier_3_name$'_left_1_duration", 'tier_3_left_1_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_3_name$'_right_1_label", tier_3_right_1_label$)
						do ("Set numeric value...", last_row_vowels, "'tier_3_name$'_right_1_duration", 'tier_3_right_1_duration:1')
					
					# endif number_of_tiers > 2
					endif
					
					if number_of_tiers > 3
					
						# Write tier_4_labels
						do ("Set string value...", last_row_vowels, "'tier_4_name$'_label", tier_4_label_2$)
						do ("Set numeric value...", last_row_vowels, "'tier_4_name$'_start", 'tier_4_start:3')
						do ("Set numeric value...", last_row_vowels, "'tier_4_name$'_end", 'tier_4_end:3')
						do ("Set numeric value...", last_row_vowels, "'tier_4_name$'_duration", 'tier_4_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_4_name$'_left_1_label", tier_4_left_1_label$)
						do ("Set numeric value...", last_row_vowels, "'tier_4_name$'_left_1_duration", 'tier_4_left_1_duration:1')
						do ("Set string value...", last_row_vowels, "'tier_4_name$'_right_1_label", tier_4_right_1_label$)
						do ("Set numeric value...", last_row_vowels, "'tier_4_name$'_right_1_duration", 'tier_4_right_1_duration:1')
					
					# endif number_of_tiers > 3
					endif
					
					# Write vowel measurements
					# Write stress, pitch and intensity
					do ("Set string value...", last_row_vowels, "stress", stress$)
					do ("Set numeric value...", last_row_vowels, "vowel_mean_pitch", 'vowel_mean_pitch:1')
					do ("Set numeric value...", last_row_vowels, "vowel_minimum_pitch", 'vowel_minimum_pitch:1')
					do ("Set numeric value...", last_row_vowels, "vowel_maximum_pitch", 'vowel_maximum_pitch:1')
					do ("Set numeric value...", last_row_vowels, "vowel_intensity_mean", 'vowel_intensity_mean:2')
									
					# Write formant and bandwidth data based on vowel interval type
					# 20/50/80%
					if vowel_interval_type = 1
					
						# f1 values
						do ("Set numeric value...", last_row_vowels, "f1_twenty", 'f1_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifty", 'f1_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_eighty", 'f1_eighty:0')
						
						# f2 values
						do ("Set numeric value...", last_row_vowels, "f2_twenty", 'f2_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifty", 'f2_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_eighty", 'f2_eighty:0')
						
						# f3 values
						do ("Set numeric value...", last_row_vowels, "f3_twenty", 'f3_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifty", 'f3_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_eighty", 'f3_eighty:0')
						
						# f1_b values
						do ("Set numeric value...", last_row_vowels, "f1_b_twenty", 'f1_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifty", 'f1_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_eighty", 'f1_b_eighty:0')
						
						# f2_b values
						do ("Set numeric value...", last_row_vowels, "f2_b_twenty", 'f2_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifty", 'f2_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_eighty", 'f2_b_eighty:0')
						
						# f3_b values
						do ("Set numeric value...", last_row_vowels, "f3_b_twenty", 'f3_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifty", 'f3_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_eighty", 'f3_b_eighty:0')
						
					# 5% intervals
					elsif vowel_interval_type = 2
						
						# f1 values
						do ("Set numeric value...", last_row_vowels, "f1_zero", 'f1_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f1_five", 'f1_five:0')	
						do ("Set numeric value...", last_row_vowels, "f1_ten", 'f1_ten:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifteen", 'f1_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f1_twenty", 'f1_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_twenty_five", 'f1_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_thirty", 'f1_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f1_thirty_five", 'f1_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_forty", 'f1_forty:0')
						do ("Set numeric value...", last_row_vowels, "f1_forty_five", 'f1_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifty", 'f1_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifty_five", 'f1_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f1_sixty", 'f1_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f1_sixty_five", 'f1_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_seventy", 'f1_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f1_seventy_five", 'f1_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_eighty", 'f1_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f1_eighty_five", 'f1_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_ninety", 'f1_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f1_ninety_five", 'f1_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_hundred", 'f1_hundred:0')
						
						# f2 values
						do ("Set numeric value...", last_row_vowels, "f2_zero", 'f2_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f2_five", 'f2_five:0')	
						do ("Set numeric value...", last_row_vowels, "f2_ten", 'f2_ten:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifteen", 'f2_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f2_twenty", 'f2_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_twenty_five", 'f2_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_thirty", 'f2_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f2_thirty_five", 'f2_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_forty", 'f2_forty:0')
						do ("Set numeric value...", last_row_vowels, "f2_forty_five", 'f2_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifty", 'f2_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifty_five", 'f2_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f2_sixty", 'f2_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f2_sixty_five", 'f2_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_seventy", 'f2_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f2_seventy_five", 'f2_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_eighty", 'f2_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f2_eighty_five", 'f2_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_ninety", 'f2_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f2_ninety_five", 'f2_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_hundred", 'f2_hundred:0')
					
						# f3 values
						do ("Set numeric value...", last_row_vowels, "f3_zero", 'f3_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f3_five", 'f3_five:0')	
						do ("Set numeric value...", last_row_vowels, "f3_ten", 'f3_ten:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifteen", 'f3_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f3_twenty", 'f3_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_twenty_five", 'f3_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_thirty", 'f3_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f3_thirty_five", 'f3_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_forty", 'f3_forty:0')
						do ("Set numeric value...", last_row_vowels, "f3_forty_five", 'f3_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifty", 'f3_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifty_five", 'f3_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f3_sixty", 'f3_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f3_sixty_five", 'f3_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_seventy", 'f3_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f3_seventy_five", 'f3_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_eighty", 'f3_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f3_eighty_five", 'f3_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_ninety", 'f3_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f3_ninety_five", 'f3_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_hundred", 'f3_hundred:0')
					
						# f1_b values
						do ("Set numeric value...", last_row_vowels, "f1_b_zero", 'f1_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f1_b_five", 'f1_b_five:0')	
						do ("Set numeric value...", last_row_vowels, "f1_b_ten", 'f1_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifteen", 'f1_b_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f1_b_twenty", 'f1_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_twenty_five", 'f1_b_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_thirty", 'f1_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f1_b_thirty_five", 'f1_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_forty", 'f1_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_forty_five", 'f1_b_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifty", 'f1_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifty_five", 'f1_b_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f1_b_sixty", 'f1_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_sixty_five", 'f1_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_seventy", 'f1_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_seventy_five", 'f1_b_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_eighty", 'f1_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_eighty_five", 'f1_b_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_ninety", 'f1_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_ninety_five", 'f1_b_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_hundred", 'f1_b_hundred:0')
						
						# f2_b values
						do ("Set numeric value...", last_row_vowels, "f2_b_zero", 'f2_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f2_b_five", 'f2_b_five:0')	
						do ("Set numeric value...", last_row_vowels, "f2_b_ten", 'f2_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifteen", 'f2_b_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f2_b_twenty", 'f2_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_twenty_five", 'f2_b_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_thirty", 'f2_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f2_b_thirty_five", 'f2_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_forty", 'f2_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_forty_five", 'f2_b_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifty", 'f2_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifty_five", 'f2_b_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f2_b_sixty", 'f2_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_sixty_five", 'f2_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_seventy", 'f2_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_seventy_five", 'f2_b_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_eighty", 'f2_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_eighty_five", 'f2_b_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_ninety", 'f2_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_ninety_five", 'f2_b_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_hundred", 'f2_b_hundred:0')
						
						# f3_b values
						do ("Set numeric value...", last_row_vowels, "f3_b_zero", 'f3_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f3_b_five", 'f3_b_five:0')	
						do ("Set numeric value...", last_row_vowels, "f3_b_ten", 'f3_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifteen", 'f3_b_fifteen:0')	
						do ("Set numeric value...", last_row_vowels, "f3_b_twenty", 'f3_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_twenty_five", 'f3_b_twenty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_thirty", 'f3_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f3_b_thirty_five", 'f3_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_forty", 'f3_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_forty_five", 'f3_b_forty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifty", 'f3_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifty_five", 'f3_b_fifty_five:0')							
						do ("Set numeric value...", last_row_vowels, "f3_b_sixty", 'f3_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_sixty_five", 'f3_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_seventy", 'f3_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_seventy_five", 'f3_b_seventy_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_eighty", 'f3_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_eighty_five", 'f3_b_eighty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_ninety", 'f3_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_ninety_five", 'f3_b_ninety_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_hundred", 'f3_b_hundred:0')
						
					# 10% intervals
					elsif vowel_interval_type = 3
						
						# f1 values
						do ("Set numeric value...", last_row_vowels, "f1_zero", 'f1_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f1_ten", 'f1_ten:0')
						do ("Set numeric value...", last_row_vowels, "f1_twenty", 'f1_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_thirty", 'f1_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f1_forty", 'f1_forty:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifty", 'f1_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_sixty", 'f1_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f1_seventy", 'f1_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f1_eighty", 'f1_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f1_ninety", 'f1_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f1_hundred", 'f1_hundred:0')
						
						# f2 values
						do ("Set numeric value...", last_row_vowels, "f2_zero", 'f2_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f2_ten", 'f2_ten:0')
						do ("Set numeric value...", last_row_vowels, "f2_twenty", 'f2_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_thirty", 'f2_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f2_forty", 'f2_forty:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifty", 'f2_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_sixty", 'f2_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f2_seventy", 'f2_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f2_eighty", 'f2_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f2_ninety", 'f2_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f2_hundred", 'f2_hundred:0')
					
						# f3 values
						do ("Set numeric value...", last_row_vowels, "f3_zero", 'f3_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f3_ten", 'f3_ten:0')
						do ("Set numeric value...", last_row_vowels, "f3_twenty", 'f3_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_thirty", 'f3_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f3_forty", 'f3_forty:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifty", 'f3_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_sixty", 'f3_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f3_seventy", 'f3_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f3_eighty", 'f3_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f3_ninety", 'f3_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f3_hundred", 'f3_hundred:0')
					
						# f1_b values
						do ("Set numeric value...", last_row_vowels, "f1_b_zero", 'f1_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f1_b_ten", 'f1_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_twenty", 'f1_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_thirty", 'f1_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f1_b_forty", 'f1_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifty", 'f1_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_sixty", 'f1_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_seventy", 'f1_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_eighty", 'f1_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_ninety", 'f1_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_hundred", 'f1_b_hundred:0')
						
						# f2_b values
						do ("Set numeric value...", last_row_vowels, "f2_b_zero", 'f2_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f2_b_ten", 'f2_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_twenty", 'f2_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_thirty", 'f2_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f2_b_forty", 'f2_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifty", 'f2_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_sixty", 'f2_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_seventy", 'f2_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_eighty", 'f2_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_ninety", 'f2_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_hundred", 'f2_b_hundred:0')
						
						# f3_b values
						do ("Set numeric value...", last_row_vowels, "f3_b_zero", 'f3_b_zero:0')		
						do ("Set numeric value...", last_row_vowels, "f3_b_ten", 'f3_b_ten:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_twenty", 'f3_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_thirty", 'f3_b_thirty:0')	
						do ("Set numeric value...", last_row_vowels, "f3_b_forty", 'f3_b_forty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifty", 'f3_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_sixty", 'f3_b_sixty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_seventy", 'f3_b_seventy:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_eighty", 'f3_b_eighty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_ninety", 'f3_b_ninety:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_hundred", 'f3_b_hundred:0')	
						
					elsif vowel_interval_type = 4
						
						# f1 values
						do ("Set numeric value...", last_row_vowels, "f1_twenty", 'f1_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_thirty_five", 'f1_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_fifty", 'f1_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_sixty_five", 'f1_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_eighty", 'f1_eighty:0')
						
						# f2 values
						do ("Set numeric value...", last_row_vowels, "f2_twenty", 'f2_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_thirty_five", 'f2_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_fifty", 'f2_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_sixty_five", 'f2_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_eighty", 'f2_eighty:0')
	
						# f3 values
						do ("Set numeric value...", last_row_vowels, "f3_twenty", 'f3_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_thirty_five", 'f3_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_fifty", 'f3_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_sixty_five", 'f3_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_eighty", 'f3_eighty:0')
					
						# f1 bandwidthds
						do ("Set numeric value...", last_row_vowels, "f1_b_twenty", 'f1_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_thirty_five", 'f1_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_fifty", 'f1_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_sixty_five", 'f1_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f1_b_eighty", 'f1_b_eighty:0')
					
						# f2 bandwidthds
						do ("Set numeric value...", last_row_vowels, "f2_b_twenty", 'f2_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_thirty_five", 'f2_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_fifty", 'f2_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_sixty_five", 'f2_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f2_b_eighty", 'f2_b_eighty:0')
						
						# f3 bandwidthds
						do ("Set numeric value...", last_row_vowels, "f3_b_twenty", 'f3_b_twenty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_thirty_five", 'f3_b_thirty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_fifty", 'f3_b_fifty:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_sixty_five", 'f3_b_sixty_five:0')
						do ("Set numeric value...", last_row_vowels, "f3_b_eighty", 'f3_b_eighty:0')
					
					#endif vowel_interval_type = 1
					endif
					
					# Write the formant tracker data
					
					if use_the_formant_tracker = 1 and gender$ = "male"
						
						do ("Set string value...", last_row_vowels, "formant_tracker", "yes")
						do ("Set numeric value...", last_row_vowels, "number_of_tracks", 'number_of_tracks:0')
						do ("Set numeric value...", last_row_vowels, "f1_reference", 'left_F1_reference:0')
						do ("Set numeric value...", last_row_vowels, "f2_reference", 'left_F2_reference:0')
						do ("Set numeric value...", last_row_vowels, "f3_reference", 'left_F3_reference:0')
						do ("Set numeric value...", last_row_vowels, "f4_reference", 3465)
						do ("Set numeric value...", last_row_vowels, "f5_reference", 4455)
						do ("Set numeric value...", last_row_vowels, "frequency_cost", 'left_Frequency_cost:2')
						do ("Set numeric value...", last_row_vowels, "bandwidth_cost", 'left_Bandwidth_cost:2')
						do ("Set numeric value...", last_row_vowels, "transition_cost", 'left_Transition_cost:2')
						
					elsif use_the_formant_tracker = 1 and gender$ = "female"
						
						do ("Set string value...", last_row_vowels, "formant_tracker", "yes")
						do ("Set numeric value...", last_row_vowels, "number_of_tracks", 'number_of_tracks:0')
						do ("Set numeric value...", last_row_vowels, "f1_reference", 'right_F1_reference:0')
						do ("Set numeric value...", last_row_vowels, "f2_reference", 'right_F2_reference:0')
						do ("Set numeric value...", last_row_vowels, "f3_reference", 'right_F3_reference:0')
						do ("Set numeric value...", last_row_vowels, "f4_reference", 3850)
						do ("Set numeric value...", last_row_vowels, "f5_reference", 4950)
						do ("Set numeric value...", last_row_vowels, "frequency_cost", 'right_Frequency_cost:2')
						do ("Set numeric value...", last_row_vowels, "bandwidth_cost", 'right_Bandwidth_cost:2')
						do ("Set numeric value...", last_row_vowels, "transition_cost", 'right_Transition_cost:2')
					
					else
					
						do ("Set string value...", last_row_vowels, "formant_tracker", "no")
				
					# endif use_the_formant_tracker = 1 and gender$ = "male"
					endif
					
					# Write the bg_info_2
					do ("Set string value...", last_row_vowels, "analyser", analyser$)
					do ("Set string value...", last_row_vowels, "date", date$)
					do ("Set string value...", last_row_vowels, "script_name", script_name$)
					do ("Set string value...", last_row_vowels, "version", version$)
					
				########## End Write vowel measurements to table ##########
			
				########## End Collect a range of vowel measurements ##########
							
				########## End Write measurements to tables ##########				
				
				# Set up the new token id
				token_no = token_no + 1
				token_no_new = token_no
	
			# endif index (vowel_labels$, " " + tier_1_label_2$ + " ")
			endif
			
			selectObject (textgrid)
		
		# endfor interval_tier_1 from 1 to number_of_intervals_tier_1
		endfor
		
		########## End Carry out analyses based on tier 1 ##########
		
		selectObject (table_tokens)
		do ("Set numeric value...", 1, "token_no", token_no_new)
		
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

# Write the result of the table objects to the respective files
selectObject (table_tokens)
do ("Save as tab-separated file...", tokenfile$)

selectObject (table_vowel_file)
do ("Save as tab-separated file...", vowel_outputfile$)
 
selectObject (string_of_sound_files)
plus table_tokens
plus table_vowel_file

do ("Remove")

writeInfo ()
writeInfoLine ("Done!")
appendInfoLine ("")
appendInfoLine ("The results for the vowels analysis have been written to 'newline$''vowel_outputfile$'")
