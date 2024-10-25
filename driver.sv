parameter      dw              = 32;  // data width

class driver;  // Generates the commands for SDRAM controller
	stimulus sti;
	scoreboard sb;

	reg [31:0] ErrCnt;
	parameter P_SYS  = 10;     //    200MHz
	parameter P_SDR  = 20;     //    100MHz

	virtual intf_wb intf; // Instances - Create intf object

	function new(virtual intf_wb intf, scoreboard sb); // Constructor
		this.intf = intf;
		this.sb = sb;
	endfunction

    task init_param(input sys_clk);
	  begin
        sti = new();
        sti.randomize();
        
        intf.Req_Depth    = sti.Req_Depth;
        intf.SDR_Enable   = sti.SDR_Enable;
        intf.SDR_Mode_Reg = sti.SDR_Mode_Reg;
        intf.SDR_tras_d   = sti.SDR_tras_d;
        intf.SDR_trp_d    = sti.SDR_trp_d;
        intf.SDR_trcd_d   = sti.SDR_trcd_d;
        intf.SDR_cas      = sti.SDR_cas;
        intf.SDR_trcar_d  = sti.SDR_trcar_d;
        intf.SDR_twr_d    = sti.SDR_twr_d;
        intf.SDR_rf_sh    = sti.SDR_rf_sh;
        intf.SDR_rf_max   = sti.SDR_rf_max;
        
        $display("[Driver] Parameters being used");
        $display("[Driver] SDRAM Column Depth:                                                  0x%h",sti.Req_Depth);
        $display("[Driver] SDRAM Controller Enable:                                             0x%h",sti.SDR_Enable);
        $display("[Driver] SDRAM Mode Register:                                                 0x%h",sti.SDR_Mode_Reg);
        $display("[Driver] SDRAM Active to Precharge:                                           0x%h",sti.SDR_tras_d);
        $display("[Driver] SDRAM Precharge Command Period:                                      0x%h",sti.SDR_trp_d);
        $display("[Driver] SDRAM Active to Read or Write Delay:                                 0x%h",sti.SDR_trcd_d);
        $display("[Driver] SDRAM CAS Latency:                                                   0x%h",sti.SDR_cas);
        $display("[Driver] SDRAM Active to active/auto-refresh command period:                  0x%h",sti.SDR_trcar_d);
        $display("[Driver] SDRAM Write Recovery time:                                           0x%h",sti.SDR_twr_d);
        $display("[Driver] SDRAM Period between auto-refresh commands issued by the controller: 0x%h",sti.SDR_rf_sh);
        $display("[Driver] SDRAM Maximum number of rows to be refreshed at a time:              0x%h",sti.SDR_rf_max);
      
      end
    endtask
					
	task reset_test(input sys_clk); 

		$display("[Driver] Executing Reset");
		begin 
		ErrCnt        = 0;
		intf.wb_addr_i     = 0;
		intf.wb_dat_i      = 0;
		intf.wb_sel_i      = 4'h0;
		intf.wb_we_i       = 0;
		intf.wb_stb_i      = 0;
		intf.wb_cyc_i      = 0;

		intf.RESETN = 1'h1;
		#100;

		intf.RESETN = 1'h0;
		#10000;

		intf.RESETN = 1'h1;
		
		#1000;
		wait(intf.sdr_init_done == 1);
		#500;
		$display("[Driver] Finish Reset");
		end
		
	endtask


	task burst_write;
	input [31:0] Address;
	input [7:0]  bl;
	int i;
	begin
		sti = new();
		sb.afifo.push_back(Address);
		sb.bfifo.push_back(bl);
	
		@ (negedge intf.sys_clk);
			$display("[Driver] Write Address: %x, Burst Size: %d",Address,bl);

		for(i=0; i < bl; i++) begin
			sti.randomize();
			intf.wb_stb_i        = 1;
			intf.wb_cyc_i        = 1;
			intf.wb_we_i         = 1;
			intf.wb_sel_i        = 4'b1111;
			intf.wb_addr_i       = Address[31:2]+i;
			intf.wb_dat_i        = sti.data; //$random & 32'hFFFFFFFF;
			sb.set(intf.wb_addr_i, intf.wb_dat_i);

			do begin
				@ (posedge intf.sys_clk);
			end while(intf.wb_ack_o == 1'b0);
				@ (negedge intf.sys_clk);

			$display("Status: Burst-No: %d  Write Address: %x  WriteData: %x ",i,intf.wb_addr_i,intf.wb_dat_i);
			end
			intf.wb_stb_i        = 0;
			intf.wb_cyc_i        = 0;
			intf.wb_we_i         = 'hx;
			intf.wb_sel_i        = 'hx;
			intf.wb_addr_i       = 'hx;
			intf.wb_dat_i        = 'hx;
		end
	endtask


	task burst_read;
		reg [31:0] Address;
		reg [7:0]  bl;

		int i,j;
		Address = sb.afifo.pop_front(); 
		bl      = sb.bfifo.pop_front();
		
		begin
			@(negedge intf.sys_clk);

			for(j=0; j < bl; j++) begin
				intf.wb_stb_i        = 1;
				intf.wb_cyc_i        = 1;
				intf.wb_we_i         = 0;
				intf.wb_addr_i       = Address[31:2]+j;
				do begin
					@ (posedge intf.sys_clk);
					end while(intf.wb_ack_o == 1'b0);
					@ (negedge intf.sdram_clk);
			end
			intf.wb_stb_i        = 0;
			intf.wb_cyc_i        = 0;
			intf.wb_we_i         = 'hx;
			intf.wb_addr_i       = 'hx;
			end
	endtask
		
	endclass
