`ifndef AXIL_I2C_MONITOR
`define AXIL_I2C_MONITOR

class axil_i2c_monitor extends uvm_monitor;
	`uvm_component_utils(axil_i2c_monitor)

	// Virtual interface
	virtual i2c_interface vif;

	// Analysis port to send transactions to scoreboard
	uvm_analysis_port #(i2c_transaction) analysis_port;

	// Current transaction being monitored
	i2c_transaction current_item;
	bit [7:0]    current_byte;
	
	// Tracking bits
	protected bit [7:0] received_address;
	protected int      bit_count;
	protected bit      is_read_transaction;

	// Constructor and build_phase remain the same
	function new(string name = "axil_i2c_monitor", uvm_component parent = null);
		super.new(name, parent);
		analysis_port = new("analysis_port", this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual i2c_interface)::get(this, "", "i2c_vif", vif))
			`uvm_fatal("NOVIF", "Virtual interface not set for axil_i2c_monitor")
	endfunction

	// Main monitor task
	virtual task run_phase(uvm_phase phase);        
		forever begin
			@(vif.monitor_cb);
			// necessary to isolate disable fork with fork join
			fork
				monitor_i2c_transaction();
			join
		end
	endtask

	// Task to monitor a single I2C transaction
	protected task monitor_i2c_transaction();
		fork
			monitor_start_condition();
			monitor_stop_condition();
			monitor_data_transfer();
		join_any
		disable fork;
	endtask

	// Monitor START condition
	protected task monitor_start_condition();
		@(negedge vif.sda_i);
		if (vif.scl_i) begin
			`uvm_info(get_type_name(), "start detected", UVM_HIGH)
			bit_count = 0;
			current_item = i2c_transaction::type_id::create("current_item");
		end
		else wait(0);
	endtask

	// Monitor STOP condition
	protected task monitor_stop_condition();
		@(posedge vif.sda_i)
		if (vif.scl_i) begin
			`uvm_info(get_type_name(), "stop detected", UVM_HIGH)
			if (current_item != null) begin
				analysis_port.write(current_item);
				current_item.print();
				current_item = null;
			end
			bit_count = 0;
		end
		else wait(0);
	endtask

	// Monitor data transfer
	protected task monitor_data_transfer();
		wait(!vif.scl_i);
		`uvm_info(get_type_name(), "handle_transfer starts", UVM_HIGH)
		`uvm_info(get_type_name(), $sformatf("bit_count = %d", bit_count), UVM_HIGH)

		if (bit_count < 8) handle_address_phase();
		else handle_data_phase();
	endtask

	// Handle address phase
	protected task handle_address_phase();
		@(posedge vif.scl_i);
		received_address[7-bit_count] = vif.sda_i;
		`uvm_info(get_type_name(), 
				$sformatf("address [%d] %h", 7-bit_count, received_address[7-bit_count]), 
				UVM_HIGH)
		bit_count++;
		
		if (bit_count == 8) begin
			is_read_transaction = received_address[0];
			received_address = received_address >> 1;  // 7-bit address
			current_item.slave_addr = received_address;
			current_item.is_write = !is_read_transaction;
			// To be considered for later test cases: should ack be in seq_item?
			// If yes, uncomment this
			// @(posedge vif.scl_i);
			// current_item.address_ack = !vif.sda_i;
		end
	endtask

	// Handle data phase
	protected task handle_data_phase();
		if (bit_count % 9 == 8) begin
			@(posedge vif.scl_i);
			if (vif.sda_i) begin
				`uvm_info(get_type_name(), "master nacked, end of transfer", UVM_HIGH)
				return;
			end
			bit_count++;
		end
		else begin
			int bit_index = 7 - (bit_count % 9);
			@(posedge vif.scl_i);
			current_byte[bit_index] = vif.sda_i;
			
			if (bit_index == 0) begin
				current_item.payload_data.push_back(current_byte);
				`uvm_info(get_type_name(), $sformatf("Received byte: %h", current_byte), UVM_HIGH)
			end
			bit_count++;
		end
	endtask

endclass

`endif