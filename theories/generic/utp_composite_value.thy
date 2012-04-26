(******************************************************************************)
(* Title: utp/generic/utp_composite_value.thy                                 *)
(* Author: Frank Zeyda, University of York                                    *)
(******************************************************************************)
theory utp_composite_value
imports "../utp_sorts" utp_abstract_value
begin

section {* Composite Values *}

subsection {* Value Encoding *}

text {* Does @{text "SetVal"} need to know about the type of the set? *}

datatype 'BASIC_VALUE COMPOSITE_VALUE =
  BasicVal "'BASIC_VALUE" |
  PairVal "'BASIC_VALUE COMPOSITE_VALUE" "'BASIC_VALUE COMPOSITE_VALUE" |
  SetVal "'BASIC_VALUE COMPOSITE_VALUE SET"

datatype 'BASIC_TYPE COMPOSITE_TYPE =
  BasicType "'BASIC_TYPE" |
  PairType "'BASIC_TYPE COMPOSITE_TYPE" "'BASIC_TYPE COMPOSITE_TYPE" |
  SetType "'BASIC_TYPE COMPOSITE_TYPE"

subsubsection {* Destructors *}

primrec BasicOf ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> 'BASIC_VALUE" where
"BasicOf (BasicVal v) = v"

primrec PairOf ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
  ('BASIC_VALUE COMPOSITE_VALUE \<times>
   'BASIC_VALUE COMPOSITE_VALUE)" where
"PairOf (PairVal v1 v2) = (v1, v2)"

primrec SetOf ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE SET" where
"SetOf (SetVal s) = s"

subsubsection {* Tests *}

primrec IsBasicVal ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsBasicVal (BasicVal v) = True" |
"IsBasicVal (PairVal v1 v2) = False" |
"IsBasicVal (SetVal s) = False"

primrec IsPairVal ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsPairVal (BasicVal v) = False" |
"IsPairVal (PairVal v1 v2) = True" |
"IsPairVal (SetVal s) = False"

primrec IsSetVal ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsSetVal (BasicVal v) = False" |
"IsSetVal (PairVal v1 v2) = False" |
"IsSetVal (SetVal s) = True"

subsubsection {* Abbreviations *}

abbreviation EncSetVal ::
  "'BASIC_VALUE COMPOSITE_VALUE set \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE" where
"EncSetVal vs \<equiv> SetVal (EncSet vs)"

abbreviation DecSetOf ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE set" where
"DecSetOf v \<equiv> DecSet (SetOf v)"

subsection {* Typing and Refinement *}

fun lift_type_rel_composite ::
  "('BASIC_VALUE \<Rightarrow> 'BASIC_TYPE \<Rightarrow> bool) \<Rightarrow>
   ('BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
    'BASIC_TYPE COMPOSITE_TYPE \<Rightarrow> bool)"
  ("(_ \<up> _ : _)" [50, 51] 50) where
"type_rel \<up> (BasicVal v) : (BasicType t) = (type_rel v t)" |
"type_rel \<up> (PairVal v1 v2) : (PairType t1 t2) =
   ((type_rel \<up>  v1 : t1) \<and> (type_rel \<up>  v2 : t2))" |
"type_rel \<up> (SetVal vs) : (SetType t) =
   (\<forall> v \<in> DecSet(vs) . type_rel \<up>  v : t)" |
"(type_rel \<up> _ : _) = False"

fun lift_value_ref_composite ::
  "('BASIC_VALUE \<Rightarrow> 'BASIC_VALUE \<Rightarrow> bool) \<Rightarrow>
   ('BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
    'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool)"
  ("(_ \<up> _ \<sqsubseteq>v/ _)" [50, 51] 50) where
"value_ref \<up> (BasicVal v) \<sqsubseteq>v (BasicVal v') = (value_ref v v')" |
"value_ref \<up> (PairVal v1 v2) \<sqsubseteq>v (PairVal v1' v2') =
   (v1 = v1' \<and> v2 = v2')" |
"value_ref \<up> (SetVal vs) \<sqsubseteq>v (SetVal vs') = (vs = vs')" |
"(value_ref \<up> _ \<sqsubseteq>v _) = False"

subsection {* Sort Membership *}

instantiation COMPOSITE_VALUE :: (BASIC_SORT) COMPOSITE_SORT
begin
definition ValueRef_COMPOSITE_VALUE :
"ValueRef_COMPOSITE_VALUE =
 lift_value_ref_composite (VALUE_SORT_class.ValueRef)"
definition MkInt_COMPOSITE_VALUE :
"MkInt_COMPOSITE_VALUE i = BasicVal (MkInt i)"
definition DestInt_COMPOSITE_VALUE :
"DestInt_COMPOSITE_VALUE v = DestInt (BasicOf v)"
definition IsInt_COMPOSITE_VALUE :
"IsInt_COMPOSITE_VALUE v = ((IsBasicVal v) \<and> IsInt (BasicOf v))"
definition MkBool_COMPOSITE_VALUE :
"MkBool_COMPOSITE_VALUE b = BasicVal (MkBool b)"
definition DestBool_COMPOSITE_VALUE :
"DestBool_COMPOSITE_VALUE v = DestBool (BasicOf v)"
definition IsBool_COMPOSITE_VALUE :
"IsBool_COMPOSITE_VALUE v = ((IsBasicVal v) \<and> IsBool (BasicOf v))"
definition MkStr_COMPOSITE_VALUE :
"MkStr_COMPOSITE_VALUE s = BasicVal (MkStr s)"
definition DestStr_COMPOSITE_VALUE :
"DestStr_COMPOSITE_VALUE v = DestStr (BasicOf v)"
definition IsStr_COMPOSITE_VALUE :
"IsStr_COMPOSITE_VALUE v = ((IsBasicVal v) \<and> IsStr (BasicOf v))"
definition MkPair_COMPOSITE_VALUE :
"MkPair_COMPOSITE_VALUE v1_v2 = (uncurry PairVal) v1_v2"
definition DestPair_COMPOSITE_VALUE :
"DestPair_COMPOSITE_VALUE v = PairOf v"
definition IsPair_COMPOSITE_VALUE :
"IsPair_COMPOSITE_VALUE v = (IsPairVal v)"
definition MkSet_COMPOSITE_VALUE :
"MkSet_COMPOSITE_VALUE vs = EncSetVal vs"
definition DestSet_COMPOSITE_VALUE :
"DestSet_COMPOSITE_VALUE v = DecSetOf v"
definition IsSet_COMPOSITE_VALUE :
"IsSet_COMPOSITE_VALUE v = (IsSetVal v)"
instance
apply (intro_classes)
done
end

subsubsection {* Default Simplifications *}

declare ValueRef_COMPOSITE_VALUE [simp]
declare MkInt_COMPOSITE_VALUE [simp]
declare DestInt_COMPOSITE_VALUE [simp]
declare IsInt_COMPOSITE_VALUE [simp]
declare MkBool_COMPOSITE_VALUE [simp]
declare DestBool_COMPOSITE_VALUE [simp]
declare IsBool_COMPOSITE_VALUE [simp]
declare MkStr_COMPOSITE_VALUE [simp]
declare DestStr_COMPOSITE_VALUE [simp]
declare IsStr_COMPOSITE_VALUE [simp]
declare MkPair_COMPOSITE_VALUE [simp]
declare DestPair_COMPOSITE_VALUE [simp]
declare IsPair_COMPOSITE_VALUE [simp]
declare MkSet_COMPOSITE_VALUE [simp]
declare DestSet_COMPOSITE_VALUE [simp]
declare IsSet_COMPOSITE_VALUE [simp]

subsection {* Locale @{text "COMPOSITE_VALUE"} *}

locale COMPOSITE_VALUE =
  VALUE "lift_type_rel_composite basic_type_rel"
for basic_type_rel :: "'BASIC_VALUE :: BASIC_SORT \<Rightarrow> 'BASIC_TYPE \<Rightarrow> bool"
begin

subsubsection {* Constructors *}

definition MkInt ::
  "int \<Rightarrow> 'BASIC_VALUE COMPOSITE_VALUE" where
"MkInt = INT_SORT_class.MkInt"

definition MkBool ::
  "bool \<Rightarrow> 'BASIC_VALUE COMPOSITE_VALUE" where
"MkBool = BOOL_SORT_class.MkBool"

definition MkStr ::
  "string \<Rightarrow> 'BASIC_VALUE COMPOSITE_VALUE" where
"MkStr = STRING_SORT_class.MkStr"

definition MkPair ::
  "'BASIC_VALUE COMPOSITE_VALUE \<times>
   'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE" where
"MkPair = PAIR_SORT_class.MkPair"

definition MkSet ::
  "'BASIC_VALUE COMPOSITE_VALUE set \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE" where
"MkSet = SET_SORT_class.MkSet"

subsubsection {* Destructors *}

definition DestInt ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> int" where
"DestInt = INT_SORT_class.DestInt"

definition DestBool ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"DestBool = BOOL_SORT_class.DestBool"

definition DestStr ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> string" where
"DestStr = STRING_SORT_class.DestStr"

definition DestPair ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
  ('BASIC_VALUE COMPOSITE_VALUE \<times>
   'BASIC_VALUE COMPOSITE_VALUE)" where
"DestPair = PAIR_SORT_class.DestPair"

definition DestSet ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow>
   'BASIC_VALUE COMPOSITE_VALUE set" where
"DestSet = SET_SORT_class.DestSet"

subsubsection {* Tests *}

definition IsInt ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsInt = INT_SORT_class.IsInt"

definition IsBool ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsBool = BOOL_SORT_class.IsBool"

definition IsStr ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsStr = STRING_SORT_class.IsStr"

definition IsPair ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsPair = PAIR_SORT_class.IsPair"

definition IsSet ::
  "'BASIC_VALUE COMPOSITE_VALUE \<Rightarrow> bool" where
"IsSet = SET_SORT_class.IsSet"

subsubsection {* Default Simplifications *}

declare MkInt_def [simp]
declare MkBool_def [simp]
declare MkStr_def [simp]
declare MkPair_def [simp]
declare MkSet_def [simp]

declare DestInt_def [simp]
declare DestBool_def [simp]
declare DestStr_def [simp]
declare DestPair_def [simp]
declare DestSet_def [simp]

declare IsInt_def [simp]
declare IsBool_def [simp]
declare IsStr_def [simp]
declare IsPair_def [simp]
declare IsSet_def [simp]
end

subsection {* Theorems *}

theorem lift_type_rel_composite_VALUE [intro!] :
"\<lbrakk>VALUE basic_type_rel\<rbrakk> \<Longrightarrow>
 VALUE (lift_type_rel_composite basic_type_rel)"
apply (simp add: VALUE_def)
apply (clarify)
apply (induct_tac t)
apply (drule_tac x = "BASIC_TYPE" in spec)
apply (safe)
apply (rule_tac x = "BasicVal x" in exI)
apply (simp)
apply (rule_tac x = "PairVal x xa" in exI)
apply (auto)
apply (rule_tac x = "EncSetVal {}" in exI)
apply (auto)
done

text {* The following theorem facilitates locale instantiation. *}

theorem VALUE_COMPOSITE_VALUE_inst [intro!, simp] :
"\<lbrakk>VALUE type_rel\<rbrakk> \<Longrightarrow> COMPOSITE_VALUE type_rel"
apply (simp add: COMPOSITE_VALUE_def)
apply (auto)
done
end