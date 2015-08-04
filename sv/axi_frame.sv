/******************************************************************************
	* DVT CODE TEMPLATE: sequence item
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_item
//
//------------------------------------------------------------------------------

class  uvc_company_uvc_name_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;
	
	// TODO: Declare fields here
	
	
	rand int data;
	
	// TODO : it is a good practice to define a c_default_values_*
	// constraint for each field in which you constrain the field to some
	// default value or range. You can disable these constraints using
	// set_constraint_mode() before you call the randomize() function
	constraint c_default_values_data {
		data inside {[1:10]};
	}

	// UVM utility macros
	`uvm_object_utils_begin(uvc_company_uvc_name_item) 
		`uvm_field_int(data, UVM_DEFAULT)
	`uvm_object_utils_end

endclass :  uvc_company_uvc_name_item
