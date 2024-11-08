`ifndef AXIL_BUS_READ_SEQ
`define AXIL_BUS_READ_SEQ

class axil_bus_read_seq extends uvm_sequence #(axil_seq_item);
    `uvm_object_utils(axil_bus_read_seq)
	axil_seq_item req;

    function new(string name = "axil_bus_read_seq");
        super.new(name);
        req = axil_seq_item::type_id::create("req");
    endfunction

    task body();
        start_item(req);
		assert (req.randomize() with {
			req.read == 1;
			req.strb == 4'b0011;
		})
		else `uvm_error(get_type_name(), "Randomization failed")
        finish_item(req);
		get_response(rsp);
    endtask

endclass

`endif
