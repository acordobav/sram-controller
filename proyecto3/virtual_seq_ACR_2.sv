class virtual_sequence_ACR_2 extends uvm_sequence;
  `uvm_object_utils(virtual_sequence_ACR_2)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  rand logic [14:0] t_delay;
  
  function new(string name="virtual_sequence_ACR_2");
    super.new(name);
  endfunction
  
  // Add Seqr and its Gen
  init_params_sequencer init_params_seqr;
  reset_sequencer reset_seqr;
  sram_sequencer sram_seqr;
  
  gen_init_params_item_seq seq1;
  gen_reset_item_seq seq2;
  gen_sram_item_seq seq3;
  
  virtual task body();
    
    seq1 = gen_init_params_item_seq::type_id::create("seq1");
    seq2 = gen_reset_item_seq::type_id::create("seq2");
    seq3 = gen_sram_item_seq::type_id::create("seq3");
    
    for (int i = 0; i < 20; i ++) begin
      seq1.randomize();
      seq1.start(p_sequencer.init_params_seqr);
      seq2.randomize();
      seq2.start(p_sequencer.reset_seqr);
      seq3.randomize();
      seq3.start(p_sequencer.sram_seqr);
      t_delay=t_f2(); // to randomize t_delay 
    #t_delay;
    end
    
  endtask
endclass


function int t_f2();
    t_f2 = $urandom_range(1000, 10000); 
endfunction
