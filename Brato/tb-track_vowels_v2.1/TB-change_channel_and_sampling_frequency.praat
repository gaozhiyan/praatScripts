########## Begin Change number of channels and change sampling frequency ##########
				
selectObject (longsound)

# Get the number of channels and sampling frequency
long_soundinfo$ = Info
number_of_channels$ = extractLine$(long_soundinfo$, "Number of channels: ")
number_of_channels = number (number_of_channels$)
				
sampling_frequency$ = extractLine$(long_soundinfo$, "Sampling frequency: ")
sampling_frequency = number (sampling_frequency$)

# Extract the segment on tier 1 for further analysis
segment = do ("Extract part...", tier_1_start-margin, tier_1_end+margin, "yes")

# Check if the segment is stereo and change to mono if selected in the form
if number_of_channels = 2 and convert_to_mono = 1
	segment_mono = do ("Convert to mono")

# endif number_of_channels = 2 and convert_to_mono = 1
endif

# If the sampling frequency is higher than that set in the form, downsample.
if sampling_frequency > downsample_to and downsample_to > 0
	
	current_segment = selected ("Sound")
	segment_resampled = do ("Resample...", downsample_to, 50)
	
	# if we resample, we remove the segment with the original sampling rate
	selectObject (current_segment)
	do ("Remove")
	selectObject (segment_resampled)
	
# endif sampling_frequency > downsample_consonants
endif
	
########## End Change number of channels and change sampling frequency ##########