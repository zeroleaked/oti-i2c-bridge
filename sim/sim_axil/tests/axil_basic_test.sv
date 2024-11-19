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
        
        phase.raise_objection(this);

		read_write_sequences();
		read_invalid_sequences();
        
        #1000;
        phase.drop_objection(this);
    endtask

	// when these subtasks gets too many, make them sequences
	// for now, I don't see a pattern for a base vseq, but perhaps later

	task read_write_sequences();
		int multiplier_number = 50;
        basic_rd_wr_vseq#(axil_i2c_rd_seq) read_vseq;
        basic_rd_wr_vseq#(axil_i2c_wr_seq) write_vseq;

        `uvm_info(get_type_name(),
			$sformatf("Basic Functionality starts %0d I2C transactions",
			multiplier_number*6), UVM_LOW);

		read_vseq = basic_rd_wr_vseq#(axil_i2c_rd_seq)::
			type_id::create("read_vseq", this);
		write_vseq = basic_rd_wr_vseq#(axil_i2c_wr_seq)::
			type_id::create("write_vseq", this);

        read_vseq.configure(
			env.axil_seqr, env.i2c_agnt.sequencer);
        write_vseq.configure(
			env.axil_seqr, env.i2c_agnt.sequencer);

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

        `uvm_info(get_type_name(), "Basic Functionality ends", UVM_LOW);
	endtask

	task read_invalid_sequences();
		int multiplier_number = 1;
        basic_rd_wr_vseq#(axil_i2c_rd_invalid_seq) read_vseq;

        `uvm_info(get_type_name(),
			$sformatf("Invalid Read starts %0d I2C transactions",
			multiplier_number*2), UVM_LOW);

		read_vseq = basic_rd_wr_vseq#(axil_i2c_rd_invalid_seq)::
			type_id::create("read_vseq", this);

        read_vseq.configure(
			env.axil_seqr, env.i2c_agnt.sequencer);

		// single read
        repeat (multiplier_number) read_vseq.start_single();

		// multiple read
        repeat (multiplier_number) read_vseq.start_multiple();

        `uvm_info(get_type_name(), "Invalid Read ends", UVM_LOW);
	endtask

endclass

`endif
