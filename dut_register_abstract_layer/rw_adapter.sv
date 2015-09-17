`ifndef DUT_REGISTER_MODEL_RW_ADAPTER_SVH
`define DUT_REGISTER_MODEL_RW_ADAPTER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_rw_adapter extends uvm_component;

	`uvm_component_utils(dut_register_model_rw_adapter)

	uvm_analysis_port#(dut_frame)		adapter_export;
	uvm_analysis_imp0#(dut_frame)		adapter_import;

	uvm_analysis_port#(axi_frame)		write_export;
	uvm_analysis_port#(axi_frame)		read_export;

	uvm_analysis_imp1	#(.T(axi_frame), .IMP(dut_register_model_rw_adapter))	write_import;
	uvm_analysis_imp2	#(.T(axi_frame), .IMP(dut_register_model_rw_adapter))	read_import;



	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		write_export 	= new("write_export", 	this);
		read_export		= new("read_export", 	this);
		write_import 	= new("write_import", 	this);
		read_import 	= new("read_import", 	this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern function void write0(dut_frame frame);
	extern function void write1(axi_frame frame);
	extern function void write2(axi_frame frame);

endclass : dut_register_model_rw_adapter


function dut_register_model_rw_adapter::write0(input dut_frame frame);
	axi_frame frame_axi;

	if(frame.rw == AXI_READ)
		begin
			$cast(frame_axi, frame);
			write_export.write(frame_axi);
		end
	else
		begin
			$cast(frame_axi, frame);
			read_export.write(frame_axi);
		end

endfunction

function dut_register_model_rw_adapter::write1(input axi_frame frame);

	dut_frame frame_dut;
	frame_dut = new();

	frame_dut.copyAxiFrame(frame);
	frame_dut.rw = AXI_WRITE;

	adapter_export.write(frame_dut);


endfunction

function dut_register_model_rw_adapter::write2(input axi_frame frame);

	dut_frame frame_dut;
	frame_dut = new();

	frame_dut.copyAxiFrame(frame);
	frame_dut.rw = AXI_READ;

	adapter_export.write(frame_dut);

endfunction


`endif
