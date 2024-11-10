`ifndef MASTER_I2C_OP_BASE_SEQ
`define MASTER_I2C_OP_BASE_SEQ

class master_i2c_op_base_seq extends uvm_sequence;
    `uvm_object_utils(master_i2c_op_base_seq)

	int payload_data_length;
	bit [6:0] slave_addr;

    function new(string name = "master_i2c_op_base_seq");
        super.new(name);
    endfunction
    
	// must override
	// implement subsequences to stimulate DUT I2C operation 
	virtual task body();
	endtask

endclass

`endif
