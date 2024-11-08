`ifndef AXIL_I2C_RESPONSE_SEQ
`define AXIL_I2C_RESPONSE_SEQ

class i2c_response_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_response_seq)
	i2c_seq_item tx;

    function new(string name = "i2c_response_seq");
        super.new(name);
		tx = i2c_seq_item::type_id::create("tx");
    endfunction
  
	task body();
		start_item(tx);
		assert(tx.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");
		finish_item(tx);
	endtask

endclass

`endif
