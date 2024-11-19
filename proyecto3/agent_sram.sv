class agent_sram_active extends uvm_agent;
  `uvm_component_utils(agent_sram_active)
  function new(string name="agent_sram_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  sram_driver sram_drv;
  sram_sequencer sram_seqr;
  sdram_monitor_wr mntr_wr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    sram_drv = sram_driver::type_id::create ("sram_drv", this); 
    
    sram_seqr = sram_sequencer::type_id::create("sram_seqr", this);
    
    mntr_wr = sdram_monitor_wr::type_id::create ("mntr_wr", this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sram_drv.seq_item_port.connect(sram_seqr.seq_item_export);
  endfunction

endclass

//////PASSIVE///////
class agent_sram_passive extends uvm_agent;
  `uvm_component_utils(agent_sram_passive)
  function new(string name="agent_sram_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  
  sdram_monitor_rd mntr_rd;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    mntr_rd = sdram_monitor_rd::type_id::create ("mntr_rd", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass