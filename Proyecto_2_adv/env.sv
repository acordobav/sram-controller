class environment extends uvm_env;

 `uvm_component_utils(environment)
  
  function new (string name = "environment", uvm_component parent = null);
    super.new (name, parent);
  endfunction

  virtual intf_wb intf;
  scoreboard sb;
  init_params_sequencer v_seqr;

  
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  // Call the parent class build_phase

    // Retrieve the virtual interface from the config database
    if (uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    sb = scoreboard::type_id::create ("sb", this); 
    v_seqr = init_params_sequencer::type_id::create ("v_seqr", this);

    // Set the virtual interface in the config database
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();
  endfunction
    
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
   
  endfunction
  
  

  
endclass
