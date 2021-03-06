section {* Fuel Pump in UTP CSP *}

theory utp_csp_pump
  imports "../theories/circus/utp_circus"
begin

alphabet st_pump =
  fuelQ :: "nat"

datatype ch_pump =
  init | liftNozzle | putNozzle | pressTrigger | releaseTrigger | enterAmount nat | reload nat

type_synonym op_pump = "st_pump hrel_des"
type_synonym act_pump = "(st_pump, ch_pump) action"

definition PInit :: "act_pump" where
[rdes_def]: "PInit = (fuelQ :=\<^sub>C 5000)"

definition Reload :: "nat \<Rightarrow> act_pump" where
[rdes_def]: "Reload(q) = fuelQ :=\<^sub>C (&fuelQ + \<guillemotleft>q\<guillemotright>)"

definition Supply :: "nat \<Rightarrow> act_pump" where
[rdes_def]: "Supply(q) = fuelQ :=\<^sub>C (&fuelQ - \<guillemotleft>q\<guillemotright>)"

definition PumpActive :: "act_pump" where
[rdes_def]: "PumpActive = putNozzle \<^bold>\<rightarrow> Skip \<box>
                           enterAmount?(q) \<^bold>\<rightarrow> pressTrigger \<^bold>\<rightarrow> Supply(q) ;; releaseTrigger \<^bold>\<rightarrow> Skip"

definition PumpIdle :: "act_pump" where
[rdes_def]: "PumpIdle = liftNozzle \<^bold>\<rightarrow> PumpActive \<box>
                         reload?(q) \<^bold>\<rightarrow> Reload(q) \<box>
                         init \<^bold>\<rightarrow> PInit"

definition Pump :: "act_pump" where
[rdes_def]: "Pump = init \<^bold>\<rightarrow> PInit ;; (while\<^sub>R true do PumpIdle od)"

end
