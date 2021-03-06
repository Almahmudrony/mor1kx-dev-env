/* 
   Debug interface stimulus for the mor1kx processor.
   This is the verilog stimulus to match the processor software
   for the test called mor1kx-debugtest
 
   Julius Baxter, julius@opencores.org
 
 */

`include "mor1kx-sprs.v"

module mor1kx_debug_test_stim;

   reg [31:0] spr_dat, saved_npc;

   // Include the debug utility functions to control the mohor debug unit
   
`define TB_TOP orpsoc_testbench
`define DBG_CTRL `TB_TOP.mohor_debug_control
   `include "mor1kx_mohor_debug_tasks.v"
      
   initial begin
      /* Wait some before beginning - let the processor start up */
      #100_000;
      /* Stall the processor */
      reset_everything();
      stall_proc();

      /* read an spr */
      read_spr(`OR1K_SPR_SR_ADDR, spr_dat);
      $display("SPR SR: %08h", spr_dat);

      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      single_step();
      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      single_step();
      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      single_step();
      
      
      //unstall_proc();

      // Now try single stepping the processor through a "l.j 0" instruction
      write_mem_32(32'h10, 32'd0);
      write_mem_32(32'h14, 32'h14000000);

      // Flush the instruction cache for these addresses
      write_spr(`OR1K_SPR_ICBIR_ADDR, 32'h10);

      // Set the PC to 0x10
      read_npc(saved_npc);
      write_npc(32'h10);
      single_step();
      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      single_step();
      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      single_step();
      read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
      unstall_proc();
      #1000;
      stall_proc();

      // Continue on as we were
      write_npc(saved_npc);
      
      /* should finish the sim */
      write_mem_32(32'd4, 32'h8000000d);

      while (1) begin
	 read_npc(spr_dat); $display("NPC is: %08h", spr_dat);
	 single_step();
      end

      
     end

endmodule
   
