type jExpr =
       | Unit
       | Var of Types.var
       | Integer of int
       | Boolean of bool
       | UnaryOp of Types.unary_oper * jExpr
       | Op of jExpr * Types.oper * jExpr
       | If of jExpr * jExpr * jExpr
       | Pair of jExpr * jExpr
       | Fst of jExpr
       | Snd of jExpr
       | Inl of jExpr
       | Inr of jExpr
       | Case of jExpr * lambda * lambda
       | While of jExpr * jExpr
       | Seq of (jExpr list)
       | Ref of jExpr
       | Deref of jExpr
       | Assign of jExpr * jExpr
       | Lambda of lambda
       | App of jExpr * jExpr
       | Let of lambda * jExpr
       | LetFun of Types.var * lambda * jExpr * int (* For assigning local offsets *)
       | LetRecFun of Types.var * lambda * jExpr *  int

and lambda = Types.var * jExpr * int (* Number of local variables *)