

val infer : (Past.var * Past.type_expr) list -> (string * Past.loc) list ->
  Past.expr -> (Past.expr * Past.type_expr)

val check : Past.expr -> Past.expr 
