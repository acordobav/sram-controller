interface intf_wb #(parameter dw=32) (input sys_clk, sdram_clk);  //Communicates TB and DUT
    
  //--------------------------------------
  // Wish Bone Interface
  // -------------------------------------      
  logic             wb_stb_i;
  logic             wb_ack_o;
  logic [25:0]      wb_addr_i;
  logic             wb_we_i;  // 1 - Write, 0 - Read
  logic [dw-1:0]    wb_dat_i;
  logic [dw/8-1:0]  wb_sel_i; // Byte enable
  logic [dw-1:0]    wb_dat_o;
  logic             wb_cyc_i;
  logic [2:0]       wb_cti_i;
  
  logic sys_clk;
  logic RESETN;

  //--------------------------------------------
  // SDRAM I/F 
  //--------------------------------------------
`ifdef SDR_32BIT
  wire [31:0]      sdr_dq;         // SDRAM Read/Write Data Bus
  wire [3:0]       sdr_dqm ;       // SDRAM DATA Mask
`elsif SDR_16BIT 
  wire [15:0]      sdr_dq;         // SDRAM Read/Write Data Bus
  wire [1:0]       sdr_dqm ;       // SDRAM DATA Mask
`else 
  wire [7:0]       sdr_dq;         // SDRAM Read/Write Data Bus
  wire [0:0]       sdr_dqm;        // SDRAM DATA Mask
`endif

  logic [1:0]       sdr_ba;        // SDRAM Bank Select
  logic [12:0]      sdr_addr;      // SDRAM ADRESS
  logic             sdr_init_done; // SDRAM Init Done 
  
  logic sdram_clk;
  
  logic sdr_cke;
  logic sdr_cs_n;
  logic sdr_ras_n;
  logic sdr_cas_n;
  logic sdr_we_n;

  //--------------------------------------------
  // MODULE PARAMS
  //--------------------------------------------
  logic [1:0]  Req_Depth;
  logic        SDR_Enable;
  logic [12:0] SDR_Mode_Reg;
  logic [3:0]  SDR_tras_d;
  logic [3:0]  SDR_trp_d;
  logic [3:0]  SDR_trcd_d;
  logic [2:0]  SDR_cas;
  logic [3:0]  SDR_trcar_d;
  logic [3:0]  SDR_twr_d;
  logic [11:0] SDR_rf_sh;
  logic [3:0]  SDR_rf_max;

  task reset();
    $display("Executing Reset");
	  // ErrCnt          = 0;
    intf.wb_addr_i     = 0;
    intf.wb_dat_i      = 0;
    intf.wb_sel_i      = 4'h0;
    intf.wb_we_i       = 0;
    intf.wb_stb_i      = 0;
    intf.wb_cyc_i      = 0;

	  // Seq of reset
    intf.RESETN        = 1'h1;
    #100;
    intf.RESETN        = 1'h0;
    #10000
    intf.RESETN        = 1'h1;
    #1000;
    wait(intf.sdr_init_done == 1);
    #500;
    $display("Finish Reset");
  endtask

  task write(input logic[11:0] address,
             input logic[31:0] data);
    begin
      @ (negedge intf.sys_clk);
      intf.wb_stb_i        = 1;
      intf.wb_cyc_i        = 1;
      intf.wb_we_i         = 1;
      intf.wb_sel_i        = 4'b1111;
      intf.wb_addr_i       = address;
      intf.wb_dat_i        = data;

      do begin
        @ (posedge intf.sys_clk);
      end while(intf.wb_ack_o == 1'b0);
      @ (negedge intf.sys_clk);

      intf.wb_stb_i        = 0;
      intf.wb_cyc_i        = 0;
      intf.wb_we_i         = 'hx;
      intf.wb_sel_i        = 'hx;
      intf.wb_addr_i       = 'hx;
      intf.wb_dat_i        = 'hx;    
    end
  endtask

  task read(input logic[11:0] address);
    begin
      @(negedge intf.sys_clk);
      intf.wb_stb_i        = 1;
      intf.wb_cyc_i        = 1;
      intf.wb_we_i         = 0;
      intf.wb_addr_i       = address;
      
      do begin
        @ (posedge intf.sys_clk);
      end while(intf.wb_ack_o == 1'b0);
      @ (negedge intf.sdram_clk);
      
      intf.wb_stb_i        = 0;
      intf.wb_cyc_i        = 0;
      intf.wb_we_i         = 'hx;
      intf.wb_addr_i       = 'hx;
    end
  endtask

  task mntr_wr(output logic[11:0] address,
               output logic[31:0] data,
               output logic wr_op);
    // Sincronización con el reloj de la interfaz
    @(posedge intf.sys_clk);

    // Verificar que sea una transaccion de escritura
    wr_op = intf.wb_stb_i && intf.wb_cyc_i && intf.wb_we_i;

    if (wr_op) begin
      address = intf.wb_addr_i; // Captura la dirección
      data =    intf.wb_dat_i;  // Captura los datos del bus
      @(posedge intf.wb_ack_o); // Espera el acknowledgment para confirmar la escritura
    end
  endtask

  task mntr_rd(output logic[11:0] address,
               output logic[31:0] data,
               output logic rd_op);
    // Sincronización con el reloj de la interfaz
    @(posedge intf.sys_clk);

    // Verificar que sea una transacción de lectura
    rd_op = intf.wb_ack_o == 1'b1 && intf.wb_we_i == 1'b0;
    
    if (rd_op) begin
      address = intf.wb_addr_i; // Captura la dirección
      data = intf.wb_dat_o;     // Captura los datos de salida del bus
    end
  endtask

endinterface
