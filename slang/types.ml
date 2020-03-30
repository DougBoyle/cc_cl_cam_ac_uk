type oper = ADD | MUL | DIV | SUB | LT | AND | OR | EQB | EQI

type unary_oper = NEG | NOT | READ

type var = string

let string_of_uop = function
  | NEG -> "NEG"
  | NOT -> "NOT"
  | READ -> "READ"

let string_of_bop = function
  | ADD -> "ADD"
  | MUL  -> "MUL"
  | DIV  -> "DIV"
  | SUB -> "SUB"
  | LT   -> "LT"
  | EQI   -> "EQI"
  | EQB   -> "EQB"
  | AND   -> "AND"
  | OR   -> "OR"

let pp_uop = function
  | NEG -> "-"
  | NOT -> "~"
  | READ -> "read"


let pp_bop = function
  | ADD -> "+"
  | MUL  -> "*"
  | DIV  -> "/"
  | SUB -> "-"
  | LT   -> "<"
  | EQI   -> "eqi"
  | EQB   -> "eqb"
  | AND   -> "&&"
  | OR   -> "||"


let string_of_oper = pp_bop
let string_of_unary_oper = pp_uop

type jExpr =
       | Unit
       | Var of var
       | Integer of int
       | Boolean of bool
       | UnaryOp of unary_oper * jExpr
       | Op of jExpr * oper * jExpr
       | If of jExpr * jExpr * jExpr
       | Pair of jExpr * jExpr
       | Fst of jExpr
       | Snd of jExpr
       | Inl of jExpr
       | Inr of jExpr
       | Case of jExpr * jLambda * jLambda
       | While of jExpr * jExpr
       | Seq of (jExpr list)
       | Ref of jExpr
       | Deref of jExpr
       | Assign of jExpr * jExpr
       | Lambda of jLambda
       | App of jExpr * jExpr
       | LetFun of var * jLambda * jExpr * int (* For assigning local offsets *)
       | LetRecFun of var * jLambda * jExpr *  int

and jLambda = var * jExpr * int (* Number of local variables *)