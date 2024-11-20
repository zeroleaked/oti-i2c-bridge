/*
* File: axil_coverage.sv
*
* This file defines the coverage collection for AXI-Lite transactions.
*
* TODO:
* - Expand coverage to include more complex scenarios (e.g., back-to-back transactions)
* - Add functional coverage for specific DUT behaviors triggered by AXI-Lite transactions
* - Consider implementing cross-coverage between AXI-Lite and I2C transactions
*
* Improvement Opportunities:
* - The current coverage model is quite basic. It could benefit from more detailed bins
*   and cross-coverage between fields.
* - Consider adding coverage for protocol-specific sequences (e.g., write followed by read)
*/
`ifndef AXIL_COVERAGE
`define AXIL_COVERAGE

class axil_coverage extends uvm_subscriber #(axil_seq_item);
    `uvm_component_utils(axil_coverage)
    
    covergroup axil_cg;
        addr_cp: coverpoint trans.addr {
            bins data = {DATA_REG};
            bins status = {STATUS_REG};
            bins prescale = {PRESCALE_REG};
            bins command = {CMD_REG};
        }
        
        direction_cp: coverpoint trans.read;
        
        // TODO: Add coverage for data values, especially for command register

        addr_dir_cross: cross addr_cp, direction_cp;
        // TODO: Add cross coverage with data values for write transactions
    endgroup

	// Data Transfer Coverage
	covergroup data_transfer_cg;
		option.per_instance = 1;

		// Data values
		data_cp: coverpoint trans.data[7:0] {
			bins low_values = {[8'h00:8'h1F]};
			bins mid_values = {[8'h20:8'hDF]};
			bins high_values = {[8'hE0:8'hFF]};
		}

		// Data valid for read op
		data_valid_cp: coverpoint trans.data[8] iff (trans.read == 1);

		// Data last for write op
		data_last_cp: coverpoint trans.data[9] iff (trans.read == 0);
	endgroup
    
    axil_seq_item trans;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        axil_cg = new();
		data_transfer_cg = new();
    endfunction
    
    function void write(axil_seq_item t);
        trans = t;
        axil_cg.sample();

		// Only sample data transfer coverage for DATA_REG transactions
		if (trans.addr == DATA_REG) begin
			data_transfer_cg.sample();
		end
    endfunction
    // TODO: Implement report_phase to provide coverage summary
endclass

`endif
