`ifndef AXI_WRITE_WRAPPER_MONITOR_SVH
`define AXI_WRITE_WRAPPER_MONITOR_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : write_wrapper_monitor.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : write_wrapper_monitor is util that will collect sequence item from
* 				agent monitor, convert it to dut_frame and send it to top_monitor
*
*/
// -----------------------------------------------------------------------------

class axi_write_wrapper_monitor extends uvm_monitor;

	uvm_analysis_imp#(.T(axi_frame), .IMP(axi_write_wrapper_monitor))  	write_monitor_import;
	uvm_analysis_port#(.T(dut_frame))									wrapper_port;

	`uvm_component_utils(axi_write_wrapper_monitor)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		write_monitor_import 	= new("AxiWriteWrapperMonitorWriteImprt", this);
		wrapper_port		= new("AxiWriteWrapperMonitorPort", this);
	endfunction : build_phase


	extern function void write(input axi_frame input_axi_frame);

endclass : axi_write_wrapper_monitor

	function void axi_write_wrapper_monitor::write(input axi_frame input_axi_frame);
		 dut_frame export_frame;

		export_frame = new();

		export_frame.copyAxiFrame(input_axi_frame);
		export_frame.rw = AXI_WRITE;

		wrapper_port.write(export_frame);

	endfunction

`endif