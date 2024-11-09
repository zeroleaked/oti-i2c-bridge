`ifndef AXIL_I2C_OP_WRITE_SEQ
`define AXIL_I2C_OP_WRITE_SEQ

class axil_i2c_op_write_seq extends axil_i2c_op_base_seq;
    `uvm_object_utils(axil_i2c_op_write_seq)
  
	task do_operation();
		write_command(CMD_START | CMD_WR_M);

		// initial write data settings
		api.req.seq_cfg_data_c.constraint_mode(0); // randomize first byte
		api.req.cfg_address = DATA_REG;

		repeat (data_length-1) write_data(DATA_DEFAULT);	
		write_data(DATA_LAST);

		// stop
		write_command(CMD_STOP);
	endtask

	task write_data(bit [1:0] flags);
		api.req.cfg_data[9:8] = flags;
		api.start(m_sequencer);
		`uvm_info(get_type_name(), $sformatf("Write data register %s", api.req.convert2string()), UVM_LOW)
	endtask

    function new(string name = "axil_i2c_op_write_seq");
        super.new(name);
    endfunction

endclass

`endif
