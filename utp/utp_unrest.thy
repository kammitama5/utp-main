section {* Unrestriction *}

theory utp_unrest
  imports utp_expr
begin

text {* Unrestriction is an encoding of semantic freshness, that allows us to reason about the
        presence of variables in predicates without being concerned with abstract syntax trees.
        An expression $p$ is unrestricted by variable $x$, written $x \mathop{\sharp} p$, if
        altering the value of $x$ has no effect on the valuation of $p$. This is a sufficient
        notion to prove many laws that would ordinarily rely on an \emph{fv} function. *}

consts
  unrest :: "'a \<Rightarrow> 'b \<Rightarrow> bool"

syntax
  "_unrest" :: "svar \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<sharp>" 20)

translations
  "_unrest x p" == "CONST unrest x p" 

named_theorems unrest

lift_definition unrest_upred :: "('a, '\<alpha>) uvar \<Rightarrow> ('b, '\<alpha>) uexpr \<Rightarrow> bool"
is "\<lambda> x e. \<forall> b v. e (var_update x v b) = e b" .

adhoc_overloading
  unrest unrest_upred

lemma unrest_lit [unrest]: "x \<sharp> \<guillemotleft>v\<guillemotright>"
  by (transfer, simp)

text {* The following law demonstrates why we need variable independence: a variable 
        expression is unrestricted by another variable only when the two variables are independent. *}

lemma unrest_var [unrest]: "\<lbrakk> uvar x; x \<bowtie> y \<rbrakk> \<Longrightarrow> y \<sharp> var x"
  by (transfer, auto)

lemma unrest_uop [unrest]: "x \<sharp> e \<Longrightarrow> x \<sharp> uop f e"
  by (transfer, simp)

lemma unrest_bop [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> bop f u v"
  by (transfer, simp)

lemma unrest_trop [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v; x \<sharp> w \<rbrakk> \<Longrightarrow> x \<sharp> trop f u v w"
  by (transfer, simp)

lemma unrest_eq [unrest]: "\<lbrakk> x \<sharp> u; x \<sharp> v \<rbrakk> \<Longrightarrow> x \<sharp> u =\<^sub>u v"
  by (simp add: eq_upred_def, transfer, simp)

end