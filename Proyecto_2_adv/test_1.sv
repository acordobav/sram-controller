class test_basic extends uvm_test;
  `uvm_component_utils(test_basic)

  function new(string name = "test_basic", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Declare the interface and environment
  virtual intf_wb intf;  
  environment env;       

  // Uncomment and implement the build_phase function if needed
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  // Call the parent class build_phase

    // Retrieve the virtual interface from the config database
    if (uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end

    // Create the environment instance
    env = environment::type_id::create("env", this);

    // Set the virtual interface in the config database
    uvm_config_db #(virtual intf_wb)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
  endfunction
  

  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
	uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print(); 
  endfunction : end_of_elaboration_phase
  
  init_params_item v_seq;
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    v_seq = init_params_item::type_id::create("v_seq");  
    v_seq.start(env.v_seqr);    
    
    phase.drop_objection(this);
  endtask
  
  

endclass
