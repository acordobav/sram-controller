#!/bin/bash

vcs -f filelist -sverilog -full64 -debug_access+all -cm line+tgl+assert -timescale=1ns/1ps +incdir+$UVM_HOME +define+UVM_NO_DPI -ntb_opts uvm -assert svaext +UVM_TESTNAME=test_ACR_1

./simv -cm line+tgl+assert +UVM_TESTNAME=test_ACR_1