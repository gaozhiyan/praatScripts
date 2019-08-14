# Convert TextGrid interval tier to Audacity label format
# Written by Jose Joaquin Atria (1 July 2013)
#
# Converts selected TextGrid objects to Audacity labels and
# either saves them to external files or prints them  to the
# Info window.
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

form TextGrid to Audacity label...
  integer Tier 1
  sentence Save_to
  comment Leave path empty for GUI selector
  boolean Print_to_Info no
endform

if !print_to_Info
  @checkDirectory(save_to$, "Choose output directory...")
  path$ = checkDirectory.name$
endif

total_textgrids = numberOfSelected("TextGrid")
for i to total_textgrids
  tg[i] = selected("TextGrid", i)
endfor

if print_to_Info and total_textgrids
  clearinfo
endif

for i to total_textgrids
  selectObject(tg[i])
  name$ = selected$("TextGrid")
  intervals = Get number of intervals: tier

  if !print_to_Info
    outfile$ = path$ + name$ + ".txt"
    if fileReadable(outfile$)
      appendInfoLine: "Overwriting existing file ", outfile$, "..."
      deleteFile(outfile$)
    endif
  elsif total_textgrids > 1
    appendInfoLine("-- Begin label for ", name$, " --")
  endif

  for ii from 2 to intervals-1
    start = Get start point: tier, ii
    end = Get end point: tier, ii
    label$ = Get label of interval: tier, ii

    if !print_to_Info
      appendFileLine(outfile$, start, tab$, end, tab$, label$)
    else
      appendInfoLine(start, tab$, end, tab$, label$)
    endif

  endfor

  if total_textgrids > 1 and print_to_Info
    appendInfoLine("-- End label for ", name$, " --")
  endif
endfor

# Restore original selection
if total_textgrids
  selectObject(tg[1])
  for i from 2 to total_textgrids
    plusObject(tg[i])
  endfor
endif
