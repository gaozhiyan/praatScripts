# This script is originally by Chris Darwin, reposted by Will Styler because it's really awesome and needs common use.
# From http://www.lifesci.sussex.ac.uk/home/Chris_Darwin/Praatscripts/SWS

# SWS makes =<3-formant sine-wave speech out of the selected Sound object
# modified to have consistent new-style syntax 1/9/00 - cjd
# modified optionally to low-pass filter the formant tracks 4/6/01 - cjd
# modified to vary tracking parameters with talkerID 12/6/01 - cjd
# modified to include Add_dynamic - 27/2/03 cjd

#a Formant object may be pre-prepared and used instead of the default (which is prepared directly from the selected sound)
# if a pre-prepared Formant object is used, the amplitudes for the sine waves are taken from its frequencies on the spectrogram derived from the selected sound.
# Formant objects can be edited using Inspect
# the pre-prepared Formant object must have the same name as the selected Sound
 
#Add to dynamic menu... Sound 1 "" 0 "" 0 "Sine-wave speech" Resample... 1 yourdisk:Praat:scripts:SWS

form Sine-wave speech
	choice TalkerID: 1
		button Male
		button Female
		button Child
	comment  Which formants to synthesise?
   boolean Formant_1 1
   boolean Formant_2 1
   boolean Formant_3 1
	comment  Do you want them added together?
   boolean Add_them 1
	comment Use a pre-prepared Formant object with 
	comment  same name as the selected Sound?
	boolean Formant_object 0
	comment Amplitude tracks are normally LP filtered
	comment  at 50 Hz to remove pitch modulations
	integer Amp_low_pass_freq_(Hz) 50
	comment Low pass filtering of the formant tracks
	comment   removes warble, but can degrade rapid consonants.
	comment Do you want to LP filter the formant tracks?
	boolean Low_pass 1
	comment Choose the highest frequency that doesn't give warble.
	integer Formant_low_pass_freq_(Hz) 20
	boolean Remove_intermediate_files 1
endform

if numberOfSelected ("Sound") <> 1
	pause Select one Sound then Continue
endif
snd$ = selected$("Sound", 1)
snd = selected("Sound", 1)

 # upper formant limit depends on talker
  if talkerID = 1
		upperf = 5000; male
	elsif talkerID = 2
		upperf = 5500; female
	else
		upperf = 8000; child
	endif

#create wide-band spectrogram for finding formant amplitudes
To Spectrogram... 0.003 'upperf' 0.001 40 Gaussian

# if no pre-prepared Formant object has been identified then make it, 
if formant_object = 0
	select 'snd'
	To Formant (burg)... 0.01 5  'upperf' 0.025 50
	Rename... untrack
  if talkerID = 1 
		basef = 500; male
	elsif talkerID = 2
		basef = 550; female
	else
		basef = 800; child
	endif
	Track... 3 'basef' 'basef'*3 'basef'*5 'basef'*7 'basef'*9 1 0.1 1
	Rename... 'snd$'
	select Formant untrack
	Remove
endif

# plot a spectrogram if asked for
if formant_object = 0
Erase all
Viewport... 0 9 0 4.5
select Spectrogram 'snd$'
Paint... 0 0 0 'basef'*7 100 yes 50 6 0 no
select Formant 'snd$'
Red
Speckle... 0 0 'basef'*7 30 yes
Draw tracks... 0 0 'basef'*7 yes
endif

select 'snd'
dur = Get duration
sf = Get sample rate

#start of main formant loop
#===========================
#for each chosen formant turn formant tracks into 
#a Matrix then a Sound object for optional low-pass filtering
#NB this Sound object is the formant TRACK
#then back into a Matrix object for sound synthesis

for i from 1 to 3
if formant_'i' 
# make a matrix from Fi
select Formant 'snd$'
To Matrix... 'i'
Rename... f'i'
if low_pass
#low-pass filter the  formant track and tidy-up the names
#filtering needs a Sound object, so cast as Sound, filter and then back to Matrix
	To Sound (slice)... 1
	Filter (pass Hann band)... 0 'formant_low_pass_freq' 'formant_low_pass_freq'
	Down to Matrix
	select Matrix f'i'
	Remove
	select Matrix f'i'_band
	Rename... f'i'
	select Sound f'i'
	plus Sound f'i'_band
	Remove
endif

#set up amplitude contour array (sample only at 1kHz) for i'th formant
#make it a Sound object so that it can be smoothed by filtering
Create Sound... amp'i' 0 'dur' 1000 sqrt(Spectrogram_'snd$'(x,Matrix_f'i'(x)))
#smooth out pitch amplitude modulation by low-pass filtering
	Filter (pass Hann band)... 0 'amp_low_pass_freq' 'amp_low_pass_freq'
	select Sound amp'i'
	Remove
	select Sound amp'i'_band
	Rename... amp'i'
# To make a sine-wave at Fi (NB you can't just use sin(2pi*fm*t) - since fm is only the instantaneous, not the historic frequency)
# create a waveform with the phase-change associated with sinewave of frequency Fi
Create Sound... sin'i' 0 'dur' 'sf' Matrix_f'i'(x)/'sf'
# integrate phase-change to get actual local value
Formula... if (self + self[col-1]) >1 then (self + self[col-1])-1 else self + self[col-1] fi
# turn phase into sine value, with amplitude corresponding to formant freq in spectrogram
Formula... 0.75*sin(2*pi*self)*Sound_amp'i'(x)

if remove_intermediate_files
#tidy-up
	select Sound amp'i'
	plus Matrix f'i'
	Remove
endif

endif
endfor
#===========================
#end of the main formant loop

#tidy-up
select Spectrogram 'snd$'
Remove

#add-up the three sine components
#first select them
if (formant_1 + formant_2 + formant_3) > 1 and add_them
for i from 1 to 3
if formant_'i' 
plus Sound sin'i'
endif
endfor
#then call Add_dynamic to add them up
call add_dynamic 0 2 1
Rename... 'snd$'SWS
endif

#============================
# The "Preserve real time" option keeps the samples that are added together in their absolute time positions. 
# If sounds have been Extracted from another Sound, then their absolute time position will ONLY have been preserved
#      if you have used "Extract windowed selection..." with the "Preserve times" option checked.  
#  To preserve absolute times when you extract an UNwindowed waveform you should use "Extract windowed selection..." 
#      with a Rectangular window with "Relative width"=1.0, since "Extract selection" does not have a "Preserve time" option.
#  Sampling frequency is set to that of the last-finishing sound

procedure add_dynamic play_after_synthesis scaling_factor mode

#find out how many Sounds have been selected
numberOfSounds = numberOfSelected ("Sound")

#set up arrays with names and IDs of selected Sounds
for ifile from 1 to numberOfSounds
   sound$ = selected$("Sound",'ifile')
   soundID = selected("Sound",'ifile')
   ids'ifile' = soundID
   names'ifile'$ = sound$
endfor 


#   find the file with the most samples or longest duration
maxduration = 0
for ifile from 1 to numberOfSounds
		filenum = ids'ifile'
		select 'filenum'
if mode = 1
	  duration = Get number of samples
elsif mode = 2
# get finishing time of sound
		duration = Get finishing time
endif
	  if  duration > maxduration
		 	maxID = filenum
			 maxduration = duration
	  endif
endfor

# create a blank file that will run from zero to the end of the latest finishing time
# with a sampling frequency that is the same as that of the last-finishing sound
select 'maxID'
sf = Get sample rate
if mode = 1
		Create Sound... sum 0 (maxduration/sf) sf 0
elsif mode =2
		Create Sound... sum 0 maxduration sf 0
endif

#now cycle through all selected files, add to sum
for ifile from 1 to numberOfSounds
    sound$ = names'ifile'$
   if mode = 1
			Formula...  self + 'scaling_factor'*Sound_'sound$'[]
		else
			Formula...  self + 'scaling_factor'*Sound_'sound$'()
		endif
endfor

if play_after_synthesis
	Play
endif

endproc


