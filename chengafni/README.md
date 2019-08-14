# Plugins for Praat

* This repository contains some plugins for Praat. Each plugin adds functions to Praat's menus.
* To install a plugin, download its zip file and unzip it in your Praat's preference folder. If you don't know where Praat's preference folder is located, download *praatPrefDir.praat* and run it in Praat: on the *Praat* menu select *Open Praat script...*, select *praatPrefDir.praat* and click *Run* in the *Run* menu.
* Once a plugin folder is placed in Praat's preference folder, starting Praat will automatically add the functions included in the plugin to the appropriate menus of Praat.
* If you do not wish to install the plugins, you can simply open the scripts in Praat when needed and run them. Some plugins contain two scripts: the script whose name contains the word "Editor" operates inside the Sound editor; the other script operates on an object (e.g., an intensity object) in the objects window.
* There are several types of plugins in the repository: (1) "Align intervals" adds content to a TextGrid object, (2) several other plugins measure certain acoustic parameters, and (3) "Complete analysis" (the last plugin on the list) is a "super-program" that automatically measures any number of selected acoustic parameters on complete Sound and TextGrid objects.

List of plugins:
## 1) Align intervals
* Download: plugin_AlignIntervals.zip
* Aligns all intervals on a selected TextGrid tier.
* The plugin adds the command *Align all intervals* to the Interval menu of the TextGrid editor.
* Put cursor in the tier of interest and invoke the *Align all intervals* command. 

## 2) Formant transitions
* Download: plugin_formantTrans.zip.
* Calculates start and end values of F1, F2, F3 in a selected sound fragment.
* The plugin adds the command *Formant transitions* at the end of the *Formant* menu of the Sound and TextGrid editors.

## 3) High-to-Low spectral band energies
* Download: plugin_HL.zip.
* Calculates energy ratio between high and low frequency bands (H/L).
* The plugin adds the command *Get H/L* after the command *Get band density difference...* in the *Query* menu for Spectrum objects.

## 4) Hammarberg index
* Download: plugin_HammarbergIndex.zip
* Calculates the Hammarberg index of the Ltas object.
* Hammarberg index (see: Hammarberg et al., 1980) = the difference between the maximum of the LTAS curve in the range 0-2000 Hz and the LTAS curve in the range 2000-5000 Hz.
* The plugin adds the command *Get Hammarberg index* at the bottom of the *Query* menu for Ltas objects.

## 5) Mean Intensity slope
* Download: plugin_IntensitySlope.zip
* Calculates the mean slope of the intensity curve (in dB/s).
* Two methods: 
    1. raw: the direction of local changes in the intensity curve is taken into account; 
    2. aboslute: the direction of local changes in the intensity curve is disregarded.
* The plugin adds the command *Get mean slope* to the following menus: 
   * Objects window: at the bottom of the *Query* menu for Intensity objects.
   * Sound and TextGrid editors: at the bottom of the *Intensity* menu.

## 6) Peak-to-average ratio
* Download: plugin_PA.zip.
* Calculates Peak-to-Average (P/A) ratio of sound amplitude (see: Hillenbrand et al., 1994).
* The plugin adds the command *Get peak to average ratio* after the command *Get standard deviation...* in the *Query* menu for Sound objects.

## 7) Pitch peak latency
* Download: plugin_PitchPeakLatency.zip.
* Calculates the peak latency of the Pitch contour. 
* Peak latency: the time interval between the start of the interval and the point of maximum pitch, divided by the duration of the interval (0.5 = pitch maximum is mid-interval).
* The plugin adds the command *Get peak latency* to the following menus: 
    * Objects window: after the command *Get time of maximum...* in the *Query* menu for Pitch objects.
    * Sound and TextGrid editors: at the bottom of the *Pitch* menu.

## 8) Spectral emphasis 
* Download: plugin_SpectralEmphasis.zip
* Calculates the intensity (in dB) contained in the high-frequency band of a sound signal. This is accomplished by low-pass filtering the sound signal and calculating the intensity lost in the process (See: Traunmüller and Eriksson, 2000). This measure is used in voice quality analysis.
* The plugin adds the command *Get spectral emphasis* to the following menus: 
    * Objects window: at the bottom of the *Query* menu for Sound objects.
    * Sound and TextGrid editors: at the bottom of the *Spectrum* menu.

## 9) Label words
* Download: plugin_LabelWords.zip
* Annotates a sound object according to a list of labels.
* The list of labels should be stored in a tab-separated text file. To use the script, select a sound object in Praat's objects window and run the script. On first run, you will be asked to select the file labels from the disk. The script is designed to handle cases in which the number of recorded sections is larger than the number of labels due to multiple repetitions of words. In such cases, the script will halt and display an error message when the list of labels has been exhausted. To resume the annotation, find the number of the first mislabeled TextGrid interval and the number of the first misidentified label. Then, re-run the script, un-check the "first attempt" check box and replace the values of "start interval" and "start word" with the values you wish to continue from.
* The plugin adds the command *Label words* after the command *To TextGrid (silences)...* in the *Annotate* menu for Sound objects.

## 10) Complete analysis
* Download: plugin_CompleteAnalysis.zip
* An extensive acoustic analysis of Sound objects in the Sound editor (non-annotated sounds) or TextGrid editor (annotated sounds) of Praat.

### Description
* This script performs an extensive acoustic analysis of Sound objects in the Sound editor (non-annotated sounds) or TextGrid editor (annotated sounds) of Praat.
* It can automatically measure any number of acoustic parameters for all intervals in a given tier and also run on all TextGrid tiers.
* The result is a table containing the list of intervals and the values of the measured parameters. The name of the tier, the start time and duration of each interval are also included. The other measured parameters are taken from an external text file.
* The script is distributed as part of a plugin named "plugin_CompleteAnalysis". When the plugin is installed, it adds the command "Complete analysis" at the bottom of the "Query" menu of the Sound and TextGrid editors.

### Requirements
* The script requires a Sound (and optionally, a TextGrid) object open in the editor. In addition, the script requires three tabulated text files, which should be placed in the same folder as the script:
1. settings.txt: the file contains commands that adjust the settings of various parts of the editor (e.g., pitch floor and ceiling, number of formants, etc.). These settings will apply automatically before the analysis starts.
2. objects.txt: the file contains the commands that generate objects during the analysis (e.g., Spectrum). The acoustic parameters are obtained by querying these obejcts.
3. commands.txt: the file contains the query commands for the various acoustic paramteres.
* The above mentioned text files are distributed alongside the script, as part of the plugin. They can be edited freely (e.g., adding/removing commands, changing the input arguments of commands). The plugin also contains an Excel file named "Sound editor tables.xls", which contains these tables as separate sheets. This provides an easy way to edit the tables (after editing the file, the modified table should be saved as a Tab-delimited text file).

### Usage
* Select a part of the sound (e.g., some interval in a tier of interest), and run the script.
* You'll be presented with several dialog boxes:
1. Type of analysis: contains the following checkboxes:
   - "automatic": analyze all intervals in the selected tier. If unchecked, only the selected interval will be analyzed.
   - "all tiers": analyze all tiers in the TextGrid. If unchecked, only the selected tier will be analyzed.
	- "continued": add rows to an existing analysis table (e.g., to add previously unanalyzed tiers).
	- "appended": add columns to an existing analysis table (e.g., to add previously unqueried parameters).
2. If either "continued" or "appended" checkboxes was checked in the first dialog, you will be asked whether to load an existing analysis table from disk. If the loadTable checkbox is checked, you will be prompted to supply the file containing the results of the previous analysis. If the checkbox is unchecked, the script assumes that a Table object named "analysis" is present in Praat's objects list.
3. you will be asked if you want to select which objects to query. If the "select objects" checkbox is checked you will be presented with a list of objects. Uncheck the objects you don't want to query.
4. you will be asked if you want to select which queries to perform. If the "select queries" checkbox is checked you will be presented with one or more lists of parameters. If you unchecked one or more objects in the previous step, only the parameters relevant to the objects you selected will be displayed. Uncheck the parameters you don't want to query.

* Note: if you continue previous analysis, make sure that all the checked parameters are listed in the analysis table. If you want to query both new intervals and parameters check both the 'continued' and 'appended' checkboxes.

* The analysis will be performed and the results will be entered into a table object named "analysis".
