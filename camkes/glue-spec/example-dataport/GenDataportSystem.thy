(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 *
 * SPDX-License-Identifier: GPL-2.0-only
 *)
(*<*)
(* THIS FILE IS AUTOMATICALLY GENERATED. YOUR EDITS WILL BE OVERWRITTEN. *)
theory GenDataportSystem
imports UserDataport
begin
(*>*)

subsection \<open>\label{ssec:dataportsys}Generated System Theory\<close>

subsubsection \<open>\label{sssec:dataportsystypes}Types\<close>
text \<open>
  At the system level we have the now familiar generated types.
\<close>

type_synonym component = "(channel, component_state) comp"

type_synonym lstate = "component_state local_state"

type_synonym gstate = "(inst, channel, component_state) global_state"

subsubsection \<open>\label{sssec:dataportsysuntrusted}Untrusted Components\<close>
text \<open>
  A definition is generated for the untrusted execution of the component,
  @{term DataportTest}. In this definition there are two interfaces the
  component can send and receive on, but the other details of the definition
  are identical to the previous examples.
\<close>

definition
  DataportTest_untrusted :: "(DataportTest_channel \<Rightarrow> channel) \<Rightarrow> component"
where
  "DataportTest_untrusted ch \<equiv>
    LOOP (
      UserStep
    \<squnion> ArbitraryRequest (ch DataportTest_d2)
    \<squnion> ArbitraryResponse (ch DataportTest_d2)
    \<squnion> ArbitraryRequest (ch DataportTest_d1)
    \<squnion> ArbitraryResponse (ch DataportTest_d1))"

subsubsection \<open>\label{sssec:dataportsysinst}Component Instances\<close>
text \<open>
  The definitions for untrusted execution of the two component instances are
  generated by partially applying the untrusted definition of
  @{term DataportTest} with different functions mapping its interfaces to
  connections. In this way, two processes are formed that have identical local
  behaviour, but have different effects when they perform communication
  actions.
\<close>

definition
  comp2_untrusted :: component
where
  "comp2_untrusted \<equiv>
    DataportTest_untrusted (\<lambda>c. case c of DataportTest_d1 \<Rightarrow> simple2
                                        | DataportTest_d2 \<Rightarrow> simple1)"

definition
  comp1_untrusted :: component
where
  "comp1_untrusted \<equiv>
    DataportTest_untrusted (\<lambda>c. case c of DataportTest_d2 \<Rightarrow> simple2
                                        | DataportTest_d1 \<Rightarrow> simple1)"

subsubsection \<open>\label{ssecdataportsysmem}Shared Memory Components\<close>
text \<open>
  A component instance is generated for each connection involving a dataport,
  as mentioned previously. As for events, the user is given no opportunity to
  provide trusted definitions for these instances because we can automatically
  generate their precise behaviour without ambiguity.
\<close>

definition
  simple2\<^sub>d_instance :: component
where
  "simple2\<^sub>d_instance \<equiv> Buf\<^sub>d (\<lambda>_. simple2)"

definition
  simple1\<^sub>d_instance :: component
where
  "simple1\<^sub>d_instance \<equiv> Buf\<^sub>d (\<lambda>_. simple1)"

subsubsection \<open>\label{sssec:dataportsysgs}Initial State\<close>
text \<open>
  The initial state for this system includes cases for the introduced shared
  memory components, using the definitions presented above. Both begin in the
  common initial memory state containing the empty map.
\<close>

definition
  gs\<^sub>0 :: gstate
where
  "gs\<^sub>0 p \<equiv> case trusted p of Some s \<Rightarrow> Some s | _ \<Rightarrow>
  (case p of comp2 \<Rightarrow> Some (comp2_untrusted, Component init_component_state)
           | comp1 \<Rightarrow> Some (comp1_untrusted, Component init_component_state)
           | simple2\<^sub>d \<Rightarrow> Some (simple2\<^sub>d_instance, init_memory_state)
           | simple1\<^sub>d \<Rightarrow> Some (simple1\<^sub>d_instance, init_memory_state))"

(*<*)
end
(*>*)
