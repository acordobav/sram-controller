class virtual_sequence extends uvm_sequence;
  `uvm_object_utils(virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  rand logic [14:0] t_delay;
  int num_repeats =2;
  
  function new(string name="virtual_sequence");
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
    
    seq1.randomize();
    seq1.start(p_sequencer.init_params_seqr);
    
    t_delay=t_f(); // to randomize t_delay 
    #t_delay;
    
    seq2 = gen_reset_item_seq::type_id::create("seq2");
    
    seq2.randomize();
    seq2.start(p_sequencer.reset_seqr);
    
    t_delay=t_f(); // to randomize t_delay 
    #t_delay;
    
    for (int i = 0; i < num_repeats; i++) begin
      seq3 = gen_sram_item_seq::type_id::create("seq3");
      seq3.randomize();
      seq3.start(p_sequencer.sram_seqr);
    end
  endtask
endclass


function int t_f();
    t_f = $urandom_range(1000, 10000); 
endfunction
