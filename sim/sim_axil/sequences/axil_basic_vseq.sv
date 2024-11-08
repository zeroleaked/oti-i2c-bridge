`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends uvm_sequence;
	uvm_sequencer_base axil_sequencer;
	uvm_sequencer_base i2c_sequencer;
    
	`uvm_object_utils(axil_basic_vseq)
    
    function new(string name = "axil_basic_vseq");
        super.new(name);
    endfunction

    task body();
        axil_seq_item req;
        bit [6:0] slave_addr = 7'h50;  // TODO: Make this configurable
        bit [7:0] reg_addr = 8'hC5;     // TODO: Make this configurable
		int data_length = 3;
		
		axil_i2c_write_seq axil_i2c_write = axil_i2c_write_seq::type_id::create("req");
		i2c_response_seq i2c_w_api = i2c_response_seq::type_id::create("req");

        `uvm_info("SEQ", "Starting I2C write/read sequence", UVM_MEDIUM)

		i2c_w_api.req.cfg_address = slave_addr;
		axil_i2c_write.slave_address = slave_addr;
		axil_i2c_write.data_length = data_length;
		        
		fork
			axil_i2c_write.start(axil_sequencer);
			i2c_w_api.start(i2c_sequencer);
		join

    endtask

	task configure(
		input uvm_sequencer_base axil_sequencer,
		input uvm_sequencer_base i2c_sequencer
		);

		this.axil_sequencer = axil_sequencer;
		this.i2c_sequencer = i2c_sequencer;
	endtask
endclass

`endif
