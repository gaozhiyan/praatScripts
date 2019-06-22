# Save all selected objects to disk. By default, the script overwrites
# existing files and prints the number of saved objects to the Info
# screen. This behaviour can be changed by modifying the overwrite and
# verbose variables respectively.
#
# The first version of this script was written for the
# Laboratorio de Fonetica Letras UC
#
# Written by Jose J. Atria (18 November 2011)
# Complete re-write: February 27, 2014
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc
include ../procedures/check_directory.proc
include ../procedures/require.proc
@require("5.3.63")

form Save selected objects...
  sentence Save_to
  comment Leave empty for GUI selector
  boolean Overwrite no
endform

@checkDirectory(save_to$, "Save objects to...")
save_to$ = checkDirectory.name$

# Save selection
@saveSelectionTable()
original = saveSelectionTable.table

selectObject: original

# LongSound objects are already on disk, so it makes no sense to save them
writable_objects = Extract rows where column (text): "type",
  ... "is not equal to", "LongSound"
Append column: "extension"
Append column: "new_name"
Rename: "writable_objects"
total_objects = Object_'writable_objects'.nrow

# Determine the extension for each object type
for row to total_objects
  extension$ = Object_'writable_objects'$[row, "type"]
  extension$ = if extension$ = "Sound" then "wav" else extension$ fi
  Set string value: row, "extension", "." + extension$
endfor

# Counters are unique per type and name, so we need to
# determine how many types there are in the selection
types = Collapse rows: "type extension", "", "", "", "", ""
total_types = Object_'types'.nrow

# For each type subset
for type to total_types

  selectObject: types
  type$ = Object_'types'$[type, "type"]
  extension$ = Object_'types'$[type, "extension"]

  selectObject: writable_objects
  type_subset = Extract rows where column (text): "type",
    ... "is equal to", type$
  Rename: type$ + "_objects"

  # Find all unique names
  unique_names = Collapse rows: "name", "", "", "", "", ""
  Rename: "unique_names"

  # And for every unique name
  for name to Object_'unique_names'.nrow
    this_name$ = Object_'unique_names'$[name, "name"]

    selectObject: type_subset
    same_name = Extract rows where column (text): "name",
      ... "is equal to", this_name$

    # Determine if it is repeated to see if padding is necessary
    repeated = Object_'same_name'.nrow
    for same to repeated
      id = Object_'same_name'[same, "id"]
      selectObject: writable_objects
      row = Search column: "id", string$(id)
      new_name$ = if repeated > 1 then 
        ... this_name$ + "." + string$(same) else this_name$ fi
      Set string value: row, "new_name", new_name$
    endfor
    removeObject: same_name
  endfor
  removeObject: unique_names, type_subset
endfor
removeObject: types

# Save individual files
for i to Object_'writable_objects'.nrow
  selectObject: writable_objects
  id         = Object_'writable_objects' [i, "id"]
  name$      = Object_'writable_objects'$[i, "new_name"]
  type$      = Object_'writable_objects'$[i, "type"]
  extension$ = Object_'writable_objects'$[i, "extension"]

  # Despite padding, that file already exists
  # Ask for a new one, or overwrite
  filename$ = name$ + extension$
  if !overwrite and fileReadable(save_to$ + filename$)
    beginPause: "File exists"
    comment: "A new name for this object was generated, but it already exists on disk"
    comment: "Provide a new one or overwrite this file"
    sentence: "New_name", filename$
    boolean: "Overwrite_all", 0
    button = endPause: "OK", 1
    overwrite = if overwrite_all then 1 else overwrite fi
    filename$ = new_name$
  endif

  # Actually save the files
  selectObject: id
  if type$ = "Sound"
    Save as WAV file: save_to$ + filename$
  else
    Save as text file: save_to$ + filename$
  endif
endfor
removeObject: writable_objects

@restoreSavedSelection(original)
removeObject: original
