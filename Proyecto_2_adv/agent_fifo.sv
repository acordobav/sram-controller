class agent_fifo_active extends uvm_agent;
  `uvm_component_utils(agent_fifo_active)
  function new(string name="agent_fifo_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  driver drv;  //fifo driver
  init_params_sequencer seqr;
  monitor_wr mntr_wr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    drv = driver::type_id::create ("drv", this); //fifo driver
    
    seqr = init_params_sequencer::type_id::create("seqr", this);
    
    mntr_wr = monitor_wr::type_id::create ("mntr_wr", this);
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.env.fifo_ag.fifo_drv", "VIRTUAL_INTERFACE", intf);    

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(fifo_seqr.seq_item_export); //review this  MODIFY when Drivers ports are ready
  endfunction
  endfunction

endclass

//////PASSIVE///////
class agent_fifo_passive extends uvm_agent;
  `uvm_component_utils(agent_fifo_passive)
  function new(string name="agent_fifo_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_wb intf;
  
  fifo_monitor_rd fifo_mntr_rd;  //MODIFY according with JuanPa
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    fifo_mntr_rd = fifo_monitor_rd::type_id::create ("fifo_mntr_rd", this); // //MODIFY according with JuanPa
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
