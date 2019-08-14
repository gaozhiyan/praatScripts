# Move all boundaries from a TextGrid to their nearest
# zero-crossings, keeping labels and number of intervals.
#
# The script can also move points in point tiers to
# zero-crossings, if so desired, by changing the value of the
# move_points variable.
#
# The script will process Sound and TextGrid pairs in sequential
# order, pairing the first Sound object with the first TextGrid
# object and so on. This should be fine for most cases.
#
# Written by Jose J. Atria (April 20, 2012)
# Latest revision: 27 October 2014
# Requires Praat v 5.3.44
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Move boundaries to zero-crossings (batch)...
  sentence Sound_directory
  sentence TextGrid_directory
  sentence Output_directory
  integer Tier 0 (= all)
  integer Maximum_shift_(s) 0 (= no maximum)
  boolean Ignore_points 1
endform

include ../procedures/require.proc
include ../procedures/check_directory.proc

# The current version of this script uses the new syntax, made available
# with Praat v.5.3.44
@require("5.3.44")

@checkDirectory(sound_directory$, "Read Sounds from...")
sound_directory$ = checkDirectory.name$

@checkDirectory(textGrid_directory$, "Read TextGrids from...")
textgrid_directory$ = checkDirectory.name$

@checkDirectory(output_directory$, "Save TextGrids to...")
output_directory$ = checkDirectory.name$

verbose = 0

cleared = 0
if verbose
  clearinfo
  cleared = 1
endif

sounds = Create Strings as file list: "files",
  ... sound_directory$ + "*wav"
total_sounds = Get number of strings

textgrids = Create Strings as file list: "files",
  ... textgrid_directory$ + "*TextGrid"
total_textgrids = Get number of strings

# Perform initial checks on available objects
if !total_sounds or total_sounds and (total_sounds != total_textgrids)
  exitScript: "Not able to read an equal number of Sound and TextGrid objects."
endif

for current to total_sounds

  selectObject: sounds
  sound_file$ = Get string: current
  sound = Read from file: sound_directory$ + sound_file$

  selectObject: textgrids
  textgrid_file$ = Get string: current
  textgrid = Read from file: textgrid_directory$ + textgrid_file$

  selectObject: sound, textgrid
  runScript: "../textgrid/move_to_zero_crossings.praat",
    ... tier, maximum_shift, ignore_points

  selectObject: textgrid
  name$ = selected$("TextGrid")
  Save as text file: output_directory$ + name$ + "_zero" + "TextGrid"

  removeObject: sound, textgrid

endfor

removeObject: sounds, textgrids
