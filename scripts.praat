#praat script 
script_name$ = "analyse_intervals.praat"
#author Daniel Hirst
#email daniel.hirst@lpl.univ-aix.fr
version$ = "[2009:01:29]"
date$ = date$()

#purpose Analyse a folder of Sound files and a folder of TextGrid files
# for each interval on selected tier calculate
#	- duration, mean pitch, intensity, f1, f2 f3
#output to Info window

#define parameters used in the script
form analyse intervals
	sentence Sound_folder data
	sentence TextGrid_folder data
	word Analysis_tier transcription
	positive Time_step 0.01
	boolean automatic_max_min yes
	natural Min_pitch 100
	natural Max_pitch 500
	natural Number_of_formants 5
	natural Maximum_formant 5500
	positive Window_length 0.025
	positive Pre_emphasis 50
	word Undefined_value NA
endform

clearinfo

#print header of output file
printline #File created by 'script_name$' version 'version$'
printline #Analysis carried out by 'investigator$' on 'date$' on tier ['analysis_tier$']
printline #
print #Parameters:  
if automatic_max_min
	print "Automatic max min for pitch"
else
	print pitch min='min_pitch'; max='max_pitch' 
endif
printline #'tab$'formants n='number_of_formants', max='maximum_formant'
printline #'tab$'window='window_length', pre-emphasis='pre_emphasis'
printline #
printline 'tab$'extract'tab$'label'tab$'duration'tab$'pitch'tab$'intensity
...'tab$'F1'tab$'F2'tab$'F3

#Read in list of sound files
myStrings = Create Strings as file list... sounds 'sound_folder$'/*.wav
nSounds = Get number of strings
item = 0

#check if TextGrid file exists for each sound and call treatment
for iSound from 1 to nSounds
	select myStrings
	sound_name$ = Get string... iSound
	textGrid_name$ = sound_name$ - "wav" + "TextGrid"
	sound$ = sound_folder$ + "/" + sound_name$
	textGrid$ = textGrid_folder$ + "/" + textGrid_name$
	if fileReadable(textGrid$)
		call treatment
	endif
endfor

#subroutine treatment
procedure treatment
	Read from file... 'sound$'
	mySound = selected("Sound")
	name$ = selected$("Sound")
	Read from file... 'textGrid$'
	myTextGrid = selected("TextGrid")
	nTiers = Get number of tiers
#find number of analysis tier
	tier = 0
	for iTier from 1 to nTiers
		tier_name$ = Get tier name... iTier
		if tier_name$ = analysis_tier$
			tier = iTier
		endif
	endfor
	if tier
#create analysis objects
		select mySound
		myPitch = To Pitch... time_step min_pitch max_pitch
		if automatic_max_min
			q25 = Get quantile... 0 0 0.25 Hertz
			q75 = Get quantile... 0 0 0.75 Hertz
			min_pitch = 0.75*q25
			max_pitch = 1.5*q75
			Remove
			select mySound
			myPitch = To Pitch... time_step min_pitch max_pitch
			printline # min_pitch 'min_pitch:0'; max_pitch 'max_pitch:0'
		endif
		select mySound
		myIntensity = To Intensity... min_pitch time_step Yes
		select mySound
		myFormant = To Formant (burg)... time_step number_of_formants maximum_formant window_length pre_emphasis

#Get time values of beginning and end of each interval for treatment
		select myTextGrid
		nIntervals = Get number of intervals... tier   

		for iInterval from 1 to nIntervals
			select myTextGrid
			label$ = Get label of interval... tier iInterval
			start = Get starting point... tier iInterval
			end = Get end point... tier iInterval
			if label$ != "" and label$ != "_" and label$ != "#"
#calculate parameters for each non empty interval
				item = item+1
#duration
				duration = 1000*(end - start)
				call set_undefined duration
				duration$ = value$
#pitch
				select myPitch
				meanPitch = Get mean... start end Hertz
				call set_undefined meanPitch
				meanPitch$ = value$
#intensity
				select myIntensity
				meanIntensity = Get mean... start end energy
				call set_undefined meanIntensity
				meanIntensity$ = value$
#formants
				select myFormant
				f1 = Get mean... 1 start end Hertz
				call set_undefined f1
				f1$ = value$
				f2 = Get mean... 2 start end Hertz
				call set_undefined f2
				f2$ = value$
				f3 = Get mean... 3 start end Hertz
				call set_undefined f3
				f3$ = value$
#print out results
				printline 'item''tab$''name$''tab$''label$''tab$''duration$'
				...'tab$''meanPitch$''tab$''meanIntensity$''tab$''f1$'
				...'tab$''f2$''tab$''f3$'
			endif
		endfor
#Remove analysis files
		select myPitch
		plus myIntensity
		plus myFormant
		Remove
	else
#print warning if TextGrid has no analysis tier
		printline ###TextGrid 'name$' has no tier 'analysis_tier$'
	endif
#Remove Sound and TextGrid
	select mySound
	plus myTextGrid
	Remove
endproc

#Remove file list
select myStrings
Remove

procedure set_undefined value
	if value = undefined
		value$ = undefined_value$
	else
		value$ = "'value:0'"
	endif
endproc

#version history

#[2009:01:29] added automatic max min for pitch
#[2007:10:30] first version calculates duration pitch intensity & formants on intervals