class virtual_sequence_colBits extends uvm_sequence;
  `uvm_object_utils(virtual_sequence_colBits)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  virtual intf_wb intf;
  
  function new(string name="virtual_sequence_colBits");
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
  gen_spec_param_item_seq seq_colBits_1;
  
  virtual task body();
    
     // Configurar el valor de update_bitColumns en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_CAS_latency", 1'b0);
    
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
    
    // Configurar el valor de update_bitColumns en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_bitColumns", 1'b0);
    
    //Sequence 3. Randomize Colum Bits
    seq_colBits_1 = gen_spec_param_item_seq::type_id::create("seq_colBits_1");
    
    seq_colBits_1.randomize();
    seq_colBits_1.start(p_sequencer.spec_param_seqr);
    
    // Configurar el valor de update_bitColumns en uvm_config_db
    uvm_config_db#(logic)::set(null, "", "update_bitColumns", 1'b1);
    
    //Sequence 3. Randomize Colum Bits
    
    seq_colBits_1.randomize();
    seq_colBits_1.start(p_sequencer.spec_param_seqr); 
    
    seq_colBits_1.randomize();
    seq_colBits_1.start(p_sequencer.spec_param_seqr); 
    
    seq_colBits_1.randomize();
    seq_colBits_1.start(p_sequencer.spec_param_seqr); 
    
    seq_colBits_1.randomize();
    seq_colBits_1.start(p_sequencer.spec_param_seqr); 

  endtask
endclass