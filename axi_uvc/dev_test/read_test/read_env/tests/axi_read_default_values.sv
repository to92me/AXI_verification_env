// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_default_values.sv
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
* Description : one test case
*
* Classes : 1. axi_axi_read_default_values
*           2. axi_read_whole_burst_default_values
*           3. axi_read_single_frame_default_values
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class: axi_read_whole_burst_default_values
//
//------------------------------------------------------------------------------
/**
* Description : burst frame with default values for all possible signals
**/
// -----------------------------------------------------------------------------
class axi_read_whole_burst_default_values extends axi_pkg::axi_read_whole_burst;

    `uvm_object_utils(axi_read_whole_burst_default_values)

    constraint default_ct {default_id == 1; default_region == 1; default_len == 1; default_size == 1; default_burst_type == 1; default_lock == 1; default_cache == 1; default_qos == 1;}

endclass : axi_read_whole_burst_default_values

//------------------------------------------------------------------------------
//
// Class: axi_read_single_frame_default_values
//
//------------------------------------------------------------------------------
/**
* Description : single frame with default values for all possible signals
**/
// -----------------------------------------------------------------------------
class axi_read_single_frame_default_values extends axi_pkg::axi_read_single_addr;

    `uvm_object_utils(axi_read_single_frame_default_values)

    constraint default_ct {default_resp == 1; id_mode == GOOD_ID; last_mode == GOOD_LAST_BIT; correct_lane == 1; read_enable == 0;}

endclass : axi_read_single_frame_default_values

//------------------------------------------------------------------------------
//
// TEST: axi_read_default_values
//
//------------------------------------------------------------------------------
/**
* Description : test using default values for all possible signals
**/
// -----------------------------------------------------------------------------
class axi_read_default_values extends axi_read_base_test;

    `uvm_component_utils(axi_read_default_values)

    function new(string name = "axi_read_default_values", uvm_component parent);
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

        // type overrides
        set_type_override_by_type(axi_pkg::axi_read_whole_burst::get_type(), axi_read_whole_burst_default_values::get_type());
        set_type_override_by_type(axi_pkg::axi_read_single_addr::get_type(), axi_read_single_frame_default_values::get_type());

        // sequences
        uvm_config_wrapper::set(this, "tb0.virtual_seqr.run_phase", "default_sequence",
                                                     virtual_transfer_multiple_addr::get_type());
        uvm_config_wrapper::set(this, "tb0.axi0.read_slave*.sequencer.run_phase", "default_sequence",
                                                     axi_slave_read_simple_two_phase_seq::get_type());

        super.build_phase(phase);

    endfunction : build_phase

endclass : axi_read_default_values