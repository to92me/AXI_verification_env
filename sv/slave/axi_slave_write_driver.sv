/******************************************************************************
	* DVT CODE TEMPLATE: driver
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_driver
//
//------------------------------------------------------------------------------

class axi_slave_write_driver extends uvm_driver #(axi_frame);

	protected virtual axi_if vif;

	axi_slave_config config_obj;

	`uvm_component_utils(axi_slave_write_driver)
	axi_slave_write_main_driver driver;


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		driver = axi_slave_write_main_driver::type_id::create("AxiSlaveWriteMainDriver",this);
		driver.setSlaveCondig(config_obj);

	endfunction: build_phase

	extern task resetAll();
	extern task setSlaveConfig(input axi_slave_config cfg);

	// run_phase
	virtual task run_phase(uvm_phase phase);
		/*
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
	*/
		get_and_drive();
	endtask : run_phase

	// get_and_drive
	virtual protected task get_and_drive();
//
		fork
			driver.startDriver();
			this.resetAll();
		join
/*
		forever begin
			// Don't continue with the driving if reset is not high
			do
				@(posedge vif.sig_clock);
			while(vif.sig_reset!==1);

			seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);
//			seq_item_port.put_response(rsp);
			end
*/


	endtask : get_and_drive

endclass : axi_slave_write_driver


task axi_slave_write_driver::resetAll();
	forever begin
     @(negedge vif.sig_reset);
		do
			begin
			driver.reset();
			@(posedge vif.sig_clock);
			end
		while(vif.sig_reset!==1);
	end
endtask


task axi_slave_write_driver::setSlaveConfig(input axi_slave_config cfg);
    this.config_obj = cfg;
endtask



