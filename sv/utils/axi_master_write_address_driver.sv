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

	extern static function axi_master_write_address_driver getDriverInstance(input uvm_component parent);

	extern function void getNextFrame();
	extern function void driverVif();
	extern function void completeTransaction();
	extern function void init();
	extern function void reset();
	extern task main();


endclass : axi_master_write_address_driver

function axi_master_write_address_driver axi_master_write_address_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
	begin
		$display("Creating Axi Master Write Address Driver");
		driverInstance = new("AxiMasterWriteAddressDriver", parent);
	end
	return driverInstance;
endfunction

function void axi_master_write_address_driver::getNextFrame();

	mssg = main_driver.getAddrFrame();

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


function void axi_master_write_address_driver::driverVif();
    	sem.get(1);
		vif.awid	= current_frame.id;
		vif.awaddr	= current_frame.addr;
		vif.awlen 	= current_frame.len;
		vif.awsize 	= current_frame.size;
		vif.awburst = current_frame.burst_type;
		vif.awlock 	= current_frame.lock;
		vif.awcache = current_frame.cache;
		vif.awprot 	= current_frame.prot;
		vif.awqos 	= current_frame.qos;
		vif.awregion= current_frame.region;
		vif.awvalid = 1'b1;
		sem.put(1);
endfunction

function void axi_master_write_address_driver::completeTransaction();
	    vif.awvalid = this.valid_default;
endfunction

function void axi_master_write_address_driver::init();
		vif.awid	= 0;
		vif.awaddr	= 0;
		vif.awlen 	= 0;
		vif.awsize 	= 0;
		vif.awburst = 0;
		vif.awlock 	= 0;
		vif.awcache = 0;
		vif.awprot 	= 0;
		vif.awqos 	= 0;
		vif.awregion= 0;
		vif.awvalid = valid_default;
endfunction

function void axi_master_write_address_driver::reset();
		vif.awid	= 0;
		vif.awaddr	= 0;
		vif.awlen 	= 0;
		vif.awsize 	= 0;
		vif.awburst = 0;
		vif.awlock 	= 0;
		vif.awcache = 0;
		vif.awprot 	= 0;
		vif.awqos 	= 0;
		vif.awregion= 0;
		vif.awvalid = valid_default;
		`uvm_info(get_name(),$sformatf("reset recievied"), UVM_LOW)
endfunction

task axi_master_write_address_driver::main();
	this.init();
	forever
		begin
			case (state)
				GET_FRAME:
				begin
					this.getNextFrame();
					sem.get(1);
					if(current_frame == null)
						state = WAIT_CLK;
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
					state = GET_FRAME;
				end

				COMPLETE_TRANSACTION:
				begin
					repeat(current_frame.delay_addr)
						@(posedge vif.sig_clock)
					this.completeTransaction();
					state = WAIT_READY;
				end
			endcase
			$display("FATAL ADDRESS DRIVER");
		end
endtask


`endif
