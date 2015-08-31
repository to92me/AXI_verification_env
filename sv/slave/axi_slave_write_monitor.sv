`ifndef AXI_slave_WRITE_MAIN_MONITOR_SCH
`define AXI_slave_WRITE_MAIN_MONITOR_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_main_monitor extends uvm_monitor;

	static axi_slave_write_main_monitor 					main_monitor_instance;
	axi_slave_write_address_collector 						address_collector;
	axi_slave_write_data_collector							data_collector;
	axi_slave_write_response_collector						response_collector;
	axi_slave_write_coverage								coverage;
	axi_slave_write_checker								checker_util;// ne moze da se zove samo checker
	uvm_analysis_port#(axi_write_address_collector_mssg)	addr_port;
	uvm_analysis_port#(axi_write_data_collector_mssg)		data_port;
	uvm_analysis_port#(axi_write_response_collector_mssg) 	response_port;


	`uvm_component_utils(axi_slave_write_main_monitor)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

	address_collector 	= 	axi_slave_write_address_collector::type_id::create("AxislaveWriteAddressCollector",this);
	data_collector 		=	axi_slave_write_data_collector::type_id::create("AxislaveWriteDateCollector", this);
	response_collector	= 	axi_slave_write_response_collector::type_id::create("AxislaveWriteResponseCollector", this );
	coverage	     	= 	axi_slave_write_coverage::type_id::create("AxislaveWriteCoverage", this);
	checker_util		= 	axi_slave_write_checker::type_id::create("AxislaveWriteChecker", this);

	addr_port 			= new("AddressCollectedPort",this);
	data_port 			= new("DataCollectedPort",this);
	response_port		= new("ResponseCollectedPodr",this);

	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		address_collector.setMainMonitorInstance(this);
		data_collector.setMainMonitorInstance(this);
		response_collector.setMainMonitorInstance(this);

	endfunction : build_phase

	task run_phase(uvm_phase phase);
		this.main();
	endtask


	extern function static axi_slave_write_main_monitor getMonitorMainInstance(input string name, uvm_component parent);

	extern task pushAddressItem(axi_write_address_collector_mssg mssg0);
	extern task pushDataItem(axi_write_data_collector_mssg mssg0);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg0);
	extern task main();


endclass : axi_slave_write_main_monitor

	function static axi_slave_write_main_monitor axi_slave_write_main_monitor::getMonitorMainInstance(input string name, input uvm_component parent);
	    if(main_monitor_instance == null)
		    begin
			    main_monitor_instance = new(name, parent);
			    $display("Creating Axi slave Main Monitor");
		    end
		return main_monitor_instance;
	endfunction

	task axi_slave_write_main_monitor::main();
		fork
			address_collector.main();
			data_collector.main();
			response_collector.main();
			checker_util.main();
		join
	endtask

	task axi_slave_write_main_monitor::pushAddressItem(input axi_write_address_collector_mssg mssg0);
		axi_write_address_collector_mssg mssg1, mssg2;

		mssg1 = new();
		mssg2 = new();
		mssg1.copyMssg(mssg0);
		mssg2.copyMssg(mssg0);

		coverage.pushAddrItem(mssg0);
		checker_util.pushAddressItem(mssg1);
		addr_port.write(mssg2);

	endtask

	task axi_slave_write_main_monitor::pushDataItem(input axi_write_data_collector_mssg mssg0);
		axi_write_data_collector_mssg mssg1, mssg2;

		mssg1 = new();
		mssg2 = new();
		mssg1.copyMssg(mssg0);
		mssg2.copyMssg(mssg0);

		coverage.pushDatatItem(mssg0);
		checker_util.pushDataItem(mssg1);
		data_port.write(mssg2);

	endtask

	task axi_slave_write_main_monitor::pushResponseItem(input axi_write_response_collector_mssg mssg0);
		axi_write_response_collector_mssg mssg1, mssg2;


		mssg1 = new();
		mssg2 = new();
		mssg1.copyMssg(mssg0);
		mssg2.copyMssg(mssg0);

		coverage.pushResponseItem(mssg0);
		checker_util.pushResponseItem(mssg1);
		response_port.write(mssg2);

	endtask


`endif