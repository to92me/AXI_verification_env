`ifndef AXI_WRITE_CONFIGUARION_SVH
`define AXI_WRITE_CONFIGUARION_SVH

class axi_write_master_configuration extends uvm_object;


// +++++++++++++++++++++++++++++++++++++++++GLOOBAL SETTINGS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//with setting do coverage axi_write uvc will collect coverage and report it
true_false_enum			do_coverage								= TRUE;

//with seeting do checks axi_write uvc will do checks
true_false_enum			do_checks 								= TRUE;

// if correct_driving_vif is setted as true then axi master write uvc will correcly ( acording to axi 3 / 4 protocol ) drive DUV
true_false_enum			correct_driving_vif 					= TRUE;

//this is number of active bursts at same time if this is setted to 0 then axi uvc will work like AXI4 othervise like AXI3
int 					master_write_deepth 					= 5;

//+++++++++++ MASTER DRIVER+++++++++++++++++++++++

//++ DATA DRIVER

//if full_speed == TRUE then there will be no any delay in any stage of driving data of  DUT othervise configuration after will
// be used for delays
true_false_enum			data_master_full_speed 					= FALSE;

// if valid_delay == TRUE when setting new dat on data bus driver will wait some time before setting wvalid
true_false_enum			data_valid_delay 						= FALSE;

// configuration for random delay before setting valid
int 					data_delay_minimum						= 0;
int 					data_delay_maximum						= 5;


//++ ADDRESS DRIVER

//if full_speed == TRUE then there will be no any delay in any stage of driving address of  DUT othervise configuration after will
// be used for delays
true_false_enum			addr_master_full_speed 					= FALSE;

// if valid_delay == TRUE when setting new dat on addr bus driver will wait some time before setting awvalid
true_false_enum			addr_valid_delay 						= FALSE;

// configuration for random delay before setting valid
int 					addr_data_delay_minimum					= 0;
int 					addr_delay_maximum						= 5;

//++ MAIN DRIVER

//if data_before_addr == TRUE when driving new burst to slave master can send few data items before address item
true_false_enum			data_before_addr 						= FALSE;


//++ RESPONSE DRIVER
//if full speed is setted master will keep bready on 1 all time if it is posible
true_false_enum			bready_delay_full_speed					= FALSE;

//if bready delay_constant  == TRUE when master driver detectes 1 on bvalid from slave it will wait const time to set
// bready
true_false_enum			bready_delay_constant					= FALSE;
int						bready_delay_const_value				= 5;

//if bready_delay_constant == FALSE ready delay will get random value with limits:
int 					bready_delay_minimum 					= 0;
int 					bready_delay_masimum					= 5;

//if bready_constant == TRUE after completeing one transfer bready will always get setted value in bready_const_value
true_false_enum			bready_constant							= FALSE;
int 					bready_const_value						= 0;

//if bready_constant == FALSE then after completeing one transfer bready will get radnomly 0 or 1 in setted posibiliy
int 					bready_posibility_of_0					= 5;
int 					bready_posibility_of_1					= 5;


//+++++++ SLAVE DRIVER ++++++++++++

// DATA DRIVER
// if data_slave_full_speed == TRUE, wready will be keept on 1 mouch is it posible
true_false_enum			data_slave_full_speed					= FALSE;

//if wready delay_constant  == TRUE when master driver detectes 1 on wvalid from slave it will wait const time to set
// bready
true_false_enum			wready_delay_constant					= FALSE;
int						wready_delay_const_value				= 5;

//if wready_delay_constant == FALSE ready delay will get random value with limits:
int 					wready_delay_minimum 					= 0;
int 					wready_delay_masimum					= 5;

//if wready_constant == TRUE after completeing one transfer wready will always get setted value in wready_const_value
true_false_enum			wready_constant							= FALSE;
int 					wready_const_value						= 0;

//if wready_constant == FALSE then after completeing one transfer wready will get radnomly 0 or 1 in setted posibiliy
int 					wready_posibility_of_0					= 5;
int 					wready_posibility_of_1					= 5;



// ADDRESS DRIVER
// if addr_slave_full_speed == TRUE, wready will be keept on 1 mouch is it posible
true_false_enum			addr_slave_full_speed					= FALSE;

//if aready delay_constant  == TRUE when master driver detectes 1 on awvalid from slave it will wait const time to set
// bready
true_false_enum			awready_delay_constant					= FALSE;
int						awready_delay_const_value				= 5;

//if awready_delay_constant == FALSE ready delay will get random value with limits:
int 					awready_delay_minimum 					= 0;
int 					awready_delay_masimum					= 5;

//if awready_constant == TRUE after completeing one transfer wready will always get setted value in awready_const_value
true_false_enum			awready_constant						= FALSE;
int 					awready_const_value						= 0;

//if wready_constant == FALSE then after completeing one transfer wready will get radnomly 0 or 1 in setted posibiliy
int 					awready_posibility_of_0					= 5;
int 					awready_posibility_of_1					= 5;


//++ RESPONS DRIVER

//if full_speed == TRUE then there will be no any delay in any stage of driving address of  DUT othervise configuration after will
// be used for delays
true_false_enum			rsp_slave_full_speed 					= FALSE;

// if valid_delay == TRUE when setting new dat on addr bus driver will wait some time before setting bvalid
true_false_enum			bvalid_valid_delay 						= FALSE;

// configuration for random delay before setting bvalid
int 					bvalid_data_delay_minimum				= 0;
int 					bvalid_delay_maximum					= 5;


endclass


`endif