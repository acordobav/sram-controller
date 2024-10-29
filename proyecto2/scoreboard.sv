`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon ) 

// Create a class that extends from uvm_scoreboard
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils (scoreboard)

  function new (string name, uvm_component parent=null);
		super.new (name, parent);
  endfunction

  // Declare and create TLM Analysis Ports to receive data objects from other TB components
  uvm_analysis_imp_drv #(sram_item, scoreboard) sram_drv;  // Driver
  uvm_analysis_imp_mon #(sram_item, scoreboard) sram_mon;  // Monitor

  // Reference model
  int afifo[$];    // address fifo
  int bfifo[$];    // Burst Length fifo
  int memory[int]; // Declare an associative array which will model the memory
  int ErrCnt = 0;  // Error counter

  // Instantiate the analysis ports
	function void build_phase (uvm_phase phase);
      sram_drv = new ("sram_drv", this);
      sram_mon = new ("sram_mon", this);
	endfunction

  // write function used by the driver
  virtual function void write_drv (sram_item item);
    `uvm_info ("scoreboard", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)
    memory[item.address] = item.data;
	endfunction

  // write function used by the monitor
  virtual function void write_mon(sram_item item);
    `uvm_info ("scoreboard", $sformatf("Data received = 0x%0h | Address received =  0x%0h", item.data, item.address), UVM_MEDIUM)
    
    // Check address was used
    if (!memory.exists(item.address)) begin
      `uvm_error ("scoreboard", $sformatf("Address received =  0x%0h was not used", item.address))
      ErrCnt = ErrCnt + 1;
    end
    else begin
      // Address was accessed at some point, check its value
      int exp_data = memory[item.address];
      if (exp_data !== item.data) begin
        `uvm_error ("scoreboard", $sformatf("On address 0x%0h the expected value is 0x%0h, instead got 0x%0h", item.address, exp_data, item.data))
        ErrCnt = ErrCnt + 1;
      end
    end
  endfunction

	virtual function void check_phase (uvm_phase phase);
	  if (ErrCnt == 0) begin
        `uvm_info("sram_monitor", "STATUS: SDRAM Write/Read TEST PASSED", UVM_NONE)
      end else begin
        `uvm_error("sram_monitor", $sformatf("ERROR: SDRAM Write/Read TEST FAILED with %0d errors", ErrCnt))
      end
	endfunction

endclass