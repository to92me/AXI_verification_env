`ifndef AXI_TYPES_SVH
`define AXI_TYPES_SVH

parameter PIPE_SIZE = 5;
parameter MASTER_PIPE_SIZE = 5;
parameter SLAVE_PIPE_SIZE = 5;


parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 64;
parameter ID_WIDTH = 32;

parameter STRB_WIDTH = DATA_WIDTH / 8;

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

typedef enum {
	READY = 0,
	NOT_READY = 1,
	QUEUE_EMPTY = 2
}axi_mssg_enum;

typedef enum {
	QUEUE_LOCKED,
	QUEUE_UNLOCKED
}burst_queue_lock_enum;

typedef enum {
 	UNIQUE_ID,
 	EXISTING_ID,
 	FIRST_OF_EXISTING_ID
} id_type_enum;

typedef enum {
	FIRST_SENT,
	FIRST_NOT_SENT
} first_sent_enum;

typedef enum {
	BAD_LAST_BIT = 0,
	GOOD_LAST_BIT = 1
} last_enum;

typedef enum {
	FRAME_VALID,
	FRAME_NOT_VALID
} valid_enum;

typedef enum {
	TRUE = 1,
	FALSE = 0
} true_false_enum;

typedef enum {
	ERROR,
	NO_ERROR
} err_enum;


typedef enum {
	READY_DEFAULT_0 = 0,
	READY_DEFAULT_1 = 1
}	ready_default_enum;


typedef union {
	bit[7:0] [DATA_WIDTH/8 -1 : 0] lane;
	bit[DATA_WIDTH-1:0] data;
} mem_access;


typedef union {
	bit[7 : 0]	one_byte;
	bit 		[7 : 0]one_bit;
}bit_byte_union;

typedef enum{
	WAIT_WALID_TRANSACTION = 0,
	SEND_COLLECTED_DATA = 1
}axi_write_base_collector_state_enum;


`endif
