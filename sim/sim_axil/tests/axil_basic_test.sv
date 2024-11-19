`ifndef AXIL_BASIC_TEST
`define AXIL_BASIC_TEST

class axil_basic_test extends uvm_test;
    axil_bridge_env env;
    
    `uvm_component_utils(axil_basic_test)
    
    function new(string name = "axil_basic_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axil_bridge_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
		axil_basic_vseq basic_vseq;
		axil_rd_invalid_vseq invalid_vseq;
        
        phase.raise_objection(this);

		// Basic functionality test
		basic_vseq = axil_basic_vseq::type_id::create("basic_vseq", this);
		basic_vseq.configure_start(env.axil_seqr, env.i2c_agnt.sequencer);

		// Invalid read test
		invalid_vseq = axil_rd_invalid_vseq::type_id::create("invalid_vseq", this);
		invalid_vseq.configure_start(env.axil_seqr, env.i2c_agnt.sequencer);
        
        #1000;
        phase.drop_objection(this);
    endtask

endclass

`endif
