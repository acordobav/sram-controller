class reset_item extends uvm_sequence_item;
  
  rand logic start_reset;
  
  constraint r1 {start_reset inside {[1:1]};}
  
  `uvm_object_utils_begin(reset_item)
  	`uvm_field_int (start_reset, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "reset_item");
    super.new(name);
  endfunction
  
endclass

class gen_reset_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_reset_item_seq)
  
  function new(string name="gen_reset_item_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    reset_item n_reset = reset_item::type_id::create("n_reset");
    start_item(n_reset);
    n_reset.randomize();
    `uvm_info("SEQ", $sformatf("Generate new reset item: "), UVM_LOW)
    n_reset.print();
    finish_item(n_reset);
    `uvm_info("SEQ", $sformatf("Done reset generation"), UVM_LOW)
  endtask
endclass

class reset_driver extends uvm_driver #(reset_item);
  `uvm_component_utils(reset_driver)
  
  function new (string name="reset_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase (phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      reset_item n_reset;
      `uvm_info("DRV_RST", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(n_reset);
      reset_drive(n_reset);
      seq_item_port.item_done();
    end
  endtask
  
  virtual task reset_drive(reset_item n_reset);
    intf.reset();
  endtask
  
endclass