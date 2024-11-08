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
		
		memory_slave_seq mem_slave = memory_slave_seq::type_id::create("req");
		api_single_rw_seq axil_api = api_single_rw_seq::type_id::create("req");
		i2c_single_w_seq i2c_w_api = i2c_single_w_seq::type_id::create("req");

		int timeout_count = 0;

        `uvm_info("SEQ", "Starting I2C write/read sequence", UVM_MEDIUM)
        mem_slave.configure(axil_sequencer, slave_addr);
		axil_api.configure(axil_sequencer);
		i2c_w_api.set_address(slave_addr);
		        
		// do write, then a read
		fork
			// mem_slave.register_read(reg_addr);
			mem_slave.register_write(reg_addr, 8'hA5);
			begin
        		`uvm_info(get_type_name(), "i2c_w_api start", UVM_MEDIUM)
				i2c_w_api.start(i2c_sequencer);
        		`uvm_info(get_type_name(), "i2c_w_api done", UVM_MEDIUM)
				// i2c_read_api.start_read(slave_addr, 8'hFA);
			end
		join
		
		// #1000
		// // do write, then a read
		// fork
		// 	// mem_slave.register_read(reg_addr);
		// 	mem_slave.register_write(reg_addr, 8'hA5);
		// 	begin
        // 		`uvm_info(get_type_name(), "i2c_w_api start", UVM_MEDIUM)
		// 		i2c_w_api.start(i2c_sequencer);
        // 		`uvm_info(get_type_name(), "i2c_w_api done", UVM_MEDIUM)
		// 		// i2c_read_api.start_read(slave_addr, 8'hFA);
		// 	end
		// join

		`uvm_info("SEQ", $sformatf("Read data from I2C: %h", mem_slave.data), UVM_LOW)
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
