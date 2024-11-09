`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends uvm_sequence;
	uvm_sequencer_base axil_sequencer;
	uvm_sequencer_base i2c_sequencer;

	bit single_op_mode = 0;
    
	rand bit [6:0] slave_addr;
	rand int data_length;

	constraint cfg_c {
		if (single_op_mode) {
			data_length == 1;
		} else {
			data_length inside {[1:10]};
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
		axil_i2c_op_write_seq axil_i2c_write = axil_i2c_op_write_seq::type_id::create("req");
		i2c_response_seq i2c_api = i2c_response_seq::type_id::create("req");

		axil_i2c_op_read_seq axil_i2c_read = axil_i2c_op_read_seq::type_id::create("req");

		assert (this.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");

		// AXIL to I2C write sequence
        `uvm_info(get_type_name(), $sformatf("write: slave_addr=%0h data_length=%0d", slave_addr, data_length), UVM_LOW)
		i2c_api.req.cfg_slave_addr = slave_addr;
		axil_i2c_write.slave_address = slave_addr;
		axil_i2c_read.slave_address = slave_addr;

		axil_i2c_write.data_length = data_length;
		i2c_api.req.cfg_payload_length = 0; // no respond data for write
		fork
			axil_i2c_write.start(axil_sequencer);
			i2c_api.start(i2c_sequencer);
		join

		// AXIL to I2C read sequence
        `uvm_info(get_type_name(), $sformatf("read: slave_addr=%0h data_length=%0d", slave_addr, data_length), UVM_LOW)
		axil_i2c_read.data_length = data_length;
		i2c_api.req.cfg_payload_length = data_length;
		fork
			axil_i2c_read.start(axil_sequencer);
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
endclass

`endif
