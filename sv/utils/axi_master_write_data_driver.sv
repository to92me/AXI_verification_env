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



class axi_master_write_data_driver extends axi_master_write_base_driver;

	write_states_enum 						state = GET_FRAME;
	write_states_enum						next_state;
	static 	axi_master_write_data_driver	driverInstance; 

	// Provide implementations of virtual methods such as get_type_name and create

	// new - constructor
	local function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		current_frame = new();
	endfunction : new

	extern static function axi_master_write_data_driver getDriverInstance(input uvm_component parent); 

	extern function void getNextFrame();
	extern function void driverVif();
	extern function void completeTransaction();
	extern function void calculateStrobe(input axi_single_frame strobe_frame);
	extern function void init();
	extern task main();


endclass : axi_master_write_data_driver

function axi_master_write_data_driver axi_master_write_data_driver::getDriverInstance(input uvm_component parent); 
	if(driverInstance == null)
	begin 
		$display("Creating Axi Master Write Data Driver ");
		driverInstance = new("AxiMasterWriteDataDriver", parent);
	end 
	return driverInstance;
endfunction

function void axi_master_write_data_driver::getNextFrame();

	mssg = main_driver.getDataFrame();

	if(mssg.state == READY)
		begin
		sem.get(1);
		current_frame = mssg.frame;
		sem.put(1);
		end
	else
		sem.get(1);
		current_frame = null;
		sem.put(1);

endfunction


function void axi_master_write_data_driver::driverVif();
    	sem.get(1);
		calculateStrobe(current_frame);
		vif.wid 	= 	current_frame.id;
		vif.wlast 	=  	current_frame.last_one;
		vif.wvalid	= 	1'b1;
		if(current_frame.last_one)
			begin
			vif.wlast = 1'b1;
			end
		sem.put(1);
endfunction

function void axi_master_write_data_driver::completeTransaction();
    vif.wvalid 	=	1'b1;
	vif.wlast 	= 	1'b1;
endfunction

function void axi_master_write_data_driver::init();
    	vif.wid 	= 	0;
		vif.wlast 	=  	0;
		vif.wvalid	= 	valid_default;
endfunction

function void axi_master_write_data_driver::calculateStrobe(input axi_single_frame strobe_frame);
    $display("NOT IMPLEMENTDE STROBE SELECT");
	vif.wdata = current_frame.data;
	vif.wstrb = 1;

endfunction

task axi_master_write_data_driver::main();
	this.init();
	forever
		begin
			case (state)
				GET_FRAME:
				begin
					this.getNextFrame();
					sem.get(1);
					if(current_frame == null)
						begin
							state = WAIT_CLK;
							next_state = GET_FRAME;
						end
					else
						state = DRIVE_VIF;
					sem.put(1);
				end

				DRIVE_VIF:
				begin
					@(posedge vif.sig_clock);
					#10
					this.driverVif();
					state = COMPLETE_TRANSACTION;
				end

				WAIT_READY:
				begin
					state = GET_FRAME;
					if(vif.awready == 1)
							continue;
					@(posedge vif.sig_clock iff vif.awready == 1);
				end

				WAIT_CLK:
				begin
					@(posedge vif.sig_clock);
					state = next_state;
				end

				COMPLETE_TRANSACTION:
				begin
					repeat(current_frame.delay_data)
						@(posedge vif.sig_clock)
					this.completeTransaction();
					state = WAIT_READY;
				end
			endcase
		end
endtask

