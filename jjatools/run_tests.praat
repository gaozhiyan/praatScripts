test_dir$ = "./tests/"
tests = Create Strings as file list: "tests", test_dir$ + "*praat"
n = Get number of strings
for i to n
  selectObject: tests
  script$ = Get string: i
  runScript: test_dir$ + script$
endfor
removeObject: tests
