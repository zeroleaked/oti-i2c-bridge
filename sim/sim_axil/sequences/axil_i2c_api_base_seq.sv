`ifndef AXIL_I2C_API_BASE_SEQ
`define AXIL_I2C_API_BASE_SEQ

class i2c_api_base_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_api_base_seq)

    function new(string name = "i2c_api_base_seq");
        super.new(name);
    endfunction

    task body();
        req = i2c_seq_item::type_id::create("req");
        start_item(req);
		req.randomize();
        finish_item(req);
		get_response(rsp);
		req.print();
    endtask

endclass

`endif
