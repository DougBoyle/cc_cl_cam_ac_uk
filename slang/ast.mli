type expr =
       | Unit  
       | Var of Types.var
       | Integer of int
       | Boolean of bool
       | UnaryOp of Types.unary_oper * expr
       | Op of expr * Types.oper * expr
       | If of expr * expr * expr
       | Pair of expr * expr
       | Fst of expr 
       | Snd of expr 
       | Inl of expr 
       | Inr of expr 
       | Case of expr * lambda * lambda 

       | While of expr * expr 
       | Seq of (expr list)
       | Ref of expr 
       | Deref of expr 
       | Assign of expr * expr 

       | Lambda of lambda 
       | App of expr * expr
       | Let of lambda * expr
       | LetFun of Types.var * lambda * expr
       | LetRecFun of Types.var * lambda * expr

and lambda = Types.var * expr

(* printing *) 
val string_of_unary_oper : Types.unary_oper -> string
val string_of_oper : Types.oper -> string
val string_of_uop : Types.unary_oper -> string
val string_of_bop : Types.oper -> string
val print_expr : expr -> unit 
val eprint_expr : expr -> unit
val string_of_expr : expr -> string 
