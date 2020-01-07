### This script runs through all soundfiles in a folder and outputs a list of 1000 F0 values for each
### as well as the duration (s) for that file
### Pitch window is set at 50-450 Hz 
### Tuuli Morrill, January 2015


form Pitch track file information
	comment Enter directory where soundfiles and textgrids are located
	text inFolder /Users/zhiyangao/Desktop/ken/
	comment Full path of the resulting text file
	text resultfile /Users/zhiyangao/Desktop/ken/test2.txt
endform

#Check if the result file exists:
if fileReadable (resultfile$)
	pause The file 'resultfile$' already exists. Overwrite?
	filedelete 'resultfile$'
endif

#Write a row with column titles to the result file:
titleline$ = "Filename 'tab$'  IntervalDuration 'tab$'Time'tab$'PointNumber'tab$'F0'tab$'pitch'newline$'"
fileappend "'resultfile$'" 'titleline$'

Create Strings as file list... fileList 'inFolder$'/*.wav
numFiles = Get number of strings

for i from 1 to numFiles

	select Strings fileList
	fileNameLong$ = Get string... i
	fileNameShort$ = fileNameLong$-".wav"
	Read from file... 'inFolder$'/'fileNameLong$'

#### Get the pitch manipulation object (all the points)
	select Sound 'fileNameShort$'
	To Manipulation: 0.01, 50, 450

#### Interpolate between pitch points
	Extract pitch tier
	To Pitch: 0.01, 10, 450

#### Smooth pitch contour
	Smooth: 15

### get formats
	select Sound 'fileNameShort$'
	To Formant (burg)... 0.01 5 5500 0.025 50

#### Extract pitch information at each 1/100 of the phrase
	phraseduration = 0.31
	totalpoint=phraseduration*100
	phrasediv = phraseduration/totalpoint
	startphrase = Get start time
	pitchpoint = startphrase
		for k from 1 to totalpoint
			select Pitch 'fileNameShort$'
			f0 = Get value at time: pitchpoint, "semitones re 1 Hz", "Linear"
			f2 = Get value at time... 2 pitchpoint, "Hertz", "Linear"
			pitch = Get value at time: pitchpoint, "Hertz", "Linear"
			resultline$ = "'fileNameShort$' 'tab$' 'phraseduration' 'tab$' 'pitchpoint''tab$' 'k''tab$' 'f0' 'tab$''pitch''tab$' 'tab$''f2''newline$'"
            fileappend "'resultfile$'" 'resultline$'
			pitchpoint = startphrase+(k*phrasediv)
		endfor
endfor
select all
Remove



