`ifndef AXIL_I2C_TRANSLATOR_SV
`define AXIL_I2C_TRANSLATOR_SV

class axil_i2c_translator extends uvm_component;
	`uvm_component_utils(axil_i2c_translator)

    // Internal state machine for building transaction
    typedef enum {
        IDLE,
        START,
        ADDR_PHASE,
        READ_PHASE,
        WRITE_PHASE,
        STOP
    } build_state_t;

	//----------------------------------------------------------------------------
	// Class Properties
	//----------------------------------------------------------------------------

	protected build_state_t current_state = IDLE;
	protected i2c_transaction current_tr;
	protected int read_data_length;
	protected bit is_complete_transaction = 0;

	bit is_write;
	protected bit master_req = 0;
	protected bit [7:0] read_data_queue[$];
	protected bit [7:0] write_data_queue[$];
	protected int read_length = 0;
	protected bit [6:0] slave_addr;
	protected bit is_write;

	//----------------------------------------------------------------------------
	// Main methods
	//----------------------------------------------------------------------------

	function void add_start_bit();
		assert(current_state==IDLE)
		else
			`uvm_fatal(get_type_name(),
				{"state=", current_state.name(),
				" Ref model has not implemented repeated start!"})

		current_tr = i2c_transaction::type_id::create("trans");
		current_state = START;
	endfunction

	function void add_stop_bit();
		assert(current_state==READ_PHASE || current_state==WRITE_PHASE)
		else `uvm_fatal(get_type_name(), "Not in the state for add_stop_bit!")

		assert((read_data_length > 0) || (current_tr.payload_data.size > 0))
		else `uvm_fatal(get_type_name(), "Transaction is empty!")

		current_state = IDLE;
		is_complete_transaction = 1;
	endfunction

	function void add_slave_addr(bit [6:0] slave_addr);
		assert(current_state==START)
		else `uvm_fatal(get_type_name(),
			"add_slave_addr was called before add_start_bit!")

		current_state = ADDR_PHASE;

		current_tr.slave_addr = slave_addr;
	endfunction

	function void set_direction(bit is_write);
		assert(current_state==ADDR_PHASE)
		else `uvm_fatal(get_type_name(),
			{"state=",current_state.name(),
			" set_direction was called before add_slave_addr!"})

		current_tr.is_write = is_write;

		if (current_tr.is_write) begin
			current_state = WRITE_PHASE;
			current_tr.payload_data = {};
		end
		else begin
			current_state = READ_PHASE;
			read_data_length = 0;
		end
	endfunction

	function void add_read_byte(bit [6:0] slave_addr);
		assert(current_state==READ_PHASE)
		else `uvm_fatal(get_type_name(),
			"Not in the state for add_read_byte!")

		assert(current_tr.slave_addr==slave_addr)
		else `uvm_fatal(get_type_name(),
			"Ref model has not implemented read address changing before stop!")

		read_data_length++;
	endfunction

	function void add_write_byte(bit [7:0] write_data);
		assert(current_state==WRITE_PHASE)
		else `uvm_fatal(get_type_name(),
			"Not in the state for add_write_byte!")

		current_tr.payload_data.push_back(write_data);
	endfunction

	function bit is_ready();
		return is_complete_transaction;
	endfunction

	function i2c_transaction get_transaction(i2c_transaction slave_tr);
		assert(is_complete_transaction)
		else `uvm_fatal(get_type_name(),
			"Transaction is not complete!")

		// copy slave's data for read transactions
		if (!current_tr.is_write) begin
			current_tr.payload_data = slave_tr.payload_data;

			// Adjust payload_data length if it exceeds read_length
			while (current_tr.payload_data.size() > read_data_length) begin
				current_tr.payload_data.pop_back();
			end
		end

		is_complete_transaction = 0;
		return current_tr;
	endfunction

	function new(string name="axil_i2c_translator", uvm_component parent);
		super.new(name, parent);
	endfunction

endclass

`endif