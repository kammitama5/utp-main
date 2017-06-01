section {* Terminated lists *}

theory Terminated_lists
imports
  Main
  Monoid_extra
begin

text {* Finite terminated lists are lists where the Nil element 
        can record some information.*}

subsection {* Generic terminated lists datatype *}

datatype ('\<alpha>,'\<theta>) gtlist = Nil "'\<alpha>" ("[;;(_)]") | Cons "'\<theta>" "('\<alpha>,'\<theta>) gtlist" (infixr "#\<^sub>g\<^sub>t" 65) 
  
syntax
  "_gtlist"     :: "args \<Rightarrow> 'a \<Rightarrow> ('\<alpha>,'\<theta>) gtlist"    ("[(_);;(_)]")

translations
  "[x,xs;;y]" == "(x#\<^sub>g\<^sub>t[xs;;y])"
  "[x;;y]" == "x#\<^sub>g\<^sub>t[;;y]"
  
value "[a,b,c;;e]"
value "[;;e]"
  
text {* If we take '\<alpha> to be the unit type, then we have a traditional
        list where the Nil element does not record anything else. *}

type_synonym '\<theta> unit_ttlist1 = "(unit,'\<theta>) gtlist"
  
primrec ttlist1_list2list :: "'\<theta> unit_ttlist1 \<Rightarrow> '\<theta> list" where
"ttlist1_list2list (Nil s) = []" |
"ttlist1_list2list (Cons x xs) = x#(ttlist1_list2list xs)"

primrec list2ttlist1_list :: "'\<theta> list \<Rightarrow> '\<theta> unit_ttlist1" where
"list2ttlist1_list [] = (Nil ())" |
"list2ttlist1_list (x#xs) = (Cons x (list2ttlist1_list xs))"

lemma "list2ttlist1_list (ttlist1_list2list sl) = sl"
  by (induct sl, auto)
  
lemma "ttlist1_list2list (list2ttlist1_list sl) = sl"
  by (induct sl, auto)
    
text {* If we wanted to show that given a plus operator between
        '\<alpha> => '\<theta> yielding '\<theta>, we would need some kind of locale
        here, and would need a function ('\<alpha> => '\<theta> => '\<theta>) to be
        able to define plus in a generic way. *}

subsection {* Standard terminated lists *}
  
datatype '\<alpha> stlist = Nil "'\<alpha>" ("[;(_)]") | Cons "'\<alpha>" "'\<alpha> stlist" (infixr "#\<^sub>t" 65)  
  
syntax
  "_stlist"     :: "args \<Rightarrow> 'a \<Rightarrow> '\<alpha> stlist"    ("[(_); (_)]")

translations
  "[x,xs;y]" == "(x#\<^sub>t[xs;y])"
  "[x;y]" == "x#\<^sub>t[;y]"

value "[a,b,c;e]"
value "[;e]"
  
text {* We can then show that a list is a special
        case of this structure by defining a pair of functions. *}

primrec stlist2list :: "'\<theta> stlist \<Rightarrow> '\<theta> list" where
"stlist2list [;s] = []" |
"stlist2list (x#\<^sub>txs) = x#(stlist2list xs)"  

primrec list2stlist :: "'\<theta> \<Rightarrow> '\<theta> list \<Rightarrow> '\<theta> stlist" where
"list2stlist a [] = [;a]" |
"list2stlist a (x#xs) = (Cons x (list2stlist a xs))"
  
lemma "stlist2list (list2stlist z sl) = sl"
  by (induct sl, auto)

text {* And given a stlist with a predefined zero representation,
        we get the same back. *}
    
lemma "list2stlist z (stlist2list (sl#\<^sub>t[;z])) = (sl#\<^sub>t[;z])"
  by (auto)
  
primrec seq2_Nlist2list :: "'\<theta> stlist \<Rightarrow> '\<theta> list" where
"seq2_Nlist2list [;s] = [s]" |
"seq2_Nlist2list (x#\<^sub>txs) = x#(seq2_Nlist2list xs)"

primrec Nlist2seq2_list :: "'\<theta> list \<Rightarrow> '\<theta> stlist" where
"Nlist2seq2_list [] = [;undefined]" |
"Nlist2seq2_list (x#xs) = (if xs = [] then [;x] else (x#\<^sub>t(Nlist2seq2_list xs)))"

lemma "Nlist2seq2_list (seq2_Nlist2list sl) = sl"
  apply (induct sl)
  by (auto)
  
lemma 
  assumes "length sl > 0" 
  shows "seq2_Nlist2list (Nlist2seq2_list sl) = sl"
  using assms
  apply (induct sl)
  by auto
    
subsection {* Auxiliary induction rules *}
  
lemma stlist_induct_cons: 
  "\<lbrakk>
   \<And>a b.  P [;a] [;b];
   \<And>a x xs. P (x#\<^sub>txs) [;a] ;
   \<And>a y ys. P [;a] (y#\<^sub>tys);
   \<And>x xs y ys. P xs ys  \<Longrightarrow> P (x#\<^sub>txs) (y#\<^sub>tys) \<rbrakk>
 \<Longrightarrow> P xs ys"
  apply (induct xs arbitrary: ys)
  apply auto
  apply (case_tac "xa")
  apply auto
  apply (case_tac "x")
  by auto

subsection {* Operators *}
  
text {* We define a concatenation operator (plus) based on the plus of the
        parametrised type being used. *}  
  
fun concat_stlist :: "('a::plus) stlist \<Rightarrow> ('a::plus) stlist \<Rightarrow> ('a::plus) stlist" (infixl "@\<^sub>t" 66)
where
"[;z] @\<^sub>t [;x] = [;z+x]" |
"[;z] @\<^sub>t (x#\<^sub>txs) = (z+x)#\<^sub>txs" |
"(x#\<^sub>txs) @\<^sub>t zs = x#\<^sub>t(xs@\<^sub>tzs)"

text {* We define a last function *}
  
primrec last :: "'a stlist \<Rightarrow> 'a" where
"last [;x] = x" |
"last (x#\<^sub>txs) = last xs"

subsection {* Classes *}

subsubsection {* Plus *}  
  
text {* We now instantiate the plus operator for the stlist type. *}
  
instantiation stlist :: (plus) plus
begin

  definition plus_stlist :: "'a stlist \<Rightarrow> 'a stlist \<Rightarrow> 'a stlist"
    where "plus_stlist == concat_stlist"
  
  instance by (intro_classes)
end
  
lemma stlist_nil_concat_cons:
  shows "[;a] + (xs#\<^sub>tys) = (a + xs)#\<^sub>tys" 
  by (simp add:plus_stlist_def)

lemma stlist_not_cons: "d \<noteq> x#\<^sub>td"
  by (metis add_cancel_left_right lessI less_imp_not_eq2 stlist.size(4))
    
lemma stlist_concat_not_eq: "(b#\<^sub>t[;d])+a \<noteq> [;c]+a"
  unfolding plus_stlist_def
  apply (induct a rule:stlist.induct)
  apply simp_all
  by (metis stlist_not_cons)
    
lemma stlist_concat_not_eq2: "(b#\<^sub>t[d;e])+a \<noteq> [;c]+a"
  unfolding plus_stlist_def
  apply (induct a rule:stlist.induct)
  apply simp_all
  by (metis add_le_same_cancel1 le_add lessI not_less stlist.size(4))
    
lemma stlist_concat_noteq: "x1a #\<^sub>t x2 \<noteq> x2"
  apply (induct x2)
  by auto
    
lemma stlist_concat_noteq2: "(b #\<^sub>t x2) + a \<noteq> (b #\<^sub>t x1a #\<^sub>t x2) + a"
  by (simp add: plus_stlist_def stlist_not_cons)
    
lemma stlist_last_concat:
  fixes s z :: "'a::plus stlist"
  shows "last (s + (x#\<^sub>tz)) = last z"
  unfolding plus_stlist_def
  apply (induct s)
  by auto
    
lemma stlist_last_concat2:
  fixes s :: "'a::plus stlist"
  shows "last (x#\<^sub>t(s + [;z])) = last s + z"
  unfolding plus_stlist_def
  apply (induct s)
  by auto
    
lemma stlist_last_concat3:
  fixes s :: "'a::plus stlist"
  shows "last ((x#\<^sub>ts) + [;z]) = last s + z"
  unfolding plus_stlist_def
  apply (induct s)
  by auto    
    
subsubsection {* Additive monoid *}
  
text {* Given a monoid_add class we also have a monoid_add. On top of
        plus we define the zero as the parametrised type zero. *}
  
instantiation stlist :: (monoid_add) monoid_add
begin
  
  definition zero_stlist :: "'a stlist" where "zero_stlist = [;0]" 
  
subsubsection {* Lemmas on monoid_add with stlist *}
    
lemma stlist_concat_zero_left[simp]: 
  fixes y::"'a stlist"
  shows "[;0] + y = y"
  unfolding plus_stlist_def
  by (induct y, auto)
    
lemma stlist_concat_zero_right[simp]: 
  fixes y::"'a stlist"
  shows "y + [;0] = y"
  unfolding plus_stlist_def
  by (induct y, auto)
    
lemma plus_seq_assoc: 
  fixes xs ys zs::"'a stlist"
  shows "(xs + ys) + zs = xs + (ys + zs)"
  unfolding plus_stlist_def
  apply (induct xs)
  apply (induct ys)
  apply (induct zs)
  apply auto
  apply (simp add: add.assoc)
  by (simp add:add.semigroup_axioms semigroup.assoc)
    
instance
  apply (intro_classes)
  by (auto simp:plus_seq_assoc zero_stlist_def)
  
end

text {* Given an additive monoid type, we can define a front function
        that yields front(s) + last(s) for a given stlist s *}
    
primrec front :: "'a::monoid_add stlist \<Rightarrow> 'a stlist" where
"front [;x] = 0" |
"front (x#\<^sub>txs) = (x#\<^sub>tfront xs)"

value "front [a;b]"

lemma stlist_front_concat_last: "s = front(s) + [;last(s)]"
  unfolding plus_stlist_def
  apply (induct s)
  apply auto
  by (simp add: zero_stlist_def)
    
subsubsection {* Orders *}
  
text {* We now instantiate the ord class for the stlist type. *}
  
instantiation stlist :: (monoid_add) ord
begin
  definition less_eq_stlist :: "'a stlist \<Rightarrow> 'a stlist \<Rightarrow> bool" where "less_eq_stlist == monoid_le"
  definition less_stlist :: "'a stlist \<Rightarrow> 'a stlist \<Rightarrow> bool" where "less_stlist x y == x \<le> y \<and> \<not> (y \<le> x)"

  instance by (intro_classes)
end
  
subsubsection {* Cancelative monoid *}
  
text {* We now instantiate the cancel_monoid class for the stlist type. *}

instantiation stlist :: (cancel_monoid) cancel_monoid
begin
  
lemma stlist_plus_follow_concat:
  fixes a c :: "'a stlist"
  shows "a + (b #\<^sub>t c) = a + [b;0] + c"
  by (metis concat_stlist.simps(3) plus_seq_assoc plus_stlist_def stlist_concat_zero_left)
  
(* right *)

lemma stlist_right_cancel_monoid0:
  fixes b c :: "'a stlist"
  shows "(b + [;a] = c + [;a]) \<Longrightarrow> b = c"
  unfolding plus_stlist_def
  apply (induct b c rule:stlist_induct_cons, auto)
  using right_cancel_monoid_class.add_right_imp_eq by blast
    
lemma stlist_right_cancel_monoid1:
  fixes b c :: "'a stlist"
  shows "(b + [a;d] = c + [a;d]) \<Longrightarrow> b = c"
  unfolding plus_stlist_def
  apply (induct b c rule:stlist_induct_cons, auto)
  using right_cancel_monoid_class.add_right_imp_eq apply blast
  apply (case_tac "xs", simp+)
  by (case_tac "ys", simp+)
    
lemma stlist_right_cancel_monoid2:
  fixes b c :: "'a"
  shows "(b#\<^sub>ta) = (c#\<^sub>ta) \<Longrightarrow> b = c"  
  by auto
    
lemma stlist_right_cancel_monoid:
  fixes b c :: "'a stlist"
  shows "b+a = c+a \<Longrightarrow> b = c"
  apply (induct a arbitrary: b c rule:stlist.induct)
  using stlist_right_cancel_monoid0 apply blast 
  by (metis (no_types, lifting) add.assoc concat_stlist.simps(3) plus_stlist_def stlist_concat_zero_left stlist_right_cancel_monoid1 zero_stlist_def)

(* left *)

lemma stlist_left_zero_cancel:
  fixes a :: "'a stlist"
  shows "a + [;b] = a + [;c] \<Longrightarrow> [;b] = [;c]"
  unfolding plus_stlist_def
  apply (induct a)
  apply auto
  using left_cancel_monoid_class.add_left_imp_eq by blast
   
lemma stlist_left_cancel_monoid0:
  fixes b c :: "'a stlist"
  shows "[;a] + b = [;a] + c \<Longrightarrow> b = c"
  unfolding plus_stlist_def
  apply (induct rule:stlist_induct_cons)
  apply auto
  using left_cancel_monoid_class.add_left_imp_eq by blast+
    
lemma stlist_left_cancel_monoid:
  fixes a b c :: "'a stlist"
  shows "a + b = a + c \<Longrightarrow> b = c"
  apply (induct a rule:stlist.induct)
  using Terminated_lists.stlist_left_cancel_monoid0 apply blast
  by (simp add: plus_stlist_def)

lemma stlist_zero_monoid_sum:
  fixes a :: "'a stlist"
  shows "a + b = 0 \<Longrightarrow> a = 0"
  apply (induct a b rule:stlist_induct_cons)
  by (simp add: plus_stlist_def zero_stlist_def zero_sum_left)+ 
    
instance
  apply (intro_classes)
  using stlist_left_cancel_monoid  stlist_zero_monoid_sum stlist_right_cancel_monoid by blast+
end

subsubsection {* Difference *}
  
instantiation stlist :: (monoid_add) minus
begin
  definition minus_stlist :: "'a stlist \<Rightarrow> 'a stlist \<Rightarrow> 'a stlist" where "minus_stlist == monoid_subtract"
  
  instance by intro_classes
end
  
subsubsection {* Pre_trace *}
  
instantiation stlist :: (pre_trace) pre_trace
begin
  
instance by (intro_classes, simp_all add: less_eq_stlist_def less_stlist_def minus_stlist_def)
end

lemma monoid_le_stlist2:
  "(xs :: 'a::monoid_add stlist) \<le>\<^sub>m ys \<longleftrightarrow> xs \<le> ys"
  by (simp add: less_eq_stlist_def)
    
lemma stlist_eq_nil:
  fixes a b :: "'a::pre_trace"
  shows "a = b \<longleftrightarrow> [;a] = [;b]"
  by simp
  
lemma monoid_plus_prefix_iff_zero:
  fixes a b :: "'a::pre_trace"
  shows "a + x \<le> a \<longleftrightarrow> x = 0"
  by (metis add.right_neutral antisym le_add left_cancel_monoid_class.add_left_imp_eq)
    
lemma stlist_le_nil_imp_le_elements:
  fixes a b :: "'a::pre_trace"
  shows "[;a] \<le> [;b] \<Longrightarrow> a \<le> b"
  apply (simp add: less_eq_stlist_def monoid_le_def)
  apply auto
  apply (case_tac c)
  apply auto
  apply (simp add: plus_stlist_def)
  by (simp add: stlist_nil_concat_cons)
    
lemma stlist_le_nil_iff_le_elements:
  fixes a b :: "'a::pre_trace"
  shows "[;a] \<le> [;b] \<longleftrightarrow> a \<le> b"
  by (metis concat_stlist.simps(1) pre_trace_class.le_iff_add plus_stlist_def stlist_le_nil_imp_le_elements)
    
lemma stlist_plus_nils:
  fixes a b :: "'a::pre_trace"
  shows "a + b = c \<longleftrightarrow> [;a] + [;b] = [;c]"
  by (simp add: plus_stlist_def)      
    
lemma stlist_nil_minus:
  fixes a b :: "'a::pre_trace"
  shows "[;a] - [;b] = [;a-b]"
  apply (case_tac "b \<le> a")
  apply auto
  apply (metis add_monoid_diff_cancel_left concat_stlist.simps(1) diff_add_cancel_left' minus_stlist_def plus_stlist_def)
  apply (simp add:stlist_le_nil_iff_le_elements)
  by (simp add:zero_stlist_def)
        
lemma stlist_nil_le_cons_imp_le:
  fixes xs :: "'a::pre_trace stlist"
  shows "[;a] \<le> (x#\<^sub>txs) \<Longrightarrow> a \<le> x"
  apply (simp add:le_is_monoid_le monoid_le_def)
  apply auto
  apply (case_tac c)
  apply (simp add: plus_stlist_def)
  by (metis stlist.inject(2) stlist_nil_concat_cons)

lemma stlist_cons_minus_nil_eq:
  fixes xs :: "'a::pre_trace stlist"
  assumes "[;a] \<le> (x#\<^sub>txs)"
  shows "(x#\<^sub>txs) - [;a] = (x-a)#\<^sub>txs" 
  using assms
  apply (simp add:minus_stlist_def minus_def le_is_monoid_le)
  by (smt Terminated_lists.last.simps(1) add.assoc add.right_neutral assms concat_stlist.simps(2) diff_add_cancel_left' front.simps(1) left_cancel_monoid_class.add_left_imp_eq minus_def stlist_front_concat_last stlist_nil_concat_cons stlist_nil_le_cons_imp_le stlist_plus_follow_concat zero_stlist_def)
  
instantiation stlist :: (trace) trace
begin
  
lemma stlist_le_sum_cases:
fixes a :: "'a stlist"
shows "a \<le> b + c \<Longrightarrow> a \<le> b \<or> b \<le> a"
  apply (induct a b rule:stlist_induct_cons)
  apply (case_tac c)
  apply (simp add: le_sum_cases plus_stlist_def stlist_le_nil_iff_le_elements)
  apply (metis le_sum_cases stlist_le_nil_iff_le_elements stlist_nil_concat_cons stlist_nil_le_cons_imp_le)
  apply (smt add.assoc add_monoid_diff_cancel_left less_eq_stlist_def minus_stlist_def monoid_le_def stlist_cons_minus_nil_eq stlist_plus_follow_concat stlist_right_cancel_monoid)
  apply (smt add.assoc add_monoid_diff_cancel_left less_eq_stlist_def minus_stlist_def monoid_le_def right_cancel_monoid_class.add_right_imp_eq stlist_cons_minus_nil_eq stlist_plus_follow_concat)
  by (simp add: plus_stlist_def pre_trace_class.le_iff_add)
  
instance by (intro_classes, simp add:stlist_le_sum_cases)
end

(* assorted lemmas below *)
  
lemma stlist_cons_right_prefix:
  fixes a :: "'a::pre_trace"
  shows "[;a] \<le> [a;c]"
proof -
  have "[;a] \<le> [a;c] = ([;a] \<le> [;a] + [0;c])"
    unfolding less_eq_stlist_def monoid_le_def plus_stlist_def by simp
  also have "... = True"
    by simp
      
  finally show ?thesis by simp
qed
  
lemma monoid_le_stlist:
  fixes a :: "'a::pre_trace stlist"
  shows "a \<le> b \<longleftrightarrow> a \<le>\<^sub>m b"
  by (simp add:le_is_monoid_le)

lemma monoid_subtract_stlist: 
  fixes a :: "'a::pre_trace stlist"
  shows "(a - b) = (a -\<^sub>m b)"
  by (simp add:minus_def)  
  
(* this yields the difA of CTA nicely *)    
    
lemma stlist_cons_minus_zero_left:
  fixes a :: "'a::pre_trace"
  shows "[a;c] - [;a] = [0;c]"      
proof -
  have "[a;c] - [;a] = [;a] + [0;c] - [;a]"
    unfolding plus_stlist_def minus_stlist_def monoid_subtract_def by simp
  also have "[;a] + [0;c] - [;a] = [0;c]"
    by simp
      
  finally show ?thesis by simp
qed

end  