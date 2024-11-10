`ifndef COMMON_SEQ_LIB_SV
`define COMMON_SEQ_LIB_SV

package common_seq_lib;

//--------------------------------------------------------------------------
// UVM Package Import and Macro Inclusion
//--------------------------------------------------------------------------

// Import UVM base package - required for all UVM components
import uvm_pkg::*;

// Include UVM macros for component automation
`include "uvm_macros.svh"

import common_i2c_pkg::i2c_transaction;
//--------------------------------------------------------------------------
// Component Hierarchy
//--------------------------------------------------------------------------

// Include files in dependency order - base classes first
`include "i2c_response_seq.sv" // I2C slave API sequence
`include "master_i2c_op_base_seq.sv"

`include "base_basic_vseq.sv"

endpackage

`endif // COMMON_I2C_PKG_SV