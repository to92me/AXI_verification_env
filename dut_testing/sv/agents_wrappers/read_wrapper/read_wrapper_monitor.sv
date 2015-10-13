`ifndef AXI_READ_WRAPPER_MONITOR_SVH
`define AXI_READ_WRAPPER_MONITOR_SVH

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : read_wrapper_monitor.sv
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
* Description : read_wrapper_monitor is util that will collect sequence item from
* 				agent monitor, convert it to dut_frame and send it to top_monitor
*
*/
// -----------------------------------------------------------------------------

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
		int i;

		export_frame = new();

		export_frame.rw 	= AXI_READ;
		export_frame.addr 	= input_read_frame.addr;
		export_frame.id		= input_read_frame.id;

		export_frame.resp   = OKAY;

		foreach(input_read_frame.single_frames[i])
			begin

			// copy data
			export_frame.data.push_back(input_read_frame.single_frames[i].data);

			// if resp is error set it to unique resp
			if((input_read_frame.single_frames[i].resp == SLVERR) || (input_read_frame.single_frames[i].resp == DECERR))
				export_frame.resp   = input_read_frame.single_frames[i].resp;

			// if there is no error but exokay set it to unique resp
			if(input_read_frame.single_frames[i].resp == EXOKAY && export_frame.resp == OKAY)
				export_frame.resp = EXOKAY;

			end

		wrapper_port.write(export_frame);
	endfunction


`endif