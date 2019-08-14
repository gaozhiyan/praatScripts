# Perform a generic sort on strings in a Strings object.
# The standard Sort command for Strings sorts alphabetically.
# This script tries to convert strings to numbers and uses the
# numbers for sorting. Strings that cannot be converted to numbers
# are sorted alphabetically.
#
# Written by Jose J. Atria (19 February 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include require.proc
@require("5.3.44")

form Sort strings (generic)...
  boolean Numeric_first yes
  boolean Case_sensitive yes
endform

n = numberOfSelected("Strings")
for i to n
  strings[i] = selected("Strings", i)
endfor

for i to n
  # stopwatch

  selectObject(strings[i])
  nstrings = Get number of strings

  # Create an empty table
  cols$ = "num str"
  if !case_sensitive
    cols$ = cols$ + " lc"
  endif
  table = Create Table with column names: "nums", nstrings, cols$

  # Populate the table with the strings or their number versions where possible
  for row to nstrings
    selectObject(strings[i])
    s$ = Get string: row
    s = number(s$)

    selectObject(table)
    Set string value: row, "str", s$
    if !case_sensitive
      Set string value: row, "lc", replace_regex$(s$, "(.*)", "\L\1", 0)
    endif
    Set numeric value: row, "num", number(s$)
  endfor

  sort$ = "num " + if case_sensitive then "str" else "lc" fi
  Sort rows: sort$

  # Invert order for non-numeric strings first
  if !numeric_first
    selectObject(table)
    nantable = nowarn Extract rows where column (text):
      ..."num", "is equal to", "--undefined--"
    selectObject(table)
    numtable = nowarn Extract rows where column (text):
      ..."num", "is not equal to", "--undefined--"
    removeObject(table)
    selectObject(nantable, numtable)
    table = Append
    removeObject(nantable, numtable)
  endif

  # Replace the original strings with the sorted list
  selectObject(table)
  for row to nstrings
    selectObject(table)
    s$ = Get value: row, "str"
    selectObject(strings[i])
    Set string: row, s$
  endfor

  # Clean-up
  removeObject(table)

  # selectObject(strings[i])
  # name$ = selected$("Strings")
  # time = stopwatch
  # appendInfoLine("Sorted ", name$ , " in ", time)
endfor

# Restore selection
if n >= 1
  selectObject(strings[1])
  for i from 2 to n
    plusObject(strings[i])
  endfor
endif
