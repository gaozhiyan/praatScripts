s# = selected# ("Sound")

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

selectObject: s#

beginPause: "Update EQ presets list"
	comment: "EQ presets list has been updated."
endPause: "OK", 1, 1
