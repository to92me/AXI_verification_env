`ifndef AXI_WRITE_USER_CONFIGUARION_SVH
`define AXI_WRITE_USER_CONFIGUARION_SVH

class axi_write_master_user_configuration extends axi_write_user_config_base;

`uvm_component_utils(axi_write_master_user_configuration)

function new (string name, uvm_component parent);
		super.new(name, parent);
endfunction : new

function void setConfigurations();

$display("USER CONFIGURATION");

// +++++++++++++++++++++++++++++++++++++++++GLOOBAL SETTINGS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//with setting do coverage axi_write uvc will collect coverage and report it
//true_false_enum			do_coverage								= TRUE;
registerConfiguration("general","do_coverage", TRUE);

//with seeting do checks axi_write uvc will do checks
//true_false_enum			do_checks 								= TRUE;
registerConfiguration("general","do_checks", TRUE);


// if correct_driving_vif is setted as true then axi master write uvc will correcly ( acording to axi 3 / 4 protocol ) drive DUV
// and section incorrect data will be ignored
//true_false_enum			correct_driving_vif 					= TRUE;
registerConfiguration("general", "correct_driving_vif", TRUE);

//if this is setted as TRUE then axi uvc will support data interleaving ( AXI 3 feature )
//true_false_enum			axi_3_support		 					= TRUE;
registerConfiguration("general", "axi_3_support", TRUE);


//this is number of active bursts at same time if this is setted to 0 then axi uvc will work like AXI4 othervise like AXI3, if AXI3
//support is disabled this option will be ignored
//int 					master_write_deepth 					= 5;
registerConfiguration("general", "master_write_deepth", 5);


//if this option is TRUE then all delay options and seetings for ready will be ignored
//true_false_enum			global_full_speed						= FALSE;

registerConfiguration("general", "full_speed", TRUE);

//+++++++++++++++++++++++++++++++++++++++END GLOBAL SETTINGS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





// ++++++++++++++++++++++++++++++++++++++INCORECT DATA++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 1. AWID
//				 -correct 						option = 1
//				 -incorrect (default = 0)  		option = 2
//				 -random correct vs. incorrect	option = 3
//int 			awid_mode 						= 1;
//int 			awid_possibility_correct		= 5;
//int 			awid_possibility_incorrect 		= 5;
registerConfiguration("data_correctnes", "awid_mode", 1);
registerConfiguration("data_correctnes","awid_dist_incorrect", 5);


// 2. AWREGION
//				 -correct 						option = 1
//				 -incorrect (default = 0)  		option = 2
//				 -random correct vs. incorrect	option = 3
//int 			awregion_mode 					=1;
//int 			awregion_possibility_correct	= 5;
//int 			awregion_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awregion_mode", 1);


// 3. AWLEN
//				-correct						option = 1
// 				-incorrect (default = 0)		option = 2
//				-random correct vs. inccorect	option = 3
//int 			awlen_mode						= 1;
//int 			awlen_possibility_correct		= 5;
//int 			awlen_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awlen_mode", 1);

//4. AWSIEZE
//				-correct 						option = 1
//				-incorrect (default = 0)  		option = 2
//				-random correct vs. incorrect	option = 3
//int 			awsize_mode 					= 1;
//int 			awsize_possibility_correct		= 5;
//int 			awsize_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awsize_mode", 1);

// 5. AWBURST
//				-correct 						option = 1
//				-incorrect (default = INCR) 	option = 2
//				-random correct vs. incorrect	option = 3
//int 			awburst_mode					= 1;
//int 			awburst_possibility_correct		= 5;
//int 			awburst_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awburst_mode", 1);


// 6. AWLOCK
//				-correct 						option = 1
//				-incorrect (default =0)			option = 2
//				-random correct vs. incorrect	option = 3
//int 			awlock_mode 					= 1;
//int 			awlock_possibility_correct		= 5;
//int 			awlock_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awlock_mode", 1);



// 7. AWCACHE
//				-correct 								option = 1
//				-incorrect (default = normal access)	option = 2
//				-random correct vs. incorrect			option = 3
//int 			awcache_mode					= 1;
//int 			awcache_possibility_correct		= 5;
//int 			awcache_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awcache_mode", 1);



//8. AWQOS
//				-correct 						option = 1
//				-incorrect (default = 0)		option = 2
//				-random correct vs. incorrect	option = 3
//int 			awqos_mode 						= 1;
//int 			awqos_possibility_correct		= 5;
//int 			awqos_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "awqos_mode", 1);


// 7. WSTRB
//				-correct 						option = 1
//				-incorrect (default = all_ones)	option = 2
//				-random correct vs. incorrect	option = 3
//int 			wstrb_mode 						= 1;
//int 			wstrb_possibility_correct		= 5;
//int 			wstrb_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "wstrb_mode", 1);


// 8. BRESP
//				-correct 						option = 1
//				-incorrect (default = all_ones)	option = 2
//				-random correct vs. incorrect	option = 3
//int 			bresp_mode 						= 1;
//int 			bresp_possibility_correct		= 5;
//int 			bresp_possibility_incorrect 	= 5;
registerConfiguration("data_correctnes", "bresp_mode", 1);

// ++++++++++++++++++++++++++++++++++++++END INCORECT DATA+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






//+++++++++++++++++++++++++++++++++++++++ MASTER DRIVER++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//++ DATA DRIVER

//if full_speed == TRUE then there will be no any delay in any stage of driving data of  DUT othervise configuration after will
// be used for delays
//true_false_enum			data_master_full_speed 					= FALSE;
//registerConfiguration("master_data_driver", "full_speed", FALSE);


//// if valid_delay == TRUE when setting new dat on data bus driver will wait some time before setting wvalid
//true_false_enum			data_valid_delay 						= TRUE;

//
//// if data_valid_constant_delay == TRUE then delay before setting wvalid to active will be constant value
//true_false_enum			data_valid_constant_delay				= FALSE;
//
////if data_valid_constant_delay == TRUE delay will have data_constant_delay_value value=
//int 					data_valid_contant_delay_value 			= 2;
//
//// configuration for random delay before setting valid
//int 					data_delay_minimum						= 0;
//int 					data_delay_maximum						= 5;
registerConfiguration("master_data_driver", "valid_delay_exists", TRUE);
registerConfiguration("master_data_driver", "valid_delay_minimum", 0);
registerConfiguration("master_data_driver", "valid_delay_maximum", 5);

//
////++ ADDRESS DRIVER
//
////if full_speed == TRUE then there will be no any delay in any stage of driving address of  DUT othervise configuration after will
//// be used for delays
//true_false_enum			addr_master_full_speed 					= FALSE;
//
//// if valid_delay == TRUE when setting new dat on addr bus driver will wait some time before setting awvalid
//true_false_enum			addr_valid_delay 						= TRUE;
//
//// if addr_valid_constant_delay == TRUE then delay before setting awvalid to active will be constant value
//true_false_enum 		addr_valid_constant_delay				= FALSE;
//
////if addr_valid_constant_delay == TRUE delay will have addr_constant_delay_value value
//int 					addr_constant_delay_value 				= 2;
//
//
//// configuration for random delay before setting valid
//int 					addr_data_delay_minimum					= 0;
//int 					addr_delay_maximum						= 5;

registerConfiguration("master_addr_driver", "valid_delay_exists", TRUE);
registerConfiguration("master_addr_driver", "valid_delay_minimum", 0);
registerConfiguration("master_addr_driver", "valid_delay_maximum", 5);

//
////++ MAIN DRIVER
//
////if data_before_addr == TRUE when driving new burst to slave master can send few data items before address item
//true_false_enum			data_before_addr 						= FALSE;
//
//
////++ RESPONSE DRIVER
////if full speed is setted master will keep bready on 1 all time if it is posible
//true_false_enum			bready_delay_full_speed					= FALSE;
//
////if bready delay_constant  == TRUE when master driver detectes 1 on bvalid from slave it will wait const time to set
//// bready
//true_false_enum			bready_delay_constant					= FALSE;
//int						bready_delay_const_value				= 5;
//
////if bready_delay_constant == FALSE ready delay will get random value with limits:
//int 					bready_delay_minimum 					= 0;
//int 					bready_delay_maximum					= 5;
//
////if bready_constant == TRUE after completeing one transfer bready will always get setted value in bready_const_value
//true_false_enum			bready_constant							= FALSE;
//int 					bready_const_value						= 0;
//
////if bready_constant == FALSE then after completeing one transfer bready will get radnomly 0 or 1 in setted posibiliy
//int 					bready_posibility_of_0					= 5;
//int 					bready_posibility_of_1					= 5;

registerConfiguration("master_resp_driver", "ready_delay_exists", TRUE);
registerConfiguration("master_resp_driver", "ready_delay_constant", FALSE);
registerConfiguration("master_resp_driver", "ready_delay_minimum", 0);
registerConfiguration("master_resp_driver", "ready_delay_maximum", 5);
registerConfiguration("master_resp_driver", "ready_constant", FALSE);
registerConfiguration("master_resp_driver", "ready_posibility_of_0", 5);
registerConfiguration("master_resp_driver", "ready_posibility_of_1", 5);
//+++++++++++++++++++++++++++++++++++++++END MASTER DRIVER+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






//+++++++++++++++++++++++++++++++++++++++++ SLAVE DRIVER ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//// DATA DRIVER
//// if data_slave_full_speed == TRUE, wready will be keept on 1 mouch is it posible
//true_false_enum			data_slave_full_speed					= FALSE;
//
////if wready delay_constant  == TRUE when master driver detectes 1 on wvalid from slave it will wait const time to set
//// bready
//true_false_enum			wready_delay_constant					= FALSE;
//int						wready_delay_const_value				= 5;
//
////if wready_delay_constant == FALSE ready delay will get random value with limits:
//int 					wready_delay_minimum 					= 0;
//int 					wready_delay_maximum					= 5;
//
////if wready_constant == TRUE after completeing one transfer wready will always get setted value in wready_const_value
//true_false_enum			wready_constant							= FALSE;
//int 					wready_const_value						= 0;
//
////if wready_constant == FALSE then after completeing one transfer wready will get radnomly 0 or 1 in setted posibiliy
//int 					wready_posibility_of_0					= 5;
//int 					wready_posibility_of_1					= 5;
//
registerConfiguration("slave_addr_driver", "ready_delay_exists", TRUE);
registerConfiguration("slave_addr_driver", "ready_delay_constant", FALSE);
registerConfiguration("slave_addr_driver", "ready_delay_minimum", 0);
registerConfiguration("slave_addr_driver", "ready_delay_maximum", 5);
registerConfiguration("slave_addr_driver", "ready_constant", FALSE);
registerConfiguration("slave_addr_driver", "ready_posibility_of_0", 5);
registerConfiguration("slave_addr_driver", "ready_posibility_of_1", 5);

//
//
//// ADDRESS DRIVER
//// if addr_slave_full_speed == TRUE, wready will be keept on 1 mouch is it posible
//true_false_enum			addr_slave_full_speed					= FALSE;
//
////if aready delay_constant  == TRUE when master driver detectes 1 on awvalid from slave it will wait const time to set
//// bready
//true_false_enum			awready_delay_constant					= FALSE;
//int						awready_delay_const_value				= 5;
//
////if awready_delay_constant == FALSE ready delay will get random value with limits:
//int 					awready_delay_minimum 					= 0;
//int 					awready_delay_maximum					= 5;
//
////if awready_constant == TRUE after completeing one transfer wready will always get setted value in awready_const_value
//true_false_enum			awready_constant						= FALSE;
//int 					awready_const_value						= 0;
//
////if wready_constant == FALSE then after completeing one transfer wready will get radnomly 0 or 1 in setted posibiliy
//int 					awready_posibility_of_0					= 5;
//int 					awready_posibility_of_1					= 5;
//
registerConfiguration("slave_data_driver", "ready_delay_exists", TRUE);
registerConfiguration("slave_data_driver", "ready_delay_constant", FALSE);
registerConfiguration("slave_data_driver", "ready_delay_minimum", 0);
registerConfiguration("slave_data_driver", "ready_delay_maximum", 5);
registerConfiguration("slave_data_driver", "ready_constant", FALSE);
registerConfiguration("slave_data_driver", "ready_posibility_of_0", 5);
registerConfiguration("slave_data_driver", "ready_posibility_of_1", 5);

//
////++ RESPONS DRIVER
//
////if full_speed == TRUE then there will be no any delay in any stage of driving address of  DUT othervise configuration after will
//// be used for delays
//true_false_enum			rsp_slave_full_speed 					= FALSE;
//
//// if valid_delay == TRUE when setting new dat on addr bus driver will wait some time before setting bvalid
//true_false_enum			bvalid_valid_delay 						= TRUE;
//
//// if bvalid_constant_delay == TRUE then delay before setting bvalid to active will be constant value
//true_false_enum			bvalid_constant_delay 					= FALSE;
//
////if bvalid_constant_delay == TRUE delay will have bvalid_constant_delay_value value=
//int 					bvalid_constant_delay_value				= 2;
//
//// configuration for random delay before setting bvalid
//int 					bvalid_data_delay_minimum				= 0;
//int 					bvalid_delay_maximum					= 5;

registerConfiguration("slave_resp_driver", "valid_delay_exists", TRUE);
registerConfiguration("slave_resp_driver", "valid_delay_minimum", 0);
registerConfiguration("slave_resp_driver", "valid_delay_maximum", 5);


//+++++++++++++++++++++++++++++++++++++++++END SLAVE DRIVER ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
endfunction

endclass




`endif