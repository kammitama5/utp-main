(******************************************************************************)
(* Title: utp/generic/utp_eval_tactic.thy                                     *)
(* Author: Frank Zeyda, University of York                                    *)
(******************************************************************************)
theory utp_eval_tactic
imports utp_generic_pred
begin

section {* Proof Tactic for Predicates *}

context GEN_PRED
begin

subsection {* Interpretation Function *}

definition EvalP ::
  "('VALUE, 'TYPE) ALPHA_PREDICATE \<Rightarrow>
   ('VALUE, 'TYPE) BINDING \<Rightarrow> bool" where
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP p b \<longleftrightarrow> b \<in> \<beta> p"

subsection {* Fundamental Theorem *}

theorem EvalP_intro :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 p1 = p2 \<longleftrightarrow>
 (\<alpha> p1) = (\<alpha> p2) \<and> (\<forall> b \<in> WF_BINDING . (EvalP p1 b) \<longleftrightarrow> (EvalP p2 b))"
apply (safe)
apply (simp add: EvalP_def)
apply (rule prod_eqI)
apply (assumption)
apply (subgoal_tac "\<beta> p1 \<subseteq> WF_BINDING")
apply (subgoal_tac "\<beta> p2 \<subseteq> WF_BINDING")
apply (auto) [1]
apply (simp_all add: pred_subset_binding)
done

theorem EvalP_intro_rule :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 (\<alpha> p1) = (\<alpha> p2);
 (\<forall> b \<in> WF_BINDING . (EvalP p1 b) \<longleftrightarrow> (EvalP p2 b))\<rbrakk> \<Longrightarrow> p1 = p2"
apply (subst EvalP_intro)
apply (simp_all)
done

subsection {* Distribution Theorems *}

theorem EvalP_LiftP :
"\<lbrakk>a \<in> WF_ALPHABET;
 f \<in> WF_BINDING_FUN a;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (LiftP a f) b = f b"
apply (simp add: EvalP_def)
apply (simp add: LiftP_def)
done

theorem EvalP_TrueP :
"\<lbrakk>a \<in> WF_ALPHABET;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (true a) b = True"
apply (simp add: EvalP_def)
apply (simp add: TrueP_def)
done

theorem EvalP_FalseP :
"\<lbrakk>a \<in> WF_ALPHABET;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (false a) b = False"
apply (simp add: EvalP_def)
apply (simp add: FalseP_def)
done

theorem EvalP_ExtP :
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 a \<in> WF_ALPHABET;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p \<oplus> a) b = (EvalP p b)"
apply (simp add: EvalP_def)
apply (simp add: ExtP_def)
done

theorem EvalP_ResP :
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 a \<in> WF_ALPHABET;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p \<ominus> a) b =
   (\<exists> b' \<in> WF_BINDING . EvalP p (b \<oplus> b' on a))"
apply (simp add: EvalP_def)
apply (simp add: ResP_def)
apply (safe)
apply (unfold Bex_def)
apply (rule_tac x = "b1" in exI)
apply (simp)
apply (rule_tac x = "b \<oplus> b' on a" in exI)
apply (simp)
apply (rule_tac x = "b" in exI)
apply (simp)
done

theorem EvalP_NotP :
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (\<not>p p) b = (\<not> (EvalP p b))"
apply (simp add: EvalP_def)
apply (simp add: NotP_def)
done

theorem EvalP_AndP :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p1 \<and>p p2) b = ((EvalP p1 b) \<and> (EvalP p2 b))"
apply (simp add: EvalP_def)
apply (simp add: AndP_def)
done

theorem EvalP_OrP :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p1 \<or>p p2) b = ((EvalP p1 b) \<or> (EvalP p2 b))"
apply (simp add: EvalP_def)
apply (simp add: OrP_def)
done

theorem EvalP_ImpliesP :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p1 \<Rightarrow>p p2) b = ((EvalP p1 b) \<longrightarrow> (EvalP p2 b))"
apply (simp add: ImpliesP_def)
apply (simp add: EvalP_OrP EvalP_NotP)
done

theorem EvalP_IffP :
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p1 \<Leftrightarrow>p p2) b = ((EvalP p1 b) \<longleftrightarrow> (EvalP p2 b))"
apply (simp add: IffP_def)
apply (simp add: EvalP_AndP EvalP_ImpliesP)
apply (auto)
done

theorem EvalP_ExistsResP :
"\<lbrakk>a \<in> WF_ALPHABET;
 p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (\<exists>-p a . p) b =
   (\<exists> b' \<in> WF_BINDING . EvalP p (b \<oplus> b' on a))"
apply (simp add: ExistsResP_def)
apply (simp add: EvalP_ResP)
done

theorem EvalP_ForallResP :
"\<lbrakk>a \<in> WF_ALPHABET;
 p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (\<forall>-p a . p) b =
   (\<forall> b' \<in> WF_BINDING . EvalP p (b \<oplus> b' on a))"
apply (simp add: ForallResP_def)
apply (simp add: EvalP_NotP EvalP_ExistsResP)
done

theorem EvalP_ExistsP :
"\<lbrakk>a \<in> WF_ALPHABET;
 p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (\<exists>p a . p) b =
   (\<exists> b' \<in> WF_BINDING . EvalP p (b \<oplus> b' on a))"
apply (simp add: ExistsP_def)
apply (simp add: EvalP_ExtP EvalP_ExistsResP)
done

theorem EvalP_ForallP :
"\<lbrakk>a \<in> WF_ALPHABET;
 p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (\<forall>p a . p) b =
   (\<forall> b' \<in> WF_BINDING . EvalP p (b \<oplus> b' on a))"
apply (simp add: ForallP_def)
apply (simp add: EvalP_ExtP EvalP_ForallResP)
done
end

(*
-- {* How do we elegantly deal with single-quantified variables? *}

-- {* The tentative theorem below requires typing to be fixed in the locale. *}

theorem (in GEN_PRED) EvalP_ResP_single_var :
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 b \<in> WF_BINDING\<rbrakk> \<Longrightarrow>
 EvalP (p \<ominus> {v}) b = (\<exists> x . x : (type v) \<and> EvalP p (b(v:=x)))"
apply (simp add: EvalP_def)
apply (simp add: ResP_def)
apply (simp add: typing_consistency)
apply (safe)
apply (rule_tac x = "b1 v" in exI)
apply (auto)
apply (simp add: EvalP_def)
apply (subgoal_tac "b(v := ba v) = b \<oplus> ba on {v}")
apply (simp add: EvalP_def)
apply (rule_tac x = "b \<oplus> ba on {v}" in exI)
apply (simp)
apply (rule_tac x = "b" in exI)
apply (simp)
apply (simp add: override_on_def)
apply (rule ext)
apply (auto)
done
*)

subsection {* Automatic Tactics *}

subsubsection {* Theorem Attributes *}

ML {*
  structure eval =
    Named_Thms (val name = "eval" val description = "eval theorems")
*}
setup eval.setup

ML {*
  structure taut =
    Named_Thms (val name = "taut" val description = "taut theorems")
*}
setup taut.setup

context GEN_PRED
begin
declare EvalP_intro [eval]
declare EvalP_LiftP [eval]
declare EvalP_TrueP [eval]
declare EvalP_FalseP [eval]
declare EvalP_ExtP [eval]
declare EvalP_ResP [eval]
(* declare EvalP_ResP_single_var [eval] *)
declare EvalP_NotP [eval]
declare EvalP_AndP [eval]
declare EvalP_OrP [eval]
declare EvalP_ImpliesP [eval]
declare EvalP_IffP [eval]
declare EvalP_ExistsResP [eval]
declare EvalP_ForallResP [eval]
declare EvalP_ExistsP [eval]
declare EvalP_ForallP [eval]
declare ClosureP_def [eval]
declare RefP_def [eval]
declare pred_alphabet [eval]
declare Tautology_def [taut]
declare Contradiction_def [taut]
declare Contingency_def [taut]
declare Refinement_def [taut]
end

subsubsection {* Proof Methods *}

text {*
  We note that the proof methods are also generic and do not have to be
  recreated for concrete instantiations of the @{text "GEN_PRED"} locale.
*}

ML{*
  fun utp_pred_eq_simpset ctxt =
    (simpset_of ctxt) addsimps (eval.get ctxt);
*}

ML{*
  fun utp_pred_taut_simpset ctxt =
    (utp_pred_eq_simpset ctxt) addsimps (taut.get ctxt);
*}

method_setup utp_pred_eq_tac = {*
  Attrib.thms >>
  (fn thms => fn ctxt =>
    SIMPLE_METHOD' (fn i =>
      CHANGED (asm_full_simp_tac
        (utp_pred_eq_simpset ctxt) i)))
*} "Proof Tactic for Predicate Equalities"

method_setup utp_pred_taut_tac = {*
  Attrib.thms >>
  (fn thms => fn ctxt =>
    SIMPLE_METHOD' (fn i =>
      CHANGED (asm_full_simp_tac
        (utp_pred_taut_simpset ctxt) i)))
*} "Proof Tactic for Predicate Tautologies"

text {* TODO: Integrate Holger's code for the simplifier to raise provisos. *}

subsection {* Proof Experiments *}

context GEN_PRED
begin
theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 p3 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 p1 \<and>p (p2 \<and>p p3) = (p1 \<and>p p2) \<and>p p3"
apply (utp_pred_eq_tac)
apply (auto)
done

theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 p3 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 p1 \<and>p (p2 \<or>p p3) = (p1 \<and>p p2) \<or>p (p1 \<and>p p3)"
apply (utp_pred_eq_tac)
apply (auto)
done

theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE;
 p3 \<in> WF_ALPHA_PREDICATE;
 p4 \<in> WF_ALPHA_PREDICATE;
 p5 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 p1 \<and>p p2 \<and>p p3 \<and>p p4 \<and>p p5 = (p1 \<and>p p5) \<and>p p3 \<and>p (p4 \<and>p p2)"
apply (utp_pred_eq_tac)
apply (auto)
done

theorem
"\<lbrakk>a \<in> WF_ALPHABET\<rbrakk> \<Longrightarrow>
 (true a) = \<not>p (false a)"
apply (utp_pred_eq_tac)
done

theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
 p2 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 taut (p1 \<and>p p2) \<Leftrightarrow>p (p2 \<and>p p1)"
apply (utp_pred_taut_tac)
apply (auto)
done

theorem
"\<lbrakk>p \<in> WF_ALPHA_PREDICATE;
 a \<in> WF_ALPHABET\<rbrakk> \<Longrightarrow>
 taut (\<forall>p a . \<not>p p) \<Leftrightarrow>p \<not>p (\<exists>p a . p)"
apply (utp_pred_taut_tac)
done

theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
  p2 \<in> WF_ALPHA_PREDICATE\<rbrakk> \<Longrightarrow>
 taut p1 \<or>p p2 \<sqsubseteq>p p1"
apply (utp_pred_taut_tac)
done

theorem
"\<lbrakk>p1 \<in> WF_ALPHA_PREDICATE;
  p2 \<in> WF_ALPHA_PREDICATE;
 (\<alpha> p1) = (\<alpha> p2)\<rbrakk> \<Longrightarrow>
 p1 \<or>p p2 \<sqsubseteq> p1"
apply (utp_pred_taut_tac)
done
end
end