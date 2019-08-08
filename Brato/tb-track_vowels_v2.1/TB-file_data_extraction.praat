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