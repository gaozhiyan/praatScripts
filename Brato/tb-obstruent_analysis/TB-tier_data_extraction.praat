###############################################################################
# 
# Author: Thorsten Brato
# Mail: Thorsten.Brato@phil.tu-chemnitz.de
# Script name: TB-tier_data_extraction.praat
# Version: [2014:09:17]
# This script is distributed under the GNU General Public License 
# (http://www.gnu.org/licenses/gpl.txt).
# Copyright 17/09/2014 by Thorsten Brato.
#
# Description:
# This script was developed for Praat 5.3.44 and newer. 
# This script is not a standalone script, i.e. it is only called by some of my
# other scripts and cannot be run on its own.
# It collects data from to up to four tiers ordered from smallest to largest 
# unit based on information in tier 1. It assumes that tier 1 contains the 
# labels of data to analyse acoustically and therefore collects the most 
# detailed information from this tier and only collects data from the other 
# tiers if one of the labels in tier 1 is matched by the calling script.
# For example, if you look for vowels you may have coded them as lexical sets,
# such as 'strut' or 'foot'. The script will only collect data if the interval
# on tier 1 is either 'strut' or 'foot', but not 'goose' or 't". 
#
# The script will collect the following information from all tiers and store
# them temporarily so that you can write them to a table or other type of 
# output using the calling script:
# - start of the interval
# - end of the interval
# - duration of the interval (in ms)
# - label, start, end and duration of the first intervals to the left and right
# In addition on the first tier, the script will also create variables for the
# times at 5% intervals, which I need for my vowel tracking script. 
# On the first and second tiers, stress information for the current interval
# is also stored if this information is provided in the required format. I code
# stress in vowels by attaching 0, 1 or 2 to the vowel label, e.g. 'foot1'. 
# 0 indicates an unstressed vowel, 1 is for primary stress and 2 for secondary
# stress. 
# The script uses regular expressions to collect this information and also to
# create variables without the stress label for the previous and following 
# segments on tier 1 and current, previous and following segments on tier 2. 
#
# The script can easily be adapted to collect data from more than four
# tiers should you feel that this is necessary, just remember to also change
# the script that 'outputs' the results.
###############################################################################

########## Begin Collect tier 1 interval data ##########
				
# Extract the stress information
if endsWith (tier_1_label$, "0") = 1
	stress$ = "unstressed"
elsif endsWith (tier_1_label$, "1") = 1
	stress$ = "primary stress"
elsif endsWith (tier_1_label$, "2") = 1
	stress$ = "secondary stress"
else
	stress$ = "stress uncoded"
# endif endsWith (tier_1_label$, "0") = 1
endif

# Get the start, end, duration (in ms) and centre of tier 1 intervals
tier_1_start = do ("Get starting point...", 1, interval_tier_1)
tier_1_end = do ("Get end point...", 1, interval_tier_1)
tier_1_duration = (tier_1_end - tier_1_start)*1000
tier_1_centre = (tier_1_start + tier_1_end)/2

# Create dummy variables in order to not potentially produce an error
tier_1_left_1_label_2$ = ""
tier_1_left_1_duration = 0
tier_1_left_1_start = 0
tier_1_left_1_end = 0

# Get the label of the first interval to the left
if interval_tier_1 > 1 
	
		interval_tier_1_left_1 = interval_tier_1-1
		tier_1_left_1_label$ = do$ ("Get label of interval...", 1, interval_tier_1_left_1)
	
		if tier_1_left_1_label$ = ""
			tier_1_left_1_label$ = "empty"
		# endif tier_1_left_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the first interval to the left
		tier_1_left_1_start = do ("Get starting point...", 1, interval_tier_1_left_1)
		tier_1_left_1_end = do ("Get end point...", 1, interval_tier_1_left_1)
		tier_1_left_1_duration = (tier_1_left_1_end - tier_1_left_1_start)*1000
		tier_1_left_1_label_2$ = replace_regex$ (tier_1_left_1_label$,"[0-9]", "", 0)	
# endif interval_tier_1 > 1 
endif

# Get the label of the first interval to the right
if interval_tier_1 < number_of_intervals_tier_1
	
		interval_tier_1_right_1 = interval_tier_1+1
		tier_1_right_1_label$ = do$ ("Get label of interval...", 1, interval_tier_1_right_1)
	
		if tier_1_right_1_label$ = ""
			tier_1_right_1_label$ = "empty"
		# endif tier_1_right_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the first interval to the right
		tier_1_right_1_start = do ("Get starting point...", 1, interval_tier_1_right_1)
		tier_1_right_1_end = do ("Get end point...", 1, interval_tier_1_right_1)
		tier_1_right_1_duration = (tier_1_right_1_end - tier_1_right_1_start)*1000
		tier_1_right_1_label_2$ = replace_regex$ (tier_1_right_1_label$,"[0-9]", "", 0)	
# endif interval_tier_1 < number_of_intervals_tier_1
endif

# Get the times at various places
time_zero = tier_1_start
time_five = tier_1_start + 5*(tier_1_end-tier_1_start)/100
time_ten = tier_1_start + 10*(tier_1_end-tier_1_start)/100
time_fifteen = tier_1_start + 15*(tier_1_end-tier_1_start)/100
time_twenty = tier_1_start + 20*(tier_1_end-tier_1_start)/100
time_twenty_five = tier_1_start + 25*(tier_1_end-tier_1_start)/100
time_thirty = tier_1_start + 30*(tier_1_end-tier_1_start)/100
time_thirty_five = tier_1_start + 35*(tier_1_end-tier_1_start)/100
time_forty = tier_1_start + 40*(tier_1_end-tier_1_start)/100
time_forty_five = tier_1_start + 55*(tier_1_end-tier_1_start)/100
time_fifty = tier_1_start + 50*(tier_1_end-tier_1_start)/100
time_fifty_five = tier_1_start + 55*(tier_1_end-tier_1_start)/100
time_sixty = tier_1_start + 60*(tier_1_end-tier_1_start)/100
time_sixty_five = tier_1_start + 65*(tier_1_end-tier_1_start)/100
time_seventy = tier_1_start + 70*(tier_1_end-tier_1_start)/100
time_seventy_five = tier_1_start + 75*(tier_1_end-tier_1_start)/100
time_eighty = tier_1_start + 80*(tier_1_end-tier_1_start)/100
time_eighty_five = tier_1_start + 55*(tier_1_end-tier_1_start)/100
time_ninety = tier_1_start + 90*(tier_1_end-tier_1_start)/100
time_ninety_five = tier_1_start + 95*(tier_1_end-tier_1_start)/100
time_hundred = tier_1_end

########## End Collect tier 1 interval data ##########

########## Begin Collect tier 2 interval data ##########

if number_of_tiers > 1

	interval_tier_2 = do ("Get interval at time...", 2, tier_1_centre)
	
	# Get the label of the tier_2 interval
	tier_2_label$ = do$ ("Get label of interval...", 2, interval_tier_2)
	
	if tier_2_label$ = ""
	tier_2_label$ = "empty"
	# endif tier_2_label$ = ""
	endif
	
	# Get the start, end, duration (in ms) of the tier 2 intervals
	tier_2_start = do ("Get starting point...", 2, interval_tier_2)
	tier_2_end = do ("Get end point...", 2, interval_tier_2)
	tier_2_duration = (tier_2_end - tier_2_start)*1000
	tier_2_label_2$ = replace_regex$ (tier_2_label$,"[0-9]", "", 0)
	
	# Create dummy variables in order to not potentially produce an error
	tier_2_left_1_label_2$ = ""
	tier_2_left_1_duration = 0
	tier_2_left_1_start = 0
	tier_2_left_1_end = 0
	
	# Get the label of the first interval to the left
	if interval_tier_2 > 1 
		
		interval_tier_2_left_1 = interval_tier_2-1
		tier_2_left_1_label$ = do$ ("Get label of interval...", 2, interval_tier_2_left_1)
	
		if tier_2_left_1_label$ = ""
			tier_2_left_1_label$ = "empty"
		# endif tier_2_left_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the preceding tier 2 intervals
		tier_2_left_1_start = do ("Get starting point...", 2, interval_tier_2_left_1)
		tier_2_left_1_end = do ("Get end point...", 2, interval_tier_2_left_1)
		tier_2_left_1_duration = (tier_2_left_1_end - tier_2_left_1_start)*1000
		tier_2_left_1_label_2$ = replace_regex$ (tier_2_left_1_label$,"[0-9]", "", 0)	
	# endif interval_tier_2 > 1 and interval_tier_2 < number_of_intervals_tier_2
	endif	
	
	# Get the label of the first interval to the right
	if interval_tier_2 < number_of_intervals_tier_2
		
		interval_tier_2_right_1 = interval_tier_2+1
		tier_2_right_1_label$ = do$ ("Get label of interval...", 2, interval_tier_2_right_1)
	
		if tier_2_right_1_label$ = ""
			tier_2_right_1_label$ = "empty"
		# endif tier_2_right_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the following tier 2 intervals
		tier_2_right_1_start = do ("Get starting point...", 2, interval_tier_2_right_1)
		tier_2_right_1_end = do ("Get end point...", 2, interval_tier_2_right_1)
		tier_2_right_1_duration = (tier_2_right_1_end - tier_2_right_1_start)*1000
		tier_2_right_1_label_2$ = replace_regex$ (tier_2_right_1_label$,"[0-9]", "", 0)	
	# endif interval_tier_2 < number_of_intervals_tier_2
	endif
	
	# Extract the stress information on the second tier if it is a vowel
	#left
	if endsWith (tier_2_left_1_label$, "0") = 1
		phoneme_preceding_stress$ = "unstressed"
	elsif endsWith (tier_2_left_1_label$, "1") = 1
		phoneme_preceding_stress$ = "primary stress"
	elsif endsWith (tier_2_left_1_label$, "2") = 1
		phoneme_preceding_stress$ = "secondary stress"
	else
		phoneme_preceding_stress$ = "NA"
	# endif endsWith (tier_2_left_1_label$, "0") = 1
	endif
	
	#right
	if endsWith (tier_2_right_1_label$, "0") = 1
		phoneme_following_stress$ = "unstressed"
	elsif endsWith (tier_2_right_1_label$, "1") = 1
		phoneme_following_stress$ = "primary stress"
	elsif endsWith (tier_2_right_1_label$, "2") = 1
		phoneme_following_stress$ = "secondary stress"
	else
		phoneme_following_stress$ = "NA"
	# endif endsWith (tier_2_right_1_label$, "0") = 1
	endif
	
# endif number_of_tiers > 1
endif

########## Begin Collect tier 3 interval data ##########

if number_of_tiers > 2

	interval_tier_3 = do ("Get interval at time...", 3, tier_1_centre)
	
	# Get the label of the tier_3 interval
	tier_3_label$ = do$ ("Get label of interval...", 3, interval_tier_3)
	
	if tier_3_label$ = ""
	tier_3_label$ = "empty"
	# endif tier_3_label$ = ""
	endif
	
	# Get the start, end, duration (in ms) of the tier 3 intervals
	tier_3_start = do ("Get starting point...", 3, interval_tier_3)
	tier_3_end = do ("Get end point...", 3, interval_tier_3)
	tier_3_duration = (tier_3_end - tier_3_start)*1000
	tier_3_label_2$ = replace_regex$ (tier_3_label$,"[0-9]", "", 0)
	
	# Create dummy variables in order to not potentially produce an error
	tier_3_left_1_label_2$ = ""
	tier_3_left_1_duration = 0
	tier_3_left_1_start = 0
	tier_3_left_1_end = 0
	
	# Get the label of the first interval to the left
	if interval_tier_3 > 1 
		
		interval_tier_3_left_1 = interval_tier_3-1
		tier_3_left_1_label$ = do$ ("Get label of interval...", 3, interval_tier_3_left_1)
	
		if tier_3_left_1_label$ = ""
			tier_3_left_1_label$ = "empty"
		# endif tier_3_left_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the preceding tier 3 intervals
		tier_3_left_1_start = do ("Get starting point...", 3, interval_tier_3_left_1)
		tier_3_left_1_end = do ("Get end point...", 3, interval_tier_3_left_1)
		tier_3_left_1_duration = (tier_3_left_1_end - tier_3_left_1_start)*1000
		tier_3_left_1_label_2$ = replace_regex$ (tier_3_left_1_label$,"[0-9]", "", 0)	
	# endif interval_tier_3 > 1 and interval_tier_3 < number_of_intervals_tier_3
	endif	
	
	# Get the label of the first interval to the right
	if interval_tier_3 < number_of_intervals_tier_3
		
		interval_tier_3_right_1 = interval_tier_3+1
		tier_3_right_1_label$ = do$ ("Get label of interval...", 3, interval_tier_3_right_1)
	
		if tier_3_right_1_label$ = ""
			tier_3_right_1_label$ = "empty"
		# endif tier_3_right_1_label$ = ""
		endif
			
		#  Get the start, end, duration (in ms) of the following tier 3 intervals
		tier_3_right_1_start = do ("Get starting point...", 3, interval_tier_3_right_1)
		tier_3_right_1_end = do ("Get end point...", 3, interval_tier_3_right_1)
		tier_3_right_1_duration = (tier_3_right_1_end - tier_3_right_1_start)*1000
		tier_3_right_1_label_2$ = replace_regex$ (tier_3_right_1_label$,"[0-9]", "", 0)	
	# endif interval_tier_3 < number_of_intervals_tier_3
	endif

# endif number_of_tiers > 2
endif

########## End Collect tier 3 interval data ##########

########## Begin Collect tier 4 interval data ##########

if number_of_tiers > 3

	interval_tier_4 = do ("Get interval at time...", 4, tier_1_centre)
	
	# Get the label of the tier_3 interval
	tier_4_label$ = do$ ("Get label of interval...", 4, interval_tier_4)
	
	if tier_4_label$ = ""
	tier_4_label$ = "empty"
	# endif tier_4_label$ = ""
	endif
	
# endif number_of_tiers > 3
endif

########## End Collect tier 4 interval data ##########