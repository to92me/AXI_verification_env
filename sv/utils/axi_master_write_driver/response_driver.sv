`ifndef AXI_MASTER_WRITE_RESPONS_DRIVER_SVH
`define AXI_MASTER_WRITE_RESPONS_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

typedef enum{
	WAIT_RSP = 1 ,
	GET_DATA = 2,
	SEND_RESPONSE = 3,
	COMPLETE_RECIEVE = 4,
	WAIT_CLK_RECIEVE = 5
} response_state_enum;

class axi_master_write_response_driver extends axi_master_write_base_driver;

	response_state_enum 						state = WAIT_RSP;
	axi_slave_response							rsp;
	axi_master_write_scheduler 					scheduler;
	static axi_master_write_response_driver 	driverInstance;
	axi_slave_write_base_driver_delays			random_delay;

	`uvm_component_utils(axi_master_write_response_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		current_frame = new();
		random_delay = new();
	endfunction : new

	extern static function axi_master_write_response_driver getDriverInstance(input uvm_component parent);

	extern task getNextFrame();
	extern task completeTransaction();
	extern task main();
	extern function void build();
	extern task init();

endclass : axi_master_write_response_driver

function axi_master_write_response_driver axi_master_write_response_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
	begin
		$display("Creating Master Write response driver");
		driverInstance = new("MasterWriteResponseDriver",parent);
	end
	return driverInstance;
endfunction

task axi_master_write_response_driver::getNextFrame();
    rsp = new();
	rsp.ID = vif.bid;
	rsp.rsp = vif.bresp;
endtask

task axi_master_write_response_driver::completeTransaction();
	$display("sending recieved package from slave ");
	scheduler.putResponseFromSlave(rsp);
endtask

task axi_master_write_response_driver::main();
	this.init();
    forever
	    begin
	    case(state)
		    WAIT_RSP:
		    begin
			    @(posedge vif.sig_clock iff vif.bvalid == 1'b1 );
			     state = GET_DATA;
		    end

		    GET_DATA:
		    begin
			   this.getNextFrame();
				state = SEND_RESPONSE;
		    end

		    SEND_RESPONSE:
		    begin
			    scheduler.putResponseFromSlave(rsp);
			    state = COMPLETE_RECIEVE;
		    end

		    COMPLETE_RECIEVE:
		    begin
			    assert(random_delay.randomize());
			    repeat (random_delay.delay)
				    begin
						@(posedge vif.sig_clock);
				    end
				vif.bready <= 'b1;
			    state = WAIT_CLK_RECIEVE;
		    end

		    WAIT_CLK_RECIEVE:
		    begin
			    @(posedge vif.sig_clock);
			    vif.bready <= 1'b0;
			    state = WAIT_RSP;
		    end
	    endcase
    end
endtask

function void axi_master_write_response_driver::build();
    scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
	if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
endfunction

task axi_master_write_response_driver::init();
	vif.bready <= 1'b0;
endtask

`endif
