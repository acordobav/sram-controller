class virtual_sequence_sel extends uvm_sequence;
  `uvm_object_utils(virtual_sequence_sel)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  virtual intf_wb intf;
  
  function new(string name="virtual_sequence_sel");
    super.new(name);
  endfunction
  
  // Add Seqr and its Gen for the sequences to be implemented
  init_params_sequencer init_params_seqr;
  reset_sequencer reset_seqr;
  sram_sequencer sram_seqr;
  spec_param_sequencer spec_param_seqr;
  
  gen_init_params_item_seq seq1;
  gen_reset_item_seq seq2;
  gen_sram_item_seq seq3;
  gen_spec_param_item_seq seq_sel_1;
  
  virtual task body();
    
    // Configurar el valor de custom variables en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_SDR_enable", 1'b0);
    uvm_config_db#(logic)::set(null, "", "update_bitColumns", 1'b0);
    uvm_config_db#(logic)::set(null, "", "update_sel", 1'b0);
    
    if (uvm_config_db #(virtual intf_wb)::get(p_sequencer, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    //Sequence 1. Initializing Parameters
    seq1 = gen_init_params_item_seq::type_id::create("seq1");
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    //Sequence 2. Reseting the DUV
    seq2 = gen_reset_item_seq::type_id::create("seq2");
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);
    
    // Configurar el valor de update_sel en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_sel", 1'b0);
    
    //Sequence 3. Randomize Sel
    seq3 = gen_sram_item_seq::type_id::create("seq3");
    
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    
    // Configurar el valor de update_sel en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_sel", 1'b1);
    
    //Sequence 3. Randomize Colum Bits
    //Iteration 1
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 2
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 3
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 4
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 5
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 6
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 7
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 8
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);
    //Iteration 9
    seq3.randomize();
    seq3.start(p_sequencer.sram_seqr);

  endtask
endclass