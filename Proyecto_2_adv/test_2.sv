class test_basic2 extends test_1;

  `uvm_component_utils(test_basic2)
 
  function new(string name = "test_basic2", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new  
  
  
  environment env = new(intf);
  stimulus sti;
  int k;

  initial
   begin
     sti = new();
     $display("\n-------------------------------------------------- ");
     $display("******************* TESTCASE 2 *******************");
     $display("--------------------------------------------------\n");

     $display("[INFO] Initializing");
     env.drvr.reset_test(intf.sys_clk);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;

     $display("---------------------------------------------------");
     $display(" Case: 6 Random 2 write and 2 read random");
     $display("---------------------------------------------------");
     
     // Randomly generates stimulus for Address and burst length (bl)
     if (!sti.randomize()) begin
       $display("[ERROR] Random generation failed.");
       $finish;
     end

     for(k=0; k < 2; k++) begin
       $display("[INFO] ---WRITE Test---");
       env.drvr.burst_write(sti.Address,sti.bl); 
       sti.t_delay = tiempo(); // Update t_delay with a new random value
       #sti.t_delay;
       $display("[INFO] ---READ Test---");
       env.drvr.burst_read();  
       sti.t_delay = tiempo(); // Update t_delay with a new random value
       #sti.t_delay;
     end

     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;

     $display("\n[INFO] ---CHECKER---");
     env.mntr.eot_check();
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $finish;
  
end 
endclass


function int tiempo();
    tiempo = $urandom_range(1000, 10000); // Devuelve el valor generado
endfunction
