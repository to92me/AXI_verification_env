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
	SEND_DATA = 0,
	WAIt_FOR_READY_ACTIVE = 1,
	WAIT_FOR_CLK = 2,
	WAIT_FOR_FRAME = 3,
	GET_FRAME = 4,
	TRANSACTION_DONE =5 ,
	CHECK_FOR_RESPOND =6 ,
	ERROR = 7
} state_enum;


class axi_master_write_vif_driver extends uvm_component;

	axi_single_frame current_frame;
	axi_mssg next_frame;
	event have_frame_for_sending;
	state_enum state = WAIT_FOR_CLK;
	state_enum next_state = GET_FRAME;

	virtual interface axi_if vif;

	axi_master_write_scheduler scheduler;
	static axi_master_write_vif_driver	driverInstance;

	`uvm_component_utils_begin(axi_master_write_vif_driver)
	 `uvm_field_object(current_frame, UVM_DEFAULT)
	 `uvm_field_object(driverInstance, UVM_DEFAULT)
 `uvm_component_utils_end


	// constructor
	local function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build
	local function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		 if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
	endfunction : build_phase

	// get instace - singleton class
	extern static function axi_master_write_vif_driver getDriverInstance(input uvm_object parent);

	//metodes specific to driver
	extern function void getNexItem();
	extern task main();
	extern function void reset();
//	extern function void ()
	extern function void sendFrame();
	extern function void checkForRespond();
	extern function void error();
	extern function void transactioDone();
	extern function void checkForResponde();
	extern function void waitForSlaveReady();

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
endfunction

function void axi_master_write_vif_driver::reset();
    next_frame = null;
	current_frame = null;
endfunction

task axi_master_write_vif_driver::main();
	forever
		begin
			case (state)
				WAIT_FOR_CLK:
					@(posedge vif.sig_clock);
				GET_FRAME:
					this.getNexItem();
				WAIt_FOR_READY_ACTIVE:
					this.wait
				default     : ;
			endcase
		end
endtask






