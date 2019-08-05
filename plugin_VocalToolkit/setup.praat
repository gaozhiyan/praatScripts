# Praat Vocal Toolkit
# A Praat plugin with automated scripts for voice processing
# http://www.praatvocaltoolkit.com
# This plugin is open source and can be used for any purpose

if praatVersion < 6046
	beginPause: "Praat Vocal Toolkit - Unsupported Praat version"
		comment: "“Praat Vocal Toolkit” requires Praat version 6.0.46 or higher."
		comment: "Your version of Praat is " + praatVersion$ + ". Please update it at ""http://www.praat.org""."
	endPause: "OK", 1, 1
else
	runScript: "buttons.praat"
endif
