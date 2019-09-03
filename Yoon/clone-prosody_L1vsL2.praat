Appendix (Praat Script)
######################################################################################
# prosody-cloning.praat (Written by Kyuchul Yoon, kyoon@kyungnam.ac.kr)
# Given two utterances with corresponding textgrids (aligned by the segment), # this script copies the durations and/or the F0 and/or intensity contour
# from the native utterance, using the PSOLA algorithm. The two textgrids
# should have the same number of intervals, otherwise, an error message pops up. # The section below illustrates how to clone one or two or all three prosodic
# parameters from the native utterance to its corresponding nonnative utterance. # (D for duration, F for F0 contour, I for intensity contour)
# List of output files:	D-nonnative.wav, F-nonnative.wav, I-nonnative.wav, #	DF-nonnative.wav, DI-nonnative.wav, FI-nonnative.wav
#	DFI-nonnative.wav
######################################################################################
# (1) native D		PSOLA, modify nonnative D wrt/ native D # (2) native F	(a)	PSOLA, modify native D wrt/ nonnative D
#	(b)	PSOLA, copy native F to nonnative utterance # (3) native I	(a)=(2a)	PSOLA, modify native D wrt/ nonnative D
#	(b)	NON-PSOLA,copy native I to nonnative utterance # (4) native D + F	(a)=(1)	PSOLA, modify nonnative D wrt/ native D
#	(b)=(2b)	PSOLA, copy native F to nonnative utterance # (5) native D + I	(a)=(1)	PSOLA, modify nonnative D wrt/ native D
#	(b)=(3b)	NON-PSOLA, copy native I to nonnative utterance # (6) native F + I	(a)=(2a)	PSOLA, modify native D wrt/ nonnative D
#	(b)=(2b)	PSOLA, copy native F to nonnative utterance
#	(c)=(3b)	NON-PSOLA, copy native I to nonnative utterance # (7) native D + F + I (a)=(1)	PSOLA, modify nonnative D wrt/ native D
#	(b)=(2b)	PSOLA, copy native F to nonnative utterance
#	(c)=(3b)	NON-PSOLA, copy native I to nonnative utterance ######################################################################################
form Specify files and folders comment NATIVE utterance word natFolder native
word natSound_(with_dot_wav) native.wav
word natTextgrid_(with_dot_textgrid) native.TextGrid natural natTierOfSegment 1
comment NONNATIVE utterance word nonnatFolder nonnative
word nonnatSound_(with_dot_wav) nonnative.wav
word nonnatTextgrid_(with_dot_textgrid) nonnative.TextGrid natural nonnatTierOfSegment 1
comment New synthetic NONNATIVE utterances will be created here word outFolder_(to_be_created) clonedUtterances
endform ######################################## # CREATE FOLDER AND READ TEXTGRID FILES ########################################
system_nocheck mkdir 'outFolder$'
Read from file... 'natFolder$'/'natSound$'
Rename... natSoundObj durNatSound = Get total duration
Read from file... 'natFolder$'/'natTextgrid$'
Rename... natTextgridObj
natNumIntervals = Get number of intervals... natTierOfSegment Read from file... 'nonnatFolder$'/'nonnatSound$'
Rename... nonnatSoundObj durNonnatSound = Get total duration
Read from file... 'nonnatFolder$'/'nonnatTextgrid$'
Rename... nonnatTextgridObj
nonnatNumIntervals = Get number of intervals... nonnatTierOfSegment ################################################
# CHECK IF THE NUMBER OF INTERVALS ARE THE SAME ################################################
if (natNumIntervals <> nonnatNumIntervals)
exit WARNING! The number of intervals of the two textgrids are not the same! endif
################################################### # GET MANIPULATION OBJECTS FOR LATER DURATION SWAP ###################################################
select Sound natSoundObj
To Manipulation... 0.01 60 400
#noprogress To Manipulation... 0.01 60 400 Rename... natSoundManipObj
select Sound nonnatSoundObj To Manipulation... 0.01 60 400
# noprogress To Manipulation... 0.01 60 400 Rename... nonnatSoundManipObj ################################################# # GET PITCH TIER OF NATURAL FOR LATER PITCH SWAP #################################################
select Manipulation natSoundManipObj Extract pitch tier
Rename... natPitchObj ########################################################## # CREATE AN EMPTY DURATION TIER OBJECT FOR TWO UTTERANCES ##########################################################
Create DurationTier... natDurTier 0 durNatSound Create DurationTier... nonnatDurTier 0 durNonnatSound ##################################################### # GET DURATION RATIO OF EACH NONNATIVE INTERVAL WRT/
# CORRESPONDING NATIVE INTERVAL AND ADD POINTS TO # NONNATIVE DURATION TIER OBJECT
#####################################################
nonnatStartTime = 0
natStartTime = 0
for iInterval to nonnatNumIntervals select TextGrid nonnatTextgridObj
nonnatEndTime = Get end point... nonnatTierOfSegment iInterval nonnatIntervalDur = nonnatEndTime - nonnatStartTime storeNonnatStartTime = nonnatStartTime + 0.00000000001 nonnatStartTime = nonnatEndTime
# Get the ratio
select TextGrid natTextgridObj
natEndTime = Get end point... natTierOfSegment iInterval natIntervalDur = natEndTime - natStartTime
natStartTime = natEndTime
ratioOfInterval = natIntervalDur / nonnatIntervalDur # Insert a point to the duration tier
select DurationTier nonnatDurTier
Add point... storeNonnatStartTime ratioOfInterval Add point... nonnatEndTime ratioOfInterval
endfor ##################################################### # GET DURATION RATIO OF EACH NATIVE INTERVAL WRT/
# CORRESPONDING NONNATIVE INTERVAL AND ADD POINTS TO # NATIVE DURATION TIER OBJECT
#####################################################
nonnatStartTime = 0
natStartTime = 0
for iInterval to nonnatNumIntervals select TextGrid natTextgridObj
natEndTime = Get end point... natTierOfSegment iInterval natIntervalDur = natEndTime - natStartTime storeNatStartTime = natStartTime + 0.00000000001 natStartTime = natEndTime
# Get the ratio
select TextGrid nonnatTextgridObj
nonnatEndTime = Get end point... nonnatTierOfSegment iInterval nonnatIntervalDur = nonnatEndTime - nonnatStartTime nonnatStartTime = nonnatEndTime
ratioOfInterval = nonnatIntervalDur / natIntervalDur # Insert a point to the duration tier
select DurationTier natDurTier
Add point... storeNatStartTime ratioOfInterval Add point... natEndTime ratioOfInterval
endfor ################################## # CLONE NATIVE DURATIONS ONLY (1) ##################################
select Manipulation nonnatSoundManipObj # Store the original nonnatSoundManipObj Copy... copyNonnatSoundManipObj
plus DurationTier nonnatDurTier Replace duration tier
select Manipulation copyNonnatSoundManipObj Get resynthesis (PSOLA)
# Then we get a new synthetic nonnative sound (1): D only from native Rename... synNonnatSoundObjD
# Save the sound file in the output folder synSoundD$ = "D-" + nonnatSound$
Write to WAV file... 'outFolder$'/'synSoundD$'
# The manipulation object can be used later on: D only from native To Manipulation... 0.01 60 400
# noprogress To Manipulation... 0.01 60 400 Rename... synNonnatManipObjD
########################################################## # CLONE NONNATIVE DURATIONS ONLY (2a/3a) AND
# GET PITCH TIER OF MODIFIED NATURAL FOR LATER PITCH SWAP ##########################################################
select DurationTier natDurTier plus Manipulation natSoundManipObj Replace duration tier
select Manipulation natSoundManipObj Get resynthesis (PSOLA)
# Then we get a new synthetic native sound (2a): D only from nonnative Rename... synNatSoundObjD
# The manipulation object can be used later on: D only from nonnative To Manipulation... 0.01 60 400
# noprogress To Manipulation... 0.01 60 400 Rename... synNatManipObjD
Extract pitch tier Rename... synNatPitchObjD
############################# # CLONE F0 CONTOUR ONLY (2b) #############################
synSoundF$ = "F-" + nonnatSound$
select Manipulation nonnatSoundManipObj plus PitchTier synNatPitchObjD
Replace pitch tier
select Manipulation nonnatSoundManipObj Get resynthesis (PSOLA)
# Then we get a new synthetic nonnative sound (2b): F only from native Rename... synNonnatSoundObjF
Write to WAV file... 'outFolder$'/'synSoundF$' ####################################
# CLONE INTENSITY CONTOUR ONLY (3b) ####################################
synSoundI$ = "I-" + nonnatSound$
# Intensity object of the duration-copied native utterance (3a) select Sound synNatSoundObjD
# Get the intensity value in dB synNatSoundObjDIntensityValue = Get intensity (dB)
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... synNatSoundDIntensityObj Down to IntensityTier
Rename... synNatSoundDIntensityTierObj
# Intensity object of the original nonnative utterance select Sound nonnatSoundObj
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... nonnatSoundIntensityObj
# Inverse the intensity object by getting the maximum and subtracting self maxNonnat = Get maximum... 0 0 Parabolic
Formula... 'maxNonnat' - self # And make IntensityTier object Down to IntensityTier
Rename... nonnatSoundIntensityTierObj
# Multiply the nonnative utterance with its own inverse IntensityTier and then # by the IntensityTier of the synthetic natural D utterance
select Sound nonnatSoundObj
plus IntensityTier nonnatSoundIntensityTierObj Multiply
Rename... nonnatSoundInverseObj
plus IntensityTier synNatSoundDIntensityTierObj Multiply
# Before writing, adjust the average intensity value in dB Scale intensity... 'synNatSoundObjDIntensityValue'
# Another new synthetic nonnative sound (3b): I only from native Write to WAV file... 'outFolder$'/'synSoundI$' ##############################################
# CLONE DURATIONS + F0 CONTOUR (4a+4b)=(1+2b) ##############################################
synSoundDF$ = "DF-" + nonnatSound$ select Manipulation synNonnatManipObjD plus PitchTier natPitchObj
Replace pitch tier
select Manipulation synNonnatManipObjD Get resynthesis (PSOLA)
Rename... synNonnatSoundObjDF
Write to WAV file... 'outFolder$'/'synSoundDF$' ##################################################### # CLONE DURATIONS + INTENSITY CONTOUR (5a+5b)=(1+3b) #####################################################
synSoundDI$ = "DI-" + nonnatSound$
# Intensity object of the original natural utterance select Sound natSoundObj
# Get the intensity value in dB natIntensityValue = Get intensity (dB)
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... natIntensityObj
Down to IntensityTier Rename... natIntensityTierObj
# Intensity object of the duration-copied nonnative utterance select Sound synNonnatSoundObjD
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... synNonnatSoundIntensityObj
# Inverse the intensity object by getting the maximum and subtracting self maxNonnat = Get maximum... 0 0 Parabolic
Formula... 'maxNonnat' - self # And make IntensityTier object Down to IntensityTier
Rename... synNonnatSoundIntensityTierObj
# Multiply the nonnative utterance with its own inverse IntensityTier and then # by the IntensityTier of the natural utterance
select Sound synNonnatSoundObjD
plus IntensityTier synNonnatSoundIntensityTierObj Multiply
Rename... synNonnatSoundInverseObj plus IntensityTier natIntensityTierObj Multiply
# Before writing, adjust the average intensity value in dB Scale intensity... 'natIntensityValue'
Write to WAV file... 'outFolder$'/'synSoundDI$' ############################################################# # CLONE F0 CONTOUR + INTENSITY CONTOUR (6a+6b+6c)=(2a+2b+3b) #############################################################
synSoundFI$ = "FI-" + nonnatSound$
# Intensity object of the duration-copied native utterance select Sound synNatSoundObjD
# Get the intensity value in dB synNatIntensityValue = Get intensity (dB)
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... synNatIntensityObj Down to IntensityTier
Rename... synNatIntensityTierObj
# Intensity object of the F0-copied nonnative utterance select Sound synNonnatSoundObjF
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... synNonnatSoundIntensityObj
# Inverse the intensity object by getting the maximum and subtracting self maxNonnat = Get maximum... 0 0 Parabolic
Formula... 'maxNonnat' - self # And make IntensityTier object Down to IntensityTier
Rename... synNonnatSoundIntensityTierObj
# Multiply the nonnative utterance with its own inverse IntensityTier and then # by the IntensityTier of the natural utterance
select Sound synNonnatSoundObjF
plus IntensityTier synNonnatSoundIntensityTierObj
Multiply
Rename... synNonnatSoundInverseObj
plus IntensityTier synNatIntensityTierObj Multiply
# Before writing, adjust the average intensity value in dB Scale intensity... 'synNatIntensityValue'
Write to WAV file... 'outFolder$'/'synSoundFI$' ############################################################################## # CLONE DURATIONS + F0 CONTOUR + INTENSITY CONTOUR (7a+7b+7c)=(1+2b+3b)=(4+5) ##############################################################################
synSoundDFI$ = "DFI-" + nonnatSound$
# Intensity object of the native utterance select Sound natSoundObj
# Get the intensity value in dB natIntensityValue = Get intensity (dB)
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... natIntensityObj
Down to IntensityTier Rename... natIntensityTierObj
# Intensity object of the DF-copied nonnative utterance select Sound synNonnatSoundObjDF
To Intensity... 70 0
# noprogress To Intensity... 70 0 Rename... synNonnatSoundIntensityObj
# Inverse the intensity object by getting the maximum and subtracting self maxNonnat = Get maximum... 0 0 Parabolic
Formula... 'maxNonnat' - self # And make IntensityTier object Down to IntensityTier
Rename... synNonnatSoundIntensityTierObj
# Multiply the nonnative utterance with its own inverse IntensityTier and then # by the IntensityTier of the native utterance
select Sound synNonnatSoundObjDF
plus IntensityTier synNonnatSoundIntensityTierObj Multiply
Rename... synNonnatSoundInverseObj plus IntensityTier natIntensityTierObj Multiply
# Before writing, adjust the average intensity value in dB Scale intensity... 'natIntensityValue'
Write to WAV file... 'outFolder$'/'synSoundDFI$' select all
nocheck Remove
############### END OF SCRIPT ##################
