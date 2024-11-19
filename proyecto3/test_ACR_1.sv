class test_ACR_1 extends uvm_test;
  `uvm_component_utils(test_ACR_1)

  virtual intf_wb intf;  
  environment env;
  
  function new(string name = "test_ACR_1", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  //Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

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
  
  virtual_sequence_ACR_1 v_seq_ACR;
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    $display("\n-------------------------------------------------- ");
    $display("********************* ACR TEST **********************");
    $display("--------------------------------------------------\n");
    v_seq_ACR = virtual_sequence_ACR_1::type_id::create("v_seq_ACR");
    v_seq_ACR.start(env.virtual_seqr);
    phase.drop_objection(this);
  endtask
endclass