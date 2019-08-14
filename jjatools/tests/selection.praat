include ../procedures/selection.proc
jja.debug = 0

select all
baseline = numberOfSelected()

## Create test sounds
name$ = "sound"
sound[1] = Create Sound as pure tone: name$, 1, 0, 0.4, 44100, 220, 0.2, 0.01, 0.01
for i from 2 to 5
  sound[i] = Copy: name$
endfor

## Clear selection
@clearSelection()
assert numberOfSelected("Sound") = 0

## Save Sound selection
for i from 1 to 5
  plusObject: sound[i]
endfor
assert numberOfSelected("Sound") = 5

@saveSelectionTable()
sounds = saveSelectionTable.table
assert numberOfSelected("Sound") = 5

## Create TextGrids
To TextGrid: "tier", ""
assert numberOfSelected("TextGrid") = 5

## Save TextGrid selection
@saveSelectionTable()
textgrids = saveSelectionTable.table
assert numberOfSelected("TextGrid") = 5

## Swap between saved selections
@restoreSavedSelection(sounds)
assert numberOfSelected("TextGrid") = 0
assert numberOfSelected("Sound")    = 5
assert numberOfSelected()           = 5

## De-select saved selection
@minusSavedSelection(sounds)
assert numberOfSelected() = 0

## Add saved selection to current selection
@plusSavedSelection(sounds)
@plusSavedSelection(textgrids)
assert numberOfSelected("TextGrid") = 5
assert numberOfSelected("Sound")    = 5
assert numberOfSelected()           = 10

## Refine selection to specified type
@refineToType("Sound")
assert numberOfSelected("TextGrid") = 0
assert numberOfSelected("Sound")    = 5
assert numberOfSelected()           = 5

## Select all objects of given type
@selectType("TextGrid")
assert numberOfSelected("TextGrid") = 5
assert numberOfSelected("Sound")    = 0
assert numberOfSelected()           = 5

## Add saved selections together
selectObject: sounds,textgrids
all = Append

## Test object tables
@checkSelectionTable(all)
objects = checkSelectionTable.table
assert checkSelectionTable.return = 1

## Count object types
@countObjects(objects, "Sound")
assert countObjects.n = 5
@countObjects(objects, "Pitch")
assert countObjects.n = 0

@restoreSavedSelection(all)
assert numberOfSelected("TextGrid") = 5
assert numberOfSelected("Sound")    = 5
assert numberOfSelected()           = 10
Remove

## Remove all selection tables
@selectSelectionTables()
assert numberOfSelected("Table") = 3
Remove

## Remove all object tables
@selectObjectTables()
assert numberOfSelected("Table") = 1
Remove

## Make sure no objects are left behind
select all
assert numberOfSelected() = baseline
