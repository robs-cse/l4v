(*
 * Copyright 2018, Data61, CSIRO
 *
 * This software may be distributed and modified according to the terms of
 * the GNU General Public License version 2. Note that NO WARRANTY is provided.
 * See "LICENSE_GPLv2.txt" for details.
 *
 * @TAG(DATA61_GPL)
 *)

chapter "An Initial Kernel State"

theory Init_A
imports "../Retype_A"
begin

context Arch begin global_naming RISCV64_A

text \<open>
  This is not a specification of true kernel initialisation. This theory describes a dummy
  initial state only, to show that the invariants and refinement relation are consistent.
\<close>

(* Some address sufficiently aligned address for one page *)
definition riscv_global_pt_ptr :: obj_ref
  where
  "riscv_global_pt_ptr = pptr_base + 0x2000"

(* Sufficiently aligned for irq type + cte_level_bits *)
definition init_irq_node_ptr :: obj_ref
  where
  "init_irq_node_ptr = pptr_base + 0x3000"

(* The highest user-level virtual address that is still canonical.
   It can be larger than user_vtop, which is the highest address we allow to be mapped.
   We need canonical_user, because the page tables have to have valid mappings there. *)
definition canonical_user :: "vspace_ref" where
  "canonical_user \<equiv> mask canonical_bit"

definition init_vspace_uses :: "vspace_ref \<Rightarrow> riscvvspace_region_use"
  where
  "init_vspace_uses p \<equiv>
     if p \<in> {pptr_base ..< kernel_base} then RISCVVSpaceKernelWindow
     else if kernel_base \<le> p then RISCVVSpaceKernelELFWindow
     else if p \<le> canonical_user then RISCVVSpaceUserRegion
     else RISCVVSpaceInvalidRegion"

definition init_arch_state :: arch_state
  where
  "init_arch_state \<equiv> \<lparr>
     riscv_asid_table = Map.empty,
     riscv_global_pts = (\<lambda>level. if level = max_pt_level then {riscv_global_pt_ptr} else {}),
     riscv_kernel_vspace = init_vspace_uses
   \<rparr>"

definition init_global_pt :: kernel_object
  where
  "init_global_pt \<equiv> ArchObj $ PageTable (\<lambda>_. InvalidPTE)"

definition init_kheap :: kheap
  where
  "init_kheap \<equiv>
    (\<lambda>x. if \<exists>irq :: irq. init_irq_node_ptr + (ucast irq << cte_level_bits) = x
           then Some (CNode 0 (empty_cnode 0))
           else None)
    (idle_thread_ptr \<mapsto>
       TCB \<lparr>
         tcb_ctable = NullCap,
         tcb_vtable = NullCap,
         tcb_reply = NullCap,
         tcb_caller = NullCap,
         tcb_ipcframe = NullCap,
         tcb_state = IdleThreadState,
         tcb_fault_handler = replicate word_bits False,
         tcb_ipc_buffer = 0,
         tcb_fault = None,
         tcb_bound_notification = None,
         tcb_mcpriority = minBound,
         tcb_arch = init_arch_tcb
         \<rparr>,
      riscv_global_pt_ptr \<mapsto> init_global_pt
    )"

definition init_cdt :: cdt
  where
  "init_cdt \<equiv> Map.empty"

definition init_ioc :: "cslot_ptr \<Rightarrow> bool"
  where
  "init_ioc \<equiv>
   \<lambda>(a,b). (\<exists>obj. init_kheap a = Some obj \<and>
                  (\<exists>cap. cap_of obj b = Some cap \<and> cap \<noteq> cap.NullCap))"

definition init_A_st :: "'z::state_ext state"
  where
  "init_A_st \<equiv> \<lparr>
    kheap = init_kheap,
    cdt = init_cdt,
    is_original_cap = init_ioc,
    cur_thread = idle_thread_ptr,
    idle_thread = idle_thread_ptr,
    machine_state = init_machine_state,
    interrupt_irq_node = \<lambda>irq. init_irq_node_ptr + (ucast irq << cte_level_bits),
    interrupt_states = \<lambda>_. IRQInactive,
    arch_state = init_arch_state,
    exst = ext_init
  \<rparr>"

end
end
