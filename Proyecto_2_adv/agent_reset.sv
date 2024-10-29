class reset_agent_active extends uvm_agent;
  `uvm_component_utils(reset_agent_active)
  function new(string name="reset_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  driver drv;  // must be included reset driver 
  init_params_sequencer seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    drv = driver::type_id::create ("drv", this);  // must be included the reset driver
    
    seqr = init_params_sequencer::type_id::create("seqr", this);   

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);  //review this  MODIFY when Drivers ports are ready
  endfunction

endclass
