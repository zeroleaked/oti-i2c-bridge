//------------------------------------------------------------------------------
// File: common_i2c_pkg.sv
// Description: Common Package for I2C UVM Verification Components
//
// This package contains all the common components needed for I2C protocol
// verification. It serves as a central location for all I2C-related verification
// components, ensuring consistent usage across the testbench hierarchy.
//
// Components Included:
//   - I2C Transaction Class (i2c_transaction.sv)
//   - I2C Slave Driver Class (i2c_slave_driver.sv)
//   - I2C Protocol Monitor Class (i2c_protocol_monitor.sv)
//
// Dependencies:
//   - UVM Package
//   - Interface files must be compiled before this package
//
// Usage:
//   - Import this package in your testbench/test files
//   - All I2C verification components will be available
//------------------------------------------------------------------------------

`ifndef COMMON_I2C_PKG_SV
`define COMMON_I2C_PKG_SV

package i2c_verification_pkg;  // Renamed for clarity

//--------------------------------------------------------------------------
// UVM Package Import and Macro Inclusion
//--------------------------------------------------------------------------

// Import UVM base package - required for all UVM components
import uvm_pkg::*;

// Include UVM macros for component automation
`include "uvm_macros.svh"

//--------------------------------------------------------------------------
// Component Hierarchy
//--------------------------------------------------------------------------

// Include files in dependency order - base classes first

// Basic transaction object - foundation for stimulus and monitoring
`include "i2c_transaction.sv"

// Core verification components
`include "i2c_driver.sv"      // Drives I2C slave protocol
`include "i2c_monitor.sv"   // Monitors I2C bus activity

//--------------------------------------------------------------------------
// Future Extensions
//--------------------------------------------------------------------------
/*
	* Planned/Suggested additions:
	* - I2C Configuration Object
	* - I2C Sequencer
	* - I2C Agent
	* - I2C Scoreboard
	* - Protocol Coverage Collection
	* - Reference Model
	* - Register Block
	*/

endpackage : i2c_verification_pkg

`endif // COMMON_I2C_PKG_SV