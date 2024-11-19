// virtual sequence for basic functionality

`ifndef AXIL_RD_INVALID_VSEQ_SV
`define AXIL_RD_INVALID_VSEQ_SV

class axil_rd_invalid_vseq extends uvm_sequence;

    //--------------------------------------------------------------------------
    // Class Properties
    //--------------------------------------------------------------------------
    
    // Sequence instances
	basic_rd_wr_vseq#(axil_i2c_rd_invalid_seq) read_vseq;

	// Amount of repetition
	int multiplier_number = 1;

    //--------------------------------------------------------------------------
    // Factory Registration
    //--------------------------------------------------------------------------
    `uvm_object_utils(axil_rd_invalid_vseq)

    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------
    
	function new(string name = "axil_rd_invalid_vseq");
        super.new(name);
    endfunction

    //--------------------------------------------------------------------------
    // Main Sequence Methods
    //--------------------------------------------------------------------------
    
	task body();
        `uvm_info(get_type_name(),
			$sformatf("Invalid Read starts %0d I2C transactions",
			multiplier_number*2), UVM_LOW);

		// single read & write
        repeat (multiplier_number) read_vseq.start_single();

		// multiple read & write
        repeat (multiplier_number) read_vseq.start_multiple();

        `uvm_info(get_type_name(), "Invalid Read ends", UVM_LOW);
    endtask

    //--------------------------------------------------------------------------
    // Configuration and Control Methods
    //--------------------------------------------------------------------------
    
	task configure_start(
        input uvm_sequencer_base axil_sequencer,
        input uvm_sequencer_base i2c_sequencer
        );

        // create subsequences
		read_vseq = basic_rd_wr_vseq#(axil_i2c_rd_invalid_seq)::
			type_id::create("read_vseq");

        // configure subsequences' sequencer
        read_vseq.configure(axil_sequencer, i2c_sequencer);

		start(null);
    endtask

endclass

`endif