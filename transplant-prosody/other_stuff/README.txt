*************************************
** PROSODIC TRANSPLANTATION SCRIPT **
**           VERSION 0.7           **
**                -                **
**     MADE WITH PRAAT 6.0.21      **
*************************************

*Patch Notes*
VERSION 0.7
- tweaked SPL normalisation and echo reduction
VERSION 0.6
- added more refined user interface allowing for full automatic and manual transplantation
VERSION 0.5
- added ERB correction of donor pitch contour for mean pitch of receiver pitch contour
VERSION 0.4
- added automatic syllable-mismatch detection
- added automatic pause insertion
- added support for multiple receivers and donors per sentence
- interface changes
VERSION 0.3
- added Sound Pressure Level (SPL) normalisation of receiver files
- added SPL reduction of pauses

*Usage*
> Praat > Open Praat script > transplantProsody_v0.5.praat > Open
> Run > Run
> Give sentence label (e.g. CV1)
> Fill out the complete path to folder containing donor and receiver files
> Provide path to output folder
> OK
- At this point you might get an error for some sentences. As of version 0.7 this problem is unresolved. Please try another sentence.
- If all goes well another pop-up screen will appear.
> Specify whether you would like manual control over speaker and prosody combinations.
> Continue
- If you opted for automatic speaker selection:
  > Choose the mother tongue of the receiver.
  > Continue
- If you opted for manual speaker selection:
  > Provide receiver and donor labels (these can be found in the table accompanying this pop-up screen)
  > Continue
- If you opted for manual prosody selection:
  > Select the manipulations you would like to carry out.
  >Continue
- If you opted for automatic prosody selection or selected intonation as a transplantation parameter:
  > Choose the optimal settings for pitch analysis of both speakers
  > Continue
- The script will now take a few minutes to carry out all transplantations
- The resynthesised sound files should be saved to the output folder you specified at the start
- TIP: By viewing the manipulation objects, you can get a visual representation of what has been changed.

*Assumptions*
- .wav files and corresponding .TextGrid files have identical names (except for extension) according to the following template: [sentence_label]-[L1|L2]_[speaker_identifier].[wav|TextGrid]
- .wav files and corresponding .TextGrid files are located in the same folder.
- When providing file paths use forward slashes "/" (the Unix & OSX standard).
- Corresponding donor and receiver TextGrids have the same amount of syllable intervals. An uneven syllable amount should now be handled by the script. Realizations that have a different amount of syllables for a word compared to the majority of productions are ignored. Differences in syllable intervals as a result of the presence or absence of pauses are resolved by automatically inserting a small empty interval at relevant times. The script throws a warning message if the two TextGrids somehow still differ in syllable count.
- Both TextGrids have empty intervals either side of the actual utterance.

*Missing Functionality*
- Handling of multiple sentences
- Normalisation of donor intensity
- Gender-based pitch analysis
