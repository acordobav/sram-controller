class mem_sequencer extends uvm_sequencer #(init_params_item);
  
  // Constructor
  function new(string name = "mem_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass