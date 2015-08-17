
/*
import uvm_pkg::*;
	`include "uvm_macros.svh"


typedef class axi_master_write_data_driver;
typedef class axi_master_write_address_driver;
typedef class axi_master_write_main_driver;
typedef class axi_master_write_base_driver;
typedef class axi_master_config;
typedef class axi_slave_config;
typedef class axi_config;
typedef class axi_frame;
typedef class slave_config_factory;

`include "sv/axi_types.sv"
`include "sv/axi_frame.sv"


`include "sv/utils/axi_mssg.sv"
`include "sv/utils/axi_master_write_scheduler_packages.sv"
`include "sv/utils/axi_master_write_scheduler.sv"

`include "sv/utils/axi_master_write_base_driver.sv"
`include "sv/utils/axi_master_write_main_driver.sv"
`include "sv/utils/axi_master_write_data_driver.sv"
`include "sv/utils/axi_master_write_address_driver.sv"
`include "sv/utils/axi_master_write_response_driver.sv"

`include "sv/master/axi_master_write_driver.sv"
`include "sv/axi_config.sv"
`include "sv/master/axi_master_config.sv"
`include "sv/slave/axi_slave_config.sv"
*/
`include "sv/axi_if.sv"
`include "sv/axi_pkg.sv"

	import uvm_pkg::*;
	`include "uvm_macros.svh"





//import axi_pkg::*

// `include "sv/axi_if.sv"

module top;

	import axi_pkg::*;

	axi_frame frame;
	//axi_master_write_scheduler scheduler;
	//axi_master_write_main_driver driver;
	//axi_master_write_response_driver response;

	axi_master_write_driver driver;
	int queue[$] = {0,1,2,3,4,5};
	int i;

	reg clock;
	reg reset;

	axi_if if0(.sig_clock(clock),.sig_reset(reset));



initial begin

	uvm_config_db#(virtual axi_if)::set(null,"uvm_test_top.*","vif",if0);

	driver = axi_master_write_driver::type_id::create("write_driver",null);
	driver.startDriver();
	driver.startScheduler();


	/*
	scheduler = axi_master_write_scheduler::getSchedulerInstance(null);
	driver = axi_master_write_main_driver::getDriverInstance(null);
	response = axi_master_write_response_driver::getDriverInstance(null);
	driver.build();
	response.build();

	*/
/*
 *
 *
	 i = 1;
	while(i != 3)
	begin
	case (i)
		1: begin
			$display("tome and there goes continue");
			if(i == 1)
			begin
				i = 2;
				continue;
				$display("after break; ",);
			end
			else
			begin
				break;
				$display("there is an error",);
			end
			end
		2: begin
			$display("i set to 3 and ");
			i = 3;
			end
		// default : ;
	endcase
	end

	// fork
		//response.main();
		//driver.main();


	$display("i : %d", i );

	// fork
		// scheduler.main();
		// begin
			// foreach(queue[i])
			// begin
				// $display("item %d: %d",i, queue[i]);
			// end
			frame = new();
			assert(frame.randomize());
			scheduler.addBurst(frame);
			// $display("adding second one");
			assert(frame.randomize());
			// $display("adding second one");
			scheduler.addBurst(frame);
			assert(frame.randomize());
			scheduler.addBurst(frame);
			assert(frame.randomize());
			scheduler.addBurst(frame);
			assert(frame.randomize());
			scheduler.addBurst(frame);
			assert(frame.randomize());
			scheduler.addBurst(frame);
			repeat(1400)
			 begin
			scheduler.delayCalculator();
			scheduler.serchForReadyFrame();
			 end
			scheduler.print();
		// end
	// join_any
	*/


end
endmodule