`ifndef AXIL_I2C_RD_BASE_SEQ
`define AXIL_I2C_RD_BASE_SEQ

class axil_i2c_rd_base_seq extends master_i2c_op_base_seq;
    `uvm_object_utils(axil_i2c_rd_base_seq)
	
	axil_bus_seq api;

	task body();
		api = axil_bus_seq::type_id::create("api");
		api.configure(m_sequencer);

		// address phase and first byte	
		api.write_command(slave_addr, CMD_START | CMD_READ);

		// rest of the bytes
		repeat (payload_data_length-1) begin
			api.write_command(slave_addr, CMD_READ);
		end

		// stop
		api.write_command(slave_addr, CMD_STOP);

		// read first data
		#2000
		api.read_data_until_valid();
	endtask

    function new(string name = "axil_i2c_rd_base_seq");
        super.new(name);
    endfunction
endclass

`endif
