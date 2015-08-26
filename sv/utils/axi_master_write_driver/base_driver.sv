`ifndef AXI_MASTER_WRITE_BASE_DRIVER_SVH
`define AXI_MASTER_WRITE_BASE_DRIVER_SVH

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

	virtual interface axi_if 				vif;
	axi_single_frame 						current_frame;
	static axi_master_write_base_driver 	driverInstance;
	axi_mssg 								mssg;
	axi_master_write_main_driver			main_driver;
	axi_master_write_scheduler				scheduler;
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
	virtual function void build();
		`uvm_info("axi master write base vif driver","Building", UVM_MEDIUM);
		main_driver = axi_master_write_main_driver::getDriverInstance(this);
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	endfunction

	extern static function axi_master_write_base_driver getDriverInsance(input uvm_component parent);

	extern virtual task getNextFrame();
	extern virtual task driverVif();
	extern virtual task completeTransaction();
	extern virtual task main();
	extern virtual task init();
	extern task setValiDefaultValue(input bit input_valid);
	extern virtual task reset();


endclass : axi_master_write_base_driver

task axi_master_write_base_driver::driverVif();
    $display("ERRROR AXI MASTER WRITE BASE: redefine this please 1");
endtask

task axi_master_write_base_driver::getNextFrame();
    $display("ERRROR AXI MASTER WRITE BASE: redefine this please 2");
endtask

task axi_master_write_base_driver::main();
 	 $display("ERRROR AXI MASTER WRITE BASE: redefine this please 3");
endtask

task axi_master_write_base_driver::completeTransaction();
 	 $display("ERRROR AXI MASTER WRITE BASE: redefine this please 4");
endtask

task axi_master_write_base_driver::init();
     $display("ERRROR AXI MASTER WRITE BASE: redefine this please 5");
endtask

task axi_master_write_base_driver::reset();
	$display("ERRROR AXI MASTER WRITE BASE: redefine this please 6 ");
endtask

function axi_master_write_base_driver axi_master_write_base_driver::getDriverInsance(input uvm_component parent);
	 if(driverInstance == null)
	    begin
	    driverInstance = new("AxiMasterWriteMainDriverCore", parent);
		$display("Creating Axi Master Write Main Driver Core");
	    end
	return getDriverInsance;
endfunction

task axi_master_write_base_driver::setValiDefaultValue(input bit input_valid);
	this.valid_default = input_valid;
endtask

`endif


