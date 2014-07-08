(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: utp_iteration.thy                                                    *)
(* Author: Simon Foster and Frank Zeyda, University of York (UK)              *)
(******************************************************************************)

header {* Constructs for Iteration *}

theory utp_iteration
imports 
  utp_recursion
  "../laws/utp_refine_laws"
begin

text {* Relational Iteration (Kleene Star) *}

lemma OneP_closure [closure]:
  "1 \<in> WF_RELATION"
  by (simp add:one_upred_def closure)

lemma TimesP_closure [closure]:
  "\<lbrakk> P \<in> WF_RELATION; Q \<in> WF_RELATION \<rbrakk> \<Longrightarrow> P\<cdot>Q \<in> WF_RELATION"
  by (simp add:times_upred_def closure)

lemma PowerP_closure [closure]:
  fixes P :: "'a upred"
  assumes "P \<in> WF_RELATION"
  shows "P^n \<in> WF_RELATION"
  by (induct n, simp_all add:closure assms)
  
lemma EvalRR_power [evalrr]:
  "\<lbrakk>P^n\<rbrakk>\<R> = \<lbrakk>P\<rbrakk>\<R> ^^ n"
  apply (induct n)
  apply (simp add:one_upred_def evalrr)
  apply (simp add:times_upred_def evalrr relpow_commute)
done

lemma EvalRX_power [evalrx]:
  "P \<in> WF_RELATION \<Longrightarrow> \<lbrakk>P^n\<rbrakk>RX = \<lbrakk>P\<rbrakk>RX ^^ n"
  apply (induct n)
  apply (simp add:one_upred_def evalrx)
  apply (simp add:times_upred_def evalrx closure relpow_commute)
done

lemma UNREST_PowerP [unrest]: "UNREST NON_REL_VAR p \<Longrightarrow> UNREST NON_REL_VAR (p ^ n)"
  apply (induct n)
  apply (simp add:unrest one_upred_def)
  apply (simp add:times_upred_def)
  apply (force intro:unrest)
done

lemma UNREST_NON_REL_VAR_PowerP:
  "\<lbrakk> vs \<sharp> p; vs \<subseteq> NON_REL_VAR \<rbrakk> \<Longrightarrow> vs \<sharp> p^n"
  apply (induct n)
  apply (simp_all add: one_upred_def times_upred_def)
  apply (metis UNREST_SkipR)
  apply (metis ExistsP_SemiR_NON_REL_VAR_expand1 UNREST_as_ExistsP)
done

instantiation upred :: (VALUE) star_op
begin

definition star_upred :: "'a upred \<Rightarrow> 'a upred" where
"star_upred p \<equiv> (\<Sqinter> { p ^ n | n. n \<in> UNIV})"

instance ..

end

context kleene_algebra
begin

definition star1 :: "'a \<Rightarrow> 'a" ("_\<^sup>+" [201] 200) where
"star1 p = p\<cdot>p\<^sup>\<star>"

end


declare star1_def [eval,evalr,evalrr,evalrx]

syntax
  "_n_upred_star"     :: "n_upred \<Rightarrow> n_upred" ("_\<^sup>\<star>" [900] 900)

translations
  "_n_upred_star p"   == "p\<^sup>\<star>"

lemma StarP_closure [closure]:
  "P \<in> WF_RELATION \<Longrightarrow> P\<^sup>\<star> \<in> WF_RELATION"
  by (auto intro:closure simp add:star_upred_def)

lemma EvalRR_StarP: "\<lbrakk>P\<^sup>\<star>\<rbrakk>\<R> = \<lbrakk>P\<rbrakk>\<R>\<^sup>*"
  apply (auto simp add: rtrancl_is_UN_relpow star_upred_def evalrr)
  apply (metis EvalRR_power)
done

lemma EvalRX_StarP [evalrx]: 
  "P \<in> WF_RELATION \<Longrightarrow> \<lbrakk>P\<^sup>\<star>\<rbrakk>RX = \<lbrakk>P\<rbrakk>RX\<^sup>*"
  apply (auto simp add: rtrancl_is_UN_relpow star_upred_def evalrx closure)
  apply (metis EvalRX_power)
done

lemma EvalRR_StarP_Union: "\<lbrakk>P\<^sup>\<star>\<rbrakk>\<R> = (\<Union>n. (\<lbrakk>P\<rbrakk>\<R> ^^ n))"
  apply (auto simp add: rtrancl_is_UN_relpow star_upred_def evalrr)
  apply (metis EvalRR_power)
done

lemma EvalRX_StarP_Union: 
  "P \<in> WF_RELATION \<Longrightarrow> \<lbrakk>P\<^sup>\<star>\<rbrakk>RX = (\<Union>n. (\<lbrakk>P\<rbrakk>RX ^^ n))"
  apply (auto simp add: rtrancl_is_UN_relpow star_upred_def evalrx closure)
  apply (metis EvalRX_power)
done

lemma UNREST_StarP [unrest]: "UNREST NON_REL_VAR p \<Longrightarrow> UNREST NON_REL_VAR (p\<^sup>\<star>)"
  by (auto intro:unrest simp add:star_upred_def)

lemma UNREST_NON_REL_VAR_StarP:
  "\<lbrakk> vs \<sharp> p; vs \<subseteq> NON_REL_VAR \<rbrakk> \<Longrightarrow> vs \<sharp> p\<^sup>\<star>"
  apply (simp add: star_upred_def)
  apply (rule unrest)
  apply (auto)
  apply (metis UNREST_NON_REL_VAR_PowerP)
done

instantiation upred :: (VALUE) dioid
begin

instance
  apply (intro_classes)
  apply (simp_all add:plus_upred_def times_upred_def 
                      zero_upred_def one_upred_def
                      less_upred_def)
  apply (utp_pred_auto_tac)+
done
end

instantiation upred :: (VALUE) kleene_algebra
begin

instance proof

  fix x :: "'a upred"
  show "x\<^sup>\<star> \<sqsubseteq> 1 + x \<cdot> x\<^sup>\<star>"
    by (auto simp add: evalrr EvalRR_StarP)

next

  fix x y z :: "'a upred"
  show "y \<sqsubseteq> z + x \<cdot> y \<longrightarrow> y \<sqsubseteq> x\<^sup>\<star> \<cdot> z"
    apply (simp add: evalrr EvalRR_StarP)
    apply (metis rel_dioid.add_lub rel_kleene_algebra.star_inductl)
  done

next

  fix x y z :: "'a upred"
  show "y \<sqsubseteq> z + y \<cdot> x \<longrightarrow> y \<sqsubseteq> z \<cdot> x\<^sup>\<star>"
    apply (simp add: evalrr EvalRR_StarP)
    apply (metis Un_least rel_kleene_algebra.star_inductr)
  done

qed (simp_all add: evalrr)
end

instance upred :: (VALUE) bounded_distributive_lattice ..

lemma UNREST_StarP_coerce:
  "- vs \<sharp> p \<Longrightarrow> - vs \<sharp> ((p\<^sup>\<star>) ;\<^sub>R II\<^bsub>vs\<^esub>)"
  apply (subst left_pre_kleene_algebra_class.star_unfoldl_eq[of p, THEN sym])
  apply (simp add: times_upred_def one_upred_def plus_upred_def SemiR_OrP_distr)
  apply (rule unrest)
  apply (auto intro:unrest UNREST_subset)[1]
  apply (rule UNREST_SemiR_general[of "in(- vs) \<union> nrel(- vs)" _ "- vs"])
  apply (rule UNREST_SemiR_general)
  apply (simp)
  apply (rule UNREST_NON_REL_VAR_StarP[of "NON_REL_VAR - vs"])
  apply (auto intro:UNREST_subset)[1]
  apply (simp)
  apply (simp add:var_dist)
  apply (rule UNREST_subset)
  apply (rule UNREST_SkipRA)
  apply (force)
  apply (simp add:var_dist)
  apply (auto simp add:var_defs)
done

lemma Star1P_closure [closure]:
  "P \<in> WF_RELATION \<Longrightarrow> P\<^sup>+ \<in> WF_RELATION"
  by (auto intro:closure simp add:star1_def)

lemma StarP_mono: "mono (\<lambda> x. (II \<or>\<^sub>p (p ;\<^sub>R x)))"
  apply (rule)
  apply (utp_rel_auto_tac)
done

lemma StarP_false [simp]: "false\<^sup>\<star> = II"
  apply (subst left_pre_kleene_algebra_class.star_unfoldl_eq[THEN sym])
  apply (simp add:plus_upred_def one_upred_def times_upred_def)
done

text {* Kleene star talks about finite iteration only, and is therefore a strict subset of
        the set of infinite recursions *}

lemma StarP_refines_WFP: "(\<mu> X \<bullet> II \<or>\<^sub>p (P ;\<^sub>R X)) \<sqsubseteq> P\<^sup>\<star>"
  apply (auto simp add:evalrr EvalRR_StarP gfp_def)
  apply (metis EvalRR_StarP rel_kleene_algebra.star_unfoldl_eq subset_refl)
done
lemma SFP_refines_StarP: "P\<^sup>\<star> \<sqsubseteq> (\<nu> X \<bullet> II \<or>\<^sub>p (P ;\<^sub>R X))"
  apply (rule lfp_lowerbound)
  apply (metis OrP_refine left_near_kleene_algebra_class.star_1l left_near_kleene_algebra_class.star_ref one_upred_def times_upred_def)
done

lemma StarP_refines_SFP: "(\<nu> X \<bullet> II \<or>\<^sub>p (P ;\<^sub>R X)) \<sqsubseteq> P\<^sup>\<star>"
  apply (rule lfp_greatest)
  apply (metis left_near_kleene_algebra_class.star_inductl_one one_upred_def plus_upred_def times_upred_def)
done

text {* The star is equivalent to the greatest fixed-point *}
theorem StarP_as_SFP: "P\<^sup>\<star> = (\<nu> X \<bullet> II \<or>\<^sub>p (P ;\<^sub>R X))"
  by (metis SFP_refines_StarP StarP_refines_SFP antisym)

definition 
  IterP :: " 'a upred 
           \<Rightarrow> 'a upred 
           \<Rightarrow> 'a upred" ("while _ do _ od") where
"IterP b P \<equiv> ((b \<and>\<^sub>p P)\<^sup>\<star>) \<and>\<^sub>p (\<not>\<^sub>p b\<acute>)"  

definition 
  IterInvP :: " 'a upred
             \<Rightarrow> 'a upred 
             \<Rightarrow> 'a upred 
             \<Rightarrow> 'a upred" ("while _ inv _ do _ od") where
"IterInvP b i P = IterP b P"  

  
syntax
  "_n_upred_while"     :: "n_upred \<Rightarrow> n_upred \<Rightarrow> n_upred" ("while _ do _ od")
  "_n_upred_while_inv" :: "n_upred \<Rightarrow> n_upred \<Rightarrow> n_upred \<Rightarrow> n_upred" ("while _ inv _ do _ od")

translations
  "_n_upred_while b p"       == "CONST IterP b p"
  "_n_upred_while_inv b i p" == "CONST IterInvP b i p"

declare EvalRR_StarP [evalrr]
declare IterP_def [eval, evalr, evalrr, evalrx]
declare IterInvP_def [eval, evalr, evalrr, evalrx]

lemma IterP_closure [closure]:
  "\<lbrakk> b \<in> WF_RELATION; P \<in> WF_RELATION \<rbrakk> \<Longrightarrow>
     while b do P od \<in> WF_RELATION"
  by (simp add:IterP_def closure)

lemma IterInvP_closure [closure]:
  "\<lbrakk> b \<in> WF_RELATION; P \<in> WF_RELATION \<rbrakk> \<Longrightarrow>
     while b inv i do P od \<in> WF_RELATION"
  by (simp add:IterInvP_def closure)

theorem IterP_false: "while false do P od = II"
  by (simp add:evalrr)

theorem IterP_true: "while true do P od = false"
  by (simp add:evalrr)

theorem IterP_cond_true:
  assumes "b \<in> WF_CONDITION" "P \<in> WF_RELATION"
  shows "`(while b do P od) \<and> b` = `(P \<and> b) ; while b do P od`"
proof -
  have "`while b do P od \<and> b` = `((b \<and> P)\<^sup>\<star> \<and> \<not>b\<acute>) \<and> b`"
    by (simp add:IterP_def)

  also have "... = `((II \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>)) \<and> \<not>b\<acute>) \<and> b`"
    by (metis left_pre_kleene_algebra_class.star_unfoldl_eq one_upred_def plus_upred_def times_upred_def)

  also have "... = `(b \<and> (II \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>))) \<and> \<not>b\<acute>`"
    by (metis AndP_assoc AndP_comm)

  also have "... = `(((b \<and> II) \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>))) \<and> \<not>b\<acute>`"
    by (smt AndP_OrP_distl AndP_rel_closure OrP_AndP_distr SemiR_AndP_left_precond StarP_closure WF_CONDITION_WF_RELATION assms utp_pred_simps(7) utp_pred_simps(8))

  also have "... = `(((II \<and> b\<acute>) \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>))) \<and> \<not>b\<acute>`"
    by (utp_rel_auto_tac)

  also have "... = `(((II \<and> b\<acute> \<and> \<not>b\<acute>) \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>))) \<and> \<not>b\<acute>`"
    by (metis (lifting, no_types) AndP_OrP_distr AndP_assoc AndP_idem)

  also have "... = `((b \<and> P) ; (b \<and> P)\<^sup>\<star>) \<and> \<not>b\<acute>`"
    by (metis AndP_contra utp_pred_simps(10) utp_pred_simps(5))

  also have "... = `(b \<and> P) ; while b do P od`"
    by (metis AndP_rel_closure ConvR_NotP IterP_def NotP_cond_closure PrimeP_WF_CONDITION_WF_POSTCOND SemiR_AndP_right_postcond StarP_closure WF_CONDITION_WF_RELATION assms(1) assms(2))

  finally show ?thesis by (metis AndP_comm)
qed

theorem IterP_cond_false:
  assumes "b \<in> WF_CONDITION" "P \<in> WF_RELATION"
  shows "`while b do P od \<and> \<not>b` = `II \<and> \<not>b`"
proof -
  have "`while b do P od \<and> \<not>b` = `((b \<and> P)\<^sup>\<star> \<and> \<not>b\<acute>) \<and> \<not>b`"
    by (simp add:IterP_def)

  also have "... = `((II \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>)) \<and> \<not>b\<acute>) \<and> \<not>b`"
    by (metis left_pre_kleene_algebra_class.star_unfoldl_eq one_upred_def plus_upred_def times_upred_def)

  also have "... = `(\<not>b \<and> (II \<or> ((b \<and> P) ; (b \<and> P)\<^sup>\<star>))) \<and> \<not>b\<acute>`"
    by (metis AndP_assoc AndP_comm)

  also have "... = `((\<not>b \<and> II) \<or> ((\<not>b \<and> (b \<and> P)) ; (b \<and> P)\<^sup>\<star>)) \<and> \<not>b\<acute>`"
    by (metis AndP_OrP_distl AndP_rel_closure NotP_cond_closure SemiR_AndP_left_precond StarP_closure WF_CONDITION_WF_RELATION assms(1) assms(2))

  also have "... = `(\<not>b \<and> II) \<and> \<not>b\<acute>`"
    by (metis (hide_lams, no_types) AndP_assoc AndP_comm AndP_contra OrP_comm SemiR_FalseP_left calculation utp_pred_simps(10) utp_pred_simps(5))

  also have "... = `(\<not>b \<and> II)`"
  using assms by (utp_xrel_auto_tac)

  finally show ?thesis
    by (metis AndP_comm) 
qed
   
theorem IterP_unfold:
  assumes "b \<in> WF_CONDITION" "S \<in> WF_RELATION"
  shows "while b do S od = (S ;\<^sub>R while b do S od) \<lhd> b \<rhd> II"
proof -
  have "`while b do S od` = `(while b do S od \<and> b) \<or> (while b do S od \<and> \<not>b)`"
    by (metis AndP_comm WF_PREDICATE_cases)

  also have "... = `((S \<and> b) ; while b do S od) \<or> (II \<and> \<not>b)`"
    by (metis IterP_cond_false IterP_cond_true assms)

  also have "... = (S ;\<^sub>R while b do S od) \<lhd> b \<rhd> II"
    by (metis AndP_comm CondR_def IterP_closure SemiR_AndP_left_precond WF_CONDITION_WF_RELATION assms)

  finally show ?thesis .
qed

theorem SemiR_ImpliesP_idem:
  "p \<in> WF_CONDITION \<Longrightarrow> `(p \<Rightarrow> p\<acute>) ; (p \<Rightarrow> p\<acute>)` = `(p \<Rightarrow> p\<acute>)`"
  by (frule SemiR_TrueP_precond, utp_xrel_auto_tac)

lemma SFP_refines_IterP:
  assumes "b \<in> WF_CONDITION" "P \<in> WF_RELATION"
  shows "while b do P od \<sqsubseteq> (\<nu> X \<bullet> ((P ;\<^sub>R X) \<lhd> b \<rhd> II))"
  by (metis IterP_unfold assms(1) assms(2) lfp_lowerbound order_refl)

(*
lemma "(\<And> P :: 'a upred. F(P) \<sqsubseteq> G(P)) \<Longrightarrow> \<nu> F \<sqsubseteq> \<nu> G"
  apply (rule lfp_mono)
  apply (auto)
  apply (subgoal_tac "{u. u \<sqsubseteq> F u} \<noteq> {}")
  apply (subgoal_tac "{u. u \<sqsubseteq> G u} \<noteq> {}")
  apply (simp add: lfp_def)
  
  apply (utp_rel_auto_tac)
  sledgehammer

  apply (utp_pred_auto_tac)
  apply (drule_tac x="b" in spec)
*)

lemma SupP_conj: "ps \<noteq> {} \<Longrightarrow> (\<Squnion> ps) \<and>\<^sub>p q = \<Squnion> {p \<and>\<^sub>p q | p. p \<in> ps}"
  apply (subgoal_tac "{p \<and>\<^sub>p q | p. p \<in> ps} \<noteq> {}")
  apply (utp_rel_tac)
  apply (subst Int_ac(3))
  apply (simp add: inter_Inter_dist)
  apply (auto)
  apply (metis EvalR_AndP Int_iff)
done

declare lfp_const [simp]

(*
lemma "`(\<nu> X. ((true ; X) \<lhd> b \<rhd> II))` \<sqsubseteq> `(\<nu> X. II \<or> ((b \<and> true) ; X)) \<and> \<not> b\<acute>`"
  apply (simp add:lfp_def)
  apply (subst SupP_conj)
  apply (auto)
  apply (metis OrP_ref utp_pred_simps(9))
  apply (rule Inf_superset_mono)
  apply (auto)
  nitpick
  sledgehammer  
*)


lemma StarP_denest: "`(P \<or> Q)\<^sup>\<star>` = `(P\<^sup>\<star> ; Q\<^sup>\<star>)\<^sup>\<star>`"
  by (metis left_pre_kleene_algebra_class.star_denest plus_upred_def times_upred_def)

(* Can't prove this yet, though I reckon it's true *)
lemma IterP_refines_SFP:
  assumes "b \<in> WF_CONDITION" "P \<in> WF_RELATION"
shows "(\<nu> X \<bullet> ((P ;\<^sub>R X) \<lhd> b \<rhd> II)) \<sqsubseteq> while b do P od"
  apply (simp add:IterP_def StarP_as_SFP)
oops
 
end
