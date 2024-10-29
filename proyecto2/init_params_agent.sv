class init_params_agent extends uvm_agent;
  `uvm_component_utils(init_params_agent)
  
  function new(string name="init_params_agent", uvm_component parent=null);
    super.new(name, parent);
    
  endfunction
  
  virtual intf_wb intf;
  init_params_driver init_params_drv;
  init_params_sequencer init_params_seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    init_params_drv = init_params_driver::type_id::create ("init_params_drv", this); 
    
    init_params_seqr = init_params_sequencer::type_id::create("init_params_seqr", this);   

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    init_params_drv.seq_item_port.connect(init_params_seqr.seq_item_export);
  endfunction

endclass

