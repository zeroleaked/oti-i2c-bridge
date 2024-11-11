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
	// Input queues
	//----------------------------------------------------------------------------
	
	axil_seq_item axil_queue[$];
	i2c_transaction i2c_queue[$];

	axil_seq_item axil_trans;
	i2c_transaction i2c_trans;

	// protected pci_register_handler register_handler;

	//----------------------------------------------------------------------------
	// Methods
	//----------------------------------------------------------------------------

	function new(string name="axil_ref_model", uvm_component parent);
		super.new(name, parent);
		// register_handler = pci_register_handler::type_id::create("register_handler");
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
			wait((axil_queue.size() > 0) || (i2c_queue.size() > 0));
			
			if (axil_queue.size() > 0) begin
				axil_trans = axil_queue.pop_front();
				axil_expected_transaction();
				axil_rm2sb_port.write(axil_trans);
				`uvm_info(get_type_name(), {"Reference model receives", axil_trans.convert2string()}, UVM_HIGH)
			end

			if (i2c_queue.size() > 0) begin
				i2c_trans = i2c_queue.pop_front();
				i2c_expected_transaction();
				i2c_rm2sb_port.write(i2c_trans);
				`uvm_info(get_type_name(), {"Reference model receives", i2c_trans.convert2string()}, UVM_HIGH)
			end
		end
	endtask

	//----------------------------------------------------------------------------
	// Task for processing transactions
	//----------------------------------------------------------------------------

	task axil_expected_transaction();
	endtask
	
	task i2c_expected_transaction();
	endtask
endclass

`endif