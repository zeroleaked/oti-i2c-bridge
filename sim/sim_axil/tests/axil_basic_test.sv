`ifndef AXIL_BASIC_TEST
`define AXIL_BASIC_TEST

class axil_basic_test extends uvm_test;
    bridge_env env;
    
    `uvm_component_utils(axil_basic_test)
    
    function new(string name = "axil_basic_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = bridge_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        axil_basic_vseq basic_vseq;
        
        phase.raise_objection(this);

        basic_vseq = axil_basic_vseq::type_id::create("axil_basic_vseq");
        basic_vseq.configure(env.axil_seqr, env.i2c_seqr);
        basic_vseq.start(null);
        
        // TODO: Add more sophisticated test scenarios
        #1000;
        phase.drop_objection(this);
    endtask
    // TODO: Implement other phases as needed (e.g., extract_phase for results checking)
endclass

`endif
