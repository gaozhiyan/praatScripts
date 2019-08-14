# Filter and center sound objects
#
# The script takes a number of selected sound objects and, depending
# on user input, applies a high-pass filter to remove bands of low
# energy irrelevant for speech and/or centers the sound on zero to avoid
# oscillations that sometimes result from improper calibration of the
# recording equipment.
#
# The script will replace the selected objects with filtered objects with
# the same name.
#
# Written by Jose J. Atria (October, 2012)
# Latest revision: 21 February 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc
include ../procedures/require.proc
@require("5.3.44")

form Filter and center...
  comment Filter options
  boolean Stop_Hann_band 1
  real left_Frequency_band 0
  real right_max_frequency 100
  boolean Subtract_mean 1
  boolean Make_changes_inline yes
endform

use_filter = stop_Hann_band
minfreq = left_Frequency_band
maxfreq = right_max_frequency

if use_filter + subtract_mean > 0

  @saveSelectionTable()
  original_selection = saveSelectionTable.table
  total_selected = numberOfSelected()

  @refineToType("Sound")
  @saveSelectionTable()
  sounds_selection = saveSelectionTable.table
  selected_sounds = numberOfSelected()

  if selected_sounds and total_selected = selected_sounds

    @createEmptySelectionTable()
    filtered_selection = createEmptySelectionTable.table

    for i to selected_sounds
      selectObject: sounds_selection
      id = Get value: i, "id"
      selectObject: id

      old = selected()
      max = Get maximum: 0, 0, "None"
      min = Get minimum: 0, 0, "None"
      min *= -1
      name$ = selected$("Sound")

      if make_changes_inline
        new = id
      else
        new = Copy: name$
      endif

      if use_filter
        r = selected()
        new = Filter (stop Hann band): minfreq, maxfreq, 100
        removeObject(r)
      endif
      @addToSelectionTable(filtered_selection, new)

      if subtract_mean
        Subtract mean
      endif

      if !make_changes_inline
        Rename: name$ + "_filtered"
      endif

    endfor

  else
    appendInfoLine: "More than one type selected"
    @restoreSavedSelection(original_selection)
  endif

endif

@selectSelectionTables()
Remove

@restoreSavedSelection(filtered_selection)
