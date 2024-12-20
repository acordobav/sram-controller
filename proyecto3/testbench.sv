// =============================================================================
// Instituto Tecnológico de Costa Rica                                                  
// Escuela de Ingeniería Electrónica                                                    
// Carrera de Maestría en Electrónica  
//
// Verificación Funcional (MP6134)                                                     
// Prof. Gerardo Castro Jiménez 
//
//
// 							Proyecto #2: 
// Fecha de entrega: Martes 29 de octubre del 2024, a las 6:30pm
//
// Descripción: 
// 	Crear un modelo de Verificación Funcional utilizando el estándar UVM 
//
// GR-02:
// 		Jill Carranza
// 		Arturo Córdoba
// 		Juan Pablo Ureña
// 		Victor Sánchez                                              
//                                                       
// =============================================================================


`timescale 1ns/1ps
`define S60

`include "top_hvl.sv"
`include "interface.sv"

`include "init_params_driver.sv"
`include "reset_driver.sv"
`include "sram_driver.sv"
`include "spec_param_driver.sv"

`include "init_params_seqr.sv"
`include "reset_seqr.sv"
`include "sram_sqer.sv"
`include "spec_param_seqr.sv"

`include "virtual_seqr.sv"
`include "virtual_seq.sv"
`include "virtual_seq_colBits1.sv"
`include "virtual_seq_sel1.sv"
`include "virtual_seq_row_bank.sv"
`include "virtual_seq_enable_rst.sv"
`include "virtual_seq_CAS1.sv"
`include "virtual_seq_ACR_1.sv"
`include "virtual_seq_ACR_2.sv"

`include "scoreboard.sv"
`include "monitor.sv"

`include "init_params_agent.sv"
`include "reset_agent.sv"
`include "agent_sram.sv"
`include "spec_param_agent.sv"

`include "coverage.sv"

`include "env.sv"

`ifdef SDR_32BIT
`include "mt48lc2m32b2.v"
`elsif SDR_16BIT 
`include "IS42VM16400K.V"
`else  // 8 BIT SDRAM
`include "mt48lc8m8a2.v"
`endif

`include "test_1.sv"
`include "test_ColBits.sv"
`include "test_sel.sv"
`include "test_row_bank.sv"
`include "test_CAS_latency.sv"
`include "test_ACR_1.sv"
`include "test_ACR_2.sv"
`include "test_reset.sv"

`include "assertion.sv"
