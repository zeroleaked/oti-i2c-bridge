`ifndef AXIL_I2C_OP_READ_SEQ
`define AXIL_I2C_OP_READ_SEQ

class axil_i2c_op_read_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_i2c_op_read_seq)
	int data_length;
	bit [6:0] slave_address;

    function new(string name = "axil_i2c_op_read_seq");
        super.new(name);
    endfunction
  
	task body();
		axil_bus_seq api = axil_bus_seq::type_id::create("api");

		// address phase and first byte	
		api.is_write = 1;
		api.req.cfg_address = CMD_REG;
		api.req.cfg_data = {
			19'h0,
			CMD_START | CMD_READ,
			1'b0,
			slave_address
		};
		api.start(m_sequencer);

		api.is_write = 0;
		api.req.cfg_address = DATA_REG;
		do begin
			api.start(m_sequencer);
		end while (!(api.rsp.data[9:8] & DATA_VALID));
		`uvm_info(get_type_name(), $sformatf("Read data register %s", api.rsp.convert2string()), UVM_LOW)

		// rest of the bytes
		for (int i=0; i<data_length-1; i++) begin
			api.is_write = 1;
			api.req.cfg_address = CMD_REG;
			api.req.cfg_data = {
				19'h0,
				CMD_READ,
				1'b0,
				slave_address
			};
			api.start(m_sequencer);

			api.is_write = 0;
			api.req.cfg_address = DATA_REG;
			do begin
				api.start(m_sequencer);
			end while (!(api.rsp.data[9:8] & DATA_VALID));
			`uvm_info(get_type_name(), $sformatf("Read data register %s", api.rsp.convert2string()), UVM_LOW)
		end

		// stop
		api.is_write = 1;
		api.req.cfg_address = CMD_REG;
		api.req.cfg_data = {
			19'h0,
			CMD_STOP,
			1'b0,
			slave_address
		};
		api.start(m_sequencer);

	endtask

endclass

`endif
