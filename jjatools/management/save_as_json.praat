# Praat object to JSON converter
#
# Written by Jose J. Atria (27 February 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc
include ../procedures/check_directory.proc
include ../procedures/json_base.proc
include ../procedures/utils.proc
include ../procedures/warnings.proc

# Ideally, these would only be included if necessary
include ../procedures/json_textgrid.proc
include ../procedures/json_points.proc

form Save as JSON...
  sentence Save_to
  optionmenu Format: 1
    option Pretty printed
    option Minified
endform

@addWarning("AmplitudeTierAsIntensityTier",
  ..."AmplitudeTier objects saved as IntensityTier objects")

@checkDirectory(save_to$, "Save JSON to...")
directory$ = checkDirectory.name$

@saveSelection()

if format$ = "Pretty printed"
  json.n$ = newline$
  json.t$ = tab$
  json.s$ = " "
elsif format$ = "Minified"
  json.n$ = ""
  json.t$ = json.n$
  json.s$ = json.n$
endif

for i to saveSelection.n
  # Reset fallback flag for this object
  # If this object requires a fallback, then this will
  # be set somewhere else in the loop
  fallback = 0

  selectObject(saveSelection.id[i])
  type$ = extractWord$(selected$(), "")

  if type$ = "AmplitudeTier"
    @warning("AmplitudeTierAsIntensityTier")
    fallback_to = selected()
    fallback = To IntensityTier: -10000
  endif

  # If an objects requires a fallback, this is selected
  if fallback
    selectObject(fallback)
    type$ = extractWord$(selected$(), "")
  else
    selectObject(saveSelection.id[i])
  endif

  name$ = selected$(type$)
  start = Get start time
  end = Get end time
  output_file$ = directory$ + "/" +
    ...name$ + "_" + replace_regex$(type$, "(.)", "\L\1", 0) + ".json"

  supported_type = 0
  if      type$ = "TextGrid"      or
      ... type$ = "PointProcess"  or
      ... type$ = "PitchTier"     or
      ... type$ = "DurationTier"  or
      ... type$ = "AmplitudeTier" or
      ... type$ = "IntensityTier" or
      ... type$ = "Intensity"
    supported_type = 1
  endif

  if supported_type
    if fileReadable(output_file$)
      deleteFile: output_file$
    endif

    @startJsonObject(output_file$)
    @writeJsonString(output_file$, "File type", "json", 0)
    @writeJsonString(output_file$, "Object class", type$, 0)
    @writeJsonNumber(output_file$, "start", start, 0)
    @writeJsonNumber(output_file$, "end", end, 0)

    if type$ = "TextGrid"

      @textGridToJson(output_file$)

    elsif type$ = "PointProcess"

      @pointsToJson(output_file$)

    elsif type$ = "PitchTier"     or
      ... type$ = "DurationTier"  or
      ... type$ = "AmplitudeTier" or
      ... type$ = "IntensityTier" or
      ... type$ = "Intensity"

      @pointsWithNumbersToJson(output_file$)

    else
      # Unsupported
    endif

    @endJsonObject(output_file$, 1)
  else
    @addWarning(type$ + "Unsupported",
      ...type$ + " objects not yet supported")
    @warning(type$ + "Unsupported")
  endif

  if fallback
    removeObject(fallback)
    selectObject(saveSelection.id[i])
  endif

endfor

@restoreSelection()

@issueWarnings()
