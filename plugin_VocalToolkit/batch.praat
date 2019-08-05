batch_sel# = selected# ("Sound")
n_batch = size (batch_sel#)
new_batch# = zero# (n_batch)

for i_batch to n_batch
	selectObject: batch_sel#[i_batch]
	@action
	new_batch# [i_batch] = selected()
endfor

selectObject: new_batch#
