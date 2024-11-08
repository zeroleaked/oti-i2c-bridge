`ifndef AXIL_I2C_SINGLE_R_SEQ
`define AXIL_I2C_SINGLE_R_SEQ

class i2c_single_w_seq extends i2c_api_base_seq;
    `uvm_object_utils(i2c_single_w_seq)
	i2c_w_seq_item write_tx;

    function new(string name = "i2c_single_w_seq");
        super.new(name);
		write_tx = i2c_w_seq_item::type_id::create("write_tx");
    endfunction
  
	task body();
		start_item(write_tx);
		assert(write_tx.randomize())
		else `uvm_error(get_type_name(), "Randomization failed");
		finish_item(write_tx);
	endtask

	task set_address(input bit [6:0] address);
		write_tx.configured_addr = address;
	endtask

endclass

`endif
