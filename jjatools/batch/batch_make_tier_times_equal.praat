# Equalise TextGrid tier durations (batch)
#
# Praat allows for tiers of different durations to be merged into a single
# annotation file. However, this is contrary to the expectations of most
# scripts in existence. Since it is also hard to check whether a given TextGrid
# will suffer from this, this script extends all tiers of insufficient length
# until they reach the duration of the longest.
#
# Author: Jose Joaquin Atria
# Initial release: October 24, 2014
# Last modified:   October 24, 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Equalize tier durations...
  sentence Read_from
  sentence Save_to
  comment Leave paths empty for GUI selector
  boolean Verbose no
endform

include ../procedures/make_tier_times_equal.proc
include ../procedures/check_directory.proc

@checkDirectory("Read TextGrids from...", read_from$)
read_from$ = checkDirectory.name$

@checkDirectory("Save TextGrids to...", save_to$)
save_to$ = checkDirectory.name$

filelist = Create Strings as file list: "files", read_from$ + "*.TextGrid"
files = Get number of strings

for f to files
  selectObject: filelist
  filename$ = Get string: f
  textgrid = Read from file: read_from$ + filename$

  @makeTierTimesEqual()
  selectObject: makeTierTimesEqual.id

  Save as text file: save_to$ + textgrid$ + ".TextGrid"
  # End file loop
endfor
