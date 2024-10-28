parameter      dw              = 32;  // data width

class driver extends uvm_driver#(sdram_item);
	`uvm_component_utils(driver)

	virtual intf_wb intf; // Instances - Create intf object
	scoreboard sb;	

	reg [31:0] ErrCnt;
	parameter P_SYS  = 10;     //    200MHz
	parameter P_SDR  = 20;     //    100MHz

	function new(string name = "driver", uvm_component_parent = null);
		super.new(name, parent);
	endfunction

	// Interfaz y Scoreboard init
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf))
    		`uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
		if (!uvm_config_db #(scoreboard)::get(this, "", "SCOREBOARD", sb))
    		`uvm_fatal("SCOREBOARD_CONNECT", "Could not get from the database the scoreboard for the TB")
	endfunction
	
	task run_phase(uvm_phase phase);
		sdram_item req;

		forever begin
			//Init Transaction
			seq_item_port.get_next_item(req);

			case(req.get_type_name())

				"init_params_item" begin:
					init_params_item init_tr = init_params_item::type_id::create("init_tr");
          			init_tr.copy(req);
          			init_param(init_tr);
				end

				"write_data_item" begin:
					write_data_item write_tr = write_data_item::type_id::create("write_tr");
          			write_tr.copy(req);
          			burst_write(write_tr);
				end

				"read_data_item" begin:
					read_data_item read_tr = read_data_item::type_id::create("read_tr");
          			read_tr.copy(req);
					burst_read(read_tr);
				end

				default: `uvm_error("DRIVER", $sformatf("Unknown Sequence item %s", req.get_type_name()))
			endcase

			//End Transaction
			seq_item_port.item_done();
		end
	endtask

    task init_param(init_params_item req);
		$display("[Driver] Init SDRAM PARAMETERS");
		begin
			intf.Req_Depth    = req.Req_Depth;
			intf.SDR_Enable   = req.SDR_Enable;
			intf.SDR_Mode_Reg = req.SDR_Mode_Reg;
			intf.SDR_tras_d   = req.SDR_tras_d;
			intf.SDR_trp_d    = req.SDR_trp_d;
			intf.SDR_trcd_d   = req.SDR_trcd_d;
			intf.SDR_cas      = req.SDR_cas;
			intf.SDR_trcar_d  = req.SDR_trcar_d;
			intf.SDR_twr_d    = req.SDR_twr_d;
			intf.SDR_rf_sh    = req.SDR_rf_sh;
			intf.SDR_rf_max   = req.SDR_rf_max;
			
			$display("[Driver] Parameters being used");
			$display("[Driver] SDRAM Column Depth:                                                  0x%h",req.Req_Depth);
			$display("[Driver] SDRAM Controller Enable:                                             0x%h",req.SDR_Enable);
			$display("[Driver] SDRAM Mode Register:                                                 0x%h",req.SDR_Mode_Reg);
			$display("[Driver] SDRAM Active to Precharge:                                           0x%h",req.SDR_tras_d);
			$display("[Driver] SDRAM Precharge Command Period:                                      0x%h",req.SDR_trp_d);
			$display("[Driver] SDRAM Active to Read or Write Delay:                                 0x%h",req.SDR_trcd_d);
			$display("[Driver] SDRAM CAS Latency:                                                   0x%h",req.SDR_cas);
			$display("[Driver] SDRAM Active to active/auto-refresh command period:                  0x%h",req.SDR_trcar_d);
			$display("[Driver] SDRAM Write Recovery time:                                           0x%h",req.SDR_twr_d);
			$display("[Driver] SDRAM Period between auto-refresh commands issued by the controller: 0x%h",req.SDR_rf_sh);
			$display("[Driver] SDRAM Maximum number of rows to be refreshed at a time:              0x%h",req.SDR_rf_max);
			
		end
    endtask
					
	task reset_test(input sys_clk);
		$display("[Driver] Executing Reset");
		begin 
		ErrCnt             = 0;
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

	task burst_write(write_data_item req);
		input [31:0] Address;
		input [7:0]  bl;
		int i;
		begin
			//sti = new();
			sb.afifo.push_back(Address);
			sb.bfifo.push_back(bl);
		
			@ (negedge intf.sys_clk);
				$display("[Driver] Write Address: %x, Burst Size: %d",Address,bl);

			for(i=0; i < bl; i++) begin
				//sti.randomize();
				intf.wb_stb_i        = 1;
				intf.wb_cyc_i        = 1;
				intf.wb_we_i         = 1;
				intf.wb_sel_i        = 4'b1111;
				intf.wb_addr_i       = Address[31:2]+i;
				intf.wb_dat_i        = req.data; //$random & 32'hFFFFFFFF;
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

	task burst_read(read_data_item req);
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