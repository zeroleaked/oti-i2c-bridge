// virtual sequence for basic functionality

`ifndef AXIL_BASIC_VSEQ_SV
`define AXIL_BASIC_VSEQ_SV

class axil_basic_vseq extends uvm_sequence;

    //--------------------------------------------------------------------------
    // Class Properties
    //--------------------------------------------------------------------------
    
    // Sequence instances
	basic_rd_wr_vseq#(axil_i2c_rd_seq) read_vseq;
	basic_rd_wr_vseq#(axil_i2c_wr_seq) write_vseq;

	// Amount of repetition
	int multiplier_number = 100;

    //--------------------------------------------------------------------------
    // Factory Registration
    //--------------------------------------------------------------------------
    `uvm_object_utils(axil_basic_vseq)

    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    
	function new(string name = "axil_basic_vseq");
        super.new(name);
    endfunction

    //--------------------------------------------------------------------------
    // Main Sequence Methods
    //--------------------------------------------------------------------------
    
	task body();
        `uvm_info(get_type_name(),
			$sformatf("Basic Functionality starts %0d I2C transactions",
			multiplier_number*6), UVM_LOW);

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

    //--------------------------------------------------------------------------
    // Configuration and Control Methods
    //--------------------------------------------------------------------------
    
	task configure(
        input uvm_sequencer_base axil_sequencer,
        input uvm_sequencer_base i2c_sequencer
        );

        // create subsequences
		read_vseq = basic_rd_wr_vseq#(axil_i2c_rd_seq)::
			type_id::create("read_vseq");
		write_vseq = basic_rd_wr_vseq#(axil_i2c_wr_seq)::
			type_id::create("write_vseq");

        // configure subsequences' sequencer
        read_vseq.configure(
			axil_sequencer, i2c_sequencer);
        write_vseq.configure(
			axil_sequencer, i2c_sequencer);
    endtask

endclass

`endif