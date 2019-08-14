# Detect non-overlapping intervals in a multi-tiered TextGrid
#
# This script will generate a new TextGrid object with a single tier
# containing intervals obtained by "flattening" those of all tiers in the
# original TextGrid.
#
# Depending on the label of those intervals, it will be possible to determine
# whether they were silent in the original (no label), whether they have an
# overlap across tiers ("0" as the label), or whether they are a non-overlapping
# interval, in which case the number of the tier to which they correspond will
# be the label.
#
# Based on https://uk.groups.yahoo.com/neo/groups/praat-users/conversations/messages/6947
#
# Author: Jose Joaquin Atria
# Initial release: October 24, 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/to_non-overlapping_intervals.proc

textgrids = numberOfSelected("TextGrid")
for i to textgrids
  tg[i] = selected("TextGrid", i)
endfor

for i to textgrids
  selectObject: tg[i]
  @toNonOverlappingIntervals()
  newtg[i] = selected("TextGrid")
endfor

nocheck selectObject: undefined
for i to textgrids
  plusObject: newtg[i]
endfor
