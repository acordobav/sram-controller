class init_params_sequencer extends uvm_sequencer #(init_params_item);
  `uvm_component_utils(init_params_sequencer)

  // Constructor
  function new(string name = "init_params_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

class write_data_sequencer extends uvm_sequencer #(write_data_item);
  
  // Constructor
  function new(string name = "write_data_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

class read_data_sequencer extends uvm_sequencer #(read_data_item);
  
  // Constructor
  function new(string name = "read_data_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

class t_delay_sequencer extends uvm_sequencer #(t_delay_item);
  
  // Constructor
  function new(string name = "t_delay_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
