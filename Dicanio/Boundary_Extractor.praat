#Extracts time indices of labels in textgrid.
#Copyright Christian DiCanio, Haskins Laboratories, October 2011.

form Extract Time Indices from Textgrids
   sentence Directory_name: /Linguistics/Mixteco/editado/Forced_Alignment/FA_no_glottal/
   sentence Log_file logfile
   positive Labeled_tier_number 1
endform

Create Strings as file list... list 'directory_name$'/*.TextGrid
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	ints = Get number of intervals... 'labeled_tier_number'
	
	for i to ints
		tag$ = Get label of interval... 'labeled_tier_number' i
		start = Get start point... 'labeled_tier_number' i
		end = Get end point... 'labeled_tier_number' i
		fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$''tag$''tab$''start''tab$''end''newline$'
	endfor
endfor