section {* Designs *}

theory utp_designs
imports
  utp_rel
  utp_wp
  utp_theory
begin

text {* In UTP, in order to explicitly record the termination of a program, 
a subset of alphabetized relations is introduced. These relations are called 
designs and their alphabet should contain the special boolean observational variable ok. 
It is used to record the start and termination of a program. *}

subsection {* Definitions *}

text {* In the following, the definitions of designs alphabets, designs and 
healthiness (well-formedness) conditions are given. The healthiness conditions of
designs are defined by $H1$, $H2$, $H3$ and $H4$.*}

record alpha_d = des_ok::bool

text {* The ok variable is defined using the syntactic translation \emph{VAR} *}

definition "ok = VAR des_ok"

declare ok_def [upred_defs]

lemma uvar_ok [simp]: "uvar ok"
  by (unfold_locales, simp_all add: ok_def)

lemma ok_ord [usubst]:
  "$ok \<prec>\<^sub>v $ok\<acute>"
  by (simp add: var_name_ord_def)

type_synonym '\<alpha> alphabet_d  = "'\<alpha> alpha_d_scheme alphabet"
type_synonym ('a, '\<alpha>) uvar_d = "('a, '\<alpha> alphabet_d) uvar"
type_synonym ('\<alpha>, '\<beta>) relation_d = "('\<alpha> alphabet_d, '\<beta> alphabet_d) relation"
type_synonym '\<alpha> hrelation_d = "'\<alpha> alphabet_d hrelation"

definition des_lens :: "('\<alpha>, '\<alpha> alphabet_d) lens" ("\<Sigma>\<^sub>D") where
"des_lens = \<lparr> lens_get = more, lens_put = fld_put more_update \<rparr>"

syntax
  "_svid_alpha_d"  :: "svid" ("\<Sigma>\<^sub>D")

translations
  "_svid_alpha_d" => "\<Sigma>\<^sub>D"

declare des_lens_def [upred_defs]

lemma uvar_des_lens [simp]: "uvar des_lens"
  by (unfold_locales, simp_all add: des_lens_def)

lemma ok_indep_des_lens [simp]: "ok \<bowtie> des_lens" "des_lens \<bowtie> ok"
  by (rule lens_indepI, simp_all add: ok_def des_lens_def)+

lemma ok_des_bij_lens: "bij_lens (ok +\<^sub>L des_lens)"
  by (unfold_locales, simp_all add: ok_def des_lens_def lens_plus_def prod.case_eq_if)

text {* It would be nice to be able to prove some general distributivity properties
        about these lifting operators. I don't know if that's possible somehow... *}

abbreviation lift_desr :: "('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("\<lceil>_\<rceil>\<^sub>D")
where "\<lceil>P\<rceil>\<^sub>D \<equiv> P \<oplus>\<^sub>p (des_lens \<times>\<^sub>L des_lens)"

abbreviation drop_desr :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("\<lfloor>_\<rfloor>\<^sub>D")
where "\<lfloor>P\<rfloor>\<^sub>D \<equiv> P \<restriction>\<^sub>p (des_lens \<times>\<^sub>L des_lens)"

definition design::"('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>" 60)
where "P \<turnstile> Q = ($ok \<and> P \<Rightarrow> $ok\<acute> \<and> Q)"

text {* An rdesign is a design that uses the Isabelle type system to prevent reference to ok in the
        assumption and commitment. *}

definition rdesign::"('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>\<^sub>r" 60)
where "(P \<turnstile>\<^sub>r Q) = \<lceil>P\<rceil>\<^sub>D \<turnstile> \<lceil>Q\<rceil>\<^sub>D" 

text {* An ndesign is a normal design, i.e. where the assumption is a condition *}

definition ndesign::"'\<alpha> condition \<Rightarrow> ('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>\<^sub>n" 60)
where "(p \<turnstile>\<^sub>n Q) = (\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q)"

definition skip_d :: "'\<alpha> hrelation_d" ("II\<^sub>D")
where "II\<^sub>D \<equiv> (true \<turnstile>\<^sub>r II)"

definition assigns_d :: "'\<alpha> usubst \<Rightarrow> '\<alpha> hrelation_d" ("\<langle>_\<rangle>\<^sub>D")
where "assigns_d \<sigma> = (true \<turnstile>\<^sub>r assigns_r \<sigma>)"

syntax
  "_assignmentd" :: "svid_list \<Rightarrow> uexprs \<Rightarrow> logic"  (infixr ":=\<^sub>D" 55)

translations
  "_assignmentd xs vs" => "CONST assigns_d (_mk_usubst (CONST id) xs vs)"

definition J :: "'\<alpha> hrelation_d"
where "J = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)"

definition "H1 (P)  \<equiv>  $ok \<Rightarrow> P"

definition "H2 (P)  \<equiv>  P ;; J"

definition "H3 (P)  \<equiv>  P ;; II\<^sub>D"

definition "H4 (P)  \<equiv> ((P;;true) \<Rightarrow> P)"

syntax
  "_ok_f"  :: "logic \<Rightarrow> logic" ("_\<^sup>f" [1000] 1000)
  "_ok_t"  :: "logic \<Rightarrow> logic" ("_\<^sup>t" [1000] 1000)
  "_top_d" :: "logic" ("\<top>\<^sub>D")
  "_bot_d" :: "logic" ("\<bottom>\<^sub>D")

translations
  "P\<^sup>f" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ovar CONST ok) false) P"
  "P\<^sup>t" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ovar CONST ok) true) P"
  "\<top>\<^sub>D" => "CONST not_upred (CONST var (CONST ivar CONST ok))"
  "\<bottom>\<^sub>D" => "true"

definition pre_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("pre\<^sub>D'(_')") where
"pre\<^sub>D(P) = \<lfloor>\<not> P\<lbrakk>true,false/$ok,$ok\<acute>\<rbrakk>\<rfloor>\<^sub>D"

definition post_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("post\<^sub>D'(_')") where
"post\<^sub>D(P) = \<lfloor>P\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>\<rfloor>\<^sub>D"

definition wp_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> '\<beta> condition \<Rightarrow> '\<alpha> condition" (infix "wp\<^sub>D" 60) where
"Q wp\<^sub>D r = (\<lfloor>pre\<^sub>D(Q) ;; true\<rfloor>\<^sub>< \<and> (post\<^sub>D(Q) wp r))"

declare design_def [upred_defs]
declare rdesign_def [upred_defs]
declare skip_d_def [upred_defs]
declare J_def [upred_defs]
declare pre_design_def [upred_defs]
declare post_design_def [upred_defs]
declare wp_design_def [upred_defs]
declare assigns_d_def [upred_defs]

declare H1_def [upred_defs]
declare H2_def [upred_defs]
declare H3_def [upred_defs]
declare H4_def [upred_defs]

lemma drop_desr_inv [simp]: "\<lfloor>\<lceil>P\<rceil>\<^sub>D\<rfloor>\<^sub>D = P"
  by (simp add: arestr_aext prod_mwb_lens)
  
lemma lift_desr_inv:
  fixes P :: "('\<alpha>, '\<beta>) relation_d"
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P"
  shows "\<lceil>\<lfloor>P\<rfloor>\<^sub>D\<rceil>\<^sub>D = P"
proof -
  have "bij_lens (des_lens \<times>\<^sub>L des_lens +\<^sub>L (in_var ok +\<^sub>L out_var ok) :: (_, '\<alpha> alpha_d_scheme \<times> '\<beta> alpha_d_scheme) lens)"
    (is "bij_lens (?P)")
  proof -
    have "?P \<approx>\<^sub>L (ok +\<^sub>L des_lens) \<times>\<^sub>L (ok +\<^sub>L des_lens)" (is "?P \<approx>\<^sub>L ?Q")
      apply (simp add: in_var_def out_var_def prod_as_plus)
      apply (simp add: prod_as_plus[THEN sym])
      apply (meson lens_equiv_sym lens_equiv_trans lens_indep_prod lens_plus_comm lens_plus_prod_exchange ok_indep_des_lens)
    done
    moreover have "bij_lens ?Q"
      by (simp add: ok_des_bij_lens prod_bij_lens)
    ultimately show ?thesis
      by (metis bij_lens_equiv lens_equiv_sym)
  qed

  with assms show ?thesis
    apply (rule_tac aext_arestr[of _ "in_var ok +\<^sub>L out_var ok"])
    apply (simp add: prod_mwb_lens)
    apply (simp)
    apply (metis alpha_in_var lens_indep_prod lens_indep_sym ok_indep_des_lens out_var_def prod_as_plus)
    using unrest_var_comp apply blast
  done
qed

subsection {* Design laws *}

lemma prod_lens_indep_in_var [simp]:
  "a \<bowtie> x \<Longrightarrow> a \<times>\<^sub>L b \<bowtie> in_var x"
  by (metis in_var_def in_var_indep out_in_indep out_var_def plus_pres_lens_indep prod_as_plus)

lemma prod_lens_indep_out_var [simp]:
  "b \<bowtie> x \<Longrightarrow> a \<times>\<^sub>L b \<bowtie> out_var x"
  by (metis in_out_indep in_var_def out_var_def out_var_indep plus_pres_lens_indep prod_as_plus)

lemma unrest_out_des_lift [unrest]: "out\<alpha> \<sharp> p \<Longrightarrow> out\<alpha> \<sharp> \<lceil>p\<rceil>\<^sub>D"
  by (pred_tac, auto simp add: out\<alpha>_def des_lens_def prod_lens_def)

lemma lift_dist_seq [simp]:
  "\<lceil>P ;; Q\<rceil>\<^sub>D = (\<lceil>P\<rceil>\<^sub>D ;; \<lceil>Q\<rceil>\<^sub>D)"
  by (rel_tac, metis alpha_d.select_convs(2))

lemma lift_des_skip_dr_unit_unrest: "$ok\<acute> \<sharp> P \<Longrightarrow> (P ;; \<lceil>II\<rceil>\<^sub>D) = P"
  by (rel_tac, metis alpha_d.surjective alpha_d.update_convs(1))

lemma true_is_design:
  "(false \<turnstile> true) = true"
  by rel_tac

lemma true_is_rdesign:
  "(false \<turnstile>\<^sub>r true) = true"
  by rel_tac

theorem design_refinement:
  assumes 
    "$ok \<sharp> P1" "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> P2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "(P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2) \<longleftrightarrow> (`P1 \<Rightarrow> P2` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`)"
proof -
  have "(P1 \<turnstile> Q1) \<sqsubseteq> (P2 \<turnstile> Q2) \<longleftrightarrow> `($ok \<and> P2 \<Rightarrow> $ok\<acute> \<and> Q2) \<Rightarrow> ($ok \<and> P1 \<Rightarrow> $ok\<acute> \<and> Q1)`"
    by pred_tac
  also with assms have "... = `(P2 \<Rightarrow> $ok\<acute> \<and> Q2) \<Rightarrow> (P1 \<Rightarrow> $ok\<acute> \<and> Q1)`"
    by (subst subst_bool_split[of "in_var ok"], simp_all, subst_tac)
  also with assms have "... = `(\<not> P2 \<Rightarrow> \<not> P1) \<and> ((P2 \<Rightarrow> Q2) \<Rightarrow> P1 \<Rightarrow> Q1)`"
    by (subst subst_bool_split[of "out_var ok"], simp_all, subst_tac)
  also have "... \<longleftrightarrow> `(P1 \<Rightarrow> P2)` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`"
    by (pred_tac)
  finally show ?thesis .
qed

theorem rdesign_refinement:
  "(P1 \<turnstile>\<^sub>r Q1 \<sqsubseteq> P2 \<turnstile>\<^sub>r Q2) \<longleftrightarrow> (`P1 \<Rightarrow> P2` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`)"
  apply (simp add: rdesign_def)
  apply (subst design_refinement)
  apply (simp_all add: unrest)
  apply (pred_tac)
  apply (metis alpha_d.select_convs(2))+
done

lemma design_refine_intro:
  assumes "`P1 \<Rightarrow> P2`" "`P1 \<and> Q2 \<Rightarrow> Q1`"
  shows "P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2"
  using assms unfolding upred_defs
  by pred_tac

theorem design_ok_false [usubst]: "(P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk> = true"
  by (simp add: design_def usubst)

theorem design_pre: 
  "\<not> (P \<turnstile> Q)\<^sup>f = ($ok \<and> P\<^sup>f)"
  by (simp add: design_def, subst_tac)
     (metis (no_types, hide_lams) not_conj_deMorgans true_not_false(2) utp_pred.compl_top_eq 
            utp_pred.sup.idem utp_pred.sup_compl_top)

declare des_lens_def [upred_defs]
declare lens_create_def [upred_defs]
declare prod_lens_def [upred_defs]
declare in_var_def [upred_defs]

theorem rdesign_pre [simp]: "pre\<^sub>D(P \<turnstile>\<^sub>r Q) = P"
  by pred_tac

theorem rdesign_post [simp]: "post\<^sub>D(P \<turnstile>\<^sub>r Q) = (P \<Rightarrow> Q)"
  by pred_tac

theorem design_true_left_zero: "(true ;; (P \<turnstile> Q)) = true"
proof -
  have "(true ;; (P \<turnstile> Q)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> true\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk>) \<or> (true\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; true\<^sub>h) \<or> (true ;; ((P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>)))"
    by (subst_tac, rel_tac)
  also have "... = true"
    by (subst_tac, simp add: precond_right_unit unrest)
  finally show ?thesis .
qed

theorem design_top_left_zero: "(\<top>\<^sub>D ;; (P \<turnstile> Q)) = \<top>\<^sub>D"
  by (rel_tac, meson alpha_d.select_convs(1))

theorem design_choice:
  "(P\<^sub>1 \<turnstile> P\<^sub>2) \<sqinter> (Q\<^sub>1 \<turnstile> Q\<^sub>2) = ((P\<^sub>1 \<and> Q\<^sub>1) \<turnstile> (P\<^sub>2 \<or> Q\<^sub>2))"
  by rel_tac

theorem design_inf:
  "(P\<^sub>1 \<turnstile> P\<^sub>2) \<squnion> (Q\<^sub>1 \<turnstile> Q\<^sub>2) = ((P\<^sub>1 \<or> Q\<^sub>1) \<turnstile> ((P\<^sub>1 \<Rightarrow> P\<^sub>2) \<and> (Q\<^sub>1 \<Rightarrow> Q\<^sub>2)))"
  by rel_tac

theorem rdesign_choice:
  "(P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2) \<sqinter> (Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2) = ((P\<^sub>1 \<and> Q\<^sub>1) \<turnstile>\<^sub>r (P\<^sub>2 \<or> Q\<^sub>2))"
  by rel_tac

theorem design_condr:
  "((P\<^sub>1 \<turnstile> P\<^sub>2) \<triangleleft> b \<triangleright> (Q\<^sub>1 \<turnstile> Q\<^sub>2)) = ((P\<^sub>1 \<triangleleft> b \<triangleright> Q\<^sub>1) \<turnstile> (P\<^sub>2 \<triangleleft> b \<triangleright> Q\<^sub>2))"
  by rel_tac

lemma design_top:
  "(P \<turnstile> Q) \<sqsubseteq> \<top>\<^sub>D"
  by rel_tac

lemma design_bottom:
  "\<bottom>\<^sub>D \<sqsubseteq> (P \<turnstile> Q)"
  by simp

lemma design_USUP: 
  assumes "A \<noteq> {}"
  shows "(\<Sqinter> i \<in> A \<bullet> P(i) \<turnstile> Q(i)) = (\<Squnion> i \<in> A \<bullet> P(i)) \<turnstile> (\<Sqinter> i \<in> A \<bullet> Q(i))"
  using assms by rel_tac

lemma design_UINF: 
  "(\<Squnion> i \<in> A \<bullet> P(i) \<turnstile> Q(i)) = (\<Sqinter> i \<in> A \<bullet> P(i)) \<turnstile> (\<Squnion> i \<in> A \<bullet> P(i) \<Rightarrow> Q(i))"
  by rel_tac

theorem design_composition_subst:
  assumes 
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = 
         (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
proof -
  have "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> ((P1 \<turnstile> Q1)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>))"
    by (rule seqr_middle, simp)
  also have " ... 
        = (((P1 \<turnstile> Q1)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>false/$ok\<rbrakk>) 
            \<or> ((P1 \<turnstile> Q1)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: true_alt_def false_alt_def, pred_tac)
  also from assms
  have "... = ((($ok \<and> P1 \<Rightarrow> Q1\<lbrakk>true/$ok\<acute>\<rbrakk>) ;; (P2 \<Rightarrow> $ok\<acute> \<and> Q2\<lbrakk>true/$ok\<rbrakk>)) \<or> ((\<not> ($ok \<and> P1)) ;; true))"
    by (simp add: design_def usubst unrest, pred_tac)
  also have "... = ((\<not>$ok ;; true\<^sub>h) \<or> (\<not>P1 ;; true) \<or> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; \<not>P2) \<or> ($ok\<acute> \<and> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>)))"
    by (rel_tac)
  also have "... = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: precond_right_unit design_def unrest, rel_tac)
  finally show ?thesis .
qed 

lemma design_export_ok:
  "P \<turnstile> Q = (P \<turnstile> ($ok \<and> Q))"
  by (rel_tac)

lemma design_export_ok':
  "P \<turnstile> Q = (P \<turnstile> ($ok\<acute> \<and> Q))"
  by (rel_tac)

theorem design_composition:
  assumes 
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
  using assms by (simp add: design_composition_subst usubst)

lemma runrest_ident_var:
  assumes "x \<sharp>\<sharp> P"
  shows "($x \<and> P) = (P \<and> $x\<acute>)"
proof -
  have "P = ($x\<acute> =\<^sub>u $x \<and> P)"
    by (metis (no_types, lifting) RID_def assms conj_idem unrest_relation_def utp_pred.inf.left_commute)
  moreover have "($x\<acute> =\<^sub>u $x \<and> ($x \<and> P)) = ($x\<acute> =\<^sub>u $x \<and> (P \<and> $x\<acute>))"
    by (rel_tac)
  ultimately show ?thesis
    by (metis utp_pred.inf.assoc utp_pred.inf_left_commute)
qed

theorem design_composition_runrest:
  assumes 
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "ok \<sharp>\<sharp> Q1" "ok \<sharp>\<sharp> Q2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<^sup>t ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
proof -
  have "($ok \<and> $ok\<acute> \<and> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>)) = ($ok \<and> $ok\<acute> \<and> (Q1 ;; Q2))"
  proof -
    have "($ok \<and> $ok\<acute> \<and> (Q1 ;; Q2)) = ($ok \<and> Q1 ;; Q2 \<and> $ok\<acute>)"
      by (metis (no_types, hide_lams) seqr_post_out seqr_pre_out utp_pred.inf.commute utp_rel.unrest_iuvar utp_rel.unrest_ouvar uvar_ok vwb_lens_mwb) 
    also have "... = (Q1 \<and> $ok\<acute> ;; $ok \<and> Q2)"
      by (simp add: assms(3) assms(4) runrest_ident_var)
    also have "... = (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>)"
      by (metis seqr_left_one_point seqr_post_transfer true_alt_def uivar_convr upred_eq_true utp_pred.inf.cobounded2 utp_pred.inf.orderE utp_rel.unrest_iuvar uvar_ok vwb_lens_mwb)
    finally show ?thesis
      by (metis utp_pred.inf.left_commute utp_pred.inf_left_idem)
  qed
  moreover have "(\<not> (\<not> P1 ;; true) \<and> \<not> (Q1\<^sup>t ;; \<not> P2)) \<turnstile> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>) =
                 (\<not> (\<not> P1 ;; true) \<and> \<not> (Q1\<^sup>t ;; \<not> P2)) \<turnstile> ($ok \<and> $ok\<acute> \<and> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
    by (metis design_export_ok design_export_ok')   
  ultimately show ?thesis using assms
    by (simp add: design_composition_subst usubst, metis design_export_ok design_export_ok')
qed

theorem rdesign_composition:
  "((P1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (simp add: rdesign_def design_composition unrest alpha)

lemma skip_d_alt_def: "II\<^sub>D = true \<turnstile> II"
  by (rel_tac)

theorem design_skip_idem [simp]:
  "(II\<^sub>D ;; II\<^sub>D) = II\<^sub>D"
  by (simp add: skip_d_def urel_defs, pred_tac)

theorem design_composition_cond:
  assumes 
    "out\<alpha> \<sharp> p1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" 
  shows "((p1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
  using assms
  by (simp add: design_composition unrest precond_right_unit)

theorem rdesign_composition_cond:
  assumes "out\<alpha> \<sharp> p1"
  shows "((p1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  using assms
  by (simp add: rdesign_def design_composition_cond unrest alpha)

theorem design_composition_wp:
  fixes Q1 Q2 :: "'a hrelation_d"
  assumes 
    "ok \<sharp> p1" "ok \<sharp> p2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile> Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile> Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile> (Q1 ;; Q2))"
  using assms
  by (simp add: design_composition_cond unrest, rel_tac)

theorem rdesign_composition_wp:
  fixes Q1 Q2 :: "'a hrelation"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (simp add: rdesign_composition_cond unrest, rel_tac)

theorem rdesign_wp [wp]:
  "(\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q) wp\<^sub>D r = (p \<and> Q wp r)"
  by rel_tac

theorem wpd_seq_r:
  fixes Q1 Q2 :: "'\<alpha> hrelation"
  shows "(\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1 ;; \<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2) wp\<^sub>D r = (\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) wp\<^sub>D ((\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2) wp\<^sub>D r)"
  apply (simp add: wp)
  apply (subst rdesign_composition_wp)
  apply (simp only: wp)
  apply (rel_tac)
done

lemma design_subst_ok_ok':
  "(P\<lbrakk>true/$ok\<rbrakk> \<turnstile> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>) = (P \<turnstile> Q)"
proof -
  have "(P \<turnstile> Q) = (($ok \<and> P) \<turnstile> ($ok \<and> $ok\<acute> \<and> Q))"
    by (pred_tac)
  also have "... = (($ok \<and> P\<lbrakk>true/$ok\<rbrakk>) \<turnstile> ($ok \<and> ($ok\<acute> \<and> Q\<lbrakk>true/$ok\<acute>\<rbrakk>)\<lbrakk>true/$ok\<rbrakk>))"
    by (metis conj_eq_out_var_subst conj_pos_var_subst upred_eq_true utp_pred.inf_commute uvar_ok)
  also have "... = (($ok \<and> P\<lbrakk>true/$ok\<rbrakk>) \<turnstile> ($ok \<and> $ok\<acute> \<and> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>))"
    by (simp add: usubst)  
  also have "... = (P\<lbrakk>true/$ok\<rbrakk> \<turnstile> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>)"
    by (pred_tac)
  finally show ?thesis ..
qed

lemma design_subst_ok':
  "(P \<turnstile> Q\<lbrakk>true/$ok\<acute>\<rbrakk>) = (P \<turnstile> Q)"
proof -
  have "(P \<turnstile> Q) = (P \<turnstile> ($ok\<acute> \<and> Q))"
    by (pred_tac)
  also have "... = (P \<turnstile> ($ok\<acute> \<and> Q\<lbrakk>true/$ok\<acute>\<rbrakk>))"
    by (metis conj_eq_out_var_subst upred_eq_true utp_pred.inf_commute uvar_ok)
  also have "... = (P \<turnstile> Q\<lbrakk>true/$ok\<acute>\<rbrakk>)"
    by (pred_tac)
  finally show ?thesis ..
qed

theorem design_left_unit [simp]:
  "(II\<^sub>D ;; P \<turnstile>\<^sub>r Q) = (P \<turnstile>\<^sub>r Q)"
  by (simp add: skip_d_def urel_defs, pred_tac)

theorem design_right_cond_unit [simp]:
  assumes "out\<alpha> \<sharp> p"
  shows "(p \<turnstile>\<^sub>r Q ;; II\<^sub>D) = (p \<turnstile>\<^sub>r Q)"
  using assms
  by (simp add: skip_d_def rdesign_composition_cond)

lemma lift_des_skip_dr_unit [simp]:
  "(\<lceil>P\<rceil>\<^sub>D ;; \<lceil>II\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  "(\<lceil>II\<rceil>\<^sub>D ;; \<lceil>P\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  by rel_tac rel_tac

lemma assigns_d_id [simp]: "\<langle>id\<rangle>\<^sub>D = II\<^sub>D"
  by (rel_tac)

lemma assign_d_left_comp:
  "(\<langle>f\<rangle>\<^sub>D ;; (P \<turnstile>\<^sub>r Q)) = (\<lceil>f\<rceil>\<^sub>s \<dagger> P \<turnstile>\<^sub>r \<lceil>f\<rceil>\<^sub>s \<dagger> Q)"
  by (simp add: assigns_d_def rdesign_composition assigns_r_comp subst_not)

lemma assign_d_right_comp:
  "((P \<turnstile>\<^sub>r Q) ;; \<langle>f\<rangle>\<^sub>D) = ((\<not> (\<not> P ;; true)) \<turnstile>\<^sub>r (Q ;; \<langle>f\<rangle>\<^sub>a))"
  by (simp add: assigns_d_def rdesign_composition)

lemma assigns_d_comp: 
  "(\<langle>f\<rangle>\<^sub>D ;; \<langle>g\<rangle>\<^sub>D) = \<langle>g \<circ> f\<rangle>\<^sub>D" 
  using assms
  by (simp add: assigns_d_def rdesign_composition assigns_comp)

subsection {* Design preconditions *}

lemma design_pre_choice [simp]:
  "pre\<^sub>D(P \<sqinter> Q) = (pre\<^sub>D(P) \<and> pre\<^sub>D(Q))"
  by (rel_tac)

lemma design_post_choice [simp]:
  "post\<^sub>D(P \<sqinter> Q) = (post\<^sub>D(P) \<or> post\<^sub>D(Q))"
  by (rel_tac)

lemma design_pre_condr [simp]:
  "pre\<^sub>D(P \<triangleleft> \<lceil>b\<rceil>\<^sub>D \<triangleright> Q) = (pre\<^sub>D(P) \<triangleleft> b \<triangleright> pre\<^sub>D(Q))"
  by (rel_tac)

lemma design_post_condr [simp]:
  "post\<^sub>D(P \<triangleleft> \<lceil>b\<rceil>\<^sub>D \<triangleright> Q) = (post\<^sub>D(P) \<triangleleft> b \<triangleright> post\<^sub>D(Q))"
  by (rel_tac)

subsection {* H1: No observation is allowed before initiation *}

lemma H1_idem:
  "H1 (H1 P) = H1(P)"
  by pred_tac

lemma H1_monotone:
  "P \<sqsubseteq> Q \<Longrightarrow> H1(P) \<sqsubseteq> H1(Q)"
  by pred_tac

lemma H1_below_top:
  "H1(P) \<sqsubseteq> \<top>\<^sub>D"
  by pred_tac

lemma H1_design_skip:
  "H1(II) = II\<^sub>D"
  by rel_tac

text {* The H1 algebraic laws are valid only when $\alpha(R)$ is homogeneous. This should maybe be
        generalised. *}

theorem H1_algebraic_intro:
  assumes 
    "(true\<^sub>h ;; R) = true\<^sub>h" 
    "(II\<^sub>D ;; R) = R"
  shows "R is H1"
proof -
  have "R = (II\<^sub>D ;; R)" by (simp add: assms(2))
  also have "... = (H1(II) ;; R)"
    by (simp add: H1_design_skip)
  also have "... = (($ok \<Rightarrow> II) ;; R)"
    by (simp add: H1_def)
  also have "... = ((\<not> $ok ;; R) \<or> R)"
    by (simp add: impl_alt_def seqr_or_distl)
  also have "... = (((\<not> $ok ;; true\<^sub>h) ;; R) \<or> R)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok ;; true\<^sub>h) \<or> R)"
    by (metis assms(1) seqr_assoc)
  also have "... = ($ok \<Rightarrow> R)"
    by (simp add: impl_alt_def precond_right_unit unrest)
  finally show ?thesis by (metis H1_def Healthy_def')
qed

lemma nok_not_false:
  "(\<not> $ok) \<noteq> false"
  by (pred_tac, metis alpha_d.select_convs(1))

theorem H1_left_zero:
  assumes "P is H1"
  shows "(true ;; P) = true"
proof -
  from assms have "(true ;; P) = (true ;; ($ok \<Rightarrow> P))"
    by (simp add: H1_def Healthy_def')
  (* The next step ensures we get the right alphabet for true by copying it *)
  also from assms have "... = (true ;; (\<not> $ok \<or> P))" (is "_ = (?true ;; _)")
    by (simp add: impl_alt_def)
  also from assms have "... = ((?true ;; \<not> $ok) \<or> (?true ;; P))"
    using seqr_or_distr by blast
  also from assms have "... = (true \<or> (true ;; P))"
    by (simp add: nok_not_false precond_left_zero unrest)
  finally show ?thesis 
    by (rel_tac)
qed

theorem H1_left_unit:
  fixes P :: "'\<alpha> hrelation_d"
  assumes "P is H1"
  shows "(II\<^sub>D ;; P) = P"
proof -
  have "(II\<^sub>D ;; P) = (($ok \<Rightarrow> II) ;; P)"
    by (metis H1_def H1_design_skip)
  also have "... = ((\<not> $ok ;; P) \<or> P)"
    by (simp add: impl_alt_def seqr_or_distl)
  also from assms have "... = (((\<not> $ok ;; true\<^sub>h) ;; P) \<or> P)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok ;; (true\<^sub>h ;; P)) \<or> P)"
    by (simp add: seqr_assoc)
  also from assms have "... = ($ok \<Rightarrow> P)"
    by (simp add: H1_left_zero impl_alt_def precond_right_unit unrest)
  finally show ?thesis using assms
    by (simp add: H1_def Healthy_def')
qed

theorem H1_algebraic:
  "P is H1 \<longleftrightarrow> (true\<^sub>h ;; P) = true\<^sub>h \<and> (II\<^sub>D ;; P) = P"
  using H1_algebraic_intro H1_left_unit H1_left_zero by blast

theorem H1_nok_left_zero:
  fixes P :: "'\<alpha> hrelation_d"
  assumes "P is H1"
  shows "(\<not> $ok ;; P) = (\<not> $ok)"  
proof -
  have "(\<not> $ok ;; P) = ((\<not> $ok ;; true\<^sub>h) ;; P)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok) ;; true\<^sub>h)"
    by (metis H1_left_zero assms seqr_assoc)
  also have "... = (\<not> $ok)"
    by (simp add: precond_right_unit unrest)
  finally show ?thesis .
qed

lemma H1_design:
  "H1(P \<turnstile> Q) = (P \<turnstile> Q)"
  by (rel_tac)

lemma H1_rdesign:
  "H1(P \<turnstile>\<^sub>r Q) = (P \<turnstile>\<^sub>r Q)"
  by (rel_tac)

lemma H1_choice_closed:
  "\<lbrakk> P is H1; Q is H1 \<rbrakk> \<Longrightarrow> P \<sqinter> Q is H1"
  by (simp add: H1_def Healthy_def' disj_upred_def impl_alt_def semilattice_sup_class.sup_left_commute)

lemma H1_inf_closed:
  "\<lbrakk> P is H1; Q is H1 \<rbrakk> \<Longrightarrow> P \<squnion> Q is H1"
  by (rel_tac, blast+)
  
lemma H1_USUP:
  assumes "A \<noteq> {}"
  shows "H1(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> H1(P(i)))"
  using assms by (rel_tac)

lemma H1_Sup: 
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is H1"
  shows "(\<Sqinter> A) is H1"
proof -
  from assms(2) have "H1 ` A = A"
    by (auto simp add: Healthy_def rev_image_eqI)
  with H1_USUP[of A id, OF assms(1)] show ?thesis 
    by (simp add: USUP_as_Sup_image Healthy_def)
qed
  
lemma H1_UINF:
  shows "H1(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> H1(P(i)))"
  by (rel_tac)

lemma H1_Inf: 
  assumes "\<forall> P \<in> A. P is H1"
  shows "(\<Squnion> A) is H1"
proof -
  from assms have "H1 ` A = A"
    by (auto simp add: Healthy_def rev_image_eqI)
  with H1_UINF[of A id] show ?thesis 
    by (simp add: UINF_as_Inf_image Healthy_def)
qed

subsection {* H2: A specification cannot require non-termination *}

lemma J_split: 
  shows "(P ;; J) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
proof -
  have "(P ;; J) = (P ;; (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (simp add: H2_def J_def design_def)
  also have "... = (P ;; (($ok \<Rightarrow> $ok \<and> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by rel_tac
  also have "... = ((P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) \<or> (P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))))"
    by rel_tac
  also have "... = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  proof -
    have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = P\<^sup>f"
    proof -
      have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = ((P \<and> \<not> $ok\<acute>) ;; \<lceil>II\<rceil>\<^sub>D)"
        by rel_tac
      also have "... = (\<exists> $ok\<acute> \<bullet> P \<and> $ok\<acute> =\<^sub>u false)"
        by (rel_tac, metis (mono_tags, lifting) alpha_d.surjective alpha_d.update_convs(1))
      also have "... = P\<^sup>f"
        by (metis C1 one_point out_var_uvar pr_var_def unrest_as_exists uvar_ok vwb_lens_mwb)
     finally show ?thesis .
    qed
    moreover have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P\<^sup>t \<and> $ok\<acute>)"
    proof -
      have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P ;; ($ok \<and> II))"
        by (rel_tac, metis alpha_d.equality)
      also have "... = (P\<^sup>t \<and> $ok\<acute>)"
        by (rel_tac, metis (full_types) alpha_d.surjective alpha_d.update_convs(1))+
      finally show ?thesis .
    qed
    ultimately show ?thesis
      by simp
  qed 
  finally show ?thesis .
qed

lemma H2_split: 
  shows "H2(P) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  by (simp add: H2_def J_split)
 
theorem H2_equivalence:
  "P is H2 \<longleftrightarrow> `P\<^sup>f \<Rightarrow> P\<^sup>t`"
proof -
  have "`P \<Leftrightarrow> (P ;; J)` \<longleftrightarrow> `P \<Leftrightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))`"
    by (simp add: J_split)
  also from assms have "... \<longleftrightarrow> `(P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>f \<and> (P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>t`"
    by (simp add: subst_bool_split)
  also from assms have "... = `(P\<^sup>f \<Leftrightarrow> P\<^sup>f) \<and> (P\<^sup>t \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t)`"
    by subst_tac
  also have "... = `P\<^sup>t \<Leftrightarrow> (P\<^sup>f \<or> P\<^sup>t)`"
    by pred_tac
  also have "... = `(P\<^sup>f \<Rightarrow> P\<^sup>t)`"
    by pred_tac
  finally show ?thesis using assms
    by (metis H2_def Healthy_def' taut_iff_eq)
qed

lemma H2_equiv:
  "P is H2 \<longleftrightarrow> P\<^sup>t \<sqsubseteq> P\<^sup>f" 
  using H2_equivalence refBy_order by blast

lemma H2_design:
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q"
  shows "H2(P \<turnstile> Q) = P \<turnstile> Q"
  using assms
  by (simp add: H2_split design_def usubst unrest, pred_tac)

lemma H2_rdesign:
  "H2(P \<turnstile>\<^sub>r Q) = P \<turnstile>\<^sub>r Q"
  by (simp add: H2_design unrest rdesign_def)

theorem J_idem:
  "(J ;; J) = J"
  by (simp add: J_def urel_defs, pred_tac)

theorem H2_idem:
  "H2(H2(P)) = H2(P)"
  by (metis H2_def J_idem seqr_assoc)

theorem H2_not_okay: "H2 (\<not> $ok) = (\<not> $ok)"
proof -
  have "H2 (\<not> $ok) = ((\<not> $ok)\<^sup>f \<or> ((\<not> $ok)\<^sup>t \<and> $ok\<acute>))"
    by (simp add: H2_split)
  also have "... = (\<not> $ok \<or> (\<not> $ok) \<and> $ok\<acute>)"
    by (subst_tac)
  also have "... = (\<not> $ok)"
    by pred_tac
  finally show ?thesis .
qed

lemma H2_true: "H2(true) = true"
  by (rel_tac)

lemma H2_choice_closed:
  "\<lbrakk> P is H2; Q is H2 \<rbrakk> \<Longrightarrow> P \<sqinter> Q is H2"
  by (metis H2_def Healthy_def' disj_upred_def seqr_or_distl)

lemma H2_inf_closed:
  assumes "P is H2" "Q is H2"
  shows "P \<squnion> Q is H2"
proof -
  have "P \<squnion> Q = (P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>) \<squnion> (Q\<^sup>f \<or> Q\<^sup>t \<and> $ok\<acute>)"
    by (metis H2_def Healthy_def J_split assms(1) assms(2))
  moreover have "H2(...) = ..."
    by (simp add: H2_split usubst, pred_tac)
  ultimately show ?thesis
    by (simp add: Healthy_def)
qed

lemma H2_USUP:
  shows "H2(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> H2(P(i)))"
  using assms by (rel_tac)

theorem H1_H2_commute: 
  "H1 (H2 P) = H2 (H1 P)"
proof -
  have "H2 (H1 P) = (($ok \<Rightarrow> P) ;; J)"
    by (simp add: H1_def H2_def)
  also from assms have "... = ((\<not> $ok \<or> P) ;; J)"
    by rel_tac
  also have "... = ((\<not> $ok ;; J) \<or> (P ;; J))"
    using seqr_or_distl by blast
  also have "... =  ((H2 (\<not> $ok)) \<or> H2(P))"
    by (simp add: H2_def)
  also have "... =  ((\<not> $ok) \<or> H2(P))"
    by (simp add: H2_not_okay)
  also have "... = H1(H2(P))"
    by rel_tac
  finally show ?thesis by simp
qed

lemma ok_pre: "($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (\<not> P\<^sup>f))"
  by (pred_tac)
     (metis (mono_tags, lifting) alpha_d.surjective alpha_d.update_convs(1) alpha_d.update_convs(2))+

lemma ok_post: "($ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (P\<^sup>t))"
  by (pred_tac)
     (metis alpha_d.cases_scheme alpha_d.ext_inject alpha_d.select_convs(1) alpha_d.select_convs(2) alpha_d.update_convs(1) alpha_d.update_convs(2))+

theorem H1_H2_is_design:
  assumes "P is H1" "P is H2"
  shows "P = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
proof -
  from assms have "P = ($ok \<Rightarrow> H2(P))"
    by (simp add: H1_def Healthy_def')
  also have "... = ($ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>)))"
    by (metis H2_split)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> P\<^sup>t)"
    by pred_tac
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> $ok \<and> P\<^sup>t)"
    by pred_tac
  also have "... = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
    by pred_tac
  finally show ?thesis .
qed

lemma H1_H2_eq_design:
  "H1 (H2 P) = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
  apply (subst H1_H2_is_design)
  apply (simp_all add: Healthy_def H1_idem H2_idem H1_H2_commute)
  apply (simp add: H2_split H1_def usubst)
  apply (rel_tac)
done
  
theorem H1_H2_is_rdesign:
  assumes "P is H1" "P is H2"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
proof -
  from assms have "P = ($ok \<Rightarrow> H2(P))"
    by (simp add: H1_def Healthy_def')
  also have "... = ($ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>)))"
    by (metis H2_split)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> P\<^sup>t)"
    by pred_tac
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> $ok \<and> P\<^sup>t)"
    by pred_tac
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> $ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by (simp add: ok_post ok_pre)
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by pred_tac
  also from assms have "... =  pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
    by (simp add: rdesign_def design_def)
  finally show ?thesis .
qed

abbreviation "H1_H2 P \<equiv> H1 (H2 P)"

lemma design_is_H1_H2:
  "\<lbrakk> $ok\<acute> \<sharp> P; $ok\<acute> \<sharp> Q \<rbrakk> \<Longrightarrow> (P \<turnstile> Q) is H1_H2"
  by (simp add: H1_design H2_design Healthy_def')

lemma rdesign_is_H1_H2:
  "(P \<turnstile>\<^sub>r Q) is H1_H2"
  by (simp add: Healthy_def H1_rdesign H2_rdesign)

lemma seq_r_H1_H2_closed:
  assumes "P is H1_H2" "Q is H1_H2"
  shows "(P ;; Q) is H1_H2"
proof -
  obtain P\<^sub>1 P\<^sub>2 where "P = P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def assms(1))
  moreover obtain Q\<^sub>1 Q\<^sub>2 where "Q = Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2"
   by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def assms(2))
  moreover have "((P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2) ;; (Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2)) is H1_H2"
    by (simp add: rdesign_composition rdesign_is_H1_H2)
  ultimately show ?thesis by simp
qed

lemma assigns_d_comp_ext:
  fixes P :: "'\<alpha> hrelation_d"
  assumes "P is H1_H2"
  shows "(\<langle>\<sigma>\<rangle>\<^sub>D ;; P) = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P"
proof -
  have "(\<langle>\<sigma>\<rangle>\<^sub>D ;; P) = (\<langle>\<sigma>\<rangle>\<^sub>D ;; pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P))"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def' assms)
  also have "... = \<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> pre\<^sub>D(P) \<turnstile>\<^sub>r \<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> post\<^sub>D(P)"
    by (simp add: assign_d_left_comp)
  also have "... = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> (pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P))"
    by (rel_tac)
  also have "... = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def' assms)
  finally show ?thesis .
qed

lemma USUP_H1_H2_closed:
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is H1_H2"
  shows "(\<Sqinter> A) is H1_H2"
proof -
  from assms have A: "A = H1_H2 ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Sqinter> ...) = (\<Sqinter> P \<in> A. H1_H2(P))"
    by auto
  also have "... = (\<Sqinter> P \<in> A \<bullet> H1_H2(P))"
    by (simp add: USUP_as_Sup_collect)
  also have "... = (\<Sqinter> P \<in> A \<bullet> (\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
    by (meson H1_H2_eq_design)
  also have "... = (\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f) \<turnstile> (\<Sqinter> P \<in> A \<bullet> P\<^sup>t)"  
    by (simp add: design_USUP assms)
  also have "... is H1_H2"
    by (simp add: design_is_H1_H2 unrest)
  finally show ?thesis .
qed

definition design_sup :: "('\<alpha>, '\<beta>) relation_d set \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("\<Sqinter>\<^sub>D_" [900] 900) where
"\<Sqinter>\<^sub>D A = (if (A = {}) then \<top>\<^sub>D else \<Sqinter> A)"

lemma design_sup_H1_H2_closed:
  assumes "\<forall> P \<in> A. P is H1_H2"
  shows "(\<Sqinter>\<^sub>D A) is H1_H2"
  apply (auto simp add: design_sup_def)
  apply (simp add: H1_def H2_not_okay Healthy_def impl_alt_def)
  using USUP_H1_H2_closed assms apply blast
done

lemma design_sup_empty [simp]: "\<Sqinter>\<^sub>D {} = \<top>\<^sub>D"
  by (simp add: design_sup_def)

lemma design_sup_non_empty [simp]: "A \<noteq> {} \<Longrightarrow> \<Sqinter>\<^sub>D A = \<Sqinter> A"
  by (simp add: design_sup_def)

lemma UINF_H1_H2_closed:
  assumes "\<forall> P \<in> A. P is H1_H2"
  shows "(\<Squnion> A) is H1_H2"
proof -
  from assms have A: "A = H1_H2 ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Squnion> ...) = (\<Squnion> P \<in> A. H1_H2(P))"
    by auto
  also have "... = (\<Squnion> P \<in> A \<bullet> H1_H2(P))"
    by (simp add: UINF_as_Inf_collect)
  also have "... = (\<Squnion> P \<in> A \<bullet> (\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
    by (meson H1_H2_eq_design)
  also have "... = (\<Sqinter> P \<in> A \<bullet> \<not> P\<^sup>f) \<turnstile> (\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f \<Rightarrow> P\<^sup>t)"
    by (simp add: design_UINF)
  also have "... is H1_H2"
    by (simp add: design_is_H1_H2 unrest)
  finally show ?thesis .
qed

abbreviation design_inf :: "('\<alpha>, '\<beta>) relation_d set \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("\<Squnion>\<^sub>D_" [900] 900) where
"\<Squnion>\<^sub>D A \<equiv> \<Squnion> A"

subsection {* H3: The design assumption is a precondition *}

theorem H3_idem:
  "H3(H3(P)) = H3(P)"
  by (metis H3_def design_skip_idem seqr_assoc)

theorem design_condition_is_H3:
  assumes "out\<alpha> \<sharp> p"
  shows "(p \<turnstile> Q) is H3"
proof -
  have "((p \<turnstile> Q) ;; II\<^sub>D) = (\<not> (\<not> p ;; true)) \<turnstile> (Q\<^sup>t ;; II\<lbrakk>true/$ok\<rbrakk>)"
    by (simp add: skip_d_alt_def design_composition_subst unrest assms)
  also have "... = p \<turnstile> (Q\<^sup>t ;; II\<lbrakk>true/$ok\<rbrakk>)"
    using assms precond_equiv seqr_true_lemma by force
  also have "... = p \<turnstile> Q"
    by (rel_tac, metis (full_types) alpha_d.cases_scheme alpha_d.select_convs(1) alpha_d.update_convs(1))
  finally show ?thesis
    by (simp add: H3_def Healthy_def')
qed

theorem rdesign_H3_iff_pre: 
  "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "(P \<turnstile>\<^sub>r Q ;; II\<^sub>D) = (P \<turnstile>\<^sub>r Q ;; true \<turnstile>\<^sub>r II)"
    by (simp add: skip_d_def)
  also from assms have "... = (\<not> (\<not> P ;; true) \<and> \<not> (Q ;; \<not> true)) \<turnstile>\<^sub>r (Q ;; II)"
    by (simp add: rdesign_composition)
  also from assms have "... = (\<not> (\<not> P ;; true) \<and> \<not> (Q ;; \<not> true)) \<turnstile>\<^sub>r Q"
    by simp
  also have "... = (\<not> (\<not> P ;; true)) \<turnstile>\<^sub>r Q"
    by pred_tac
  finally have "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P \<turnstile>\<^sub>r Q = (\<not> (\<not> P ;; true)) \<turnstile>\<^sub>r Q"
    by (metis H3_def Healthy_def')
  also have "... \<longleftrightarrow> P = (\<not> (\<not> P ;; true))"
    by (metis rdesign_pre)
  also have "... \<longleftrightarrow> P = (P ;; true)"
    by (simp add: seqr_true_lemma)
  finally show ?thesis .
qed

theorem design_H3_iff_pre: 
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "P \<turnstile> Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "P \<turnstile> Q = \<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D"
    by (simp add: assms lift_desr_inv rdesign_def)
  moreover hence "\<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D is H3 \<longleftrightarrow> \<lfloor>P\<rfloor>\<^sub>D = (\<lfloor>P\<rfloor>\<^sub>D ;; true)"
    using rdesign_H3_iff_pre by blast
  ultimately show ?thesis
    by (metis assms drop_desr_inv lift_desr_inv lift_dist_seq aext_true)
qed

theorem H1_H3_commute:
  "H1 (H3 P) = H3 (H1 P)"
  by rel_tac

lemma skip_d_absorb_J_1:
  "(II\<^sub>D ;; J) = II\<^sub>D"
  by (metis H2_def H2_rdesign skip_d_def)

lemma skip_d_absorb_J_2:
  "(J ;; II\<^sub>D) = II\<^sub>D"
proof -
  have "(J ;; II\<^sub>D) = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D ;; true \<turnstile> II)"
    by (simp add: J_def skip_d_alt_def)
  also have "... = (\<^bold>\<exists> ok\<^sub>0 \<bullet> (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = (((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>false/$ok\<rbrakk>)
                  \<or> ((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D ;; true) \<or> (\<lceil>II\<rceil>\<^sub>D ;; $ok\<acute> \<and> \<lceil>II\<rceil>\<^sub>D))"
    by rel_tac
  also have "... = II\<^sub>D"
    by rel_tac
  finally show ?thesis .
qed

lemma H2_H3_absorb:
  "H2 (H3 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_1)

lemma H3_H2_absorb:
  "H3 (H2 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_2)

theorem H2_H3_commute:
  "H2 (H3 P) = H3 (H2 P)"
  by (simp add: H2_H3_absorb H3_H2_absorb)

theorem H3_design_pre:
  assumes "$ok \<sharp> p" "out\<alpha> \<sharp> p" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "H3(p \<turnstile> Q) = p \<turnstile> Q"
  using assms
  by (metis Healthy_def' design_H3_iff_pre precond_right_unit unrest_out\<alpha>_var uvar_ok vwb_lens_mwb) 

theorem H3_rdesign_pre:
  assumes "out\<alpha> \<sharp> p"
  shows "H3(p \<turnstile>\<^sub>r Q) = p \<turnstile>\<^sub>r Q"
  using assms
  by (simp add: H3_def)

theorem H1_H3_is_design:
  assumes "P is H1" "P is H3"
  shows "P = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
  by (metis H1_H2_eq_design H2_H3_absorb Healthy_def' assms(1) assms(2))

theorem H1_H3_is_rdesign:
  assumes "P is H1" "P is H3"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
  by (metis H1_H2_is_rdesign H2_H3_absorb Healthy_def' assms)

theorem H1_H3_is_normal_design:
  assumes "P is H1" "P is H3"
  shows "P = \<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)"
  by (metis H1_H3_is_rdesign assms drop_pre_inv ndesign_def precond_equiv rdesign_H3_iff_pre)

abbreviation "H1_H3 p \<equiv> H1 (H3 p)"

lemma H1_H3_impl_H2: "P is H1_H3 \<Longrightarrow> P is H1_H2"
  by (metis H1_H2_commute H1_idem H2_H3_absorb Healthy_def')

lemma H1_H3_eq_design_d_comp: "H1 (H3 P) = ((\<not> P\<^sup>f) \<turnstile> P\<^sup>t ;; II\<^sub>D)"
  by (metis H1_H2_eq_design H1_H3_commute H3_H2_absorb H3_def)

lemma H1_H3_eq_design: "H1 (H3 P) = (\<not> (P\<^sup>f ;; true)) \<turnstile> P\<^sup>t"
  apply (simp add: H1_H3_eq_design_d_comp skip_d_alt_def)
  apply (subst design_composition_subst)
  apply (simp_all add: usubst unrest)
  apply (rel_tac)
done

lemma H3_unrest_out_alpha_nok [unrest]: 
  assumes "P is H1_H3"
  shows "out\<alpha> \<sharp> P\<^sup>f"
proof -
  have "P = (\<not> (P\<^sup>f ;; true)) \<turnstile> P\<^sup>t"
    by (metis H1_H3_eq_design Healthy_def assms)
  also have "out\<alpha> \<sharp> (...\<^sup>f)"
    by (simp add: design_def usubst unrest, rel_tac)
  finally show ?thesis .
qed
 
lemma H3_unrest_out_alpha [unrest]: "P is H1_H3 \<Longrightarrow> out\<alpha> \<sharp> pre\<^sub>D(P)"
  by (metis H1_H3_commute H1_H3_is_rdesign H1_idem Healthy_def' precond_equiv rdesign_H3_iff_pre)

theorem wpd_seq_r_H1_H2 [wp]:
  fixes P Q :: "'\<alpha> hrelation_d"
  assumes "P is H1_H3" "Q is H1_H3"
  shows "(P ;; Q) wp\<^sub>D r = P wp\<^sub>D (Q wp\<^sub>D r)"
  by (smt H1_H3_commute H1_H3_is_rdesign H1_idem Healthy_def' assms(1) assms(2) drop_pre_inv precond_equiv rdesign_H3_iff_pre wpd_seq_r)

subsection {* H4: Feasibility *}

theorem H4_idem:
  "H4(H4(P)) = H4(P)"
  by pred_tac

lemma is_H4_alt_def:
  "P is H4 \<longleftrightarrow> (P ;; true) = true"
  by (rel_tac)

lemma H4_assigns_d: "\<langle>\<sigma>\<rangle>\<^sub>D is H4"
proof -
  have "(\<langle>\<sigma>\<rangle>\<^sub>D ;; (false \<turnstile>\<^sub>r true\<^sub>h)) = (false \<turnstile>\<^sub>r true)"
    by (simp add: assigns_d_def rdesign_composition assigns_r_feasible)
  moreover have "... = true"
    by (rel_tac)
  ultimately show ?thesis
    using is_H4_alt_def by auto
qed

subsection {* UTP theories *}

typedef DES  = "UNIV :: unit set" by simp
typedef NDES = "UNIV :: unit set" by simp

abbreviation "DES \<equiv> TYPE(DES \<times> '\<alpha> alphabet_d)"
abbreviation "NDES \<equiv> TYPE(NDES \<times> '\<alpha> alphabet_d)"

overloading
  des_hcond == "utp_hcond :: (DES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> ('\<alpha> alphabet_d \<times> '\<alpha> alphabet_d) Healthiness_condition"
  des_unit == "utp_unit :: (DES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> '\<alpha> hrelation_d"

  ndes_hcond == "utp_hcond :: (NDES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> ('\<alpha> alphabet_d \<times> '\<alpha> alphabet_d) Healthiness_condition"
  ndes_unit == "utp_unit :: (NDES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> '\<alpha> hrelation_d"

begin
  definition des_hcond :: "(DES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> ('\<alpha> alphabet_d \<times> '\<alpha> alphabet_d) Healthiness_condition" where
  "des_hcond t = H1_H2"  

  definition des_unit :: "(DES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> '\<alpha> hrelation_d" where
  "des_unit t = II\<^sub>D"

  definition ndes_hcond :: "(NDES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> ('\<alpha> alphabet_d \<times> '\<alpha> alphabet_d) Healthiness_condition" where
  "ndes_hcond t = H1_H3"  

  definition ndes_unit :: "(NDES \<times> '\<alpha> alphabet_d) itself \<Rightarrow> '\<alpha> hrelation_d" where
  "ndes_unit t = II\<^sub>D"

end

interpretation des_utp_theory: utp_theory "TYPE(DES \<times> '\<alpha> alphabet_d)"
  by (simp add: H1_H2_commute H1_idem H2_idem des_hcond_def utp_theory_def)

interpretation ndes_utp_theory: utp_theory "TYPE(NDES \<times> '\<alpha> alphabet_d)"
  by (simp add: H1_H3_commute H1_idem H3_idem ndes_hcond_def utp_theory.intro)

interpretation des_left_unital: utp_theory_left_unital "TYPE(DES \<times> '\<alpha> alphabet_d)"
  apply (unfold_locales)
  apply (simp_all add: des_hcond_def des_unit_def)
  apply (simp add: rdesign_is_H1_H2 skip_d_def)
  apply (metis H1_idem H1_left_unit Healthy_def')
done

interpretation ndes_unital: utp_theory_unital "TYPE(NDES \<times> ('\<alpha> alphabet_d))"
  apply (unfold_locales, simp_all add: ndes_hcond_def ndes_unit_def)
  apply (metis H1_rdesign H3_def Healthy_def' design_skip_idem skip_d_def)
  apply (metis H1_idem H1_left_unit Healthy_def')
  apply (metis H1_H3_commute H3_def H3_idem Healthy_def')
done

interpretation design_complete_lattice: utp_theory_lattice "TYPE(DES \<times> '\<alpha> alphabet_d)"
  rewrites "carrier (utp_order DES) = \<lbrakk>H1_H2\<rbrakk>"
  apply (unfold_locales)
  apply (simp_all add: des_hcond_def utp_order_def H1_idem H2_idem)
  apply (rule_tac x="\<Squnion>\<^sub>D A" in exI)
  apply (auto simp add: least_def Upper_def)
  using Inf_lower apply blast
  apply (simp add: Ball_Collect UINF_H1_H2_closed)
  apply (meson Ball_Collect Inf_greatest)
  apply (rule_tac x="\<Sqinter>\<^sub>D A" in exI)
  apply (case_tac "A = {}")
  apply (auto simp add: greatest_def Lower_def)
  using design_sup_H1_H2_closed apply fastforce
  apply (metis H1_below_top Healthy_def')
  using Sup_upper apply blast
  apply (metis (no_types) USUP_H1_H2_closed contra_subsetD emptyE mem_Collect_eq)
  apply (meson Ball_Collect Sup_least)
done

abbreviation design_lfp :: "_ \<Rightarrow> _" ("\<mu>\<^sub>D") where
"\<mu>\<^sub>D F \<equiv> \<mu>\<^bsub>utp_order DES\<^esub> F"

abbreviation design_gfp :: "_ \<Rightarrow> _" ("\<nu>\<^sub>D") where
"\<nu>\<^sub>D F \<equiv> \<nu>\<^bsub>utp_order DES\<^esub> F"

end