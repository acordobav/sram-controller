class environment extends uvm_env;
 `uvm_component_utils(environment)
  
  function new (string name = "environment", uvm_component parent = null);
    super.new (name, parent);
  endfunction

  virtual intf_wb intf;
  
  //Sequencers
  init_params_agent init_params_ag;
  reset_agent reset_ag;
  agent_sram_active sram_ag;
  agent_sram_passive sram_ag_passive;
  scoreboard sram_sb;
  virtual_sequencer virtual_seqr;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    //Add here Sqcr, Sqc, etc
    init_params_ag = init_params_agent::type_id::create ("init_params_ag", this);
    reset_ag = reset_agent::type_id::create ("reset_ag", this);
    sram_ag = agent_sram_active::type_id::create ("sram_ag", this);
    sram_ag_passive = agent_sram_passive::type_id::create ("sram_ag_passive", this);
    sram_sb = scoreboard::type_id::create ("sram_sb", this);
    virtual_seqr = virtual_sequencer::type_id::create ("virtual_seqr", this);
      
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();

  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sram_ag.mntr_wr.mon_analysis_port.connect(sram_sb.sram_drv);
    sram_ag_passive.mntr_rd.mon_analysis_port.connect(sram_sb.sram_mon);
    virtual_seqr.reset_seqr = reset_ag.reset_seqr;
    virtual_seqr.init_params_seqr = init_params_ag.init_params_seqr;
    virtual_seqr.sram_seqr = sram_ag.sram_seqr;
  endfunction
  
endclass
