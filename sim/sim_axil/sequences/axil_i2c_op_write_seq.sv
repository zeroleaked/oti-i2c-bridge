`ifndef AXIL_I2C_OP_WRITE_SEQ
`define AXIL_I2C_OP_WRITE_SEQ

class axil_i2c_op_write_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_i2c_op_write_seq)
	int data_length;
	bit [6:0] slave_address;

    function new(string name = "axil_i2c_op_write_seq");
        super.new(name);
    endfunction
  
	task body();
		axil_bus_write_seq api = axil_bus_write_seq::type_id::create("api");

		// address phase
		api.req.cfg_address = CMD_REG;
		api.req.cfg_data = {
			19'h0,
			CMD_START | CMD_WR_M,
			1'b0,
			slave_address
		};
		api.start(m_sequencer);

		// data phase
		for (int i=0; i<data_length; i++) begin
			api.req.cfg_address = DATA_REG;
			api.req.cfg_data[15:8] = 8'h0;
			
			// randomize first byte			
			api.req.seq_cfg_data_c.constraint_mode(0);

			// last item
			if (i == data_length - 1) begin
				api.req.cfg_data[15:8] |= DATA_LAST;
			end 
			
			api.start(m_sequencer);
		end

		// stop
		api.req.cfg_address = CMD_REG;
		api.req.cfg_data = {
			19'h0,
			CMD_STOP,
			8'h0
		};
		api.start(m_sequencer);

	endtask

endclass

`endif
