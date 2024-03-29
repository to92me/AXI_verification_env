// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_base_test.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : contains tests
*
* Classes : 1. axi_read_base_test
*           2. axi_read_valid_burst_frame
*           3. axi_read_valid_single_frame
*           4. virtual_seq_test
**/
// -----------------------------------------------------------------------------


//----------------------------------------------------------------
//
// TEST: axi_read_base_test
//
//----------------------------------------------------------------
/**
* Description : base test
**/
// -----------------------------------------------------------------------------
class axi_read_base_test extends uvm_test;

    axi_read_tb tb0;

    `uvm_component_utils_begin(axi_read_base_test)
        `uvm_field_object(tb0, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name = "axi_read_base_test", uvm_component parent);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb0 = axi_read_tb::type_id::create("tb0", this);
    endfunction : build_phase

endclass : axi_read_base_test

//------------------------------------------------------------------------------
//
// Class: axi_read_valid_burst_frame
//
//------------------------------------------------------------------------------
/**
* Description : burst frame following protocol
**/
// -----------------------------------------------------------------------------
class axi_read_valid_burst_frame extends axi_pkg::axi_read_whole_burst;

    `uvm_object_utils(axi_read_valid_burst_frame)

    constraint valid_ct {valid_burst == 1;}
    
endclass : axi_read_valid_burst_frame

//------------------------------------------------------------------------------
//
// Class: axi_read_valid_single_frame
//
//------------------------------------------------------------------------------
/**
* Description : single frame following protocol
**/
// -----------------------------------------------------------------------------
class axi_read_valid_single_frame extends axi_pkg::axi_read_single_addr;

    `uvm_object_utils(axi_read_valid_single_frame)

    constraint valid_ct {id_mode == GOOD_ID; resp_mode == GOOD_RESP; last_mode == GOOD_LAST_BIT; correct_lane == 1; read_enable == 0;}
    
endclass : axi_read_valid_single_frame

//----------------------------------------------------------------
//
// TEST: virtual_seq_test
//
//----------------------------------------------------------------
/**
* Description : simple test
**/
// -----------------------------------------------------------------------------
class virtual_seq_test extends axi_read_base_test;
    `uvm_component_utils(virtual_seq_test)

    function new(string name = "virtual_seq_test", uvm_component parent);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);

        // Enable transaction recording for everything
        set_config_int("*", "recording_detail", UVM_FULL);
        // collect coverage or not
        uvm_config_int::set(this, "tb0.axi0.*", "coverage_enable", 1);
        // perform checks in monitor
        uvm_config_int::set(this, "tb0.axi0.*", "checks_enable", 1);
        // early termination of bursts
        uvm_config_int::set(this, "*", "terminate_enable", 1);
        // randomizing ready signal for master
        uvm_config_int::set(this, "tb0.axi0.read_master.driver", "master_ready_rand_enable", 1);
        // radnomizing ready signal for slave
        uvm_config_int::set(this, "tb0.axi0.read_slave*.driver", "slave_ready_rand_enable", 1);
        // actions based on region signal
        uvm_config_int::set(this, "tb0.axi0.read_slave*.sequencer.arbit", "region_enable", 1);

        // uvm_config_db#(uvm_object_wrapper)::set(this, "tb0.virtual_sequencer.run_phase", "default_sequence", virtual_transfer_seq::type_id.get());
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_multiple_addr::get_type());
        uvm_config_wrapper::set(this, "tb0.axi0.read_slave*.sequencer.run_phase", "default_sequence",
                                                     axi_slave_read_simple_two_phase_seq::get_type());

        // Create the tb
        super.build_phase(phase);
    endfunction : build_phase

endclass : virtual_seq_test