interface intf_wb #(parameter dw=32, data_bits=32) (input sys_clk, sdram_clk);  //Communicates TB and DUT
	
  //wishbone
  	logic 				wb_stb_i;
	logic 				wb_ack_o;
    logic [25:0] 		wb_addr_i;
	logic 				wb_we_i; // 1 - Write, 0 - Read
	logic [dw-1:0]  	wb_dat_i;
	logic [dw/8-1:0] 	wb_sel_i; // Byte enable
	logic [dw-1:0]  	wb_dat_o;
	logic 				wb_cyc_i;
    logic [2:0]	 		wb_cti_i;
  
 	logic sys_clk;
  	logic RESETN;

  //SDRAM
  wire  [data_bits - 1 : 0] sdr_dq; // SDRAM Read/Write Data Bus // INOUT // Se crearon 2
    logic [3:0] sdr_dqm; // SDRAM DATA Mask
    logic [1:0] sdr_ba; // SDRAM Bank Select
    logic [12:0] sdr_addr; // SDRAM ADRESS
	logic sdr_init_done; // SDRAM Init Done 
  
    logic sdram_clk;
  
	logic sdr_cke;
    logic sdr_cs_n;
    logic sdr_ras_n;
    logic sdr_cas_n;
  	logic sdr_we_n;

endinterface
