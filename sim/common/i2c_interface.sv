`ifndef I2C_INTERFACE
`define I2C_INTERFACE

interface i2c_if(input logic clk, rst);
    logic scl_i, scl_o, scl_t;
    logic sda_i, sda_o, sda_t;

    // Clocking block for driver
    clocking driver_cb @(posedge clk);
        output scl_i, sda_i;
        input  scl_o, scl_t, sda_o, sda_t;
    endclocking

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        input scl_i, scl_o, scl_t, sda_i, sda_o, sda_t;
    endclocking

    modport driver(clocking driver_cb);
    modport monitor(clocking monitor_cb);
endinterface

`endif
