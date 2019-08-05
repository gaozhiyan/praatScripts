form Analyse to EQ preset
	sentence New_EQ_preset_name untitled
endform

new_EQ_preset_name$ = left$(replace_regex$(replace$(new_EQ_preset_name$, " ", "_", 0), "[^0-9a-zA-Z_]", "", 0), 32)

if new_EQ_preset_name$ = "" or new_EQ_preset_name$ = "untitled"
	exitScript: "Please enter some name."
endif

s = selected("Sound")
sf = Get sampling frequency
sf_max = max(sf, 44100)

if sf <> sf_max
	rs = Resample: sf_max, 50
endif

runScript: "ireq.praat"
Save as binary file: "eq/" + new_EQ_preset_name$ + ".Sound"
Remove

if sf <> sf_max
	removeObject: rs
endif

Create Strings as file list: "list", "eq/*.Sound"
numberOfFiles = Get number of strings
for i to numberOfFiles
	fileName$[i] = Get string: i
endfor
Remove

txt$ = ""
for i to numberOfFiles
	l = length(fileName$[i]) - 6
	fileName$ = left$(fileName$[i], l)
	txt$ = txt$ + "option " + fileName$ + newline$
endfor
writeFile: "eqpresetslist.inc", txt$

selectObject: s

beginPause: "Analyse to EQ preset"
	comment: "New EQ preset has been saved as “" + new_EQ_preset_name$ + "”."
endPause: "OK", 1, 1
