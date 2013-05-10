(******************************************************************************)
(* Project: Mechanisation of the UTP                                          *)
(* File: utp_designs.thy                                                      *)
(* Authors: Simon Foster, University of York                                  *)
(******************************************************************************)

header {* UTP Designs *}

theory utp_designs
imports 
  "../tactics/utp_rel_tac"
  "../tactics/utp_xrel_tac"
  "../tactics/utp_expr_tac"
  "../core/utp_wp"
  "../laws/utp_pred_laws"
  "../laws/utp_rename_laws"
  "../laws/utp_subst_laws"
  "../laws/utp_rel_laws"
  utp_theory
begin

text {* Most predicates need a boolean type, so we here set the appropriate sort constraint *}

default_sort BOOL_SORT

subsection {* Design Constructs *}

abbreviation "okay  \<equiv> MkPlain ''okay'' BoolType True"
abbreviation "ok  \<equiv> VarP okay"
abbreviation "ok' \<equiv> VarP okay\<acute>"
abbreviation "ok'' \<equiv> VarP okay\<acute>\<acute>"
abbreviation "ok''' \<equiv> VarP okay\<acute>\<acute>\<acute>"

definition DesignD :: 
"'VALUE WF_PREDICATE \<Rightarrow>
 'VALUE WF_PREDICATE \<Rightarrow>
 'VALUE WF_PREDICATE" (infixr "\<turnstile>" 60) where
"p \<turnstile> q = `ok \<and> p \<Rightarrow> ok' \<and> q`"

definition SkipD :: "'VALUE WF_PREDICATE" where
"SkipD = true \<turnstile> II (REL_VAR - {okay,okay\<acute>})"

notation SkipD ("II\<^sub>D")

declare DesignD_def [eval,evalr,evalrx]
declare SkipD_def [eval,evalr,evalrx]

syntax
  "_upred_design" :: "upred \<Rightarrow> upred \<Rightarrow> upred" (infixr "\<turnstile>" 30)

translations
  "_upred_design p q"  == "CONST DesignD p q"

subsection {* Closure / UNREST theorems *}

lemma UNREST_SkipD_NON_REL_VAR [unrest]:
  "UNREST NON_REL_VAR II\<^sub>D"
  apply (simp add:SkipD_def DesignD_def)
  apply (force intro: unrest)
done

lemma UNREST_aux [unrest]:
  "\<lbrakk> aux x; UNREST AUX_VAR p \<rbrakk> \<Longrightarrow> UNREST {x} p"
  by (rule UNREST_subset, auto)

lemma DesignD_rel_closure [closure]:
  "\<lbrakk>P \<in> WF_RELATION; Q \<in> WF_RELATION\<rbrakk> \<Longrightarrow> P \<turnstile> Q \<in> WF_RELATION"
  by (simp add:DesignD_def closure)

lemma SkipD_rel_closure [closure]:
  "II\<^sub>D \<in> WF_RELATION"
  by (auto intro:closure simp add:SkipD_def)

subsection {* Design Laws *}

lemma DesignD_extreme_point_true:
  "false \<turnstile> false = false \<turnstile> true"
  by (utp_pred_tac)

lemma DesignD_extreme_point_nok:
  "true \<turnstile> false = \<not>p ok"
  by (utp_pred_tac)

lemma DesignD_export_precondition:
  "`(P \<turnstile> Q)` = `(P \<turnstile> P \<and> Q)`"
  by (utp_pred_tac)

text {* Design refinement law *}

lemma DesignD_refinement:
  assumes "UNREST AUX_VAR P1" "UNREST AUX_VAR P2"
          "UNREST AUX_VAR Q1" "UNREST AUX_VAR Q2"
  shows "P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2 = `[P1 \<Rightarrow> P2] \<and> [P1 \<and> Q2 \<Rightarrow> Q1]`"
proof -
  have "`(P1 \<turnstile> Q1) \<sqsubseteq> (P2 \<turnstile> Q2)` = `[P2 \<turnstile> Q2 \<Rightarrow> P1 \<turnstile> Q1]`"
    by (utp_pred_tac)

  also have "... = `[(ok \<and> P2 \<Rightarrow> ok' \<and> Q2) \<Rightarrow> (ok \<and> P1 \<Rightarrow> ok' \<and> Q1)]`"
    by (utp_pred_tac)

  also with assms have "... = `[(P2 \<Rightarrow> ok' \<and> Q2) \<Rightarrow> (P1 \<Rightarrow> ok' \<and> Q1)]`"
    apply (rule_tac trans)
    apply (rule_tac x="okay" in BoolType_aux_var_split_taut)
    apply (simp_all add:usubst typing defined)
  done

  also from assms have "... = `[(\<not> P2 \<Rightarrow> \<not> P1) \<and> ((P2 \<Rightarrow> Q2) \<Rightarrow> (P1 \<Rightarrow> Q1))]`"
    apply (rule_tac trans)
    apply (rule_tac x="okay\<acute>" in BoolType_aux_var_split_taut)
    apply (simp_all add:usubst typing defined)
  done

  also have "... = `[(P1 \<Rightarrow> P2) \<and> ((P2 \<Rightarrow> Q2) \<Rightarrow> (P1 \<Rightarrow> Q1))]`"
    by (utp_pred_auto_tac)

  also have "... = `[(P1 \<Rightarrow> P2)] \<and> [P1 \<and> Q2 \<Rightarrow> Q1]`"
    by (utp_pred_auto_tac)

  ultimately show ?thesis
    by (metis less_eq_WF_PREDICATE_def)

qed

lemma DesignD_diverge:
  "`(P \<turnstile> Q)[false/okay]` = true"
  by (simp add:DesignD_def usubst typing defined)

lemma WF_RELATION_UNREST_dash2 [unrest]: 
  "P \<in> WF_RELATION \<Longrightarrow> UNREST {x\<acute>\<acute>} P"
  apply (simp add:WF_RELATION_def)
  apply (rule UNREST_subset)
  apply (auto simp add:NON_REL_VAR_def)
done

lemma WF_RELATION_UNREST_dash3 [unrest]:
  "P \<in> WF_RELATION \<Longrightarrow> UNREST {x\<acute>\<acute>\<acute>} P"
  apply (simp add:WF_RELATION_def)
  apply (rule UNREST_subset)
  apply (auto simp add:NON_REL_VAR_def)
done

lemma DesignD_left_zero:
  assumes "P \<in> WF_RELATION" "Q \<in> WF_RELATION"
  shows "true ; (P \<turnstile> Q) = true"
proof -

  from assms have "`true ; (P \<turnstile> Q)` = `\<exists> okay\<acute>\<acute>\<acute>. true[$okay\<acute>\<acute>\<acute>/okay\<acute>] ; (P \<turnstile> Q)[$okay\<acute>\<acute>\<acute>/okay]`"
    by (simp add: SemiR_extract_variable closure)

  also from assms have "... = `(true[false/okay\<acute>] ; (P \<turnstile> Q)[false/okay]) \<or> (true[true/okay\<acute>] ; (P \<turnstile> Q)[true/okay])`"
    apply (rule_tac trans)
    apply (rule BoolType_aux_var_split_exists, simp_all)
    apply (simp add:usubst typing assms closure defined unrest)
  done

  also have "... = `((true ; true) \<or> (true ; ((P \<turnstile> Q)[true/okay])))`"
    by (simp add:usubst closure typing DesignD_diverge)

  ultimately show ?thesis
    by (simp add:closure SemiR_TrueP_precond)
qed

text {* The choice of two designs conjoins the assumptions and disjoins the commitments *}

lemma DesignD_choice:
  "(P1 \<turnstile> Q1) \<sqinter> (P2 \<turnstile> Q2) = `(P1 \<and> P2 \<turnstile> Q1 \<or> Q2)`"
  by (utp_pred_auto_tac)

lemma DesignD_cond:
  "`(P1 \<turnstile> Q1) \<lhd> b \<rhd> (P2 \<turnstile> Q2)` = `((P1 \<lhd> b \<rhd> P2) \<turnstile> (Q1 \<lhd> b \<rhd> Q2))`"
  by (utp_pred_auto_tac)

lemma DesignD_composition:
  assumes "P1 \<in> WF_RELATION" "P2 \<in> WF_RELATION" "Q1 \<in> WF_RELATION" "Q2 \<in> WF_RELATION"
          "UNREST AUX_VAR P1" "UNREST AUX_VAR P2" "UNREST AUX_VAR Q1" "UNREST AUX_VAR Q2"
  shows "`(P1 \<turnstile> Q1) ; (P2 \<turnstile> Q2)` = `((\<not> ((\<not> P1) ; true)) \<and> \<not> (Q1 ; (\<not> P2))) \<turnstile> (Q1 ; Q2)`"
proof -
  from assms have "`(P1 \<turnstile> Q1) ; (P2 \<turnstile> Q2)` = `\<exists> okay\<acute>\<acute>\<acute> . ((P1 \<turnstile> Q1)[$okay\<acute>\<acute>\<acute>/okay\<acute>] ; (P2 \<turnstile> Q2)[$okay\<acute>\<acute>\<acute>/okay])`"
    by (smt DesignD_rel_closure MkPlain_UNDASHED SemiR_extract_variable)

  also from assms 
  have "... = `((P1 \<turnstile> Q1)[false/okay\<acute>] ; (P2 \<turnstile> Q2)[false/okay]) \<or> ((P1 \<turnstile> Q1)[true/okay\<acute>] ; (P2 \<turnstile> Q2)[true/okay])`"
    by (simp add:ucases typing usubst defined closure unrest DesignD_def)

  also from assms 
  have "... = `((ok \<and> P1 \<Rightarrow> Q1) ; (P2 \<Rightarrow> ok' \<and> Q2)) \<or> ((\<not> (ok \<and> P1)) ; true)`"
    by (simp add: typing usubst defined unrest DesignD_def OrP_comm)

  also from assms
  have "... = `((\<not> (ok \<and> P1) \<or> Q1) ; (P2 \<Rightarrow> ok' \<and> Q2)) \<or> ((\<not> (ok \<and> P1)) ; true)`" 
    by (simp add:ImpliesP_def)

  also from assms
  have "... = `(((\<not> (ok \<and> P1)) ; (P2 \<Rightarrow> ok' \<and> Q2)) \<or> (Q1 ; (P2 \<Rightarrow> ok' \<and> Q2))) \<or> (\<not> (ok \<and> P1)) ; true`"
    by (metis (lifting, no_types) SemiR_OrP_distr)

  also have "... = `(((\<not> (ok \<and> P1)) ; (P2 \<Rightarrow> ok' \<and> Q2)) \<or> (\<not> (ok \<and> P1)) ; true) \<or> (Q1 ; (P2 \<Rightarrow> ok' \<and> Q2))`"
    by (metis (lifting, no_types) OrP_assoc OrP_comm)

  also have "... = `((\<not> (ok \<and> P1)) ; true) \<or> (Q1 ; (P2 \<Rightarrow> ok' \<and> Q2))`"
    by (smt SemiR_OrP_distl utp_pred_simps(9))

  also have "... = `((\<not> ok) ; true) \<or> ((\<not> P1) ; true) \<or> (Q1 ; (\<not> P2)) \<or> (ok' \<and> (Q1 ; Q2))`" 
  proof -
    have "`((\<not> (ok \<and> P1)) ; true)` = `((\<not> ok) ; true) \<or> ((\<not> P1) ; true)`"
      by (simp add: demorgan2 SemiR_OrP_distr)

    moreover from assms
    have "`(Q1 ; (P2 \<Rightarrow> ok' \<and> Q2))` = `(Q1 ; (\<not> P2)) \<or> (ok' \<and> (Q1 ; Q2))`"
      apply (simp add:ImpliesP_def SemiR_OrP_distl)
      apply (metis (no_types) AndP_comm MkPlain_UNDASHED SemiR_AndP_right_postcond UNDASHED_dash_DASHED VarP_precond_closure)
    done
  
    ultimately show ?thesis
      by (metis (lifting, no_types) OrP_assoc)
  qed

  also from assms
  have "... = `((\<not> ((\<not> P1) ; true)) \<and> \<not> (Q1 ; (\<not> P2))) \<turnstile> (Q1 ; Q2)`"
  proof -
    have "`(\<not> ok) ; true \<or> (\<not> P1) ; true` = `\<not> ok \<or> (\<not> P1) ; true`"
      by (simp add: SemiR_TrueP_precond closure)

    thus ?thesis
      apply (simp add: DesignD_def ImpliesP_def demorgan1)
      apply (smt OrP_assoc demorgan2 demorgan3)
    done

  qed

  ultimately show ?thesis
    by (simp)
qed


lemma DesignD_composition_cond:
  assumes "p1 \<in> WF_CONDITION" "P2 \<in> WF_RELATION" "Q1 \<in> WF_RELATION" "Q2 \<in> WF_RELATION"
          "UNREST AUX_VAR p1" "UNREST AUX_VAR P2" "UNREST AUX_VAR Q1" "UNREST AUX_VAR Q2"
  shows "`(p1 \<turnstile> Q1) ; (P2 \<turnstile> Q2)` = `(p1 \<and> \<not> (Q1 ; \<not> P2)) \<turnstile> (Q1 ; Q2)`"
proof -
  have "`\<not> (\<not> p1 ; true)` = p1"
    by (metis NotP_NotP NotP_cond_closure SemiR_TrueP_precond assms(1))

  with assms show ?thesis
    by (metis DesignD_composition WF_CONDITION_WF_RELATION)
qed

lemma condition_comp [simp]:
  "p1 \<in> WF_CONDITION \<Longrightarrow> `\<not> (\<not> p1 ; true)` = p1"
  by (metis NotP_NotP NotP_cond_closure SemiR_TrueP_precond)

lemma DesignD_composition_wp:
  assumes "p1 \<in> WF_CONDITION" "P2 \<in> WF_RELATION" "Q1 \<in> WF_RELATION" "Q2 \<in> WF_RELATION"
          "UNREST AUX_VAR p1" "UNREST AUX_VAR P2" "UNREST AUX_VAR Q1" "UNREST AUX_VAR Q2"
  shows "`(p1 \<turnstile> Q1) ; (P2 \<turnstile> Q2)` = `(p1 \<and> (Q1 wp P2)) \<turnstile> (Q1 ; Q2)`"
  by (metis (hide_lams, no_types) DesignD_composition_cond WeakPrecondP_def assms)

lemma minus_intersect [simp]:
  "vs1 - (vs1 - vs2) = vs1 \<inter> vs2"
  by (auto)

lemma SkipD_left_unit:
  assumes "P \<in> WF_RELATION" "Q \<in> WF_RELATION" "UNREST AUX_VAR P" "UNREST AUX_VAR Q"
  shows "II\<^sub>D ; (P \<turnstile> Q) = P \<turnstile> Q"
proof -
  have "II\<^sub>D ; (P \<turnstile> Q) = (\<exists>p {okay\<acute>\<acute>\<acute>}. II\<^sub>D[VarE okay\<acute>\<acute>\<acute>|okay\<acute>] ; (P \<turnstile> Q)[VarE okay\<acute>\<acute>\<acute>|okay])"
    by (metis DesignD_rel_closure MkPlain_UNDASHED SemiR_extract_variable SkipD_rel_closure assms(1) assms(2))

  also from assms
  have "... = P \<turnstile> Q"
    apply (simp add:ucases typing)
    apply (simp add:DesignD_def SkipD_def usubst closure typing defined unrest assms)
    apply (simp add:SemiR_TrueP_precond closure)
    apply (rule BoolType_aux_var_split_eq_intro[of okay])
    apply (simp_all)
    apply (simp add:usubst typing defined)
    apply (simp add:usubst typing defined assms closure unrest)
    apply (rule SemiR_SkipRA_left)
    apply (simp_all add:assms unrest closure var_dist)
  done

  ultimately show ?thesis
    by (simp)
qed

definition J_pred :: "'VALUE WF_PREDICATE" ("J") where
"J \<equiv> (ok \<Rightarrow>p ok') \<and>p II ((UNDASHED \<union> DASHED) - {okay,okay\<acute>})"

declare J_pred_def [eval,evalr]

abbreviation ok_true :: 
  "'VALUE WF_PREDICATE \<Rightarrow> 'VALUE WF_PREDICATE" ("_\<^sup>t" [150]) where
"p\<^sup>t \<equiv> `p[true/okay\<acute>]`"

abbreviation ok_false :: 
  "'VALUE WF_PREDICATE \<Rightarrow> 'VALUE WF_PREDICATE" ("_\<^sup>f" [150]) where
"p\<^sup>f \<equiv> `p[false/okay\<acute>]`"

syntax
  "_upred_ok_true"  :: "upred \<Rightarrow> upred" ("_\<^sup>t" [1000] 1000)
  "_upred_ok_false" :: "upred \<Rightarrow> upred" ("_\<^sup>f" [1000] 1000)
  "_upred_SkipD"    :: "upred" ("II\<^sub>D")
  "_upred_J"        :: "upred" ("J")

translations
  "_upred_ok_true p"  == "CONST ok_true p"
  "_upred_ok_false p" == "CONST ok_false p"
  "_upred_SkipD"      == "CONST SkipD"
  "_upred_J"          == "CONST J_pred"

definition H1 :: "'a WF_FUNCTION" where "H1(P) = `ok \<Rightarrow> P`"
definition H2 :: "'a WF_FUNCTION" where "H2(P) = `P ; J`"
definition H3 :: "'a WF_FUNCTION" where "H3(P) = `P ; II\<^sub>D`"
definition "isH4(P) \<equiv> `P ; true` = `true`"

declare H1_def [eval,evalr,evalrx]
declare H2_def [eval,evalr,evalrx]
declare H3_def [eval,evalr,evalrx]

lemma H1_true:
  "true is H1"
  by (utp_pred_tac)

lemma DesignD_is_H1 :
  "P \<turnstile> Q is H1"
  by (utp_pred_auto_tac)

lemma H1_AndP: "H1 (p \<and>p q) = H1(p) \<and>p H1(q)"
  by (utp_pred_auto_tac)

lemma H1_OrP: "H1 (p\<or>p q) = H1(p) \<or>p H1(q)"
  by (utp_pred_auto_tac)

lemma MkBool_True_compat [typing]: 
  "vtype x = BoolType \<Longrightarrow> MkBool True \<rhd> x"
  by (metis BOOL_SORT_class.Defined MkBool_type var_compat_intros(1))

lemma MkBool_False_compat [typing]: 
  "vtype x = BoolType \<Longrightarrow> MkBool False \<rhd> x"
 by (metis BOOL_SORT_class.Defined MkBool_type var_compat_intros(1))

lemma SemiR_TrueP_right_precond:
  assumes "P \<in> WF_CONDITION"
  shows "true ; P = P\<^sup>\<smile> ; true"
proof -
  have "true ; P = `true ; (P \<and> true)`"
    by simp

  also from assms have "... = P\<^sup>\<smile> ; true"
    by (simp only: SemiR_AndP_right_precond closure, simp)

  ultimately show ?thesis by simp
qed

lemma ImpliesP_export:
  "`p \<Rightarrow> q` = `p \<Rightarrow> (p \<and> q)`"
  by (utp_pred_tac)

(*
lemma "\<lbrakk> P \<in> WF_RELATION; e \<rhd>\<^sub>e x; UNREST_EXPR (DASHED \<union> NON_REL_VAR) e; Q \<in> WF_RELATION; x \<in> UNDASHED \<rbrakk> 
       \<Longrightarrow> `P ; (($x = e) \<and> Q)` = `P[e\<acute>/x\<acute>] ; Q[e/x]`"
  apply (rule trans)
  apply (rule SemiR_algebraic_rel)
  apply (simp add:closure unrest NON_REL_VAR_def)
  apply (rule closure)
  apply (rule closure)
  apply (rule unrest)
  apply (simp add: NON_REL_VAR_def)
  apply (auto intro:closure unrest)[1]
  apply (auto intro:closure unrest)[1]
  apply (simp add:urename typing defined closure)
  apply (simp)
  apply (rule closure)
  apply (rule closure)
  apply (rule unrest)
  
  apply (simp add:SemiR_algebraic_rel closure unrest typing defined)
*)

(*
lemma ImpliesP_SemiR_precond:
  "\<lbrakk> p \<in> WF_CONDITION; Q \<in> WF_RELATION; R \<in> WF_RELATION \<rbrakk> 
  \<Longrightarrow> `(p \<Rightarrow> Q) ; R` = `p \<Rightarrow> (Q ; R)`"
  apply (subgoal_tac "p ; true = p")
  apply (simp add:evalrx closure)
  apply (auto)
*)

lemma H1_algebraic_intro:
  assumes "P \<in> WF_RELATION" "(true ; P = true)" "(II\<^sub>D ; P = P)"
  shows "P is H1"
proof -

  let ?vs = "REL_VAR - {okay,okay\<acute>}"

  have "P = II\<^sub>D ; P" by (simp add: assms)

  also have "... = `(true \<turnstile> II\<^bsub>?vs\<^esub>) ; P`"
    by (simp add:SkipD_def)

  also have "... = `(ok \<Rightarrow> (ok' \<and> II\<^bsub>?vs\<^esub>)) ; P`"
    by (simp add:DesignD_def)

  also have "... = `(ok \<Rightarrow> (ok \<and> ok' \<and> II\<^bsub>?vs\<^esub>)) ; P`"
    by (smt ImpliesP_export)

  also have "... = `(ok \<Rightarrow> (ok \<and> $okay\<acute> = $okay \<and> II\<^bsub>?vs\<^esub>)) ; P`"
    apply (simp add:VarP_EqualP_aux typing defined)
    apply (utp_rel_auto_tac)
  done

  also have "... = `(ok \<Rightarrow> II) ; P`"
    by (simp add:SkipRA_unfold[THEN sym] SkipR_as_SkipRA ImpliesP_export[THEN sym])

  also have "... = `((\<not> ok) ; P \<or> P)`"
    by (simp add:ImpliesP_def SemiR_OrP_distr)

  also have "... = `(((\<not> ok) ; true) ; P \<or> P)`"
    by (simp add:SemiR_TrueP_precond closure)

  also have "... = `ok \<Rightarrow> P`"
    apply (simp add:SemiR_assoc[THEN sym] assms(2))
    apply (simp add:SemiR_TrueP_precond closure ImpliesP_def)
  done

  ultimately show ?thesis by (simp add:is_healthy_def H1_def)
qed

lemma H1_left_zero:
  assumes "P \<in> WF_RELATION" "P is H1"
  shows "true ; P = true"
proof -

  from assms have "`true ; P` = `true ; (ok \<Rightarrow> P)`"
    by (simp add:is_healthy_def H1_def)

  thus ?thesis
    by (metis DesignD_left_zero FalseP_rel_closure H1_def ImpliesP_def SemiR_OrP_distl TrueP_rel_closure DesignD_extreme_point_nok is_healthy_def assms utp_pred_simps(8))
qed

lemma H1_left_unit:
  assumes "P \<in> WF_RELATION" "P is H1"
  shows "II\<^sub>D ; P = P"
proof -

  let ?vs = "REL_VAR - {okay,okay\<acute>}"

  have "II\<^sub>D ; P = `(true \<turnstile> II\<^bsub>?vs\<^esub>) ; P`"
    by (simp add:SkipD_def)

  also have "... = `(ok \<Rightarrow> ok' \<and> II\<^bsub>?vs\<^esub>) ; P`"
    by (simp add:DesignD_def)

  also have "... = `(\<not> ok ; P) \<or> (ok \<and> P)`"
    apply (rule BoolType_aux_var_split_eq_intro[of okay])
    apply (simp_all add: usubst closure typing defined assms unrest)
    apply (simp add:VarP_EqualP_aux)
    apply (subgoal_tac "`($okay\<acute> = true \<and> II\<^bsub>REL_VAR - {okay, okay\<acute>}\<^esub>)` = `(okay :: 'a VAR) := true`")
    apply (simp add: AssignR_SemiR_left typing defined unrest SkipRA_def)
    apply (simp add: AssignR_alt_def typing unrest defined SkipRA_def)
  done

  also have "... = `((\<not> ok \<and> true) ; P) \<or> (ok \<and> P)`"
    by (metis AndP_comm utp_pred_simps(6))

  also from assms have "... = `(\<not> ok \<and> (true ; P)) \<or> (ok \<and> P)`"
    by (simp add:SemiR_AndP_left_precond closure unrest typing defined del:utp_pred_simps)

  also have "... = `(\<not> ok ; true) \<or> (ok \<and> P)`"
    by (simp add: assms H1_left_zero closure SemiR_TrueP_precond)

  also have "... = `\<not> ok \<or> (ok \<and> P)`"
    by (simp add:closure SemiR_TrueP_precond)

    also have "... = `(ok \<Rightarrow> P)`"
      by (utp_pred_tac)

    ultimately show ?thesis using assms
      by (simp add:H1_def is_healthy_def)
qed

lemma H1_algebraic:
  assumes "P \<in> WF_RELATION"
  shows "P is H1 \<longleftrightarrow> (true ; P = true) \<and> (II\<^sub>D ; P = P)"
   by (metis H1_algebraic_intro H1_left_unit H1_left_zero assms)
  
lemma H1_false:
  "H1 false \<noteq> false"
  apply (auto simp add:H1_def eval evale)
  apply (rule_tac x="\<B>(okay :=\<^sub>b FalseV)" in exI)
  apply (simp add:typing defined)
done

lemma H1_ImpliesP_SemiR:
  assumes "p \<in> WF_CONDITION" "Q \<in> WF_RELATION" "R \<in> WF_RELATION" "R is H1"
  shows "`p \<Rightarrow> (Q ; R)` = `(p \<Rightarrow> Q) ; R`"
proof -

  have "`(p \<Rightarrow> Q) ; R` = `\<not> p ; R \<or> (Q ; R)`"
    by (metis ImpliesP_def SemiR_OrP_distr)

  also have "... = `(\<not> p ; true) ; R \<or> (Q ; R)`"
    by (metis NotP_cond_closure SemiR_TrueP_precond assms(1))

  also have "... = `\<not> p \<or> (Q ; R)`"
    by (metis H1_left_zero SemiR_assoc assms condition_comp utp_pred_simps(3))

  ultimately show ?thesis
    by (metis ImpliesP_def)

qed

lemma H1_idempotent:
  "H1 (H1 p) = H1 p"
  by (rule, simp add:H1_def eval)

lemma J_split:
  assumes "P \<in> WF_RELATION"
  shows "P ; J = `P\<^sup>f \<or> (P\<^sup>t \<and> ok')`"
proof -

  let ?vs = "((UNDASHED \<union> DASHED) - {okay,okay\<acute>}) :: 'a VAR set"

  have "P ; J = `P ; ((ok \<Rightarrow> ok') \<and> II\<^bsub>?vs\<^esub>)`"
    by (simp add:J_pred_def)

  also have "... = P ; (ok \<Rightarrow>p ok \<and>p ok') \<and>p II ?vs"
    apply (utp_rel_auto_tac)
    apply (auto simp add:BindR_def)
  done

  also have "... = P ; ((\<not>p ok \<or>p (ok \<and>p ok')) \<and>p II ?vs)"
    by (utp_rel_auto_tac)

  also have "... = (P ; (\<not>p ok \<and>p II ?vs)) \<or>p (P ; (ok \<and>p (II ?vs \<and>p ok')))"
    by (smt AndP_OrP_distr AndP_assoc AndP_comm SemiR_OrP_distl)
    
  also have "... = `P\<^sup>f \<or> (P\<^sup>t \<and> ok')`"
  proof -
    from assms have "(P ; (\<not>p ok \<and>p II ?vs)) = P\<^sup>f"
      by (simp add: VarP_NotP_EqualP_aux SemiR_left_one_point closure typing defined unrest urename usubst SkipRA_right_unit var_dist)

    moreover have "(P ; (ok \<and>p (II ?vs \<and>p ok'))) = (P\<^sup>t \<and>p ok')"
    proof -
      have "(P ; (ok \<and>p (II ?vs \<and>p ok'))) = (P ; (ok \<and>p II ?vs)) \<and>p ok'"
        apply (insert SemiR_TrueP_postcond[OF VarP_precond_closure[of "okay\<acute>",simplified]])
        apply (auto simp add:evalrx closure assms)
      done

      moreover from assms have "(P ; (ok \<and>p II ?vs)) =  P\<^sup>t"
        by (simp add: VarP_EqualP_aux SemiR_left_one_point closure typing defined unrest urename usubst SkipRA_right_unit var_dist)
     
      ultimately show ?thesis by simp
    qed

    ultimately show ?thesis by (simp)
  qed

  ultimately show ?thesis by simp
qed

lemma H2_equivalence:
  assumes "P \<in> WF_RELATION"
  shows "P is H2 \<longleftrightarrow> [P\<^sup>f \<Rightarrow>p (P\<^sup>t)]p"
proof -
  from assms have "`[P \<Leftrightarrow> (P ; J)]` = `[P \<Leftrightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> ok'))]`"
    by (simp add:J_split)

  also have "... = `[(P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> ok')\<^sup>f \<and> (P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> ok')\<^sup>t]`"
    by (simp add: ucases)

  also have "... = `[(P\<^sup>f \<Leftrightarrow> P\<^sup>f) \<and> (P\<^sup>t \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t)]`"
    by (simp add:usubst closure typing defined)

  also have "... = `[P\<^sup>t \<Leftrightarrow> (P\<^sup>f \<or> P\<^sup>t)]`"
    by (utp_pred_tac)

  ultimately show ?thesis
    by (utp_pred_auto_tac)

qed

lemma J_closure [closure]:
  "J \<in> WF_RELATION"
  by (simp add:J_pred_def closure)

lemma J_is_H2:
  "H2(J) = J"
proof -
  have "H2(J) = J\<^sup>f \<or>p (J\<^sup>t \<and>p ok')"
    by (simp add:H2_def closure J_split)

  also have "... = ((\<not>p ok \<and>p II (REL_VAR - {okay, okay\<acute>})) \<or>p II (REL_VAR - {okay, okay\<acute>}) \<and>p ok')"
    by (simp add:J_pred_def usubst typing defined closure)

  also have "... = (\<not>p ok \<or>p ok') \<and>p II (REL_VAR - {okay, okay\<acute>})"
    by (utp_pred_auto_tac)

  also have "... = (ok \<Rightarrow>p ok') \<and>p II (REL_VAR - {okay, okay\<acute>})"
    by (utp_pred_tac)

  ultimately show ?thesis
    by (metis J_pred_def)
qed

lemma J_idempotent [simp]: "J ; J = J"
  by (simp add:H2_def[THEN sym] J_is_H2)

lemma H2_idempotent:
  "H2 (H2 p) = H2 p"
  apply (simp add:H2_def)
  apply (metis J_idempotent SemiR_assoc)
done

lemma DesignD_is_H2:
  "\<lbrakk> P \<in> WF_RELATION; Q \<in> WF_RELATION; UNREST AUX_VAR P; UNREST AUX_VAR Q \<rbrakk> \<Longrightarrow> P \<turnstile> Q is H2"
  apply (simp add:H2_equivalence closure)
  apply (simp add:DesignD_def usubst closure typing defined)
  apply (utp_pred_auto_tac)
done

lemma H1_H2_commute: "H1 (H2 p) = H2 (H1 p)"
  apply (simp add:H1_def H2_def ImpliesP_def)
  apply (smt DesignD_is_H2 FalseP_rel_closure H2_def SemiR_OrP_distr TrueP_rel_closure UNREST_FalseP UNREST_TrueP DesignD_extreme_point_nok is_healthy_def)
done

lemma H1_H2_is_DesignD:
  assumes "P \<in> WF_RELATION" "P is H1" "P is H2"
  shows "P = `(\<not> P\<^sup>f) \<turnstile> P\<^sup>t`"
proof -
  have "P = `ok \<Rightarrow> P`"
    by (metis H1_def assms(2) is_healthy_def) 
  
  also have "... = `ok \<Rightarrow> (P ; J)`"
    by (metis H2_def assms(3) is_healthy_def) 

  also have "... = `ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> ok'))`"
    by (metis J_split assms(1))

  also have "... = `ok \<and> (\<not> P\<^sup>f) \<Rightarrow> ok' \<and> P\<^sup>t`"
    by (utp_pred_auto_tac)

  also have "... = `(\<not> P\<^sup>f) \<turnstile> P\<^sup>t`"
    by (metis DesignD_def)

  ultimately show ?thesis by simp
qed

lemma SkipRA_compose [simp]:
  "\<lbrakk> HOMOGENEOUS vs1; HOMOGENEOUS vs2; vs1 \<subseteq> REL_VAR; vs2 \<subseteq> REL_VAR \<rbrakk> 
  \<Longrightarrow> II vs1 ; II vs2 = II (vs1 \<inter> vs2)"
  apply (subgoal_tac "vs1 \<inter> vs2 \<subseteq> REL_VAR")
  apply (auto simp add:evalrx closure relcomp_unfold var_dist)
  apply (rule_tac x="y \<oplus>\<^sub>x xa on (vs1 - vs2)" in exI)
  apply (auto)
  apply (case_tac "x \<in> vs2")
  apply (auto)
done

lemma SkipD_idempotent:
  "`II\<^sub>D ; II\<^sub>D` = `II\<^sub>D`"
  apply (simp add: SkipD_def DesignD_def)
  apply (simp add: SemiR_extract_variable[of _ _ okay] closure usubst typing defined)
  apply (simp add: BoolType_aux_var_split_exists closure usubst typing defined unrest)
  apply (rule BoolType_aux_var_split_eq_intro[of okay])
  apply (simp_all add: usubst typing defined closure unrest SemiR_TrueP_precond)

  apply (rule BoolType_aux_var_split_eq_intro[of "okay\<acute>"])
  apply (simp_all add: usubst typing defined closure unrest)
done

lemma H3_idempotent:
  "H3 (H3 p) = H3 p"
  by (metis H3_def SemiR_assoc SkipD_idempotent)

(* Theory of Designs *)
lift_definition DESIGNS :: "'VALUE WF_THEORY" is "({vs. vs \<subseteq> REL_VAR \<and> {okay,okay\<acute>} \<subseteq> vs}, {H1,H2})"
  by (simp add:WF_THEORY_def IDEMPOTENT_OVER_def H1_idempotent H2_idempotent)

lemma DESIGNS_WF_RELATION [closure]:
  "p \<in> THEORY_PRED DESIGNS \<Longrightarrow> p \<in> WF_RELATION"
  apply (auto simp add:THEORY_PRED_def DESIGNS.rep_eq utp_alphabets_def WF_RELATION_def)
  apply (metis (mono_tags) Compl_Diff_eq UNDASHED_DASHED_inter(15) UNREST_subset Un_empty_left VAR_subset compl_le_swap1 double_compl subset_empty)
done

lemma DESIGNS_H1 [closure]:
  "p \<in> THEORY_PRED DESIGNS \<Longrightarrow> p is H1"
  by (auto simp add:THEORY_PRED_def DESIGNS.rep_eq healthconds_def WF_RELATION_def)

lemma DESIGNS_H2 [closure]:
  "p \<in> THEORY_PRED DESIGNS \<Longrightarrow> p is H2"
  by (auto simp add:THEORY_PRED_def DESIGNS.rep_eq healthconds_def WF_RELATION_def)

lemma DESIGNS_intro:
  "\<lbrakk> P is H1; P is H2; P \<in> WF_RELATION \<rbrakk> \<Longrightarrow> P \<in> THEORY_PRED DESIGNS"
  apply (simp add:THEORY_PRED_def utp_alphabets_def healthconds_def DESIGNS.rep_eq)
  sorry
   
(*
lemma "(d1 = d2) \<longleftrightarrow> (\<forall> r. d1 wp r = d2 wp r)"
  apply (simp add:WeakPrecondA_def)
  apply (utp_alpha_tac)
  apply (utp_pred_tac)
*)
    
end