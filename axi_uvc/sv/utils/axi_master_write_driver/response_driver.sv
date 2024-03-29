`ifndef AXI_MASTER_WRITE_RESPONS_DRIVER_SVH
`define AXI_MASTER_WRITE_RESPONS_DRIVER_SVH

/****************************************************************
* Project : AXI UVC
*
* File : response_driver.sv
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
* Description : axi master write response bus driver
*
* Classes :	1. axi_master_write_response_driver
******************************************************************/


typedef enum{
	WAIT_RSP_VALID = 0 ,
	DELAY_RSP_READY = 1,
	COMPLETE_RSP = 2,
	SET_RSP_READY = 3
} master_write_response_dirver_ready_responder_eunum;

typedef enum{
	WAIT_RSP_FRAME = 0,
	COLLECT_RSP_FRAME = 1,
	SEND_RSP_FRAME = 2
} master_write_respons_driver_package_record_enum;


//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_response_driver
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			class axi_master_write_response_driver gets items from response bus
//			from slave and sends it to scheduler
//
//	API:
//		1.main()
//
//			-this methode is main loop of driver and should be forked in module
//			where is driver instaced
//
// CONFIGURATIONS:
//
//
//
// REQUIREMENTS:
//		1. axi virtual interface - axi_if must be properli set in uvm_database
//
//		2. scheculer instance - sheduler must be implemented with methode
//		putResponseFromSlave(axi_slave_response) to push collected response
//		from slave
//
//------------------------------------------------------------------------------

class axi_master_write_response_driver extends axi_master_write_base_driver;

	axi_slave_response									rsp;
	static axi_master_write_response_driver 			driverInstance;
	axi_master_write_base_driver_delays					random_delay;
	axi_master_write_base_driver_ready_default_value	random_ready;

	`uvm_component_utils(axi_master_write_response_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		current_frame = new();
		random_delay = new();
		random_ready = new();

		random_delay.delay_max = 3;
		random_delay.delay_min = 0;

	endfunction : new

	function void build_phase(input uvm_phase phase);
		super.build_phase(phase);
	endfunction

	extern static function axi_master_write_response_driver getDriverInstance(input uvm_component parent);

	extern task getNextFrame();
	extern task completeTransaction();
	extern task main();
	extern task init();
	extern task packageRecorder();
	extern task readyResponder();
	extern function void configureDelayOptions();
	extern function void setBusWriteConfiguration();


endclass : axi_master_write_response_driver

function axi_master_write_response_driver axi_master_write_response_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
	begin
		$display("Creating Master Write response driver");
		driverInstance = new("MasterWriteResponseDriver",parent);
	end
	return driverInstance;
endfunction

function void axi_master_write_response_driver::configureDelayOptions();

	random_delay.setDelay_exist(bus_driver_read_configuration.getReady_delay_exists());
	random_delay.setDelay_max(bus_driver_read_configuration.getReady_delay_maximum());
	random_delay.setDelay_min(bus_driver_read_configuration.getReady_delay_minimum());
	random_delay.setConst_delay(bus_driver_read_configuration.getReady_delay_constant());
	random_delay.setConst_delay_value(bus_driver_read_configuration.getReady_delay_const_value());

	if(bus_driver_read_configuration.getReady_constant() == FALSE)
		begin
			random_ready.setReady_random(TRUE);
			$display("TOME SAD 1 ");
		end
	else
		begin
			random_ready.setReady_random(FALSE);
			$display("TOME WORKS 1 ");
		end

	random_ready.setReady_default(bus_driver_read_configuration.getReady_const_value());
	random_ready.setReady_0_dist(bus_driver_read_configuration.getReady_posibility_of_0());
	random_ready.setReady_1_dist(bus_driver_read_configuration.getReady_posibility_of_1());

endfunction

function void axi_master_write_response_driver::setBusWriteConfiguration();
   	bus_driver_read_configuration = uvc_config_obj.getMaster_resp_config_object();
endfunction

task axi_master_write_response_driver::getNextFrame();
    rsp = new();
	rsp.ID = vif.bid;
	rsp.rsp = vif.bresp;
endtask

task axi_master_write_response_driver::completeTransaction();
//	$display("sending recieved package from slave ");
	scheduler.putResponseFromSlave(rsp);
endtask

task axi_master_write_response_driver::main();
    fork
	    this.readyResponder();
	    this.packageRecorder();
    join
endtask

task axi_master_write_response_driver::readyResponder();
	master_write_response_dirver_ready_responder_eunum state = WAIT_RSP_VALID;
	this.init();
    forever
	    begin
	    case(state)
		    WAIT_RSP_VALID:
		    begin
			    @(posedge vif.sig_clock iff vif.bvalid == 1'b1 );
			     state = SET_RSP_READY;
		    end

		    SET_RSP_READY:
		    begin
			    if(vif.bready != 1)
				    begin
					    #2
					    vif.bready <= 1'b0;
				    end
			    state = DELAY_RSP_READY;
		    end

		    DELAY_RSP_READY:
		    begin
			    assert(random_delay.randomize());
			    repeat (random_delay.delay)
				    begin
						@(posedge vif.sig_clock);
				    end
			    vif.bready <= 1'b1;
			    state = COMPLETE_RSP;
		    end

		    COMPLETE_RSP:
		    begin
			    assert(random_ready.randomize());
//			    #2
			    if(random_ready.ready == READY_DEFAULT_0)
					vif.bready <= 'b0;
			    else
				    vif.bready <= 'b1;
			    state = WAIT_RSP_VALID;
		    end

	    endcase
    end
endtask

task axi_master_write_response_driver::packageRecorder();
master_write_respons_driver_package_record_enum state = WAIT_RSP_FRAME;
	forever begin
		case(state)
			WAIT_RSP_FRAME:
			begin
				@(posedge vif.sig_clock);
				if(vif.bvalid == 1 && vif.bready == 1)
					state = COLLECT_RSP_FRAME;
				else
					state = WAIT_RSP_FRAME;
			end

			COLLECT_RSP_FRAME:
			begin
			   	this.getNextFrame();
				state =	SEND_RSP_FRAME;
			end

			SEND_RSP_FRAME:
			begin
				scheduler.putResponseFromSlave(rsp);
				state = WAIT_RSP_FRAME;
			end
		endcase
	end
endtask


task axi_master_write_response_driver::init();
	assert(random_ready.randomize());
//	  #2
	if(random_ready.ready == READY_DEFAULT_0)
		vif.bready <= 'b0;
	 else
	  	vif.bready <= 'b1;
//	vif.bready <= 1'b0;
endtask

`endif
