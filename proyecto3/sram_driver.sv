class sram_item extends uvm_sequence_item;
  
  rand logic [31:0] data;
  rand logic [31:0] address;
  
  // Constraint address value
  constraint valid_address {
  	address inside {[32'h00000000:32'h003FF]};
  }

// Constraint data value
`ifdef SDR_32BIT
  constraint valid_data {
  	address inside {[32'h00000000:32'hFFFFFFFF]};
  }
`elsif SDR_16BIT
  constraint valid_data {
  	address inside {[32'h00000000:32'h0000FFFF]};
  }
`else
  constraint valid_data {
  	address inside {[32'h00000000:32'h000000FF]};
  }
`endif

  int time_ns;

  randc logic [3:0]  sel;
  logic              update_sel;
  
  constraint valid_sel {
    sel inside {4'b0001, 4'b0010, 4'b0100, 4'b1000,   // Un solo byte
                 4'b0011, 4'b1100, 4'b1010, 4'b0110,  // Dos bytes
                 4'b1111};                            // All bytes
  }
  
  // Use utility macros to implement standard functions
  // like print, copy, clone, etc
  `uvm_object_utils_begin(sram_item)
    `uvm_field_int (data, UVM_DEFAULT)
    `uvm_field_int (address, UVM_DEFAULT)
  	`uvm_field_int (sel, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "sram_item");
    super.new(name);
    update_sel = 1'b0;
  endfunction
endclass

class gen_sram_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_sram_item_seq)
  function new(string name="gen_sram_item_seq");
    super.new(name);
  endfunction
  
  rand int num; // Config total number of items to be sent
  
  constraint c1 { num inside {[2:5]}; }
  
  virtual task body();
    sram_item s_item = sram_item::type_id::create("s_item");
    
    `uvm_info("sequencer", $sformatf("Generate %d sram_items",num), UVM_LOW)
    
    for (int i = 0; i < num; i ++) begin
      start_item(s_item);
      s_item.randomize();

      // Recupera el valor de 'update_sel' desde uvm_config_db
      if (!uvm_config_db#(logic)::get(null, "", "update_sel", s_item.update_sel)) begin
        `uvm_warning("SEQ", "No se configuró el valor de update_sel en uvm_config_db, usando valor por defecto.")
      end

      `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
      s_item.print();
      finish_item(s_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass


class sram_driver extends uvm_driver #(sram_item);
  `uvm_component_utils (sram_driver)
  function new (string name = "sram_driver", uvm_component parent = null);
    super.new (name, parent);
  endfunction

  virtual intf_wb intf;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
   
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sram_item s_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(s_item);
      if (s_item.update_sel) begin
        write_custom(s_item);
      end else begin
        write(s_item);
      end
      read(s_item);
      seq_item_port.item_done();
    end
  endtask
    
  virtual task write(sram_item s_item);
    begin
      `uvm_info("sram_driver", $sformatf("Write Address: 0x%0h, Data: 0x%0h", s_item.address, s_item.data), UVM_LOW)
      intf.write(s_item.address, s_item.data);
    end
  endtask
  
  virtual task read(sram_item s_item);
    begin
      `uvm_info("sram_driver", $sformatf("Read Address: 0x%0h", s_item.address), UVM_LOW)
      intf.read(s_item.address);
    end
  endtask
  
  virtual task write_custom(sram_item s_item);
    begin
      `uvm_info("sram_driver", $sformatf("Write Address: 0x%0h, Data: 0x%0h, Sel: 0x%0h", s_item.address, s_item.data, s_item.sel), UVM_LOW)
      intf.write_with_selector(s_item.address, s_item.data, s_item.sel);  
    end
  endtask
  
endclass
