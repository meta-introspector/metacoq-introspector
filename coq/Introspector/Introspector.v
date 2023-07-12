Require Import MetaCoq.Template.All.
  (* MetaCoq Quote Recursively Definition rec_def_tconst := tConst. *)
  (* MetaCoq Quote Recursively Definition rec_def_basic_ast := MetaCoq.Common.BasicAst. *)
  (* Set Printing All. *)
  (* MetaCoq Quote Recursively Definition rec_def_term := term. *)
  MetaCoq Quote Recursively Definition rec_def_term := mk_global_env.
  Redirect "rout1.txt" Print rec_def_term.
  Extraction Language Haskell.
  Extraction "ref_mk_global_env.hs" rec_def_term.
  
  (* MetaCoq Quote Recursively Definition rec_def_term2 := rec_def_term. *)
  (* Redirect "rout2.txt" Print rec_def_term2. *)
  (* Extraction rec_def_term2. *)
  
  (* MetaCoq Quote Recursively Definition rec_def_term3 := rec_def_term2. *)
  (* Redirect "rout3.txt" Print rec_def_term3. *)
  (* MetaCoq Quote Recursively Definition rec_def_term4 := rec_def_term3. *)
  (* Redirect "rout4.txt" Print rec_def_term4. *)
  (* MetaCoq Quote Recursively Definition rec_def_term5 := rec_def_term4. *)
  (* Redirect "rout5.txt" Print rec_def_term5. *)


(* Definition print_foo := *)
(*   match rec_def_exists2  with *)
(*   | (mk_global_env _ _ _, _)  => ExistsT *)
(*   end. *)
