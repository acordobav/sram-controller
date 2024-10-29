class init_params_sequencer extends uvm_sequencer #(init_params_item);
  `uvm_component_utils(init_params_sequencer)
  
  function new (string name = "init_params_sequencer", uvm_component parent = null);
    super.new (name, parent);
 
  endfunction  

endclass