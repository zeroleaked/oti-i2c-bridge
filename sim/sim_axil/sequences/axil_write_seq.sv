`ifndef AXIL_WRITE_SEQ
`define AXIL_WRITE_SEQ

class axil_write_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_write_seq)
	axil_seq_item req;

    function new(string name = "axil_write_seq");
        super.new(name);
        req = axil_seq_item::type_id::create("req");
    endfunction

    task body();
        start_item(req);
		assert (req.randomize() with {
			req.read == 0;
			req.strb == 4'b0011;
		})
		else `uvm_error(get_type_name(), "Randomization failed")
        finish_item(req);
		get_response(rsp);
		req.print();
    endtask

endclass

`endif
