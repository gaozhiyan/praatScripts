# Copy multiple selected objects
#
# Praat's built-in "Copy" command only works for a single selected object.
# Thinking that this is an unnecessary limitation, this script allows one to
# copy whole sets of objects at once.
#
# Written by Jose J. Atria (September 12, 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc

@saveSelection()
@createEmptySelectionTable()
new = createEmptySelectionTable.table

for i to saveSelection.n
  selectObject: saveSelection.id[i]
  type$ = extractWord$(selected$(), "")
  name$ = selected$(type$)
  Copy: name$
  @addToSelectionTable(new, selected())
endfor

@restoreSavedSelection(new)
removeObject: new
