`ifndef AXI_SLAVE_WRITE_BURST_COLLECOTOR
`define AXI_SLAVE_WRITE_BURST_COLLECOTOR

class axi_slave_write_burst_collector extends axi_slave_write_checker_base;
	axi_frame				burst_queue[$];


	`uvm_component_utils(axi_slave_write_burst_collector)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(main_monitor_instance.suscribeChecker(this, TRUE, TRUE, TRUE, TRUE, TRUE));
	endfunction : build_phase

//	extern task main();

	extern task pushAddressItem(axi_write_address_collector_mssg mssg);
	extern task pushDataItem(axi_write_data_collector_mssg mssg);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg);

	extern task reset();
	extern task printState();


	extern task checkForId(input bit[WID_WIDTH - 1 : 0] id, output int index);

endclass : axi_slave_write_burst_collector



task axi_slave_write_burst_collector::pushAddressItem(input axi_write_address_collector_mssg mssg);
	int 		index;
	axi_frame	frame;

	checkForId(mssg.id, index);
	if(index == -1)
		begin
			frame 				= new();
			frame.id 			= mssg.getId();
			frame.addr 			= mssg.getAddr();
			frame.awuser 		= mssg.getUser();
			frame.burst_type 	= mssg.getBurst_type();
			frame.cache			= mssg.getCache();
			frame.len			= mssg.getLen();
			frame.lock			= mssg.getLock();
			frame.prot			= mssg.getProt();
			frame.qos			= mssg.getQos();
			frame.region		= mssg.getRegion();
			frame.size			= mssg.getSize();

			burst_queue.push_back(frame);

		end
	else
		begin
			`uvm_warning("AxiSlaveWriteBurstCollector [UW]",$sformatf("ID : %h already exists in burst collecotr queue", mssg.getId()));
		end

endtask

task axi_slave_write_burst_collector::pushDataItem(input axi_write_data_collector_mssg mssg);
    int 		index;
	checkForId(mssg.id, index);

	if(index != -1)
		begin
			burst_queue[index].data.push_front(mssg.getData());
			burst_queue[index].wuser = mssg.getUser();
		end
	else
		begin
			`uvm_warning("AxiSlaveWriteBurstCollector [UW]",$sformatf("ID : %h non existing ID in burst collecotr queue", mssg.getId()));
		end


endtask

task axi_slave_write_burst_collector::pushResponseItem(input axi_write_response_collector_mssg mssg);
    int 		index;

	checkForId(mssg.id, index);

    if(index != -1)
	    begin
		    main_monitor_instance.sendBurst(burst_queue[index]);
		    burst_queue.delete(index);
	    end
    else
	    begin
		    `uvm_warning("AxiSlaveWriteBurstCollector [UW]",$sformatf("ID : %h non existing ID in burst collecotr queue", mssg.getId()));
	    end

endtask


task axi_slave_write_burst_collector::checkForId(input bit[WID_WIDTH-1:0] id, output int index);
    int i;
	foreach(burst_queue[i])
		begin
			if (id == burst_queue[i].id)
				begin
					index = i;
					return;
				end
		end
	// if id is not found index = -1
	index = -1 ;
	return;

endtask

task axi_slave_write_burst_collector::reset();
    burst_queue.delete();
endtask

task axi_slave_write_burst_collector::printState();
   $display("AxiSlaveWriteBurstCollector [UW]: number of active bursts: %0d", burst_queue.size());

endtask

`endif