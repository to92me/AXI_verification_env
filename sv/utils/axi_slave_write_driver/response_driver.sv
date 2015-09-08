`ifndef AXI_SLAVE_WRITE_RESPONSE_DRIVER_SVH
`define AXI_SLAVE_WRITE_RESPONSE_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------



typedef enum{
	GET_RSP_MSSG = 0,
	DRIVE_RSP_VIF = 1,
	DELAY_RSP_VALID = 2,
	SET_RSP_VALID = 3,
	WAIT_ON_MASTER_READY = 4,
	COMPLETE_RSP_MSSG = 5
} rsp_states_enum;


class axi_slave_write_response_driver extends uvm_component;
//	axi_slave_write_rsp_mssg			rsp_queue[$];
	mailbox#(axi_slave_write_rsp_mssg)	rsp_mbox;
	axi_slave_write_rsp_mssg			current_rsp;
	virtual interface axi_if 			vif;
	rsp_states_enum						state = GET_RSP_MSSG;
	semaphore 							sem;
	axi_slave_write_base_driver_delays 	valid_delay;
	axi_write_conf						uvc_config_obj;
	axi_write_buss_write_configuration	bus_write_config_obj;


	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_write_response_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		rsp_mbox = new();
		current_rsp = new();
		valid_delay = new();

		valid_delay.delay_max = 3;
		valid_delay.delay_min = 0;
		valid_delay.const_delay = FALSE;
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		super.build_phase(phase);

		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", uvc_config_obj))
			 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})



//		this.init();
	endfunction : build_phase

	extern task main();
	extern task pushRsp(input axi_slave_write_rsp_mssg message);
	extern task driverVif();
	extern task completeRspMessage();
	extern task init();
	extern function void setConfiguration();
//	extern task

//	extern static function axi_slave_write_response_driver getDriverInstace(uvm_component parent);

endclass : axi_slave_write_response_driver
/*
function axi_slave_write_response_driver axi_slave_write_response_driver::getDriverInstace(input uvm_component parent);
    if(driverInstance == null)
	    begin
		    $display("Creating Axi Slave Write Response Driver");
		    driverInstance = new("AxiSlaveWriteResponseDriver", parent);
	    end
   return driverInstance;
endfunction
*/

task axi_slave_write_response_driver::pushRsp(input axi_slave_write_rsp_mssg message);
	$display("SLAVE recieved message to send");
   	rsp_mbox.put(message);
endtask

task axi_slave_write_response_driver::driverVif();
	#2
	vif.bid   <= current_rsp.ID;
    vif.bresp <= current_rsp.rsp;
endtask

task axi_slave_write_response_driver::completeRspMessage();
	#2
	vif.bvalid <= 1'b0;
endtask

task axi_slave_write_response_driver::init();
	vif.bvalid <= 1'b0;
	vif.bresp <= 0;
	vif.bid <= 0;
endtask

task axi_slave_write_response_driver::main();
	init();
	forever
		begin
			case(state)
				GET_RSP_MSSG:
				begin
					rsp_mbox.get(current_rsp);
					state = DRIVE_RSP_VIF;
//					if(rsp_mbox.try_get(current_rsp))
//						begin
//							state = DRIVE_RSP_VIF;
//						end
//					else
//						begin
//							state = GET_RSP_MSSG;
//						end
				end

				DRIVE_RSP_VIF:
				begin
					@(posedge vif.sig_clock);
//					#10
					this.driverVif();
					state = DELAY_RSP_VALID;
				end

				DELAY_RSP_VALID:
				begin
					assert(valid_delay.randomize());
					repeat(valid_delay.delay)
						begin
							@(posedge vif.sig_clock);
						end
					state = SET_RSP_VALID;
				end

				SET_RSP_VALID:
				begin
//					$display(":::::::::::::::::::::::::::::::::::::::::::::::::TOOOMEEEEE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
					this.vif.bvalid <= 1'b1;
					state = WAIT_ON_MASTER_READY;
				end

				WAIT_ON_MASTER_READY:
				begin
//					$display(" WAITING BREADYYYY ");
					@(posedge vif.sig_clock iff vif.bready == 1'b1);
//					if(vif.bready == 1'b1)
//						state = COMPLETE_RSP_MSSG;
//					else
//						@(posedge vif.sig_clock);
//						state=WAIT_ON_MASTER_READY;
//					$display(" GOOOOOT BREADYYYY ");
					state = COMPLETE_RSP_MSSG;
				end

				COMPLETE_RSP_MSSG:
				begin
					this.completeRspMessage();
					state = GET_RSP_MSSG;
				end
			endcase
		end
endtask

function void axi_slave_write_response_driver::setConfiguration();
   bus_write_config_obj = uvc_config_obj.getSlave_resp_config_object();

	valid_delay.setConst_delay(bus_write_config_obj.getValid_constant_delay());
	valid_delay.setConst_delay_value(bus_write_config_obj.getValid_contant_delay_value());
	valid_delay.setDelay_exist(bus_write_config_obj.getValid_delay_exists());
	valid_delay.setDelay_max(bus_write_config_obj.getDelay_maximum());
	valid_delay.setDelay_min(bus_write_config_obj.getDelay_minimum());

endfunction

`endif
