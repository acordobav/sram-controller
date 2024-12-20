class environment;
  driver drvr;
  scoreboard sb;
  monitor mntr;
  virtual intf_wb intf;
           
  function new(virtual intf_wb intf);
    $display("Creating environment");
    this.intf = intf;
    sb = new();
    drvr = new(intf, sb);
    mntr = new(intf,sb);
    fork 
      mntr.check();
    join_none
  endfunction
           
endclass
