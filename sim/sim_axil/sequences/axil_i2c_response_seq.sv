`ifndef AXIL_I2C_RESPONSE_SEQ
`define AXIL_I2C_RESPONSE_SEQ

class i2c_response_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_response_seq)
	i2c_seq_item req;

    function new(string name = "i2c_response_seq");
        super.new(name);
		req = i2c_seq_item::type_id::create("req");
    endfunction
  
	task body();
		start_item(req);
		assert(req.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");
		finish_item(req);
	endtask

endclass

`endif
