

(* 
     free_vars (bvars, e) returns a list of the 
     free vars of e that are not contained in bvars. 

*) 
val free_vars : (Types.var list) * Ast.expr -> (Types.var list)
val free_vars_jargon : (Types.var list) * JargonAst.jExpr -> (Types.var list)
