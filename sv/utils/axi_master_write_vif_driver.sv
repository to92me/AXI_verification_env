/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 7, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

typedef enum {
	SEND_ADDR = 0,
	SEND_DATA =1,
	WAIT_FOR_AWREADY_ACTIVE = 2,
	WAIT_FOR_WREADY_ACTIVE = 3,
	WAIT_FOR_CLK = 4,
	GET_FRAME = 5,
	CHECK_FOR_RESPOND = 6 ,
	WAIT_DATA_DELAY = 7,
	END_TRANSACTION = 8
} state_enum;



class axi_master_write_vif_driver extends uvm_component;

	axi_single_frame current_frame;
	axi_mssg next_frame;
	event have_frame_for_sending;
	state_enum state = GET_FRAME;
	state_enum next_state = WAIT_FOR_CLK;

	virtual interface axi_if vif;

	axi_master_write_scheduler scheduler;
	static axi_master_write_vif_driver	driverInstance;

	`uvm_component_utils_begin(axi_master_write_vif_driver)
	 `uvm_field_object(current_frame, UVM_DEFAULT)
	 `uvm_field_object(driverInstance, UVM_DEFAULT)
 `uvm_component_utils_end


	// CONSTRUCTOR
	local function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//BUILD
	local function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		 if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
	endfunction : build_phase

	// GET INSTANCE - sungleton
	extern static function axi_master_write_vif_driver getDriverInstance(input uvm_object parent);

	//metodes specified to comunicate with scheduler and env
	extern function void getNexItem();
	extern task main();
	extern function void reset();
//	extern task mainAddr();
//	extern task mainData();
	extern task mainRsp();

	//metodes used for driving interface
	extern function void calculateStrobe(axi_single_frame);

endclass : axi_master_write_vif_driver


	function axi_master_write_vif_driver axi_master_write_vif_driver::getDriverInstance(input uvm_object parent);
		if(driverInstance == null)
			begin
				$display("Creating master driver");
				driverInstance = new("Master Driver", parent);
				this.build;
			end;
		return driverInstance;
	endfunction


function void axi_master_write_vif_driver::getNexItem();
    next_frame = scheduler.getFrameForDrivingVif();
	if (next_frame.state == READY)
		current_frame = next_frame.frame;
	else
		current_frame = null;
endfunction

function void axi_master_write_vif_driver::reset();
    next_frame = null;
	current_frame = null;

	vif.awid	= 	0;
	vif.awaddr	= 	0;
	vif.awlen	=	0;
	vif.awsize 	=	0;
	vif.awburst =	0;
	vif.awlock 	=	0;
	vif.awcache = 	0;
	vif.awprot 	=	0;
	vif.awqos	= 	0;
	vif.awregion=	0;
	vif.awvalid	=	0;

	vif.wdata 	= 	0;
	vif.wstrb	=	0;
	vif.wlast	=	0;
	vif.wvalid 	= 	0;

endfunction

task axi_master_write_vif_driver::main();
	forever
		begin
			case (state)
//WAIT CLK
				WAIT_FOR_CLK:
				begin
					@(posedge vif.sig_clock);
					state = next_state;
				end

				GET_FRAME:
				begin
					this.getNexItem();
					if(current_frame.first_one)
					state = SEND_ADDR;
				end
//WAIT AWREADY
				WAIT_FOR_AWREADY_ACTIVE:
				begin
					if(vif.awready == 1)
						continue;
					else
						@(posedge vif.awready);
				end
// WAIT WREADY
				WAIT_FOR_WREADY_ACTIVE:
				begin
					if(vif.wready == 1)
						continue;
					else
						@(posedge vif.wready);
				end
// SEND DATA
				SEND_DATA:
				begin
					calculateStrobe(current_frame);
					vif.wlast 	<=  current_frame.last_one;
					vif.wvalid	<= 	1'b1;
					if(current_frame.last_one == TRUE)
						state = CHECK_FOR_RESPOND;
					else
						state = END_TRANSACTION;
				end
//SEND ADDR
				SEND_ADDR:
				begin
					vif.awid	<= current_frame.id;
					vif.awaddr	<= current_frame.addr;
					vif.awlen 	<= current_frame.len;
					vif.awsize 	<= current_frame.size;
					vif.awburst <= current_frame.burst_type;
					vif.awlock 	<= current_frame.lock;
					vif.awcache <= current_frame.cache;
					vif.awprot 	<= current_frame.prot;
					vif.awqos 	<= current_frame.qos;
					vif.awregion<= current_frame.region;
					vif.awvalid <= 1'b1;
					state = WAIT_DATA_DELAY;
				end
//RESPONSE
				CHECK_FOR_RESPOND:
				begin
					$display("TODO check for responde");
				end
//WAIT DELAY
			 	WAIT_DATA_DELAY:
			 	begin
				 	repeat(current_frame.delay_addrdata)
					 	begin
						 	@(posedge vif.sig_clock);
					 	end
					 state = SEND_DATA;
			 	end

			 	END_TRANSACTION:
			 	begin
				 	vif.awvalid <= 1'b0;
				 	vif.wvalid <= 1'b0;
				 	vif.bready <= 1'b0;
			 	end

			endcase
		end
endtask



function axi_master_write_vif_driver::calculateStrobe(axi_single_frame);

endfunction

task axi_master_write_vif_driver::mainRsp();
	axi_slave_response rsp;
	forever
		begin
			rsp = new();
			@(posedge vif.bvalid)
			rsp.ID = vif.bid;
			rsp.resp = vif.bresp;
			vif.bready = 1'b0;
			scheduler.putResponseFromSlave(rsp);
		end

endtask





