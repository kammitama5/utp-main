(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: utp_sorts.thy                                                        *)
(* Author: Frank Zeyda and Simon Foster, University of York (UK)              *)
(******************************************************************************)

header {* Value Sorts *}

theory utp_sorts
imports 
  "../utp_common" 
  utp_names
  utp_event
  utp_value
begin

text {* Some sorts still need to be developed in terms of their operators. *}

subsection {* Parametric Type Locale *}

text {* The following locale allows us to deal generically with single-parametric types.
  It provides a constructor, destructor, UTP type, set of permissible parameter types
  and a function to get the elements as a set. We are required to prove that
  the destructor is inverse of the constructor, that the defined carrier of the type
  is precisely those values which can be constructed and that the parametric type
  constructor is injective. *}

locale UTP_PARM_TYPE =
  (* Constructor *)
  fixes AbsU     :: "'UTP_VALUE utype \<Rightarrow> 'HOL_VALUE::type \<Rightarrow> 'UTP_VALUE"
  (* Destructor *)
  fixes RepU     :: "'UTP_VALUE \<Rightarrow> 'HOL_VALUE"
  (* Type for constructed values *)
  fixes TypeU    :: "'UTP_VALUE utype \<Rightarrow> 'UTP_VALUE utype"
  (* Permissible element types *)
  fixes PermU    :: "'UTP_VALUE utype set"
  (* The elements of a composite value *)
  fixes elemU    :: "'HOL_VALUE \<Rightarrow> 'UTP_VALUE set"

  assumes RepU: "\<lbrakk> a \<in> PermU; elemU x \<subseteq> dcarrier a \<rbrakk> \<Longrightarrow> RepU (AbsU a x) = x"
  and     TypeU_dcarrier: 
            "a \<in> PermU \<Longrightarrow> dcarrier (TypeU a) = AbsU a ` {xs . elemU xs \<subseteq> dcarrier a}"
  (* and     AbsU_type: "a \<in> PermU \<Longrightarrow> AbsU a xs : a" *)
  and     TypeU_inj: "inj_on TypeU PermU"
  and     PermU_exists: "\<exists>x. x \<in> PermU"
begin

definition isTypeU :: "'UTP_VALUE utype \<Rightarrow> bool" where
"isTypeU a = (\<exists> b. a = TypeU b)"

definition TypeU_param :: "'UTP_VALUE utype \<Rightarrow> 'UTP_VALUE utype" where
"TypeU_param t = (THE a. t = TypeU a \<and> a \<in> PermU)"

definition DefaultPermU :: "'UTP_VALUE utype" where
"DefaultPermU = (SOME x. x \<in> PermU)"

lemma isTypeU: "isTypeU (TypeU a)"
  by (auto simp add:isTypeU_def)

lemma isTypeU_elim: "\<lbrakk> isTypeU a; \<And> b. \<lbrakk> a = TypeU b \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (auto simp add: isTypeU_def)

lemma TypeU_param: "a \<in> PermU \<Longrightarrow> TypeU_param (TypeU a) = a"
  apply (simp add:TypeU_param_def)
  apply (rule the_equality)
  apply (simp)
  apply (metis TypeU_inj inj_on_eval_simp)
done

lemma DefaultPermU: "DefaultPermU \<in> PermU"
  by (metis (full_types) PermU_exists someI_ex DefaultPermU_def)

lemma Defined: 
  "\<lbrakk> a \<in> PermU; elemU x \<subseteq> dcarrier a \<rbrakk> \<Longrightarrow> \<D> (AbsU a x)"
  by (smt TypeU_dcarrier dcarrier_def imageI mem_Collect_eq)

lemma AbsU_type:
  "\<lbrakk> a \<in> PermU; elemU x \<subseteq> dcarrier a \<rbrakk> \<Longrightarrow> AbsU a x :! TypeU a"
  by (metis (lifting) TypeU_dcarrier dcarrier_dtype imageI mem_Collect_eq)

lemma TypeU_witness:
  "\<lbrakk> a \<in> PermU; xs :! TypeU a \<rbrakk> \<Longrightarrow> \<exists> ys. elemU ys \<subseteq> dcarrier a \<and> xs = AbsU a ys"
  apply (unfold dtype_as_dcarrier[THEN sym])
  apply (unfold TypeU_dcarrier)
  apply (auto)
done

lemma TypeU_elim:
  "\<lbrakk> x :! TypeU a; a \<in> PermU
   ; \<And> y. \<lbrakk> x = AbsU a y; elemU y \<subseteq> dcarrier a \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis TypeU_witness)

end

subsection {* Bottom Element Sort *}

class BOT_SORT = VALUE +
  fixes ubot :: "'a utype \<Rightarrow> 'a" ("\<bottom>v\<^bsub>_\<^esub>")
  assumes ubot_ndefined [defined] : "\<D> (\<bottom>v\<^bsub>a\<^esub>) = False"
  and     ubot_type [typing]: "\<bottom>v\<^bsub>a\<^esub> : a"

subsubsection {* Theorems *}

theorem Defined_not_eq_bot [simp] :
"\<D> v \<Longrightarrow> v \<noteq> \<bottom>v\<^bsub>a\<^esub>"
  by (metis ubot_ndefined)

(*
subsection {* Coercision Sort *}
class COERCE_SORT = VALUE +
  fixes coerce :: "'a \<Rightarrow> 'a utype \<Rightarrow> 'a"
  assumes coerce_tau: "x :! t \<Longrightarrow> \<tau> (coerce x t) = t"
*)

subsection {* Integer Sort *}

text {* The @{term "INT_SORT"} and most other sorts in this file
define three constants and several properties. The constants are an
injection @{term "MkInt"}, a projection @{term "DestInt"}, and 
a type. *}

class INT_SORT = VALUE +
  fixes MkInt   :: "int \<Rightarrow> 'a"
  fixes DestInt :: "'a \<Rightarrow> int"
  fixes IntType :: "'a utype"
  -- {* The injection can always be reversed. *}
  assumes Inverse [simp] : "DestInt (MkInt i) = i"
  -- {* The values produced by the injection are precisely the well typed 
        and defined integer values. *}
  assumes IntType_dcarrier: "dcarrier IntType = range MkInt"
begin

text {* The results of the injection are always defined. *}

lemma Defined [defined]: "\<D> (MkInt i)"
  by (metis IntType_dcarrier dcarrier_defined rangeI)

lemma MkInt_type [typing]: "MkInt n : IntType"
  by (metis IntType_dcarrier dcarrier_type rangeI)

lemma MkInt_dtype [typing]: "MkInt n :! IntType"
  by (metis Defined MkInt_type dtype_relI)

lemma MkInt_cases [elim]: 
  "\<lbrakk> x :! IntType; \<And> i. x = MkInt i \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis IntType_dcarrier dtype_as_dcarrier image_iff)

lemma MkInt_inj_simp [simp]: 
  "(MkInt x = MkInt y) \<longleftrightarrow> x = y"
  by (metis Inverse)

subsubsection {* Integer Operators *}

definition UMinusV :: "'a \<Rightarrow> 'a" where
"UMinusV i = MkInt (-DestInt(i))"
notation UMinusV ("-v _" [81] 80)

definition PlusV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"PlusV i1 i2 = MkInt (DestInt(i1) + DestInt(i2))"
notation PlusV (infixl "+v" 65)

definition MinusV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"MinusV i1 i2 = MkInt (DestInt(i1) - DestInt(i2))"
notation MinusV (infixl "-v" 65)

definition MultV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"MultV i1 i2 = MkInt (DestInt(i1) * DestInt(i2))"
notation MultV (infixl "*v" 70)

definition DivideV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"DivideV i1 i2 = MkInt (DestInt(i1) div DestInt(i2))"
notation DivideV (infixl "divv" 70)

definition ModulusV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"ModulusV i1 i2 = MkInt (DestInt(i1) mod DestInt(i2))"
notation ModulusV (infixl "modv" 70)

subsubsection {* Default Simplifications *}

declare UMinusV_def [simp]
declare PlusV_def [simp]
declare MinusV_def [simp]
declare MultV_def [simp]
declare DivideV_def [simp]
declare ModulusV_def [simp]

end

subsection {* Name Sort *}

class NAME_SORT = VALUE +
  fixes MkNm :: "NAME \<Rightarrow> 'a"
  fixes DestNm :: "'a \<Rightarrow> NAME"
  fixes NmType  :: "'a utype"
  assumes Inverse [simp] : "DestNm (MkNm b) = b"
  and     MkNm_dcarrier: "dcarrier NmType = range MkNm"
  and     NmType_monotype [typing]: "monotype NmType"

subsection {* Boolean Sort *}

class BOOL_SORT = VALUE +
  fixes MkBool :: "bool \<Rightarrow> 'a"
  fixes DestBool :: "'a \<Rightarrow> bool"
  fixes BoolType  :: "'a utype"
  assumes Inverse [simp] : "DestBool (MkBool b) = b"
  and     BoolType_dcarrier: "dcarrier BoolType = range MkBool"
  and     BoolType_monotype [typing]: "monotype BoolType"
begin

subsubsection {* Derived theorems *}

lemma Defined [defined] : "\<D> (MkBool b)"
  by (metis BoolType_dcarrier dcarrier_defined rangeI)

lemma MkBool_type [typing]: "MkBool b : BoolType"
  by (metis BoolType_dcarrier dcarrier_type rangeI)

lemma MkBool_dtype [typing]: "MkBool b :! BoolType"
  by (metis Defined MkBool_type dtype_relI)

lemma DestBool_inj: "inj_on DestBool (range MkBool)"
  by (simp add:inj_on_def)

lemma MkBool_inj: "inj MkBool"
  by (smt Inverse injI)

lemma MkBool_inj_simp [simp]:
  "MkBool x = MkBool y \<longleftrightarrow> x = y"
  by (metis (full_types) MkBool_inj UNIV_def injD)

lemma DestBool_inv: "x \<in> range MkBool \<Longrightarrow> MkBool (DestBool x) = x"
  by (smt DestBool_inj Inverse inj_on_iff rangeI)

subsubsection {* Boolean Operators *}

definition TrueV :: "'a" where
"TrueV = MkBool True"

definition FalseV :: "'a" where
"FalseV = MkBool False"

text {* The precedence of boolean operators is similar to those in HOL. *}

definition NotV :: "'a \<Rightarrow> 'a" where
"NotV x = MkBool (\<not> DestBool x)"
notation NotV ("\<not>v _" [40] 40)

definition AndV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"AndV b1 b2 = MkBool (DestBool(b1) \<and> DestBool(b2))"
notation AndV (infixr "\<and>v" 35)

definition OrV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"OrV b1 b2 = MkBool (DestBool(b1) \<or> DestBool(b2))"
notation OrV (infixr "\<and>v" 30)

definition ImpliesV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"ImpliesV b1 b2 = MkBool (DestBool(b1) \<longrightarrow> DestBool(b2))"
notation OrV (infixr "\<Rightarrow>v" 25)

definition IffV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"IffV b1 b2 = MkBool (DestBool(b1) \<longleftrightarrow> DestBool(b2))"
notation IffV (infixr "\<Leftrightarrow>v" 25)

subsubsection {* Default Simplifications *}

declare TrueV_def [simp]
declare FalseV_def [simp]
declare NotV_def [simp]
declare AndV_def [simp]
declare OrV_def [simp]
declare ImpliesV_def [simp]
declare IffV_def [simp]

lemma MkBool_cases [elim]: 
  "\<lbrakk> x : BoolType; \<not> \<D> x \<Longrightarrow> P; x = TrueV \<Longrightarrow> P; x = FalseV \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  apply (case_tac "\<D> x")
  apply (simp)
  apply (subgoal_tac "x \<in> range MkBool")
  apply (auto)
  apply (metis)
  apply (metis BoolType_dcarrier dcarrierI)
done

lemma MkBool_cases_defined [elim]:
  "\<lbrakk> x :! BoolType; x = TrueV \<Longrightarrow> P; x = FalseV \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis MkBool_cases dtype_relE)

lemma MkBool_unq [simp]: 
  "MkBool True \<noteq> MkBool False"
  "MkBool False \<noteq> MkBool True"
  by (metis Inverse)+

end

subsection {* Character Sort *}

class CHAR_SORT = VALUE +
  fixes MkChar :: "char \<Rightarrow> 'a"
  fixes DestChar :: "'a \<Rightarrow> char"
  fixes CharType :: "'a utype"
  assumes Inverse [simp] : "DestChar (MkChar c) = c"
  assumes MkChar_range: "range MkChar = {x. x : CharType \<and> \<D> x}"
begin

subsubsection {* Derived theorems *}

lemma Defined [simp] : "Defined (MkChar c)"
  by (metis (lifting) CollectD MkChar_range rangeI)

lemma MkChar_type [typing] : "MkChar x : CharType"
  by (metis (lifting) CollectD MkChar_range rangeI)

end

subsection {* String Sort *}

class STRING_SORT = VALUE +
  fixes MkStr :: "string \<Rightarrow> 'a"
  fixes DestStr :: "'a \<Rightarrow> string"
  fixes StringType :: "'a utype"
  assumes Inverse [simp] : "DestStr (MkStr s) = s"
  and     MkStr_range: "range MkStr = {x. x : StringType \<and> \<D> x}"
begin

subsubsection {* Derived theorems *}

lemma Defined [simp] : "\<D> (MkStr s)"
  by (metis (lifting) MkStr_range mem_Collect_eq rangeI)

lemma MkStr_type [typing] : "MkStr s : StringType"
  by (metis MkStr_range dcarrier_def dcarrier_type rangeI)

end

(*
subsection {* Order operation class *}

class LESS_EQ_SORT = VALUE + BOOL_SORT +
  fixes ulesseq :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"
  assumes ulesseq_type: "ulesseq x y : BoolType"

subsection {* Minus operation class *}

class MINUS_SORT = VALUE +
  fixes utminus :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"
*)

subsection {* Finite set sort *}

class FSET_SORT = BOOL_SORT +
  fixes   MkFSet   :: "'a utype \<Rightarrow> 'a fset \<Rightarrow> 'a"
  and     DestFSet :: "'a \<Rightarrow> 'a fset"
  and     FSetType :: "'a utype \<Rightarrow> 'a utype"
  and     FSetPerm :: "'a utype set"
  assumes FSet_UTP_TYPE: "UTP_PARM_TYPE MkFSet DestFSet FSetType FSetPerm Rep_fset"
begin

theorems 
  MkFSet_defined [defined]  = UTP_PARM_TYPE.Defined[OF FSet_UTP_TYPE] and
  MkFSet_inv [simp]         = UTP_PARM_TYPE.RepU[OF FSet_UTP_TYPE] and
  MkFSet_type [typing]      = UTP_PARM_TYPE.AbsU_type[OF FSet_UTP_TYPE] and
  FSetType_witness [typing] = UTP_PARM_TYPE.TypeU_witness[OF FSet_UTP_TYPE] and
  FSetType_elim [elim]      = UTP_PARM_TYPE.TypeU_elim[OF FSet_UTP_TYPE]

definition FEmptyV  :: "'a utype \<Rightarrow> 'a" where
"FEmptyV a = MkFSet a \<lbrace>\<rbrace>"

definition FInsertV :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FInsertV a x xs = MkFSet a (finsert x (DestFSet xs))"

definition FUnionV  :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FUnionV a xs ys = MkFSet a (DestFSet xs \<union>\<^sub>f DestFSet ys)"

definition FInterV  :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FInterV a xs ys = MkFSet a (DestFSet xs \<inter>\<^sub>f DestFSet ys)"

definition FSubsetV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FSubsetV xs ys = MkBool (DestFSet xs \<subseteq>\<^sub>f DestFSet ys)"

definition FMemberV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FMemberV x xs = MkBool (x \<in>\<^sub>f DestFSet xs)"

definition FNMemberV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"FNMemberV x xs = MkBool (x \<notin>\<^sub>f DestFSet xs)"

end

class BOOL_FSET_SORT = BOOL_SORT + FSET_SORT +
  assumes BoolType_FSetPerm [closure]: "BoolType \<in> FSetPerm"

class INT_FSET_SORT = INT_SORT + FSET_SORT +
  assumes IntType_FSetPerm [closure]: "IntType \<in> FSetPerm"

class EVENT_FSET_SORT = EVENT_SORT + FSET_SORT +
  assumes EventType_FSetPerm [closure]: "EventType \<in> FSetPerm"

class STRING_FSET_SORT = STRING_SORT + FSET_SORT +
  assumes StringType_FSetPerm [closure]: "StringType \<in> FSetPerm"

subsection {* Set sort *}

class SET_SORT = BOOL_SORT +
  fixes   MkSet   :: "'a utype \<Rightarrow> 'a set \<Rightarrow> 'a"
  and     DestSet :: "'a \<Rightarrow> 'a set"
  and     SetType :: "'a utype \<Rightarrow> 'a utype"
  and     SetPerm :: "'a utype set"
  assumes Set_UTP_TYPE: "UTP_PARM_TYPE MkSet DestSet SetType SetPerm id"
begin

theorems 
  MkSet_defined [defined]  = UTP_PARM_TYPE.Defined[OF Set_UTP_TYPE] and
  MkSet_inv [simp]         = UTP_PARM_TYPE.RepU[OF Set_UTP_TYPE] and
  MkSet_type [typing]      = UTP_PARM_TYPE.AbsU_type[OF Set_UTP_TYPE] and
  SetType_witness [typing] = UTP_PARM_TYPE.TypeU_witness[OF Set_UTP_TYPE] and
  SetType_elim [elim]      = UTP_PARM_TYPE.TypeU_elim[OF Set_UTP_TYPE]

definition EmptyV  :: "'a utype \<Rightarrow> 'a" where
"EmptyV a = MkSet a {}"

definition InsertV :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"InsertV a x xs = MkSet a (insert x (DestSet xs))"

definition UnionV  :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"UnionV a xs ys = MkSet a (DestSet xs \<union> DestSet ys)"

definition InterV  :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"InterV a xs ys = MkSet a (DestSet xs \<inter> DestSet ys)"

definition SubsetV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"SubsetV xs ys = MkBool (DestSet xs \<subseteq> DestSet ys)"

definition MemberV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"MemberV x xs = MkBool (x \<in> DestSet xs)"

definition NotMemberV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"NotMemberV x xs = MkBool (x \<notin> DestSet xs)"

end

class EVENT_SET_SORT = EVENT_SORT + SET_SORT +
  assumes EventType_SetPerm [closure]: "EventType \<in> SetPerm"

subsection {* List Sort *}

class LIST_SORT = BOOL_SORT +
  fixes MkList :: "'a utype \<Rightarrow> 'a list \<Rightarrow> 'a"
  and   DestList :: "'a \<Rightarrow> 'a list"
  and   ListType :: "'a utype \<Rightarrow> 'a utype"
  and   ListPerm :: "'a utype set"
  assumes List_UTP_TYPE: "UTP_PARM_TYPE MkList DestList ListType ListPerm set"
begin

abbreviation "isListType \<equiv> UTP_PARM_TYPE.isTypeU ListType"
abbreviation "ListParam \<equiv> UTP_PARM_TYPE.TypeU_param ListType"
abbreviation "ListDefaultPerm \<equiv> UTP_PARM_TYPE.DefaultPermU ListPerm"

theorems 
  isListType [simp]         = UTP_PARM_TYPE.isTypeU[OF List_UTP_TYPE] and
  isListType_elim [elim]    = UTP_PARM_TYPE.isTypeU_elim[OF List_UTP_TYPE] and
  ListParam [simp]          = UTP_PARM_TYPE.TypeU_param[OF List_UTP_TYPE] and
  ListType_dcarrier         = UTP_PARM_TYPE.TypeU_dcarrier[OF List_UTP_TYPE] and
  ListDefaultPerm           = UTP_PARM_TYPE.DefaultPermU[OF List_UTP_TYPE] and
  MkList_defined [defined]  = UTP_PARM_TYPE.Defined[OF List_UTP_TYPE] and
  MkList_inv [simp]         = UTP_PARM_TYPE.RepU[OF List_UTP_TYPE] and
  MkList_type [typing]      = UTP_PARM_TYPE.AbsU_type[OF List_UTP_TYPE] and
  ListType_witness [typing] = UTP_PARM_TYPE.TypeU_witness[OF List_UTP_TYPE] and
  ListType_elim [elim]      = UTP_PARM_TYPE.TypeU_elim[OF List_UTP_TYPE]

subsubsection {* List Operators *}

definition NilV :: "'a utype \<Rightarrow> 'a" where
"NilV a = MkList a []"
notation NilV ("[]\<^bsub>_\<^esub>")

definition ConsV :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"ConsV a x xs = MkList a (x # DestList xs)"

abbreviation ConsV_syn :: "'a \<Rightarrow> 'a utype \<Rightarrow> 'a \<Rightarrow> 'a" (infixr "#\<^bsub>_\<^esub>" 65) where
"ConsV_syn xs a ys \<equiv> ConsV a xs ys" 

definition ConcatV :: "'a utype \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"ConcatV a xs ys = MkList a (DestList xs @ DestList ys)"

abbreviation ConcatV_syn :: "'a \<Rightarrow> 'a utype \<Rightarrow> 'a \<Rightarrow> 'a" (infixr "@\<^bsub>_\<^esub>" 65) where
"xs @\<^bsub>a\<^esub> ys \<equiv> ConcatV a xs ys" 

definition PrefixV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"PrefixV xs ys = MkBool (prefixeq (DestList xs) (DestList ys))"
  
lemma NilV_type [typing]:
  "a \<in> ListPerm \<Longrightarrow> NilV a :! ListType a"
  by (auto intro:typing simp add:NilV_def)

(*
lemma ConsV_type [typing]:
  "\<lbrakk> a \<in> ListPerm; x :! a; xs :! ListType a \<rbrakk> 
     \<Longrightarrow> x #\<^bsub>a\<^esub> xs :! ListType a"
  apply (auto intro:typing simp add:ConsV_def)
  apply (rule typing) back
  apply (auto)
  apply (rule typing)
  apply (force intro:typing)
  apply (auto)
  apply (force)
by (metis ListType_witness MkList_inv dtype_as_dcarrier subset_code(1))

lemma ConsV_FUNC2 [closure]: 
  "a \<in> ListPerm \<Longrightarrow> ConsV a \<in> FUNC2 a (ListType a) (ListType a)"
  by (auto intro:typing simp add:FUNC2_def)

lemma ConcatV_type [typing]:
  "\<lbrakk> a \<in> ListPerm; xs :! ListType a; ys :! ListType a \<rbrakk>
     \<Longrightarrow> xs @\<^bsub>a\<^esub> ys :! ListType a" 
  by (force intro:typing simp add:ConcatV_def)

lemma ConcatV_FUNC [closure]: 
  "a \<in> ListPerm \<Longrightarrow> ConcatV a \<in> FUNC2 (ListType a) (ListType a) (ListType a)"
  by (auto intro:typing simp add:FUNC2_def)

lemma PrefixV_type [typing]:
  "\<lbrakk> a \<in> ListPerm; xs :! ListType a; ys :! ListType a \<rbrakk>
     \<Longrightarrow> PrefixV xs ys :! BoolType" 
  by (force intro:typing simp add:PrefixV_def)

lemma PrefixV_FUNC [closure]:
  "a \<in> ListPerm \<Longrightarrow> PrefixV \<in> FUNC2 (ListType a) (ListType a) BoolType"
  by (auto intro:typing simp add:FUNC2_def)
*)

text {* This lemma is sort of a lifting on the induction rule for lists *}

lemma ListType_cases:
  assumes "a \<in> ListPerm" "xs :! ListType a"
  shows "(xs = []\<^bsub>a\<^esub>) \<or> (\<exists> y ys. y :! a \<and> ys :! ListType a \<and> xs = y #\<^bsub>a\<^esub> ys)"
proof -
  from assms have "xs \<in> MkList a ` {xs. set xs \<subseteq> dcarrier a}"
    apply (unfold ListType_dcarrier[THEN sym])
    apply (unfold dcarrier_def)
    apply (auto)
  done

  then obtain ys where xsys: "xs = MkList a ys" and yscarrier: "set ys \<subseteq> dcarrier a"
    by (auto)

  from assms(1) yscarrier
  have "MkList a ys = []\<^bsub>a\<^esub> \<or> (\<exists>z zs. z :! a \<and> zs :! ListType a \<and> MkList a ys = z #\<^bsub>a\<^esub> zs)"
  proof (induct ys)
    case Nil thus ?case
      by (simp add:NilV_def)
  next
    case (Cons y ys) thus ?case
      apply (rule_tac disjI2)
      apply (rule_tac x="y" in exI)
      apply (rule_tac x="MkList a ys" in exI)
      apply (auto intro:typing)
      apply (metis ConsV_def MkList_inv)+
    done
  qed

  with xsys show ?thesis
    by (simp)
qed

lemma DestList_elem_type:
  "\<lbrakk> a \<in> ListPerm; xs :! ListType a \<rbrakk> \<Longrightarrow> set (DestList xs) \<subseteq> dcarrier a"
  by (metis ListType_elim MkList_inv)

lemma DestList_elem_stype:
  "\<lbrakk> x \<in> set (DestList xs); xs :! ListType t; t \<in> ListPerm \<rbrakk> \<Longrightarrow> x :! t"
  by (metis DestList_elem_type dcarrier_dtype set_rev_mp)

lemma MkList_inj_simp [simp]:
  assumes "t \<in> ListPerm" "set xs \<subseteq> dcarrier t" "set ys \<subseteq> dcarrier t"
  shows "(MkList t xs = MkList t ys) \<longleftrightarrow> xs = ys"
  by (metis MkList_inv assms)

end

subsection {* Pair Sort *}

class PAIR_SORT = VALUE +
  fixes MkPair :: "('a \<times> 'a) \<Rightarrow> 'a"
  and   DestPair :: "'a \<Rightarrow> ('a \<times> 'a)"
  and   PairType :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> 'a utype"
  and   PairPerm :: "'a utype set"

  assumes Inverse [simp] :
    "\<lbrakk> a \<in> PairPerm; b \<in> PairPerm; x :! a; y :! b \<rbrakk> \<Longrightarrow> DestPair (MkPair (x, y)) = (x, y)"
  and PairType_dcarrier: 
    "\<lbrakk> a \<in> PairPerm; b \<in> PairPerm \<rbrakk> \<Longrightarrow> 
       dcarrier (PairType a b) = MkPair ` (dcarrier a \<times> dcarrier b)"
begin

definition PairV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"PairV x y = MkPair (x, y)"

definition FstV :: "'a \<Rightarrow> 'a" where
"FstV x = fst (DestPair x)"

definition SndV :: "'a \<Rightarrow> 'a" where
"SndV x = snd (DestPair x)"

end

class BOOL_LIST_SORT = BOOL_SORT + LIST_SORT +
  assumes BoolType_ListPerm [closure]: "BoolType \<in> ListPerm"

class INT_LIST_SORT = INT_SORT + LIST_SORT +
  assumes IntType_ListPerm [closure]: "IntType \<in> ListPerm"

class EVENT_LIST_SORT = EVENT_SORT + LIST_SORT +
  assumes EventType_ListPerm [closure]: "EventType \<in> ListPerm"

class STRING_LIST_SORT = STRING_SORT + LIST_SORT +
  assumes StringType_ListPerm [closure]: "StringType \<in> ListPerm"

subsection {* Real Sort *}

class REAL_SORT = VALUE +
  fixes MkReal :: "real \<Rightarrow> 'a"
  fixes DestReal :: "'a \<Rightarrow> real"
  fixes IsReal :: "'a \<Rightarrow> bool"
  fixes RealType :: "'a utype" ("\<real>")
  assumes Inverse [simp] : "DestReal (MkReal r) = r"
  assumes RealType_dcarrier: "dcarrier RealType = range MkReal"
begin

text {* The results of the injection are always defined. *}

lemma Defined [defined]: "\<D> (MkReal i)"
  by (metis RealType_dcarrier dcarrier_defined rangeI)

lemma MkReal_type [typing]: "MkReal n : RealType"
  by (metis RealType_dcarrier dcarrier_type rangeI)

lemma MkReal_dtype [typing]: "MkReal n :! RealType"
  by (metis Defined MkReal_type dtype_relI)

lemma MkReal_cases [elim]: 
  "\<lbrakk> x :! RealType; \<And> i. x = MkReal i \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis RealType_dcarrier dtype_as_dcarrier image_iff)

lemma MkReal_inj_simp [simp]: 
  "(MkReal x = MkReal y) \<longleftrightarrow> x = y"
  by (metis Inverse)

end

subsection {* Function Sort *}

class FUNCTION_SORT = BOT_SORT +
  fixes MkFunc   :: "('a \<Rightarrow> 'a) \<Rightarrow> 'a"
  and   DestFunc :: "'a \<Rightarrow> ('a \<Rightarrow> 'a)"
  and   IsFunc   :: "('a \<Rightarrow> 'a) \<Rightarrow> bool"
  and   FuncType :: "'a utype \<Rightarrow> 'a utype \<Rightarrow> 'a utype"
  assumes Inverse [simp]: "IsFunc f \<Longrightarrow> DestFunc (MkFunc f) = f"
  and     Defined [simp]: "IsFunc f \<Longrightarrow> Defined (MkFunc f)"
  and     MkFunc_range: "{MkFunc f | f . \<forall> x : a. f x : b \<and> IsFunc f} = dcarrier (FuncType a b)"
  and     FuncType_inj1: "FuncType a1 b1 = FuncType a2 b2 \<Longrightarrow> a1 = a2"
  and     FuncType_inj2: "FuncType a1 b1 = FuncType a2 b2 \<Longrightarrow> b1 = b2"

begin

lemma MkFunc_type [typing]: 
  "\<lbrakk> \<forall> x : a. f x : b; IsFunc f \<rbrakk> \<Longrightarrow> MkFunc f : FuncType a b"
  apply (insert MkFunc_range[of a b])
  apply (auto simp add:dcarrier_def)
done

lemma DestFunc_type [typing]:
  "\<lbrakk> f : FuncType a b; x : a; \<D> f \<rbrakk> \<Longrightarrow> DestFunc f x : b"
  apply (insert MkFunc_range[of a b])
  apply (auto simp add:dcarrier_def)
  apply (smt CollectE CollectI Inverse)
done

definition func_inp_type :: "'a utype \<Rightarrow> 'a utype" where
"func_inp_type t = (SOME a. \<exists> b. t = FuncType a b)"

definition func_out_type :: "'a utype \<Rightarrow> 'a utype" where
"func_out_type t = (SOME b. \<exists> a. t = FuncType a b)"

lemma func_inp_type [simp]:
  "func_inp_type (FuncType a b) = a"
  apply (simp add:func_inp_type_def)
  apply (rule some_equality)
  apply (auto dest: FuncType_inj1)
done

lemma func_out_type [simp]:
  "func_out_type (FuncType a b) = b"
  apply (simp add:func_out_type_def)
  apply (rule some_equality)
  apply (auto dest: FuncType_inj2)
done

subsubsection {* Function Operators *}

definition AppV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"AppV f \<equiv> DestFunc f"

definition CompV :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" where
"CompV f g = MkFunc (DestFunc f \<circ> DestFunc g)"

subsubsection {* Default Simplifications *}

declare AppV_def [simp] CompV_def [simp]

end

class BASIC_SORT =
  INT_SORT + BOOL_SORT + STRING_SORT + REAL_SORT

class COMPOSITE_SORT =
  BASIC_SORT + PAIR_SORT + SET_SORT + FUNCTION_SORT

class REACTIVE_SORT = 
  BOOL_SORT + 
  LIST_SORT + 
  FSET_SORT + 
  SET_SORT +
  EVENT_SORT + 
  EVENT_LIST_SORT + 
  EVENT_FSET_SORT +
  EVENT_SET_SORT +
  assumes FSetPerm_ListPerm [closure]: "a \<in> ListPerm \<Longrightarrow> ListType a \<in> FSetPerm"

end
