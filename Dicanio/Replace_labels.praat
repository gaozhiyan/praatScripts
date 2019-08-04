#Labels portions in the textgrid with label x with a replacement label y. If you wish to replace an empty interval with text, use "" for the empty interval.
#Copyright Christian DiCanio, Haskins Laboratories, October 2011.

form Extract Time Indices from Textgrids
   sentence Directory_name: /Forced_Alignment/FA_Penn/CTB501Lista001/foo/
   sentence Original_label *
   sentence Replacement_label SIL
   positive Labeled_tier_number 1
endform

Create Strings as file list... list 'directory_name$'/*.TextGrid
num = Get number of strings

for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	Replace interval text... 'labeled_tier_number' 0 0 'original_label$' 'replacement_label$' Literals
	Save as text file... 'directory_name$'/'fileName$'
endfor