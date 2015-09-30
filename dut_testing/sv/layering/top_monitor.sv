`ifndef DUT_REGISTER_MODEL_TOP_MONITOR_SVH
`define DUT_REGISTER_MODEL_TOP_MONITOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_top_monitor extends uvm_monitor;

	int i;

	`uvm_analysis_imp_decl(1)
	`uvm_analysis_imp_decl(2)

	uvm_analysis_imp	#(dut_frame, dut_register_model_top_monitor) 		write_monitor_import;
	uvm_analysis_imp1	#(dut_frame, dut_register_model_top_monitor)		read_monitor_import;
	uvm_analysis_port	#(dut_frame) 										top_monitor_port;

`uvm_component_utils_begin(dut_register_model_top_monitor)
	 `uvm_field_int(i, UVM_DEFAULT)
 `uvm_component_utils_end

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


	extern function void write(input dut_frame frame);
	extern function void write1(input dut_frame frame);

endclass : dut_register_model_top_monitor

	function void dut_register_model_top_monitor::write(input dut_frame frame);

		top_monitor_port.write(frame);

	endfunction



	function void dut_register_model_top_monitor::write1(input dut_frame frame);

		top_monitor_port.write(frame);

	endfunction


`endif

