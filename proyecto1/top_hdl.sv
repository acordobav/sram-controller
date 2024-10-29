parameter P_SYS = 10;     //    200MHz
parameter P_SDR = 20;     //    100MHz


import uvm_pkg::*;

module top_hdl();
  
  logic sdram_clk;
  logic sys_clk;

  initial sys_clk = 0;
  initial sdram_clk = 0;
  
  always #(P_SYS/2) sys_clk = !sys_clk;
  always #(P_SDR/2) sdram_clk = !sdram_clk;

  // to fix the sdram interface timing issue
  wire #(2.0) sdram_clk_d   = sdram_clk;
  
  // Interfaces
  intf_wb intf(sys_clk, sdram_clk);
  
  // DUT connection	
  sdrc_top #(.SDR_DW(32),.SDR_BW(4)) u_dut(
    .cfg_sdr_width(2'b00),
    .cfg_colbits(2'b00), 
    
     // WB bus
    .wb_rst_i(!intf.RESETN),
    .wb_clk_i(intf.sys_clk),
    
    .wb_stb_i(intf.wb_stb_i),
    .wb_ack_o(intf.wb_ack_o),
    .wb_addr_i(intf.wb_addr_i),
    .wb_we_i(intf.wb_we_i),
	.wb_dat_i(intf.wb_dat_i),
	.wb_sel_i(intf.wb_sel_i),
	.wb_dat_o(intf.wb_dat_o),
	.wb_cyc_i(intf.wb_cyc_i),
    .wb_cti_i(intf.wb_cti_i),
    
     /* Interface to SDRAMs */
    .sdram_clk(intf.sdram_clk),
    .sdram_resetn(intf.RESETN),

    .sdr_cs_n(intf.sdr_cs_n),
	.sdr_cke(intf.sdr_cke),
	.sdr_ras_n(intf.sdr_ras_n),
	.sdr_cas_n(intf.sdr_cas_n),
	.sdr_we_n(intf.sdr_we_n),
    
	.sdr_dqm(intf.sdr_dqm),
	.sdr_ba(intf.sdr_ba),
	.sdr_addr(intf.sdr_addr),
    .sdr_dq(intf.sdr_dq),
    
     /* Parameters */  // FROM GIT tb_top.sv line 158 
    .sdr_init_done      (intf.sdr_init_done),
	.cfg_req_depth      (2'h3),//how many req. buffer should hold
	.cfg_sdr_en         (1'b1),
	.cfg_sdr_mode_reg   (13'h033),
	.cfg_sdr_tras_d     (4'h4),
	.cfg_sdr_trp_d      (4'h2),
	.cfg_sdr_trcd_d     (4'h2),
	.cfg_sdr_cas        (3'h3),
	.cfg_sdr_trcar_d    (4'h7),
	.cfg_sdr_twr_d      (4'h1),
	.cfg_sdr_rfsh       (12'h100), // reduced from 12'hC35
	.cfg_sdr_rfmax      (3'h6)
   );

   mt48lc2m32b2 #(.data_bits(32)) u_sdram32 (
      	  .Dq(intf.sdr_dq) ,  
      	  .Addr(intf.sdr_addr[10:0]), 
          .Ba(intf.sdr_ba), 
          .Clk(sdram_clk_d), 
          .Cke(intf.sdr_cke), 
          .Cs_n(intf.sdr_cs_n), 
          .Ras_n(intf.sdr_ras_n), 
          .Cas_n(intf.sdr_cas_n), 
          .We_n(intf.sdr_we_n), 
          .Dqm(intf.sdr_dqm)
    
    );

initial begin
    $display("Inicio!");
    $dumpfile("dump.vcd");
    $dumpvars(1);

    uvm_config_db #(virtual intf_wb)::set(null, "uvm_test_top", "VIRTUAL_INTERFACE", intf);
    
end  

  //Test case
  
//	testcase test(intf);

endmodule
