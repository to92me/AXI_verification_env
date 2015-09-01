`ifndef AXI_MASTER_WRITE_COVERAGE_SVH_TOME
`define AXI_MASTER_WRITE_COVERAGE_SVH_TOME

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_write_coverage extends axi_master_write_coverage_base;


	`uvm_component_utils(axi_master_write_coverage)

	covergroup axi_master_write_address_cg;

		ADDR: coverpoint addr_item.addr {
			bins values = default;
		}

		ID:	coverpoint addr_item.id {
			bins values = default;
		}

		BURST:	coverpoint addr_item.burst_type {
			bins INC_BURST 		= {INCR};
			bins FIXED_BURST 	= {FIXED};
			bins WRAP_BURST 	= {WRAP};
			bins RESERVED		= {Reserved};
		}

		CACHE:	coverpoint addr_item.cache {
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

		LEN:	coverpoint addr_item.len {
			bins SMALL_BURST 	= {[0 : 20]};
			bins MIDDLE_BURST 	= {[21 : 100]};
			bins LARGE_BURST 	= {[101 : 127]};
		}

		LOCK:	coverpoint addr_item.lock {
			bins NORMAL_ACCESS 		= {'b0};
			bins EXCLUSIVE_ACCESS	= {'b1};
		}

		ACCESS_PERMISION:	coverpoint addr_item.prot {
			bins UNPRIVILEGED_ACCESS 	= {'b000};
			bins PRIVILEGED_ACCESS 		= {'b001};
			bins SECURE_ACCESS 			= {'b010};
			bins NON_SECURE_ACCESS 		= {'b011};
			bins DATA_ACCESS			= {'b110};
			bins INSTRUCTION_ACCESS 	= {'b111};
		}

		QOS: coverpoint addr_item.qos {
			bins qos_values = default;
		}

		REGION:	coverpoint addr_item.region {
			bins region_values = default;
		}

		SIZE :	coverpoint addr_item.size {
			bins BYTE_1 	= {BYTE_1};
			bins BYTE_2 	= {BYTE_2};
			bins BYTE_4 	= {BYTE_4};
			bins BYTE_8 	= {BYTE_8};
			bins BYTE_16 	= {BYTE_16};
			bins BYTE_32 	= {BYTE_32};
			bins BYTE_64 	= {BYTE_64};
			bins BYTE_128 	= {BYTE_128};
		}

	endgroup


	covergroup axi_master_write_data_cg;
		ID: coverpoint data_item.id {
			bins id_values = default;
		}

		DATA : coverpoint data_item.data{
			bins data_values = default;
		}

		LAST : coverpoint data_item.last{
			bins LAST = {1};
			bins NOT_LAST = {0};
		}

	endgroup

	covergroup axi_master_write_response_cg;

		ID: coverpoint response_item.id{
			bins id_values = default;
		}

		RESP: coverpoint response_item.bresp{
			bins OKAY = {OKAY};
			bins EXOKAY = {EXOKAY};
			bins SLVERR = {SLVERR};
			bins DECERR = {DECERR};
		}

	endgroup

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

		axi_master_write_address_cg = new();
		axi_master_write_data_cg = new();
		axi_master_write_response_cg = new();

		axi_master_write_address_cg.set_inst_name({get_full_name(), ".axi_master_write_address_cg"});
		axi_master_write_data_cg.set_inst_name({get_full_name(), ".axi_master_write_data_cg"});
		axi_master_write_response_cg.set_inst_name({get_full_name(), ".axi_master_write_response_cg"});

	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(main_monitor_instance.suscribeCoverage(this, TRUE, TRUE, TRUE));
	endfunction : build_phase

	extern task sampleAddr();
	extern task sampleData();
	extern task sampleResponse();

endclass : axi_master_write_coverage

	task axi_master_write_coverage::sampleAddr();
		axi_master_write_address_cg.sample();
	endtask

	task axi_master_write_coverage::sampleData();
		axi_master_write_data_cg.sample();
	endtask

	task axi_master_write_coverage::sampleResponse();
		axi_master_write_response_cg.sample();
	endtask

`endif