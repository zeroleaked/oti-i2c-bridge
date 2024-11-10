`ifndef AXIL_BASIC_VSEQ
`define AXIL_BASIC_VSEQ

class axil_basic_vseq extends base_basic_vseq
	#(axil_i2c_op_read_seq, axil_i2c_op_write_seq);
	
	`uvm_object_utils(axil_basic_vseq);
    
    function new(string name = "axil_basic_vseq");
        super.new(name);
    endfunction
endclass

`endif
