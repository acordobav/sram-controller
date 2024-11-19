`timescale 1ns / 1ps
`define SDR_32BIT
// `define SDR_16BIT
// `define SDR_8BIT
`include "sdrc_top.v"
`include "wb2sdrc.v"
`include "async_fifo.v"
`include "sync_fifo.v"
`include "sdrc_bank_ctl.v"
`include "sdrc_bank_fsm.v"
`include "sdrc_bs_convert.v"
`include "sdrc_core.v"
`include "sdrc_define.v"
`include "sdrc_req_gen.v"
`include "sdrc_xfr_ctl.v"
`include "top_hdl.sv"
