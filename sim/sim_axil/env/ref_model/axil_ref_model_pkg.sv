`ifndef AXIL_REF_MODEL_PKG_SV
`define AXIL_REF_MODEL_PKG_SV

package axil_ref_model_pkg;
   
  // Import UVM package and include macros
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import required custom packages
	import i2c_master_axil_pkg::*;
	import common_i2c_pkg::*;
	import axil_agent_pkg::*;
	import common_utils_pkg::*;

  // Include environment components
//   `include "axil_i2c_translator.sv"
  `include "axil_ref_model.sv"

endpackage

`endif


