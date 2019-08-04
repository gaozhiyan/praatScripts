#Extraction of speech rate from textgrids. 
#Saves the duration data as a text file with the name of the file and the interval name.
#Copyright Christian DiCanio, UC Berkeley, 2/2008

form Extract Durations from labelled points
   sentence Directory_name: /Linguistics/Triqui/Grabacion/2006_Recordings/Maria/
   sentence Objects_name: M_*
   sentence Log_file MNrate
   positive Labeled_tier_number 3
   positive Other_tier 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
endform

Read from file... 'directory_name$''objects_name$'.wav
soundID = selected("Sound")

Read from file... 'directory_name$''objects_name$'.TextGrid
textGridID = selected("TextGrid")

select 'soundID'
plus 'textGridID'
Extract non-empty intervals... other_tier no
q = numberOfSelected ("Sound")

select 'soundID'
plus 'textGridID'
Extract non-empty intervals... labeled_tier_number no

n = numberOfSelected ("Sound")
for i to n
	sound'i' = selected ("Sound", i)
endfor

Create Table without column names... temp n 1
select Table temp
Set column label (index)... 1 duration

for i to n
	select sound'i'
	dur = Get total duration
	Remove
	select Table temp
	Set numeric value... i duration 'dur'
endfor

select Table temp
meanID = Get mean... duration
syll_sec = 1 / meanID
for i to q
	fileappend 'directory_name$''log_file$'.txt 'objects_name$''tab$''syll_sec''newline$'
endfor