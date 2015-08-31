`ifndef AXI_MASTER_WRITE_DATA_DRIVER_SVH
`define AXI_MASTER_WRITE_DATA_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------



class axi_master_write_data_driver extends axi_master_write_base_driver;


	static 	axi_master_write_data_driver	driverInstance;
	int 									clock_counter;
	event 									frame_collected;
	int 									send_items = 0;

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
	extern task validTriger();
	extern task dataDriver();
	extern task testClock();


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
		#2
//		$display(" MASTER SEND current frame: %h %d %h, strobe: %b, count: %d",current_frame.id, current_frame.last_one, current_frame.data, current_frame.strobe,  send_items );
		send_items++;
		calculateStrobe(current_frame);
		vif.wid 	<= 	current_frame.id;
		if(current_frame.last_one == TRUE)
			begin
				vif.wlast  	<= 'b1;
			end
		else
			vif.wlast 	<= 'b0;

endtask
task axi_master_write_data_driver::completeTransaction();
	#2
    vif.wvalid 		<=	1'b1;
endtask

task axi_master_write_data_driver::init();
		#2
		vif.wid 	<= 	0;
		vif.wlast 	<= 	0;
		vif.wdata 	<= 	0;
		vif.wvalid	<= 	1'b0;
endtask

task axi_master_write_data_driver::reset();
		vif.wid 	<= 	0;
		vif.wlast 	<= 	0;
		vif.wdata 	<= 	0;
		vif.wvalid	<= 	1'b0;
		`uvm_info(get_name(),$sformatf("reset recievied"), UVM_LOW)
endtask

task axi_master_write_data_driver::calculateStrobe(input axi_single_frame strobe_frame);
	vif.wdata <= current_frame.data;
	vif.wstrb <= 1;

endtask

task axi_master_write_data_driver::spinClock(input int clocks);
	this.scheduler.main(clocks);
	this.main_driver.mainMainDriver(clocks);
endtask

task axi_master_write_data_driver::main();
    fork
	    this.validTriger();
	    this.dataDriver();
	    this.testClock();
    join
endtask

task axi_master_write_data_driver::validTriger();
	axi_master_write_base_driver_valid_core state = GET_FRAME;

	this.init();

	$display("Running data driver main core....  ");
	forever
		begin
			case (state)
				GET_FRAME:
				begin
					this.getNextFrame();
					if(current_frame == null)
						begin
							this.init();
							@(posedge vif.sig_clock);
							state = GET_FRAME;
						end
					else
						begin
							state = DRIVE_VIF;
						end
				end

				DRIVE_VIF:
				begin
					this.driverVif();
					state = DELAY_WVALID;
				end

				DELAY_WVALID:
				begin
					repeat (current_frame.delay_wvalid) begin
						if(vif.wvalid == 1)
							begin
								#2
								vif.wvalid <= 0;
							end
						@(posedge vif.sig_clock);
					end
					state = SET_WVALID;
				end

				SET_WVALID:
				begin
					if(vif.wvalid == 1'b0)
						begin
							#2
							vif.wvalid <= 1'b1;
						end
					state = WAIT_TO_COLLET;
				end

				WAIT_TO_COLLET:
				begin
					wait(frame_collected.triggered);
					state = GET_FRAME;
				end
			endcase
		end
		$display("FATAL DATA DRIVER");
endtask

task axi_master_write_data_driver::dataDriver();
	axi_master_write_base_driver_data_core state = WAIT_TO_COLLECT;
    forever begin
	    case(state)
		    WAIT_TO_COLLECT:
		    begin
			    @(posedge vif.sig_clock)
			    if(vif.wvalid == 1 && vif.wready == 1)
				    begin
					    state = INFORM_VALID_CORE;
				    end
			    else
				   begin
					   state = WAIT_TO_COLLECT;
				   end
		    end

		    INFORM_VALID_CORE:
		    begin
			    ->frame_collected;
			    state = WAIT_TO_COLLECT;
		    end

	    endcase
    end
endtask


task axi_master_write_data_driver::testClock();
forever begin
	@(posedge vif.sig_clock);
	this.spinClock(1);
end
endtask

`endif