`ifndef AXIL_I2C_READ_SEQ
`define AXIL_I2C_READ_SEQ

class axil_i2c_read_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_i2c_read_seq)
	int data_length;
	bit [6:0] slave_address;

    function new(string name = "axil_i2c_read_seq");
        super.new(name);
    endfunction
  
	task body();
		axil_write_seq write_api = axil_write_seq::type_id::create("write_api");
		axil_read_seq read_api = axil_read_seq::type_id::create("write_api");

		// address phase and first byte
		write_api.req.cfg_address = CMD_REG;
		write_api.req.cfg_data = {
			19'h0,
			CMD_START | CMD_READ,
			1'b0,
			slave_address
		};
		write_api.start(m_sequencer);

		read_api.req.cfg_address = DATA_REG;
		do begin
			read_api.start(m_sequencer);
		end while (!(read_api.rsp.data[9:8] & DATA_VALID));
		`uvm_info(get_type_name(), "seq rsp", UVM_LOW)
		read_api.rsp.print();

		// rest of the bytes
		for (int i=0; i<data_length-1; i++) begin
			write_api.req.cfg_address = CMD_REG;
			write_api.req.cfg_data = {
				19'h0,
				CMD_READ,
				1'b0,
				slave_address
			};
			write_api.start(m_sequencer);

			read_api.req.cfg_address = DATA_REG;
			do begin
				read_api.start(m_sequencer);
			end while (!(read_api.rsp.data[9:8] & DATA_VALID));
			`uvm_info(get_type_name(), "seq rsp", UVM_LOW)
			read_api.rsp.print();
		end

		// stop
		write_api.req.cfg_address = CMD_REG;
		write_api.req.cfg_data = {
			19'h0,
			CMD_STOP,
			1'b0,
			slave_address
		};
		write_api.start(m_sequencer);

	endtask

endclass

`endif
