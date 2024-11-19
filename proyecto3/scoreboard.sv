`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon )
`uvm_analysis_imp_decl( _init ) 

// Create a class that extends from uvm_scoreboard
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils (scoreboard)

  function new (string name, uvm_component parent=null);
    super.new (name, parent);
  endfunction

  // Declare and create TLM Analysis Ports to receive data objects from other TB components
  uvm_analysis_imp_drv #(sram_item, scoreboard) sram_drv;  // Driver
  uvm_analysis_imp_mon #(sram_item, scoreboard) sram_mon;  // Monitor
  uvm_analysis_imp_init #(init_params_item, scoreboard) sram_init;  // Monitor

  // Reference model
  int memory[int]; // Declare an associative array which will model the memory
  int ErrCnt = 0;  // Error counter

  // Instantiate the analysis ports
	function void build_phase (uvm_phase phase);
      sram_drv = new ("sram_drv", this);
      sram_mon = new ("sram_mon", this);
      sram_init = new ("sram_init", this);
	endfunction

  // write function used by the driver
  virtual function void write_drv(sram_item item);
    `uvm_info("scoreboard (driver)", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)

    // Only update the bytes that are selected based on the 'sel' value
    if (item.sel[0]) memory[item.address][7:0] = item.data[7:0];      // Byte 0
    if (item.sel[1]) memory[item.address][15:8] = item.data[15:8];    // Byte 1
    if (item.sel[2]) memory[item.address][23:16] = item.data[23:16];  // Byte 2
    if (item.sel[3]) memory[item.address][31:24] = item.data[31:24];  // Byte 3
  endfunction

  // write function used by the monitor
  virtual function void write_mon(sram_item item);
    `uvm_info ("scoreboard (monitor)", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)
    
    if (1'b1) begin
      // Address was accessed at some point, check its value
      int exp_data = memory[item.address];

      // Only compare the bytes that are selected based on the 'sel' value
      if (item.sel[0]) begin
        if (exp_data[7:0] !== item.data[7:0]) begin
          `uvm_error("scoreboard (monitor)", $sformatf("FAILED | On address 0x%0h, expected byte 0: 0x%0h, got 0x%0h", item.address, exp_data[7:0], item.data[7:0]))
          ErrCnt = ErrCnt + 1;
        end
      end
      if (item.sel[1]) begin
        if (exp_data[15:8] !== item.data[15:8]) begin
          `uvm_error("scoreboard (monitor)", $sformatf("FAILED | On address 0x%0h, expected byte 1: 0x%0h, got 0x%0h", item.address, exp_data[15:8], item.data[15:8]))
          ErrCnt = ErrCnt + 1;
        end
      end
      if (item.sel[2]) begin
        if (exp_data[23:16] !== item.data[23:16]) begin
          `uvm_error("scoreboard (monitor)", $sformatf("FAILED | On address 0x%0h, expected byte 2: 0x%0h, got 0x%0h", item.address, exp_data[23:16], item.data[23:16]))
          ErrCnt = ErrCnt + 1;
        end
      end
      if (item.sel[3]) begin
        if (exp_data[31:24] !== item.data[31:24]) begin
          `uvm_error("scoreboard (monitor)", $sformatf("FAILED | On address 0x%0h, expected byte 3: 0x%0h, got 0x%0h", item.address, exp_data[31:24], item.data[31:24]))
          ErrCnt = ErrCnt + 1;
        end
      end
    end
  endfunction
  
  
  
   // write function used by the monitor
  virtual function void write_init(init_params_item item);
    int real_time_ns;
    int exp_data;
    //`uvm_info("scoreboard (monitor) SUCCEED", " NO DICE NADA:  %d actual: ", UVM_NONE)
    
    //real_time_ns = 40 + (20*item.signal);
    if (1'b1) begin
       exp_data = 40 + (20*item.signal); // ecuación para calcular el tiempo
       if (exp_data !== item.time_ns) begin
         
         `uvm_error ("scoreboard (monitor)", $sformatf("FAILED |data expected is %d, instead got %dns", exp_data, item.time_ns))
           ErrCnt = ErrCnt + 1;
       end
       else begin
          // `uvm_info ("scoreboard (monitor)", $sformatf("SUCCEED | data expected is %d, data otained from SDR_trcar_d %d", exp_data, item.time_ns), UVM_NONE)
       end
          // Address was accessed at some point, check its value
    end

    
  endfunction  
  
// end of test logic
  virtual function void check_phase (uvm_phase phase);
    `uvm_info("scoreboard", "#######################################", UVM_NONE)
    if (ErrCnt == 0) begin
      `uvm_info("sram_monitor", "STATUS: SDRAM Write/Read TEST PASSED", UVM_NONE)
    end else begin
      `uvm_error("sram_monitor", $sformatf("ERROR: SDRAM Write/Read TEST FAILED with %0d errors", ErrCnt))
    end
    `uvm_info("scoreboard", "#######################################", UVM_NONE)
  endfunction

endclass
