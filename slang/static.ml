open Past 

let complain = Errors.complain

let internal_error msg = complain ("INTERNAL ERROR: " ^ msg)

let report_expecting e msg t = 
    let loc = loc_of_expr e in 
    let loc_str = string_of_loc loc in 
    let e_str = string_of_expr e in 
    let t_str = string_of_type t in 
    complain ("ERROR at location " ^ 
	      loc_str ^ "\nExpression " ^ e_str ^ 
	      "\nhas type " ^ t_str ^ ", but expecting " ^ msg) 

let report_types_not_equal loc t1 t2 = 
    let loc_str = string_of_loc loc in 
    let t1_str = string_of_type t1 in 
    let t2_str = string_of_type t2 in 
    complain ("Error near location " ^ loc_str ^ 
              "\nExpecting type " ^ t1_str ^ " to be equal to type " ^ t2_str)

let report_type_mismatch (e1, t1) (e2, t2) = 
    let loc1 = loc_of_expr e1 in 
    let loc2 = loc_of_expr e2 in 
    let loc1_str = string_of_loc loc1 in 
    let loc2_str = string_of_loc loc2 in 
    let e1_str = string_of_expr e1 in 
    let e2_str = string_of_expr e2 in 
    let t1_str = string_of_type t1 in 
    let t2_str = string_of_type t2 in 
    complain ("ERROR, Type Mismatch: expecting equal types, however\n" ^ 
	      "at location " ^ loc1_str ^ "\nexpression " ^ e1_str ^ "\nhas type " ^ t1_str ^ 
	      " and at location " ^ loc2_str ^ "\nexpression " ^ e2_str ^ "\nhas type " ^ t2_str)

let rec find loc x = function 
  | [] -> complain (x ^ " is not defined at " ^ (string_of_loc loc)) 
  | (y, v) :: rest -> if x = y then v else find loc x rest

let rec match_types (t1, t2) = (t1 = t2)

let make_pair loc (e1, t1) (e2, t2)  = (Pair(loc, e1, e2), TEproduct(t1, t2))
let make_inl loc t2 (e, t1)          = (Inl(loc, t2, e), TEunion(t1, t2))
let make_inr loc t1 (e, t2)          = (Inr(loc, t1, e), TEunion(t1, t2))
let make_lambda loc x t1 (e, t2)     = (Lambda(loc, (x, t1, e)), TEarrow(t1, t2))
let make_ref loc (e, t)              = (Ref(loc, e), TEref t)
let make_letfun loc f x t1 (body, t2) (e, t)    = (LetFun(loc, f, (x, t1, body), t2, e), t)
let make_letrecfun loc f x t1 (body, t2) (e, t) = (LetRecFun(loc, f, (x, t1, body), t2, e), t)

let make_let loc x t (e1, t1) (e2, t2)  = 
    if match_types (t, t1) 
    then (Let(loc, x, t, e1, e2), t2)
    else report_types_not_equal loc t t1 

let make_if loc (e1, t1) (e2, t2) (e3, t3) = 
     match t1 with 
     | TEbool ->
          if match_types (t2, t3) 
          then (If(loc, e1, e2, e3), t2) 
          else report_type_mismatch (e2, t2) (e3, t3) 
      | ty -> report_expecting e1 "boolean" ty 

let make_app loc (e1, t1) (e2, t2) = 
    match t1 with 
    | TEarrow(t3, t4) -> 
         if match_types(t2, t3) 
         then (App(loc, e1, e2), t4)
         else report_expecting e2 (string_of_type t3) t2
    | _ -> report_expecting e1 "function type" t1

let make_fst loc = function 
  | (e, TEproduct(t, _)) -> (Fst(loc, e), t) 
  | (e, t) -> report_expecting e "product" t

let make_snd loc = function 
  | (e, TEproduct(_, t)) -> (Snd(loc, e), t) 
  | (e, t) -> report_expecting e "product" t


let make_deref loc (e, t) = 
    match t with 
    | TEref t' -> (Deref(loc, e), t') 
    | _ -> report_expecting e "ref type" t

let make_uop loc uop (e, t) = 
    match uop, t with 
    | NEG, TEint  -> (UnaryOp(loc, uop, e), t) 
    | NEG, t'     -> report_expecting e "integer" t
    | NOT, TEbool -> (UnaryOp(loc, uop, e), t) 
    | NOT, t'     -> report_expecting e "boolean" t

let make_bop loc bop (e1, t1) (e2, t2) = 
    match bop, t1, t2 with 
    | LT,  TEint,  TEint  -> (Op(loc, e1, bop, e2), TEbool)
    | LT,  TEint,  t      -> report_expecting e2 "integer" t
    | LT,  t,      _      -> report_expecting e1 "integer" t
    | ADD, TEint,  TEint  -> (Op(loc, e1, bop, e2), t1) 
    | ADD, TEint,  t      -> report_expecting e2 "integer" t
    | ADD, t,      _      -> report_expecting e1 "integer" t
    | SUB, TEint,  TEint  -> (Op(loc, e1, bop, e2), t1) 
    | SUB, TEint,  t      -> report_expecting e2 "integer" t
    | SUB, t,      _      -> report_expecting e1 "integer" t
    | MUL, TEint,  TEint  -> (Op(loc, e1, bop, e2), t1) 
    | MUL, TEint,  t      -> report_expecting e2 "integer" t
    | MUL, t,      _      -> report_expecting e1 "integer" t
    | DIV, TEint,  TEint  -> (Op(loc, e1, bop, e2), t1) 
    | DIV, TEint,  t      -> report_expecting e2 "integer" t
    | DIV, t,      _      -> report_expecting e1 "integer" t
    | OR,  TEbool, TEbool -> (Op(loc, e1, bop, e2), t1) 
    | OR,  TEbool,  t     -> report_expecting e2 "boolean" t
    | OR,  t,      _      -> report_expecting e1 "boolean" t
    | AND, TEbool, TEbool -> (Op(loc, e1, bop, e2), t1) 
    | AND, TEbool,  t     -> report_expecting e2 "boolean" t
    | AND, t,      _      -> report_expecting e1 "boolean" t
    | EQ,  TEbool, TEbool -> (Op(loc, e1, EQB, e2), t1) 
    | EQ,  TEint,  TEint  -> (Op(loc, e1, EQI, e2), TEbool)  
    | EQ,  _,      _      -> report_type_mismatch (e1, t1) (e2, t2) 
    | EQI, _, _           -> internal_error "EQI found in parsed AST"
    | EQB, _, _           -> internal_error "EQB found in parsed AST"

let make_while loc (e1, t1) (e2, t2)    = 
    if t1 = TEbool 
    then if t2 = TEunit 
         then (While(loc, e1, e2), TEunit)
         else report_expecting e2 "unit type" t2
    else report_expecting e1 "boolean" t1

let make_assign loc (e1, t1) (e2, t2) = 
    match t1 with 
    | TEref t -> if match_types(t, t2) 
                 then (Assign(loc, e1, e2), TEunit) 
                 else report_type_mismatch (e1, t) (e2, t2)
    | t -> report_expecting e1 "ref type" t 

let make_case loc left right x1 x2 (e1, t1) (e2, t2) (e3, t3) = 
    match t1 with 
    | TEunion(left', right') -> 
      if match_types(left, left') 
      then if match_types(right, right')
           then if match_types(t3, t2)
                then (Case(loc, e1, (x1, left, e2), (x2, right, e3)), t2)
                else report_type_mismatch (e2, t2) (e3, t3)
           else report_types_not_equal loc right right'
      else report_types_not_equal loc left left' 
    | t -> report_expecting e1 "disjoint union" t

(* Verifies that type used is actually defined at that point *)
let rec valid_type loc decls = function
  | TEcustom (s,_) -> TEcustom (s, find loc s decls)
  | TEref t -> TEref (valid_type loc decls t)
  | TEarrow (t1, t2) -> TEarrow (valid_type loc decls t1, valid_type loc decls t2)
  | TEproduct (t1, t2) -> TEproduct (valid_type loc decls t1, valid_type loc decls t2)
  | TEunion (t1, t2) -> TEunion (valid_type loc decls t1, valid_type loc decls t2)
  | t -> t

let rec match_type_list loc = function
  | [(e,t)] -> t
  | (e,t)::ts -> let t1 = match_type_list loc ts in
    if match_types (t, t1) then t else report_types_not_equal loc t t1
  | _ -> complain "Empty match statement"

let rec infer env decls e =
    match e with 
    | Unit _               -> (e, TEunit)
    | What _               -> (e, TEint) 
    | Integer _            -> (e, TEint) 
    | Boolean _            -> (e, TEbool)
    | Var (loc, x)         -> (e, find loc x env)
    | Seq(loc, el)         -> infer_seq loc env decls el
    | While(loc, e1, e2)   -> make_while loc (infer env decls e1) (infer env decls e2)
    | Ref(loc, e)          -> make_ref loc (infer env decls e)
    | Deref(loc, e)        -> make_deref loc (infer env decls e)
    | Assign(loc, e1, e2)  -> make_assign loc (infer env decls e1) (infer env decls e2)
    | UnaryOp(loc, uop, e) -> make_uop loc uop (infer env decls e)
    | Op(loc, e1, bop, e2) -> make_bop loc bop (infer env decls e1) (infer env decls e2)
    | If(loc, e1, e2, e3)  -> make_if loc (infer env decls e1) (infer env decls e2) (infer env decls e3)
    | Pair(loc, e1, e2)    -> make_pair loc (infer env decls e1) (infer env decls e2)
    | Fst(loc, e)          -> make_fst loc (infer env decls e)
    | Snd (loc, e)         -> make_snd loc (infer env decls e)
    | Inl (loc, t, e)      -> let t' = valid_type loc decls t in
      make_inl loc t' (infer env decls e)
    | Inr (loc, t, e)      -> let t' = valid_type loc decls t in
      make_inr loc t' (infer env decls e)
    | Case(loc, e, (x1, t1, e1), (x2, t2, e2)) ->
      let t1' = valid_type loc decls t1 in let t2' = valid_type loc decls t2 in
            make_case loc t1' t2' x1 x2 (infer env decls e) (infer ((x1, t1') :: env) decls e1)
                                                          (infer ((x2, t2') :: env) decls e2)
    | Lambda (loc, (x, t, e)) -> let t' = valid_type loc decls t in
      make_lambda loc x t' (infer ((x, t') :: env) decls e)
    | App(loc, e1, e2)        -> make_app loc (infer env decls e1) (infer env decls e2)
    | Let(loc, x, t, e1, e2)  -> let t' = valid_type loc decls t in
      make_let loc x t' (infer env decls e1) (infer ((x, t') :: env) decls e2)
    | LetFun(loc, f, (x, t1, body), t2, e) -> let t1' = valid_type loc decls t1 in
      let t2' = valid_type loc decls t2 in
      let env1 = (f, TEarrow(t1', t2')) :: env in
      let p = infer env1 decls e  in
      let env2 = (x, t1') :: env in
         (try let (bdy, bdy_t) = infer env2 decls body in
          if match_types (bdy_t, t2) then make_letfun loc f x t1' (bdy, bdy_t) p
          else report_types_not_equal loc bdy_t t2
          with _ -> let env3 = (f, TEarrow(t1', t2')) :: env2 in
                    let (bdy, bdy_t) = infer env3 decls body in
                    if match_types (bdy_t, t2) then make_letrecfun loc f x t1' (bdy, bdy_t) p
                    else report_types_not_equal loc bdy_t t2
         )
    | LetRecFun(_, _, _, _, _)  -> internal_error "LetRecFun found in parsed AST"
    | Decl(loc, x, l, e) -> let decls' = (x,loc)::decls in (* loc tracks which datatype declaration for dup names *)
      let env' = (List.map (fun (y, t) -> (y, TEarrow (valid_type loc decls' t, TEcustom(x, loc)))) l ) @ env in
      let (e', t) = infer env' decls' e in (Decl(loc, x, l, e'), t)
    | Match(loc, e, l) -> let (e', t) = infer env decls e in
     let ts = List.map (fun (s,x,e) -> let t1 = find loc s env in
         match t1 with TEarrow(t1', t2) -> if match_types (t, t2) then
                      let (e',t') = infer ((x,t1')::env) decls e in ((s,x,e'), t')
                        else report_types_not_equal loc t t2
                    | _ -> complain "Match expression only allowed on datatype instances" ) l in
         let t = match_type_list loc ts in (Match(loc, e, List.map (fun (a,b) -> a) ts), t)


and infer_seq loc env decls el =
    let rec aux decls carry = function
      | []        -> internal_error "empty sequence found in parsed AST"
      | [e]       -> let (e', t) = infer env decls e in (Seq(loc, List.rev (e' :: carry )), t)
      | e :: rest -> let (e', _) = infer env decls e in aux decls (e' :: carry) rest
    in aux decls [] el
       
let env_init = []
let decls_init = []

let check e = 
    let (e', _) = infer env_init decls_init e
    in e' 

