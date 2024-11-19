class spec_param_item extends uvm_sequence_item;
  
  // Randomize Parameters of the module
  randc logic [1:0]  bitColumns;
  rand logic  [1:0]  CAS_latency;
  
  logic              update_bitColumns;
  logic              update_CAS_latency;
  
  // Constraints for Module Parameters
  constraint bit_Columns_limit    {bitColumns < 4;}
  
  constraint valid_CAS {
    CAS_latency inside {2, 3};
  }

  `uvm_object_utils_begin(spec_param_item)
  	`uvm_field_int (bitColumns, UVM_DEFAULT)
  	`uvm_field_int (CAS_latency, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "spec_param_item");
    super.new(name);
    update_bitColumns  = 1'b0;
    update_CAS_latency = 1'b0;
    bitColumns         = 2'b00;
    CAS_latency        = 2'h3;
  endfunction
  
endclass

class gen_spec_param_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_spec_param_item_seq)
  
  function new(string name="gen_spec_param_item_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    spec_param_item n_param = spec_param_item::type_id::create("n_param");
    
    start_item(n_param);
    
    // Recupera el valor de 'update_bitColumns' desde uvm_config_db
    if (!uvm_config_db#(logic)::get(null, "", "update_bitColumns", n_param.update_bitColumns)) begin
      `uvm_warning("SEQ", "No se configuró el valor de update_bitColumns en uvm_config_db, usando valor por defecto.")
    end
    
    // Recupera el valor de 'update_CAS_latency' desde uvm_config_db
    if (!uvm_config_db#(logic)::get(null, "", "update_CAS_latency", n_param.update_CAS_latency)) begin
      `uvm_warning("SEQ", "No se configuró el valor de update_CAS_latency en uvm_config_db, usando valor por defecto.")
    end

    `uvm_info("SEQ", $sformatf("Generated Spec Param with update_bitColumns: %0b and update_CAS_latency: %0b", n_param.update_bitColumns, n_param.update_CAS_latency), UVM_LOW)
    
    if(n_param.update_bitColumns || n_param.update_CAS_latency) begin
      n_param.randomize();
    end else begin
      `uvm_info("SEQ", $sformatf("Skipping update of the bitColumns value. Update flag was read as FALSE."), UVM_LOW)
    end
    
    `uvm_info("SEQ", $sformatf("Generated PARAM: "), UVM_LOW)
    n_param.print();
    
    finish_item(n_param);
  endtask
endclass

class spec_param_driver extends uvm_driver #(spec_param_item);
  `uvm_component_utils(spec_param_driver)
  
  function new (string name="spec_param_driver", uvm_component parent=null);
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
      spec_param_item n_param;
      `uvm_info("DRV_SPEC_PAR", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(n_param);
      if (n_param.update_bitColumns) begin
        bit_columns_drive(n_param);
      end else if (n_param.update_CAS_latency) begin
        CAS_latency_drive(n_param);
      end else begin
        `uvm_info("DRV_SPEC_PAR", $sformatf("No specific parameter to be updated"), UVM_LOW)
      end
      seq_item_port.item_done();
    end
  endtask
  
  virtual task bit_columns_drive(spec_param_item n_param);
    $display("[Driver INIT PARAMS] Updating Column Bits");
    intf.Col_bits = n_param.bitColumns;
    $display("[Driver INIT PARAMS] Colum Bits updated to %0d", n_param.bitColumns);
  endtask
  
  virtual task CAS_latency_drive(spec_param_item n_param);
    $display("[Driver INIT PARAMS] Updating CAS Latency");
    
    intf.SDR_Mode_Reg = 1'b1;
    intf.SDR_cas = n_param.CAS_latency;
    intf.SDR_Mode_Reg = 1'b0;
    
    intf.sdr_cs_n  = 1'b0;
    intf.sdr_ras_n = 1'b0;
    intf.sdr_cas_n = 1'b0;
    intf.sdr_we_n  = 1'b0;
    if (n_param.CAS_latency == 2'h1) begin
      intf.sdr_addr  = 11'b00000010011;
    end else if (n_param.CAS_latency == 2'h2) begin
      intf.sdr_addr  = 11'b00000100011;
    end else begin
      intf.sdr_addr  = 11'b00000110011;
    end
    intf.sdr_cs_n  = 1'b0;
    intf.sdr_ras_n = 1'b0;
    intf.sdr_cas_n = 1'b0;
    intf.sdr_we_n  = 1'b1;
    
    $display("[Driver INIT PARAMS] CAS Latency updated to %0d", n_param.CAS_latency);
  endtask
  
endclass