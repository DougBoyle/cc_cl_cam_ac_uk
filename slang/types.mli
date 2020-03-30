type oper = ADD | MUL | DIV | SUB | LT | AND | OR | EQB | EQI

type unary_oper = NEG | NOT | READ

type var = string

val string_of_uop : unary_oper -> string
val string_of_bop : oper -> string
val string_of_unary_oper : unary_oper -> string
val string_of_oper : oper -> string

