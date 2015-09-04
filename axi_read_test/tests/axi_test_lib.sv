// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_test_lib.sv
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
* Description : contains includes
**/
// -----------------------------------------------------------------------------

`include "tests/axi_read_base_test.sv"
`include "tests/axi_read_zero_delay.sv"
`include "tests/axi_read_all_valid_frames.sv"
`include "tests/axi_read_bad_last_bit.sv"
`include "tests/axi_read_slave_bad_id.sv"
`include "tests/axi_read_slave_bad_resp.sv"
`include "tests/axi_read_fixed_type_bad_len.sv"
`include "tests/axi_read_incr_type_boundary.sv"
`include "tests/axi_read_wrap_type_bad_len_bad_addr.sv"
`include "tests/axi_read_reserved_type.sv"
`include "tests/axi_read_large_size.sv"
`include "tests/axi_read_exclusive_access.sv"
`include "tests/axi_read_bad_cache.sv"
`include "tests/axi_read_default_values.sv"