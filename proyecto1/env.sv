class environment extends uvm_env;

 `uvm_component_utils(environment)
  
  function new (string name = "environment", uvm_component parent = null);
    super.new (name, parent);
  endfunction

  virtual intf_wb intf;
           
  //.. continuar para modificarlo a UVM 
  
  /* function new(virtual intf_wb intf);
    $display("Creating environment");
    this.intf = intf;
    sb = new();
    drvr = new(intf, sb);
    mntr = new(intf,sb);
    fork 
      mntr.check();
    join_none
  endfunction*/
  
  
endclass
