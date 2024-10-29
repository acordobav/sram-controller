program testcase(intf_wb intf);
  environment env = new(intf);
  stimulus sti;
   
  initial
    begin
     sti = new();
     $display("\n-------------------------------------------------- ");
     $display("******************* TESTCASE 1 *******************");
     $display("--------------------------------------------------\n");

     $display("[INFO] Initializing Parameters for Module"); 
     env.drvr.init_param(intf.sys_clk);

     $display("[INFO] Initializing");
     env.drvr.reset_test(intf.sys_clk);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;

     $display("-------------------------------------- ");
     $display(" Case-1: Single Write/Read Case ");
     $display("--------------------------------------");

     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     
     $display("-------------------------------------- ");
     $display(" Case-2: Repeat same transfer once again ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---TEST de lectura---");
     env.drvr.burst_read();
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h0040_0000,8'h5);
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     
     $display("----------------------------------------");
     $display(" Case:4 4 Write & 4 Read                ");
     $display("----------------------------------------");
     $display("[INFO] ---WRITE Test---");
     env.drvr.burst_write(32'h4_0000,8'h4);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h5_0000,8'h5);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h6_0000,8'h6);      
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     env.drvr.burst_write(32'h7_0000,8'h7); 
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("[INFO]---READ Test---");
     env.drvr.burst_read();  
     env.drvr.burst_read();  
     env.drvr.burst_read();
     env.drvr.burst_read(); 
    

     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $display("\n[INFO] ---CHECKER---");
     env.mntr.eot_check();
     
     sti.t_delay = tiempo(); // Update t_delay with a new random value
     #sti.t_delay;
     $finish;
  
	end 
endprogram

function int tiempo();
    tiempo = $urandom_range(1000, 10000); // Devuelve el valor generado
endfunction