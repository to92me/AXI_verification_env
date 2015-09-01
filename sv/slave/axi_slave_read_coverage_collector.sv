// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_slave_read_coverage_collector.sv
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
* Description : collects coverage
*
* Classes :	1. axi_slave_read_coverage_collector
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. void write(axi_read_single_frame trans)
*				4. void write1(axi_read_burst_frame trans)
**/
// -----------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_COVERAGE_COLLECTOR_SV
`define AXI_SLAVE_READ_COVERAGE_COLLECTOR_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_coverage_collector
//
//------------------------------------------------------------------------------

class axi_slave_read_coverage_collector extends uvm_component;

	// control bit
	bit coverage_enable = 1;

	`uvm_analysis_imp_decl(1)
	`uvm_analysis_imp_decl(2)
	
	// TLM connection to the monitor
	uvm_analysis_imp #(axi_read_single_frame, axi_slave_read_coverage_collector) data_channel_port;
	uvm_analysis_imp1 #(axi_read_burst_frame, axi_slave_read_coverage_collector) addr_channel_port;

	// the current frames
	axi_read_single_frame single_frame;
	axi_read_burst_frame burst_frame;

	`uvm_component_utils_begin(axi_slave_read_coverage_collector)
   		`uvm_field_int(coverage_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// Covergroups
	covergroup axi_slave_read_addr_channel_cg;

		ADDR: coverpoint burst_frame.addr {
			bins values = default;
		}

		ID:	coverpoint burst_frame.id {
			bins ZERO_ID = {0};
			bins values = default;
		}

		LEN: coverpoint burst_frame.len {
			bins ZERO_LEN		= {0};
			bins SMALL_BURST 	= {[1 : 20]};
			bins MIDDLE_BURST 	= {[21 : 100]};
			bins LARGE_BURST 	= {[101 : 127]};
		}

		SIZE :	coverpoint burst_frame.size {
			bins BYTE_1 	= {BYTE_1};
			bins BYTE_2 	= {BYTE_2};
			bins BYTE_4 	= {BYTE_4};
			bins BYTE_8 	= {BYTE_8};
			bins BYTE_16 	= {BYTE_16};
			bins BYTE_32 	= {BYTE_32};
			bins BYTE_64 	= {BYTE_64};
			bins BYTE_128 	= {BYTE_128};
		}

		BURST_TYPE:	coverpoint burst_frame.burst_type {
			bins INC_BURST 		= {INCR};
			bins FIXED_BURST 	= {FIXED};
			bins WRAP_BURST 	= {WRAP};
			bins RESERVED		= {Reserved};
		}

		LOCK:	coverpoint burst_frame.lock {
			bins NORMAL_ACCESS 		= {'b0};
			bins EXCLUSIVE_ACCESS	= {'b1};
		}

		CACHE:	coverpoint burst_frame.cache {
			bins DEVICE_NON_BUFFERABLE  				= {'b0000};
			bins DEVICE_BUFFERABLE						= {'b0001};
			bins NORMAL_NON_CACHEABLE_NON_BUFFERABLE 	= {'b0010};
			bins NORAML_NON_CACHEABLE_BUFFERABLE 		= {'b0011};
			bins WRITE_THROUGHT_NO_ALLOCATE				= {'b0110};
			bins WRITE_THROUGHT_READ_ALLOCATE			= {'b0110};
			bins WRITE_THROUGHT_WRITE_ALLOCATE			= {'b1110,'b1010};
			bins WRITE_THROUGHT_READ_AND_WRITE_ALLOCATE = {'b1110};
			bins WRITE_BACK_NO_ALLOCATE 				= {'b0111};
			bins WRITE_BACK_READ_ALLOCATE				= {'b0111};
			bins WRITE_BACK_WRITE_ALLOCATE				= {'b1111,'b1011};
			bins WRITE_BACK_READ_AND_WRITE_ALLOCATE 	= {'b1111};
		}

		PROTECTION_TYPE: coverpoint burst_frame.prot {
			bins UNPRIVILEGED_ACCESS 	= {'b000};
			bins PRIVILEGED_ACCESS 		= {'b001};
			bins SECURE_ACCESS 			= {'b010};
			bins NON_SECURE_ACCESS 		= {'b011};
			bins DATA_ACCESS			= {'b110};
			bins INSTRUCTION_ACCESS 	= {'b111};
		}

		QOS: coverpoint burst_frame.qos {
			bins qos_values = default;
		}

		REGION:	coverpoint burst_frame.region {
			bins region_values = default;
		}

		// user
	endgroup


	covergroup axi_slave_read_data_channel_cg;

		ID: coverpoint single_frame.id {
			bins ZERO_ID = {0};
			bins values = default;
		}

		DATA : coverpoint single_frame.data {
			bins data_values = default;
		}

		RESP : coverpoint single_frame.resp {
			bins OKAY = {'b00};
			bins EXOKAY = {'b01};
			bins SLVERR = {'b10};
			bins DECERR = {'b11};
		}

		LAST : coverpoint single_frame.last {
			bins LAST = {1};
			bins NOT_LAST = {0};
		}

		// user
	endgroup

	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
		// Create TLM ports
		data_channel_port = new("data_channel_port", this);
		addr_channel_port = new("addr_channel_port", this);
		// Create covergroups if coverage is enabled
    	void'(uvm_config_int::get(this, "", "coverage_enable", coverage_enable));
		if(coverage_enable) begin
			axi_slave_read_addr_channel_cg = new();
			axi_slave_read_addr_channel_cg.set_inst_name({get_full_name(), ".axi_slave_read_addr_channel_cg"});
			axi_slave_read_data_channel_cg = new();
			axi_slave_read_data_channel_cg.set_inst_name({get_full_name(), ".axi_slave_read_data_channel_cg"});
		end
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void write(axi_read_single_frame trans);
	extern virtual function void write1(axi_read_burst_frame trans);

endclass : axi_slave_read_coverage_collector

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build
* Parameters :	1. phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_coverage_collector::build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

//------------------------------------------------------------------------------
/**
* Function : write
* Purpose : sample transaction after the monitor collects the frame
* Parameters :	1. trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_coverage_collector::write(axi_read_single_frame trans);
		$cast(single_frame, trans.clone());

		if(coverage_enable) begin
			axi_slave_read_data_channel_cg.sample();
		end
	endfunction : write

//------------------------------------------------------------------------------
/**
* Function : write1
* Purpose : sample transaction after the monitor collects the frame
* Parameters :	1. trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_coverage_collector::write1(axi_read_burst_frame trans);
		$cast(burst_frame, trans.clone());

		if(coverage_enable) begin
			axi_slave_read_addr_channel_cg.sample();
		end
	endfunction : write1

`endif