(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: utp_hoare.thy                                                        *)
(* Author: Simon Foster, University of York (UK)                              *)
(******************************************************************************)

header {* Hoare Logic *}

theory utp_hoare
imports 
  utp_lattice 
  utp_recursion
  utp_iteration
  "../laws/utp_pred_laws"
  "../laws/utp_rel_laws"
  "../laws/utp_refine_laws"
  "../parser/utp_pred_parser"
begin

definition HoareP :: 
  "'a WF_PREDICATE \<Rightarrow> 'a WF_PREDICATE \<Rightarrow> 'a WF_PREDICATE \<Rightarrow> 'a WF_PREDICATE" ("_{_}\<^sub>p_" [200,0,201] 200) where
"p{Q}\<^sub>pr = ((p \<Rightarrow>\<^sub>p r\<acute>) \<sqsubseteq>\<^sub>p Q)"

declare HoareP_def [eval,evalr,evalrx]

syntax
  "_upred_hoare" :: "upred \<Rightarrow> upred \<Rightarrow> upred \<Rightarrow> upred" ("_{_}_" [55,0,56] 55)

translations
  "_upred_hoare p Q r"  == "CONST HoareP p Q r"

lemma HoareP_intro [intro]:
  "(p \<Rightarrow>\<^sub>p r\<acute>) \<sqsubseteq> Q \<Longrightarrow> `p{Q}r`"
  by (metis HoareP_def less_eq_WF_PREDICATE_def)

lemma HoareP_elim [elim]:
  "\<lbrakk> `p{Q}r`; \<lbrakk> (p \<Rightarrow>\<^sub>p r\<acute>) \<sqsubseteq> Q \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis HoareP_def less_eq_WF_PREDICATE_def)

theorem HoareP_AndP:
  "`p{Q}(r \<and> s)` = `p{Q}r \<and> p{Q}s`"
  apply (simp add:HoareP_def urename)
  apply (utp_pred_auto_tac)
done

theorem HoareP_OrP:
  "`(p \<or> q){Q}r` = `p{Q}r \<and> q{Q}r`"
  apply (simp add:HoareP_def urename)
  apply (utp_pred_auto_tac)
done

theorem HoareP_TrueR:
  "`p{Q}true`"
  by (metis ConvR_TrueP HoareP_intro RefineP_TrueP_refine utp_pred_simps(14))

theorem HoareP_SkipR:
  assumes "p \<in> WF_CONDITION"
  shows "`p{II}p`"
  using assms by (utp_xrel_auto_tac)
  
theorem HoareP_SemiR:
  assumes 
    "p \<in> WF_CONDITION" "r \<in> WF_CONDITION" "s \<in> WF_CONDITION"
    "Q1 \<in> WF_RELATION" "Q2 \<in> WF_RELATION"
    "`p{Q1}s`" "`s{Q2}r`" 
  shows "`p{Q1 ; Q2}r`"
proof
  from assms 
  have refs: "(p \<Rightarrow>\<^sub>p s\<acute>) \<sqsubseteq> Q1" "(s \<Rightarrow>\<^sub>p r\<acute>) \<sqsubseteq> Q2"
    by (auto elim!:HoareP_elim)

  thus "`(p \<Rightarrow> r\<acute>)` \<sqsubseteq> `Q1 ; Q2`"
    apply (rule_tac order_trans)
    apply (rule SemiR_mono_refine)
    apply (assumption)
    apply (assumption)
    apply (rule SemiR_spec_inter_refine)
    apply (simp_all add:assms)
  done
qed

lemma (in left_near_kleene_algebra) star_rtc_least_intro:
  "1 + x + y \<cdot> y \<le> y \<Longrightarrow> x\<^sup>\<star> \<le> y"
  by (metis add_lub less_eq_def star_inductl_one star_subdist)

lemma IterP_unfold:
  assumes "b \<in> WF_CONDITION" "S \<in> WF_RELATION"
  shows "while b do S od = (S ; while b do S od) \<lhd> b \<rhd> II"
proof -
  have "`while b do S od` = `(while b do S od \<and> b) \<or> (while b do S od \<and> \<not>b)`"
    by (metis AndP_comm WF_PREDICATE_cases)

  also have "... = `((S \<and> b) ; while b do S od) \<or> (II \<and> \<not>b)`"
    by (metis IterP_cond_false IterP_cond_true assms)

  also have "... = (S ; while b do S od) \<lhd> b \<rhd> II"
    by (metis AndP_comm CondR_def IterP_closure SemiR_AndP_left_precond WF_CONDITION_WF_RELATION assms)

  finally show ?thesis .
qed

lemma SemiR_ImpliesP_idem:
  "p \<in> WF_CONDITION \<Longrightarrow> `(p \<Rightarrow> p\<acute>) ; (p \<Rightarrow> p\<acute>)` = `(p \<Rightarrow> p\<acute>)`"
  by (frule SemiR_TrueP_precond, utp_xrel_auto_tac)

theorem HoareP_IterP:
  assumes "p \<in> WF_CONDITION" "b \<in> WF_CONDITION" "S \<in> WF_RELATION"
    "`(p \<and> b){S}p`"
  shows "`p{while b do S od}(\<not>b \<and> p)`"
using assms
    apply (rule_tac HoareP_intro)
    apply (erule_tac HoareP_elim)
    apply (simp add:IterP_def urename)
proof -
  from assms have "`p \<Rightarrow> p\<acute>` \<sqsubseteq> `(b \<and> S)\<^sup>\<star>`"
    apply (rule_tac star_rtc_least_intro)
    apply (simp add:one_WF_PREDICATE_def plus_WF_PREDICATE_def times_WF_PREDICATE_def)
    apply (simp add:SemiR_ImpliesP_idem)
    apply (utp_xrel_auto_tac)
  done


proof 
  have "while b do S od = (S ; while b do S od) \<lhd> b \<rhd> II"
    by (metis IterP_unfold assms)

  also have "`p \<Rightarrow> (\<not> b \<and> p)\<acute>` \<sqsubseteq> ..."
    apply (rule refine)
    defer
    using assms apply (utp_xrel_auto_tac)
    thm star_rtc_least
    using assms apply (utp_xrel_auto_tac)

using assms
    apply (rule_tac HoareP_intro)
    apply (erule_tac HoareP_elim)
    apply (simp add:IterP_def)
    apply (rule star_rtc_least_intro)
    apply (simp add:plus_WF_PREDICATE_def times_WF_PREDICATE_def one_WF_PREDICATE_def)
    thm star_rtc_least[of "S \<lhd> b \<rhd> II"]
    thm star_inductl[of p]
    apply (frule_tac SemiR_TrueP_precond)
    apply (frule_tac SemiR_TrueP_precond) back
    apply (simp add:IterP_def)
    apply (utp_xrel_auto_tac)
oops

end