`ifndef DUT_REG_MOGEL_FRAME_SVH
`define DUT_REG_MOGEL_FRAME_SVH


class dut_frame extends axi_frame;

	axi_direction_enum rw;
	`uvm_object_utils_begin(uvc_company_uvc_name_item)
	 `uvm_field_enum(read_write_enum, rw, UVM_ALL_ON)
 	`uvm_object_utils_end

 	function new (string name = "axi_frame");
		super.new(name);
	endfunction

endclass :  dut_frame

`endif