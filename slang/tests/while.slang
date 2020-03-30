
let i : int ref = ref (-100)
in  while !i < 3 do
      i := (!i + 1)
    end;
    !i
end