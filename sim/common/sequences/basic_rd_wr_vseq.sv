`ifndef BASIC_RD_WR_VSEQ_SV
`define BASIC_RD_WR_VSEQ_SV

class basic_rd_wr_vseq #(type T=master_i2c_op_base_seq) extends uvm_sequence;
	// randomized variables
	rand bit [6:0] slave_addr;
	rand int payload_data_length;
	constraint cfg_c {
		if (single_op_mode) {
			payload_data_length == 1;
		} else {
			// limit maximum length to 16 bytes
			payload_data_length inside {[1:16]};
		}
	}
	`uvm_object_utils_begin(basic_rd_wr_vseq#(T))
		`uvm_field_int(slave_addr, UVM_DEFAULT)
		`uvm_field_int(payload_data_length, UVM_DEFAULT)
	`uvm_object_utils_end

	uvm_sequencer_base master_sequencer;
	uvm_sequencer_base i2c_sequencer;

	bit single_op_mode = 0;
	
	// master sequence
	T master_sequence;
	
	// slave sequence
	i2c_response_seq i2c_api; 

    task body();
		// create subsequences
		master_sequence = T::type_id::create("master_sequence");
		i2c_api = i2c_response_seq::type_id::create("i2c_api");

		// do a part of the randomization in vseq level
		randomize_this();

		// run subsequences in parallel
		fork
			master_sequence.start(master_sequencer);
			i2c_api.start(i2c_sequencer);
		join
    endtask

	// randomize payload length and slave address
	protected task randomize_this();
		if (!this.randomize())
			`uvm_error(get_type_name(), "Randomization failed");
        `uvm_info(get_type_name(), $sformatf("slave_addr=%0h payload_data_length=%0d", slave_addr, payload_data_length), UVM_LOW)

		// apply randomized to each workers
		i2c_api.req.cfg_slave_addr = slave_addr;
		master_sequence.slave_addr = slave_addr;
		master_sequence.payload_data_length = payload_data_length;
		i2c_api.req.cfg_payload_length = payload_data_length;
	endtask

	task configure(
		input uvm_sequencer_base master_sequencer,
		input uvm_sequencer_base i2c_sequencer
		);

		this.master_sequencer = master_sequencer;
		this.i2c_sequencer = i2c_sequencer;
	endtask

	task start_single();
		single_op_mode = 1;
		start(null);
	endtask

	task start_multiple();
		single_op_mode = 0;
		start(null);
	endtask
    
    function new(string name = "basic_rd_wr_vseq");
        super.new(name);
    endfunction
endclass

`endif
