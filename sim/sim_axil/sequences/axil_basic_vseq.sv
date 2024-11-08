`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends uvm_sequence;
	uvm_sequencer_base axil_sequencer;
	uvm_sequencer_base i2c_sequencer;
    
	rand bit [6:0] slave_addr;
	rand int data_length;
	
	constraint len_c {
		data_length inside {[1:10]};
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
		axil_i2c_slave_resp_seq i2c_api = axil_i2c_slave_resp_seq::type_id::create("req");

		axil_i2c_op_read_seq axil_i2c_read = axil_i2c_op_read_seq::type_id::create("req");

		assert (this.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");

		i2c_api.req.cfg_address = slave_addr;
		axil_i2c_write.slave_address = slave_addr;
		axil_i2c_read.slave_address = slave_addr;

        `uvm_info(get_type_name(), "Starting AXIL to I2C write sequence", UVM_MEDIUM)

		axil_i2c_write.data_length = data_length;
		i2c_api.req.cfg_data_length = 0; // no respond data for write

		fork
			axil_i2c_write.start(axil_sequencer);
			i2c_api.start(i2c_sequencer);
		join
		        
        `uvm_info(get_type_name(), "Starting AXIL to I2C read sequence", UVM_MEDIUM)
		axil_i2c_read.data_length = data_length;
		i2c_api.req.cfg_data_length = data_length;
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
