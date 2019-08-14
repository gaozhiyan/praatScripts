# Equalise TextGrid tier durations
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

include ../procedures/make_tier_times_equal.proc

textgrids = numberOfSelected("TextGrid")

if !textgrids
  exitScript: "No TextGrid objects selected"
endif

for i to textgrids
  tg[i] = selected("TextGrid", i)
endfor

for i to textgrids
  selectObject: tg[i]
  name$ = selected$("TextGrid")
  @makeTierTimesEqual()
  current = selected()
  if tg[i] = current
    new[i] = Copy: name$ + "_unchanged"
  else
    new[i] = selected()
  endif
endfor

nocheck selectObject: undefined
for i to textgrids
  plusObject: new[i]
endfor
