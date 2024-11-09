`ifndef AXIL_I2C_OP_READ_SEQ
`define AXIL_I2C_OP_READ_SEQ

class axil_i2c_op_read_seq extends axil_i2c_op_base_seq;
    `uvm_object_utils(axil_i2c_op_read_seq)
  
	task do_operation();
		// address phase and first byte	
		write_command(CMD_START | CMD_READ);
		read_data_until_valid();

		// rest of the bytes
		repeat (data_length-1) begin
			write_command(CMD_READ);
			read_data_until_valid();
		end

		// stop
		write_command(CMD_STOP);
	endtask

	// Check data register until it finds valid data
	task read_data_until_valid();
		api.is_write = 0;
		api.req.cfg_address = DATA_REG;
		do begin
			api.start(m_sequencer);
		end while (!(api.rsp.data[9:8] & DATA_VALID));
		`uvm_info(get_type_name(), $sformatf("Read data register %s", api.rsp.convert2string()), UVM_LOW)
	endtask

    function new(string name = "axil_i2c_op_read_seq");
        super.new(name);
    endfunction
endclass

`endif
