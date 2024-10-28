`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon ) 

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils (scoreboard)

  int ErrCnt = 0; // Contador errores

  uvm_analysis_imp#(sdram_item, scoreboard) mon;
  
  //uvm_analysis_imp_drv #(driver, scoreboard) drv;

  function new (string name, uvm_component parent=null);
		super.new (name, parent);
  endfunction
  
  uvm_analysis_imp_drv #(driver, scoreboard) fifo_drv;
  uvm_analysis_imp_mon #(driver, scoreboard) fifo_mon;

    logic [7:0] ref_model [$];  
  
	function void build_phase (uvm_phase phase);
      fifo_drv = new ("fifo_drv", this);
      fifo_mon = new ("fifo_mon", this);
	endfunction

 ///WIP   not ready yet

	virtual function void check_phase (uvm_phase phase);
      if(ref_model.size() > 0)
        `uvm_warning("SB Warn", $sformatf("FIFO not empty at check phase. Fifo still has 0x%0h data items allocated", ref_model.size()));
	endfunction

  
  
 



  /*
  int afifo[$]; // address  fifo
  int bfifo[$]; // Burst Length fifo

  // Declare an associative array which will model the memory  
  int memory[int];
  
  // Constructor (optional, here for clarity)
  function new();
    // Can initialize any default values if needed
  endfunction

  // Method to set the value of an address
  function void set(int address, int value);
    memory[address] = value;
  endfunction
 
  // Method to retrieve a value by address
  function int get(int address);
    if (memory.exists(address)) begin
      return memory[address];
    end
    else begin
      $display("Warning: address %X not found in memory", address);
      return -1;  // Return -1 if address doesn't exist
    end
  endfunction*/
  
endclass
