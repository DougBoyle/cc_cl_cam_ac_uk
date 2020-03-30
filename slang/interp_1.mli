
type address = int 

type value = 
     | REF of address 
     | INT of int 
     | BOOL of bool 
     | UNIT
     | PAIR of value * value 
     | INL of value 
     | INR of value 
     | REC_CLOSURE of closure
     | CLOSURE of closure  

and closure = Types.var * Ast.expr * env

and continuation_action = 
  | UNARY of Types.unary_oper
  | OPER of Types.oper * value
  | OPER_FST of Ast.expr * env * Types.oper
  | ASSIGN of value
  | ASSIGN_FST of Ast.expr * env
  | TAIL of Ast.expr list * env
  | IF of Ast.expr * Ast.expr * env
  | WHILE of Ast.expr * Ast.expr * env
  | MKPAIR of value 
  | PAIR_FST of Ast.expr * env 
  | FST 
  | SND 
  | MKINL 
  | MKINR 
  | MKREF 
  | DEREF 
  | CASE of Types.var * Ast.expr * Types.var * Ast.expr * env
  | APPLY of value 
  | ARG of Ast.expr * env 

and continuation = continuation_action  list

and binding = Types.var * value

and env = binding list

type state = 
   | EXAMINE of Ast.expr * env * continuation 
   | COMPUTE of continuation * value 

val step : state -> state 

val driver : int -> state -> value 

val eval : Ast.expr * env -> value 

val interpret : Ast.expr -> value 

val string_of_value : value -> string 

