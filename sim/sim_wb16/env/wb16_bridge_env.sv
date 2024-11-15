/*
* File: wb16_bridge_env.sv
*
* This file defines the 'wb16_bridge_env' class, which represents the top-level UVM environment
* for verifying the WB16 to I2C Master Bridge.
*
* Key Features:
* - Instantiates and connects all major components of the verification environment.
* - Includes WB16 driver, monitor, and sequencer for stimulating and observing the DUT.
* - Includes I2C monitor for observing I2C transactions.
* - Incorporates a scoreboard for checking the correctness of transactions.
* - Includes a coverage collector for tracking functional coverage.
* - Sets up an I2C responder to simulate I2C slave behavior.
*
* The environment coordinates the interaction between these components to enable
* comprehensive testing of the WB16 to I2C Master Bridge functionality.
*/

`ifndef WB16_BRIDGE_ENV
`define WB16_BRIDGE_ENV

class wb16_bridge_env extends uvm_env;
    `uvm_component_utils(wb16_bridge_env)

    wb16_driver    wb16_drv;
    wb16_monitor   wb16_mon;
    wb16_i2c_monitor    i2c_mon;
    uvm_sequencer #(wb16_seq_item) wb16_seqr;
    wb16_scoreboard scbd;
    wb16_coverage cov;

	i2c_agent i2c_agent_instance;

    // Constructor
    function new(string name = "wb16_bridge_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase: Create and configure all components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create instances of all components
        wb16_drv = wb16_driver::type_id::create("wb16_drv", this);
        wb16_mon = wb16_monitor::type_id::create("wb16_mon", this);
        i2c_mon = wb16_i2c_monitor::type_id::create("i2c_mon", this);
        wb16_seqr = uvm_sequencer#(wb16_seq_item)::type_id::create("wb16_seqr", this);
        scbd = wb16_scoreboard::type_id::create("scbd", this);
        cov = wb16_coverage::type_id::create("cov", this);

		i2c_agent_instance = i2c_agent::type_id::create("i2c_agent", this);
    endfunction
    
    // Connect phase: Establish connections between components
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect sequencer to driver
        wb16_drv.seq_item_port.connect(wb16_seqr.seq_item_export);

        // Connect monitors to scoreboard
        wb16_mon.ap.connect(scbd.wb16_export);
        i2c_mon.ap.connect(scbd.i2c_export);

        // Connect AXI-Lite monitor to coverage collector
        wb16_mon.ap.connect(cov.analysis_export);
        `uvm_info("ENV", "All connections completed", UVM_LOW)
    endfunction
endclass

`endif