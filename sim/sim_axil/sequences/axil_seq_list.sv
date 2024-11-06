`ifndef AXIL_SEQ_LIST
`define AXIL_SEQ_LIST

package axil_seq_list;
   
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // importing packages : agent,ref model, register ...
   /////////////////////////////////////////////////////////
	import dut_params_pkg::*;
	import i2c_master_axil_pkg::*;
	import bridge_env_pkg::*;
	import axil_agent_pkg::axil_seq_item;
   //////////////////////////////////////////////////////////
   // include top env files 
   /////////////////////////////////////////////////////////
	`include "api_single_rw_seq.sv"

	`include "memory_slave_seq.sv"

	`include "config_seq.sv"
	`include "write_read_seq.sv"

endpackage

`endif


