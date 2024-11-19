int contador = 0;
bit flag_count = 0; 
int time_ns;
int watchdog;


class sdram_monitor extends uvm_monitor;
  `uvm_component_utils(sdram_monitor)

  virtual intf_wb intf; // Interfaz virtual que permite el acceso a las señales del bus SDRAM
  uvm_analysis_port #(sram_item) mon_analysis_port; // Puerto de análisis para conectar con el scoreboard
  //uvm_analysis_port #(ACR_item) mon_analysis_port2; // Puerto de análisis para conectar con el scoreboard

  // Constructor
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // build_phase: Inicializa el puerto de análisis y obtiene la interfaz virtual de la DB
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Crear el puerto de análisis
    mon_analysis_port = new("mon_analysis_port", this);
   /// mon_analysis_port2 = new("mon_analysis_port2", this);

    // Obtener la interfaz virtual del Configuration DB
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase); // Llamada a la fase base
  endtask

endclass

class sdram_monitor_wr extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_wr)

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    sram_item item = sram_item::type_id::create("item", this); // Crea un nuevo item para capturar datos
    logic wr_op = 1'b0;

    forever begin
      intf.mntr_wr(item.address, item.data, wr_op);

      if(wr_op) begin
        mon_analysis_port.write(item);
        `uvm_info("sdram_monitor_wr", $sformatf("Escrito - Dirección: 0x%0h | Dato: 0x%0h", item.address, item.data), UVM_LOW);
      end
    end
  endtask

endclass

class sdram_monitor_rd extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_rd)

  // Suponiendo una frecuencia de reloj de 1 GHz (1 ciclo = 1 ns)
  real clock_period_ns = 1.0;  // El período del reloj en ns (1 GHz -> 1 ns por ciclo)
  integer cycle_count = 0;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    sram_item item = sram_item::type_id::create("item", this); // Crea un nuevo item para capturar datos
    //ACR_item item2 = ACR_item::type_id::create("item2", this); // Crea un nuevo item para capturar datos

    logic rd_op = 1'b0;

    forever begin
      intf.mntr_rd(item.address, item.data, rd_op);

      if (rd_op) begin
        mon_analysis_port.write(item);
        //mon_analysis_port2.write(item2)
        `uvm_info("sdram_monitor_rd", $sformatf("Leído - Dirección: 0x%0h | Dato: 0x%0h", item.address, item.data), UVM_LOW);
      end
    end
  endtask

endclass

class monitor_ACR extends uvm_monitor;
  `uvm_component_utils(monitor_ACR)
  real clock_period_ns = 1.0;  // El período del reloj en ns (1 GHz -> 1 ns por ciclo)
  integer cycle_count = 0;
  int aref_negedge = 0;
  
  virtual intf_wb intf; // Interfaz virtual que permite el acceso a las señales del bus SDRAM
  uvm_analysis_port #(init_params_item) mon_analysis_port; // Puerto de análisis para conectar con el scoreboard
  //uvm_analysis_port #(ACR_item) mon_analysis_port2; // Puerto de análisis para conectar con el scoreboard

  // Constructor
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // build_phase: Inicializa el puerto de análisis y obtiene la interfaz virtual de la DB
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   
      
    // Crear el puerto de análisis
    mon_analysis_port = new("mon_analysis_port", this);

    // Obtener la interfaz virtual del Configuration DB
    if(uvm_config_db #(virtual intf_wb)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
      
   virtual task run_phase(uvm_phase phase);
    init_params_item item = init_params_item::type_id::create("item", this); // Crea un nuevo item para capturar datos
    
    super.run_phase(phase); // Llamada a la fase base
      forever begin
        @(posedge intf.sys_clk); // Sincronización con el reloj de la interfaz
		watchdog = $time;
        if((watchdog - time_ns) > 340)begin
          time_ns = 0;
          aref_negedge = 0;
          flag_count = 0;
        end
        
        if ( ~intf.sdr_cs_n & ~intf.sdr_ras_n & ~intf.sdr_cas_n & intf.sdr_we_n ) begin
          if(aref_negedge == 1) begin
            item.time_ns = $time - time_ns;
            //`uvm_info("time arriba", $sformatf("Tiempo total (en ns) para %0d ", ($time - time_ns)),UVM_LOW);
            //`uvm_info("time arriba", $sformatf("Tiempo total (en ns) para %0d ", item.time_ns),UVM_LOW);   
            //tiempo_actual - tiempo anterior
            item.signal = intf.SDR_trcar_d;
            mon_analysis_port.write(item);
            aref_negedge = 0;
          end
          if (flag_count == 0) begin
             time_ns = $time;
          end
          
          flag_count = 1;
          //`uvm_info("time abajo", $sformatf("Tiempo total (en ns) para %0d ", $time),UVM_LOW);
          //capturar tiempo
        end
        else begin
          if(flag_count == 1) begin
            aref_negedge = 1;
            flag_count = 0;
          end
        end
       end

  endtask


endclass
