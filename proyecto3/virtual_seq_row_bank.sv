class gen_sram_item_seq_row_bank extends uvm_sequence;
  `uvm_object_utils(gen_sram_item_seq_row_bank)
  function new(string name="gen_sram_item_seq_row_bank");
    super.new(name);
  endfunction
  
  logic [23:0] addresses[24];

  virtual task body();
    sram_item s_item = sram_item::type_id::create("s_item");

    $display("---------------------------------------");
    $display(" Case: 24 Write & 24 Read With Different Bank and Row ");
    $display("---------------------------------------");

    // Address Decodeing:
    //  with cfg_col bit configured as: 00
    //    <12 Bit Row> <2 Bit Bank> <8 Bit Column> <2'b00>
    
    addresses[00] = {12'h000,2'b00,8'h00,2'b00};   // Row: 0 Bank : 0
    addresses[01] = {12'h000,2'b01,8'h00,2'b00};   // Row: 0 Bank : 1
    addresses[02] = {12'h000,2'b10,8'h00,2'b00};   // Row: 0 Bank : 2
    addresses[03] = {12'h000,2'b11,8'h00,2'b00};   // Row: 0 Bank : 3
    addresses[04] = {12'h001,2'b00,8'h00,2'b00};   // Row: 1 Bank : 0
    addresses[05] = {12'h001,2'b01,8'h00,2'b00};   // Row: 1 Bank : 1
    addresses[06] = {12'h001,2'b10,8'h00,2'b00};   // Row: 1 Bank : 2
    addresses[07] = {12'h001,2'b11,8'h00,2'b00};   // Row: 1 Bank : 3

    addresses[08] = {12'h002,2'b00,8'h00,2'b00};   // Row: 2 Bank : 0
    addresses[09] = {12'h002,2'b01,8'h00,2'b00};   // Row: 2 Bank : 1
    addresses[10] = {12'h002,2'b10,8'h00,2'b00};   // Row: 2 Bank : 2
    addresses[11] = {12'h002,2'b11,8'h00,2'b00};   // Row: 2 Bank : 3
    addresses[12] = {12'h003,2'b00,8'h00,2'b00};   // Row: 3 Bank : 0
    addresses[13] = {12'h003,2'b01,8'h00,2'b00};   // Row: 3 Bank : 1
    addresses[14] = {12'h003,2'b10,8'h00,2'b00};   // Row: 3 Bank : 2
    addresses[15] = {12'h003,2'b11,8'h00,2'b00};   // Row: 3 Bank : 3

    addresses[16] = {12'h002,2'b00,8'h00,2'b00};   // Row: 2 Bank : 0
    addresses[17] = {12'h002,2'b01,8'h01,2'b00};   // Row: 2 Bank : 1
    addresses[18] = {12'h002,2'b10,8'h02,2'b00};   // Row: 2 Bank : 2
    addresses[19] = {12'h002,2'b11,8'h03,2'b00};   // Row: 2 Bank : 3
    addresses[20] = {12'h003,2'b00,8'h04,2'b00};   // Row: 3 Bank : 0
    addresses[21] = {12'h003,2'b01,8'h05,2'b00};   // Row: 3 Bank : 1
    addresses[22] = {12'h003,2'b10,8'h06,2'b00};   // Row: 3 Bank : 2
    addresses[23] = {12'h003,2'b11,8'h07,2'b00};   // Row: 3 Bank : 3

    for (int i = 0; i < 24; i++) begin
      start_item(s_item);
      s_item.address = addresses[i];
      s_item.data = $random & 32'hFFFFFFFF;
      s_item.print();
      finish_item(s_item);
    end
  endtask
endclass

class virtual_sequence_row_bank extends uvm_sequence;
  `uvm_object_utils(virtual_sequence_row_bank)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  virtual intf_wb intf;
  
  function new(string name="virtual_sequence_row_bank");
    super.new(name);
  endfunction
  
  // Add Seqr and its Gen for the sequences to be implemented
  init_params_sequencer init_params_seqr;
  reset_sequencer reset_seqr;
  sram_sequencer sram_seqr;
  
  gen_init_params_item_seq seq1;
  gen_reset_item_seq seq2;
  gen_sram_item_seq_row_bank seq3;
  
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
    
    // Sequence 3. Prueba dirigida
    seq3 = gen_sram_item_seq_row_bank::type_id::create("seq3");
    seq3.start(p_sequencer.sram_seqr);

  endtask
endclass