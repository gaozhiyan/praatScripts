#Replaces portions of sound files that are unlabelled in the textgrid with silence.
#Copyright Christian DiCanio, Haskins Laboratories, October 2011.

form Extract Time Indices from Textgrids
   sentence Directory_name: /Linguistics/Mixteco/editado/Forced_Alignment/testing2/
   sentence Log_file logfile
   positive Labeled_tier_number 1
endform

Create Strings as file list... list 'directory_name$'/*.TextGrid
num = Get number of strings

for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	Replace interval text... 'labeled_tier_number' 0 0 "" SIL Literals
	Save as text file... 'directory_name$'/'fileName$'
endfor

Create Strings as file list... list 'directory_name$'/*.wav
numwav = Get number of strings
Create Strings as file list... list 'directory_name$'/*.TextGrid
numtxt = Get number of strings
for ifile to numtxt
	name$ = Get string... ifile
	namemod$ = replace$ (name$, "TextGrid", "wav", 1)
	Read from file... 'directory_name$'/'name$'
	text = selected("TextGrid")
	numint = Get number of intervals... 'labeled_tier_number'
	for i to numint
		select text
		labint$ = Get label of interval... 'labeled_tier_number' 'i'
		if labint$ = "SIL"
			startint = Get start point... 'labeled_tier_number' 'i'
			endint = Get end point... 'labeled_tier_number' 'i'
			Read from file... 'directory_name$''namemod$'
			soundID = selected("Sound")
			Set part to zero... 'startint' 'endint' at exactly these times
			Save as WAV file... 'directory_name$'/'namemod$'
		else #do nothing
		endif
	endfor
endfor
