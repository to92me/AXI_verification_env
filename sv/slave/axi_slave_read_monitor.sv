// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_slave_read_monitor.sv
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
* Description : monitors data and address channels
*
* Classes :	1. axi_slave_read_monitor
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. report_phase(uvm_phase phase)
*				4. void new_burst(axi_read_burst_frame collected_burst)
*				5. void new_frame(axi_read_single_frame collected_frame)
*				6. bit check_data_channel(axi_read_single_frame collected_frame)
*				7. void check_addr_channel(axi_read_burst_frame collected_burst)
*				8. void write(axi_read_single_frame trans)
*				9. void write1(axi_read_burst_frame trans)
*
* Tasks:	1. run_phase(uvm_phase phase)
**/
// -----------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_MONITOR_SV
`define AXI_SLAVE_READ_MONITOR_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_monitor
//
//------------------------------------------------------------------------------
class axi_slave_read_monitor extends uvm_monitor;

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

	int unsigned num_single_frames = 0;
	axi_read_single_frame error_frames[$];
	axi_read_whole_burst burst_queue[$];
	axi_read_whole_burst finished_bursts[$];

	semaphore sem;

	// TLM Ports
	uvm_analysis_port #(axi_read_single_frame) data_collected_port;
	uvm_analysis_port #(axi_read_burst_frame) addr_collected_port;

	`uvm_analysis_imp_decl(1)
	`uvm_analysis_imp_decl(2)
	
	// TLM connection to the collector
	uvm_analysis_imp #(axi_read_single_frame, axi_slave_read_monitor) data_channel_imp;
	uvm_analysis_imp1 #(axi_read_burst_frame, axi_slave_read_monitor) addr_channel_imp;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_monitor)
		`uvm_field_object(config_obj, UVM_DEFAULT)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
		`uvm_field_int(terminate_enable, UVM_DEFAULT)
		`uvm_field_int(num_single_frames, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		data_collected_port = new("data_collected_port", this);
		addr_collected_port = new("addr_collected_port", this);
		data_channel_imp = new("data_channel_imp", this);
		addr_channel_imp = new("addr_channel_imp", this);
		sem = new(1);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void new_burst(axi_read_burst_frame collected_burst);
	extern virtual function void new_frame(axi_read_single_frame collected_frame);
	extern virtual function void report_phase(uvm_phase phase);
	extern virtual function bit check_data_channel(axi_read_single_frame collected_frame);
	extern virtual function void check_addr_channel(axi_read_burst_frame collected_burst);
	extern virtual function void write(axi_read_single_frame trans);
	extern virtual function void write1(axi_read_burst_frame trans);
	extern virtual task run_phase(uvm_phase phase);

endclass : axi_slave_read_monitor

//------------------------------------------------------------------------------
/**
* Task : run_phase
* Purpose : end simulation, if the nothing happens
* Inputs :	1. phase
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_monitor::run_phase(uvm_phase phase);
		#100000
		`uvm_info(get_type_name(), $sformatf("Force end simulation"), UVM_LOW);
		$finish(2);
	endtask : run_phase

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build
* Parameters :	1. phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		// Propagate the configuration object
		if(!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

//------------------------------------------------------------------------------
/**
* Function : write
* Purpose : sample transaction after the monitor collects the frame
* Parameters :	1. trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::write(axi_read_single_frame trans);
		axi_read_single_frame single_frame;
		single_frame = axi_read_single_frame::type_id::create("single_frame");
		$cast(single_frame, trans.clone());
		new_frame(single_frame);
		data_collected_port.write(single_frame);
	endfunction : write

//------------------------------------------------------------------------------
/**
* Function : write1
* Purpose : sample transaction after the monitor collects the frame
* Parameters :	1. trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::write1(axi_read_burst_frame trans);
		axi_read_burst_frame burst_frame;
		burst_frame = axi_read_burst_frame::type_id::create("burst_frame");
		$cast(burst_frame, trans.clone());
		new_burst(burst_frame);
		addr_collected_port.write(burst_frame);
	endfunction : write1

//------------------------------------------------------------------------------
/**
* Function : new_frame
* Purpose : called when a new frame is collected
* Parameters :	1. collected_frame
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::new_frame(axi_read_single_frame collected_frame);
		int i = 0;
		bit last = 0;
		axi_read_single_addr single_addr_frame;

		num_single_frames++;

		if (checks_enable) begin
			last = check_data_channel(collected_frame);
		end

		for(i = 0; i < burst_queue.size(); i++) begin
			if(burst_queue[i].id == collected_frame.id) begin
				single_addr_frame = axi_read_single_addr::type_id::create("single_addr_frame");
				single_addr_frame.copy(collected_frame);
				burst_queue[i].single_frames.push_back(single_addr_frame);
				if(burst_queue[i].single_frames.size() == (burst_queue[i].len+1))
					last = 1;
				break;
			end
		end
		if(last) begin
			finished_bursts.push_back(burst_queue[i]);
			burst_queue.delete(i);
		end

	endfunction : new_frame

//------------------------------------------------------------------------------
/**
* Function : new_burst
* Purpose : called when a new burst request is collected
* Parameters :	1. collected_burst
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::new_burst(axi_read_burst_frame collected_burst);
		axi_read_whole_burst burst_copy;

		burst_copy = axi_read_whole_burst::type_id::create("burst_copy",this);
		burst_copy.copy(collected_burst);

		if (checks_enable) begin
			check_addr_channel(collected_burst);
		end

		burst_queue.push_back(burst_copy);

	endfunction : new_burst

//------------------------------------------------------------------------------
/**
* Function : report_phase
* Purpose : report
* Parameters :	1. phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report: AXI monitor collected: %0d bursts, %0d single frames, of which %0d bursts were finished and %0d were not and %0d frames had an error", burst_queue.size()+finished_bursts.size(), num_single_frames, finished_bursts.size(), burst_queue.size(), error_frames.size()), UVM_LOW);
	endfunction : report_phase

//------------------------------------------------------------------------------
/**
* Function : check_data_channel
* Purpose : performs checks on single frames
* Parameters :	1. collected_frame
* Return :	bit - last frame in burst / termination signal
**/
//------------------------------------------------------------------------------
	function bit axi_slave_read_monitor::check_data_channel(axi_read_single_frame collected_frame);
			bit last = 0;
			int i = 0;

			// check response
			if(collected_frame.resp == SLVERR) begin
				`uvm_error(get_type_name(), "Collected frame with SLVERR response")
				error_frames.push_back(collected_frame);
				if(terminate_enable)
					last = 1;
			end
			else if (collected_frame.resp == DECERR) begin
				`uvm_error(get_type_name(), "Collected frame with DECERR response")
				error_frames.push_back(collected_frame);
				if(terminate_enable)
					last = 1;
			end

			for(i = 0; i < burst_queue.size(); i++) begin
				if (burst_queue[i].id == collected_frame.id) begin
					// check last
					if(burst_queue[i].single_frames.size() == (burst_queue[i].len)) begin
						if (!collected_frame.last) begin
							`uvm_error(get_type_name(), "Last bit not set for last frame in burst")
							error_frames.push_back(collected_frame);
							last = 1;
						end
					end
					else if(collected_frame.last) begin
						`uvm_error(get_type_name(), "Last bit set for frame that is not last in burst")
						error_frames.push_back(collected_frame);
					end

					// check response
					if((burst_queue[i].lock == EXCLUSIVE) && (collected_frame.resp == OKAY)) begin
						`uvm_error(get_type_name(), "Recieved OKAY response for EXCLUSIVE request")
						error_frames.push_back(collected_frame);
						if(terminate_enable)
							last = 1;
					end

					// checks id
					break;
				end
			end

			if (i > burst_queue.size()) begin
				`uvm_error(get_type_name(), "Collected frame with id that was not requested")
				error_frames.push_back(collected_frame);
			end

			return last;
	endfunction : check_data_channel

//------------------------------------------------------------------------------
/**
* Function : check_addr_channel
* Purpose : performs checks on burst requests
* Parameters :	1. collected_burst
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::check_addr_channel(axi_read_burst_frame collected_burst);

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
				if(!(((2**collected_burst.size) * collected_burst.len) inside {1, 3, 7, 15, 31, 63, 127}))
					`uvm_error(get_type_name(), "The number of bytes to be transferred in an exclusive access burst must be a power of 2")
				// max number of bytes in a burst is 128
				if(((2**collected_burst.size) * collected_burst.len) > 128)
					`uvm_error(get_type_name(), "max number of bytes to be transferred in an exclusive burst is 128")
				// burst length must not exceed 16 transfers
				if(collected_burst.len >= 16)
					`uvm_error(get_type_name(), "Unsuported burst length for exclusive access")
				// TODO : za cache signale (str. 93)
			end

	endfunction : check_addr_channel

`endif