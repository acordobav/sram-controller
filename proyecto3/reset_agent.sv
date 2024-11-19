class reset_agent extends uvm_agent;
  `uvm_component_utils(reset_agent)
  
  function new(string name="reset_agent", uvm_component parent=null);
    super.new(name, parent);
    
  endfunction
  
  virtual intf_wb intf;
  reset_driver reset_drv;
  reset_sequencer reset_seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    reset_drv = reset_driver::type_id::create ("reset_drv", this); 
    
    reset_seqr = reset_sequencer::type_id::create("reset_seqr", this);   

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reset_drv.seq_item_port.connect(reset_seqr.seq_item_export);
  endfunction

endclass

