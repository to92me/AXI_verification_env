`ifndef AXI_SLAVE_WRITE_BASE_DRIVER_SVH
`define AXI_SLAVE_WRITE_BASE_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

typedef enum {
	WAIT_VALID = 0,
	COLLECT_DATA =1,
	DO_DELAY = 2,
	SET_READY = 3,
	SEND_FRAME = 4,
	COMPLETE_RECIEVE_TRANSFER = 5
} write_slave_states_enum;

typedef enum{
	READY_DEFAULT_0 = 0,
	READY_DEFAULT_1 = 1
}ready_default_enum;

class axi_slave_write_base_driver_delays;
	rand int 			delay;

	int 				delay_max = 5;
	int 				delay_min = 0;
	int 				cosnt_delay = 2;
	true_false_enum 	const_delay = FALSE ;
	true_false_enum		delay_exist = TRUE;

	constraint ready_delay_csr{
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
	ready_default_enum		ready_default;
	int 					ready_1_dist = 1;
	int 					ready_0_dist = 1;

	constraint valid_default_csr{
		 ready dist{
			READY_DEFAULT_0 	:= 	ready_0_dist,
			READY_DEFAULT_1 	:= 	ready_1_dist
		 };
	}

endclass


class axi_slave_write_base_driver extends uvm_component;


	write_slave_states_enum 							state = WAIT_VALID;
	true_false_enum										ready_detected;
//	true_false_enum 									delay_exist;
	axi_slave_write_base_driver_delays					delay_randomization;

	axi_slave_write_base_driver_ready_default_value		ready_default_randomization;
//	ready_default_enum									ready_default;
//	true_false_enum										ready_rand;

	axi_single_frame									single_frame;

	axi_slave_write_main_driver 						main_driver;
	protected virtual interface axi_if 					vif;
	int 												delay;

	semaphore 											sem;



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


	extern virtual task main();
	// this methodes should be overrided if not it will display ERROR
	extern virtual function void init();
	extern virtual function void  send();
	extern virtual task waitOnValid(ref true_false_enum ready);
	extern virtual task getData();
	extern virtual task completeRecieve();
	extern virtual task setReady();
	extern virtual task getDelay(ref int delay);

	extern task setDefaultReady(input ready_default_enum cosnt_ready );
	extern task setRandomReady(input int ready_0_ratio, int ready_1_ratio);

	extern task setReadyDelayRandom(input int deleay_minimum, int delay_maximum);
	extern task setReadyDelayConst(input int delay_const);
	extern task setReadyZeroDelay();


endclass : axi_slave_write_base_driver

	task axi_slave_write_base_driver::main();
		this.init();
	    forever
		    begin
			    case(state)
//Wait master singal valid = 1
				    WAIT_VALID:
				    begin
					    this.waitOnValid(ready_detected);
					    if (ready_detected == TRUE)
						    begin
							    state = COLLECT_DATA;
						    end
					    else
						    begin
							    @(posedge vif.sig_clock)
							    state = WAIT_VALID;
						    end
				    end

// if data is valid get data from vif
				    COLLECT_DATA:
				    begin
					    this.getData();
					    state = DO_DELAY;
				    end

// when colected data if delay is setted wait delay time
				    DO_DELAY:
				    begin
						this.getDelay(delay);
						repeat(delay)
							begin
								@(posedge vif.sig_clock)
							 	state = SET_READY;
							end
				    end

// after delay or not set ready singnal to signal master that slave has colected data from bus
				    SET_READY:
				    begin
					    this.setReady();
					    state = SEND_FRAME;
				    end

// whea
				    SEND_FRAME:
				    begin
					    this.send();
					    state = COMPLETE_RECIEVE_TRANSFER;
				    end

				    COMPLETE_RECIEVE_TRANSFER:
				    begin
					    this.completeRecieve();
				    end
			    endcase
		    end
	endtask

	function void axi_slave_write_base_driver::init();
	   $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function init NOT IMPELMENTED !, OVERIDE IT ");
	endfunction

	function void axi_slave_write_base_driver::send();
		$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function send NOT IMPELMENTED, OVERIDE IT  !");
	endfunction

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


`endif