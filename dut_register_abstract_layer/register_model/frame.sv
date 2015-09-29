`ifndef DUT_REG_MOGEL_FRAME_SVH_
`define DUT_REG_MOGEL_FRAME_SVH_


class dut_frame extends axi_frame;

	rand axi_direction_enum rw;
	`uvm_object_utils_begin(dut_frame)
	 `uvm_field_enum(axi_direction_enum, rw, UVM_ALL_ON)
 	`uvm_object_utils_end

 	function new (string name = "axi_frame");
		super.new(name);
 	endfunction

 	extern function void copyAxiFrame(ref axi_frame frame);
 	extern function void copyDutFrame(input dut_frame frame);

endclass :  dut_frame


	function void dut_frame::copyAxiFrame(ref axi_frame frame);
		this.addr = frame.addr;
		this.awuser = frame.awuser;
		this.burst_type = frame.burst_type;
		this.cache		= frame.cache;
		this.data		= frame.data;
		this.id			= frame.id;
		this.len		= frame.len;
		this.lock		= frame.lock;
		this.prot		= frame.prot;
		this.qos		= frame.qos;
		this.region		= frame.region;
		this.size		= frame.size;
		this.wuser		= frame.wuser;
		this.resp		= frame.resp;
	endfunction

	function void dut_frame::copyDutFrame(input dut_frame frame);
		this.addr 		= frame.addr;
		this.awuser 	= frame.awuser;
		this.burst_type = frame.burst_type;
		this.cache		= frame.cache;
		this.data		= frame.data;
		this.id			= frame.id;
		this.len		= frame.len;
		this.lock		= frame.lock;
		this.prot		= frame.prot;
		this.qos		= frame.qos;
		this.region		= frame.region;
		this.size		= frame.size;
		this.wuser		= frame.wuser;
		this.resp		= frame.resp;
		this.rw			= frame.rw;
	endfunction

`endif