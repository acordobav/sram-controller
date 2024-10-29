class scoreboard;

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
  endfunction
  
endclass
