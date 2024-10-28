// Esta sera la clase principal
// De esta heredaran las otras secuencias que deban definirse
class sdram_item extends uvm_sequence_item;
  `uvm_object_utils(sdram_item)

  function new(string name = "sdram_item");
    super.new(name);
  endfunction
endclass

class init_params_item extends sdram_item;
  `uvm_object_utils(init_params_item)

  // Randomize Parameters of the module
  rand logic [1:0]  Req_Depth;
  rand logic        SDR_Enable;
  rand logic [12:0] SDR_Mode_Reg;
  rand logic [3:0]  SDR_tras_d;
  rand logic [3:0]  SDR_trp_d;
  rand logic [3:0]  SDR_trcd_d;
  rand logic [2:0]  SDR_cas;
  rand logic [3:0]  SDR_trcar_d;
  rand logic [3:0]  SDR_twr_d;
  rand logic [11:0] SDR_rf_sh;
  rand logic [3:0]  SDR_rf_max;

  // Constraints for Module Parameters
  constraint Req_Depth_limit    {Req_Depth    inside {2'h3,2'h3};}
  constraint SDR_Enable_limit   {SDR_Enable   inside {1,1};}
  constraint SDR_Mode_Reg_limit {SDR_Mode_Reg inside {13'h033,13'h033};}
  constraint SDR_tras_d_limit   {SDR_tras_d   inside {4'h4,4'h4};}
  constraint SDR_trp_d_limit    {SDR_trp_d    inside {4'h2,4'h2};}
  constraint SDR_trcd_d_limit   {SDR_trcd_d   inside {4'h2,4'h2};}
  constraint SDR_cas_limit      {SDR_cas      inside {3'h3,3'h3};}
  constraint SDR_trcar_d_limit  {SDR_trcar_d  inside {4'h7,4'h7};}
  constraint SDR_twr_d_limit    {SDR_twr_d    inside {4'h1,4'h1};}
  constraint SDR_rf_sh_limit    {SDR_rf_sh    inside {12'h100,12'h100};}
  constraint SDR_rf_max_limit   {SDR_rf_max   inside {3'h6,3'h6};}

  function new(string name = "init_params_item");
    super.new(name);
  endfunction

endclass

class write_data_item extends sdram_item;
  `uvm_object_utils(write_data_item)

  rand logic [31:0] Address;
  rand logic [7:0]  bl;
  rand logic [31:0] data;

  // Address must be in range 0x000000 to 0x003FFFFF
  constraint addr_c { Address inside {[32'h00000000:32'h003FFFFF]}; }
  
  // Burst length (bl) range
  constraint bl_c { bl inside {[1:8]}; }

  function new(string name = "write_data_item");
    super.new(name);
  endfunction

endclass

class read_data_item extends sdram_item;
  `uvm_object_utils(read_data_item)

  rand logic [31:0] Address;
  
  // Address must be in range 0x000000 to 0x003FFFFF
  constraint addr_c { Address inside {[32'h00000000:32'h003FFFFF]}; }

  function new(string name = "read_data_item");
    super.new(name);
  endfunction

endclass

class t_delay_item extends sdram_item;
  `uvm_object_utils(t_delay_item)

  // Random delays; no constraints by the moment

  rand logic [14:0] t_delay;
  constraint t_delay_r {t_delay inside {[14'h3E8 : 14'h2710]}; } //t_delay  = $urandom_range(1000, 10000); 

  function new(string name = "t_delay_item");
    super.new(name);
  endfunction

endclass

class sdram_controller_sequence extends uvm_sequence#(uvm_sequence_item);
  `uvm_object_utils(sdram_controller_sequence)

  function new(string name = "sdram_controller_sequence");
    super.new(name);
  endfunction

  virtual task body();
  
    init_params_item init_tr;
    write_data_item write_tr;
    read_data_item read_tr;
    t_delay_item delay_tr;

    // Transacción de inicialización
    init_tr = init_params_item::type_id::create("init_tr");
    start_item(init_tr);
    if (!init_tr.randomize()) `uvm_error("SEQ_ERR", "Error while randomizing init_tr");
    finish_item(init_tr);

    // Transacción de escritura
    write_tr = write_data_item::type_id::create("write_tr");
    start_item(write_tr);
    if (!write_tr.randomize()) `uvm_error("SEQ_ERR", "Error while randomizing write_tr");
    finish_item(write_tr);

    // Transacción de lectura
    read_tr = read_data_item::type_id::create("read_tr");
    start_item(read_tr);
    if (!read_tr.randomize()) `uvm_error("SEQ_ERR", "Error while randomizing read_tr");
    finish_item(read_tr);

    delay_tr = t_delay_item::type_id::create("delay_tr");
    start_item(delay_tr);
    if (!delay_tr.randomize()) `uvm_error("SEQ_ERR", "Error while randomizing delay_tr");
	  finish_item(delay_tr);
  endtask

endclass
