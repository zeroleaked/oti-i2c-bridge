`ifndef COMMON_I2C_PKG
`define COMMON_I2C_PKG

package common_i2c_pkg;
   
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // importing packages : agent,ref model, register ...
   /////////////////////////////////////////////////////////
   // TODO: Add imports for any dependent packages

  `include "i2c_transaction.sv"
  `include "i2c_driver.sv"
  `include "i2c_monitor.sv"

endpackage

`endif