#Extraction of durations from textgrids. 
#Extracts the duration of every labelled interval on a particular tier. Saves the duration data as a text 
# file with the name of the file and each interval's name.
#Copyright Christian DiCanio, Laboratoire Dynamique du Langage, 6/2011.

form Extract Durations from labelled points
   sentence Directory_name: /Linguistics/Rate_Spanish/Mexican_Spanish_Older_transcriptions/
   sentence Objects_name: MS_M23_CPC_leer
   sentence Log_file datafile
   positive Labeled_tier_number 2
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
endform

Read from file... 'directory_name$''objects_name$'.wav
soundID = selected("Sound")

Read from file... 'directory_name$''objects_name$'.TextGrid
textGridID = selected("TextGrid")
num_labels = Get number of intervals... labeled_tier_number

select 'soundID'
plus 'textGridID'
Extract non-empty intervals... labeled_tier_number yes

durID = selected ("Sound")
objID = selected ("Sound", -1)
for i from durID to objID
	select 'i'
	dur = Get total duration
	interval_label$ = selected$ ("Sound")
	fileappend 'directory_name$''log_file$'.txt 'objects_name$''tab$''interval_label$''tab$''dur''newline$'
endfor
select all
Remove