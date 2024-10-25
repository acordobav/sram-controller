class stimulus;
	rand logic [31:0] Address;
  rand logic [7:0]  bl;
  rand logic [31:0] data; 

  // Randomize Parameters of the module
  rand logic [1:0]  Req_Depth;
  rand logic        SDR_Enable;
  rand logic [12:0] SDR_Mode_Reg;
  rand logic [3:0]  SDR_tras_d;
  rand logic [3:0]  SDR_trp_d;
  rand logic [3:0]  SDR_trcd_d;
  rand logic [2:0]  SDR_cas;
  rand logic [3:0]  SDR_trcar_d;
  rand logic [3:0]  SDR_twr_d;
  rand logic [11:0] SDR_rf_sh;
  rand logic [3:0]  SDR_rf_max;

  // Address must be in range 0x000000 to 0x003FFFFF
  constraint addr_c { Address inside {[32'h00000000:32'h003FFFFF]}; }

  // Burst length (bl) range
  constraint bl_c { bl inside {[1:8]}; }

  // Constraints for Module Parameters
  constraint Req_Depth_limit    {Req_Depth    inside {2'h3,2'h3};}
  constraint SDR_Enable_limit   {SDR_Enable   inside {1,1};}
  constraint SDR_Mode_Reg_limit {SDR_Mode_Reg inside {13'h033,13'h033};}
  constraint SDR_tras_d_limit   {SDR_tras_d   inside {4'h4,4'h4};}
  constraint SDR_trp_d_limit    {SDR_trp_d    inside {4'h2,4'h2};}
  constraint SDR_trcd_d_limit   {SDR_trcd_d   inside {4'h2,4'h2};}
  constraint SDR_cas_limit      {SDR_cas      inside {3'h3,3'h3};}
  constraint SDR_trcar_d_limit  {SDR_trcar_d  inside {4'h7,4'h7};}
  constraint SDR_twr_d_limit    {SDR_twr_d    inside {4'h1,4'h1};}
  constraint SDR_rf_sh_limit    {SDR_rf_sh    inside {12'h100,12'h100};}
  constraint SDR_rf_max_limit   {SDR_rf_max   inside {3'h6,3'h6};}

endclass