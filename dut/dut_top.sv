// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : dut_top.sv
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
* Description : top module for testing
**/
// -----------------------------------------------------------------------------

`include "dut_counter.v"    // design under test

module axi_top;

    import uvm_pkg::*;            // import the UVM library
    `include "uvm_macros.svh"     // Include the UVM macros

    reg clock;
    reg reset;
    reg fclk;
  
    dut_counter dut(.AXI_ACLK(clock), .AXI_ARESETN(reset), .FCLK(fclk) );


    initial begin
        reset <= 1'b0;
        clock <= 1'b0;
        fclk <= 1'b0;
        #5 reset <= 1'b1;
    end

    //Generate Clock
    always begin
        #4 fclk = ~fclk;
        #1 clock = ~clock;
    end

endmodule : axi_top
