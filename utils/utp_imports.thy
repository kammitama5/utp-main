(******************************************************************************)
(* Project: The Isabelle/UTP Proof System                                     *)
(* File: utp.thy                                                              *)
(* Authors: Simon Foster and Frank Zeyda (University of York, UK)             *)
(* Emails: simon.foster@york.ac.uk and frank.zeyda@york.ac.uk                 *)
(******************************************************************************)

section {* Meta-theory for Library Imports *}

theory utp_imports
imports
  "~~/src/HOL/Eisbach/Eisbach"
  "~~/src/Tools/Adhoc_Overloading"
  "~~/src/HOL/Library/Char_ord"
  "~~/src/HOL/Library/Countable_Set"
  "~~/src/HOL/Library/FSet"
  "~~/src/HOL/Library/Monad_Syntax"
  "~~/src/HOL/Library/Prefix_Order"
  "~~/src/HOL/Library/Sublist"
  "../lenses/Lenses"
  "Library_extra/FSet_extra"
  "Library_extra/List_extra"
  "Library_extra/List_lexord_alt"
  "Library_extra/Monoid_extra"
  "Library_extra/Pfun"
  "Library_extra/Ffun"
  Profiling
  TotalRecall
begin end