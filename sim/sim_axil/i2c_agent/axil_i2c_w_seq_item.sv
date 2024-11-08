`ifndef AXIL_I2C_W_SEQ_ITEM
`define AXIL_I2C_W_SEQ_ITEM

class i2c_w_seq_item extends i2c_seq_item;
    `uvm_object_utils(i2c_w_seq_item);
	bit [7:0] slave_address; // set by sequence

    // Constraints
    constraint seq_cfg_addr {
        address == slave_address;  // 7-bit address range
    }
    
    constraint write_data_size {
		data.size() == 0;  // Initial data is empty for write
    }

    // Constructor
    function new(string name = "i2c_w_seq_item");
        super.new(name);
    endfunction

endclass

`endif
