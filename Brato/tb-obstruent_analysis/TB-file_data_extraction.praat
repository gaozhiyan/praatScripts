###############################################################################
# 
# Author: Thorsten Brato
# Mail: Thorsten.Brato@phil.tu-chemnitz.de
# Script name: TB-file_data_extraction.praat
# Version: [2014:09:17]
# This script is distributed under the GNU General Public License 
# (http://www.gnu.org/licenses/gpl.txt).
# Copyright 17/09/2014 by Thorsten Brato.
#
# Description:
# This script was developed for Praat 5.3.44 and newer. 
# This script is not a standalone script, i.e. it is only called by some of my
# other scripts and cannot be run on its own.
# The scripts checks the file names whether they contain style and/or gender 
# information. For both to work it assumes the following format I usually use 
# for my file names: 'speakercode-stylecode', e.g. 'AKM1-RP.wav'
# - style: The script checks if the two final characters of the file name 
# 	before the .Sound_file_extension (usually .wav) are one of three 
# 	options  - WL, RP or IN - indicating wordlist, reading passage and 
# 	interview respectively. This information is stored temporarily and may be
# 	written to the output table by the calling script. If the pattern is not 
#	matched, the script will store "style uncoded". N.B.: Praat is case-
# 	sensitive, so 'in' and 'IN' are different.
# - gender: I usually use a four-character speaker code	to identify my
#	speakers. In the third I code for gender - F (female) and M (male). My 
# 	vowel analysis scripts use this information to automatically change the
# 	formant settings. If gender is not coded in this position, the script will
#	prompt the user to enter this information manually for every new speaker. 
#
# This script can be adapted easily for other types of naming systems and/or 
# further information to automatically extract using regular expressions:
# cf. http://www.fon.hum.uva.nl/praat/manual/Regular_expressions.html
#
###############################################################################

########## Begin Extract sound name, style, speaker and gender ##########
	
# Extract style
if endsWith (filename$, "WL'sound_file_extension$'") = 1
	style$ = "wordlist"
elsif endsWith (filename$, "RP'sound_file_extension$'") = 1
	style$ = "reading passage"
elsif endsWith (filename$, "IN'sound_file_extension$'") = 1
	style$ = "interview"
else
	style$ = "style uncoded"
# endif endsWith (filename$, "WL") = 1
endif

#Extract the sound name
soundname$ = replace$ (filename$, sound_file_extension$, "", 0)

# Extract the speaker name
# Replace the sequence "- + any two uppercase letters + a single number" by nothing
speakername$ = replace_regex$ (soundname$,"-[A-Z]*[a-z]*[0-9]*", "", 0)

# Extract the gender
gender$ = mid$ (speakername$, 3, 1)
if gender$ = "f" or gender$ = "F"
	gender$ = "female"
elsif gender$ = "m" or gender$ = "M"
	gender$ = "male"
else
	beginPause ("Provide gender information!")
	comment ("Gender is uncoded in the filename. Please select speaker gender.")
	optionMenu ("Gender", 0)
		option ("female")
		option ("male")
	gender_continue = endPause ("Continue", 1)
	if gender_continue = 1
	
	#endif gender_continue
	endif
#endif gender$ = "f" or gender$ = "F"
endif

########## End Extract sound name, style, speaker and gender ##########