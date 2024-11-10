`ifndef COMMON_I2C_OP_BASE_SEQ
`define COMMON_I2C_OP_BASE_SEQ

class common_i2c_op_base_seq extends uvm_sequence;
    `uvm_object_utils(common_i2c_op_base_seq)
	axil_bus_seq api;

	int payload_data_length;
	bit [6:0] slave_addr;

    function new(string name = "common_i2c_op_base_seq");
        super.new(name);
    endfunction
    
	// must override
	// implement subsequences to stimulate DUT I2C operation 
	virtual task body();
	endtask

endclass

`endif
