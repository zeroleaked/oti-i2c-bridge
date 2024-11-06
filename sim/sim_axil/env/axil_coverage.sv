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
        
        addr_dir_cross: cross addr_cp, direction_cp;
    endgroup
    
    axil_seq_item trans;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        axil_cg = new();
    endfunction
    
    function void write(axil_seq_item t);
        trans = t;
        axil_cg.sample();
    endfunction
endclass

`endif
