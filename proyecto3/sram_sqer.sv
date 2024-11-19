class sram_sequencer extends uvm_sequencer #(sram_item);
   
  `uvm_component_utils(sram_sequencer)
  
  function new (string name = "sram_sequencer", uvm_component parent = null);
    super.new (name, parent);
 
  endfunction  

endclass