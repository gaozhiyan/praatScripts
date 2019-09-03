#################################################################################
# clone-prosody.praat ( Written by Kyuchul Yoon kyoon@kyungnam.ac.kr )
#################################################################################
# Given two utterances with corresponding textgrids (aligned by the segment),
# the script copies the durations and the F0 and intensity contour from the
# native utterance, using the PSOLA algorithm. The two textgrids should have the
# same number of intervals, otherwise, an error message pops up.
#################################################################################
form Specify files and folders
 comment Original sound
 word natFolder origKwon
 word natSound_(with_dot_wav) origKwon_cheap.wav
 word natTextgrid_(with_dot_textgrid) origKwon_cheap.TextGrid
 natural natTierOfSegment 1
 comment Processee sound
 word nonnatFolder procKim
 word nonnatSound1_(with_dot_wav) procKim_cheap.wav
 word nonnatTextgrid1_(with_dot_textgrid) procKim_cheap.TextGrid
 natural nonnatTierOfSegment 1
 comment NEW processed sounds will be created here
 word outFolder_(to_be_created) synthetic
endform
###############################
# CREATE FOLDER AND READ FILES
###############################
system_nocheck mkdir 'outFolder$'
Read from file... 'natFolder$'/'natTextgrid$'
Rename... natTextgridObj
natNumIntervals = Get number of intervals... natTierOfSegment
Read from file... 'nonnatFolder$'/'nonnatTextgrid1$'
Rename... nonnatTextgridObj1
nonnatNumIntervals1 = Get number of intervals... nonnatTierOfSegment
###########################################
# CHECK IF THE NUMBER OF INTERVALS ARE THE SAME
###########################################
if (natNumIntervals <> nonnatNumIntervals1)
 pause WARNING! The number of intervals of the two textgrids are not the same!
else

 ####################################
 ### MAIN FUNCTION: DURATION SWAP ###
 ####################################
 ###################################################
 # GET MANIPULATION OBJECTS FOR LATER DURATION SWAP
 ###################################################
 Read from file... 'nonnatFolder$'/'nonnatSound1$'
 Rename... nonnatSoundObj1
 durNonnatSound1 = Get total duration
 To Manipulation... 0.01 60 400
 Rename... nonnatSoundManipObj1
 #################################################
 # GET PITCH TIER OF NATURAL FOR LATER PITCH SWAP
 #################################################
 Read from file... 'natFolder$'/'natSound$'
 Rename... natSoundObj
 To Manipulation... 0.01 60 400
 Rename... natSoundManipObj
 Extract pitch tier
 Rename... natPitchObj
 ##############################################################
 # CREATE AN EMPTY DURATION TIER OBJECT FOR THE NONNATIVE UTTERANCE
 ##############################################################
 Create DurationTier... durTier1 0 durNonnatSound1
 #############################################
 # NONNATIVE TEXTGRID: GET DURATION RATIO
 # FOR EACH INTERVAL BTW/ NATIVE AND NONNATIVE
 # AND ADD POINTS TO DURATION TIER OBJECT
 #############################################
 # With nonnatTextgridObj1, get the ratio of each interval wrt/ the natTextgridObj
 nonnatStartTime = 0
 natStartTime = 0
 for iInterval to nonnatNumIntervals1
 select TextGrid nonnatTextgridObj1
 nonnatEndTime = Get end point... nonnatTierOfSegment iInterval
 nonnatIntervalDur = nonnatEndTime - nonnatStartTime
 storeNonnatStartTime = nonnatStartTime + 0.00000000001
 nonnatStartTime = nonnatEndTime
 # Get the ratio
 select TextGrid natTextgridObj
 natEndTime = Get end point... natTierOfSegment iInterval
 natIntervalDur = natEndTime - natStartTime
 natStartTime = natEndTime
 ratioOfInterval = natIntervalDur / nonnatIntervalDur
 # Insert a point to the duration tier
 select DurationTier durTier1
 Add point... storeNonnatStartTime ratioOfInterval
 Add point... nonnatEndTime ratioOfInterval
 endfor
 #################
 # SWAP DURATIONS
 #################
 select DurationTier durTier1
 plus Manipulation nonnatSoundManipObj1
 Replace duration tier
 select Manipulation nonnatSoundManipObj1
 Get resynthesis (PSOLA)
 To Manipulation... 0.01 60 400
 Rename... newSoundManipObj1
 ###################
 ### PITCH SWAP ###
 ###################
 ######################################
 # SWAP PITCH AND WRITE THE NEW SOUNDS
 ######################################
 newSound1$ = "duration&F0-" + nonnatSound1$
 select Manipulation newSoundManipObj1
 plus PitchTier natPitchObj
 Replace pitch tier
 select Manipulation newSoundManipObj1
 Get resynthesis (PSOLA)
 Rename... nonnatSoundPSOLAObj1
 Write to WAV file... 'outFolder$'/'newSound1$'
 select DurationTier durTier1
 prefix1$ = nonnatSound1$ - "wav"
 durTierFileName1$ = prefix1$ + "DurationTier"
 Write to text file... 'nonnatFolder$'/'durTierFileName1$'
 ######################
 ### INTENSITY SWAP ###
 ######################
 #########################################
 # SWAP INTENSITY AND WRITE THE NEW SOUND
 #########################################
 completeSound1$ = "duration&F0&intensity-" + nonnatSound1$
 # Intensity object of the native utterance
 select Sound natSoundObj
 # Get the intensity value in dB
 natIntensityValue = Get intensity (dB)
 To Intensity... 70 0
 Rename... natIntensityObj
 Down to IntensityTier
 Rename... natIntensityTierObj
 # Intensity object of the 1st nonnative utterance
 select Sound nonnatSoundPSOLAObj1
 To Intensity... 70 0
 Rename... nonnatSoundPSOLAIntensityObj1
 # Inverse the intensity object by getting the maximum and subtracting self
 maxNonnat = Get maximum... 0 0 Parabolic
 Formula... 'maxNonnat' - self
 # And make IntensityTier object
 Down to IntensityTier
 Rename... nonnatSoundPSOLAIntensityTierObj1
 # Multiply the nonnative utterance with its own inverse IntensityTier and then
 # by the IntensityTier of the native utterance
 select Sound nonnatSoundPSOLAObj1
 plus IntensityTier nonnatSoundPSOLAIntensityTierObj1
 Multiply
 Rename... nonnatSoundPSOLAInverseObj1
 plus IntensityTier natIntensityTierObj
 Multiply
 Rename... completeSoundObj1
 # Before writing, adjust the average intensity value in dB
 Scale intensity... 'natIntensityValue'
 Write to WAV file... 'outFolder$'/'completeSound1$'
endif
################# END OF SCRIPT #################