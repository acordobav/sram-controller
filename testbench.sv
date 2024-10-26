// =============================================================================
// Instituto Tecnológico de Costa Rica                                                  
// Escuela de Ingeniería Electrónica                                                    
// Carrera de Maestría en Electrónica  
//
// Verificación Funcional (MP6134)                                                     
// Prof. Gerardo Castro Jiménez 
//
//
// 							Proyecto #1: 
// Fecha de entrega: Martes 24 de septiembre del 2024, a las 6pm
//
// Descripción: 
// 	Crear un testbench basado en capas con los siguientes módulos:
// 		a. Generación de estímulo.
// 		b. Driver.
// 		c. Scoreboard.
// 		d. Monitor.
// 		e. Checkers.
//
// GR-02:
// 		Jill Carranza
// 		Arturo Córdoba
// 		Juan Pablo Ureña
// 		Victor Sánchez                                              
//                                                       
// =============================================================================


`timescale 1ns/1ps
`define SDR_32BIT
`define S60

`include "top_hvl.sv"
`include "interface.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "stimulus.sv"
`include "env.sv"
`include "mt48lc2m32b2.v"
`include "test_1.sv"
//`include "test_2.sv"  
