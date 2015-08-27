`ifndef AXI_MASTER_WRITE_ADDRESS_DRIVER_SVH
`define AXI_MASTER_WRITE_ADDRESS_DRIVER_SVH
`define tome
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------




`ifdef tome
class axi_master_write_address_driver extends axi_master_write_base_driver;
	static  axi_master_write_address_driver		driverInstance;
	int 										send_items;
	event 										frame_collected;

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
	extern task dataDriver();
	extern task validTriger();


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
		#2
		$display(" MASTER SEND current frame: %h %d %h, count: %d",current_frame.id,current_frame.len, current_frame.data, send_items );
		send_items++;
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
		#2
	    vif.awvalid <= 1'b1;
endtask

task axi_master_write_address_driver::init();
		#2
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
		#2
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
   fork
   		this.validTriger();
		this.dataDriver();
   join
endtask

task axi_master_write_address_driver::validTriger();
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
						if(vif.awvalid == 1)
							begin
								#2
								vif.awvalid <= 0;
							end
						@(posedge vif.sig_clock);
					end
					state = SET_WVALID;
				end

				SET_WVALID:
				begin
					if(vif.awvalid == 1'b0)
						begin
							#2
							vif.awvalid <= 1'b1;
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

task axi_master_write_address_driver::dataDriver();
	axi_master_write_base_driver_data_core state = WAIT_TO_COLLECT;
    forever begin
	    case(state)
		    WAIT_TO_COLLECT:
		    begin
			    @(posedge vif.sig_clock)
			    if(vif.awvalid == 1 && vif.awready == 1)
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

`endif

`endif
