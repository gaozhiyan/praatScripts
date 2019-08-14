# Batch generation of Pitch objects using Hirst's two-pass method
# Written by Jose Joaquin Atria (2 July 2014)
#
# Generates a Pitch object for each Sound object in the target directory
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

form Batch to Pitch (Hirst two-pass)...
  positive Floor_factor 0.75
  positive Floor_factor 1.5 (=use 2.5 for expressive speech)
  comment For a large number of files, use batch mode to process one at a time and clear object list
  boolean Batch_mode yes

  comment Leave paths blank for GUI selector
  sentence Read_from
  sentence Save_to
endform

extension$ = "wav"

@checkDirectory(read_from$, "Read sounds from...")
read_from$ = checkDirectory.name$

if batch_mode
  @checkDirectory(save_to$, "Save Pitch objects to...")
  save_to$ = checkDirectory.name$
endif

files = Create Strings as file list: "files", read_from$ + "*" + extension$

n = Get number of strings
for i to n
  selectObject: files
  filename$ = Get string: i
  source = Read from file: path$ + filename$
  runScript: "to_pitch_two-pass.praat", floor_factor, ceiling_factor
  new[i] = selected("Pitch")
  removeObject: source

  if batch_mode
    # In batch mode, generated pitch objects are saved to disk and
    # removed from the object list as they are created
    Save as text file: save_to$ + (filename$ - extension$ + "Pitch")
    removeObject: new[i]
  endif
endfor

removeObject: files

if !batch_mode
  for i to n
    plusObject: new[i]
  endfor
endif
