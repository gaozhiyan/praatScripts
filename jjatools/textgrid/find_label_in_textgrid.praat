# Find label in a TextGrid Interval tier.
#
# The script runs through the intervals of an interval tier looking
# for a literal label. If found, it prints the number of the interval
# that holds it. Using the value in the "index" variable it's possible
# to look for the interval number with the nth repetition of the label.
#
# The first version of this script was written for the
# Laboratorio de Fonetica Letras UC
#
# Written by Jose J. Atria (18 November 2011)
# Latest revision: April 4, 2014
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Find label...
  integer    Tier 1
  sentence   Target
  optionmenu Direction: 1
    option   Forwards
    option   Backwards
  integer    Start_from 1
  comment    When searching backwards, starting point is counted from end
endform

include ../procedures/find_label.proc

if direction$ = "Forwards"
  @findFromStart(tier, target$, start_from)
  writeInfoLine: findFromStart.return
elsif direction$ = "Backwards"
  @findFromEnd(tier, target$, start_from)
  writeInfoLine: findFromEnd.return
else
  exitScript: "Error. Please contact author."
endif
