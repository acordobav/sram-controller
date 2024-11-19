class funct_coverage extends uvm_component;
  `uvm_component_utils(funct_coverage)
  
  function new (string name = "funct_coverage", uvm_component parent = null);
    super.new(name, parent);
    cov0 = new();
    cov1 = new();
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
        cov0.sample();
        cov1.sample();
      end
    end
  endtask
  
  covergroup cov1;
    ;
  endgroup
  
  covergroup cov2;
    
  endgroup
  
  virtual function void report_phase(uvm_phase phase);
    super.phase(phase);
    //Report coverage
    $display("COV0 Overall: %3.2f%% coverage achieved.",
    cov0.get_coverage());
    $display("COV1 Overall: %3.2f%% coverage achieved.",    
    cov1.get_coverage());
  endfunction