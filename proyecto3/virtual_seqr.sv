class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer)
  
  //Add all required Seqr
  reset_sequencer reset_seqr;
  init_params_sequencer init_params_seqr;
  sram_sequencer sram_seqr;
  spec_param_sequencer spec_param_seqr;
  
  function new (string name = "virtual_sequencer", uvm_component parent = null);
    super.new (name, parent);
 
  endfunction  

endclass
