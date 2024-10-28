class test_1 extends uvm_test;
  `uvm_component_utils(test_1)

  virtual intf_wb intf;  
  environment env; 

  //Items Sqc
  init_params_item init_item;
  write_data_item write_item;
  read_data_item read_item;
  t_delay_item delay_item;

  function new(string name = "test_1", uvm_component parent = null);
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
  
  //Execution phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    init_item = init_params_item::type_id::create("init_item");
    write_item = write_data_item::type_id::create("write_item");
    read_item = read_data_item::type_id::create("read_item");
    delay_item = t_delay_item::type_id::create("delay_item");

    //Init Module Params
    start_init_sequence();

    // Reiniciar el dispositivo
    env.drv.reset_test(intf_wb::get_instance().sys_clk);

    // Ejecutar secuencias de escritura y lectura
    start_write_read_sequence();

    // Verificar resultados
    $display("\n[INFO] ---CHECKER---");
    //env.mntr.eot_check();

    phase.drop_objection(this);

    $finish; // Terminar la simulación
  endtask
  
 // Iniciar secuencia init
  virtual task start_init_sequence();
    init_params_sequencer init_seq = init_params_sequencer::type_id::create("init_seq");
    init_seq.start(env.drv.seq_item_port); // Iniciar la secuencia
  endtask

  //Escribir/Leer SDRAM
  virtual task start_write_read_sequence();
    write_data_sequencer write_seq = write_data_sequencer::type_id::create("write_seq");
    read_data_sequencer read_seq = read_data_sequencer::type_id::create("read_seq");
    t_delay_sequencer delay_seq = t_delay_sequencer::type_id::create("t_delay_seq");

    // Enviar la secuencia de escritura
    write_seq.start(env.drv.seq_item_port);
    // Esperar un tiempo aleatorio
    delay_seq.start(env.drv.seq_item_port);

    // Enviar la secuencia de lectura
    read_seq.start(env.drv.seq_item_port);
    // Esperar un tiempo aleatorio
    delay_seq.start(env.drv.seq_item_port);
  endtask

endclass
