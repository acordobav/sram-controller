class spec_param_sequencer extends uvm_sequencer #(spec_param_item);
  `uvm_component_utils(spec_param_sequencer)
  
  function new (string name = "spec_param_sequencer", uvm_component parent = null);
    super.new (name, parent);
 
  endfunction  

endclass