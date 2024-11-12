`ifndef AXIL_REF_MODEL_SV
`define AXIL_REF_MODEL_SV

class axil_ref_model extends uvm_component;
	`uvm_component_utils(axil_ref_model)
	
	//----------------------------------------------------------------------------
	// TLM Ports
	//----------------------------------------------------------------------------
	
	// inputs
	`uvm_analysis_imp_decl(_axil)
	`uvm_analysis_imp_decl(_i2c)
	uvm_analysis_imp_axil #(axil_seq_item, axil_ref_model) axil_imp;
	uvm_analysis_imp_i2c #(i2c_transaction, axil_ref_model) i2c_imp;
	
	// outputs
	uvm_analysis_port#(axil_seq_item) axil_rm2sb_port;
	uvm_analysis_port#(i2c_transaction) i2c_rm2sb_port;

	//----------------------------------------------------------------------------
	// Input Queues
	//----------------------------------------------------------------------------
	
	axil_seq_item axil_queue[$];
	i2c_transaction i2c_queue[$];

	axil_seq_item axil_trans;
	i2c_transaction i2c_trans;

	//----------------------------------------------------------------------------
	// Class Properties
	//----------------------------------------------------------------------------

	protected bit master_req = 0;
	protected bit [7:0] read_data_queue[$];
	protected bit [7:0] write_data_queue[$];
	protected int read_length = 0;
	protected bit [6:0] slave_addr;
	protected bit is_write;

	//----------------------------------------------------------------------------
	// Methods
	//----------------------------------------------------------------------------

	function new(string name="axil_ref_model", uvm_component parent);
		super.new(name, parent);
		axil_rm2sb_port = new("axil_rm2sb_port", this);
		i2c_rm2sb_port = new("i2c_rm2sb_port", this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axil_imp = new("axil_imp", this);
		i2c_imp = new("i2c_imp", this);
	endfunction

	//----------------------------------------------------------------------------
	// Analysis port write implementations
	//----------------------------------------------------------------------------

	function void write_axil(axil_seq_item trans);
		axil_queue.push_back(trans);
	endfunction
	
	function void write_i2c(i2c_transaction trans);
		i2c_queue.push_back(trans);
	endfunction

	//----------------------------------------------------------------------------
	// Main Reference Model Process
	//----------------------------------------------------------------------------

	task run_phase(uvm_phase phase);
		forever begin
			fork begin fork
				begin
					wait(axil_queue.size() > 0);
					axil_trans = axil_queue.pop_front();
					`uvm_info(get_type_name(), {"Reference model receives axil",
						axil_trans.convert2string()}, UVM_HIGH)
					axil_expected_transaction();
					axil_rm2sb_port.write(axil_trans);
					`uvm_info(get_type_name(), {"Reference model sends",
						axil_trans.convert2string()}, UVM_MEDIUM)
					`uvm_info(get_type_name(), "AXIL ends fork", UVM_HIGH);
				end
				begin
					wait(master_req && (i2c_queue.size() > 0));
					i2c_trans = i2c_queue.pop_front();
					`uvm_info(get_type_name(), {"Reference model receives i2c",
						i2c_trans.convert2string()}, UVM_HIGH)
					i2c_expected_transaction();
					i2c_rm2sb_port.write(i2c_trans);
					`uvm_info(get_type_name(), {"Reference model sends",
						i2c_trans.convert2string()}, UVM_MEDIUM)
					`uvm_info(get_type_name(), "I2C ends fork", UVM_HIGH);
				end
			join_any disable fork;
			`uvm_info(get_type_name(), "End of fork", UVM_HIGH);
			end join
		end
	endtask

	//----------------------------------------------------------------------------
	// Task for processing transactions
	//----------------------------------------------------------------------------

	task axil_expected_transaction();
		if (axil_trans.read) begin
			case (axil_trans.addr)
				DATA_REG: read_data();
			endcase
		end
		else begin
			case (axil_trans.addr)
				CMD_REG: write_command();
				DATA_REG: write_data();
			endcase
		end
	endtask
	
	task i2c_expected_transaction();
		wait(master_req);
		
		i2c_trans.slave_addr = slave_addr;
		
		if (is_write) begin
			i2c_trans.payload_data = {};
			foreach(write_data_queue[i])
				i2c_trans.payload_data.push_back(write_data_queue[i]);
		end

		else begin // read
			// Adjust payload_data length if it exceeds read_length
			while (i2c_trans.payload_data.size() > read_length) begin
				i2c_trans.payload_data.pop_back();
			end
			`uvm_info(get_type_name(), $sformatf("Length adjusted to %0d",
				read_length), UVM_HIGH)

			// Copy payload to internal queue
			foreach(i2c_trans.payload_data[i]) begin
				read_data_queue.push_back(i2c_trans.payload_data[i]);
			end
		end
		master_req = 0;
	endtask

	//----------------------------------------------------------------------------
	// AXI-Lite Register Writes
	//----------------------------------------------------------------------------

	// write to command register
	task write_command();
		bit [4:0] flags = axil_trans.data[12:8];

		// start of i2c transaction
		if (flags & CMD_START) begin
			`uvm_info(get_type_name(), "Start bit detected", UVM_HIGH)

			// save slave address, ensure all commands have this address
			slave_addr = axil_trans.data[6:0];
			
			// mark as a new i2c read transaction (1 byte)
			if (flags & CMD_READ) begin
				`uvm_info(get_type_name(), $sformatf("Starting a new read for %h",
					slave_addr), UVM_HIGH)
				read_length = 1;
				is_write = 0;
			end

			// mark as a new i2c multiple write transaction (0 bytes)
			if (flags & CMD_WR_M) begin
				`uvm_info(get_type_name(), $sformatf("Starting a new write for %h",
					slave_addr), UVM_HIGH)
				is_write = 1;
			end

		end else begin
		
		// middle of i2c transaction
		if ((flags & CMD_READ) && (slave_addr==axil_trans.data[6:0])) begin

			`uvm_info(get_type_name(), "Continue reading", UVM_HIGH)

			// read more bytes
			read_length++;

		end else

		// end of i2c_transaction
		if (flags & CMD_STOP) begin
			`uvm_info(get_type_name(), "Stop reading", UVM_HIGH)
			master_req = 1;
		end
		end
	endtask

	task write_data();
		bit [1:0] flags = axil_trans.data[9:8];

		write_data_queue.push_back(axil_trans.data[7:0]);

		if (flags & DATA_LAST)
			master_req = 1;
	endtask

	//----------------------------------------------------------------------------
	// AXI-Lite Register Reads
	//----------------------------------------------------------------------------

	// read data register
	task read_data();
		bit [7:0] data_from_i2c;

		// todo: take care of race condition
		wait (read_data_queue.size() > 0) begin
			data_from_i2c = read_data_queue.pop_front();
			axil_trans.data = {22'h0, DATA_VALID, data_from_i2c};
		end
	endtask

endclass

`endif