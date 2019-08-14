# Normalise all sounds in a given directory using RMS normallisation
#
# Written by Jose J. Atria (29 May 2014)
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.
#
# TODO: set sounds to specified RMS

include ../procedures/check_directory.proc
include ../procedures/require.proc
@require("5.3.63")

form RMS normalisation...
  sentence Read_from
  sentence Save_to
  comment Normalised sounds will be saved in specified directory. Leave empty for GUI selector
  word Sound_extension wav
  boolean Keep_conversion_table no
endform

@checkDirectory(read_from$, "Read sounds from...")
read_from$ = checkDirectory.name$

@checkDirectory(save_to$, "Save sounds to...")
save_to$ = checkDirectory.name$

stopwatch

files = Create Strings as file list: "files",
  ...read_from$ + "*" + sound_extension$

mindb = 70

# Make sure a temporary directory exists in the plugin root
Create directory: "tmp"

n = Get number of strings

if n
  table = Create Table with column names: "conversions", 0,
    ..."filename rms_pre max_pre rms_post max_post"

  for i to n
    selectObject(files)
    filename$ = Get string: i
    sound = Read from file: read_from$ + "/" + filename$

    @rms_and_max()

    selectObject(table)
    Append row
    Set string value:  i, "filename", filename$
    Set numeric value: i, "rms_pre",  rms
    Set numeric value: i, "max_pre",  max

    selectObject(sound)

    Scale intensity: mindb

    @rms_and_max()

    selectObject(table)
    Set numeric value: i, "rms_post",  rms
    Set numeric value: i, "max_post",  max

    selectObject(sound)
    Save as binary file: "tmp/" + (filename$ - "wav" + "Sound")

    removeObject(sound)
  endfor

  selectObject(table)
  max = Get maximum: "max_post"
  factor = 0.999 / max

  for i to n
    selectObject(files)
    filename$ = Get string: i
    sound = Read from file: "tmp/" + (filename$ - "wav" + "Sound")

    deleteFile("tmp/" + (filename$ - "wav" + "Sound"))

    Formula: "self*" + string$(factor)

    @rms_and_max()

    selectObject(table)
    Set numeric value: i, "rms_post",  rms
    Set numeric value: i, "max_post",  max

    selectObject(sound)
    Save as WAV file: save_to$ + "/" + filename$
    removeObject(sound)
  endfor

  removeObject(files)
  if !keep_conversion_table
    removeObject(table)
  endif

  time = stopwatch

  writeInfoLine: "Processed " + string$(n) + " files in " + fixed$(time, 2) + " seconds"
  appendInfoLine: "All processed files set to a RMS of " + fixed$(rms, 2) + " Pascal"
else
  writeInfoLine: "No objects to process"
endif

procedure rms_and_max ()
  rms = Get root-mean-square: 0, 0
  max = Get maximum: 0, 0, "None"
  min = Get minimum: 0, 0, "None"
  max = if abs(max) > abs(min) then abs(max) else abs(min) fi
endproc
