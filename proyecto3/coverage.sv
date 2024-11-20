class funct_coverage extends uvm_component;
  `uvm_component_utils(funct_coverage)
  
  function new (string name = "funct_coverage", uvm_component parent = null);
    super.new(name, parent);
    cov_sel = new();
    cov_reset = new();
    cov_ACR = new();
    cov_banks = new();
  endfunction
  
  virtual intf_wb intf;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(intf.sys_clk) begin
        cov_sel.sample();
        cov_reset.sample();
        cov_ACR.sample();
        cov_banks.sample();
      end
    end
  endtask
  
  covergroup cov_sel;
    Feature_sel: coverpoint intf.wb_sel_i {
      bins single_byte[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000}; // Un solo byte
      bins two_bytes[]   = {4'b0011, 4'b1100, 4'b1010, 4'b0110}; // Dos bytes
      bins all_bytes     = {4'b1111};                            // Todos los bytes
    }
  endgroup
  
  covergroup cov_reset;
    Feature_reset: coverpoint intf.SDR_Enable {
      bins possible_state[] = {1'b1, 1'b0};
    }
  endgroup
  
  covergroup cov_banks;
    // Address Decodeing:
    //  with cfg_col bit configured as: 00
    //    <12 Bit Row> <2 Bit Bank> <8 Bit Column> <2'b00>
    Feature_banks: coverpoint intf.wb_addr_i[11:10] {
      bins possible_state[] = {2'b00, 2'b01, 2'b10, 2'b11};
    }
  endgroup

  covergroup cov_ACR;
    Feature_ACR: coverpoint intf.SDR_trcar_d {
      bins possible_state[] = {4'h1, 4'h2, 4'h3, 4'h4, 4'h5, 4'h6, 4'h7, 4'h8, 
                               4'h9, 4'ha, 4'hb, 4'hc, 4'hd, 4'he, 4'hf};
    }
  endgroup

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    //Report coverage
    $display("COV SEL Overall: %3.2f%% coverage achieved.", cov_sel.get_coverage());
    $display("COV RST Overall: %3.2f%% coverage achieved.", cov_reset.get_coverage());
    $display("COV ACR Overall: %3.2f%% coverage achieved.", cov_ACR.get_coverage());
    $display("COV BANKS Overall: %3.2f%% coverage achieved.", cov_banks.get_coverage());
  endfunction
endclass