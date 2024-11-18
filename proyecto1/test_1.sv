program testcase(intf_wb intf);
  environment env = new(intf);
  stimulus sti;
  
  int k;

  initial
   begin
     sti = new();
     $display("\n-------------------------------------------------- ");
     $display("******************* TESTCASE 1 *******************");
     $display("--------------------------------------------------\n");

     $display("[INFO] Initializing");
     env.drvr.reset_test(intf.sys_clk);
     #1000;

     $display("-------------------------------------- ");
     $display(" Case-1: Single Write/Read Case ");
     $display("--------------------------------------");

     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     #1000; // DELAY 
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     #1000;
     
     $display("-------------------------------------- ");
     $display(" Case-2: Repeat same transfer once again ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     #1000; // DELAY 
     $display("[INFO]---TEST de lectura---");
     env.drvr.burst_read();
     #1000;
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h0040_0000,8'h5);
     #1000; // DELAY 
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();
     #1000;
     
     $display("----------------------------------------");
     $display(" Case:4 4 Write & 4 Read                ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4); #1000; 
     env.drvr.burst_write(32'h5_0000,8'h5); #1000; 
     env.drvr.burst_write(32'h6_0000,8'h6); #1000; 
     env.drvr.burst_write(32'h7_0000,8'h7); 
     #1000; // DELAY
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     env.drvr.burst_read();  
     env.drvr.burst_read();
     env.drvr.burst_read(); 
    

     #1000;
     $display("\n[INFO] ---CHECKER---");
     env.mntr.eot_check();
     
     #1000;$finish;
  
end 
endprogram
