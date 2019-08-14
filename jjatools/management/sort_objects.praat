# Sorts the selected objects according to specified fields
#
# Written by Jose J. Atria (22 June 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/utils.proc
include ../procedures/require.proc
@require("5.3.44")

form Sort selected objects...
  comment Enter fields for sort, in order, separated by commas.
  text Sort_fields name, type
  comment Supported fields: name, type, length
  optionmenu Special 1
    option ...
    option Reverse
    option Randomize (ignore other options)
endform

special$ = extractWord$(replace_regex$(special$, "([A-Z])", "\L\1", 0), "")

supported_fields$ = "name type length"

# Process sorting fields
sort_fields$ = replace_regex$(sort_fields$, "([A-Z])", "\L\1", 0)
sort_fields$ = replace$(sort_fields$, " ", "", 0)
@split(",", sort_fields$)
fields = split.length
sort_fields$ = ""
for i to fields
  fields$[i] = split.array$[i]
  if index(" " + supported_fields$ + " ", " " + fields$[i] + " ")
    if i = 1
      sort_fields$ = fields$[i] + " "
    else
      sort_fields$ = sort_fields$ + " " + fields$[i]
    endif
  else
    exitScript: fields$[i], " is not a supported field"
  endif
endfor

# Save selection
n = numberOfSelected()
for i to n
  unsorted[i] = selected(i)
endfor

# Create sorting table
table = Create Table with column names: "table", 0,
  ..."id " + sort_fields$

for i to n
  selectObject: unsorted[i]

  @get_fields()

  selectObject: table
  Append row
  this_row = Get number of rows
  Set numeric value: this_row, "id", unsorted[i]

  for f to fields
    field$ = fields$[f]
    if index_regex(field$, "(type|name)")
      Set string value: this_row, fields$[f],
        ...get_fields.'field$'$
    else
      Set numeric value: this_row, fields$[f],
        ...get_fields.'field$'
    endif
  endfor

endfor

selectObject: table
if special$ = "randomize"
  Randomize rows
else
  Sort rows: sort_fields$
  if special$ = "reverse"
    Reflect rows
  endif
endif

for i to n
  selectObject: table
  id = Get value: i, "id"

  selectObject: id
  @get_fields()

  new[i] = Copy: get_fields.name$
  removeObject: id
endfor

removeObject: table
for i to n
  plusObject: new[i]
endfor

procedure get_fields ()
  .type$ = extractWord$(selected$(), "")
  .name$ = selected$(.type$)
  .length = Get total duration
endproc
