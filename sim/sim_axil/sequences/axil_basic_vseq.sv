`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends uvm_sequence;
	uvm_sequencer_base axil_sequencer;
	uvm_sequencer_base i2c_sequencer;

	bit single_op_mode = 0;
	bit is_write = 0;
	axil_i2c_op_base_seq axil_worker;
    
	rand bit [6:0] slave_addr;
	rand int data_length;

	constraint cfg_c {
		if (single_op_mode) {
			data_length == 1;
		} else {
			data_length inside {[1:16]};
		}
	}

	`uvm_object_utils_begin(axil_basic_vseq)
		`uvm_field_int(slave_addr, UVM_DEFAULT)
		`uvm_field_int(data_length, UVM_DEFAULT)
	`uvm_object_utils_end
    
    function new(string name = "axil_basic_vseq");
        super.new(name);
    endfunction

    task body();
		i2c_response_seq i2c_api = i2c_response_seq::type_id::create("req");
		if (is_write)
			axil_worker = axil_i2c_op_write_seq::type_id::create("req");
		else
			axil_worker = axil_i2c_op_read_seq::type_id::create("req");

		if (!this.randomize())
			`uvm_error(get_type_name(), "Randomization failed");

		// AXIL to I2C write or read sequence
        `uvm_info(get_type_name(), $sformatf("slave_addr=%0h data_length=%0d", slave_addr, data_length), UVM_LOW)
		i2c_api.req.cfg_slave_addr = slave_addr;
		axil_worker.slave_address = slave_addr;

		axil_worker.data_length = data_length;
		if (is_write)
			i2c_api.req.cfg_payload_length = 0; // no respond data for write
		else
			i2c_api.req.cfg_payload_length = data_length;
		fork
			axil_worker.start(axil_sequencer);
			i2c_api.start(i2c_sequencer);
		join
    endtask

	task configure(
		input uvm_sequencer_base axil_sequencer,
		input uvm_sequencer_base i2c_sequencer
		);

		this.axil_sequencer = axil_sequencer;
		this.i2c_sequencer = i2c_sequencer;
	endtask

	task start_write();
		is_write = 1;
		start(null);
	endtask

	task start_read();
		is_write = 0;
		start(null);
	endtask
endclass

`endif
