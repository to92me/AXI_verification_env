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
* Description : monitor for read slave
*
* Classes :	axi_slave_read_monitor
**/
// -----------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_MONITOR_SV
`define AXI_SLAVE_READ_MONITOR_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_monitor
//
//------------------------------------------------------------------------------
/**
* Description : gets collected frames from collector, sends them to coverage
*				collector, performs functional checks if needed and keeps track
*				of all transactions
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. report_phase(uvm_phase phase)
*				4. bit check_data_channel(axi_read_single_frame collected_frame)
*				5. void check_addr_channel(axi_read_burst_frame collected_burst)
*				6. void write(axi_read_single_frame trans)
*				7. void write1(axi_read_burst_frame trans)
*				8. void check_phase(uvm_phase phase)
*
* Tasks:	1. run_phase(uvm_phase phase)
*			2. new_frame()
*			3. new_burst()
*			4. reset()
**/
// -----------------------------------------------------------------------------
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

	// for finishing simulation by force
	int end_simulation = 0;

	int unsigned num_single_frames = 0;
	axi_read_single_frame error_frames[$];
	axi_read_whole_burst burst_queue[$];
	axi_read_whole_burst finished_bursts[$];

	semaphore sem;
	event frame_event;
	event burst_event;
	axi_read_single_frame collected_frame;
	axi_read_burst_frame collected_burst;

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
	extern virtual task new_burst();
	extern virtual task new_frame();
	extern virtual function void report_phase(uvm_phase phase);
	extern virtual function bit check_data_channel(axi_read_single_frame collected_frame);
	extern virtual function void check_addr_channel(axi_read_burst_frame collected_burst);
	extern virtual function void write(axi_read_single_frame trans);
	extern virtual function void write1(axi_read_burst_frame trans);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task reset();
	extern virtual function void check_phase(uvm_phase phase);

endclass : axi_slave_read_monitor

//------------------------------------------------------------------------------
/**
* Task : run_phase
* Purpose : create threads for new frame and burst, reset and end simulation
*			if needed
* Inputs :	phase - uvm phase
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_monitor::run_phase(uvm_phase phase);
		fork
			new_frame();
			new_burst();

			// reset
			forever begin
				@(negedge vif.sig_reset);
		    	reset();
    		end

    		// end simulation
			forever begin
				@(posedge vif.sig_clock);
				end_simulation++;
				// if nothing happens for 10.000 clk cycles, end simulation
				if(end_simulation == 10000) begin
					`uvm_info(get_type_name(), $sformatf("Force end simulation"), UVM_LOW);
					check_phase(phase);
					report_phase(phase);
					$finish(2);
				end
			end
		join
	endtask : run_phase

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build - propagate the virtual interface and configuration object
* Parameters :	phase - uvm phase
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
* Purpose : called by collector when it gets a new frame; sends the frame to
*			coverage collector and signalizes that there is a new frame
* Parameters :	trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::write(axi_read_single_frame trans);
		collected_frame = axi_read_single_frame::type_id::create("collected_frame");
		$cast(collected_frame, trans.clone());

		data_collected_port.write(collected_frame);	// to coverage collector

		end_simulation = 0;	// there was a new frame, restart counter for end simulation

		->frame_event;	// signalize new frame
	endfunction : write

//------------------------------------------------------------------------------
/**
* Function : write1
* Purpose : called by collector when it gets a new frame; sends the frame to
*			coverage collector and signalizes that there is a new frame
* Parameters :	trans - frame collected by monitor
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::write1(axi_read_burst_frame trans);
		collected_burst = axi_read_burst_frame::type_id::create("collected_burst");
		$cast(collected_burst, trans.clone());

		addr_collected_port.write(collected_burst);	// to coverage collector

		end_simulation = 0;	// there was a new frame, restart counter for end simulation

		->burst_event;	// signalize new burst
	endfunction : write1

//------------------------------------------------------------------------------
/**
* Task : new_frame
* Purpose : process a new frame - perform checks if needed, put it in the queue
*			and finish burst when last frame arrives
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_monitor::new_frame();
		int i = 0;
		bit last = 0;
		axi_read_single_addr single_addr_frame;

		forever begin
			@frame_event;

			num_single_frames++;

			// reset flags
			last = 0;
			i = 0;

			if (checks_enable) begin
				sem.get(1);
				last = check_data_channel(collected_frame);
				sem.put(1);
			end

			sem.get(1);
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
			sem.put(1);
		end
	endtask : new_frame

//------------------------------------------------------------------------------
/**
* Task : new_burst
* Purpose : process a new burst request - performs checks if needed and put it
*			in the queue
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_monitor::new_burst();
		axi_read_whole_burst burst_copy;

		forever begin
			@burst_event;

			burst_copy = axi_read_whole_burst::type_id::create("burst_copy",this);
			burst_copy.copy(collected_burst);

			if (checks_enable) begin
				check_addr_channel(collected_burst);
			end

			sem.get(1);
			burst_queue.push_back(burst_copy);
			sem.put(1);

		end

	endtask : new_burst

//------------------------------------------------------------------------------
/**
* Function : report_phase
* Purpose : report on number of collected frames
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report: AXI monitor collected: %0d bursts, %0d single frames, of which %0d bursts were finished and %0d were not and %0d frames had an error", burst_queue.size()+finished_bursts.size(), num_single_frames, finished_bursts.size(), burst_queue.size(), error_frames.size()), UVM_LOW);
	endfunction : report_phase

//------------------------------------------------------------------------------
/**
* Function : check_data_channel
* Purpose : performs checks on single frames, displays an error if needed and
*			returns information about last frame (termination of burst)
* Parameters :	collected_frame - frame beeing checked
* Return :	bit - last frame in burst / termination signal
**/
//------------------------------------------------------------------------------
	function bit axi_slave_read_monitor::check_data_channel(axi_read_single_frame collected_frame);
		bit last = 0;
		int i = 0;

		// AXI4_ERRS_RDATA_NUM
		// The number of read data items must match the corresponding ARLEN
		// TODO : kako ovo proveriti, ako bude manje, nece se zavrsiti burst
		// a ako je vise, bice error za id

		// check response
		if(collected_frame.resp == SLVERR) begin
			`uvm_warning(get_type_name(), "Collected frame with SLVERR response")
			error_frames.push_back(collected_frame);
			if(terminate_enable)
				last = 1;
		end
		else if (collected_frame.resp == DECERR) begin
			`uvm_warning(get_type_name(), "Collected frame with DECERR response")
			error_frames.push_back(collected_frame);
			if(terminate_enable)
				last = 1;
		end

		for(i = 0; i < burst_queue.size(); i++) begin
			if (burst_queue[i].id == collected_frame.id) begin
				// check last
				if(burst_queue[i].single_frames.size() == (burst_queue[i].len)) begin
					if (!collected_frame.last) begin
						`uvm_warning(get_type_name(), "Last bit not set for last frame in burst")
						error_frames.push_back(collected_frame);
						last = 1;
					end
				end
				else if(collected_frame.last) begin
					`uvm_warning(get_type_name(), "Last bit set for frame that is not last in burst")
					error_frames.push_back(collected_frame);
				end

				// check response
				if((burst_queue[i].lock == EXCLUSIVE) && (collected_frame.resp == OKAY)) begin
					`uvm_warning(get_type_name(), "Recived OKAY response for EXCLUSIVE request")
					error_frames.push_back(collected_frame);
					if(terminate_enable)
						last = 1;
				end

				// AXI4_ERRS_RRESP_EXOKAY
				// An EXOKAY read response can only be given to an exclusive read access
				if((burst_queue[i].lock != EXCLUSIVE) && (collected_frame.resp == EXOKAY)) begin
					`uvm_error(get_type_name(), "AXI4_ERRS_RRESP_EXOKAY: Recieved EXOKAY response for a read that was not exclusive")
					error_frames.push_back(collected_frame);
				end

				// checks id
				break;
			end
		end

		// Assertion AXI4_ERRS_RID
		// The read data must always follow the address that it relates to. Therefore, a slave can only give read data with an ID to match an outstanding read transaction.
		if (i >= burst_queue.size()) begin
			`uvm_error(get_type_name(), "AXI4_ERRS_RID: Collected frame with id that was not requested")
			error_frames.push_back(collected_frame);
			last = 0;	// because there is no burst with this id, there is no need to end it
		end

		return last;
	endfunction : check_data_channel

//------------------------------------------------------------------------------
/**
* Function : check_addr_channel
* Purpose : performs checks on burst requests and displays an error if needed
* Parameters :	collected_burst - burst beeing checked
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::check_addr_channel(axi_read_burst_frame collected_burst);

		// Assertion AXI4_ERRM_ARCACHE
		// When ARVALID is HIGH, if ARCACHE[1] is LOW, then ARCACHE[3:2] must also be LOW
		if(collected_burst.cache[1] == 0)
			if(!(collected_burst.cache[3:2] == 0))
				`uvm_error(get_type_name(), "AXI4_ERRM_ARCACHE: ARCACHE[1] is LOW, but ARCACHE[3:2] is not LOW")

		// check type, len and addr
		case (collected_burst.burst_type)
			FIXED : begin
				// Assertion AXI4_ERRM_ARLEN_FIXED
				// Transactions of burst type FIXED cannot have a length greater than 16 beats
				if(collected_burst.len >= 16)
					`uvm_error(get_type_name(), "AXI4_ERRM_ARLEN_FIXED: Unsuported burst length for FIXED burst type")
			end
			INCR : begin
				// Assertion AXI4_ERRM_ARADDR_BOUNDARY
       			// A read burst cannot cross a 4KB boundary
				if((collected_burst.len * (2**collected_burst.size)) >= 4096)
					`uvm_error(get_type_name(), "AXI4_ERRM_ARADDR_BOUNDARY: Burst crossed 4KB boundary")
			end
			WRAP : begin
				// Assertion AXI4_ERRM_ARLEN_WRAP
				// A read transaction with burst type of WRAP must have a length of 2, 4, 8, or 16
				if(!(collected_burst.len inside {1, 3, 7, 15})) begin
					`uvm_error(get_type_name(), "AXI4_ERRM_ARLEN_WRAP: Unsuported burst length for WRAP burst type")
				end

				// Assertion AXI4_ERRM_ARADDR_WRAP_ALIGN
				// A read transaction with a burst type of WRAP must have an aligned address
				if(collected_burst.addr != ($floor(collected_burst.addr/(2**collected_burst.size))*(2**collected_burst.size)))
					`uvm_error(get_type_name(), "AXI4_ERRM_ARADDR_WRAP_ALIGN: Start address must be aligned for WRAP burst type")
			end
			Reserved : begin
				// Assertion AXI4_ERRM_ARBURST
				// A value of 2'b11 on ARBURST is not permitted when ARVALID is HIGH
				`uvm_error(get_type_name(), "AXI4_ERRM_ARBURST: Reserved burt type not permitted")
			end
		endcase

		// Assertion AXI4_ERRM_ARSIZE
		// The size of a read transfer must not exceed the width of the data interface
		if(collected_burst.size > $clog2(DATA_WIDTH / 8))
			`uvm_error(get_type_name(), "AXI4_ERRM_ARSIZE: Requested size larger than DATA_WIDTH")

		// check exclusive access restrictions
		if(collected_burst.lock == EXCLUSIVE) begin
			// Assertion AXI4_ERRM_EXCL_ALIGN
			// The address of an exclusive access is aligned to the total number of bytes in the transaction
			if(collected_burst.addr != ($floor(collected_burst.addr/(2**collected_burst.size))*(2**collected_burst.size)))
				`uvm_error(get_type_name(), "AXI4_ERRM_EXCL_ALIGN: Start address must be aligned for EXCLUSIVE access")

			// Assertion AXI4_ERRM_EXCL_LEN
			// The number of bytes to be transferred in an exclusive access burst is a power of 2, that is, 1, 2, 4, 8, 16, 32, 64, or 128 bytes
			if(!(((2**collected_burst.size) * collected_burst.len) inside {1, 3, 7, 15, 31, 63, 127}))
				`uvm_error(get_type_name(), "AXI4_ERRM_EXCL_LEN: The number of bytes to be transferred in an exclusive access burst must be a power of 2")

			// Assertion AXI4_ERRM_EXCL_MAX
			// The maximum number of bytes that can be transferred in an exclusive burst is 128
			if(((2**collected_burst.size) * collected_burst.len) > 128)
				`uvm_error(get_type_name(), "AXI4_ERRM_EXCL_MAX: Exceeded max number of bytes that can be transferred in an exclusive burst")
			
			// Assertion AXI4_ERRM_ARLEN_LOCK
			// Exclusive access transactions cannot have a length greater than 16 beats
			if(collected_burst.len >= 16)
				`uvm_error(get_type_name(), "AXI4_ERRM_ARLEN_LOCK: Unsuported burst length for exclusive access")
		end

	endfunction : check_addr_channel

//------------------------------------------------------------------------------
/**
* Task : reset
* Purpose : reset monitor - empty all queues
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_slave_read_monitor::reset();

		`uvm_info(get_type_name(), $sformatf("Monitor reset"), UVM_LOW);
		`uvm_info(get_type_name(), $sformatf("Report: AXI monitor collected: %0d bursts, %0d single frames, of which %0d bursts were finished and %0d were not and %0d frames had an error", burst_queue.size()+finished_bursts.size(), num_single_frames, finished_bursts.size(), burst_queue.size(), error_frames.size()), UVM_LOW);

		sem.get(1);
			num_single_frames = 0;
			error_frames.delete();
			burst_queue.delete();
			finished_bursts.delete();
		sem.put(1);

	endtask : reset

//------------------------------------------------------------------------------
/**
* Function : check_phase
* Purpose : final checks - are all bursts completed
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_slave_read_monitor::check_phase(uvm_phase phase);
		// final checks
		if (checks_enable) begin
			// Assertion AXI4_ERRS_RLAST_ALL_DONE_EOS
			// All outstanding read bursts must have completed
			if(burst_queue.size() > 0)
				`uvm_error(get_type_name(), "AXI4_ERRS_RLAST_ALL_DONE_EOS: Not all outstanding bursts have completed")
		end
	endfunction : check_phase

`endif