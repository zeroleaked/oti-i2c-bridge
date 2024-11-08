`ifndef AXIL_I2C_SEQ_ITEM
`define AXIL_I2C_SEQ_ITEM

class i2c_seq_item extends uvm_sequence_item;
    // Core fields for I2C slave behavior
    rand bit [6:0] address;      // 7-bit address to respond to
    rand bit [7:0] data[];      // Array of data bytes for read/write
    rand bit is_write;

    // Constraints
    constraint valid_addr_c {
        address inside {[0:7'h7F]};  // 7-bit address range
    }
    
    constraint reasonable_data_size_c {
        data.size() inside {[0:32]};  // Reasonable data array size
    }

    // UVM automation macros
    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(address, UVM_ALL_ON)
        `uvm_field_int(is_write, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

endclass

`endif
