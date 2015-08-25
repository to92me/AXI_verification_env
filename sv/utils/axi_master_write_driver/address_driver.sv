`ifndef AXI_MASTER_WRITE_ADDRESS_DRIVER_SVH
`define AXI_MASTER_WRITE_ADDRESS_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------





class axi_master_write_address_driver extends axi_master_write_base_driver;

	write_states_enum		 					state = GET_FRAME;
	static  axi_master_write_address_driver		driverInstance;
	// Provide implementations of virtual methods such as get_type_name and create

	// new - constructor
	local function new (string name, uvm_component parent);
		super.new(name, parent);
		mssg = new();
		sem = new(1);
		current_frame = new();
	endfunction : new

	function void build_phase(uvm_phase phase);
		`uvm_info("axi master write address driver","Building", UVM_MEDIUM);
		main_driver = axi_master_write_main_driver::getDriverInstance(this);
		scheduler = axi_master_write_scheduler::getSchedulerInstance(this);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
	endfunction

	extern static function axi_master_write_address_driver getDriverInstance(input uvm_component parent);

	extern task getNextFrame();
	extern task driverVif();
	extern task completeTransaction();
	extern task init();
	extern task reset();
	extern task main();

	extern task testClock();


endclass : axi_master_write_address_driver

function axi_master_write_address_driver axi_master_write_address_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
	begin
		$display("Creating Axi Master Write Address Driver");
		driverInstance = new("AxiMasterWriteAddressDriver", parent);
	end
	return driverInstance;
endfunction

task axi_master_write_address_driver::getNextFrame();

	main_driver.getAddrFrame(mssg);

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
endtask


task axi_master_write_address_driver::driverVif();
//		#5
//		$display("MASTER: sending address item");
		vif.awid	<= current_frame.id;
		vif.awaddr	<= current_frame.addr;
		vif.awlen 	<= current_frame.len;
		vif.awsize 	<= current_frame.size;
		vif.awburst <= current_frame.burst_type;
		vif.awlock 	<= current_frame.lock;
		vif.awcache <= current_frame.cache;
		vif.awprot 	<= current_frame.prot;
		vif.awqos 	<= current_frame.qos;
		vif.awregion<= current_frame.region;
		vif.awvalid <= 1'b1;
endtask

task axi_master_write_address_driver::completeTransaction();
	    vif.awvalid <= 1'b1;
endtask

task axi_master_write_address_driver::init();
//		#5
		vif.awid	<= 0;
		vif.awaddr	<= 0;
		vif.awlen 	<= 0;
		vif.awsize 	<= 0;
		vif.awburst <= 0;
		vif.awlock 	<= 0;
		vif.awcache <= 0;
		vif.awprot 	<= 0;
		vif.awqos 	<= 0;
		vif.awregion<= 0;
		vif.awvalid <= 1'b0;
endtask

task axi_master_write_address_driver::reset();
//		#5
		vif.awid	<= 0;
		vif.awaddr	<= 0;
		vif.awlen 	<= 0;
		vif.awsize  <= 0;
		vif.awburst <= 0;
		vif.awlock 	<= 0;
		vif.awcache <= 0;
		vif.awprot 	<= 0;
		vif.awqos 	<= 0;
		vif.awregion<= 0;
		vif.awvalid <= 1'b0;
		`uvm_info(get_name(),$sformatf("reset recievied"), UVM_LOW)
endtask

task axi_master_write_address_driver::main();
	this.init();
	$display("Running address driver main core... .");
	forever
		begin
			case (state)
				GET_FRAME:
				begin
					this.getNextFrame();

					if(current_frame == null)
						begin
							state = WAIT_CLK;
							this.init();
						end
					else
						begin
//						$display("MASTER new ADDR package");
						state = DRIVE_VIF;
						end
//					sem.put(1);
				end

				DRIVE_VIF:
				begin
//					$display("DRIVING ADDR VIF");
					this.driverVif();
					state = COMPLETE_TRANSACTION;
				end

				WAIT_READY:
				begin

					if(vif.awready == 'b1)
						begin
							state = GET_FRAME;
//							$display("MASTER: address reacieved ready from slave ");
						end
					else
						begin
						@(posedge vif.sig_clock iff vif.awready == 1);
						state = GET_FRAME;
						end
				end

				WAIT_CLK:
				begin
					@(posedge vif.sig_clock);
					state = GET_FRAME;
				end

				COMPLETE_TRANSACTION:
				begin
					if(current_frame.delay_wvalid == 0)
						begin
							@(posedge vif.sig_clock);
						end
					else
						begin
							repeat(current_frame.delay_wvalid)
								begin
									vif.awvalid <= 1'b0;
									@(posedge vif.sig_clock);
								end
						end
					this.completeTransaction();
					state = WAIT_READY;
				end
			endcase
		end
		$display("FATAL ADDRESS DRIVER");
endtask

task axi_master_write_address_driver::testClock();
	fork
		forever begin
			@(posedge vif.sig_clock);
    		scheduler.main(1);
		end
		forever begin
			@(posedge vif.sig_clock);
			main_driver.mainMainDriver(1);
		end
	join
endtask


`endif
