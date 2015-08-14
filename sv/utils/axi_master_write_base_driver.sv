/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 13, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

typedef enum{
	GET_FRAME = 1,
	DRIVE_VIF = 2,
	WAIT_READY = 3,
	WAIT_CLK = 4,
	WAIT_READY_DELAY = 6,
	COMPLETE_TRANSACTION = 5
//	STATE_CALCULATOR = 6
}write_states_enum;

class axi_master_write_base_driver extends uvm_component;

	virtual interface 						axi_if vif;
	axi_single_frame 						current_frame;
	static axi_master_write_base_driver 	driverInstance;
	axi_mssg 								mssg;
	axi_master_write_main_driver			main_driver;
	bit 									valid_default = 1'b1;

//	axi_single_frame						address_queue[$];
	semaphore 								sem;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_master_write_base_driver)



	function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		 if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		main_driver = axi_master_write_main_driver::getDriverInstance(this);
	endfunction : build_phase

	extern static function axi_master_write_base_driver getDriverInsance(input uvm_component parent);

	extern virtual function void getNextFrame();
	extern virtual function void driverVif();
	extern virtual function void completeTransaction();
	extern virtual task main();
	extern virtual function void init();
	extern function void setValiDefaultValue(input bit input_valid);


endclass : axi_master_write_base_driver

function void axi_master_write_base_driver::driverVif();
    $display("ERRROR AXI MASTER WRITE BASE: redefine this please");
endfunction

function void axi_master_write_base_driver::getNextFrame();
    $display("ERRROR AXI MASTER WRITE BASE: redefine this please");
endfunction

task axi_master_write_base_driver::main();
 	 $display("ERRROR AXI MASTER WRITE BASE: redefine this please");
endtask

function void axi_master_write_base_driver::completeTransaction();
 	 $display("ERRROR AXI MASTER WRITE BASE: redefine this please");
endfunction

function void axi_master_write_base_driver::init();
     	 $display("ERRROR AXI MASTER WRITE BASE: redefine this please");
endfunction

function axi_master_write_base_driver axi_master_write_base_driver::getDriverInsance(input uvm_component parent);
	 if(driverInstance == null)
	    begin
	    driverInstance = new("write driver", parent);
		$display("Created  Driver Core");
	    end
	return getDriverInsance;
endfunction

function void axi_master_write_base_driver::setValiDefaultValue(input bit input_valid);
	this.valid_default = input_valid;
endfunction




