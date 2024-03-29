`ifndef AXI_slave_WRITE_MAIN_MONITOR_SCH
`define AXI_slave_WRITE_MAIN_MONITOR_SVH

/**
* Project : AXI UVC
*
* File : axi_slave_write_main_monitor.sv
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
* Description : slave write monitor core
*
* Classes :	1. axi_slave_write_main_monitor
*
**/


//------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_main_monitor
//
//------------------------------------------------------------------------------



class axi_slave_write_main_monitor extends uvm_monitor;

	static axi_slave_write_main_monitor 					main_monitor_instance;
	axi_slave_write_address_collector 						address_collector;
	axi_slave_write_data_collector							data_collector;
	axi_slave_write_response_collector						response_collector;
	axi_slave_write_checker_map								checker_map[$];
	axi_slave_write_coverage_map							coverage_map[$];

	axi_slave_write_checker_creator							checkers;
	axi_slave_write_coverage_creator						coverages;

	uvm_analysis_port#(axi_write_address_collector_mssg)	addr_port;
	uvm_analysis_port#(axi_write_data_collector_mssg)		data_port;
	uvm_analysis_port#(axi_write_response_collector_mssg) 	response_port;
	uvm_analysis_port#(axi_frame) 							burst_port;

	virtual interface axi_if								vif;

	`uvm_component_utils(axi_slave_write_main_monitor)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);

	address_collector 	= 	axi_slave_write_address_collector::type_id::create("AxislaveWriteAddressCollector",this);
	data_collector 		=	axi_slave_write_data_collector::type_id::create("AxislaveWriteDateCollector", this);
	response_collector	= 	axi_slave_write_response_collector::type_id::create("AxislaveWriteResponseCollector", this );

	checkers			=   axi_slave_write_checker_creator::type_id::create("AxislaveWriteCoverageCreator", this);
	coverages			=   axi_slave_write_coverage_creator::type_id::create("AxislaveWriteCheckerCreator", this);

	addr_port 			= new("AddressCollectedPort",this);
	data_port 			= new("DataCollectedPort",this);
	response_port		= new("ResponseCollectedPodr",this);
	burst_port 			= new("BurstCollectedPort",this);

	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

		address_collector.setMainMonitorInstance(this);
		data_collector.setMainMonitorInstance(this);
		response_collector.setMainMonitorInstance(this);

	endfunction : build_phase

	task run_phase(uvm_phase phase);
		this.main();
	endtask



	extern static function axi_slave_write_main_monitor getMonitorMainInstance(uvm_component parent);
	extern task sendBurst(input axi_frame burst);
	extern task reorderData(ref axi_write_data_collector_mssg mssg0);

	extern task pushAddressItem(axi_write_address_collector_mssg mssg0);
	extern task pushDataItem(axi_write_data_collector_mssg mssg0);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg0);
	extern task main();
	extern task reset();

	extern function int suscribeChecker(input axi_slave_write_checker_base checker_base_instance,
		true_false_enum suscribed_to_address_items,  true_false_enum	suscribed_to_data_items,
		true_false_enum	suscrived_to_response_items, true_false_enum	suscribed_to_reset_event,
		true_false_enum	suscribed_to_print_event);
	extern function int suscribeCoverage(input axi_slave_write_coverage_base coverage_instace_base,
		true_false_enum	suscribed_to_address_sample, true_false_enum suscribed_to_data_sample,
		true_false_enum	suscribed_to_response_sample);


endclass : axi_slave_write_main_monitor

	function  axi_slave_write_main_monitor axi_slave_write_main_monitor::getMonitorMainInstance(input uvm_component parent);
	    if(main_monitor_instance == null)
		    begin
			    main_monitor_instance = new("AxislaveMainMonitor", parent);
//			    $display("Creating Axi slave Main Monitor");
		    end
		return main_monitor_instance;
	endfunction

	task axi_slave_write_main_monitor::main();
		fork
			address_collector.main();
			data_collector.main();
			response_collector.main();
//			checker_util.main();
			this.reset();
		join
	endtask

	task axi_slave_write_main_monitor::pushAddressItem(input axi_write_address_collector_mssg mssg0);
		axi_write_address_collector_mssg mssg1, mssg2;
		int i;

		foreach(checker_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				checker_map[i].suscribed_checker_base_instance.pushAddressItem(mssg1);
			end

		foreach(coverage_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				coverage_map[i].suscribed_coverage_instace.pushAddrItem(mssg1);
			end

		mssg2 = new();
		mssg2.copyMssg(mssg0);
		addr_port.write(mssg2);

	endtask

	task axi_slave_write_main_monitor::pushDataItem(input axi_write_data_collector_mssg mssg0);
		axi_write_data_collector_mssg mssg1,mssg2;
		int i;

		reorderData(mssg0);

		foreach(checker_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				checker_map[i].suscribed_checker_base_instance.pushDataItem(mssg1);
			end

		foreach(coverage_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				coverage_map[i].suscribed_coverage_instace.pushDatatItem(mssg1);
			end

		mssg2 = new();
		mssg2.copyMssg(mssg0);
		data_port.write(mssg2);

	endtask

	task axi_slave_write_main_monitor::pushResponseItem(input axi_write_response_collector_mssg mssg0);
		axi_write_response_collector_mssg mssg1, mssg2;

		foreach(checker_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				checker_map[i].suscribed_checker_base_instance.pushResponseItem(mssg1);
			end

		foreach(coverage_map[i])
			begin
				mssg1 = new();
				mssg1.copyMssg(mssg0);
				coverage_map[i].suscribed_coverage_instace.pushResponseItem(mssg1);
			end


		mssg2 = new();
		mssg2.copyMssg(mssg0);

		response_port.write(mssg2);

	endtask

	task axi_slave_write_main_monitor::reset();
	 	int  r;
	    forever begin
		    @(negedge vif.sig_reset);
		    foreach(coverage_map[r])
			    begin
				    coverage_map[r].suscribed_coverage_instace.reset();
			    end

			foreach(checker_map[r])
				begin
					checker_map[r].suscribed_checker_base_instance.reset();
				end
	    end
	endtask

	function int axi_slave_write_main_monitor::suscribeChecker(input axi_slave_write_checker_base checker_base_instance,
		true_false_enum suscribed_to_address_items,  true_false_enum	suscribed_to_data_items,
		true_false_enum	suscrived_to_response_items, true_false_enum	suscribed_to_reset_event,
		true_false_enum	suscribed_to_print_event);

		axi_slave_write_checker_map checker_package;
		checker_package = new($sformatf("AxislaveWriteCheckerMap[%0d]",checker_map.size()),this);

		checker_package.setChecker_id(checker_map.size());
		checker_package.setSuscribed_checker_base_instance(checker_base_instance);
		checker_package.setSuscribed_to_address_items(suscribed_to_address_items);
		checker_package.setSuscribed_to_data_items(suscribed_to_data_items);
		checker_package.setSuscribed_to_print_event(suscribed_to_print_event);
		checker_package.setSuscribed_to_reset_event(suscribed_to_reset_event);
		checker_package.setSuscrived_to_response_items(suscrived_to_response_items);

		checker_map.push_front(checker_package);
		`uvm_info(this.get_name(),$sformatf("Register new Checker with checker_id: %d", checker_package.getChecker_id()), UVM_INFO);
		return checker_package.getChecker_id();

	endfunction


	function int axi_slave_write_main_monitor::suscribeCoverage(input axi_slave_write_coverage_base coverage_instace_base,
		true_false_enum	suscribed_to_address_sample, true_false_enum suscribed_to_data_sample, true_false_enum	suscribed_to_response_sample);

		axi_slave_write_coverage_map coverage_package;
		coverage_package = new($sformatf("AxiMasterWriteCoveragerMap[%0d]",coverage_map.size()), this);

		coverage_package.setCoverage_id(coverage_map.size());
		coverage_package.setSuscribed_coverage_instace(coverage_instace_base);
		coverage_package.setSuscribed_to_address_sample(suscribed_to_address_sample);
		coverage_package.setSuscribed_to_data_sample(suscribed_to_data_sample);
		coverage_package.setSuscribed_to_response_sample(suscribed_to_response_sample);

		coverage_map.push_front(coverage_package);
		`uvm_info(this.get_name(),$sformatf("Register new Coverager with checker_id: %d", coverage_package.getCoverage_id()), UVM_INFO);
		return coverage_package.getCoverage_id();
	endfunction

	task axi_slave_write_main_monitor::sendBurst(input axi_frame burst);
	   burst_port.write(burst);
	endtask

	task axi_slave_write_main_monitor::reorderData(ref axi_write_data_collector_mssg mssg0);
	    int 			line_counter = 0;
		bit_byte_union	strobe_data;
		mem_access 		data_from_single_frame;
		mem_access 		data_to_single_frame;

		data_from_single_frame.data 	= mssg0.getData();
		strobe_data.one_byte 			= mssg0.getStrobe();

	   for (int j = 0; j <= (DATA_WIDTH/8); j++)
		   begin
			   if(strobe_data.one_bit[j] == 1'b1)
				   begin
					   data_to_single_frame.lane[line_counter] = data_from_single_frame.lane[j];
					   line_counter++;
				   end
		   end

		mssg0.setData(data_to_single_frame.data);

	endtask


`endif