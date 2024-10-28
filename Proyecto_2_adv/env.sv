class environment extends uvm_env;
 `uvm_component_utils(environment)

  //Interfaz, SB, ...
  virtual intf_wb intf;
  scoreboard sb;

  //Driver
  sdram_driver drv;

  //Sequencers
  //init_params_sequencer v_seqr;
  init_params_sequencer init_seqr;
  write_data_sequencer write_seqr;
  read_data_sequencer read_seqr;
  t_delay_sequencer delay_seqr;
  
  function new (string name = "environment", uvm_component parent = null);
    super.new (name, parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  // Call the parent class build_phase

    // Retrieve the virtual interface from the config database
    if (uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    sb = scoreboard::type_id::create ("sb", this); 

    //Sequencers
    //v_seqr = init_params_sequencer::type_id::create ("v_seqr", this);
    init_seqr = init_params_sequencer::type_id::create("init_seqr", this);
    write_seqr = write_data_sequencer::type_id::create("write_seqr", this);
    read_seqr = read_data_sequencer::type_id::create("read_seqr", this);
    delay_seqr = t_delay_sequencer::type_id::create("delay_seqr", this);

    //Driver
    drv = sdram_driver::type_id::create("drv", this);

    // Set the virtual interface in the config database
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();
  endfunction
    
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //Connect drv to seqr
    init_seqr.seq_item_port.connect(drv.seq_item_port);
    write_seqr.seq_item_port.connect(drv.seq_item_port);
    read_seqr.seq_item_port.connect(drv.seq_item_port);
    delay_seqr.seq_item_port.connect(drv.seq_item_port);
   
  endfunction
  
endclass
