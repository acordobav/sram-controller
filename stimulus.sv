class stimulus;
	rand logic [31:0] Address;
    rand logic [7:0]  bl;
    rand logic [31:0] data; 

  	// Address must be in range 0x000000 to 0x003FFFFF
    constraint addr_c { Address inside {[32'h00000000:32'h003FFFFF]}; }

    // Burst length (bl) range
  constraint bl_c { bl inside {[1:8]}; }
endclass
 

