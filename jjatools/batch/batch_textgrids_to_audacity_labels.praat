# Convert TextGrid interval tier to Audacity label format
# Written by Jose Joaquin Atria (1 July 2013)
#
# Converts all TextGrid objects in the specified directory
# to Audacity labels and either saves them to external files
# or prints them to the Info window.
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/check_directory.proc
include ../procedures/require.proc
@require("5.3.44")

form TextGrids in directory to Audacity labels...
  comment Leave blank for GUI selector
  word TextGrid_directory
  integer Tier 1
  boolean Print_to_Info no
endform

@checkDirectory(textGrid_directory$, "Choose TextGrid directory...")
path$ = checkDirectory.name$

files = Create Strings as file list: "files", path$ + "*TextGrid"

n = Get number of strings
for i to n
  selectObject(files)
  filename$ = Get string: i
  textgrid = Read from file: path$ + filename$
  runScript: "textgrid_to_audacity_label.praat", tier, path$, print_to_Info
  removeObject(textgrid)
endfor
removeObject(files)
