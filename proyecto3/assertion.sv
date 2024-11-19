`define DUV_PATH top_hdl.u_dut

module assertions();
  
  // Sync CLK
  property sync_clock_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.sdr_init_done)
    `DUV_PATH.wb_clk_i == 1'b1;
  endproperty
  
  property reset_duration_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    `DUV_PATH.wb_rst_i |-> ##1 `DUV_PATH.wb_rst_i;
  endproperty
  
  // While on RST
  property on_reset_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (`DUV_PATH.wb_rst_i == 1'b1) |-> (`DUV_PATH.wb_stb_i == 1'b0 && `DUV_PATH.wb_cyc_i == 1'b0);
  endproperty

  // After RST
  property after_reset_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (!`DUV_PATH.wb_rst_i) |-> ##1 (`DUV_PATH.wb_stb_i == 1'b0 && `DUV_PATH.wb_cyc_i == 1'b0);
  endproperty
  
  clk_cycle_a: assert property (sync_clock_p) else $error("Rule1.1: Clock cycle assertion violated");
    
  // Duracion de reset
  reset_duration_a: assert property (reset_duration_p) else $error("Rule3.05: WISHBONE RST signal must be asserted for at least one complete clock cycle");

    
  // Aserción para wb_stb_i y wb_cyc_i después de reset
  after_after_reset_a: assert property (after_reset_behavior_p) else $error("Rule3.20: WISHBONE signals wb_stb_i and wb_cyc_i must remain negated immediately after reset");
  
  // Aserción para wb_stb_i y wb_cyc_i durante reset
  on_reset_behavior_a: assert property (on_reset_behavior_p) else $error("Rule3.21: WISHBONE signals wb_stb_i and wb_cyc_i must remain negated on reset");
  
endmodule
