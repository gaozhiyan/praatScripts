# Extract non-empty intervals from a specific tier
#
# The script will process Sound and TextGrid pairs in sequential
# order, pairing the first Sound object with the first TextGrid
# object and so on. This should be fine for most cases.
#
# If a value is specified in the "Look for" field, the script will
# only extract the sounds from intervals labeled with that string.
# If the field is empty, all non-empty intervals will be extracted.
#
# For each object pair, the script looks for the intervals on the
# specified tier and extracts them into new Sound objects. These
# objects will be renamed as 'TGNAME'_'LABEL'_'COUNTER'
# where TGNAME is the name of the TextGrid object, LABEL the label
# on the interval and COUNTER a number counting the occurences of
# that label so far. Thus, if there are two intervals labeled "a"
# on the specified tier, these will result in objects named
# 'TGNAME'_a1 and 'TGNAME'_a2 respectively.
#
# Since not all characters common in interval labels are acceptable
# as object names, the script makes it easy to perform systematized
# replacements on these to prevent loss of important information.
#
# These replacements can be added by inserting replace$() or
# replace_regex$() function calls in the area of the script labeled
# as "Add ad-hoc character replacements". Alternatively, the user
# can select a csv file to be read as a list of replacements. The
# file must be in the form
#
# REPLACE,REPLACEMENT
#
# and only lines with one comma will be read.
#
# Written by Jose J. Atria (May 18, 2012)
# Last revision February 27, 2014
# Requires Praat v 5.3.63
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
include ../procedures/selection.proc
@require("5.3.63")

form Extract sounds...
  positive Tier 1
  integer Padding_(s) 0
  boolean Preserve_times 0
  sentence Look_for
  boolean Use_regular_expressions 1
  optionmenu Replacements: 2
    option Make no replacements
    option Use script replacements
    option Use external definition
endform

make_replacements = replacements - 1
external_replacements = if make_replacements > 1 then 1 else 0 fi

cleared = 0

if numberOfSelected("Sound") or numberOfSelected("LongSound")
  @saveTypeSelection("Sound")
  sounds = saveTypeSelection.table

  @saveTypeSelection("LongSound")
  longsounds = saveTypeSelection.table

  @saveSelection()
  selectObject: sounds, longsounds
  all_sounds = Append
  Rename: "sounds"
  removeObject: sounds, longsounds
  @restoreSelection()
endif
if numberOfSelected("TextGrid")
  @saveTypeSelection("TextGrid")
  textgrids = saveTypeSelection.table
endif

#Clear selection
nocheck selectObject: undefined

if external_replacements
  replacement_file$ = chooseReadFile$("Select replacement definition file")
  if replacement_file$ = ""
    exitScript("No replacement definition selected.")
  endif

  replacement_table = Create Table with column names: "replacements", 0, "replace with"
  body$ readFile(replacement_file$')

  @split(newline$, body$)
  for i to split.length
    line$[i] = split.array$[i]
  endfor

  lines = split.length
  for i to lines
    line$ = line$[i]
    @split("," line$)
    if split.length = 2
      Append row
      change$ = split.array$[1]
      into$ = split.array$[2]
      r = Get number of rows
      Set string value: r, "replace", change$
      Set string value: r, "with", into$
    endif
  endfor
endif

hash = Create Table without column names: "hash", 1, 1

@createEmptySelectionTable()
extracted = createEmptySelectionTable.table
Append column: "counter"
Append column: "textgrid"

padding_length = 1

for o to Object_'all_sounds'.nrow

  @getId(all_sounds, o)
  sound = getId.id
  selectObject: sound
  sound_name$ = extractWord$(selected$(), " ")
  @getId(textgrids, o)
  textgrid = getId.id
  selectObject: textgrid
  textgrid_name$ = selected$("TextGrid")

  if Object_'sound'.xmax = Object_'textgrid'.xmax
    # Objects have same length

    selectObject: textgrid
    intervals = Get number of intervals: tier
    for i to intervals
      selectObject: textgrid
      label$ = Get label of interval: tier, i

      if use_regular_expressions
        match = index_regex(label$, look_for$)
      else
        match = index(label$, look_for$)
      endif

      if match
        selectObject: hash
        found = Get column index: label$
        if found
          counter = Get value: 1, label$
          counter += 1
          length = length(string$(counter))
          padding_length = if length > padding_length
            ... then length else padding_length fi
          Set numeric value: 1, label$, counter
        else
          counter = 1
          Append column: label$
          Set numeric value: 1, label$, counter
        endif

        selectObject: textgrid
        start = Get start point: tier, i
        end   = Get end point:   tier, i

        selectObject: sound
        if index(selected$(), "Long")
          # LongSound
          new = Extract part: start-padding, end+padding,
            ... preserve_times
        else
          # Sound
          new = Extract part: start-padding, end+padding,
            ... "Rectangular", 1, preserve_times
        endif

        @addToSelectionTable(extracted, new)
        selectObject: extracted
        Set string value:  Object_'extracted'.nrow, "name",     label$
        Set string value:  Object_'extracted'.nrow, "textgrid", textgrid_name$
        Set numeric value: Object_'extracted'.nrow, "counter",  counter
      endif
    endfor
  else
    @clearOnce()
    appendInfoLine: "W: Sound ", sound_name$, " and TextGrid ", textgrid_name$,
      ... " do not seem to be related. Skipping."
  endif
endfor

if external_replacements
  removeObject: replacement_table
endif

for o to Object_'extracted'.nrow
  selectObject: Object_'extracted'[o,"id"]

  tg$   = Object_'extracted'$[o,"textgrid"]
  name$ = Object_'extracted'$[o,"name"]
  n     = Object_'extracted'[o,"counter"]

  @zeropad(n, padding_length)

  Rename: tg$ + "_" + name$ + "_" + zeropad.return$
endfor

removeObject: hash, all_sounds, textgrids

@restoreSavedSelection(extracted)
removeObject: extracted

procedure replaceCharacters ()
  if makereplacements
    if external_replacements
      selectObject: replacement_table
      r = Get number of rows
      for d to r
        change$ = Get value: d, "replace"
        into$   = Get value: d, "with"
        label$  = replace$(label$, change$, into$, 0)
      endfor
    endif

    if index_regex(label$, "\W")
      # Perform other changes here, with lines like
      # label$ = replace$(label$, CHANGE, INTO, 0)
      # replacing CHANGE and INTO with whatever string
      # substitution you prefer
    endif

    if index_regex(label$, "[^a-zA-Z0-9-]")
      @clearOnce()
      appendInfoLine: "W: Label ", label$, " on Sound ", sname$, " ",
        ... "still contains illegal characters. ",
        ... "These will be lost.")
    endif

  endif
endproc

procedure clearOnce ()
  if !cleared
    clearinfo
    cleared = 1
  endif
endproc
