class funct_coverage extends uvm_component;
  `uvm_component_utils(funct_coverage)
  
  function new (string name = "funct_coverage", uvm_component parent = null);
    super.new(name, parent);
    cov_sel = new();
    cov_reset = new();
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
  
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    //Report coverage
    $display("COV SEL Overall: %3.2f%% coverage achieved.", cov_sel.get_coverage());
    $display("COV RST Overall: %3.2f%% coverage achieved.", cov_reset.get_coverage());
  endfunction
endclass