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
//		sem = new(1);
		current_frame = new();
	endfunction : new

	extern static function axi_master_write_data_driver getDriverInstance(input uvm_component parent);

	extern task getNextFrame();
	extern task driverVif();
	extern task completeTransaction();
	extern task calculateStrobe(input axi_single_frame strobe_frame);
	extern task init();
	extern task reset();
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

task axi_master_write_data_driver::getNextFrame();

	main_driver.getDataFrame(mssg);

	if(mssg.state == READY)
		begin
		current_frame = mssg.frame;
		end
	else
		begin
		current_frame = null;
		end
endtask


task axi_master_write_data_driver::driverVif();
//		#5
//		$display("MASTER: DATA driving vif");
		$display("current frame: %d %d %d",current_frame.id, current_frame.last_one, current_frame.data);
		calculateStrobe(current_frame);
		vif.wid 	<= 	current_frame.id;
		if(current_frame.last_one == TRUE)
			begin
				vif.wlast  	<= 'b1;
//				vif.wvalid  <= 'b1;
			end
		else
			vif.wlast 	<= 'b0;

endtask
task axi_master_write_data_driver::completeTransaction();
//	#5
    vif.wvalid 		<=	1'b1;
endtask

task axi_master_write_data_driver::init();
//		#10
		vif.wid 	<= 	0;
		vif.wlast 	<= 	0;
		vif.wvalid	<= 	1'b0;
endtask

task axi_master_write_data_driver::reset();
		vif.wid 	<= 	0;
		vif.wlast 	<= 	0;
		vif.wvalid	<= 	1'b0;
		`uvm_info(get_name(),$sformatf("reset recievied"), UVM_LOW)
endtask

task axi_master_write_data_driver::calculateStrobe(input axi_single_frame strobe_frame);
    $display("NOT IMPLEMENTDE STROBE SELECT");
	vif.wdata <= current_frame.data;
	vif.wstrb <= 1;

endtask

task axi_master_write_data_driver::spinClock(input int clocks);
//	$display("clock clock  = %d ", clocks);
	this.scheduler.main(clocks);
	this.main_driver.mainMainDriver(clocks); // FIXME
endtask

task axi_master_write_data_driver::main();
	true_false_enum got_ready = FALSE;
//	#50
	this.init();

	$display("Running data driver main core....  ");
	forever
		begin
			case (state)
				GET_FRAME:
				begin
//				$display("MASTER DATA DRIVER                          GET FRAME: 1");
					this.getNextFrame();
					if(current_frame == null)
						begin
							state = WAIT_CLK;
							this.init();
							next_state = GET_FRAME;
						end
					else
						begin
							state = DRIVE_VIF;
						end
				end

				DRIVE_VIF:
				begin
//				$display("MASTER DATA DRIVER                          DRIVE VIF: 2");
					this.driverVif();
					state = COMPLETE_TRANSACTION;
				end

				WAIT_READY:
				begin
					if(vif.wready == 1'b1)
						begin
							spinClock(clock_counter);
							clock_counter = 0;
							state = GET_FRAME;
//							$display("MASTER DATA DRIVER                          WAIT READY: 4 : GOT READY");
							got_ready = FALSE;
						end
					else
						begin
							@(posedge vif.sig_clock);
							if(got_ready == FALSE)
								begin
//									$display("MASTER DATA DRIVER                          WAIT READY: 4 : WAIT READY");
									got_ready = TRUE;
								end
							clock_counter++;
							state = WAIT_READY;
						end
				end

				WAIT_CLK:
				begin
//					$display("MASTER DATA DRIVER                          WAIT CLK:  N ");
					@(posedge vif.sig_clock);
					state = next_state;
					spinClock(1);
				end

				COMPLETE_TRANSACTION:
				begin
					state = WAIT_READY;
//					$display("MASTER DATA DRIVER                          COMPLETE_TRANSACTION: 3");
//					$display("delay %d",current_frame.delay_wvalid);
					if(current_frame.delay_wvalid == 0)
						begin
							@(posedge vif.sig_clock);
							spinClock(1);
						end
					else
						begin
							repeat(current_frame.delay_wvalid)
								begin
//									#5
									vif.wvalid <= 1'b0;
									@(posedge vif.sig_clock);
								end
							spinClock(current_frame.delay_wvalid);
						end
					this.completeTransaction();
					state = WAIT_READY;
				end
			endcase
		end
		$display("FATAL DATA DRIVER");
endtask

`endif