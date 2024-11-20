/* 
* File: axil_seq_list.sv
*
* This file defines a package containing various AXI-Lite and I2C sequences used in the testbench.
* 
* Key Features:
* - Imports necessary packages and includes required files for sequence definitions.
* - Defines a package 'axil_seq_list' which encapsulates all the sequences.
* 
* Sequences included:
* - api_single_rw_seq: For single register read/write operations
* - memory_slave_seq: Simulates interactions with an I2C slave
* - config_seq: Configures the DUT via register writes
* - write_read_seq: Performs a write followed by a read I2C transaction through the DUT
*
* TODO:
* - Consider splitting sequences into separate files for better maintainability
* - Add more comprehensive documentation for each sequence
* - Implement parameter randomization for more diverse test scenarios
*
* NOTES:
* - The current implementation mixes different types of sequences in a single package,
*   which may not adhere to best practices for larger projects.
* - Consider implementing a base sequence class to promote code reuse among sequences.
* - The package structure could be improved to separate AXI-Lite and I2C specific sequences.
*/
`ifndef AXIL_SEQ_LIST
`define AXIL_SEQ_LIST

package axil_seq_list;
   
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	//--------------------------------------------------------------------------
	// importing packages : agent,ref model, register ...
	//--------------------------------------------------------------------------
	import i2c_master_axil_pkg::*;
	import axil_bridge_env_pkg::*;
	import axil_agent_pkg::axil_seq_item;
	import common_i2c_pkg::i2c_transaction;
	import common_seq_lib::*;

	//--------------------------------------------------------------------------
	// AXI-Lite APIs
	//--------------------------------------------------------------------------

	`include "axil_bus_seq.sv"

	//--------------------------------------------------------------------------
	// AXI-Lite workers
	//--------------------------------------------------------------------------

	// write to i2c
	`include "workers/axil_i2c_wr_seq.sv"
	
	// base read to i2c
	`include "workers/axil_i2c_rd_base_seq.sv" 
	
	// read to i2c basic
	`include "workers/axil_i2c_rd_seq.sv"

	// read to i2c with invalid reads
	`include "workers/axil_i2c_rd_invalid_seq.sv"

	//--------------------------------------------------------------------------
	// Virtual Sequences
	//--------------------------------------------------------------------------

	// Basic functionality
	`include "vseq/axil_basic_vseq.sv"

	// Invalid reads
	`include "vseq/axil_rd_invalid_vseq.sv"

endpackage

`endif


