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

	response_state_enum 						state;
	axi_slave_response							rsp;
	axi_master_write_scheduler 					scheduler;
	static axi_master_write_response_driver 	driverInstance;

	`uvm_component_utils(axi_master_write_response_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		current_frame = new();
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
	endfunction : new

	extern static function axi_master_write_response_driver getDriverInstance(input uvm_component parent);

	extern function void getNextFrame();
	extern function void completeTransaction();
	extern task main();

endclass : axi_master_write_response_driver

function axi_master_write_response_driver axi_master_write_response_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
	begin
		$display("Creating Master Write response driver");
		driverInstance = new("MasterWriteResponseDriver",parent);
	end
	return driverInstance;
endfunction

function void axi_master_write_response_driver::getNextFrame();
    rsp = new();
	rsp.ID = vif.bid;
	rsp.resp = vif.bresp;
endfunction

function void axi_master_write_response_driver::completeTransaction();
	$display("TODO COMPLETE_RESPONSE",);
endfunction

task axi_master_write_response_driver::main();
	this.init();
    forever begin
	    case(state)
		    WAIT_RSP:
		    begin
			    @(posedge vif.sig_clock iff vif.bvalid == 1);
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

		    COMPLETE_TRANSACTION:
		    begin
			    this.completeTransaction();
			    state = WAIT_CLK;
		    end

		    WAIT_CLK_RECIEVE:
		    begin
			    @(posedge vif.sig_clock)
			    state = WAIT_RSP;
		    end
	    endcase
    end
endtask


`endif
