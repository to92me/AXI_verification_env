
`include "dut.v"

`include "sv/axi_if.sv"
`include "sv/axi_pkg.sv"



module axi_top;


import uvm_pkg::*;            // import the UVM library
`include "uvm_macros.svh"     // Include the UVM macros


import axi_pkg::*;

  `include "test_lib.sv"

  reg clock;
  reg reset;

  axi_if if0(.sig_reset(reset), .sig_clock(clock));
  
  dut dut(.axi_clock(clock), .axi_reset(reset), .axi_if(if0) );

initial begin


  uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.*","vif", if0);
  
  `uvm_info("axi_top", "\n**** =============================================================================== ****", UVM_LOW)
   
  run_test();

end

initial begin
    if0.has_checks = 0;
    reset <= 1'b0;
    clock <= 1'b0;
    #6 reset <= 1'b1;
    //#11 reset <= 1'b0;
    //#16 reset <=1'b1;

  end

  //Generate Clock
  always #5 clock = ~clock;


endmodule : axi_top
