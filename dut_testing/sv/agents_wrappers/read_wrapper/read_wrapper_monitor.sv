`ifndef AXI_READ_WRAPPER_MONITOR_SVH
`define AXI_READ_WRAPPER_MONITOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_read_wrapper_monitor extends uvm_monitor;

	uvm_analysis_imp#(.T(axi_read_whole_burst), .IMP(axi_read_wrapper_monitor))  	read_monitor_import;
	uvm_analysis_port#(.T(dut_frame))												wrapper_port;

	`uvm_component_utils(axi_read_wrapper_monitor)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		read_monitor_import 	= new("AxiReadWrapperMonitorReadImport", this);
		wrapper_port 			= new("AxiReadWrapperPort", this);
	endfunction : build_phase

	extern function void write(input axi_read_whole_burst input_read_frame);

endclass : axi_read_wrapper_monitor



	function void axi_read_wrapper_monitor::write(input axi_read_whole_burst input_read_frame);
	    dut_frame export_frame;

		export_frame = new();

		export_frame.rw 	= AXI_READ;
		export_frame.addr 	= input_read_frame.addr;
		export_frame.data.push_front(input_read_frame.single_frames[0].data);
		export_frame.id		= input_read_frame.id;

		wrapper_port.write(export_frame);
	endfunction


`endif