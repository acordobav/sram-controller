class init_params_item extends uvm_sequence_item;
  int  time_ns;
  logic [3:0]  signal;

  // Randomize Parameters of the module
  rand logic  [1:0]  Req_Depth;
  rand logic         SDR_Enable;
  rand logic  [12:0] SDR_Mode_Reg;
  rand logic  [3:0]  SDR_tras_d;
  rand logic  [3:0]  SDR_trp_d;
  rand logic  [3:0]  SDR_trcd_d;
  rand logic  [2:0]  SDR_cas;
  rand logic  [3:0]  SDR_trcar_d;
  rand logic  [3:0]  SDR_twr_d;
  rand logic  [11:0] SDR_rf_sh;
  rand logic  [3:0]  SDR_rf_max;
  
  logic             update_SDR_enable;
  
  // Constraints for Module Parameters
  constraint Req_Depth_limit    {Req_Depth    inside {2'h3,2'h3};}
  constraint SDR_Enable_limit   {SDR_Enable   inside {0,1};}
  constraint SDR_Mode_Reg_limit {SDR_Mode_Reg inside {13'h033,13'h033};}
  constraint SDR_tras_d_limit   {SDR_tras_d   inside {4'h4,4'h4};}
  constraint SDR_trp_d_limit    {SDR_trp_d    inside {4'h2,4'h2};}
  constraint SDR_trcd_d_limit   {SDR_trcd_d   inside {4'h2,4'h2};}
  constraint SDR_cas_limit      {SDR_cas      inside {3'h3,3'h3};}
  constraint SDR_trcar_d_limit  {SDR_trcar_d  inside {4'h1, 4'h2, 4'h3, 4'h4, 4'h5, 4'h6, 4'h7, 4'h8, 
                               						  4'h9, 4'ha, 4'hb, 4'hc, 4'hd, 4'he, 4'hf};} //probando randomizar esta señal de refresh 
  constraint SDR_twr_d_limit    {SDR_twr_d    inside {4'h1,4'h1};}
  constraint SDR_rf_sh_limit    {SDR_rf_sh    inside {12'h100,12'h100};}
  constraint SDR_rf_max_limit   {SDR_rf_max   inside {3'h6,3'h6};}
  
  `uvm_object_utils_begin(init_params_item)
  	`uvm_field_int (Req_Depth, UVM_DEFAULT)
  	`uvm_field_int (SDR_Enable, UVM_DEFAULT)
  	`uvm_field_int (SDR_Mode_Reg, UVM_DEFAULT)
  	`uvm_field_int (SDR_tras_d, UVM_DEFAULT)
  	`uvm_field_int (SDR_trp_d, UVM_DEFAULT)
  	`uvm_field_int (SDR_trcd_d, UVM_DEFAULT)
  	`uvm_field_int (SDR_cas, UVM_DEFAULT)
  	`uvm_field_int (SDR_trcar_d, UVM_DEFAULT)
  	`uvm_field_int (SDR_twr_d, UVM_DEFAULT)
  	`uvm_field_int (SDR_rf_sh, UVM_DEFAULT)
  	`uvm_field_int (SDR_rf_max, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "init_params_item");
    super.new(name);
    update_SDR_enable = 1'b0;
  endfunction
  
endclass

class gen_init_params_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_init_params_item_seq)
  
  function new(string name="gen_init_params_item_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    init_params_item n_init_params = init_params_item::type_id::create("n_init_params");
    start_item(n_init_params);
    n_init_params.randomize();
    
    // Recupera el valor de 'update_SDR_enable' desde uvm_config_db
    if (!uvm_config_db#(logic)::get(null, "", "update_SDR_enable", n_init_params.update_SDR_enable)) begin
      `uvm_warning("SEQ", "No se configuró el valor de update_SDR_enable en uvm_config_db, usando valor por defecto.")
    end
    
    `uvm_info("SEQ", $sformatf("Generate new Init Params: "), UVM_LOW)
    n_init_params.print();
    finish_item(n_init_params);
    `uvm_info("SEQ", $sformatf("Done Init Params generation"), UVM_LOW)
  endtask
endclass

class init_params_driver extends uvm_driver #(init_params_item);
  `uvm_component_utils(init_params_driver)
  
  function new (string name="init_params_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase (phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      init_params_item n_init_params;
      `uvm_info("DRV_IN_PAR", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(n_init_params);
      init_params_drive(n_init_params);
      seq_item_port.item_done();
    end
  endtask
  
  virtual task init_params_drive(init_params_item n_init_params);
    $display("[Driver INIT PARAMS] Executing Init Params");
	
    intf.Req_Depth    = n_init_params.Req_Depth;
    if (n_init_params.update_SDR_enable) begin
      intf.SDR_Enable   = n_init_params.SDR_Enable;
    end else begin
      intf.SDR_Enable   = 1'b1;
    end
    
    intf.SDR_Mode_Reg = n_init_params.SDR_Mode_Reg;
    intf.SDR_tras_d   = n_init_params.SDR_tras_d;
    intf.SDR_trp_d    = n_init_params.SDR_trp_d;
    intf.SDR_trcd_d   = n_init_params.SDR_trcd_d;
    intf.SDR_cas      = n_init_params.SDR_cas;
    intf.SDR_trcar_d  = n_init_params.SDR_trcar_d;
    intf.SDR_twr_d    = n_init_params.SDR_twr_d;
    intf.SDR_rf_sh    = n_init_params.SDR_rf_sh;
    intf.SDR_rf_max   = n_init_params.SDR_rf_max;

    $display("[Driver INIT PARAMS] Parameters being used");
    $display("[Driver INIT PARAMS] SDRAM Column Depth:                                                  0x%h",n_init_params.Req_Depth);
    $display("[Driver INIT PARAMS] SDRAM Controller Enable:                                             0x%h",n_init_params.SDR_Enable);
    $display("[Driver INIT PARAMS] SDRAM Mode Register:                                                 0x%h",n_init_params.SDR_Mode_Reg);
    $display("[Driver INIT PARAMS] SDRAM Active to Precharge:                                           0x%h",n_init_params.SDR_tras_d);
    $display("[Driver INIT PARAMS] SDRAM Precharge Command Period:                                      0x%h",n_init_params.SDR_trp_d);
    $display("[Driver INIT PARAMS] SDRAM Active to Read or Write Delay:                                 0x%h",n_init_params.SDR_trcd_d);
    $display("[Driver INIT PARAMS] SDRAM CAS Latency:                                                   0x%h",n_init_params.SDR_cas);
    $display("[Driver INIT PARAMS] SDRAM Active to active/auto-refresh command period:                  0x%h",n_init_params.SDR_trcar_d);
    $display("[Driver INIT PARAMS] SDRAM Write Recovery time:                                           0x%h",n_init_params.SDR_twr_d);
    $display("[Driver INIT PARAMS] SDRAM Period between auto-refresh commands issued by the controller: 0x%h",n_init_params.SDR_rf_sh);
    $display("[Driver INIT PARAMS] SDRAM Maximum number of rows to be refreshed at a time:              0x%h",n_init_params.SDR_rf_max);
    $display("[Driver INIT PARAMS] Flag to randomize SDR Enable:                                        0x%h",n_init_params.update_SDR_enable);
    $display("[Driver INIT PARAMS] Finish Init Params");
  endtask
  
endclass