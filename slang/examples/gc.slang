(* Can garbage collect first branch of recursive calls,
actually only need O(n) space.
f 9 is first to cause 'heap exhausted' error *)
let f (x : int) : int =
  if x = 1 then 1
  else let a : int * int = (1,2) in f (x-1) + f (x-1) end end
in f 12 end