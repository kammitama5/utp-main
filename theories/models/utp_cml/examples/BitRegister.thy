(******************************************************************************)
(* Project: CML model for Isabelle/UTP                                        *)
(* File: BitRegister.thy                                                      *)
(* Author: Simon Foster, University of York (UK)                              *)
(******************************************************************************)

header {* CML Dwarf Signal Example *}

(*<*)
theory BitRegister
imports 
  "../utp_cml"
begin
(*>*)

text {* The ``bit-register'' is a simple process which performs
arithmetic calculations on a byte state variable. It detects overflow
and underflow if and when it occurs and informs the user. A byte is
represented as a integer with the invariant that the value must be
between 0 and 255. *}

abbreviation 
  "Byte \<equiv> \<parallel>@int inv n == (^n^ >= 0) and (^n^ <= 255)\<parallel>"

text {* The bit-register has two functions: \texttt{oflow} for
detecting overflow caused by a summation, and \texttt{uflow} for
detecting overflow caused by a substraction. Both take a pair of
integers and return a boolean if over/underflow occurs. Functions 
in CML are desugared to lambda terms . *}

definition 
  "oflow = |lambda d @ (^d^.#1 + ^d^.#2) > 255|"

definition 
  "uflow = |lambda d @ (^d^.#1 - ^d^.#2) < 0|"

text {* Next we declare the channels for the bit-register, of which
there are seven. \texttt{init} is used to signal that the bit-register
should initialise. \texttt{overflow} and \texttt{underflow} are used
to communicate errors during a calculation. \texttt{read} and
\texttt{load} are used to read the contents of the state and write a
new values, respectively. \texttt{add} and \texttt{sub} are used to
signal an addition or subtraction should be executed. *}

definition "init = MkChanD ''init'' \<parallel>()\<parallel>"
definition "overflow = MkChanD ''overflow'' \<parallel>()\<parallel>"
definition "underflow = MkChanD ''underflow'' \<parallel>()\<parallel>"
definition "read = MkChanD ''read'' \<parallel>@Byte\<parallel>"
definition "load = MkChanD ''load'' \<parallel>@Byte\<parallel>"
definition "add = MkChanD ''add'' \<parallel>@Byte\<parallel>"
definition "sub = MkChanD ''add'' \<parallel>@Byte\<parallel>"

text {* We use an Isabelle locale to create a new namespace for the
\texttt{RegisterProc}. *}

locale RegisterProc
begin

text {* This single state variable, \texttt{reg}, holds the current
value of the calculation. *}

abbreviation "reg \<equiv> MkVarD ''reg'' \<parallel>@Byte\<parallel>"

text {* Now we declare the operations of the
bit-register. \texttt{INIT} initialises the state variables to 0. *}

definition "INIT = 
  `true \<turnstile> (reg := 0)`"

text {* \texttt{LOAD} sets the register to a particular value. *}

definition "LOAD(i) =
  `true \<turnstile> (reg := ^i^)`"

(* Can't implement the READ operation -- what is the semantics of return? *)

text {* \texttt{ADD} adds the given value to the register, under the
assumption that a overflow will not occur. *}

definition "ADD(i) =
  `\<lparr> not oflow($reg, ^i^) \<rparr> \<turnstile> reg := $reg + ^i^`"

text {* \texttt{ADD} subtracts the given value from the register,
under the assumption that a underflow will not occur. *}

definition "SUBTR(i) =
  `\<lparr> not uflow($reg, ^i^) \<rparr> \<turnstile> reg := ($reg - ^i^)`"

text {* Then we create the actual \texttt{REG} process. It can be
thought of as a calculator which waits for particular buttons to be
pressed, and suitably responds. If a \texttt{load} message is
received, the value input is loaded into the the register. If a
\texttt{read} is requested then the current value of the register is
sent. If an \texttt{add} or \texttt{subtract} is request, a guarded
action is performed. If the calculation would cause an overflow or
underflow, the message \texttt{overflow} or \texttt{underflow} is
communicated and the current state is reset. Otherwise the calculation
is carried out and the state updated. *}

definition "REG =
  `\<mu> REG. ((load?(i) -> LOAD(&i)) ; REG)
          [] (read!($reg) -> REG)
          [] (add?(i) -> 
             (  ([\<lparr>oflow($reg, ^i^)\<rparr>] & (overflow -> (INIT() ; REG))) 
             [] ([\<lparr>not oflow($reg, ^i^)\<rparr>] & (ADD(^i^) ; REG))))
          [] (sub?(i) -> 
             (  ([\<lparr>uflow($reg, ^i^)\<rparr>] & (underflow -> (INIT() ; REG))) 
             [] ([\<lparr>not uflow($reg, ^i^)\<rparr>] & (SUBTR(^i^) ; REG))))`"

text {* Finally we have the main action of the process, which waits
for an \texttt{init} signal, and then initialises the register and
begins the recursive behaviour described by \texttt{REG}. *}

definition
  "MainAction = `init -> (INIT() ; REG)`"

(*<*)
end

end
(*>*)