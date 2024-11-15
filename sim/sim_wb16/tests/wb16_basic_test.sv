`ifndef WB16_BASIC_TEST
`define WB16_BASIC_TEST

class wb16_basic_test extends uvm_test;
    wb16_bridge_env env;
    
    `uvm_component_utils(wb16_basic_test)
    
    function new(string name = "wb16_basic_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = wb16_bridge_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
		int multiplier_number = 5;

        basic_rd_wr_vseq#(wb16_i2c_op_read_seq) read_vseq;
        basic_rd_wr_vseq#(wb16_i2c_op_write_seq) write_vseq;

		read_vseq = basic_rd_wr_vseq#(wb16_i2c_op_read_seq)::
			type_id::create("read_vseq", this);
		write_vseq = basic_rd_wr_vseq#(wb16_i2c_op_write_seq)::
			type_id::create("write_vseq", this);
        
        phase.raise_objection(this);

        read_vseq.configure(
			env.wb16_seqr, env.i2c_agent_instance.sequencer);
        write_vseq.configure(
			env.wb16_seqr, env.i2c_agent_instance.sequencer);

		// single read & write
        repeat (multiplier_number) read_vseq.start_single();
        repeat (multiplier_number) write_vseq.start_single();

		// multiple read & write
        repeat (multiplier_number) read_vseq.start_multiple();
        repeat (multiplier_number) write_vseq.start_multiple();

		// multiple back to back read & write
		repeat (multiplier_number) begin
			read_vseq.start_multiple();
			write_vseq.start_multiple();
		end
        
        // TODO: Add more sophisticated test scenarios
        #1000;
        phase.drop_objection(this);
    endtask
    // TODO: Implement other phases as needed (e.g., extract_phase for results checking)
endclass

`endif
