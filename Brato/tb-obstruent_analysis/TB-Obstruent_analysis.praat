###############################################################################
# 
# Author: Thorsten Brato
# Mail: Thorsten.Brato@phil.tu-chemnitz.de
# Script name: TB-Obstruent analysis.praat
# Version: [2016:07:06]
# This script is distributed under the GNU General Public License 
# (http://www.gnu.org/licenses/gpl.txt).
# Copyright 25/04/2014 by Thorsten Brato.
#
# Description:
# This script collects a large range of measurements relevant for the acoustic
# study of plosives and affricates (and to some degree also fricatives)
# and outputs them to a .txt that can be subjected to further analysis in
# e.g. Excel or R.
#
# This script was developed for Praat 5.3.44 and newer in the context of a
# study on the realisation of /t/ in Ghanaian English, but should be 
# applicable to more general research contexts. I tried to annotate it 
# extensively, so that other users can adopt, adapt and improve it according
# to their needs. It comes without any warranty.
#
# Requirements:
# - The script comes in a folder with three other more general scripts
#   (TB-change_channel_and_sampling_frequency.praat, 
#	TB-file_data_extraction.praat and TB-tier_data_extraction.praat) that it
#   requires to run. Therefore you should always keep these files together.
# - Sound (default: .wav) and TextGrid (default: .TextGrid) pairs, i.e. files
#   with the same name, e.g. 'speaker1.wav' and 'speaker1.TextGrid'. Note that
# 	Praat is case-sensitive and differentiates between .wav and .WAV. If you
#   want to use different file extensions, either change the default in the 
#	"Set up a couple of parameters section" or uncomment (remove the #) the
#	respective lines in Form 1, in which case you must comment the defaults in
# 	the section below.
# - The script can collect and output the data from up to four tiers in a
#	TextGrid (see the description in the 'tier data extraction' script on how
#	to collect more data. This would also require some changes in the current
#	script.)
# - Tiers must be ordered from smallest unit to largest unit as the main 
# 	acoustic analyses are only applied to the first tier. Tier 1 should contain
# 	the 'phone' data, i.e. it should be the most detailed segmentation into
#	phonetic elements. Let us illustrate this with an example. The realisation
#	of the phoneme /t/ can be separated in three phases, the approach, the hold
# 	and the release phases. Most of the time, only little happens in the 
#	approach phase, but preaspiration or preglottalisation may occur. I code
# 	these as 't_pa' and 't_pg' respectively. This is followed by the hold phase
#	which I code as 't'. The release phase may be characterised by aspiration 
#	or affrication for example. I code these as 't_as' and 't_af' respectively.
#	In the form this is referred to as 'Pre-phase labels' 'Hold phase labels'
#	and 'Release phase labels' respectively. Tier 2 contains the 'phoneme'
#	data. Using our /t/ example this would mean that there is only a single
#	interval spanning the duration of the three intervals above. Since it is 
#	cumbersome and error-prone to do this manually, I wrote another script 
#	(TB-Create_tier-praat) which does this for you automatically. Tier 3
#	can for example contain syllable or word information and tier 4 may be used
#	for even larger units such as intonational phrase or for comments.
#
# Usage:
# Once you have prepared the data, you can open the script from the Praat
# objects window. All major settings can be changed in a series of forms.
# Meaningful defaults (for my research purposes) are set, but feel free to 
# change them according to your needs.
# Form 1 is for the basic settings:
# - Directories in which the sound and TextGrids you want to analyse are
#	located.
# - The path (including the file name) to the output file. For the script
#	to work, the folder has to exist, the file will be created if it does not
#	exist. If a file already exists, the default is that the new data is just
#	attached, therefore you should make sure that all files have the same
#	structure with regard to tier names and number of tiers. If you tick the
#	box for overwriting the output file, the existing file will be deleted and
#	the data is written to a new file.
# - The path (including the file name) to the token file. The token file is 
#	a small text file that we use to make sure that every measurement gets a
#	unique id.
# - If you want to temporarily convert stereo files to mono files, you should
#	tick the final box.

# Form 2 is used to provide the labels you have used to code the individual 
# variants that you want the script to measure. I use the following pattern:
# Pre-phase labels:
# - pa: preaspirated
# - pg: preglottalised
# - pv: prevoiced
#
# Hold phase, as well as fricative and affricate labels should be self-
# explanatory.
#
# Release phase labels:
# - af: affricated
# - as: aspirated
# - ej: ejective
# - el: elided
# - fr: partly or fully fricated
# - gs: glottalled/glottalised
# - ua: unaspirated
# - ur: unreleased
#
# I use lexical set labels for my vowels. The labels are set up in the 
# 'vowel_labels$' variable below. If you untick the box, a form will pop up
# for you to enter the vowel labels (see below).
#
# Form 3 is used to set up the measurement settings. You can downsample, set 
# the pitch settings for intensity measurements, preemphasise the sound prior 
# to spectral moments analysis and filter. The default settings work for my 
# purposes, but you may want to change them based on experience or other
# recommendations in the literature.
#
# Form 4 will only show up if you unticked the lexical set box above and allows
# you to enter your vowel labels manually.
#
###############################################################################

########## Begin Forms ##########

########## Begin Form 1 ##########

# This form is for the basic settings applying to all the data
form Basic settings
	comment Directory of sound files (top) and textgrids (bottom) with final slash:
	# never forget the trailing slash for the script to work!
	text sound_directory: T:\Forschungsprojekte\Ghana 2012\TB-Data\Sounds & Textgrids\WL\
	# See comment below the form.
	# comment Sound file extension:
	# sentence Sound_file_extension .wav
	
	#comment Directory of TextGrid files with final slash:			
	# never forget the trailing slash for the script to work!
	text textGrid_directory T:\Forschungsprojekte\Ghana 2012\TB-Data\Sounds & Textgrids\WL\
	# See comment below the form.
	# comment TextGrid file extension:
	# sentence TextGrid_file_extension .TextGrid
	
	comment Path to (existing) output file :
	text consonant_outputfile T:\Forschungsprojekte\Ghana 2012\TB-Data\Tokens & Output\output_obstruents.txt
	
	comment Path to (existing) token file :
	text tokenfile T:\Forschungsprojekte\Ghana 2012\TB-Data\Tokens & Output\tokens.txt
	
	comment Overwrite existing output files or append?
	boolean Overwrite_output_files 0
	
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

########## Begin Form 2 ##########

# The first consonant form sets up which consonants to measure
beginPause ("Consonant settings 1")

	# Set up which consonants to analyse.
	comment ("Which consonants do you want to analyse?")
	comment ("The script recognises three kinds of labels to code plosives for the pre-, hold and release phases.")
	comment ("Use the following format: label1 label2 label3 ... or leave empty to not analyse this group")
	comment ("Plosive labels")
	# The following refers to elements such as pre-aspiration or pre-glottalisation.
	comment ("Pre-phase labels")
	text ("plosive_pre_labels", " b_pa b_pg b_pv d_pa d_pg d_pv g_pa g_pg g_pv p_pa p_pg p_pv t_pa t_pg t_pv k_pa k_pg k_pv ")
	comment ("Hold phase labels")
	text ("plosive_hold_labels", " b d g p t k ")
	comment ("Release phase labels")
	text ("plosive_release_labels", "b_af b_as b_ej b_el b_fr b_gs b_ua b_ur d_af d_as d_ej d_el d_fr d_gs d_ua d_ur g_af g_as g_ej g_el g_fr g_gs g_ua g_ur t_af t_as t_ej t_el t_fr t_gs t_ua t_ur k_af k_as k_ej k_el k_fr k_gs k_ua k_ur ")
	
	comment ("Fricative labels")
	text ("fricative_labels", " s sh ")
	
	comment ("Affricate labels")
	text ("affricate_labels", " tsh ")
	
	# Are the vowels labelled as lexical sets and do you want to use these? This is needed to calculate relative intensity.
	comment ("Use lexical set labels for vowels?")
	boolean ("Use_lexical_sets", 1)

consonant_1_continue = endPause ("Continue", 1)

########## End Form 2 ##########

if consonant_1_continue = 1
	
	plosive_pre_labels$ = " " + plosive_pre_labels$ + " "
	plosive_hold_labels$ = " " + plosive_hold_labels$ + " "
	plosive_release_labels$ = " " + plosive_release_labels$ + " "
	# Create a variable containing all the plosive labels
	plosive_labels$ = plosive_pre_labels$ + plosive_hold_labels$ + plosive_release_labels$
	fricative_labels$ = " " + fricative_labels$ + " "
	affricate_labels$ = " " + affricate_labels$ + " "
	# Create a variable containing all the consonant labels
	consonant_labels$ = plosive_labels$ + fricative_labels$ + affricate_labels$
	
# endif consonant_1_continue = 1
endif

########## Begin Form 3 ##########
	# 
	beginPause ("Consonant settings 2")
	
		# Change the sampling rate? The sampling rate should be at least twice the maximum frequency chosen for analysis.
		comment ("Downsample prior to analysis?")
		comment ("(Only applies if the sampling rate is higher. Type in 0 to keep original sampling frequency.)")
		integer ("Downsample to (Hz)", 22050)
		
		# Set up minimum pitch for intensity measurements
		comment ("Minimum pitch for intensity measurements:")
		integer ("Minimum pitch", 500)
		
		#Preemphasise and downsample the file before spectral moments analysis?
		comment ("Preemphasise the file before spectral moments analysis")
		comment ("(Type in 0 to analyse the unemphasised sound.)")
		integer ("Preemphasis (Hz)", 80)
		
		#Filter prior to the analyis?
		comment ("Apply a pass Hann band to the segments prior to the analysis?")
		comment ("(Type in 0 in any of the three fields to analyse the unfiltered sound.)")
		integer ("Minimum frequency (Hz)", 100)
		integer ("Maximum frequency (Hz)", 9500)
		integer ("Smoothing (Hz)", 30)
	
	consonant_2_continue = endPause ("Continue", 1)
	
	########## End Form 3 ##########
	
	downsample_to = downsample_to
	minimum_pitch_intensity = minimum_pitch
	preemphasis_consonant = preemphasis
	filter_minimum_frequency = minimum_frequency
	filter_maximum_frequency = maximum_frequency
	filter_smoothing = smoothing
	
	
if use_lexical_sets = 1

	vowel_labels$ = " kit dress trap lot strut foot bath cloth nurse fleece face palm thought goat goose price choice mouth near square start north force cure happy letter comma horses use "
	
else
	
	########## Begin Form 4 ##########
	
	# If the user chooses to not use lexical set labels show a form for inputting the labels.
	
	beginPause ("Vowel labels")
	
		comment ("Use the following format: label1 label2 label3 ...")
		text ("vowel_labels", "AH IJ ...")
		
	vowel_labels_continue = endPause ("Continue", 1)
	
	if vowel_labels_continue = 1
	
		vowel_labels$ = " " + vowel_labels$ + " "
	
	# endif vowel_labels_continue = 1
	endif
	
	########## End Form 4 ##########
	
# endif use_lexical_sets = 1
endif

########## End Forms ##########

########## Begin Set up a couple of parameters ##########

script_name$ = "TB-Obstruent_analysis"
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

date$ = year$ + "/" + month$ + "/" + day$ 

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

if fileReadable (consonant_outputfile$)
	do ("Read Table from tab-separated file...", consonant_outputfile$)
	
	table_consonant_file = selected ("Table")
	
	if overwrite_output_files = 1
	beginPause ("Overwrite output files")
	comment ("The consonant output file already exists.")
	comment ("Are you really sure you want to overwrite it.")
	overwrite_consonant_output = endPause ("Keep file and append new data", "Overwrite", 1)
	
		if overwrite_consonant_output = 2 
			deleteFile (consonant_outputfile$)
		
			# if the file was deleted, create dummy 
			table_consonant_file = 0
		
		#endif overwrite_consonant_output = 2
		endif
	
	# endif overwrite_output_files = 1
	endif	

else

	# if the file does not exist, create dummy 
	table_consonant_file = 0
	
# endif fileReadable (consonant_file$)
endif

########## End Load the tables if they exist. Otherwise set up the tokens table. ##########

# Index all sound files in the sound directory set up above
do ("Create Strings as file list...", "list", sound_directory$ + "*" + sound_file_extension$) 
string_of_sound_files = selected ("Strings")
number_of_files = do ("Get number of strings")

# Message to user
writeInfo()
writeInfoLine("Analysis started. Please be patient.")
appendInfoLine("")
########## Begin Loop that goes through every file in the input directory ##########
for file_number to number_of_files
	
	# Get the filename
	filename$ = do$ ("Get string...", file_number)
	
	# Open it as a long sound file
	do ("Open long sound file...", sound_directory$ + filename$)
	longsound = selected ("LongSound")
	
	# Tell the user which file is being analysed
	appendInfoLine ("Analysing 'filename$'")
	
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
			
			if index (consonant_labels$, " " + tier_1_label_2$ + " ")
			
				# Set up some variables we'll need below
				segment_mono = 0
				segment_resampled = 0
				segment_filter = 0
								
				########## Begin Collect the relevant interval data ##########
				
# Load the tier data extraction script
include TB-tier_data_extraction.praat
	
				########## End Collect the relevant interval data ##########
				
				
				########## Begin Change number of channels and change sampling frequency ##########
				
# Load the channel and sampling frequency script
include TB-change_channel_and_sampling_frequency.praat
				
				########## End Change number of channels and change sampling frequency ##########
				
				########## Begin Collect a range of consonant measurements ##########
				
				# Get the number of the current sound to select below
				current_segment = selected ("Sound")
				
				# Set up the dummy variables
				plosive_phone_relative_duration = -999
				plosive_phoneme_relative_duration_preceding = -999
				plosive_phoneme_relative_duration_following = -999
				
				########## Begin Calculate some relative durations for the consonants ##########
					
				# If the label is one of the plosives, get the relative duration of the phones to the phoneme and phoneme to preceding/following phoneme
				if index (plosive_labels$, " " + tier_1_label_2$ + " ")
				
					plosive_phone_relative_duration = tier_1_duration / tier_2_duration
					
					if tier_2_left_1_label$ <> "empty"
					
						plosive_phoneme_relative_duration_preceding = tier_2_duration / tier_2_left_1_duration
					
					# endif tier_2_left_1_label$ <> "empty"
					endif
					
					if tier_2_right_1_label$ <> "empty"
					
						plosive_phoneme_relative_duration_following = tier_2_duration / tier_2_right_1_duration
						
					# endif tier_2_right_1_label$ <> "empty"
					endif
				
				# endif index (plosive_labels$, " " + tier_1_label_2$ + " ") and tier_2_name$ = "phoneme"
				endif	
					
				########## End Calculate some relative durations for the consonants ##########
				
				# Get intensity for the consonant
				# According to Praat the duration of the sound in an intensity analysis should be 
				# at least 6.4 divided by the minimum pitch, therefore only measure intensity if
				# this criterion is fulfilled. 100 Hz is the Praat standard setting. I follow Smith
				# (2012) who suggests 500 Hz.
				
				# Set up the dummy variables
				consonant_intensity_mean_all = -999
				consonant_intensity_mean_fifty = -999
				consonant_intensity_maximum_all = -999
				consonant_intensity_maximum_fifty = -999
				consonant_rise_time = -999
				burst_intensity = -999
				relative_burst_intensity_all = -999
				relative_burst_intensity_fifty = -999
			
				if not tier_1_duration < 6.4/minimum_pitch_intensity
					intensity = do ("To Intensity...", minimum_pitch_intensity, 0, "yes")
							
					# Get mean intensity for the whole consonant and the central 50%
					consonant_intensity_mean_all = do ("Get mean...", time_zero, time_hundred, "dB")
					consonant_intensity_mean_fifty = do ("Get mean...", time_twenty_five, time_seventy_five, "dB")
					
					# Get maximum intensity for the whole consonant and the central 50%
					consonant_intensity_maximum_all = do ("Get maximum...", time_zero, time_hundred, "Parabolic")
					consonant_intensity_maximum_fifty = do ("Get maximum...", time_twenty_five, time_seventy_five, "Parabolic")
					
					# Get rise time for the whole consonant and the central 50%
					consonant_rise_time = do ("Get time of maximum...", time_zero, time_hundred, "Parabolic")
					
					# Get the burst intensity
					# Burst intensity is measured at the plosive release unless the plosive is followed by /s/ when it is measured at the end of the hold phase.
					if index (plosive_release_labels$, " " + tier_1_label$ + " ")
						burst_intensity = do ("Get mean...", time_zero, time_zero+0.02, "dB")
						relative_burst_intensity_all = burst_intensity/consonant_intensity_mean_all
						relative_burst_intensity_fifty = burst_intensity/consonant_intensity_mean_fifty
						
					elsif index (plosive_hold_labels$, " " + tier_1_label$ + " ") and tier_1_right_1_label$ = "s"
						burst_intensity = do ("Get mean...", time_hundred, time_hundred+0.02, "dB")
						relative_burst_intensity_all = burst_intensity/consonant_intensity_mean_all
						relative_burst_intensity_fifty = burst_intensity/consonant_intensity_mean_fifty	
					# endif index (plosive_hold_labels$, " " + tier_1_label$ + " ")
					endif
					
					# Remove intensity object
					do ("Remove")
					
				#endif not tier_1_duration < 6.4/minimum_pitch_consonants
				endif
				
				# Get the number of zero crossings per interval and calculate ZCR
				selectObject (current_segment)
				do ("To PointProcess (zeroes)...", 1, "yes", "no")
				zcs= Get number of points
				
				#Zero crossing rate per second
				zcr = (zcs/tier_1_duration) *1000
			
				# Remove PointProcess object
				do ("Remove")
				
				# Preemphasise and filter the segment for the spectrum analyses
				selectObject (current_segment)
				
				# Preemphasise the sound as set in the form
				if preemphasis_consonant <> 0
					segment_preemphasis = do ("Filter (pre-emphasis)...", preemphasis_consonant)
				# endif preemphasis_consonant <> 0
				endif
				
				# Create a sound with a Hann pass filter of minimum frequency
				# to maximum frequency and smoothing as set in the form.
				if filter_minimum_frequency <> 0 and filter_maximum_frequency <> 0 and filter_smoothing <> 0
					segment_filter = Filter (pass Hann band)... filter_minimum_frequency filter_maximum_frequency filter_smoothing
					filter$ = "yes"
				else
					filter$ = "no"
					filter_minimum_frequency = 0 
					filter_maximum_frequency = 0 
					filter_smoothing = 0
				#endif minimum_frequency <> 0 and maximum_frequency <> 0 and smoothing <> 0
				endif
				
				nocheck segment_spectrum = do ("Extract part...", time_twenty_five, time_seventy_five, "rectangular", 1, "yes")
				spectrum = do ("To Spectrum...", "yes")
				cog = do ("Get centre of gravity...", 2)
				sd = do ("Get standard deviation...", 2)
				skewness = do ("Get skewness...", 2)
				kurtosis = do ("Get kurtosis...", 2)
				
				#Remove spectrum and related sounds
				nocheck plus segment_spectrum
				nocheck plus segment_preemphasis
				nocheck plus segment_filter
				nocheck plus segment_resampled
				nocheck plus current_segment
				do ("Remove")
				
				# Extract the previous and following segments on tier 2 if it is a vowel
				
				# Set up the dummy variables
				vowel_preceding_intensity_mean_all = -999
				vowel_preceding_intensity_mean_fifty = -999
				
				if interval_tier_2_left_1 <> 0 and index (vowel_labels$, " " + tier_2_left_1_label_2$ + " ")
					
					selectObject (longsound)
					# Extract the previous segment on tier 2 for further analysis
					segment_tier2_left_1 = do ("Extract part...", tier_2_left_1_start-margin, tier_2_left_1_end+margin, "yes")
					
					# Check if the segment is stereo and change to mono if selected in the form
					if number_of_channels = 2 and convert_to_mono = 1
					segment_tier2_left_1_mono = do ("Convert to mono")
			
					# endif number_of_channels = 2 and convert_to_mono = 1
					endif
						
					# Here we take the Praat standard settings of 100 Hz
					if not tier_2_left_1_duration < 6.4/100
					intensity = do ("To Intensity...", 100, 0, "yes")
					
					vowel_preceding_intensity_mean_all = do ("Get mean...", time_zero, time_hundred, "dB")
					
					if vowel_preceding_intensity_mean_all = undefined
						
						vowel_preceding_intensity_mean_all = -999
					
					# endif vowel_preceding_intensity_mean_all = undefined
					endif
					
					vowel_preceding_intensity_mean_fifty = do ("Get mean...", time_twenty_five, time_seventy_five, "dB")
					
					if vowel_preceding_intensity_mean_fifty = undefined
						
						vowel_preceding_intensity_mean_fifty = -999
					
					# endif vowel_preceding_intensity_mean_fifty = undefined
					endif
					
					# Remove intensity object and segment
					plus segment_tier2_left_1
					do ("Remove")
					
					# endif not tier_2_left_1_duration < 6.4/100
					endif
				
				# endif interval_tier_2_left_1 <> 0 and index (vowel_labels$, " " + tier_2_left_1_label_2$ + " ")
				endif
				
				### EDIT 
				vowel_following_intensity_mean_all = -999
				vowel_following_intensity_mean_fifty = -999
				
				if interval_tier_2_right_1 <> 0 and index (vowel_labels$, " " + tier_2_right_1_label_2$ + " ")
					
					selectObject (longsound)
					# Extract the following segment on tier 2 for further analysis
					segment_tier2_right_1 = do ("Extract part...", tier_2_right_1_start-margin, tier_2_right_1_end+margin, "yes")
					
					# Check if the segment is stereo and change to mono if selected in the form
					if number_of_channels = 2 and convert_to_mono = 1
					segment_tier2_right_1_mono = do ("Convert to mono")
			
					# endif number_of_channels = 2 and convert_to_mono = 1
					endif
						
					# Here we take the Praat standard settings of 100 Hz
					if not tier_2_right_1_duration < 6.4/100
					intensity = do ("To Intensity...", 100, 0, "yes")
					
					vowel_following_intensity_mean_all = do ("Get mean...", time_zero, time_hundred, "dB")
					
					if vowel_following_intensity_mean_all = undefined
						
						vowel_following_intensity_mean_all = -999
					
					# endif vowel_following_intensity_mean_all = undefined
					endif
					
					vowel_following_intensity_mean_fifty = do ("Get mean...", time_twenty_five, time_seventy_five, "dB")
					
					if vowel_following_intensity_mean_fifty = undefined
						
						vowel_following_intensity_mean_fifty = -999
					
					# endif vowel_following_intensity_mean_fifty = undefined
					endif
					
					# Remove intensity object and segment
					plus segment_tier2_right_1
					do ("Remove")
					
					# endif not tier_2_right_1_duration < 6.4/100
					endif
				
				# endif interval_tier_2_right_1 <> 0 and index (vowel_labels$, " " + tier_2_right_1_label_2$ + " ")
				endif
				
				########## Begin Write consonant measurements to tables ##########	
			
				# First check if a consonant output table exists, otherwise set it up.
			
				if table_consonant_file <> 0
				
					selectObject (table_consonant_file)
				
				# If the table does not exist, set it up.
				else
				
					########## Begin Setup the titlelines ##########
					
					titleline_bg_info_1$ = "token_id sound_name speaker_name style "
					
					titleline_tier_1_labels$ = "'tier_1_name$'_label 'tier_1_name$'_start 'tier_1_name$'_end 'tier_1_name$'_duration 'tier_1_name$'_left_1_label 'tier_1_name$'_left_1_duration 'tier_1_name$'_right_1_label 'tier_1_name$'_right_1_duration "
					
					# Set up dummies for the additional tiers to avoid error message
					titleline_tier_2_labels$ = ""
					titleline_tier_3_labels$ = ""
					titleline_tier_4_labels$ = ""
					
					if number_of_tiers > 1
						titleline_tier_2_labels$ = "'tier_2_name$'_label 'tier_2_name$'_start 'tier_2_name$'_end 'tier_2_name$'_duration 'tier_2_name$'_left_1_label 'tier_2_name$'_left_1_stress 'tier_2_name$'_left_1_duration 'tier_2_name$'_right_1_label 'tier_2_name$'_right_1_stress 'tier_2_name$'_right_1_duration "
					
					# endif number_of_tiers > 1
					endif
					
					if number_of_tiers > 2
						titleline_tier_3_labels$ = "'tier_3_name$'_label 'tier_3_name$'_start 'tier_3_name$'_end 'tier_3_name$'_duration 'tier_3_name$'_left_1_label 'tier_3_name$'_left_1_duration 'tier_3_name$'_right_1_label 'tier_3_name$'_right_1_duration "
					
					# endif number_of_tiers > 2
					endif
					
					if number_of_tiers > 3
						titleline_tier_4_labels$ = "'tier_4_name$'_label "
					
					# endif number_of_tiers > 3
					endif
					
					titleline_bg_info_2$ = "analyser date script_name version"
				
					titleline_consonants_1$ = "plosive_phone_relative_duration plosive_phoneme_relative_duration_preceding plosive_phoneme_relative_duration_following consonant_intensity_mean_all consonant_intensity_mean_fifty consonant_intensity_maximum_all consonant_intensity_maximum_fifty consonant_rise_time burst_intensity relative_burst_intensity_all relative_burst_intensity_fifty zcs zcr preemphasis_consonant filter filter_minimum_frequency filter_maximum_frequency filter_smoothing cog sd skewness kurtosis vowel_preceding_intensity_mean_all vowel_preceding_intensity_mean_fifty vowel_following_intensity_mean_all vowel_following_intensity_mean_fifty "
					
					header_consonants$ = titleline_bg_info_1$ + titleline_tier_1_labels$ + titleline_tier_2_labels$ + titleline_tier_3_labels$ + titleline_tier_4_labels$ + titleline_consonants_1$ + titleline_bg_info_2$
					
					########## End Setup the titlelines ##########
				
					do ("Create Table with column names...", "output_consonants", 0, header_consonants$)
					
					table_consonant_file = selected ("Table")
				
				# endif table_consonant_file = 0
				endif
				
				selectObject (table_consonant_file)
				do ("Append row")
				last_row_consonants = do ("Get number of rows")
			
				# Write bg_info_1
				do ("Set string value...", last_row_consonants, "token_id", string$(token_no) + "-" + analyser$)
				do ("Set string value...", last_row_consonants, "sound_name", soundname$)
				do ("Set string value...", last_row_consonants, "speaker_name", speakername$)
				do ("Set string value...", last_row_consonants, "style", style$)
				
				# Write tier_1_labels
				do ("Set string value...", last_row_consonants, "'tier_1_name$'_label", tier_1_label$)
				do ("Set numeric value...", last_row_consonants, "'tier_1_name$'_start", 'tier_1_start:3')
				do ("Set numeric value...", last_row_consonants, "'tier_1_name$'_end", 'tier_1_end:3')
				do ("Set numeric value...", last_row_consonants, "'tier_1_name$'_duration", 'tier_1_duration:4')
				do ("Set string value...", last_row_consonants, "'tier_1_name$'_left_1_label", tier_1_left_1_label_2$)
				do ("Set numeric value...", last_row_consonants, "'tier_1_name$'_left_1_duration", 'tier_1_left_1_duration:4')
				do ("Set string value...", last_row_consonants, "'tier_1_name$'_right_1_label", tier_1_right_1_label_2$)
				do ("Set numeric value...", last_row_consonants, "'tier_1_name$'_right_1_duration", 'tier_1_right_1_duration:4')
				
				if number_of_tiers > 1
				
					# Write tier_2_labels
					do ("Set string value...", last_row_consonants, "'tier_2_name$'_label", tier_2_label$)
					do ("Set numeric value...", last_row_consonants, "'tier_2_name$'_start", 'tier_2_start:3')
					do ("Set numeric value...", last_row_consonants, "'tier_2_name$'_end", 'tier_2_end:3')
					do ("Set numeric value...", last_row_consonants, "'tier_2_name$'_duration", 'tier_2_duration:4')
					do ("Set string value...", last_row_consonants, "'tier_2_name$'_left_1_label", tier_2_left_1_label_2$)
					do ("Set string value...", last_row_consonants, "'tier_2_name$'_left_1_stress", phoneme_preceding_stress$)
					do ("Set numeric value...", last_row_consonants, "'tier_2_name$'_left_1_duration", 'tier_2_left_1_duration:4')
					do ("Set string value...", last_row_consonants, "'tier_2_name$'_right_1_label", tier_2_right_1_label_2$)
					do ("Set string value...", last_row_consonants, "'tier_2_name$'_right_1_stress", phoneme_following_stress$)
					do ("Set numeric value...", last_row_consonants, "'tier_2_name$'_right_1_duration", 'tier_2_right_1_duration:4')
				
				# endif number_of_tiers > 1
				endif
				
				if number_of_tiers > 2 
				
					# Write tier_3_labels
					do ("Set string value...", last_row_consonants, "'tier_3_name$'_label", tier_3_label$)
					do ("Set numeric value...", last_row_consonants, "'tier_3_name$'_start", 'tier_3_start:3')
					do ("Set numeric value...", last_row_consonants, "'tier_3_name$'_end", 'tier_3_end:3')
					do ("Set numeric value...", last_row_consonants, "'tier_3_name$'_duration", 'tier_3_duration:4')
					do ("Set string value...", last_row_consonants, "'tier_3_name$'_left_1_label", tier_3_left_1_label_2$)
					do ("Set numeric value...", last_row_consonants, "'tier_3_name$'_left_1_duration", 'tier_3_left_1_duration:4')
					do ("Set string value...", last_row_consonants, "'tier_3_name$'_right_1_label", tier_3_right_1_label_2$)
					do ("Set numeric value...", last_row_consonants, "'tier_3_name$'_right_1_duration", 'tier_3_right_1_duration:4')
				
				# endif number_of_tiers > 2
				endif
				
				if number_of_tiers > 3 
				
					# Write tier_4_labels
					do ("Set string value...", last_row_consonants, "'tier_4_name$'_label", tier_4_label$)
					
				# endif number_of_tiers > 3
				endif
				
				# Write consonant measurements
				do ("Set numeric value...", last_row_consonants, "plosive_phone_relative_duration", 'plosive_phone_relative_duration:4')
				do ("Set numeric value...", last_row_consonants, "plosive_phoneme_relative_duration_preceding", 'plosive_phoneme_relative_duration_preceding:3')
				do ("Set numeric value...", last_row_consonants, "plosive_phoneme_relative_duration_following", 'plosive_phoneme_relative_duration_following:3')
				do ("Set numeric value...", last_row_consonants, "consonant_intensity_mean_all", 'consonant_intensity_mean_all:3')
				do ("Set numeric value...", last_row_consonants, "consonant_intensity_mean_fifty", 'consonant_intensity_mean_fifty:3')
				do ("Set numeric value...", last_row_consonants, "consonant_intensity_maximum_all", 'consonant_intensity_maximum_all:3')
				do ("Set numeric value...", last_row_consonants, "consonant_intensity_maximum_fifty", 'consonant_intensity_maximum_fifty:3')
				do ("Set numeric value...", last_row_consonants, "consonant_rise_time", 'consonant_rise_time:3')
				do ("Set numeric value...", last_row_consonants, "burst_intensity", 'burst_intensity:3')
				do ("Set numeric value...", last_row_consonants, "relative_burst_intensity_all", 'relative_burst_intensity_all:3')
				do ("Set numeric value...", last_row_consonants, "relative_burst_intensity_fifty", 'relative_burst_intensity_fifty:3')
				do ("Set numeric value...", last_row_consonants, "zcs", 'zcs:3')
				do ("Set numeric value...", last_row_consonants, "zcr", 'zcr:3')
				do ("Set numeric value...", last_row_consonants, "preemphasis_consonant", 'preemphasis_consonant:3')
				do ("Set string value...", last_row_consonants, "filter", filter$)
				do ("Set numeric value...", last_row_consonants, "filter_minimum_frequency", 'filter_minimum_frequency:3')
				do ("Set numeric value...", last_row_consonants, "filter_maximum_frequency", 'filter_maximum_frequency:3')
				do ("Set numeric value...", last_row_consonants, "filter_smoothing", 'filter_smoothing:3')
				do ("Set numeric value...", last_row_consonants, "cog", 'cog:3')
				do ("Set numeric value...", last_row_consonants, "sd", 'sd:3')
				do ("Set numeric value...", last_row_consonants, "skewness", 'skewness:3')
				do ("Set numeric value...", last_row_consonants, "kurtosis", 'kurtosis:3')
				do ("Set numeric value...", last_row_consonants, "vowel_preceding_intensity_mean_all", 'vowel_preceding_intensity_mean_all:3')
				do ("Set numeric value...", last_row_consonants, "vowel_preceding_intensity_mean_fifty", 'vowel_preceding_intensity_mean_fifty:3')
				do ("Set numeric value...", last_row_consonants, "vowel_following_intensity_mean_all", 'vowel_following_intensity_mean_all:3')
				do ("Set numeric value...", last_row_consonants, "vowel_following_intensity_mean_fifty", 'vowel_following_intensity_mean_fifty:3')
				
				# Write the bg_info_2
				do ("Set string value...", last_row_consonants, "analyser", analyser$)
				do ("Set string value...", last_row_consonants, "date", date$)
				do ("Set string value...", last_row_consonants, "script_name", script_name$)
				do ("Set string value...", last_row_consonants, "version", version$)
				
			########## End Write consonant measurements to table ##########
			
			########## End Collect a range of consonant measurements ##########
		
				# Set up the new token id
				token_no = token_no + 1
				token_no_new = token_no
	
			# endif index (consonant_labels$, " " + tier_1_label_2$ + " ")
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

selectObject (table_consonant_file)
do ("Save as tab-separated file...", consonant_outputfile$)
 
selectObject (string_of_sound_files)
plus table_tokens
plus table_consonant_file

do ("Remove")

appendInfoLine ("")
appendInfoLine ("Done!")
appendInfoLine ("")
appendInfoLine ("The results for the consonants analysis have been written to 'newline$''consonant_outputfile$'")