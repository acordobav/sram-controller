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
  
  //SDR NOT ENABLED
  property before_SDR_enable_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    (!`DUV_PATH.cfg_sdr_en) |=> (`DUV_PATH.sdr_init_done == 1'b0);
  endproperty
  
  property after_SDR_enable_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    (`DUV_PATH.cfg_sdr_en) |-> ##[1:$] (`DUV_PATH.sdr_init_done == 1'b1);
  endproperty
  
  //WRITE AND READ ASSERTS
  
  property during_write_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (`DUV_PATH.wb_stb_i && `DUV_PATH.wb_cyc_i && `DUV_PATH.wb_we_i) |-> (`DUV_PATH.wb_addr_i != 1'bx && `DUV_PATH.wb_addr_i != 1'bz && `DUV_PATH.wb_dat_i != 1'bx && `DUV_PATH.wb_dat_i != 1'bz);
  endproperty      
        
  property after_write_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (`DUV_PATH.wb_ack_o) |-> ##1 (`DUV_PATH.wb_stb_i == 1'b0 && `DUV_PATH.wb_cyc_i == 1'b0 && `DUV_PATH.wb_we_i == 'hx && `DUV_PATH.wb_addr_i == 'hx && `DUV_PATH.wb_sel_i == 'hx && `DUV_PATH.wb_dat_i);
  endproperty
  
  property during_read_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (`DUV_PATH.wb_ack_o && !`DUV_PATH.wb_we_i) |-> (`DUV_PATH.wb_addr_i != 1'bx && `DUV_PATH.wb_addr_i != 1'bz && `DUV_PATH.wb_dat_i != 1'bx && `DUV_PATH.wb_dat_i != 1'bz);
  endproperty
        
  property after_read_behavior_p;
    @(posedge `DUV_PATH.sdram_clk)
    disable iff (!`DUV_PATH.wb_rst_i)
    (`DUV_PATH.wb_ack_o) |-> ##1 (`DUV_PATH.wb_stb_i == 1'b0 && `DUV_PATH.wb_cyc_i == 1'b0 && `DUV_PATH.wb_we_i == 'hx && `DUV_PATH.wb_addr_i == 'hx);
  endproperty
  
  clk_cycle_a: assert property (sync_clock_p) else $error("Rule1.1: Clock cycle assert violated");
    
  // Duracion de reset
  reset_duration_a: assert property (reset_duration_p) else $error("Rule3.05: WISHBONE RST signal must be asserted for at least one complete clock cycle");
    
  // Aserción para wb_stb_i y wb_cyc_i después de reset
  after_after_reset_a: assert property (after_reset_behavior_p) else $error("Rule3.20: WISHBONE signals wb_stb_i and wb_cyc_i must remain negated immediately after reset");
  
  // Aserción para wb_stb_i y wb_cyc_i durante reset
  on_reset_behavior_a: assert property (on_reset_behavior_p) else $error("Rule3.21: WISHBONE signals wb_stb_i and wb_cyc_i must remain negated on reset");
    
    //SDR ENABLE
    before_SDR_enable_behavior_a: assert property (before_SDR_enable_behavior_p) else $error("Rule5.1: WISHBONE signal sdr_init_done must be deasserted whenever SDR Enable is not asserted");
    
      after_SDR_enable_behavior_a: assert property (after_SDR_enable_behavior_p) else $error("Rule5.11: WISHBONE signal sdr_init_done must be asserted whenever after SDR Enable is asserted");
  
  //Aserción durante WRITE operations
  during_write_behavior_a: assert property (during_write_behavior_p) else $error("Rule4.20: WISHBONE signals (wb_addr_i, wb_dat_i) not in correct state while on write operation");
    
  //Aserción durante READ operations
  during_read_behavior_a: assert property (during_read_behavior_p) else $error("Rule4.21: WISHBONE signals (wb_addr_i, wb_dat_i) not in correct state while on read operation");
    
  // Aserción para AFTER WRITE Behavior
    after_write_behavior_a: assert property (after_write_behavior_p) else $error("Rule4.20: WISHBONE signals (wb_stb_i, wb_cyc_i, wb_we_i, wb_addr_i, wb_sel_i, wb_dat_i) not in correct state after write operation");
    
 // Aserción para AFTER READ Behavior
      after_read_behavior_a: assert property (after_read_behavior_p) else $error("Rule4.21: WISHBONE signals (wb_stb_i, wb_cyc_i, wb_we_i, wb_addr_i) not in correct state after read operation");
  
endmodule
