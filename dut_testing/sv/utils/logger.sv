`ifndef DUT_TESTING_LOGGER
`define DUT_TESTING_LOGGER

import uvm_pkg::*;
	`include "uvm_macros.svh"


typedef enum{
	READ 		= 0,
	WRITE 		= 1,
	MIRROR		= 2,
	SET			= 3,
	GET 		= 4,
	UPDATE  	= 5,
	CHECK		= 6,
	PREDICTION 	= 7
} reg_action_enum;

typedef enum{
	LOG = 0,
	TRANSACTION = 1
}mssg_type_enum;

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : logger.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : logger with coresponding logger classes
*
*/
// -----------------------------------------------------------------------------


//-------------------------------------------------------------------------------------
//
// CLASS: dut_testing_logger_mssg
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			dut_testing_logger_mssg is virtual class that every mssg in logger
//			must extend
//
//------------------------------------------------------------------------------

class dut_testing_logger_mssg;
	int 						ID;
	mssg_type_enum				mssg_type;


	// Get ID
	function int getOred_number();
		return ID;
	endfunction

	// Set ID
	function void setOred_number(int ID);
		this.ID = ID;
	endfunction

	// Get mssg_type
	function mssg_type_enum getMssg_type();
		return mssg_type;
	endfunction

	// Set mssg_type
	function void setMssg_type(mssg_type_enum mssg_type);
		this.mssg_type = mssg_type;
	endfunction



endclass

//-------------------------------------------------------------------------------------
//
// CLASS: dut_testing_logger_mssg_log
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			dut_testing_logger_mssg_log is logger string message that user can log from
//			logger API
//
// API:
//		1 setters
//
//			-for every field there is corresponding setter
//
//		2.getters
//
//			-for every field there is corresponding getter
//
//-------------------------------------------------------------------------------------

class dut_testing_logger_mssg_log extends dut_testing_logger_mssg;
	string log;

 	// Get log
 	function string getLog();
 		return log;
 	endfunction

 	// Set log
 	function void setLog(string log);
 		this.log = log;
 	endfunction



endclass


//-------------------------------------------------------------------------------------
//
// CLASS: dut_testing_logger_mssg_transaction_pack
//
//--------------------------------------------------------------------------------------
// DESCRIPTION: dut_testing_logger_mssg_transaction_pack is logger message that has
//				all informations about some transaction
//
//
// API:
//		1 setters
//
//			-for every field there is corresponding setter
//
//		2.getters
//
//			-for every field there is corresponding getter
//------------------------------------------------------------------------------

class dut_testing_logger_mssg_transaction_pack extends dut_testing_logger_mssg;
	uvm_status_e				status;
	string 						name;
	bit[DATA_WIDTH - 1 : 0]		data;
	reg_action_enum				action;
	int 						begin_time;
	int 						end_time;
	reg_action_enum				falid_action;
	bit[DATA_WIDTH - 1 : 0]		expected_data;
	bit[DATA_WIDTH - 1 : 0]		got_data;
	true_false_enum				expected_FAIL = FALSE;

	// Get action
	function reg_action_enum getAction();
		return action;
	endfunction

	// Set action
	function void setAction(reg_action_enum action);
		this.action = action;
	endfunction

	// Get begin_time
	function int getBegin_time();
		return begin_time;
	endfunction

	// Set begin_time
	function void setBegin_time(int begin_time);
		this.begin_time = begin_time;
	endfunction

	// Get data
	function bit[DATA_WIDTH-1:0] getData();
		return data;
	endfunction

	// Set data
	function void setData(bit[DATA_WIDTH-1:0] data);
		this.data = data;
	endfunction

	// Get end_time
	function int getEnd_time();
		return end_time;
	endfunction

	// Set end_timesuper
	function void setEnd_time(int end_time);
		this.end_time = end_time;
	endfunction

	// Get name
	function string getName();
		return name;
	endfunction

	// Set name
	function void setName(string name);
		this.name = name;
	endfunction

	// Get status
	function uvm_status_e getStatus();
		return status;
	endfunction

	// Set status
	function void setStatus(uvm_status_e status);
		this.status = status;
	endfunction

	// Get falid_action
	function reg_action_enum getFalid_action();
		return falid_action;
	endfunction

	// Set falid_action
	function void setFalid_action(reg_action_enum falid_action);
		this.falid_action = falid_action;
	endfunction

	// Get expected_data
	function bit[DATA_WIDTH-1:0] getExpected_data();
		return expected_data;
	endfunction

	// Set expected_data
	function void setExpected_data(bit[DATA_WIDTH-1:0] expected_data);
		this.expected_data = expected_data;
	endfunction

	// Get got_data
	function bit[DATA_WIDTH-1:0] getGot_data();
		return got_data;
	endfunction

	// Set got_data
	function void setGot_data(bit[DATA_WIDTH-1:0] got_data);
		this.got_data = got_data;
	endfunction


	// Get expected_FAIL
	function true_false_enum getExpected_FAIL();
		return expected_FAIL;
	endfunction

	// Set expected_FAIL
	function void setExpected_FAIL(true_false_enum expected_FAIL);
		this.expected_FAIL = expected_FAIL;
	endfunction


endclass


//-------------------------------------------------------------------------------------
//
// CLASS: dut_testing_logger
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//			dut_testing_logger is classic logger that can collect all transaction
//			execute them and log in easy to read way.
//			It can store contex from register model to logger data base, restore it
//			and store results of som sequence
//
// API:
//		1. function void configure(input string name, true_false_enum end_at_first_UVM_NOT_OK = FALSE, true_false_enum print_all_actions = FALSE)
//
//			- this methode will configure logger
//			- parameters:
//				1. name
//					-name of sequence
//				2. end_at_first_UVM_NOT_OK
//					- if this is TRUE then logger will skip all transactions after first UVM_NOT_OK
//				3. print_all_actions
//					- if this is TRUE then logger will log on runtime
//
//	 	2. task reg_do(input uvm_reg reg_p, reg_action_enum action = MIRROR,bit[DATA_WIDTH - 1 : 0] data = 0, true_false_enum expected_FAIL = FALSE, output bit[DATA_WIDTH-1:0] read_data)
//
//			-with this task user can create transaction on register model to DUT
//			-parameters
//				1. reg_p
//					- pointer to register model

//				2. action
//					- action can be:
//						1. READ 	standard uvm_reg.read(argv)
//						2. WRITE 	standard uvm_reg.write(argv)
//						3. MIRROR	standard uvm_reg.mirror(argv)
//						4. SET		standard uvm_reg.set(argv)
//						5. GET 		standard uvm_reg.get(argv)
//						6. UPDATE  	standard uvm_reg.update(argv)
//				3. data
//					-argument that is used to write data to register model and DUT ( argv of uvm_reg.write(argv))
//
//				4. expected_FAIL
//					if this is set as TRUE than if uvm_reg.action returns UVM_NOT_OK that will be interpreted as succes and
//					if uvm_reg.action returns UVM_IS_OK that will interpreted as ERROR
//
//				5. read_data
//					this is output value of read and get actions
//
//
//		3.function void printAll();
//
//			-this function will print all actions and logs
//
//		4.function void printErrors();
//
//			-this function will print all error actions
//
//		5.function void printStatus();
//
//			-this function will print end status
//
//		6.function void mssg(string input_string);
//
//			-this functino will create message log that will print in end status
//			-parameters
//				1. input_string
//					-this string will be printed in end status print nad print all actions
//
//		7. task storeContex(input string name, dut_register_block block_to_store  );
//
//			-this task is used to collect current state of register model registers and store it to
//			logger data base by given name
//			-parameters
//				1. name
//					this will be name of sored contex
//				2. block_to_store
//					pointer to register model to store
//
//		8. task storeResults(input string name);
//
//			-this task will collect number of succes transaction error transaction and number of skipped transactions
//			and store it to logger data base by name
//			-parameters
//				1. name
//					this will be name of stored result
//
//		9. task restoreContex(string name,  dut_register_block block_to_store);
//
//			-this task will try to get register model registers image from logger
//			data base by name if there is sotred configuration by given name
//			task will predict every ( uvm_predict) every field in register model
//
//
//		10. task printAllResults()
//
//			-this task will print all stored results in logger data base
//
//
// REQUIREMENTS:
//		1. logger_db
//		logger must have his data base to use storegin and restoreing options
//
//
//------------------------------------------------------------------------------

class dut_testing_logger;

	true_false_enum 				configured;						//this is true if logger is configured ( called function configure )
	true_false_enum 				end_on_UVM_NOT_OK;
	true_false_enum					print_status_on_end;
	true_false_enum					print_all_actions;
	string 							name;
	dut_testing_logger_mssg			actions_queue[$];
	true_false_enum					error_happed = FALSE;
	int 							skipped_actions;
	dut_testing_logger_data_base	data_base;
	int 							ok_number	 = 0;
	int 							error_number = 0;
	int 							order_number = 0;
	string	 						message_queue[$];



	function new ();
		data_base = dut_testing_logger_data_base::getDataBaseInstace();
	endfunction


	//API
	// configure logger
	extern function void configure(input string name, true_false_enum end_at_first_UVM_NOT_OK = FALSE, true_false_enum print_all_actions = FALSE);

	// main logger activiti
	extern task reg_do(input uvm_reg reg_p, reg_action_enum action = MIRROR,bit[DATA_WIDTH - 1 : 0] data = 0, true_false_enum expected_FAIL = FALSE, output bit[DATA_WIDTH-1:0] read_data);
	extern function void printAll();
	extern function void printErrors();
	extern function dut_testing_logger_mssg_transaction_pack	getErrorLog(); // this is still in development
	extern function void printStatus();
	extern function void mssg(string input_string);

	//storeing and restoreing data
	extern task storeContex(input string name, dut_register_block block_to_store  );
	extern task storeResults(input string name);
	extern task restoreContex(string name,  dut_register_block block_to_store);

//  print all results from DB TODO

	extern local function void printLog(input dut_testing_logger_mssg log_mssg);
	extern local function void printLogMssg(input dut_testing_logger_mssg_log log_mssg);
	extern local function void printLogTransaction(input dut_testing_logger_mssg_transaction_pack to_print);
	extern local function void printBeginHeader(input string sequence_name);
	extern local function void printEndHeader(input string sequence_name);
	extern local function void printEndStatus();
	extern local function string getActionString(input reg_action_enum action);
	extern local function string getStatusString(input uvm_status_e status);
	extern local function void printMessageQueue();

endclass : dut_testing_logger


	function void dut_testing_logger::configure(input string name,  true_false_enum end_at_first_UVM_NOT_OK, true_false_enum print_all_actions  );
	    //set that logger is configured
	    this.configured			= TRUE;
		this.name				= name;
		this.end_on_UVM_NOT_OK	= end_at_first_UVM_NOT_OK;
		this.print_all_actions	= print_all_actions;
	endfunction

	task dut_testing_logger::reg_do(input uvm_reg reg_p, input reg_action_enum action,bit[DATA_WIDTH-1:0] data, true_false_enum expected_FAIL, output bit[DATA_WIDTH-1:0] read_data);
		bit[DATA_WIDTH-1:0] tmp_data;
		dut_testing_logger_mssg_transaction_pack log = new();

		if(this.configured == FALSE)
			begin
				$display("TO USE LOGGER YOU HAVE TO CONFIGURE IT FIRST");
				return;
			end

		if(error_happed == TRUE && end_on_UVM_NOT_OK == TRUE)
			begin
				if(skipped_actions < 1)
					begin
						$display("Beacuse Error happened skipping actions");
					end
				skipped_actions++;
				return;
			end

		log.setName(reg_p.get_name());
		log.setAction(action);
		log.setOred_number(order_number);
		log.setExpected_FAIL(expected_FAIL);
		log.setMssg_type(TRANSACTION);
		order_number++;

		case (action)
// READ
			READ:
			begin
				log.setBegin_time($time);
				reg_p.read(log.status, tmp_data);
				log.setEnd_time($time);
				log.setData(tmp_data);
				read_data = tmp_data;
				if(log.getStatus() == UVM_NOT_OK)
					begin
						log.setFalid_action(READ);
					end
			end


//WRITE
			WRITE:
			begin
				write_extension extension;
				//this is aka "BUDJ" if writing to MIS create extension see more in MIS callbacks
				if(reg_p.get_name() == "MIS")
					begin
						bit_byte_union check_data;
						extension = write_extension::type_id::create("extension");
						check_data.one_byte = data;

						if(check_data.one_bit[0] == 1)
							extension.setOverflow(1);

						if(check_data.one_bit[1] == 1)
							extension.setUnderflow(1);

						if(check_data.one_bit[2] == 1)
							extension.setMatch(1);
					end

				log.setBegin_time($time);
				reg_p.write(log.status,data, .extension(extension));

				log.setEnd_time($time);
				log.setData(data);
				if(log.getStatus() == UVM_NOT_OK)
					begin
						log.setFalid_action(WRITE);
					end
			end


//MIRROR
			MIRROR:
			begin
				bit[DATA_WIDTH - 1 : 0]  	mirrored_tmp;
				mirrored_tmp = reg_p.get_mirrored_value();

				log.setBegin_time($time);
				//reg_p.mirror(log.status, UVM_CHECK); // ne moze jer ne mogu da dobijem da je check OK ili nije
				reg_p.read(log.status, tmp_data);
				log.setEnd_time($time);
				log.setData(tmp_data);

				if(tmp_data != mirrored_tmp)
					begin
						log.setExpected_data(mirrored_tmp);
						log.setGot_data(tmp_data);
						log.setStatus(UVM_NOT_OK);
						log.setFalid_action(CHECK);
					end
				else
					begin
						// da li treba nesto da se uradi ?? // TODO
					end
//				log.setData(reg_p.get_mirrored_value());
			end


//SET
			SET:
			begin
				log.setBegin_time($time);
				reg_p.set(data);
				log.setEnd_time($time);
				log.setData(data);
				log.setStatus(UVM_IS_OK);
			end

//GET
			GET:
			begin
				log.setBegin_time($time);
				data = reg_p.get();
				log.setEnd_time($time);
				log.setData(data);
				log.setStatus(UVM_IS_OK);
			end

//UPDATE
			UPDATE:
			begin
				log.setBegin_time($time);
				reg_p.update(log.status);
				log.setEnd_time($time);
				log.setData(data);
				log.setStatus(UVM_IS_OK);
			end

		endcase

		if(this.print_all_actions == TRUE)
			begin
				printLog(log);
			end

		// if got error and it is note predicted
		if(log.getStatus == UVM_NOT_OK && log.getExpected_FAIL() == FALSE)
			begin
				error_happed = TRUE;
			end
		// if got error and it is predicted
		else if(log.getStatus() == UVM_NOT_OK && log.getExpected_FAIL() == TRUE)
			begin
				log.setStatus(UVM_IS_OK);
			end
		// if got ok but error is predicted
		else if(log.getStatus() == UVM_IS_OK && log.getExpected_FAIL() == TRUE)
			begin
				log.setStatus(UVM_NOT_OK);
				log.setFalid_action(PREDICTION);
				error_happed = TRUE;
			end


		actions_queue.push_back(log);

	endtask


	function void dut_testing_logger::printErrors();
	   int i;

		foreach(actions_queue[i])
			begin
				dut_testing_logger_mssg_transaction_pack pack;
				$cast(pack, actions_queue[i]);
				if(pack.getStatus() != UVM_IS_OK /*|| actions_queue[i].getStatus() == UVM_HAS_X*/)
				begin
					printLog(actions_queue[i]);
				end
			end
	endfunction

	function void dut_testing_logger::printAll();
		int i;
	   	foreach(actions_queue[i])
			begin
				printLog(actions_queue[i]);
			end
	endfunction

	function void dut_testing_logger::printBeginHeader(input string sequence_name);
	   	$display("");
		$display("================================================================================================================================================================================");
		$display("==                               				sequence:    %s                                                                  " ,sequence_name);
		$display("================================================================================================================================================================================");

	endfunction

	function void dut_testing_logger::printEndHeader(input string sequence_name);
		$display("================================================================================================================================================================================");
		$display("==                               				END:    %s                                                                       ",sequence_name);
		$display("================================================================================================================================================================================");
		$display("");
	endfunction


	function void dut_testing_logger::printLog(input dut_testing_logger_mssg log_mssg);
	    if(log_mssg.getMssg_type == TRANSACTION)
		    printLogTransaction(dut_testing_logger_mssg_transaction_pack'(log_mssg));
	    else
		    printLogMssg(dut_testing_logger_mssg_log'(log_mssg));
	endfunction


	function void dut_testing_logger::printLogMssg(input dut_testing_logger_mssg_log log_mssg);
	    $display("        \t[LOG]: %s", log_mssg.getLog());
	endfunction


	function void dut_testing_logger::printLogTransaction(input dut_testing_logger_mssg_transaction_pack to_print);
		string status_string = this.getStatusString(to_print.getStatus());
		string action_string = this.getActionString(to_print.getAction());
		reg_action_enum failed_action;

		$display("%s       \t[REG]: action: %s, \tvalue: %0d, \tbegin time: %5d, \tend time : %5d, \torder of actions: %0d, \t\t\tstatus ------------------- %s",to_print.getName(),
					action_string, to_print.getData(), to_print.getBegin_time(), to_print.getEnd_time(),to_print.getOred_number(), status_string);

		// if action failed then check which action has failed
		if(to_print.getStatus() != UVM_IS_OK)
		begin
			failed_action = to_print.getFalid_action();

			if(failed_action == CHECK)
				begin
					$display("\t\t   : expected value: %0d, got_value: %0d,  faild action: CHECK ", to_print.getExpected_data(), to_print.getGot_data());
				end

			else if(failed_action == READ 	||
					failed_action == WRITE 	||
					failed_action == MIRROR	||
					failed_action == SET	||
					failed_action == UPDATE	||
					failed_action == GET 		)
				begin
					$display("\t\t\t     : ERROR while %s action. ", getActionString(to_print.getFalid_action()));
				end
			else if(failed_action == PREDICTION)
				begin
					$display("\t\t\t    : ERROR was predicted but got OK response!");
				end
		end

		if(to_print.getExpected_FAIL() == TRUE)
			begin
				$display("\t\t\t     : NOTE  predicted ERROR and got ERROR ");
			end
	endfunction

	function string dut_testing_logger::getActionString(input reg_action_enum action);
	    case (action)

		    READ:
		    begin
			    return "READ";
		    end

			WRITE:
			begin
				return "WRITE";
			end

			MIRROR:
			begin
				return "MIRROR";
			end

			SET:
			begin
				return "SET";
			end

			GET:
			begin
				return "GET";
			end

			UPDATE:
			begin
				return "UPDATE";
			end

			CHECK:
			begin
				return "CHECK";
			end

	    endcase
	endfunction

	function string dut_testing_logger::getStatusString(input uvm_status_e status);
	   case(status)
		   UVM_IS_OK:
		   begin
			   return "OK";
		   end

		   UVM_NOT_OK:
		   begin
			   return "FAILED";
		   end

		   default:
		   begin
			    return "FAILED";
		   end

	   endcase
	endfunction

	function dut_testing_logger_mssg_transaction_pack dut_testing_logger::getErrorLog();
	   $display("TODO RETURN ERROR LOG DATA ");
	endfunction

	function void dut_testing_logger::printEndStatus();
//		int ok_number	 = 0;
//		int error_number = 0;
		int i;
		foreach(actions_queue[i])
			begin
				if(actions_queue[i].getMssg_type == TRANSACTION)
					begin
						dut_testing_logger_mssg_transaction_pack pack;
						$cast(pack, actions_queue[i]);
						if(pack.getStatus() == UVM_IS_OK)
							begin
								ok_number++;
							end
						else
							begin
								error_number++;
							end
					end
			end
		$display("");
		if(error_number == 0)
			begin
				$display("-----------------------------------------------------------------------------SEQUENCE OK ! , NO ERRORS -------------------------------------------------------------------------");
			end
		else
			begin
				$display("---------------------------------------------------------SEQUENCE ERROR : %0d action(s), OK %0d action(s), SKIPPED %0d action(s)-------------------------------------------------", error_number, ok_number, skipped_actions);
				$display("");
				printErrors();
				$display("");
				$display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
			end
	endfunction


	function void dut_testing_logger::printStatus();
		this.printBeginHeader(this.name);
		this.printMessageQueue();
		this.printAll();
		this.printEndStatus();
		this.printEndHeader(this.name);
	endfunction

	task dut_testing_logger::storeContex(input string name, dut_register_block block_to_store );
	   dut_testing_logger_contex stored_contex = new();


		stored_contex.setCFG(		block_to_store.CFG_reg.get_mirrored_value()		);
		stored_contex.setCOUNT(		block_to_store.COUNT_reg.get_mirrored_value()	);
		stored_contex.setIIR(		block_to_store.IIR_reg.get_mirrored_value()		);
		stored_contex.setIM(		block_to_store.IM_reg.get_mirrored_value()		);
		stored_contex.setLOAD(		block_to_store.LOAD_reg.get_mirrored_value()	);
		stored_contex.setMATCH(		block_to_store.MATCH_reg.get_mirrored_value()	);
		stored_contex.setMIS(		block_to_store.MIS_reg.get_mirrored_value()		);
		stored_contex.setRIS(		block_to_store.RIS_reg.get_mirrored_value()		);
		stored_contex.setSWRESET(	block_to_store.SWRESET_reg.get_mirrored_value() );

		data_base.setContex(name, stored_contex);

	endtask

	task dut_testing_logger::storeResults(input string name);
		dut_testing_logger_results result_pack = new();

		result_pack.setERROR_quantity(error_number);
		result_pack.setOK_quantity(ok_number);
		result_pack.setName(name);
		result_pack.setSKIPPED_quantity(skipped_actions);

		data_base.setResult(result_pack);

	endtask

	task dut_testing_logger::restoreContex(input string name, dut_register_block block_to_store);
		int found_contex;
		dut_testing_logger_contex contex_to_restore;

	    data_base.getContex(name, contex_to_restore, found_contex);

		if(found_contex == 1)
			begin
				message_queue.push_back("ContexSwtich \t[ U ]: restoring register contex ------------------------------------------------------------------------------------------------------------------------ OK");

				void'(block_to_store.CFG_reg.predict(contex_to_restore.getCFG()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: CFG    :%4h", contex_to_restore.getCFG()));

				void'(block_to_store.COUNT_reg.predict(contex_to_restore.getCOUNT()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: COUNT  :%4h", contex_to_restore.getCOUNT()));

				void'(block_to_store.IIR_reg.predict(contex_to_restore.getIIR()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: IIR    :%4h", contex_to_restore.getIIR()));

				void'(block_to_store.IM_reg.predict(contex_to_restore.getIM()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: IM     :%4h", contex_to_restore.getIM()));

				void'(block_to_store.LOAD_reg.predict(contex_to_restore.getLOAD()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: LOAD   :%4h", contex_to_restore.getLOAD()));

				void'(block_to_store.MATCH_reg.predict(contex_to_restore.getMATCH()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: MATCH  :%4h", contex_to_restore.getMATCH()));

				void'(block_to_store.MIS_reg.predict(contex_to_restore.getMIS()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: MIS    :%4h", contex_to_restore.getMIS()));

				void'(block_to_store.RIS_reg.predict(contex_to_restore.getRIS()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: RIS    :%4h", contex_to_restore.getRIS()));

				void'(block_to_store.SWRESET_reg.predict(contex_to_restore.getSWRESET()));
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: SWRESET:%4h", contex_to_restore.getSWRESET()));

			end
		else
			begin
				message_queue.push_back($sformatf("ContexSwtich \t[ U ]: did not found register contex stored value by name: %s ----------------------------------------------------------------------------------- USING DEFAULT", name));
			end
	endtask


	function void dut_testing_logger::printMessageQueue();
		int iterator;

	   if(message_queue.size() == 0)
		   return;

	   foreach(message_queue[iterator])
		   begin
			   $display("%s", message_queue[iterator]);
		   end

		message_queue.delete();

		return;
	endfunction

	function void dut_testing_logger::mssg(string input_string);
		dut_testing_logger_mssg_log log;
		log = new();

		log.setMssg_type(LOG);
		log.setOred_number(actions_queue.size());
		log.setLog(input_string);

		actions_queue.push_back(log);

	endfunction

`endif