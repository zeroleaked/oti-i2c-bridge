`ifndef AXIL_I2C_MONITOR
`define AXIL_I2C_MONITOR

class axil_i2c_monitor extends uvm_monitor;
	`uvm_component_utils(axil_i2c_monitor)

	// Virtual interface
	virtual i2c_interface vif;

	// Analysis port to send transactions to scoreboard
	uvm_analysis_port #(i2c_seq_item) analysis_port;

	// Current transaction being monitored
	i2c_seq_item current_item;
	bit [7:0] current_byte;
	
	// Tracking bits
	protected bit [7:0] received_address;
	protected int      bit_count;
	protected bit      is_read_transaction;

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
			@(vif.monitor_cb)
			// isolate the second fork as a single child process
			fork begin fork
				// Detect START condition (SDA falling while SCL high)
				begin
					@(negedge vif.sda_i);
					if (vif.scl_i) begin
						`uvm_info(get_type_name(), "start detected", UVM_HIGH)
						handle_start();
					end
					else wait(0); // forever
				end
				// Detect STOP condition (SDA rising while SCL high)
				begin
					@(posedge vif.sda_i)
					if (vif.scl_i) begin
						`uvm_info(get_type_name(), "stop detected", UVM_HIGH)
						handle_stop();
					end
					else wait(0); // forever
				end
				// Normal bit transfer
				begin
					wait(!vif.scl_i);
					`uvm_info(get_type_name(), "lets handle transfer", UVM_HIGH)
					// Sample on rising edge of SCL
					handle_transfer();
				end
			join_any disable fork; end join
		end
	endtask

	// Handle START condition
	protected task handle_start();
		bit_count = 0;
		current_item = i2c_seq_item::type_id::create("current_item");
	endtask

	// Handle STOP condition
	protected task handle_stop();
		if (current_item != null) begin
			// analysis_port.write(current_item);
			current_item.print();
			current_item = null;
		end
		bit_count = 0;
	endtask

	// Handle data transfer monitoring
	protected task handle_transfer();
		`uvm_info(get_type_name(), $sformatf("bit_count = %d", bit_count), UVM_HIGH)

		// Address reception (first byte after START)
		if (bit_count < 8) begin
			@(posedge vif.scl_i);
			// Sample address bit
			received_address[7-bit_count] = vif.sda_i;
			`uvm_info(get_type_name(), $sformatf("address [%d] %h", 7-bit_count, received_address[7-bit_count]), UVM_HIGH)
			bit_count++;
			
			// Complete address reception
			if (bit_count == 8) begin
				is_read_transaction = received_address[0];
				received_address = received_address >> 1;  // 7-bit address
				current_item.address = received_address;
				current_item.is_write = !is_read_transaction;
				
				// Wait for ACK/NACK
				@(posedge vif.scl_i);
				// to be considered: should ack be in seq_item?
				// current_item.address_ack = !vif.sda_i; 
			end
		end
		// Data phase
		else begin
			if (is_read_transaction) begin
				`uvm_info(get_type_name(), "monitor read transaction", UVM_HIGH)
				// Slave is sending data
				if (bit_count % 9 == 8) begin
					// Sample master ACK/NACK
					@(posedge vif.scl_i);
					if (vif.sda_i) begin
						`uvm_info(get_type_name(), "master nacked, end of transfer", UVM_HIGH)
						// Master NACKed, end of transfer
						return;
					end
					bit_count++;
				end
				else begin
					int bit_index = 7 - (bit_count % 9);
					@(posedge vif.scl_i);
					current_byte[bit_index] = vif.sda_i;
					
					if (bit_index == 0) begin
						current_item.data.push_back(current_byte);
						`uvm_info(get_type_name(), $sformatf("Received byte: %h", current_byte), UVM_HIGH)
					end
					bit_count++;
				end
			end
			else begin
				`uvm_info(get_type_name(), "monitor write transaction", UVM_HIGH)
				// Master is writing
				if (bit_count % 9 == 8) begin
					// Sample slave ACK/NACK
					@(posedge vif.scl_i);
					bit_count++;
				end
				else begin
					int bit_index = 7 - (bit_count % 9);
					@(posedge vif.scl_i);
					current_byte[bit_index] = vif.sda_i;
					
					if (bit_index == 0) begin
						current_item.data.push_back(current_byte);
						`uvm_info(get_type_name(), $sformatf("Received byte: %h", current_byte), UVM_HIGH)
					end
					bit_count++;
				end
			end
		end
	endtask

endclass

`endif