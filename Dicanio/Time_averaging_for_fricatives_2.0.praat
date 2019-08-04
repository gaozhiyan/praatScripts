#Praat script which produces the first four spectral moments from fricative spectra. The DFTs are averaged using time-averaging (Shadle 2012). The fricative signals should not be
#upsampled, so if the signal is sampled at under 44.1 kHz, please adjust the Resampling rate to match that of the original recording. Within time-averaging, a number of DFTs
#are taken from across the duration of the fricative. These DFTs are averaged for each token and then the moments are calculated. The analyzed duration of the fricative is always
#equivalent to the center 80% of the total duration, cutting off the transitions.

#Note that the duration of these DFTs (window size) multiplied by the number of DFTs (window number) should equal a value no greater than 1.6 times the duration of the sound file 
#to be analyzed. In other words, if you set the window size to 15 ms and the window number to 6, the sum of all window durations is equal to 90 ms. This number of windows works 
#fine for a total fricative duration down to 56 ms., but no lower. The reason for this is that the windows should overlap only up to 50% over the duration of the fricative. If they overlap
#more than this, certain parts of the duration (in the center) get more heavily weighted than others. The value of 1.6 derives from the fact that the analyzed duration is only 80% of the
#duration of the total. Thus, the sum of the windows may only be twice of this 80% value, or 160% of the total duration.

#Copyright 2013, Christian DiCanio, Haskins Laboratories & SUNY Buffalo. Please cite this script if it is used in a publication or presentation.
#Special thanks to Christine Shadle for suggestions and troubleshooting.
#Version 2.0 revised 2017 to fix an issue with intensity averaging. Thanks to Ting Huang at Taiwan Tsing Hua University for pointing this error out to me.


form Time averaging for fricatives (be polite - please cite!)
   sentence Directory_name: /Research_Programs/Christians_praat_scripts/testing_fricatives/
   sentence Interval_label x
   sentence Log_file logfile_fricatives_15ms_6_300Hz_2
   positive Labeled_tier_number 1
   positive Resampling_rate 44100
   positive Window_number 6
   positive Window_size 0.015
   positive Low_pass_cutoff 300
endform

Create Strings as file list... list 'directory_name$'/*.wav
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	soundID1$ = selected$("Sound")
	Resample... resampling_rate 50
	soundID2 = selected("Sound")
	Read from file... 'directory_name$'/'soundID1$'.TextGrid
	textGridID = selected("TextGrid")
	num_labels = Get number of intervals... labeled_tier_number

	fileappend 'directory_name$''log_file$'.txt label'tab$'
	fileappend 'directory_name$''log_file$'.txt duration'tab$'intensity'tab$'cog'tab$'sdev'tab$'skew'tab$'kurt'tab$'
	fileappend 'directory_name$''log_file$'.txt 'newline$'

#For each duration in a sound file, extract its duration and then apply a low stop filter from 0 to the low pass cutoff frequency set as a variable. Estimate the margin of offset then for placing 
#the windows evenly across this duration.

	for i to num_labels
		select 'textGridID'
		label$ = Get label of interval... labeled_tier_number i
			if label$ = interval_label$
				fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'
	      			intvl_start = Get starting point... labeled_tier_number i
				intvl_end = Get end point... labeled_tier_number i
				threshold = 0.1*(intvl_end-intvl_start)
				domain_start = (intvl_start + threshold)
				domain_end = (intvl_end - threshold)
				select 'soundID2'
				Extract part... domain_start domain_end Rectangular 1 no
				intID = selected("Sound")
				select 'intID'
				Filter (stop Hann band)... 0 low_pass_cutoff 1
				intID2 = selected("Sound")
				d1 = Get total duration
				d2 = ((d1-window_size)*window_number)/(window_number-1)
				margin = (window_size - (d2/window_number))/2
				end_d2 = (domain_end-margin)
				start_d2 = (domain_start+margin)

#Estimating the size of each window, which varies with the window number and with the size of the margin. The margin is the offset between the edge of the overall duration and
#the estimated start of the window. If the overall duration is shorter than the sum duration of all windows, the windows will overlap and the margin will be positive. So, this means
#that the windows at the edge of the overall duration are pushed inward so that they do not begin earlier or later than the overall duration. If the overall duration is longer than the 
#sum duration of all windows, then the margin will be negative. This means that the windows are pushed outward so that they are spaced evenly across the overall duration. Tables
#are created to store the average values of each spectrum, the real values, and the imaginary values.

				chunk_length = d2/window_number
				window_end = (chunk_length)+margin
				window_start = window_end-window_size
				bins = round((22050*window_size)+1)
				bin_size = 22050/(bins - 1)
				Create TableOfReal... table 2 bins
				averages = selected("TableOfReal")
				Create TableOfReal... table window_number bins
				real_table = selected("TableOfReal")
				Create TableOfReal... table window_number bins
				imag_table = selected("TableOfReal")
				offset = 0.0001

#For each slice, extract the duration and get the intensity value. Then, convert each slice to a spectrum. For each sampling interval of the spectrum, extract the real and
#imaginary values and place them in the appropriate tables.

				Create Table with column names: "table", window_number, "int.val"
				int_table = selected("Table")
				
				for j to window_number
					window_end = (chunk_length*j)+margin
					window_start = window_end-(window_size + offset)
					select 'intID2'
					Extract part... window_start window_end Rectangular 1 yes
					chunk_part = selected("Sound")

					intensity = Get intensity (dB)
					select 'int_table'
					Set numeric value: j, "int.val", intensity
					select 'chunk_part'

					To Spectrum... no
					spect = selected("Spectrum")
						for k to bins
							select 'spect'
							real = Get real value in bin... k
							select 'real_table'
							Set value... j k real
							select 'spect'
							imaginary = Get imaginary value in bin... k
							select 'imag_table'
							Set value... j k imaginary
						endfor
						Create Table with column names: "table", window_number, "dsmfc"
						Set numeric value: 1, "dsmfc", 92879
				endfor

				select 'int_table'
				Extract rows where column (text): "int.val", "is not equal to", "--undefined--"
				int.rev.table = selected("Table")
				int = Get mean: "int.val"
				

#Getting average values from the real and imaginary numbers in the combined matrix of spectral values. Then, placing them into the averaged matrix.

				for q to bins
					select 'real_table'
					real_ave = Get column mean (index)... q
					select 'averages'
					Set value... 1 q real_ave
					select 'imag_table'
					imag_ave = Get column mean (index)... q
					select 'averages'
					Set value... 2 q imag_ave
				endfor

#Now, converting the averaged matrix to a spectrum to get the moments. Annoyingly, Praat does not allow any simple function to change the sampling interval or xmax in
#a matrix. So, instead, you have to extract the first two moments and then multiply each by the sampling interval size.

				select 'averages'
				To Matrix
				To Spectrum
				cog1 = Get centre of gravity... 2
				cog = cog1*bin_size
				sdev1 = Get standard deviation... 2
				sdev = sdev1*bin_size
				skew = Get skewness... 2
				kurt = Get kurtosis... 2
				fileappend 'directory_name$''log_file$'.txt 'd1''tab$''int''tab$''cog''tab$''sdev''tab$''skew''tab$''kurt''newline$'
			else
				#do nothing
	   		endif
	endfor
endfor
select all
Remove