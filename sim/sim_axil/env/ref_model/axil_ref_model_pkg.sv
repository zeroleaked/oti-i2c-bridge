`ifndef AXIL_REF_MODEL_PKG_SV
`define AXIL_REF_MODEL_PKG_SV

package axil_ref_model_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	//////////////////////////////////////////////////////////
	// importing packages : agent,ref model, register ...
	/////////////////////////////////////////////////////////
	import i2c_master_axil_pkg::*;
	import axil_agent_pkg::axil_seq_item;
	import common_i2c_pkg::i2c_transaction;
	//////////////////////////////////////////////////////////
	// include ref model files 
	/////////////////////////////////////////////////////////
	`include "axil_ref_model.sv"

endpackage

`endif