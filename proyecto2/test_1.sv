class test_basic extends uvm_test;
  `uvm_component_utils(test_basic)

  virtual intf_wb intf;  
  environment env; 
  //stimulus sti;
  
  function new(string name = "test_basic", uvm_component parent = null);
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
  
  virtual_sequence v_seq;
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    $display("\n-------------------------------------------------- ");
    $display("*************** INIT PARAMS AND RESET ***************");
    $display("--------------------------------------------------\n");
    v_seq = virtual_sequence::type_id::create("v_seq");
    v_seq.start(env.virtual_seqr);
    phase.drop_objection(this);
  endtask
  
endclass

/*
program testcase(intf_wb intf);
  environment env = new(intf);
  stimulus sti;
   
  initial
    begin
     sti = new();
     $display("\n-------------------------------------------------- ");
     $display("******************* TESTCASE 1 *******************");
     $display("--------------------------------------------------\n");

     $display("[INFO] Initializing Parameters for Module"); 
     env.drvr.init_param(intf.sys_clk);

     $display("[INFO] Initializing");
     env.drvr.reset_test(intf.sys_clk);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;

     $display("-------------------------------------- ");
     $display(" Case-1: Single Write/Read Case ");
     $display("--------------------------------------");

     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     
     $display("-------------------------------------- ");
     $display(" Case-2: Repeat same transfer once again ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---TEST de lectura---");
     env.drvr.burst_read();
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h0040_0000,8'h5);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     
     $display("----------------------------------------");
     $display(" Case:4 4 Write & 4 Read                ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h5_0000,8'h5);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h6_0000,8'h6);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h7_0000,8'h7); 
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     env.drvr.burst_read();  
     env.drvr.burst_read();
     env.drvr.burst_read(); 
    

     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("\n[INFO] ---CHECKER---");
     env.mntr.eot_check();
     
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $finish;
  
	end 
endprogram
*/

function int tiempo();
    tiempo = $urandom_range(1000, 10000); // Devuelve el valor generado
endfunction
