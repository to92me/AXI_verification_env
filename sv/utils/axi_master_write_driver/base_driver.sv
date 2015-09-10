`ifndef AXI_MASTER_WRITE_BASE_DRIVER_SVH
`define AXI_MASTER_WRITE_BASE_DRIVER_SVH


/****************************************************************
* Project : AXI UVC
*
* File : base_driver.sv
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
* Description : base bus driver with radnomization classes
*
* Classes :	1. axi_master_write_base_driver_delays
* 			2. axi_master_write_base_driver_ready_default_value
*			3. axi_master_write_base_driver ( abstract class )
******************************************************************/





typedef enum{
	GET_FRAME = 0,
	DRIVE_VIF = 1,
	DELAY_WVALID = 2,
	SET_WVALID = 3,
	WAIT_TO_COLLET = 4
}axi_master_write_base_driver_valid_core;


typedef enum{
	WAIT_TO_COLLECT = 2,
	INFORM_VALID_CORE = 3
}axi_master_write_base_driver_data_core;

typedef enum{
	WAIT_WVALID = 0,
	SEND_DATA = 1,
	INFOR_TRIGER = 2
}axi_master_write_driver_data_enum;

//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_base_driver_delays  ( RANDOMIZATION CLASS )
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_master_write_base_driver_delays is randomization class.
//			it it radomizes one int value in given constraints
//
// API:
//		1. setConst_delay(true_false_enum const_delay);
//
//			- if this is set random delay will be constant and equal to
//			cosnt_delay_value
//
//		2. setCosnt_delay(int cosnt_delay_value);
//
//			-this methode sets constant_delay_value
//
//		3. setDelay_exist(true_false_enum delay_exist);
//
//			-this methode sets if delay exists. If this methode is called
//			with FALSE then random delay will be always 0
//
//		4. setDelay_max(int delay_max);
//
//			-this methode sets value of delay_max. If radnom delay exist
//			and is not constant then delay will be inside delay_min and
//			delay_max.
//
//		5. setDelay_min(int delay_min);
//
//			-this methode sets value of delay_min.If radnom delay exist
//			and is not constant then delay will be inside delay_min and
//			delay_max.
//
//		6. int getRandomDelay();
//			this methode returns random delay
//
//------------------------------------------------------------------------------

class axi_master_write_base_driver_delays;
	rand int 			delay;

	int 				delay_max = 5;
	int 				delay_min = 0;
	int 				cosnt_delay_value = 2;
	true_false_enum 	const_delay = FALSE ;
	true_false_enum		delay_exist = TRUE;

	constraint ready_delay_cs{ // FIXME CSR NO!
		if(delay_exist == TRUE){
			if(const_delay == TRUE){
				delay == cosnt_delay_value;
			}else{
				delay inside {[delay_min : delay_max]};
			}
		}else{
				delay == 0;
			}
	}


	// Set const_delay
	function void setConst_delay(true_false_enum const_delay);
		this.const_delay = const_delay;
	endfunction

	// Set cosnt_delay
	function void setConst_delay_value(int cosnt_delay_value);
		this.cosnt_delay_value = cosnt_delay_value;
	endfunction

	// Get delay
	function int getRandomDelay();
		return delay;
	endfunction

	// Set delay_exist
	function void setDelay_exist(true_false_enum delay_exist);
		this.delay_exist = delay_exist;
	endfunction

	// Set delay_max
	function void setDelay_max(int delay_max);
		this.delay_max = delay_max;
	endfunction

	// Set delay_min
	function void setDelay_min(int delay_min);
		this.delay_min = delay_min;
	endfunction




endclass

//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_base_driver_ready_default_value  ( RANDOMIZATION CLASS )
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_master_write_base_driver_ready_default_value is randomization class.
//			it it radomizes ready_default_enum value ( it can be READY_DEFAULT_0 and
//			READY_DEFAULT_1) and returns ready value in given constraints
//
// API:
//		1. setReady_random(true_false_enum ready_random);
//
//			- if this is set random ready will have random value
//			or default value
//
//		2. setReady_default(ready_default_enum ready_default);
//
//			-set default value of ready
//
//		3. setReady_1_dist(int ready_1_dist);
//
//			-this methode sets distribution value for ready_1_dist. If this class
//			is in random mode, it will chose between READY_DEFAULT_0 and READY_DEFAULT_1
//			in distribution ( ready_0_dist and ready_1_dist)
//
//		4. setReady_0_dist(int ready_0_dist);
//			-this methode sets distribution value for ready_0_dist. If this class
//			is in random mode, it will chose between READY_DEFAULT_0 and READY_DEFAULT_1
//			in distribution ( ready_0_dist and ready_1_dist)
//
//		5. ready_default_enum getRandomReady()
//
//			-this methode returns radnom ready
//
//------------------------------------------------------------------------------

class axi_master_write_base_driver_ready_default_value;
	rand ready_default_enum ready;

	true_false_enum			ready_random = TRUE;
	ready_default_enum		ready_default = READY_DEFAULT_0 ;
	int 					ready_1_dist = 1;
	int 					ready_0_dist = 3;

	constraint valid_default_csr{

		 if(ready_random == TRUE){
			 ready dist{
				READY_DEFAULT_0 	:= 	ready_0_dist,
				READY_DEFAULT_1 	:= 	ready_1_dist
			 };
		 }else{
			 ready == ready_default;
			 }
	}

	// Get ready
	function ready_default_enum getRandomReady();
		return ready;
	endfunction

	// Set ready_0_dist
	function void setReady_0_dist(int ready_0_dist);
		this.ready_0_dist = ready_0_dist;
	endfunction

	// Set ready_1_dist
	function void setReady_1_dist(int ready_1_dist);
		this.ready_1_dist = ready_1_dist;
	endfunction

	// Set ready_default
	function void setReady_default(ready_default_enum ready_default);
		this.ready_default = ready_default;
	endfunction

	// Set ready_random
	function void setReady_random(true_false_enum ready_random);
		this.ready_random = ready_random;
	endfunction



endclass


//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_base_driver  ( ABSTRACT )
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		axi_master_write_base_driver is class with virtual methodes and this class should
//		be extended in drivers that drive axi bus
//
//VIRTUAL API:
//			virtual task getNextFrame();
//			virtual task driverVif();
//			virtual task completeTransaction();
//			virtual task main();
//			virtual task init();
//			virtual task reset();
//
// REQUIREMENTS:
//		1. axi virtual interface - axi_if must be properli set in uvm_database
//
//		2. main_driver - main driver isntance - main driver should be implemented and
//		setted to this variable
//
//		3. scheduler - scheduler instance - scheduler sholud be implemented and setted
//		to this variable
//------------------------------------------------------------------------------

class axi_master_write_base_driver extends uvm_component;

	virtual interface axi_if 				vif;
	axi_single_frame 						current_frame;
	static axi_master_write_base_driver 	driverInstance;
	axi_mssg 								mssg;
	axi_master_write_main_driver			main_driver;
	axi_master_write_scheduler2_0			scheduler;
	bit 									valid_default = 1'b1;
	axi_write_conf							uvc_config_obj;
	axi_write_buss_write_configuration		bus_driver_configuration;
	axi_write_buss_read_configuration		bus_driver_read_configuration;
	axi_master_write_base_driver_delays		random_delay;

//	axi_single_frame						address_queue[$];
	semaphore 								sem;

	// Provide implementations of virtual methods such as get_type_name and create
`uvm_component_utils(axi_master_write_base_driver)




	function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		random_delay = new();
	endfunction : new

	// build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("axi master write base vif driver","Building", UVM_MEDIUM);
		main_driver = axi_master_write_main_driver::getDriverInstance(this);
		scheduler = axi_master_write_scheduler2_0::getSchedulerInstance(this);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", uvc_config_obj))
			 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})

		this.setBusWriteConfiguration();
		this.configureDelayOptions();

	endfunction

	extern static function axi_master_write_base_driver getDriverInsance(input uvm_component parent);

	extern virtual task getNextFrame();
	extern virtual task driverVif();
	extern virtual task completeTransaction();
	extern virtual task main();
	extern virtual task init();
	extern task setValiDefaultValue(input bit input_valid);
	extern virtual task reset();
	extern virtual function void configureDelayOptions();
	extern virtual function void setBusWriteConfiguration();


endclass : axi_master_write_base_driver

function void axi_master_write_base_driver::setBusWriteConfiguration();
    $display("ERRROR AXI MASTER WRITE BASE: redefine this please 0");
endfunction

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

function void axi_master_write_base_driver::configureDelayOptions();
	random_delay.setConst_delay(bus_driver_configuration.getValid_constant_delay());
	random_delay.setConst_delay_value(bus_driver_configuration.getValid_contant_delay_value());
	random_delay.setDelay_exist(bus_driver_configuration.getValid_delay_exists());
	random_delay.setDelay_max(bus_driver_configuration.getDelay_maximum());
	random_delay.setDelay_min(bus_driver_configuration.getDelay_minimum());
	$display("Configuration master driver bus driver DONE");
endfunction

`endif


