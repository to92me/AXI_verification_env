`ifndef DUT_REGISTER_MODEL_TOP_MONITOR_SVH
`define DUT_REGISTER_MODEL_TOP_MONITOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_top_monitor extends uvm_monitor;

	uvm_analysis_imp0#(	.T(dut_frame),
						.IMP(dut_register_model_top_monitor)) 				write_monitor_import;
	uvm_analysis_imp1#(	.T(dut_frame),
						.IMP(dut_register_model_top_monitor))				read_monitor_import;
	uvm_analysis_port#(	.T(dut_frame)) 										top_monitor_port;

	`uvm_component_utils(dut_register_model_top_monitor)

	// new - constructor
	function new (string name = "DutRegisterTopMonitor", uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		write_monitor_import 	= new("DutRegisterModelTopMonitorWriteImport", 	this);
		read_monitor_import  	= new("DutRegisterModelTopMonitorReadImport",	this);
		top_monitor_port		= new("DutRegisterModelTopMonitorPort",			this);

	endfunction : build_phase


	extern function void write0(input dut_frame frame);
	extern function void write1(input dut_frame frame);

endclass : dut_register_model_top_monitor

	function void dut_register_model_top_monitor::write0(input dut_frame frame);

		top_monitor_port.write(frame);

	endfunction



	function void dut_register_model_top_monitor::write1(input dut_frame frame);

		top_monitor_port.write(frame);

	endfunction


`endif

