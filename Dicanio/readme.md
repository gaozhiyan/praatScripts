Praat Sciprts taken from [Dr. Christian DiCanio](https://www.acsu.buffalo.edu/~cdicanio/scripts.html) at The State University of New York at Buffalo 

### Includes:

#### Spectral Analysis / Phonation Analysis scripts

[EGG Open quotient Extraction script for Matlab](https://www.acsu.buffalo.edu/~cdicanio/scripts/egg_analysis.m) which prints EGG maxima, EGG minima, DEGG maxima, DEGG minima, Period duration, Open quotient, and Closed quotient. Requires an input directory (*input_dur*) and an output directory (*output_dir*). Special thanks to Sam Tilsen. 

[Formant Script for Praat (time normalized)](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Formants.praat) which extracts F1, F2, and F3 at even intervals in time over the duration of each textgrid-delimited region of a sound file. Works iteratively over a directory. 

[Formant Script for Praat (not time-normalized)](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Formants_nonnormalized.praat) which extracts F1, F2, and F3 at even intervals in time starting from the location of a user-specified interval. Users specify the duration over which they wish to extract formant measures. Works iteratively over a directory. 

[General vowel acoustics script for Praat (version 2.0)](https://www.acsu.buffalo.edu/~cdicanio/scripts/Vowel_Acoustics.praat) which extracts mean formant values, the first four spectral moments, and F0 dynamically across a duration defined by the textgrid. Duration is also extracted. The number of interval values extracted is equal to the value "numintervals." This script works iteratively across a directory. 

[Vowel acoustics script for corpus data analysis.](https://www.acsu.buffalo.edu/~cdicanio/scripts/Vowel_Acoustics_for_corpus_data.praat) This script extracts mean formant values, the first four spectral moments, and F0 dynamically across a duration defined by the textgrid. Duration is also extracted. The number of interval values extracted is equal to the value "numintervals." This script works iteratively across a directory and includes contextual information in the output, such as lexical identity, and the preceding/following segment identities. 

[Spectral Envelope Script for Praat](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Spectral_Envelope.praat) which divides a sound file into chunks and extracts long-term average spectra at intervals throughout the sound file. The user specifies the size of each averaged spectrum amplitude bin, e.g. bins of 100 Hz. or 50 Hz., etc. Spectra are calculated dynamically across the duration defined by the textgrid. The number of interval values extracted is equal to the value "numintervals." 

[Spectral Tilt Script for Praat](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Spectral_Tilt_2.praat) which extracts H1-H2, H1-A1, H1-A2, and H1-A3 at even intervals in time over the duration of each textgrid-delimited region of a sound file. This script also determines pitch and formant values over the same intervals. Recently revised to work iteratively across a directory and to provide HNR values. 

[Spectral moments of fricative spectra script in Praat](https://www.acsu.buffalo.edu/~cdicanio/scripts/Time_averaging_for_fricatives_2.0.praat) which extracts the first four spectral moments (center of gravity, standard deviation, skewness, and kurtosis) as well as the global intensity and duration for each fricative. The DFTs are averaged using time-averaging (Shadle 2012). Within time-averaging, a number of DFTs are taken from across the duration of the fricative. These DFTs are averaged for each token and then the moments are calculated. The user can specify the DFT number, the DFT window duration, and the low pass filter cut-off (set to 300 Hz., as per Maniwa and Jongman, 2009). Updated 2017 to fix an issue with intensity measurement. 

#### Duration, Pitch, and Rate scripts

[Boundary Extractor Script for Praat](https://www.acsu.buffalo.edu/~cdicanio/scripts/Boundary_Extractor.praat) which extracts the start and end boundaries for all boundaries in a textgrid. This script works iteratively across a directory.

[Duration Script for Praat ](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_duration_2.0.praat)which extracts the duration of each textgrid-delimited duration in a sound file. 

[Pitch Script for Praat ](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_pitch.praat)which extracts pitch values at even intervals in time over the duration of each textgrid-delimited region of a sound file. 

[Pitch Dynamics Script for Praat, version 6](https://www.acsu.buffalo.edu/~cdicanio/scripts/Pitch_Dynamics_6.praat) which provides duration and dynamic F0 values for all files in a directory. In addition to providing these, the F0 maxima and minima and their locations are also calculated. The location of the F0 maxima and minima are normalized. The user can specify the octave jump cost and other variables. If the user has lexemic or syllabic segmentation on additional tiers, this information will also be extracted. New features include the ability to specify the buffer size for F0 tracking and data filtering for excluding short tokens (e.g. less than 50 ms). Version 6 improves memory use in Praat. 

[Pitch Dynamics for declination data. ](https://www.acsu.buffalo.edu/~cdicanio/scripts/Pitch_Dynamics_for_declination_data.praat)This script is similar to Pitch Dynamics 5.0 above, though it also tracks utterance and syllable number in a labelled sound file. If the user wishes to examine F0 changes across an utterance, this script is ideal for this purpose. 

[Speech Rate Script for Praat](https://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Rate.praat) which prints a syllables per second measure. Requires that there be a textgrid tier with syllables already labelled and another with a label for each repetition in the sound file, e.g. one tier with 5 intervals labelled for 5 repetitions, another with each syllable labelled. 



#### TextGrid modification scripts

[Combine/Merge intervals in Praat.](https://www.acsu.buffalo.edu/~cdicanio/scripts/Combine_intervals.praat) This script allows the user to merge any two adjacent intervals in a TextGrid and relabel them. 

[Insert VOT components for stops in Praat.](https://www.acsu.buffalo.edu/~cdicanio/scripts/Insert_components.praat) This script reads a textgrid file and creates a tier with component labels for stop consonants. Four components may be included, e.g. voiced closure duration, voiceless closure duration, release burst, and aspiration. However, the user can specify whatever names they prefer for each. This script requires that there already be a segmentation of the speech signal into phone-sized units. Note that this script *does not segment* stops into components. It simply puts the labels down on an interval tier for the user to more easily do it her/himself. 

[Silent Replacement Script for Praat.](https://www.acsu.buffalo.edu/~cdicanio/scripts/Replace_with_Silence.praat) For all portions of a textgrid which have no label, this script replaces the portion with absolute silence (zero amplitude). This script is useful for anyone wanting to "clean up" sound files which have additional unwanted information in the recording. 

[Text Replacement Script for Praat.](https://www.acsu.buffalo.edu/~cdicanio/scripts/Replace_labels.praat) For all portions of a textgrid which have label x, this script replaces the label with y. If you wish to replace labeled portions with no label or unlabeled portions *with* a label, use two double quotations for the unlabeled interval. 

[
](https://www.acsu.buffalo.edu/~cdicanio/scripts/Combine_intervals.praat)

