class spec_param_agent extends uvm_agent;
  `uvm_component_utils(spec_param_agent)
  
  function new(string name="spec_param_agent", uvm_component parent=null);
    super.new(name, parent);
    
  endfunction
  
  virtual intf_wb intf;
  spec_param_driver spec_param_drv;
  spec_param_sequencer spec_param_seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    spec_param_drv = spec_param_driver::type_id::create ("spec_param_drv", this); 
    
    spec_param_seqr = spec_param_sequencer::type_id::create("spec_param_seqr", this);   

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    spec_param_drv.seq_item_port.connect(spec_param_seqr.seq_item_export);
  endfunction

endclass