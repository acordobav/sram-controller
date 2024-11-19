class virtual_sequence_en_rst extends uvm_sequence;
  `uvm_object_utils(virtual_sequence_en_rst)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  virtual intf_wb intf;
  
  function new(string name="virtual_sequence_en_rst");
    super.new(name);
  endfunction
  
  // Add Seqr and its Gen for the sequences to be implemented
  init_params_sequencer init_params_seqr;
  reset_sequencer reset_seqr;
  
  gen_init_params_item_seq seq1;
  gen_reset_item_seq seq2;
  
  virtual task body();
    
    // Configurar el valor de custom variables en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_SDR_enable", 1'b0);
    uvm_config_db#(logic)::set(null, "", "update_bitColumns", 1'b0);
    uvm_config_db#(logic)::set(null, "", "update_sel", 1'b0);
    
    if (uvm_config_db #(virtual intf_wb)::get(p_sequencer, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    uvm_config_db#(logic)::set(null, "", "update_SDR_enable", 1'b1);
    
    //Sequence 1. Initializing Parameters
    seq1 = gen_init_params_item_seq::type_id::create("seq1");
    seq2 = gen_reset_item_seq::type_id::create("seq2");
    
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);
    
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);
    
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);
    
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);

  endtask
endclass