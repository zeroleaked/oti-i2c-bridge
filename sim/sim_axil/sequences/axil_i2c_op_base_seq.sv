`ifndef AXIL_I2C_OP_BASE_SEQ
`define AXIL_I2C_OP_BASE_SEQ

class axil_i2c_op_base_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_i2c_op_base_seq)
	axil_bus_seq api;

	int data_length;
	bit [6:0] slave_address;

    function new(string name = "axil_i2c_op_base_seq");
        super.new(name);
    endfunction
    
	task body();
		api = axil_bus_seq::type_id::create("api");

		do_operation();
	endtask

	virtual task do_operation();
	endtask;

	task write_command(bit [4:0] flags);
		api.is_write = 1;
		api.req.cfg_address = CMD_REG;
		api.req.cfg_data = {
			19'h0,
			flags,
			1'b0,
			slave_address
		};
		api.start(m_sequencer);
	endtask

endclass

`endif
