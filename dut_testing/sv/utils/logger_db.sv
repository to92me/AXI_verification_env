`ifndef DUT_TESTING_LOGGER_DATA_BASE_SVH
`define DUT_TESTING_LOGGER_DATA_BASE_SVH

class dut_testing_logger_results;
	int OK_quantity ;
	int ERROR_quantity;
	int SKIPPED_quantity;
	string name;

 	// Get ERROR_quantity
 	function int getERROR_quantity();
 		return ERROR_quantity;
 	endfunction

 	// Set ERROR_quantity
 	function void setERROR_quantity(int ERROR_quantity);
 		this.ERROR_quantity = ERROR_quantity;
 	endfunction

 	// Get OK_quantity
 	function int getOK_quantity();
 		return OK_quantity;
 	endfunction

 	// Set OK_quantity
 	function void setOK_quantity(int OK_quantity);
 		this.OK_quantity = OK_quantity;
 	endfunction

 	// Get name
 	function string getName();
 		return name;
 	endfunction

 	// Set name
 	function void setName(string name);
 		this.name = name;
 	endfunction

 	// Get SKIPPED_quantity
 	function int getSKIPPED_quantity();
 		return SKIPPED_quantity;
 	endfunction

 	// Set SKIPPED_quantity
 	function void setSKIPPED_quantity(int SKIPPED_quantity);
 		this.SKIPPED_quantity = SKIPPED_quantity;
 	endfunction



 	function copyResult(input dut_testing_logger_results res);

		 	this.name 			= res.getName();
		 	this.ERROR_quantity = res.getERROR_quantity();
	 		this.OK_quantity 	= res.getOK_quantity();

 	endfunction


endclass


class dut_testing_logger_contex;
	bit[15 : 0]		RIS;
	bit[15 : 0]		IM;
	bit[15 : 0]		MIS;
	bit[15 : 0]		LOAD;
	bit[15 : 0]		CFG;
	bit[15 : 0]		SWRESET;
	bit[15 : 0]		IIR;
	bit[15 : 0]		MATCH;
	bit[15 : 0]		COUNT;

	// Get CFG
	function bit[15:0] getCFG();
		return CFG;
	endfunction

	// Set CFG
	function void setCFG(bit[15:0] CFG);
		this.CFG = CFG;
	endfunction

	// Get COUNT
	function bit[15:0] getCOUNT();
		return COUNT;
	endfunction

	// Set COUNT
	function void setCOUNT(bit[15:0] COUNT);
		this.COUNT = COUNT;
	endfunction

	// Get IIR
	function bit[15:0] getIIR();
		return IIR;
	endfunction

	// Set IIR
	function void setIIR(bit[15:0] IIR);
		this.IIR = IIR;
	endfunction

	// Get IM
	function bit[15:0] getIM();
		return IM;
	endfunction

	// Set IM
	function void setIM(bit[15:0] IM);
		this.IM = IM;
	endfunction

	// Get LOAD
	function bit[15:0] getLOAD();
		return LOAD;
	endfunction

	// Set LOAD
	function void setLOAD(bit[15:0] LOAD);
		this.LOAD = LOAD;
	endfunction

	// Get MATCH
	function bit[15:0] getMATCH();
		return MATCH;
	endfunction

	// Set MATCH
	function void setMATCH(bit[15:0] MATCH);
		this.MATCH = MATCH;
	endfunction

	// Get MIS
	function bit[15:0] getMIS();
		return MIS;
	endfunction

	// Set MIS
	function void setMIS(bit[15:0] MIS);
		this.MIS = MIS;
	endfunction

	// Get RIS
	function bit[15:0] getRIS();
		return RIS;
	endfunction

	// Set RIS
	function void setRIS(bit[15:0] RIS);
		this.RIS = RIS;
	endfunction

	// Get SWRESET
	function bit[15:0] getSWRESET();
		return SWRESET;
	endfunction

	// Set SWRESET
	function void setSWRESET(bit[15:0] SWRESET);
		this.SWRESET = SWRESET;
	endfunction


endclass


class dut_testing_logger_data_base_contex_package;
	dut_testing_logger_contex	contex;
	string 						name;

	// Get contex
	function dut_testing_logger_contex getContex();
		return contex;
	endfunction

	// Set contex
	function void setContex(dut_testing_logger_contex contex);
		this.contex = contex;
	endfunction

	// Get name
	function string getName();
		return name;
	endfunction

	// Set name
	function void setName(string name);
		this.name = name;
	endfunction


endclass



class dut_testing_logger_data_base;

	static  dut_testing_logger_data_base data_base_instance;
	dut_testing_logger_data_base_contex_package		contex_queue[$];
	dut_testing_logger_results						result_queue[$];

	semaphore 										sem_con;
	semaphore 										sem_res;

	local function new();
		sem_con = new(1);
		sem_res = new(1);
	endfunction

	extern static function dut_testing_logger_data_base getDataBaseInstace();

	extern task setContex(input string name, input dut_testing_logger_contex contex);
	extern task setResult(input dut_testing_logger_results result);
	extern task getContex(input string name, output dut_testing_logger_contex contex, output int found_contex);
	extern task getResults(output logger_result_queue results_queue);

endclass

	function dut_testing_logger_data_base dut_testing_logger_data_base::getDataBaseInstace();
	   if(data_base_instance == null)
		   begin
			   data_base_instance = new();
		   end
		return data_base_instance;
	endfunction

	task dut_testing_logger_data_base::setContex(input string name, input dut_testing_logger_contex contex);
	   	dut_testing_logger_data_base_contex_package pack = new();

	   	pack.setContex(contex);
		pack.setName(name);

		sem_con.get(1);
		contex_queue.push_back(pack);
		sem_con.put(1);

	endtask

	task dut_testing_logger_data_base::getContex(input string name, output dut_testing_logger_contex contex, output int found_contex);
		int iterator;
		int match_name_iterator;
		found_contex = 0;

	   sem_con.get(1);
		foreach(contex_queue[iterator])
			begin
			if(contex_queue[iterator].getName() == name)
				begin
					contex = contex_queue[iterator].getContex();
					found_contex = 1;
					match_name_iterator = iterator;
					break;
				end
			end

		if(found_contex == 1)
			contex_queue.delete(match_name_iterator);

		sem_con.put(1);

	endtask

	task dut_testing_logger_data_base::setResult(input dut_testing_logger_results result);
		sem_res.get(1);
		result_queue.push_back(result);
		sem_res.put(1);

	endtask

	task dut_testing_logger_data_base::getResults(output logger_result_queue results_queue);
		logger_result_queue send_queue;
		int iterator;

	   sem_res.get(1);
		foreach(result_queue[iterator])
			begin
				dut_testing_logger_results result = new();
				result.copyResult(result_queue[iterator]);
				send_queue.push_back(result);
			end
	   sem_res.put(1);

		results_queue = send_queue;

	endtask


`endif
