`ifndef AXIL_TEST_PKG
`define AXIL_TEST_PKG

package axil_test_pkg;
   
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // importing packages : agent,ref model, register ...
   /////////////////////////////////////////////////////////
	import axil_seq_list::*;
	import bridge_env_pkg::*;
   //////////////////////////////////////////////////////////
   // include top env files 
   /////////////////////////////////////////////////////////
  `include "i2c_master_base_test.sv"
  `include "i2c_master_test.sv"
endpackage

`endif


