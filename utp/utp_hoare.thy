subsection {* Relational Hoare calculus *}

theory utp_hoare
imports utp_rel_laws
begin

named_theorems hoare and hoare_safe

method hoare_split uses hr = 
  ((simp add: assigns_r_comp usubst unrest)?, -- {* Eliminate assignments where possible *}
   (auto 
    intro: hoare intro!: hoare_safe hr
    simp add: assigns_r_comp conj_comm conj_assoc usubst unrest))[1] -- {* Apply Hoare logic laws *}

method hoare_auto uses hr = (hoare_split hr: hr; rel_auto?)
  
definition hoare_r :: "'\<alpha> cond \<Rightarrow> '\<alpha> hrel \<Rightarrow> '\<alpha> cond \<Rightarrow> bool" ("\<lbrace>_\<rbrace>/ _/ \<lbrace>_\<rbrace>\<^sub>u") where
"\<lbrace>p\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u = ((\<lceil>p\<rceil>\<^sub>< \<Rightarrow> \<lceil>r\<rceil>\<^sub>>) \<sqsubseteq> Q)"

declare hoare_r_def [upred_defs]

lemma hoare_r_conj [hoare_safe]: "\<lbrakk> \<lbrace>p\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u; \<lbrace>p\<rbrace>Q\<lbrace>s\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>Q\<lbrace>r \<and> s\<rbrace>\<^sub>u"
  by rel_auto

lemma hoare_r_weaken_pre [hoare]:
  "\<lbrace>p\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u \<Longrightarrow> \<lbrace>p \<and> q\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u"
  "\<lbrace>q\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u \<Longrightarrow> \<lbrace>p \<and> q\<rbrace>Q\<lbrace>r\<rbrace>\<^sub>u"
  by rel_auto+
 
lemma hoare_r_conseq: "\<lbrakk> `p\<^sub>1 \<Rightarrow> p\<^sub>2`; \<lbrace>p\<^sub>2\<rbrace>S\<lbrace>q\<^sub>2\<rbrace>\<^sub>u; `q\<^sub>2 \<Rightarrow> q\<^sub>1` \<rbrakk> \<Longrightarrow> \<lbrace>p\<^sub>1\<rbrace>S\<lbrace>q\<^sub>1\<rbrace>\<^sub>u"
  by rel_auto

lemma assigns_hoare_r [hoare_safe]: "`p \<Rightarrow> \<sigma> \<dagger> q` \<Longrightarrow> \<lbrace>p\<rbrace>\<langle>\<sigma>\<rangle>\<^sub>a\<lbrace>q\<rbrace>\<^sub>u"
  by rel_auto

lemma skip_hoare_r [hoare_safe]: "\<lbrace>p\<rbrace>II\<lbrace>p\<rbrace>\<^sub>u"
  by rel_auto

lemma seq_hoare_r: "\<lbrakk> \<lbrace>p\<rbrace>Q\<^sub>1\<lbrace>s\<rbrace>\<^sub>u ; \<lbrace>s\<rbrace>Q\<^sub>2\<lbrace>r\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>r\<rbrace>\<^sub>u"
  by rel_auto

lemma seq_hoare_invariant [hoare_safe]: "\<lbrakk> \<lbrace>p\<rbrace>Q\<^sub>1\<lbrace>p\<rbrace>\<^sub>u ; \<lbrace>p\<rbrace>Q\<^sub>2\<lbrace>p\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>p\<rbrace>\<^sub>u"
  by rel_auto

lemma seq_hoare_stronger_pre_1 [hoare_safe]: 
  "\<lbrakk> \<lbrace>p \<and> q\<rbrace>Q\<^sub>1\<lbrace>p \<and> q\<rbrace>\<^sub>u ; \<lbrace>p \<and> q\<rbrace>Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p \<and> q\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u"
  by rel_auto

lemma seq_hoare_stronger_pre_2 [hoare_safe]: 
  "\<lbrakk> \<lbrace>p \<and> q\<rbrace>Q\<^sub>1\<lbrace>p \<and> q\<rbrace>\<^sub>u ; \<lbrace>p \<and> q\<rbrace>Q\<^sub>2\<lbrace>p\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p \<and> q\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>p\<rbrace>\<^sub>u"
  by rel_auto
    
lemma seq_hoare_inv_r_2 [hoare]: "\<lbrakk> \<lbrace>p\<rbrace>Q\<^sub>1\<lbrace>q\<rbrace>\<^sub>u ; \<lbrace>q\<rbrace>Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u"
  by rel_auto

lemma seq_hoare_inv_r_3 [hoare]: "\<lbrakk> \<lbrace>p\<rbrace>Q\<^sub>1\<lbrace>p\<rbrace>\<^sub>u ; \<lbrace>p\<rbrace>Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>Q\<^sub>1 ;; Q\<^sub>2\<lbrace>q\<rbrace>\<^sub>u"
  by rel_auto

lemma cond_hoare_r [hoare_safe]: "\<lbrakk> \<lbrace>b \<and> p\<rbrace>S\<lbrace>q\<rbrace>\<^sub>u ; \<lbrace>\<not>b \<and> p\<rbrace>T\<lbrace>q\<rbrace>\<^sub>u \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>S \<triangleleft> b \<triangleright>\<^sub>r T\<lbrace>q\<rbrace>\<^sub>u"
  by rel_auto

text {* Frame rule: If starting $S$ in a state satisfying $p establishes q$ in the final state, then
  we can insert an invariant predicate $r$ when $S$ is framed by $a$, provided that $r$ does not
  refer to variables in the frame, and $q$ does not refer to variables outside the frame. *}
    
lemma frame_hoare_r [hoare_safe]: 
  assumes "vwb_lens a" "a \<sharp> r" "a \<natural> q" "\<lbrace>p \<and> r\<rbrace>S\<lbrace>q\<rbrace>\<^sub>u"
  shows "\<lbrace>p \<and> r\<rbrace>a:[S]\<lbrace>q \<and> r\<rbrace>\<^sub>u"
  using assms by (rel_simp)

lemma frame_hoare_r' [hoare_safe]: 
  assumes "vwb_lens a" "a \<sharp> r" "a \<natural> q" "\<lbrace>r \<and> p\<rbrace>S\<lbrace>q\<rbrace>\<^sub>u"
  shows "\<lbrace>r \<and> p\<rbrace>a:[S]\<lbrace>r \<and> q\<rbrace>\<^sub>u"
  using assms
  by (simp add: frame_hoare_r utp_pred_laws.inf.commute)
    
lemma while_hoare_r [hoare_safe]:
  assumes "\<lbrace>p \<and> b\<rbrace>S\<lbrace>p\<rbrace>\<^sub>u"
  shows "\<lbrace>p\<rbrace>while b do S od\<lbrace>\<not>b \<and> p\<rbrace>\<^sub>u"
  using assms
  by (simp add: while_def hoare_r_def, rule_tac lfp_lowerbound) (rel_auto)

lemma while_invr_hoare_r [hoare_safe]:
  assumes "\<lbrace>p \<and> b\<rbrace>S\<lbrace>p\<rbrace>\<^sub>u" "`pre \<Rightarrow> p`" "`(\<not>b \<and> p) \<Rightarrow> post`"
  shows "\<lbrace>pre\<rbrace>while b invr p do S od\<lbrace>post\<rbrace>\<^sub>u"
  by (metis assms hoare_r_conseq while_hoare_r while_inv_def)

lemma approx_chain: 
  "(\<Sqinter>n::nat. \<lceil>p \<and> v <\<^sub>u \<guillemotleft>n\<guillemotright>\<rceil>\<^sub><) = \<lceil>p\<rceil>\<^sub><"
  by (rel_auto)

text {* Total correctness law for Hoare logic *}
    
lemma while_term_hoare_r:
  assumes "\<And> z::nat. \<lbrace>p \<and> b \<and> v =\<^sub>u \<guillemotleft>z\<guillemotright>\<rbrace>S\<lbrace>p \<and> v <\<^sub>u \<guillemotleft>z\<guillemotright>\<rbrace>\<^sub>u"
  shows "\<lbrace>p\<rbrace>while\<^sub>\<bottom> b do S od\<lbrace>\<not>b \<and> p\<rbrace>\<^sub>u"
proof -
  have "(\<lceil>p\<rceil>\<^sub>< \<Rightarrow> \<lceil>\<not> b \<and> p\<rceil>\<^sub>>) \<sqsubseteq> (\<mu> X \<bullet> S ;; X \<triangleleft> b \<triangleright>\<^sub>r II)"
  proof (rule mu_refine_intro)

    from assms show "(\<lceil>p\<rceil>\<^sub>< \<Rightarrow> \<lceil>\<not> b \<and> p\<rceil>\<^sub>>) \<sqsubseteq> S ;; (\<lceil>p\<rceil>\<^sub>< \<Rightarrow> \<lceil>\<not> b \<and> p\<rceil>\<^sub>>) \<triangleleft> b \<triangleright>\<^sub>r II"
      by (rel_auto)

    let ?E = "\<lambda> n. \<lceil>p \<and> v <\<^sub>u \<guillemotleft>n\<guillemotright>\<rceil>\<^sub><"
    show "(\<lceil>p\<rceil>\<^sub>< \<and> (\<mu> X \<bullet> S ;; X \<triangleleft> b \<triangleright>\<^sub>r II)) = (\<lceil>p\<rceil>\<^sub>< \<and> (\<nu> X \<bullet> S ;; X \<triangleleft> b \<triangleright>\<^sub>r II))"
    proof (rule constr_fp_uniq[where E="?E"])

      show "(\<Sqinter>n. ?E(n)) = \<lceil>p\<rceil>\<^sub><"
        by (rel_auto)
          
      show "mono (\<lambda>X. S ;; X \<triangleleft> b \<triangleright>\<^sub>r II)"
        by (simp add: cond_mono monoI seqr_mono)
          
      show "constr (\<lambda>X. S ;; X \<triangleleft> b \<triangleright>\<^sub>r II) ?E"
      proof (rule constrI)
        
        show "chain ?E"
        proof (rule chainI)
          show "\<lceil>p \<and> v <\<^sub>u \<guillemotleft>0\<guillemotright>\<rceil>\<^sub>< = false"
            by (rel_auto)
          show "\<And>i. \<lceil>p \<and> v <\<^sub>u \<guillemotleft>Suc i\<guillemotright>\<rceil>\<^sub>< \<sqsubseteq> \<lceil>p \<and> v <\<^sub>u \<guillemotleft>i\<guillemotright>\<rceil>\<^sub><"
            by (rel_auto)
        qed
          
        from assms
        show "\<And>X n. (S ;; X \<triangleleft> b \<triangleright>\<^sub>r II \<and> \<lceil>p \<and> v <\<^sub>u \<guillemotleft>n + 1\<guillemotright>\<rceil>\<^sub><) =
                     (S ;; (X \<and> \<lceil>p \<and> v <\<^sub>u \<guillemotleft>n\<guillemotright>\<rceil>\<^sub><) \<triangleleft> b \<triangleright>\<^sub>r II \<and> \<lceil>p \<and> v <\<^sub>u \<guillemotleft>n + 1\<guillemotright>\<rceil>\<^sub><)"
          apply (rel_auto)
          using less_antisym less_trans apply blast
        done
      qed  
    qed
  qed

  thus ?thesis
    by (simp add: hoare_r_def while_bot_def)
qed

lemma while_vrt_hoare_r [hoare_safe]:
  assumes "\<And> z::nat. \<lbrace>p \<and> b \<and> v =\<^sub>u \<guillemotleft>z\<guillemotright>\<rbrace>S\<lbrace>p \<and> v <\<^sub>u \<guillemotleft>z\<guillemotright>\<rbrace>\<^sub>u" "`pre \<Rightarrow> p`" "`(\<not>b \<and> p) \<Rightarrow> post`"
  shows "\<lbrace>pre\<rbrace>while b invr p vrt v do S od\<lbrace>post\<rbrace>\<^sub>u"
  apply (rule hoare_r_conseq[OF assms(2) _ assms(3)])
  apply (simp add: while_vrt_def)
  apply (rule while_term_hoare_r[where v="v", OF assms(1)]) 
done
  
end