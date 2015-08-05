`ifndef AXI_TYPES_SVH
`define AXI_TYPES_SVH

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 64;
parameter ID_WIDTH = 32;

typedef struct {
	bit[ADDR_WIDTH-1 : 0] start_address;
	bit[ADDR_WIDTH-1 : 0] end_address;
} slave_address_space_type;

typedef enum logic {
	NORMAL 		= 0,
	EXCLUSIVE 	= 1
} lock_enum;

typedef enum logic [1:0] {
	FIXED = 0,
	INCR = 1,
	WRAP = 2,
	Reserved = 3
} burst_type_enum;

typedef enum logic [1:0] {
	OKAY = 0,
	EXOKAY = 1,
	SLVERR = 2,
	DECERR = 3
} response_enum;

typedef enum logic [2:0] {
	BYTE_1 = 0,
	BYTE_2 = 1,
	BYTE_4 = 2,
	BYTE_8 = 3,
	BYTE_16 = 4,
	BYTE_32 = 5,
	BYTE_64 = 6,
	BYTE_128 = 7
} burst_size_enum;

typedef enum {
	AXI_READ = 0,
	AXI_WRITE = 1
} axi_direction_enum;

`endif
