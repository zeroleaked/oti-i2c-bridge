`ifndef AXIL_I2C_DRIVER
`define AXIL_I2C_DRIVER

class i2c_driver extends uvm_driver #(i2c_seq_item);
	`uvm_component_utils(i2c_driver)

	// Virtual interface
	virtual i2c_interface vif;

	// Current transaction being processed
	i2c_seq_item current_item = null;
	
	// Tracking bits
	protected bit [7:0] received_address;
	protected int      bit_count;
	protected bit      is_read_transaction;

	function new(string name = "i2c_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual i2c_interface)::get(this, "", "i2c_vif", vif))
			`uvm_fatal("NOVIF", "Virtual interface not set for i2c_driver")
	endfunction

	// Main driver task
	virtual task run_phase(uvm_phase phase);
		bit sda_prev = 1'b1;
		
		// Initialize signals
		vif.driver_cb.scl_o <= 1;  // Always high
		vif.driver_cb.sda_o <= 1;
		
		`uvm_info(get_type_name(), "good morning", UVM_LOW)
		forever begin
			@(vif.driver_cb)
			fork
				// Detect START condition (SDA falling while SCL high)
				begin
					@(negedge vif.sda_i);
					if (vif.scl_i) begin
						`uvm_info(get_type_name(), "start detected", UVM_LOW)
						handle_start();
					end
					wait(0); // forever
				end
				// Detect STOP condition (SDA rising while SCL high)
				begin
					@(posedge vif.sda_i)
					if (vif.scl_i) begin
						`uvm_info(get_type_name(), "stop detected", UVM_LOW)
						handle_stop();
					end
					wait(0); // forever
				end
				// Normal bit transfer
				begin
					@(negedge vif.scl_i);
					`uvm_info(get_type_name(), "lets handle transfer", UVM_LOW)
					// Sample on falling edge of SCL
					handle_transfer();
				end
			join_any
			disable fork;
		end
	endtask

	// Handle START condition
	protected task handle_start();
		`uvm_info(get_type_name(), "handle_start", UVM_LOW)
		bit_count = 0;
		`uvm_info(get_type_name(), "getting item...", UVM_LOW)
		seq_item_port.get_next_item(current_item);
		`uvm_info(get_type_name(), "driver rx", UVM_LOW)
		current_item.print();
	endtask

	// Handle STOP condition
	protected task handle_stop();
		if (current_item != null) begin
			seq_item_port.item_done();
			current_item = null;
		end
		bit_count = 0;
		vif.sda_o <= 1;  // Release SDA
	endtask

	// Handle data transfer
	protected task handle_transfer();
		`uvm_info(get_type_name(), $sformatf("bit_count = %d", bit_count), UVM_LOW)

		// Address reception (first byte after START)
		if (bit_count < 8) begin
			wait(vif.scl_i);
			// Sample address bit
			received_address[7-bit_count] = vif.sda_i;
			`uvm_info(get_type_name(), $sformatf("ADDRESS BIT[%d] %h", 7-bit_count, received_address[7-bit_count]), UVM_LOW)
			bit_count++;
			
			// Complete address reception
			if (bit_count == 8) begin
				is_read_transaction = received_address[0];
				received_address = received_address >> 1;  // 7-bit address
				
				// Check if this is our address
				if (current_item != null)
					if (received_address == current_item.address) begin
						// Generate ACK on next SCL
						wait(!vif.scl_i);
						vif.sda_o <= 0;
						@(negedge vif.scl_i);
						vif.sda_o <= 1;
						`uvm_info(get_type_name(), "complete address reception", UVM_LOW)
					end
			end
		end
		// Data phase
		else begin
			if (is_read_transaction) begin
				// Master is reading, we need to drive data
				if (bit_count % 9 == 0) begin
					bit master_ack;
					// Check master ACK/NACK
					@(posedge vif.scl_i);
					master_ack = !vif.sda_i;
					
					if (!master_ack) begin
						// Master NACKed, end of transfer
						vif.sda_o <= 1;
						return;
					end
					bit_count++;
				end
				else begin
					// Drive data bit
					int data_index = bit_count / 9;
					int bit_index = 7 - ((bit_count - 1) % 8);
					
					if (data_index < current_item.data.size()) begin
						@(posedge vif.scl_i);
						vif.sda_o <= current_item.data[data_index][bit_index];
						
						bit_count++;
					end
				end
			end
			else begin
				`uvm_info(get_type_name(), "handle write transaction", UVM_LOW)
				// Master is writing, we need to receive data

				// if one byte done, send ack
				if ((bit_count % 8 == 7) & (bit_count != 8)) begin
					`uvm_info(get_type_name(), "one byte done, sending ack", UVM_LOW)
					// Generate ACK
					vif.sda_o <= 0;
					@(negedge vif.scl_i);
					vif.sda_o <= 1;
				end
				else begin
					vif.sda_o <= 1;  // Release SDA for master
				end
				bit_count++;
			end
		end
	endtask

endclass

`endif