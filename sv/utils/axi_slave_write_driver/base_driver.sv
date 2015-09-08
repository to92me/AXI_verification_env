`ifndef AXI_SLAVE_WRITE_BASE_DRIVER_SVH
`define AXI_SLAVE_WRITE_BASE_DRIVER_SVH


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
* Classes :	1. axi_slave_write_base_driver_delays
* 			2. axi_slave_write_base_driver_ready_default_value
*			3. axi_slave_write_base_driver
******************************************************************/


typedef enum {
	WAIT_VALID = 0,
	DO_DELAY = 1,
	SET_READY = 2,
	COMPLETE_RECIEVE_TRANSFER = 3
} write_slave_states_enum;

typedef enum{
	WAIT_FRAME = 0,
	COLLECT_FRAME =1,
	CHECK_ID_ADDR = 2,
	SEND_FRAME = 3
} write_slave_get_frame_enum;


//-------------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_base_driver_delays  ( RANDOMIZATION CLASS )
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_slave_write_base_driver_delays is randomization class.
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

class axi_slave_write_base_driver_delays;
	rand int 			delay;

	int 				delay_max = 5;
	int 				delay_min = 0;
	int 				cosnt_delay = 2;
	true_false_enum 	const_delay = FALSE ;
	true_false_enum		delay_exist = TRUE;

	constraint ready_delay_csr{ // FIXME CSR NO!
		if(delay_exist == TRUE){
			if(const_delay == TRUE){
				delay == const_delay;
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
	function void setConst_delay_value(int cosnt_delay);
		this.cosnt_delay = cosnt_delay;
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
// CLASS: axi_slave_write_base_driver_ready_default_value  ( RANDOMIZATION CLASS )
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_slave_write_base_driver_ready_default_value is randomization class.
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


class axi_slave_write_base_driver_ready_default_value;
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
// CLASS: axi_slave_write_base_driver
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		axi_slave_write_base_driver is base class with main state machies for recordeing
//		axi packages. In class who extends this class virtual methodes should be overrided
//		and they are colled in coresponding states of state machine
//
//VIRTUAL API:
//		1. virtual task init();
//
//			-at this methode all driving data signlas shold be setted on default value
//			except valid adn ready signal
//
//		2. virtual task send();
//
//			-in this methode recorded data in task getData() should be sent
//
//		3. virtual task waitOnValid(ref true_false_enum ready);
//
//			-in this methode should be checked if valid is active
//
//		4. virtual task getData();
//
//			-when this methode is called data is valid and should be collected
//			from virtual inteface
//
//		5. virtual task completeRecieve();
//
//			-in this methode ready should be setted to corespoing state
// 			(it can be eather active or inactive state)
//
//		6. virtual task setReady();
//
//			-in this task ready should be setted to active state
//
//		7. virtual task getDelay(ref int delay);
//
//			-this methode gets delay between nioticeing valid and seeting
//			ready to actice if it is'n already on active state
//
//		8. virtual task checkIDAddr(ref true_false_enum correct_slave);
//
//			-in this methode should be checked if collected id is coresponding
//			to slave confguration
//
//		9. virtual task waitFrame(ref true_false_enum detected_frame);
//
//			-in this methode should be checked if valid and ready on active
//			if they are thes return TRUE othervise FALSE
//
// API:
//
//		1. extern task setDefaultReady(input ready_default_enum cosnt_ready );
//
//			-this methode sets default ready value
//
//		2. extern task setRandomReady(input int ready_0_ratio, int ready_1_ratio);
//
//			-this methode sets RandomReady with distribution ratios
//
//		3. extern task setReadyDelayRandom(input int deleay_minimum, int delay_maximum);
//
//			-this methode sets delay before calling methode setReady() to  radnom and
//			sets radnom limits ( maximum and minimum )
//
//		4. extern task setReadyDelayConst(input int delay_const);
//
//			-this methode sets delay before calling setReady() methode to constatn value
//			and sets constant value
//
//		5. task setReadyZeroDelay();
//
//			-this methode sets delay before calling setReady() methode to zero delay
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


class axi_slave_write_base_driver extends uvm_component;


	true_false_enum										valid_detected;
	axi_slave_write_base_driver_delays					delay_randomization;
	axi_slave_write_base_driver_ready_default_value		ready_default_randomization;
	axi_single_frame									single_frame;
	axi_slave_write_main_driver 						main_driver;
	protected virtual interface axi_if 					vif;
	int 												delay;
	slave_ID 											slave_ID;
	axi_slave_config									config_obj;
	semaphore 											sem;
	true_false_enum										testing_one_slave = TRUE;

	axi_write_conf										uvc_config_obj;
	axi_write_buss_read_configuration					bus_read_config_obj;




	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_write_base_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		sem = new(1);
		delay_randomization = new();
		ready_default_randomization = new();
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_name(),$sformatf("Building Axi Write Slave Base Driver "), UVM_LOW);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
//		main_driver = axi_slave_write_main_driver::getDriverInstance(this);

		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", uvc_config_obj))
			 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})

		this.setBusReadConfiguration();
		this.configureDelayOptions();

	endfunction : build_phase


	extern function void setSlaveConfig(input axi_slave_config cfg);
	extern virtual function void setBusReadConfiguration();
	extern function void configureDelayOptions();

	extern task main();
	extern task readyTriger();
	extern task packageRecored();
	// this methodes should be overrided if not it will display ERROR
	extern virtual task init();
	extern virtual task send();
	extern virtual task waitOnValid(ref true_false_enum ready);
	extern virtual task getData();
	extern virtual task completeRecieve();
	extern virtual task setReady();
	extern virtual task getDelay(ref int delay);
	extern virtual task checkIDAddr(ref true_false_enum correct_slave);
	extern virtual task waitFrame(ref true_false_enum detected_frame);

	extern task setDefaultReady(input ready_default_enum cosnt_ready );
	extern task setRandomReady(input int ready_0_ratio, int ready_1_ratio);

	extern task setReadyDelayRandom(input int deleay_minimum, int delay_maximum);
	extern task setReadyDelayConst(input int delay_const);
	extern task setReadyZeroDelay();

	extern virtual task setTesting(input true_false_enum testing);

endclass : axi_slave_write_base_driver

	function void axi_slave_write_base_driver::setSlaveConfig(input axi_slave_config cfg);
		config_obj = cfg;
	endfunction

	task axi_slave_write_base_driver::main();
		fork
			this.readyTriger();
			this.packageRecored();
		join
	endtask


	task axi_slave_write_base_driver::readyTriger();
		write_slave_states_enum state;
		true_false_enum correct_slave = FALSE;
		true_false_enum got_valid = FALSE;
		this.init();
	    forever
		    begin
			    case(state)
//Wait master singal valid = 1
				    WAIT_VALID:
				    begin
//					    #2				// FIXME
					    this.waitOnValid(valid_detected);
						state = SET_READY;
				    end

				    SET_READY:
				    begin
//					     $display("                                          SLAVE DATA : SET_READY");
//					    @(posedge vif.sig_clock);
					    this.setReady();
					    state = DO_DELAY;
				    end

				    DO_DELAY:
				    begin
//					     $display("                                          SLAVE DATA : DO DELAY   ");
						this.getDelay(delay);
						repeat(delay)
							@(posedge vif.sig_clock);
						 state = COMPLETE_RECIEVE_TRANSFER;
				    end



				    COMPLETE_RECIEVE_TRANSFER:
				    begin
//					    $display("                                          SLAVE DATA : COMPLETE_RECIEVE_TRANSFER");
					    @(posedge vif.sig_clock);
//					      $display("                                          SLAVE DATA : COMPLETE_RECIEVE_TRANSFER");
					    this.completeRecieve();
					    state = WAIT_VALID;
				    end
			    endcase
		    end
	endtask

	task axi_slave_write_base_driver::packageRecored();
	    write_slave_get_frame_enum state = WAIT_FRAME;
		true_false_enum	correct_slave;
		true_false_enum detected_frame;
	    forever begin
		    case(state)
			    WAIT_FRAME:
			    begin
				    this.waitFrame(detected_frame);
				    if(detected_frame == TRUE)
					 	state = COLLECT_FRAME;
				    else
					    state = WAIT_FRAME;
			    end

			    COLLECT_FRAME:
			    begin
				     this.getData();
				     if(testing_one_slave == FALSE)
						state = CHECK_ID_ADDR;
				     else
					     state = SEND_FRAME;
			    end

			    CHECK_ID_ADDR:
			    begin
				    this.checkIDAddr(correct_slave);
				    if(correct_slave == TRUE)
					    state = SEND_FRAME;
				    else
					    state = WAIT_FRAME;
			    end

			    SEND_FRAME:
			    begin
				    this.send();
				    state = WAIT_FRAME;
			    end
		    endcase
	    end
	endtask

	task axi_slave_write_base_driver::init();
	   $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function init NOT IMPELMENTED !, OVERIDE IT ");
	endtask

	task axi_slave_write_base_driver::send();
		$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function send NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::waitOnValid(ref true_false_enum ready);
	   	$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , task waitOnValid send NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::completeRecieve();
	    	$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , task completeRecieve NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::getData();
	   $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function getData  NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::getDelay(ref int delay);
	     $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , getDelay(ref int delay)  NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::setReady();
	    $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , setReady()NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::checkIDAddr(ref true_false_enum correct_slave);
	    $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR ,checkID() NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::waitFrame(ref true_false_enum detected_frame);
	  	    $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR ,waitFrame() NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::setDefaultReady(input ready_default_enum cosnt_ready );
		sem.get(1);
	  	this.ready_default_randomization.ready_random = FALSE;
		this.ready_default_randomization.ready_default = cosnt_ready;
		sem.put(1);
	endtask

	task axi_slave_write_base_driver::setReadyDelayConst(input int delay_const);
		sem.get(1);
//		this.delay_exist = TRUE;
		this.delay_randomization.cosnt_delay = delay_const;
		this.delay_randomization.delay_exist = TRUE;
		sem.put(1);
	endtask

	task axi_slave_write_base_driver::setReadyDelayRandom(input int deleay_minimum, input int delay_maximum);
		sem.get(1);
		this.delay_randomization.delay_min = delay_maximum;
		this.delay_randomization.delay_max = delay_maximum;
//		this.delay_exist = TRUE;
		this.delay_randomization.delay_exist = TRUE;
		sem.put(1);
	endtask

	task axi_slave_write_base_driver::setReadyZeroDelay();
	    sem.get(1);
//		this.delay_exist = FALSE;
		this.delay_randomization.delay_exist = FALSE;
	    sem.put(1);
	endtask

	task axi_slave_write_base_driver::setRandomReady(input int ready_0_ratio, input int ready_1_ratio);
	    sem.get(1);
		this.ready_default_randomization.ready_0_dist = ready_0_ratio;
		this.ready_default_randomization.ready_1_dist = ready_1_ratio;
		this.ready_default_randomization.ready_random = TRUE;
		sem.put(1);
	endtask

	task axi_slave_write_base_driver::setTesting(input true_false_enum testing);
	   this.testing_one_slave = testing;
	endtask

	function void axi_slave_write_base_driver::configureDelayOptions();
		$display("000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
	    delay_randomization.setDelay_exist(bus_read_config_obj.getReady_delay_exists());
		delay_randomization.setDelay_max(bus_read_config_obj.getReady_delay_maximum());
		delay_randomization.setDelay_min(bus_read_config_obj.getReady_delay_minimum());
		delay_randomization.setConst_delay(bus_read_config_obj.getReady_delay_constant());
		delay_randomization.setConst_delay_value(bus_read_config_obj.getReady_delay_const_value());

		if(bus_read_config_obj.getReady_constant() == FALSE)
			begin
				ready_default_randomization.setReady_random(TRUE);
			end
		else
			begin
			ready_default_randomization.setReady_random(FALSE);
				$display("TOME WORKS 2 ");
			end

		ready_default_randomization.setReady_default(bus_read_config_obj.getReady_const_value());
		ready_default_randomization.setReady_0_dist(bus_read_config_obj.getReady_posibility_of_0());
		ready_default_randomization.setReady_1_dist(bus_read_config_obj.getReady_posibility_of_1());

	endfunction

	function void axi_slave_write_base_driver::setBusReadConfiguration();
		$display("AXI WRITE SLAVE BASE DRIVER OVERRIDE PLEASE!!!!");
	endfunction


`endif