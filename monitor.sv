class monitor;
  scoreboard sb;
  virtual intf_wb intf;
          
  reg [31:0] sb_value;
  reg [31:0] ErrCnt;
  reg [31:0] Address;
  reg [7:0]  bl;
  int i,j;
  reg [31:0]   exp_data;
  
  
  function new(virtual intf_wb intf,scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction
          
  task check();
    reg [31:0] Address;
	reg [7:0]  bl;
	int i,j;
    ErrCnt= 0;
    
    
    forever begin
      @(posedge intf.sys_clk) begin
        if (intf.wb_ack_o == 1'b1 && intf.wb_we_i == 1'b0)begin
          exp_data = sb.dfifo.pop_front();
          if(intf.wb_dat_o !== exp_data) begin
                   $display("[Monitor] READ ERROR: Addr: %x Rxp: %x Exp: %x",intf.wb_addr_i,intf.wb_dat_o,exp_data);
             ErrCnt = ErrCnt+1;
          end
          else begin
            $display("[Monitor] READ STATUS: Addr: %x Rxd: %x",intf.wb_addr_i,intf.wb_dat_o);
          end 
        end
      end
    end
  endtask
  
  task eot_check(); //end of test checker
    begin
         if(ErrCnt == 0) begin
            $display("STATUS: SDRAM Write/Read TEST PASSED");
           $display("#############################################\n");
         end
         else begin
            $display("ERROR:  SDRAM Write/Read TEST FAILED");
           $display("#############################################\n"); 
         end
    end
  endtask
  
endclass

