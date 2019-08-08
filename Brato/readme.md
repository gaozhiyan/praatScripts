Praat Scripts taken from [Dr. Thorsten Brato](https://www.uni-regensburg.de/language-literature-culture/english-linguistics/staff/brato/praat-scripts/index.html) at Universität Regensburg

### Includes:

#### TB-Basic Vowel Analysis (V2.2)

This is a basic script for vowel formant analysis. The script goes through specified folders for sound files and TextGrids, searches for pairs, measures formants 1-3 (separated by monophthongs and diphthongs) and writes the results to a .txt file that can be submitted to the NORM script on The Vowel Normalization and Plotting Suite website or the vowels package for R for plotting and vowel normalisation. See the script for a more detailed description and requirements.

#### TB-Track Vowels (V2-deprecated)

Vowel tracking refers to taking a number of consecutive vowel formant measurements across the vowel's duration in order to find out more about the vowel formant dynamics (e.g. Fox & Jacewicz 2009) than would be possible by single (e.g. midpoint) or two-point (onset and glide) measurements alone. In the current script this is implemented in a number of ways and users can use the form to choose between four options:

three-point (Onset (20%), Midpoint (50%), Glide (80%))

11-point (10% intervals (0/10/20/30/40/50/60/70/80/90/100%)), following Hoffmann (2011)

5-point (15% intervals (20/35/50/65/80%)), following Fox & Jacewicz (2009)

13-point (Combine options 2 and 3 (0/10/20/30/35/40/50/60/65/70/80/90/100%))

The script will automatically go through all files in specified folders, collect data from up to four tiers of annotated speech and log a range of phonetic (f1-f3 formants and bandwiths at the temporal points specified, vowel durations, pitch, intensity) and meta ( speaker label, vowel label, file name, style, word, etc.) data and write them to tab-delimited text file that can be opened in Excel or R for further analyses.

**References:**

Fox, Robert A. & Ewa Jacewicz. 2009. “Cross-dialectal variation in formant dynamics of American English vowels”. Journal of the Acoustical Society of America 126, 2603–2618.

Hoffmann, Thomas. 2011. “The Black Kenyan English vowel system: An acoustic phonetic analysis”. English World-Wide 32, 147–173.

#### TB-Obstruent analyis (deprecated)

This script collects a large range of measurements relevant for the acoustic study of plosives and affricates (and to some degree also fricatives) and outputs them to a .txt that can be subjected to further analysis in e.g. Excel or R. It was developed in the context of a study on the realisation of /t/ in Ghanaian English (e.g. Brato 2015), but should be applicable to more general research contexts. I tried to annotate it extensively, so that other users can adopt, adapt and improve it according to their needs.

Among other things the script takes the following measurements: durations of segments and parts thereof, mean intensity, rise time, burst intensity, zero-crossing-rate, spectral moments (centre of gravity, standard deviation, skewness, kurtosis)


Note that there are four files in the zip file, which all must be extracted to the same folder for the script to work.

**Reference:**

Brato, Thorsten. 2015. “A pilot study of acoustic features of word-final affricated /t/ and /ts/ in educated Ghanaian English”. In Rita Calabrese, J. K. Chambers & Gerhard Leitner (eds.), Variation and Change in Postcolonial Contexts. Newcastle: Cambridge Scholars Publishing, 61–78.
