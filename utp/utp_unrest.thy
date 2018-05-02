section {* Unrestriction *}

theory utp_unrest
  imports utp_expr
begin

subsection {* Definitions and Core Syntax *}
  
text {* Unrestriction is an encoding of semantic freshness that allows us to reason about the
  presence of variables in predicates without being concerned with abstract syntax trees.
  An expression $p$ is unrestricted by lens $x$, written $x \mathop{\sharp} p$, if
  altering the value of $x$ has no effect on the valuation of $p$. This is a sufficient
  notion to prove many laws that would ordinarily rely on an \emph{fv} function. 

  Unrestriction was first defined in the work of Marcel Oliveira~\cite{Oliveira2005-PHD,Oliveira07} in his
  UTP mechanisation in \emph{ProofPowerZ}. Our definition modifies his in that our variables
  are semantically characterised as lenses, and supported by the lens laws, rather than named 
  syntactic entities. We effectively fuse the ideas from both Feliachi~\cite{Feliachi2010} and 
  Oliveira's~\cite{Oliveira07} mechanisations of the UTP, the former being also purely semantic
  in nature.

  We first set up overloaded syntax for unrestriction, as several concepts will have this
  defined. *}

consts
  unrest :: "'a \<Rightarrow> 'b \<Rightarrow> bool"

syntax
  "_unrest" :: "salpha \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<sharp>" 20)
  
translations
  "_unrest x p" == "CONST unrest x p"                                           
  "_unrest (_salphamk_set (x \<squnion>\<^sub>S y)) P"  <= "_unrest (x \<squnion>\<^sub>S y) P"
  "_unrest x p" <= "_unrest \<lbrakk>x\<rbrakk>\<^sub>\<sim> p"

text {* Our syntax translations support both variables and variable sets such that we can write down 
  predicates like @{term "&x \<sharp> P"} and also @{term "{&x,&y,&z} \<sharp> P"}. 

  We set up a simple tactic for discharging unrestriction conjectures using a simplification set. *}
  
named_theorems unrest
method unrest_tac = (simp add: unrest)?

text {* Unrestriction for expressions is defined as a lifted construct using the underlying lens
  operations. It states that lens $x$ is unrestricted by expression $e$ provided that, for any
  state-space binding $b$ and variable valuation $v$, the value which the expression evaluates
  to is unaltered if we set $x$ to $v$ in $b$. In other words, we cannot effect the behaviour
  of $e$ by changing $x$. Thus $e$ does not observe the portion of state-space characterised
  by $x$. We add this definition to our overloaded constant. *}

lift_definition unrest_uexpr :: "'\<alpha> scene \<Rightarrow> ('b, '\<alpha>) uexpr \<Rightarrow> bool"
is "\<lambda> x e. \<forall> b b'. e (b \<oplus>\<^sub>S b' on x) = e b" .

adhoc_overloading
  unrest unrest_uexpr

subsection {* Unrestriction laws *}
  
text {* We now prove unrestriction laws for the key constructs of our expression model. Many
  of these depend on lens properties and so variously employ the assumptions @{term mwb_lens} and
  @{term vwb_lens}, depending on the number of assumptions from the lenses theory is required.

  Firstly, we prove a general property -- if $x$ and $y$ are both unrestricted in $P$, then their composition
  is also unrestricted in $P$. One can interpret the composition here as a union -- if the two sets
  of variables $x$ and $y$ are unrestricted, then so is their union. *}

lemma unrest_var_comp [unrest]:
  "\<lbrakk> a \<sharp> P; b \<sharp> P \<rbrakk> \<Longrightarrow> a\<union>b \<sharp> P"
  apply (case_tac "a ##\<^sub>S b")
  apply (transfer, simp add: scene_override_union)
  apply (transfer, simp add: scene_union_incompat)
  done

text {* No lens is restricted by a literal, since it returns the same value for any state binding. *}
    
lemma unrest_lit [unrest]: "a \<sharp> \<guillemotleft>v\<guillemotright>"
  by (transfer, simp)

text {* If one scene is smaller than another, then any unrestriction on the larger scene implies
  unrestriction on the smaller. *}
    
lemma unrest_subscene:
  fixes P :: "('a, '\<alpha>) uexpr"
  assumes "idem_scene a" "a \<sharp> P" "b \<le> a"
  shows "b \<sharp> P" 
  using assms unfolding less_eq_scene_def
  by (transfer, metis scene_override_idem)
    
text \<open> If an expression is unrestricted by all variables, then it is unrestricted by any variable \<close>

lemma unrest_all_var:
  fixes e :: "('a, '\<alpha>) uexpr"
  assumes "\<Sigma> \<sharp> e"
  shows "x \<sharp> e"
  by (metis assms scene_override_id unrest_uexpr.rep_eq)
  
text \<open> We can split an unrestriction composed by lens plus \<close>

lemma unrest_plus_split:
  fixes P :: "('a, '\<alpha>) uexpr"
  assumes "a ##\<^sub>S b"
  shows "(a \<union> b \<sharp> P) \<longleftrightarrow> (a \<sharp> P) \<and> (b \<sharp> P)"
  using assms
  by (transfer, simp, metis scene_compat.rep_eq scene_override.rep_eq scene_override_overshadow_left scene_override_union)

text {* The following laws demonstrate the primary motivation for lens independence: a variable
  expression is unrestricted by another variable only when the two variables are independent. 
  Lens independence thus effectively allows us to semantically characterise when two variables,
  or sets of variables, are different. *}

lemma unrest_var [unrest]: "\<lbrakk> mwb_lens x; x \<notin>\<^sub>S a \<rbrakk> \<Longrightarrow> a \<sharp> var x"
  by (transfer, simp)
    
lemma unrest_iuvar [unrest]: "\<lbrakk> mwb_lens x; x \<bowtie> y \<rbrakk> \<Longrightarrow> $y \<sharp> $x"
  by (simp add: unrest_var)

lemma unrest_ouvar [unrest]: "\<lbrakk> mwb_lens x; x \<bowtie> y \<rbrakk> \<Longrightarrow> $y\<acute> \<sharp> $x\<acute>"
  by (simp add: unrest_var)

text {* The following laws follow automatically from independence of input and output variables. *}
    
lemma unrest_iuvar_ouvar [unrest]:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  assumes "mwb_lens y"
  shows "$x \<sharp> $y\<acute>"
  by (simp add: assms unrest_var)
  
lemma unrest_ouvar_iuvar [unrest]:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  assumes "mwb_lens y"
  shows "$x\<acute> \<sharp> $y"
  by (simp add: assms unrest_var)

text {* Unrestriction distributes through the various function lifting expression constructs;
  this allows us to prove unrestrictions for the majority of the expression language. *}
    
lemma unrest_uop [unrest]: "a \<sharp> e \<Longrightarrow> a \<sharp> uop f e"
  by (transfer, simp)

lemma unrest_bop [unrest]: "\<lbrakk> a \<sharp> u; a \<sharp> v \<rbrakk> \<Longrightarrow> a \<sharp> bop f u v"
  by (transfer, simp)

lemma unrest_trop [unrest]: "\<lbrakk> a \<sharp> u; a \<sharp> v; a \<sharp> w \<rbrakk> \<Longrightarrow> a \<sharp> trop f u v w"
  by (transfer, simp)

lemma unrest_qtop [unrest]: "\<lbrakk> a \<sharp> u; a \<sharp> v; a \<sharp> w; a \<sharp> y \<rbrakk> \<Longrightarrow> a \<sharp> qtop f u v w y"
  by (transfer, simp)

text {* For convenience, we also prove unrestriction rules for the bespoke operators on equality,
  numbers, arithmetic etc. *}
    
lemma unrest_eq [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u =\<^sub>u v"
  by (simp add: eq_upred_def, transfer, simp)

lemma unrest_zero [unrest]: "x \<sharp> 0"
  by (simp add: unrest_lit zero_uexpr_def)

lemma unrest_one [unrest]: "x \<sharp> 1"
  by (simp add: one_uexpr_def unrest_lit)

lemma unrest_numeral [unrest]: "x \<sharp> (numeral n)"
  by (simp add: numeral_uexpr_simp unrest_lit)

lemma unrest_sgn [unrest]: "x \<sharp> u \<Longrightarrow> x \<sharp> sgn u"
  by (simp add: sgn_uexpr_def unrest_uop)

lemma unrest_abs [unrest]: "x \<sharp> u \<Longrightarrow> x \<sharp> abs u"
  by (simp add: abs_uexpr_def unrest_uop)

lemma unrest_plus [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u + v"
  by (simp add: plus_uexpr_def unrest)

lemma unrest_uminus [unrest]: "x \<sharp> u \<Longrightarrow> x \<sharp> - u"
  by (simp add: uminus_uexpr_def unrest)

lemma unrest_minus [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u - v"
  by (simp add: minus_uexpr_def unrest)

lemma unrest_times [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u * v"
  by (simp add: times_uexpr_def unrest)

lemma unrest_divide [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u / v"
  by (simp add: divide_uexpr_def unrest)

text {* For a $\lambda$-term we need to show that the characteristic function expression does
  not restrict $v$ for any input value $x$. *}
    
lemma unrest_ulambda [unrest]:
  "\<lbrakk> \<And> x. v \<sharp> F x \<rbrakk> \<Longrightarrow> v \<sharp> (\<lambda> x \<bullet> F x)"
  by (transfer, simp)

end