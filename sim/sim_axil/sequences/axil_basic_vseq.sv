`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends base_basic_vseq;
	`uvm_object_utils(axil_basic_vseq);

	task create_worker();
		if (is_write)
			axil_worker = axil_i2c_op_write_seq::type_id::create("req");
		else
			axil_worker = axil_i2c_op_read_seq::type_id::create("req");
	endtask
    
    function new(string name = "axil_basic_vseq");
        super.new(name);
    endfunction
endclass

`endif
