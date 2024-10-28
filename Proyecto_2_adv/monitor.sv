class monitor extends uvm_monitor;
  `uvm_component_utils (monitor)

  virtual intf_wb intf;

  // Puerto de analisis para comunicar con SB
  uvm_analysis_port#(sdram_item) sdram_analysis;

  //Variables necesarias
  reg [31:0] sb_value;
  reg [31:0] ErrCnt;
  reg [31:0] Address;
  reg [7:0]  bl;
  int i,j;
  reg [31:0]   exp_data;

  //Constructor
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //Build Phase. Obtener interfaz
    if (!uvm_config_db#(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf))
      `uvm_fatal("INTERFACE", "No se pudo obtener la interfaz")
    
    //Init puerto de analisis
    sdram_analysis = new("sdram_analysis", this);
  endfunction

  //Execution Phase
  virtual task run_phase(uvm_phase phase);
    sdram_item item;
    ErrCnt = 0;

    forever begin
      @(posedge intf.sys_clk) begin
        if (intf.wb_ack_o == 1'b1 && intf.wb_we_i == 1'b0) begin
          item = sdram_item::type_id::create("item"); //Nueva transaccion

          //Capturar datos
          item.address = intf.wb_addr_i;
          item.data = intf.wb_dat_o;

          //Analysis (comm with SB)
          sdram_analysis.write(item);

          //Not sure about this
          if(item.data !== item.exp_data) begin
            `uvm_error("MONITOR", $sformatf("READ ERROR: Addr: %x Rxp: %x Exp: %x", item.address, item.data, item.exp_data));
            ErrCnt++;
          end else begin
            `uvm_info("MONITOR", $sformatf("READ STATUS: Addr: %x Rxd: %x", item.address, item.data), UVM_LOW);
          end 
        end
      end
    end
  endtask
endclass

/*
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
          exp_data = sb.get(intf.wb_addr_i);
          
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
*/