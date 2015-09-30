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

`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_base_test.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_zero_delay.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_all_valid_frames.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_bad_last_bit.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_slave_bad_id.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_slave_bad_resp.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_fixed_type_bad_len.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_incr_type_boundary.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_wrap_type_bad_len_bad_addr.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_reserved_type.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_large_size.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_exclusive_access.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_bad_cache.sv"
`include "axi_uvc/dev_test/read_test/read_env/tests/axi_read_default_values.sv"