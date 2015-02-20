(******************************************************************************)
(* Project: CML model for Isabelle/UTP                                        *)
(* File: utp_cml_types.thy                                                    *)
(* Author: Simon Foster, University of York (UK)                              *)
(******************************************************************************)

header {* CML expressions *}

theory utp_cml_types
imports 
  utp_cml_expr
begin

instantiation quote :: cmlv
begin

primrec Inject_quote :: "quote \<Rightarrow> cmlv" where
"Inject (QuoD x) = QuoteD x"

definition Type_quote :: "quote itself \<Rightarrow> cmlt" where
"Type_quote x = QuoteT"

instance
  apply (intro_classes)
  apply (case_tac x, case_tac y, simp)
  apply (auto)
  apply (case_tac xa, auto simp add:Type_quote_def)
  apply (case_tac xa, auto simp add:Type_quote_def)
  apply (simp add:image_def)
  apply (rule_tac x="QuoD xa" in exI)
  apply (auto)
done
end

(*
derive countable quote
derive linorder quote

lemma QuoteD_less_eq [simp]: 
  "QuoteD x \<le> QuoteD y \<longleftrightarrow> x \<le> y"
  by (auto simp add:less_eq_quote_def)

lemma QuoteD_less [simp]: 
  "QuoteD x < QuoteD y \<longleftrightarrow> x < y"
  by (simp add:less_quote_def)
*)
  
abbreviation "QuoteS x \<equiv> {QuoD x}"

abbreviation "vty_unit \<equiv> (UNIV :: unit set)"
abbreviation "vty_bool \<equiv> (UNIV :: bool set)"
abbreviation "vty_token \<equiv> (UNIV :: token set)"
abbreviation "vty_nat  \<equiv> Nats :: real set"
abbreviation "vty_nat1 \<equiv> {x\<in>vty_nat. x > 0}"
abbreviation "vty_int  \<equiv> Ints :: real set"
abbreviation "vty_rat  \<equiv> Rats :: real set"
abbreviation "vty_real \<equiv> (UNIV :: real set)"
abbreviation "vty_char \<equiv> (UNIV :: char set)"
abbreviation "vty_prod \<equiv> op \<times>"
abbreviation "vty_option A \<equiv> {Some x | x. x \<in> A} \<union> {None}"
abbreviation "vty_seq_of A  \<equiv> {xs. set xs \<subseteq> A}" 
abbreviation "vty_seq1_of A \<equiv> {xs. set xs \<subseteq> A \<and> length xs > 0}" 
abbreviation "vty_map_to X Y \<equiv> {f. DestBSet (bmdom f) \<subseteq> X \<and> DestBSet (bmran f) \<subseteq> Y}"
abbreviation "vty_inmap_to X Y \<equiv> {f. f \<in> vty_map_to X Y \<and> inj_on (DestBMap f) (DestBSet (bmdom(f))) }"

lemma vty_subtypes [simp]:
  "vty_nat1 \<subseteq> vty_nat"
  "vty_nat  \<subseteq> vty_int"
  "vty_int  \<subseteq> vty_rat"
  "vty_rat  \<subseteq> vty_real"
  apply (auto)
  apply (metis Ints_of_nat Nats_cases)
  apply (auto simp add:Ints_def Rats_def image_def)
  apply (rule_tac x="of_int xa" in exI)
  apply (simp add:of_int_def real_of_int_def)
done

lemma vty_int_members [simp]:
  "0 \<in> vty_int" "1 \<in> vty_int" "numeral n \<in> vty_int" "- numeral n \<in> vty_int"
  apply (auto simp add:Ints_def image_def)
  apply (rule_tac x="1" in exI, simp)
  apply (rule_tac x="numeral n" in exI, simp)
  apply (rule_tac x="- numeral n" in exI, simp)
done

(* FIXME: It may be that CML types need to be binding dependent
   as they can potentially depend on UTP variables. *)
definition InvS :: "'a set \<Rightarrow> ('a \<Rightarrow> bool cmle) \<Rightarrow> 'a set" where
"InvS A P = {x. x \<in> A \<and> (\<forall> b. \<lbrakk>P(x)\<rbrakk>\<^sub>* b = Some True)}"

declare InvS_def [eval,evale,evalp]

definition bset_Pow :: "'a set \<Rightarrow> 'a bset set" where
"bset_Pow A = {x. DestBSet x \<subseteq> A}"

declare bset_Pow_def [evalp]

nonterminal vty_decl and vty_decls

syntax
  "_vty_prod"    :: "vty \<Rightarrow> vty \<Rightarrow> vty" (infixr "*" 20)

syntax (xsymbols)
  "_vty_prod"    :: "vty \<Rightarrow> vty \<Rightarrow> vty" (infixr "\<times>" 20)

syntax
  "_vty_idt"     :: "idt \<Rightarrow> vty" ("_")
  "_vty_unit"    :: "vty" ("'(')")
  "_vty_quote"   :: "id \<Rightarrow> vty" ("<_>")
  "_vty_brack"   :: "vty \<Rightarrow> vty" ("'(_')")
  "_vty_union"   :: "vty \<Rightarrow> vty \<Rightarrow> vty" (infixr "|" 65)
  "_vty_inter"   :: "vty \<Rightarrow> vty \<Rightarrow> vty" (infixr "\<inter>" 60)
  "_vty_set"     :: "'a set \<Rightarrow> vty" ("@_")
  "_vty_bool"    :: "vty" ("@bool")
  "_vty_token"   :: "vty" ("@token")
  "_vty_nat"     :: "vty" ("@nat")
  "_vty_nat1"    :: "vty" ("@nat1")
  "_vty_int"     :: "vty" ("@int")
  "_vty_rat"     :: "vty" ("@rat")
  "_vty_char"    :: "vty" ("@char")
  "_vty_real"    :: "vty" ("@real")
  "_vty_option"  :: "vty \<Rightarrow> vty" ("[_]")
  "_vty_set_of"  :: "vty \<Rightarrow> vty" ("@set of _" [100] 100)
  "_vty_seq_of"  :: "vty \<Rightarrow> vty" ("@seq of _" [100] 100)
  "_vty_map_to"  :: "vty \<Rightarrow> vty \<Rightarrow> vty" ("@map _ to _" [0,100] 100)
  "_vty_inmap_to"  :: "vty \<Rightarrow> vty \<Rightarrow> vty" ("@inmap _ to _" [0,100] 100)
  "_vty_seq1_of" :: "vty \<Rightarrow> vty" ("@seq1 of _" [100] 100)
  "_vty_quo"     :: "vty \<Rightarrow> 'a set" ("\<parallel>_\<parallel>")
  "_vty_inv"     :: "vty \<Rightarrow> pttrn \<Rightarrow> n_pexpr \<Rightarrow> vty" ("_ inv _ == _")
  "_vty_collect" :: "n_pexpr \<Rightarrow> n_pexpr \<Rightarrow> vty" ("(1{_|/ _})")
  "_vty_decl"    :: "('a, 'm) pvar \<Rightarrow> vty \<Rightarrow> vty_decl" (infix ":" 50)
  "_vty_decls"   :: "[vty_decl, vty_decls] => vty_decls" ("_,/ _")
  ""             :: "vty_decl => vty_decls" ("_")
  "_vty_schema"  :: "vty_decls \<Rightarrow> n_pexpr \<Rightarrow> vty" ("(1[_|/ _])")
  
translations
  "_vty_idt x"     => "x"
  "_vty_unit"      == "CONST vty_unit"
  "_vty_quote x"   == "CONST QuoteS IDSTR(x)"
  "_vty_union x y" == "CONST union x y"
  "_vty_inter x y" == "CONST inter x y"
  "_vty_set x"     => "x"
  "_vty_brack x"   => "x"
  "_vty_bool"      == "CONST vty_bool"
  "_vty_token"     == "CONST vty_token"
  "_vty_nat"       == "CONST vty_nat"
  "_vty_nat1"      == "CONST vty_nat1"
  "_vty_int"       == "CONST vty_int"
  "_vty_rat"       == "CONST vty_rat"
  "_vty_real"      == "CONST vty_real"
  "_vty_char"      == "CONST vty_char"
  "_vty_prod x (_vty_prod y z)" == "CONST vty_prod x (_vty_prod y z)"
  "_vty_prod x y"  == "CONST vty_prod x y"
  "_vty_set_of A"  == "CONST bset_Pow A"
  "_vty_option A"  == "CONST vty_option A"
  "_vty_seq_of A"  == "CONST vty_seq_of A"
  "_vty_seq1_of A" == "CONST vty_seq1_of A"
  "_vty_map_to A B" == "CONST vty_map_to A B"
  "_vty_inmap_to A B" == "CONST vty_inmap_to A B"
  "_vty_quo x"     => "x"
  "_vty_inv A x P" == "CONST InvS A (\<lambda>x. P)"
  "_vty_collect v P" == "CONST CollectD v P"

(* Pattern parser *)

syntax
  "_vpttrn_id"     :: "idt \<Rightarrow> vpttrn" ("_")
  "_vpttrn_prod"   :: "vpttrn \<Rightarrow> vpttrns \<Rightarrow> vpttrn" ("'(_,/ _')")
  ""               :: "vpttrn => vpttrns"                  ("_")
  "_vpttrns"       :: "[vpttrn, vpttrns] => vpttrns"      ("_,/ _")

translations
  (* Parse rules for lambda abstractions *)
  "_vexpr_lambda (_vpttrn_id x) A e" => "CONST FunD A (\<lambda> x. e)"
  "_vexpr_lambda (_vpttrn_prod x (_vpttrns y z)) A e" 
      => "CONST vprod_case A (_vexpr_ulambda x (_vexpr_ulambda (_vpttrn_prod y z) e))"
  "_vexpr_lambda (_vpttrn_prod x y) A e" 
      => "CONST vprod_case A (_vexpr_ulambda x (_vexpr_ulambda y e))"
  "_vexpr_ulambda (_vpttrn_id x) e" => "(\<lambda> x. e)"
  "_vexpr_ulambda (_vpttrn_prod x (_vpttrns y z)) e" 
      => "CONST vprod_case (CONST UNIV) (_vexpr_ulambda x (_vexpr_ulambda (_vpttrn_prod y z) e))"
  "_vexpr_ulambda (_vpttrn_prod x y) e" 
      => "CONST vprod_case (CONST UNIV) (_vexpr_ulambda x (_vexpr_ulambda y e))"

term "|lambda (x,y,z) : @nat * @nat * @seq of @char @ true|"

term "FunD UNIV (\<lambda> y. |^x^| )"

definition "myfun = |lambda (x,y) : @nat * @nat @ ^x^|"

term "\<parallel>@set of @nat * @set of @nat\<parallel>"

term "|myfun(&u, &v)|"

hide_const myfun

term "\<parallel>@seq1 of @char\<parallel>"

term "CHR ''x''"

term "\<parallel>@seq1 of @char inv x == if (^x^ = ^CHR ''x''^) then true else false\<parallel>"

term "\<parallel>@map @char to @int\<parallel>"

term "`x := [3,1,4,2] : @seq1 of @nat1`"

term "\<parallel>{mk_prod($x : @int,$y : @int) | $x = $y}\<parallel>"

term "|[1] : @seq1 of @int|"

term "|forall x,y : @real, z,u : @int @ true|"

term "|lambda (x,y) : @nat * @nat @ ^x^|"

term "|iota x : @real @ ^x^ = 1|"

term "|let x : @real = 5 in true|"

term "|mk_prod(1,''hello'') hasType (@nat * @seq of @char)|"

end