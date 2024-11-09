`ifndef AXIL_I2C_SLAVE_RESP_SEQ
`define AXIL_I2C_SLAVE_RESP_SEQ

class axil_i2c_slave_resp_seq extends uvm_sequence #(i2c_transaction);
    `uvm_object_utils(axil_i2c_slave_resp_seq)
	i2c_transaction req;

    function new(string name = "axil_i2c_slave_resp_seq");
        super.new(name);
		req = i2c_transaction::type_id::create("req");
    endfunction
  
	task body();
		start_item(req);
		assert(req.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");
		finish_item(req);
	endtask

endclass

`endif
