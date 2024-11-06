`ifndef REG_DEFINES
`define REG_DEFINES

typedef enum bit [3:0] {
	STATUS_REG   = 4'h0,
	CMD_REG      = 4'h4,
	DATA_REG     = 4'h8,
	PRESCALE_REG = 4'hc
} reg_addr_t;

typedef struct packed {
	bit [31:1] reserved;
	bit        enable;
} ctrl_reg_t;

typedef struct packed {
	bit [31:4] reserved;
	bit        cmd_full;
	bit        cmd_empty;
	bit        busy;
	bit        error;
} status_reg_t;

typedef enum bit [4:0] {
	CMD_STOP	= 5'h10,
	CMD_WR_M	= 5'h8,
	CMD_WRITE	= 5'h4,
	CMD_READ	= 5'h2,
	CMD_START	= 5'h1
} reg_cmd_flag_t;

typedef enum bit [1:0] {
	DATA_LAST		= 2'h2,
	DATA_VALID		= 2'h1,
	DATA_DEFAULT	= 2'h0
} reg_data_flag_t;

`endif
	