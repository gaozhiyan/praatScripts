# Invert selection
#
# The script selects all non-selected objects, and de-selects all the ones
# that were previously selected. It does this using the selection prodecures
# defined in selection.proc
#
# Author: Jose Joaquin Atria
# Latest revision: October 22, 2014
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc

@saveSelectionTable()
selection = saveSelectionTable.table

select all

@minusSavedSelection(selection)
removeObject: selection
