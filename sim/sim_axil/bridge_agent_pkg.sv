`ifndef BRIDGE_AGENT_PKG
`define BRIDGE_AGENT_PKG

package bridge_agent_pkg;
   
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // importing packages : agent,ref model, register ...
   /////////////////////////////////////////////////////////
	// import dut_params_pkg::*;
   //////////////////////////////////////////////////////////
   // include top env files 
   /////////////////////////////////////////////////////////
  `include "axil_seq_item.sv"
  `include "axil_driver.sv"
  `include "axil_monitor.sv"
  
  `include "i2c_trans.sv"
  `include "i2c_monitor.sv"
  `include "i2c_responder.sv"

endpackage

`endif


