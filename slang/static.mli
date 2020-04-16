

val infer : (Past.var * Past.type_expr) list ->
  (string * Past.loc * (Past.var * int * Past.type_expr) list) list ->
  Past.expr -> (Past.expr * Past.type_expr)

val check : Past.expr -> Past.expr

val resolve_name : int -> string
val strtab : (int * string) list ref
