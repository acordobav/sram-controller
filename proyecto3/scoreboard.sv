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
  virtual function void write_drv (sram_item item);
    `uvm_info ("scoreboard (driver)", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)
    memory[item.address] = item.data;
	endfunction

  // write function used by the monitor
  virtual function void write_mon(sram_item item);
    `uvm_info ("scoreboard (monitor)", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)
    
    if (1'b1) begin
      // Address was accessed at some point, check its value
      int exp_data = memory[item.address];
      if (exp_data !== item.data) begin
        
        `uvm_error ("scoreboard (monitor)", $sformatf("FAILED | On address 0x%0h the expected value is 0x%0h, instead got 0x%0h", item.address, exp_data, item.data))
        ErrCnt = ErrCnt + 1;
      end
      else begin
        `uvm_info ("scoreboard (monitor)", $sformatf("SUCCEED | address: 0x%0h exp_value: 0x%0h actual: 0x%0h", item.address, exp_data, item.data), UVM_NONE)
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
         `uvm_info ("scoreboard (monitor)", $sformatf("SUCCEED | data expected is %d, data otained from SDR_trcar_d %d", exp_data, item.time_ns), UVM_NONE)
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
