`ifndef LOGGER_RESULT_PRINTER_SHV
`define LOGGER_RESULT_PRINTER_SHV

class dut_testing_logger_result_printer;

 	dut_testing_logger_data_base	db;


	function new();
		db = dut_testing_logger_data_base::getDataBaseInstace();
	endfunction

	extern task printResults(true_false_enum print_individually_results);
	extern local function void printOneResult(dut_testing_logger_results result);


endclass

	task dut_testing_logger_result_printer::printResults(true_false_enum print_individually_results);
		int OK;
		int ERROR;
		int SKIPPED;
		int i;

		dut_testing_logger_results results[$];
	   	db.getResults(results);


		foreach(results[i])
			begin
				OK 		= results[i].getOK_quantity();
				ERROR 	= results[i].getERROR_quantity();
				SKIPPED = results[i].getSKIPPED_quantity();
			end

		if(print_individually_results == TRUE)
			begin
				$display("==================================================================INDIVIDUAL RESULTS============================================================================================");
				foreach(results[i])
					begin
						this.printOneResult(results[i]);
					end
				$display("================================================================================================================================================================================");
			end

		if(ERROR == 0 && SKIPPED == 0)
			begin
				$display(" _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____  ");
				$display("|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|");
				$display("");
				$display("\t\t\t\t\t ____  _____ ___  _   _ _____ _   _  ____ _____ ____     ___  _  __  _ ");
				$display("\t\t\t\t\t/ ___|| ____/ _ \\| | | | ____| \\ | |/ ___| ____/ ___|   / _ \\| |/ / | |");
				$display("\t\t\t\t\t\\___ \\|  _|| | | | | | |  _| |  \\| | |   |  _| \\___ \\  | | | | ' /  | |");
				$display("\t\t\t\t\t ___) | |__| |_| | |_| | |___| |\\  | |___| |___ ___) | | |_| | . \\  |_|");
				$display("\t\t\t\t\t|____/|_____\\__\\_\\\\___/|_____|_| \\_|\\____|_____|____/   \\___/|_|\\_\\ (_)");
				$display("\t\t\t\t\t                                                                       ");
//				$display("");
				$display(" _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____  ");
				$display("|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|");
				$display("");
			end
		else
			begin
				$display(" _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____  ");
				$display("|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|");
				$display("");
				$display("\t\t [ R ] OK : %d", OK);
				$display("\t\t [ R ] ERROR: %d", ERROR);
				$display("\t\t [ R ] SKIPPED: %d ", SKIPPED);
				$display("");
				$display(" _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____  ");
				$display("|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|");
				$display("");

			end

	endtask

	function void dut_testing_logger_result_printer::printOneResult(input dut_testing_logger_results result);
	    if(result.getERROR_quantity() == 0)
	    	$display("result \t\t[ R ]: %s  \t---------------------------------------------------------------------------------------------------------------------------------- OK", result.getName());
	    else
		    begin
		    $display("result \t\t[ R ]: %s  \t---------------------------------------------------------------------------------------------------------------------------------- FAILED :/", result.getName());
	    	$display(" 		 \t\t[   ] OK: %d, ERROR: %d, SKIPPED: %d  ", result.getOK_quantity(), result.getERROR_quantity(), result.getSKIPPED_quantity());
		    end
	endfunction



`endif
