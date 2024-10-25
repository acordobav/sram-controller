program testcase(intf_wb intf);
  environment env = new(intf);
  stimulus sti;
  
  int k;

  initial
   begin
     sti = new();
     $display("\n-------------------------------------------------- ");
     $display("******************* TESTCASE 2 *******************");
     $display("--------------------------------------------------\n");

     $display("[INFO] Initializing Parameters for Module"); 
     env.drvr.init_param(intf.sys_clk);

     $display("[INFO] Initializing");
     env.drvr.reset_test(intf.sys_clk);
     #1000;

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
       #1000;
       $display("[INFO] ---READ Test---");
       env.drvr.burst_read();  
       #1000;
     end

     #10000;

     $display("\n[INFO] ---CHECKER---");
     env.mntr.eot_check();
     #100;
     $finish;
  
end 
endprogram
