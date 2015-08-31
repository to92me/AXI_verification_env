`ifndef AXI_SLAVE_WRITE_BASE_DRIVER_SVH
`define AXI_SLAVE_WRITE_BASE_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

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

endclass

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

endclass


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

	endfunction : build_phase


	extern function void setSlaveConfig(input axi_slave_config cfg);

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



`endif