`ifndef AXIL_API_BASE_SEQ
`define AXIL_API_BASE_SEQ

class axil_api_base_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_api_base_seq)

	axil_seq_item trans;
	uvm_sequencer_base sequencer;

    function new(string name = "axil_api_base_seq");
        super.new(name);
    endfunction

    task body();
        req = i2c_seq_item::type_id::create("req");
        start_item(req);
		req.randomize() with {
			req.address == trans.address;
		};
        finish_item(req);
		get_response(rsp);
		req.print();

		// get_response(rsp);
    endtask

	task configure(input uvm_sequencer_base seqr_in);
        trans = i2c_seq_item::type_id::create("req");
		this.sequencer = seqr_in;
	endtask

endclass

`endif
