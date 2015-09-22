`ifndef AXI_WRITE_WRAPPER_MONITOR_SVH
`define AXI_WRITE_WRAPPER_MONITOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_wrapper_monitor extends uvm_subscriber#(dut_frame);

	uvm_analysis_imp#(.T(axi_frame), .IMP(axi_write_wrapper_monitor))  	write_monitor_import;
	uvm_analysis_port#(.T(dut_frame))									wrapper_port;

	`uvm_component_utils(axi_write_wrapper_monitor)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axi_write_monitor 	= new("AxiWriteWrapperMonitorWriteImprt", this);
		wrapper_port		= new("AxiWriteWrapperMonitorPort", this);
	endfunction : build_phase


	extern function void write(input axi_frame input_axi_frame);

endclass : axi_write_wrapper_monitor

	function void axi_write_wrapper_monitor::write(input axi_frame input_axi_frame);
		 dut_frame export_frame;

		export_frame = new();

		export_frame.copyAxiFrame(frame);
		export_frame.rw = AXI_WRITE;

		wrapper_port.write(export_frame);

	endfunction

`endif