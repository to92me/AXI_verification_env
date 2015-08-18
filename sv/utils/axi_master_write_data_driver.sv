`ifndef AXI_MASTER_WRITE_DATA_DRIVER_SVH
`define AXI_MASTER_WRITE_DATA_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------



class axi_master_write_data_driver extends axi_master_write_base_driver;

	write_states_enum 						state = GET_FRAME;
	write_states_enum						next_state;
	static 	axi_master_write_data_driver	driverInstance;
	int 									clock_counter;

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
	extern function void reset();
	extern task spinClock(input int clocks);
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
		begin
		sem.get(1);
		current_frame = null;
		sem.put(1);
		end
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

function void axi_master_write_data_driver::reset();
		vif.wid 	= 	0;
		vif.wlast 	=  	0;
		vif.wvalid	= 	valid_default;
		`uvm_info(get_name(),$sformatf("reset recievied"), UVM_LOW)
endfunction

function void axi_master_write_data_driver::calculateStrobe(input axi_single_frame strobe_frame);
    $display("NOT IMPLEMENTDE STROBE SELECT");
	vif.wdata = current_frame.data;
	vif.wstrb = 1;

endfunction

task axi_master_write_data_driver::spinClock(input int clocks);
//	$display("clock clock  = %d ", clocks);
	this.scheduler.main(clocks);
	this.main_driver.mainMainDriver(clocks);
endtask

task axi_master_write_data_driver::main();
	this.init();
	$display("Running data driver main core....  ");
	forever
		begin
			case (state)
				GET_FRAME:
				begin
					this.getNextFrame();
//					sem.get(1);
					if(current_frame == null)
						begin
							state = WAIT_CLK;
//							$display("empty data");
							next_state = GET_FRAME;
						end
					else
						begin
							state = DRIVE_VIF;
							$display(" +++ +++ ++++ +++ new not empty frame ++ ++ ++ ++ ++ +++ +++ ");
						end
//					sem.put(1);
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


					if(vif.awready != 0)
						begin
							spinClock(clock_counter);
							clock_counter = 0;
							state = GET_FRAME;
						end
					else
						begin
							@(posedge vif.sig_clock);
//							$display("wait ready");
							clock_counter++;
//							state = WAIT_READY;
							state = GET_FRAME;
						end
				end

				WAIT_CLK:
				begin
					@(posedge vif.sig_clock);
					state = next_state;
					spinClock(1);
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
		$display("FATAL DATA DRIVER");
endtask

`endif