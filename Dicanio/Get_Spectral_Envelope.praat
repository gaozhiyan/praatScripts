# Extracts amplitude values in spectrum. The user specifies the size of each averaged spectrum amplitude bin,
# e.g. bins of 100 Hz. or 50 Hz., etc. Spectra are calculated dynamically across the duration defined by the textgrid. 
# The number of interval values extracted is equal to numintervals below.
# Writes results to a textfile.
# Christian DiCanio, 2010.

numintervals = 16
#Number of intervals you wish to extract pitch from.

form data from labelled points
   sentence Directory_name: /Linguistics/Triqui/Perception/Experiment2/Tone_stim/
   sentence Objects_name: 
   sentence Interval_label V
   sentence Log_file T2_spectenv
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   positive Bin_size 100
endform

# If your sound files are in a different format, you can insert that format instead of wav below.
Read from file... 'directory_name$''objects_name$'.wav
soundID = selected("Sound")
select 'soundID'
Read from file... 'directory_name$''objects_name$'.TextGrid
textGridID = selected("TextGrid")
num_labels = Get number of intervals... labeled_tier_number

for i to num_labels
	select 'textGridID'
	label$ = Get label of interval... labeled_tier_number i
		if label$ = interval_label$
			fileappend 'directory_name$''log_file$'.txt 
      			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			select 'soundID'
			Extract part... intvl_start intvl_end Rectangular 1 no
			intID = selected("Sound")
			chunkID  = (intvl_end-intvl_start)/numintervals

			for j to numintervals
				select 'intID'
				Extract part... (j-1)*chunkID j*chunkID Rectangular 1 no
				chunk_part = selected("Sound")
				select 'chunk_part'
				To Spectrum... yes
				spect = selected("Spectrum")
				To Ltas... bin_size
				To Matrix
				mat = selected("Matrix")
				select mat
				colnum = Get number of columns
					for k to colnum
					val = Get value in cell... 1 k
						if k = colnum
						fileappend 'directory_name$''log_file$'.txt
	 	           			... 'val''newline$'
						else
						fileappend 'directory_name$''log_file$'.txt
	   	         			... 'val''tab$'
						endif
					endfor
			endfor
			select 'intID'
			Remove
		else
			#do nothing
   		endif
endfor
select all
Remove