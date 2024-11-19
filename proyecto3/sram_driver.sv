class sram_item extends uvm_sequence_item;
  
`ifdef SDR_32BIT
  rand logic [31:0] data;
  rand logic [10:0] address;
`elsif SDR_16BIT
  rand logic [15:0] data;
  rand logic [11:0] address;
`else
  rand logic [7:0]  data;
  rand logic [11:0] address;
`endif
  int time_ns;
  // Use utility macros to implement standard functions
  // like print, copy, clone, etc
  `uvm_object_utils_begin(sram_item)
    `uvm_field_int (data, UVM_DEFAULT)
    `uvm_field_int (address, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "sram_item");
    super.new(name);
  endfunction
endclass

class gen_sram_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_sram_item_seq)
  function new(string name="gen_sram_item_seq");
    super.new(name);
  endfunction
  
  rand int num; // Config total number of items to be sent
  
  constraint c1 { num inside {[2:50]}; }
  
  virtual task body();
    sram_item s_item = sram_item::type_id::create("s_item");
    
    `uvm_info("sequencer", $sformatf("Generate %d sram_items",num), UVM_LOW)
    
    for (int i = 0; i < num; i ++) begin
        start_item(s_item);
    	s_item.randomize();
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
      write(s_item);
      read(s_item);
      seq_item_port.item_done();
    end
  endtask
    
  virtual task write(sram_item s_item);
    begin
      @ (negedge intf.sys_clk);
      `uvm_info("sram_driver", $sformatf("Write Address: 0x%0h, Data: 0x%0h", s_item.address, s_item.data), UVM_LOW)
      intf.wb_stb_i        = 1;
      intf.wb_cyc_i        = 1;
      intf.wb_we_i         = 1;
      intf.wb_sel_i        = 4'b1111;
      intf.wb_addr_i       = s_item.address;
      intf.wb_dat_i        = s_item.data;

      do begin
        @ (posedge intf.sys_clk);
      end while(intf.wb_ack_o == 1'b0);
      @ (negedge intf.sys_clk);

      intf.wb_stb_i        = 0;
      intf.wb_cyc_i        = 0;
      intf.wb_we_i         = 'hx;
      intf.wb_sel_i        = 'hx;
      intf.wb_addr_i       = 'hx;
      intf.wb_dat_i        = 'hx;    
    end
  endtask
  
  virtual task read(sram_item s_item);
    begin
      @(negedge intf.sys_clk);
      `uvm_info("sram_driver", $sformatf("Read Address: 0x%0h", s_item.address), UVM_LOW)
      
      intf.wb_stb_i        = 1;
      intf.wb_cyc_i        = 1;
      intf.wb_we_i         = 0;
      intf.wb_addr_i       = s_item.address;
      
      do begin
        @ (posedge intf.sys_clk);
      end while(intf.wb_ack_o == 1'b0);
      @ (negedge intf.sdram_clk);
      
      intf.wb_stb_i        = 0;
      intf.wb_cyc_i        = 0;
      intf.wb_we_i         = 'hx;
      intf.wb_addr_i       = 'hx;
      
    end
    
  endtask

endclass