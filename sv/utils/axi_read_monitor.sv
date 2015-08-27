/******************************************************************************
	* DVT CODE TEMPLATE: monitor
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_read_monitor
//
//------------------------------------------------------------------------------

`ifndef AXI_READ_MONITOR_SV
`define AXI_READ_MONITOR_SV

class axi_read_monitor extends uvm_monitor;

	// This property is the virtual interfaced needed for this component to drive
	// and view HDL signals.
	virtual axi_if vif;

	// Configuration object
	axi_config config_obj;

	// The following two bits are used to control whether checks and coverage are
	// done both in the monitor class and the interface.
	bit checks_enable = 1;
	bit coverage_enable = 1;
	// contorl bit - is early termination of bursts allowed
	bit terminate_enable = 1;

	protected int unsigned num_single_frames = 0;
	axi_read_whole_burst burst_queue[$];
	axi_read_whole_burst finished_bursts[$];

	semaphore sem;

	// TLM Ports
	uvm_analysis_port #(axi_read_single_frame) data_collected_port;
	uvm_analysis_port #(axi_read_burst_frame) addr_collected_port;

	// The following property holds the transaction information currently
	// begin captured (by the collect_address_phase and data_phase methods).
	axi_read_single_frame trans_data_channel;
	axi_read_burst_frame trans_addr_channel;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_read_monitor)
		`uvm_field_object(config_obj, UVM_DEFAULT)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
		`uvm_field_int(terminate_enable, UVM_DEFAULT)
		`uvm_field_int(num_single_frames, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		trans_data_channel = axi_read_single_frame::type_id::create("trans_data_channel");
		trans_addr_channel = axi_read_burst_frame::type_id::create("trans_addr_channel");
		data_collected_port = new("data_collected_port", this);
		addr_collected_port = new("addr_collected_port", this);
		sem = new(1);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern virtual task collect_transactions();
	extern virtual function void perform_transfer_coverage();
	extern virtual task new_burst(axi_read_burst_frame collected_burst);
	extern virtual task new_frame(axi_read_single_frame collected_frame);
	extern virtual function void report_phase(uvm_phase phase);

endclass : axi_read_monitor

	// build_phase
	function void axi_read_monitor::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		// Propagate the configuration object
		if(!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	task axi_read_monitor::run_phase(uvm_phase phase);
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
    	`uvm_info(get_type_name(), "Detected Reset Done", UVM_LOW)
    	fork
    		collect_transactions();
    		begin
    			#100000
    			`uvm_error(get_type_name(), "Monitor forces end of simulation")
    			report_phase(phase);
    			$finish(2);	// force end simulation
    		end
    	join
	endtask : run_phase

	// collect_transactions
	task axi_read_monitor::collect_transactions();
		fork
			// monitor address channel
			forever begin
				@(posedge vif.sig_clock);
				if (vif.arvalid && vif.arready)
					begin
						trans_addr_channel = axi_read_burst_frame::type_id::create("trans_addr_channel");
						trans_addr_channel.addr = vif.araddr;
						trans_addr_channel.id = vif.arid;
						trans_addr_channel.len = vif.arlen;
						trans_addr_channel.size = vif.arsize;
						trans_addr_channel.burst_type = vif.arburst;
						trans_addr_channel.lock = vif.arlock;
						trans_addr_channel.cache = vif.arcache;
						trans_addr_channel.prot = vif.arprot;
						trans_addr_channel.qos = vif.arqos;
						trans_addr_channel.region = vif.arregion;
						// user

						new_burst(trans_addr_channel);
					end

			end

			// monitor data channel
			forever begin
				@(posedge vif.sig_clock);
				if (vif.rvalid && vif.rready)
					begin
						trans_data_channel = axi_read_single_frame::type_id::create("trans_data_channel");
						trans_data_channel.data = vif.rdata;
						trans_data_channel.id = vif.rid;
						trans_data_channel.resp = vif.rresp;
						trans_data_channel.last = vif.rlast;
						// user
						num_single_frames++;

						new_frame(trans_data_channel);
					end
			end
		join
	endtask : collect_transactions

	// perform_transfer_coverage
	function void axi_read_monitor::perform_transfer_coverage();
		//cov_trans.sample();
		// TODO : Collect coverage here
		// ...
	endfunction : perform_transfer_coverage

	// called when a new frame is collected
	task axi_read_monitor::new_frame(axi_read_single_frame collected_frame);
		int i = 0;
		bit last = 0;

		if (checks_enable) begin
			// check response
			if(collected_frame.resp == SLVERR) begin
				`uvm_error(get_type_name(), "Collected frame with SLVERR response")
				if(terminate_enable)
					last = 1;
			end
			else if (collected_frame.resp == DECERR) begin
				`uvm_error(get_type_name(), "Collected frame with DECERR response")
				if(terminate_enable)
					last = 1;
			end
			sem.get(1);
				for(i = 0; i < burst_queue.size(); i++) begin
					if (burst_queue[i].id == collected_frame.id) begin
						// check last
						if(burst_queue[i].single_frames.size() == (burst_queue[i].len)) begin
							if (!collected_frame.last) begin
								`uvm_error(get_type_name(), "Last bit not set for last frame in burst")
								last = 1;
							end
						end
						else if(collected_frame.last) begin
							`uvm_error(get_type_name(), "Last bit set for frame that is not last in burst")
						end

						// check response
						if((burst_queue[i].lock == EXCLUSIVE) && (collected_frame.resp == OKAY)) begin
							`uvm_error(get_type_name(), "Recieved OKAY response for EXCLUSIVE request")
							if(terminate_enable)
								last = 1;
						end
						// checks id
						break;
					end
				end
				if (i > burst_queue.size())
					`uvm_error(get_type_name(), "Collected frame with id that was not requested")
			sem.put(1);
		end

		sem.get(1);
			for(i = 0; i < burst_queue.size(); i++) begin
				if(burst_queue[i].id == collected_frame.id) begin
					burst_queue[i].single_frames.push_back(collected_frame);
					if(burst_queue[i].single_frames.size() == burst_queue[i].len)
						last = 1;
					break;
				end
			end
			if(last) begin
				finished_bursts.push_back(burst_queue[i]);
				burst_queue.delete(i);
			end
		sem.put(1);

	endtask : new_frame

	// called when a new burst is collected
	task axi_read_monitor::new_burst(axi_read_burst_frame collected_burst);
		axi_read_whole_burst burst_copy;

		burst_copy = axi_read_whole_burst::type_id::create("burst_copy",this);
		burst_copy.copy(collected_burst);

		if (checks_enable) begin
			// check type, len and addr
			case (collected_burst.burst_type)
				FIXED : begin
					if(collected_burst.len >= 16)
						`uvm_error(get_type_name(), "Unsuported burst length for FIXED burst type")
				end
				INCR : begin

				end
				WRAP : begin
					if(!(collected_burst.len inside {1, 3, 7, 15})) begin
						`uvm_error(get_type_name(), "Unsuported burst length for WRAP burst type")
					end
					if(collected_burst.addr != ($floor(collected_burst.addr/(2**collected_burst.size))*(2**collected_burst.size)))
						`uvm_error(get_type_name(), "Start address must be aligned for WRAP burst type")
				end
				Reserved : begin
					`uvm_error(get_type_name(), "Reserved burt type not supported")
				end
			endcase

			// check size
			if(collected_burst.size > $clog2(DATA_WIDTH / 8))
				`uvm_error(get_type_name(), "Requested size larger than DATA_WIDTH")

			// check exclusive access restrictions
			if(collected_burst.lock == EXCLUSIVE) begin
				// address must be aligned
				if(collected_burst.addr != ($floor(collected_burst.addr/(2**collected_burst.size))*(2**collected_burst.size)))
					`uvm_error(get_type_name(), "Start address must be aligned for EXCLUSIVE access")
				// the number of bytes must be a power of 2
				if(!(collected_burst.len inside {1, 3, 7, 16, 31, 63, 127}))
					`uvm_error(get_type_name(), "The number of bytes to be transferred in an exclusive access burst must be a power of 2")
				// max number of bytes in a burst is 128
				if(((2**collected_burst.size) * collected_burst.len) > 128)
					`uvm_error(get_type_name(), "max number of bytes to be transferred in an exclusive burst is 128")
				// burst length must not exceed 16 transfers
				if(collected_burst.len >= 16)
					`uvm_error(get_type_name(), "Unsuported burst length for exclusive access")
				// TODO : za cache signale (str. 93)
			end
		end

		sem.get(1);
		burst_queue.push_back(burst_copy);
		sem.put(1);

	endtask : new_burst

	// FUNCTION: UVM report() phase
	function void axi_read_monitor::report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report: AXI monitor collected: %0d bursts, %0d single frames, of which %0d bursts were finished and %0d were not", burst_queue.size()+finished_bursts.size(), num_single_frames, finished_bursts.size(), burst_queue.size()), UVM_LOW);
	endfunction : report_phase

`endif