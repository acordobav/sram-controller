class sdram_monitor extends uvm_monitor;
  `uvm_component_utils(sdram_monitor)

  virtual fifo_intf intf; // Interfaz virtual que permite el acceso a las señales del bus SDRAM
  uvm_analysis_port #(sdram_item) mon_analysis_port; // Puerto de análisis para conectar con el scoreboard

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
    if (!uvm_config_db#(virtual fifo_intf)::get(this, "", "VIRTUAL_INTERFACE", intf)) begin
      `uvm_fatal("MONITOR", "No se pudo obtener la interfaz virtual del Configuration DB")
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
    sdram_item item = sdram_item::type_id::create("item", this); // Crea un nuevo item para capturar datos

    forever begin
      @(posedge intf.sys_clk); // Sincronización con el reloj de la interfaz

      // Monitorea la transacción de escritura
      if (intf.wb_stb_i && intf.wb_cyc_i && intf.wb_we_i) begin // Verifica que sea escritura
        item.address = intf.wb_addr_i; // Captura la dirección
        item.data = intf.wb_dat_i; // Captura los datos del bus

        // Espera el acknowledgment para confirmar la escritura
        @(posedge intf.wb_ack_o);
        // Enviar el item al scoreboard usando el análisis port
        mon_analysis_port.write(item);
        
        `uvm_info("sdram_monitor_wr", $sformatf("Escrito - Dirección: 0x%0h | Dato: 0x%0h", item.address, item.data), UVM_LOW);
      end
    end
  endtask

endclass

class sdram_monitor_rd extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_rd)

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    sdram_item item = sdram_item::type_id::create("item", this); // Crea un nuevo item para capturar datos

    forever begin
      @(posedge intf.sys_clk); // Sincronización con el reloj de la interfaz

      // Monitorea la transacción de lectura
      if (intf.wb_stb_i && intf.wb_cyc_i && !intf.wb_we_i) begin // Verifica que sea lectura
        // Espera el acknowledgment antes de capturar los datos
        @(posedge intf.wb_ack_o);
        
        item.address = intf.wb_addr_i; // Captura la dirección
        item.data = intf.wb_dat_o; // Captura los datos de salida del bus

        // Enviar el item al scoreboard usando el análisis port
        mon_analysis_port.write(item);
        
        `uvm_info("sdram_monitor_rd", $sformatf("Leído - Dirección: 0x%0h | Dato: 0x%0h", item.address, item.data), UVM_LOW);
      end
    end
  endtask

endclass
