// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_top.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : top module
**/
// -----------------------------------------------------------------------------

`include "axi_uvc/dev_test/read_test/read_env/dut.v"    // design under test
`include "axi_uvc/sv/axi_if.sv"
`include "axi_uvc/sv/axi_pkg.sv"
`include "axi_uvc/dev_test/read_test/read_env/read_test_pkg.sv"

module axi_top;

    import uvm_pkg::*;            // import the UVM library
    `include "uvm_macros.svh"     // Include the UVM macros

    import axi_pkg::*;

    import read_test_pkg::*;

    `include "axi_uvc/dev_test/read_test/read_env/tests/axi_test_lib.sv"

    reg clock;
    reg reset;

    axi_if if0(.sig_reset(reset), .sig_clock(clock));

    dut dut(.axi_clock(clock), .axi_reset(reset), .axi_if(if0) );

    initial begin

        uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.*","vif", if0);
        run_test();

    end

    initial begin
        if0.has_checks = 0;
        reset <= 1'b0;
        clock <= 1'b0;
        #5 reset <= 1'b1;
        #53 reset <= 1'b0;
        #360 reset <= 1'b1;
        #551 reset <= 1'b0;
        #700 reset <= 1'b1;
    end

    //Generate Clock
    always #5 clock = ~clock;


endmodule : axi_top
