`ifndef AXI_TYPES_SVH
`define AXI_TYPES_SVH

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 64;
parameter ID_WIDTH = 32;


typedef struct {
	bit[ADDR_WIDTH-1 : 0] start_address;
	bit[ADDR_WIDTH-1 : 0] end_address;
} slave_address_space_type;

typedef enum {
	NORMAL 		= 0,
	EXCLUSIVE 	= 1
} lock_enum;


`endif
