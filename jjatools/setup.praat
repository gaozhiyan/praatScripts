# Setup script for JJATools plugin
#
# Find the latest version of this plugin at
# https://github.com/jjatria/plugin_jjatools
#
# Written by Jose J. Atria (18 November 2011)
# Latest revision: April 4, 2014
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

## Static commands:

# Uncomment next line to run tests at startup
# runScript: "run_tests.praat"

# Base menu
Add menu command: "Objects", "Praat", "JJATools",                             "",                   0, ""
Add menu command: "Objects", "Praat", "Save selected objects...",             "JJATools",           1, "management/save_all.praat"
Add menu command: "Objects", "Praat", "Copy selected objects...",             "JJATools",           1, "management/copy_selected.praat"
Add menu command: "Objects", "Praat", "View each (selected)",                 "JJATools",           1, "management/view_each.opened.praat"
Add menu command: "Objects", "Praat", "View each (from disk)",                "JJATools",           1, "management/view_each.from_disk.praat"
Add menu command: "Objects", "Praat", "Sort selected objects...",             "JJATools",           1, "management/sort_objects.praat"

# Formats menu
Add menu command: "Objects", "Praat", "Formats -",                            "JJATools",           1, ""
Add menu command: "Objects", "Praat", "Save selected objects to JSON...",     "Formats -",          2, "management/save_as_json.praat"

# Object selection menu
Add menu command: "Objects", "Praat", "Object selection -",                   "JJATools",           1, ""
Add menu command: "Objects", "Praat", "Select one type...",                   "Object selection -", 2, "management/select_one_type.praat"
Add menu command: "Objects", "Praat", "Invert selection",                     "Object selection -", 2, "management/invert_selection.praat"

# Batch scripts menu
Add menu command: "Objects", "Praat", "Batch processing -",                   "JJATools",           1, ""
Add menu command: "Objects", "Praat", "Move boundaries to zero crossings...", "Batch processing -", 2, "batch/move_to_zero_crossings.praat"
Add menu command: "Objects", "Praat", "TextGrids to Audacity labels...",      "Batch processing -", 2, "batch/batch_textgrids_to_audacity_labels.praat"
Add menu command: "Objects", "Praat", "Convert to JSON...",                   "Batch processing -", 2, "batch/batch_save_to_json.praat"
Add menu command: "Objects", "Praat", "Generate Pitch (two-pass)...",         "Batch processing -", 2, "batch/batch_to_pitch_two-pass.praat"

## Dynamic commands

# Sound commands
Add action command: "Sound",         0, "",         0, "", 0, "Filter and center...",                 "Filter -",              1, "sound/filter_and_center.praat"
Add action command: "Sound",         0, "",         0, "", 0, "Normalise (RMS)...",                   "Modify -",              1, "sound/rms_normalize.praat"
Add action command: "Sound",         0, "",         0, "", 0, "To Pitch (two-pass)...",               "Analyse periodicity -", 1, "sound/to_pitch_two-pass.praat"

# Strings commands
Add action command: "Strings",       0, "",         0, "", 0, "Sort (generic)...",                    "Modify -",              1, "strings/sort_strings_generic.praat"
Add action command: "Strings",       0, "",         0, "", 0, "Extract strings...",                   "",                      0, "strings/extract_strings.praat"

# TextGrid commands
Add action command: "TextGrid",      1, "",         0, "", 0, "Find label...",                        "Query -",               1, "textgrid/find_label_in_textgrid.praat"
Add action command: "TextGrid",      0, "",         0, "", 0, "Save as Audacity label...",            "",                      0, "textgrid/textgrid_to_audacity_label.praat"

# Combined commands
Add action command: "Sound",         0, "TextGrid", 0, "", 0, "Extract labels...",                    "",                      0, "textgrid/extract_labels.praat"
Add action command: "Sound",         1, "TextGrid", 1, "", 0, "Move boundaries to zero-crossings...", "",                      0, "textgrid/move_to_zero_crossings.praat"
Add action command: "Sound",         0, "TextGrid", 0, "", 0, "View each as pairs",                   "",                      0, "management/view_each.opened.praat"

# View each
Add action command: "Intensity",     0, "",         0, "", 0, "View each",                            "",                      0, "management/view_each.opened.praat"
Add action command: "Pitch",         0, "",         0, "", 0, "View each",                            "",                      0, "management/view_each.opened.praat"
Add action command: "Sound",         0, "",         0, "", 0, "View each",                            "",                      0, "management/view_each.opened.praat"

# JSON conversion
Add action command: "TextGrid",      0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "PointProcess",  0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "DurationTier",  0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "IntensityTier", 0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "Intensity",     0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "AmplitudeTier", 0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
Add action command: "PitchTier",     0, "",         0, "", 0, "Save as JSON file...",                 "",                      0, "management/save_as_json.praat"
