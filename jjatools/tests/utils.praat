include ../procedures/utils.proc

@pwgen(10)
string$ = pwgen.return$
assert string$ != ""
assert length(string$) = 10

random$ = string$
string$ = "a," + random$ + ",a"
@split(",", string$)
assert split.length = 3
assert split.return$[2] = random$
assert split.return$[1] = split.return$[3]

@numchar(string$, ",")
assert numchar.return = 2
@numchar("", ",")
assert numchar.return = 0
