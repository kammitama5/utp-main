(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: utp_value.thy                                                        *)
(* Author: Simon Foster and Frank Zeyda, University of York (UK)              *)
(******************************************************************************)

header {* Abstract Values *}

theory utp_value
imports "../utp_common"
begin

subsection {* Theorem Attributes *}

ML {*
  structure typing =
    Named_Thms (val name = @{binding typing} val description = "typing theorems")
*}

setup typing.setup

ML {*
  structure defined =
    Named_Thms (val name = @{binding defined} val description = "definedness theorems")
*}

setup defined.setup

subsection {* The @{term "VALUE"} class *}

text {* We fix a notion of definedness from the start. This is because control
variables, such as @{term "ok"}, must always be defined but we can't assume that
all values are. *}

class DEFINED =
  fixes Defined   :: "'a \<Rightarrow> bool" ("\<D>")

class DEFINED_NE = DEFINED +
  assumes Defined_nonempty: "\<exists> x. \<D> x"

definition "DEFINED = {x. \<D> x}"
definition "UNDEFINED = {x. \<not> \<D> x}"

lemma DEFINED_UNDEFINED: 
  "DEFINED \<union> UNDEFINED = UNIV"
  by (auto simp add:DEFINED_def UNDEFINED_def)

definition Dom :: "('a \<Rightarrow> 'b::DEFINED) \<Rightarrow> 'a set" where
"Dom f = {x. \<D> (f x)}"

definition Ran :: "('a \<Rightarrow> 'b::DEFINED) \<Rightarrow> 'b set" where
"Ran f = {f x |x. \<D> (f x)}"

lemma Dom_defined [defined]: 
  "x \<in> Dom f \<Longrightarrow> \<D> (f x)"
  by (simp add:Dom_def)

text {* The @{term "VALUE"} class introduces the typing relation with an arbitrary
value sort, and the type sort given by @{term "udom"}, the Universal Domain from
HOLCF. Specifically the type sort must be injectable into udom, which has the
cardinality of the continuum and can be populated using the domain package from
HOLCF. We expect that most type sorts will be @{term "countable"}. 

We require that the typing relation have at least one type with at least one defined
value.
 *}

class VALUE = DEFINED +
  fixes   utype_rel :: "'a \<Rightarrow> nat \<Rightarrow> bool" (infix ":\<^sub>u" 50)
  assumes utype_nonempty: "\<exists> t v. v :\<^sub>u t \<and> \<D> v"

default_sort VALUE

subsection {* The @{term "utype"} type *}

text {* The type @{term "utype"} consists of the set of types which, according
to the typing relation, have at least one defined value. This set should be
more-or-less isomorphic to the underlying type sort in the user's value
model. *}

definition "utypeS (x::'a itself) = {t. \<exists> v :: 'a. v :\<^sub>u t \<and> \<D> v}"

typedef 'VALUE utype = "utypeS TYPE('VALUE)"
  apply (insert utype_nonempty)
  apply (auto simp add:utypeS_def)
done

declare Rep_utype [simp]
declare Abs_utype_inverse [simp]
declare Rep_utype_inverse [simp]

lemma Rep_utype_intro [intro!]:
  "Rep_utype x = Rep_utype y \<Longrightarrow> x = y"
  by (simp add:Rep_utype_inject)

lemma Rep_utype_elim [elim]:
  "\<lbrakk> \<And> v\<Colon>'VALUE. \<lbrakk> v :\<^sub>u Rep_utype (t :: 'VALUE utype); \<D> v \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  apply (insert Rep_utype[of t])
  apply (auto simp add:utypeS_def)
done

lemma Abs_utype_inv [simp]:
  "\<lbrakk> (v :: 'a :: VALUE) :\<^sub>u t; \<D> v \<rbrakk> \<Longrightarrow> Rep_utype (Abs_utype t :: 'a utype) = t"
  apply (rule Abs_utype_inverse)
  apply (auto simp add:utypeS_def)
done

instantiation utype :: (VALUE) countable
begin
instance
  apply (intro_classes)
  apply (rule_tac x="Rep_utype" in exI)
  apply (metis Rep_utype_inverse injI)
done
end

(*  
class VALUE_SUBTYPES = VALUE +
  fixes   usubtype_lattice :: "'a itself \<Rightarrow> nat lattice" 
  assumes carrier_utypeS: "carrier (Rep_lattice (usubtype_lattice TYPE('a))) = utypeS TYPE('a)"

instantiation utype :: (VALUE_SUBTYPES) order
begin

definition less_eq_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> bool" where
"less_eq_utype s t \<longleftrightarrow> le (Rep_lattice (usubtype_lattice TYPE('a))) (Rep_utype s) (Rep_utype t)"

definition less_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> bool" where
"less_utype x y \<longleftrightarrow> (x \<le> y \<and> \<not> y \<le> x)"

instance
  apply (intro_classes)
  apply (simp add:less_utype_def)
  apply (simp_all add: less_eq_utype_def)
  apply (metis Rep_utype carrier_utypeS ltype.le_refl)
  apply (metis (no_types) Rep_utype carrier_utypeS ltype.le_trans)
  apply (metis Rep_utype Rep_utype_intro carrier_utypeS ltype.le_antisym)
done
end

instantiation utype :: (VALUE_SUBTYPES) lattice
begin

definition sup_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> 'a utype" where
"sup_utype s t = Abs_utype (join (Rep_lattice (usubtype_lattice TYPE('a))) (Rep_utype s) (Rep_utype t))"

definition inf_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> 'a utype" where
"inf_utype s t = Abs_utype (meet (Rep_lattice (usubtype_lattice TYPE('a))) (Rep_utype s) (Rep_utype t))"

instance
  apply (intro_classes)
  apply (simp_all add:inf_utype_def less_eq_utype_def)
  apply (smt Abs_utype_inverse Rep_utype carrier_utypeS ltype.meet_closed ltype.meet_left)
  apply (smt Abs_utype_inverse Rep_utype carrier_utypeS ltype.meet_closed ltype.meet_right)
  apply (smt Abs_utype_inverse Rep_utype carrier_utypeS ltype.meet_closed ltype.meet_le)
  apply (smt Abs_utype_inverse Rep_utype carrier_utypeS ltype.join_closed ltype.join_left utp_value.sup_utype_def)
  apply (metis (no_types) Abs_utype_inverse Rep_utype carrier_utypeS ltype.join_closed ltype.join_right utp_value.sup_utype_def)
  apply (metis (no_types) Abs_utype_inverse Rep_utype carrier_utypeS ltype.join_closed ltype.join_le utp_value.sup_utype_def)
done
end
*)

instantiation utype :: (VALUE) linorder 
begin

definition less_eq_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> bool" where
"less_eq_utype x y = (Rep_utype x \<le> Rep_utype y)"

definition less_utype :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> bool" where
"less_utype x y = (Rep_utype x < Rep_utype y)"

instance
  apply (intro_classes)
  apply (auto simp add:less_eq_utype_def less_utype_def)
done
end


text {* We derive a typing relation using @{term "utype"}, which has more 
useful properties than the underlying @{term "utype_rel"}. *}

definition type_rel :: "'VALUE \<Rightarrow> 'VALUE utype \<Rightarrow> bool" (infix ":" 50) where
"x : t \<longleftrightarrow> x :\<^sub>u Rep_utype t"

definition dtype_rel :: "'VALUE \<Rightarrow> 'VALUE utype \<Rightarrow> bool" (infix ":!" 50) where
"x :! t \<longleftrightarrow> x : t \<and> \<D> x"

definition default :: "'VALUE utype \<Rightarrow> 'VALUE" where
"default t \<equiv> SOME x. x : t \<and> \<D> x"

definition someType :: "'VALUE utype" where
"someType \<equiv> SOME t. \<exists>x. x : t"

definition monotype :: "'VALUE utype \<Rightarrow> bool" where
"monotype t \<longleftrightarrow> (\<forall> x a. x : t \<and> x : a \<and> \<D> x \<longrightarrow> a = t)"

definition monovalue :: "'a::VALUE \<Rightarrow> bool" where
"monovalue x = (\<D> x \<and> (\<forall> t t'. x : t \<and> x : t' \<longrightarrow> t = t'))"

definition type_of :: "'VALUE \<Rightarrow> 'VALUE utype" ("\<tau>") where
"type_of x = (SOME t. x : t)"

lemma type_non_empty: "\<exists> x. x : t"
  apply (auto simp add:type_rel_def)
  apply (rule_tac Rep_utype_elim)
  apply (auto)
done

lemma type_non_empty_defined: "\<exists> x. x : t \<and> \<D> x"
  apply (auto simp add:type_rel_def)
  apply (rule_tac Rep_utype_elim)
  apply (auto)
done

lemma dtype_non_empty: "\<exists> x. x :! t"
  apply (auto simp add:dtype_rel_def type_rel_def)
  apply (rule_tac Rep_utype_elim)
  apply (auto)
done

lemma type_non_empty_elim [elim]:
  "\<lbrakk> \<And> x. \<lbrakk> x : t; \<D> x \<rbrakk> \<Longrightarrow> P t \<rbrakk> \<Longrightarrow> P t"
  apply (insert type_non_empty_defined[of t])
  apply (auto)
done

lemma default_type [typing,intro]: "default t : t"
  apply (simp add:default_def)
  apply (rule type_non_empty_elim)
  apply (smt tfl_some)
done

lemma default_defined [defined]: "\<D> (default t)"
  apply (simp add:default_def)
  apply (metis (lifting) some_eq_ex type_non_empty_defined)
done

instance VALUE \<subseteq> DEFINED_NE
  apply (intro_classes)
  apply (rule_tac x="default someType" in exI)
  apply (simp add:defined)
done

lemma someType_value: "\<exists> v. v : someType"
  apply (simp add:someType_def)
  apply (metis (lifting) Rep_utype_elim type_rel_def)
done

lemma type_of_type [typing]:
  "x : t \<Longrightarrow> x : \<tau> x"
  by (metis tfl_some type_of_def)

lemma type_of_monotype [simp]: 
  "\<lbrakk> x :! t; monotype t \<rbrakk> \<Longrightarrow> \<tau> x = t"
  apply (unfold type_of_def monotype_def)
  apply (rule some_equality)
  apply (auto simp add:dtype_rel_def)
done

lemma type_of_monovalue [simp]:
  "\<lbrakk> monovalue x; x : a; x : b \<rbrakk> \<Longrightarrow> a = b"
  by (auto simp add:monovalue_def)

lemma monovalue_monotype [typing]:
  "\<lbrakk> monotype t; x :! t \<rbrakk> \<Longrightarrow> monovalue x"
  by (auto simp add:monovalue_def monotype_def dtype_rel_def)

lemma Abs_utype_type [typing,intro]: 
  "\<lbrakk> x :\<^sub>u t; \<D> x \<rbrakk> \<Longrightarrow> x : Abs_utype t"
  by (metis (lifting) Rep_utype_cases Rep_utype_inverse utypeS_def mem_Collect_eq type_rel_def)

lemma dtype_relI [intro]: "\<lbrakk> x : t; \<D> x \<rbrakk> \<Longrightarrow> x :! t"
  by (simp add:dtype_rel_def)

lemma dtype_relE [elim]: "\<lbrakk> x :! t; \<lbrakk> x : t; \<D> x \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (simp add:dtype_rel_def)

lemma dtype_type [typing]: "x :! a \<Longrightarrow> x : a"
  by (simp add:dtype_rel_def)

lemma dtype_defined [defined]: "x :! a \<Longrightarrow> \<D> x"
  by (simp add:dtype_rel_def)

definition embTYPE :: "'b::countable \<Rightarrow> 'a::VALUE utype" where
"embTYPE t \<equiv> Abs_utype (to_nat t)"

definition prjTYPE :: "'a::VALUE utype \<Rightarrow> 'b::{countable}" where
"prjTYPE t \<equiv> from_nat (Rep_utype t)"

lemma embTYPE_inv [simp]:
  fixes t :: "'a::countable"
    and v :: "'b"
  assumes "v :\<^sub>u to_nat t" "\<D> v"
  shows "prjTYPE (embTYPE t :: 'b utype) = t"
  apply (subgoal_tac "to_nat t \<in> utypeS TYPE('b)")
  apply (simp add:embTYPE_def prjTYPE_def)
  apply (simp add:utypeS_def)
  apply (rule_tac x="v" in exI)
  apply (simp add:assms)
done

subsection {* Typing operator syntax *}

abbreviation Tall :: "'a utype \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool" where
  "Tall t P \<equiv> (\<forall>x. x : t \<longrightarrow> P x)"

abbreviation Tex :: "'a utype \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool" where
  "Tex t P \<equiv> (\<exists>x. x : t \<and> P x)"

abbreviation DTex :: "'a utype \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool" where
  "DTex t P \<equiv> (\<exists>x. x :! t \<and> P x)"

abbreviation DTall :: "'a utype \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> bool" where
  "DTall t P \<equiv> (\<forall>x. x :! t \<longrightarrow> P x)"

syntax
  "_Tall" :: "pttrn => 'a utype => bool => bool" ("(3\<forall> _:_./ _)" [0, 0, 10] 10)
  "_Tex"  :: "pttrn => 'a utype => bool => bool" ("(3\<exists> _:_./ _)" [0, 0, 10] 10)
  "_DTall" :: "pttrn => 'a utype => bool => bool" ("(3\<forall> _:!_./ _)" [0, 0, 10] 10)
  "_DTex"  :: "pttrn => 'a utype => bool => bool" ("(3\<exists> _:!_./ _)" [0, 0, 10] 10)

  
translations
  "\<forall> x:A. P" == "CONST Tall A (%x. P)"
  "\<exists> x:A. P" == "CONST Tex A (%x. P)"
  "\<forall> x:!A. P" == "CONST DTall A (%x. P)"
  "\<exists> x:!A. P" == "CONST DTex A (%x. P)"


instantiation utype :: (VALUE) DEFINED
begin

definition Defined_utype :: "'a utype \<Rightarrow> bool" where
"Defined_utype t = (\<exists> v:t. \<D> v)"

instance ..
end

lemma Defined_utype_elim [elim]:
  "\<lbrakk> \<D> t; \<And> x. \<lbrakk> x : t; \<D> x \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (auto simp add:Defined_utype_def)

subsection {* Universe *}

definition VALUE :: "'VALUE set" where
"VALUE = UNIV"

subsection {* Carrier Set *}

definition carrier :: "'VALUE utype \<Rightarrow> 'VALUE set" where
"carrier t = {x . x : t}"

theorem carrier_non_empty :
"\<forall> t . carrier t \<noteq> {}"
apply (simp add: carrier_def type_non_empty)
done

theorem carrier_member :
"x : t \<Longrightarrow> x \<in> carrier t"
apply (simp add: carrier_def)
done

theorem carrier_intro :
"(x : t) = (x \<in> carrier t)"
apply (simp add: carrier_def)
done

theorem carrier_elim :
"(x \<in> carrier t) = (x : t)"
apply (simp add: carrier_def)
done

subsection {* Value Sets *}

definition set_type_rel :: "('VALUE) set \<Rightarrow> 'VALUE utype \<Rightarrow> bool" where
"set_type_rel s t = (\<forall> x \<in> s . x : t)"

notation set_type_rel (infix ":\<subseteq>" 50)

theorem set_type_rel_empty [simp] :
"{} :\<subseteq> t"
apply (simp add: set_type_rel_def)
done

theorem set_type_rel_insert [simp] :
"(insert x s) :\<subseteq> t \<longleftrightarrow> (x : t \<and> s :\<subseteq> t)"
apply (simp add: set_type_rel_def)
done

definition dcarrier :: "'VALUE utype \<Rightarrow> 'VALUE set" where
"dcarrier t = {x . x : t \<and> \<D> x}"

lemma dcarrierI [intro]: 
  "\<lbrakk> x : a; \<D> x \<rbrakk> \<Longrightarrow> x \<in> dcarrier a"
  by (simp add:dcarrier_def)

lemma dcarrier_carrier:
  "dcarrier a \<subseteq> carrier a"
  by (auto simp add:carrier_def dcarrier_def)

lemma dcarrier_dtype [typing]:
  "x \<in> dcarrier a \<Longrightarrow> x :! a"
  by (auto simp add:dcarrier_def)

lemma dtype_as_dcarrier [simp]:
  "x \<in> dcarrier a \<longleftrightarrow> x :! a"
  by (auto simp add:dcarrier_def dtype_rel_def)

lemma dcarrier_type [typing]:
  "x \<in> dcarrier a \<Longrightarrow> x : a"
  by (auto simp add:dcarrier_def)

lemma dcarrier_defined [defined]:
  "x \<in> dcarrier a \<Longrightarrow> \<D> x"
  by (auto simp add:dcarrier_def)

subsection {* Function type sets *}

text {* In several models we don't necessarily want to give a complete account to functions
        so these two sets give an account to unary, binary and ternary HOL functions 
        in the UTP *}

definition "FUNC1 a b   = {f. \<forall>x:!a. f x :! b}"

lemma FUNC11I [intro, typing]: 
  "\<lbrakk> \<And> x. x :! a \<Longrightarrow> f x :! b \<rbrakk> \<Longrightarrow> f \<in> FUNC1 a b"
  by (simp add:FUNC1_def)

definition "FUNC2 a b c = {f. \<forall>x:!a. \<forall>y:!b. f x y :! c}"

lemma FUNC2I [intro, typing]: 
  "\<lbrakk> \<And> x y. \<lbrakk> x :! a; y :! b \<rbrakk> \<Longrightarrow> f x y :! c \<rbrakk> \<Longrightarrow> f \<in> FUNC2 a b c"
  by (simp add:FUNC2_def)

definition "FUNC3 a b c d = {f. \<forall>x:!a. \<forall>y:!b. \<forall>z:!c. f x y z:! d}"

lemma FUNC3I [intro, typing]: 
  "\<lbrakk> \<And> x y z. \<lbrakk> x :! a; y :! b; z :! c \<rbrakk> \<Longrightarrow> f x y z :! d \<rbrakk> \<Longrightarrow> f \<in> FUNC3 a b c d"
  by (simp add:FUNC3_def)

subsection {* Sigma types *}

typedef 'm SIGTYPE = "{(t, v :: 'm :: VALUE). v : t}"
  by (auto)

abbreviation Abs_SIGTYPE_syn :: 
  "'a \<Rightarrow> 'a utype \<Rightarrow> 'a SIGTYPE" ("(\<Sigma> _ : _)" [50] 50) where
"\<Sigma> x : t \<equiv> Abs_SIGTYPE (t, x)"

declare Rep_SIGTYPE [simp]
declare Abs_SIGTYPE_inverse [simp]
declare Rep_SIGTYPE_inverse [simp]

lemma Rep_SIGTYPE_intro [intro!]:
  "Rep_SIGTYPE x = Rep_SIGTYPE y \<Longrightarrow> x = y"
  by (simp add:Rep_SIGTYPE_inject)

definition sigtype :: "'m SIGTYPE \<Rightarrow> 'm utype" where
"sigtype s = fst (Rep_SIGTYPE s)"

definition sigvalue :: "'m SIGTYPE \<Rightarrow> 'm" where
"sigvalue s = snd (Rep_SIGTYPE s)"

lemma sigtype [simp]: 
  "x : t \<Longrightarrow> sigtype (\<Sigma> x : t) = t"
  apply (insert Rep_SIGTYPE[of "(\<Sigma> x : t)"])
  apply (auto simp add:sigtype_def)
done
  
lemma sigvalue [simp]: 
  "x : t \<Longrightarrow> sigvalue (\<Sigma> x : t) = x"
  apply (insert Rep_SIGTYPE[of "(\<Sigma> x : t)"])
  apply (auto simp add:sigvalue_def)
done

lemma sigvalue_type: "sigvalue x : sigtype x"
  apply (insert Rep_SIGTYPE[of x])
  apply (auto simp add:sigvalue_def sigtype_def)
done

subsection {* Coercision *}

definition coerce :: "'a \<Rightarrow> 'a utype \<Rightarrow> 'a" where
"coerce x t = (if (x : t) then x else default t)"

lemma coerce_type: 
  "coerce x t : t"
  by (auto simp add:coerce_def dtype_rel_def)

lemma coerce_reduce1 [simp]:
  "x : t \<Longrightarrow> coerce x t = x"
  by (simp add:coerce_def)

lemma coerce_reduce2 [simp]:
  "\<not> x : t \<Longrightarrow> coerce x t = default t"
  by (simp add:coerce_def)

end
