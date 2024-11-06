`ifndef BRIDGE_ENV_PKG
`define BRIDGE_ENV_PKG

package bridge_env_pkg;
   
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // importing packages : agent,ref model, register ...
   /////////////////////////////////////////////////////////
	import i2c_master_axil_pkg::*;
	import bridge_agent_pkg::*;
	import axil_agent_pkg::*;
   //////////////////////////////////////////////////////////
   // include top env files 
   /////////////////////////////////////////////////////////

  `include "scoreboard.sv"
  `include "axil_coverage.sv"
  `include "bridge_env.sv"

endpackage

`endif


