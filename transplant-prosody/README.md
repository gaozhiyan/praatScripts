## Dependencies
- [Praat](http://www.fon.hum.uva.nl/praat/)

## Formatting
Audio files should be annotated as follows:

![alt text](https://github.com/timjzee/transplant-prosody/blob/master/textgrid_format.png?raw=true "TextGrid format")

.wav and .TextGrid files should be named as follows:

| Sentence ID   |     | Nativeness    |     | Proficiency  |     | Speaker No. | Extension   |
|:-------------:|:---:|:-------------:|:---:|:------------:|:---:|:-----------:|:-----------:|
| `CV4`         | `-` | `L2`          | `_` | `B1`         | `_` | `4`         | `.wav`      |
| `CVC1`        | `-` | `L1`          |     |              | `_` | `2`         | `.TextGrid` |

## Requirements
- .wav files and corresponding .TextGrid files should be located in the same folder.
- When providing file paths use forward slashes "/" (the POSIX standard).
- Corresponding donor and receiver TextGrids should have the same amount of syllables. Realizations that have a different amount of syllables for a word compared to the majority of productions are ignored. Differences in syllable intervals as a result of the presence or absence of pauses are resolved by automatically inserting a small empty interval at relevant times. The script throws a warning message if the two TextGrids somehow still differ in syllable count.
- Both TextGrids should have empty intervals either side of the actual utterance (see TextGrid above).

## Usage
- Before transplantation, use Praat's pitch analysis to find the best settings (time step, min Hz, max Hz). You will need these settings for each audio file.
- Download the transplantProsody.praat file in this repository.
- Praat > Open Praat script > transplantProsody.praat > Open
- Run > Run
- Give sentence label (e.g. CV1).
- Fill out the complete path to folder containing donor and receiver files.
- Provide path to output folder.
- OK
- Specify whether you would like manual control over prosody combinations.
- Continue
- Provide receiver and donor labels (these can be found in the table accompanying this pop-up screen)
- Continue
- If you opted for manual prosody selection:
  - Select the manipulations you would like to carry out.
  - Continue
- Choose the optimal settings for pitch analysis of both speakers.
- Continue
- The script will now take a few minutes to carry out all transplantations.
- The resynthesised sound files should be saved to the output folder you specified at the start.
- By viewing the manipulation objects, you can get a visual representation of what has been changed.

## Schematic overview

![alt text](https://github.com/timjzee/transplant-prosody/blob/master/figure_final.png?raw=true "Overview")
