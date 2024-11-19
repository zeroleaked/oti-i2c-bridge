`ifndef AXIL_I2C_RD_INVALID_SEQ
`define AXIL_I2C_RD_INVALID_SEQ

class axil_i2c_rd_invalid_seq extends axil_i2c_rd_base_seq;
    `uvm_object_utils(axil_i2c_rd_invalid_seq)

	task body();
		super.body();

		// read rest of the data
		repeat (payload_data_length-1) begin
			api.read_data_until_valid();
		end
	endtask

    function new(string name = "axil_i2c_rd_invalid_seq");
        super.new(name);
    endfunction
endclass

`endif
