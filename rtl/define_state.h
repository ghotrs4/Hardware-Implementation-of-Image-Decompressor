`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_M1,
	S_M2
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [5:0] {
	S_LI_1,
	S_LI_2,
	S_LI_3,
	S_LI_4,
	S_LI_5,
	S_LI_6,
	S_LI_7,
	S_LI_8,
	S_LI_9,
	S_LI_10,
	S_LI_11,
	S_LI_12,
	S_LI_13,
	S_LI_14,
	S_LI_15,
	S_LI_16,
	S_LI_17,
	S_LI_18,
	S_LI_19,
	S_LI_20,
	S_LI_21,
	S_LI_22,
	S_LI_23,
	S_LI_24,
	S_M1_IDLE,
	S_C1,
	S_C2,
	S_C3,
	S_C4,
	S_C5,
	S_C6,
	S_LO_1,
	S_LO_2,
	S_LO_3,
	S_LO_4,
	S_LO_5,
	S_LO_6,
	S_LO_7,
	S_LO_8,
	S_LO_9,
	S_LO_10,
	S_LO_11,
	S_LO_12,
	S_LO_13,
	S_LO_14,
	S_LO_15,
	S_LO_16,
	S_LO_17,
	S_LO_18,
	S_LO_19,
	S_LO_20,
	S_LO_21,
	S_LO_22,
	S_LO_23,
	S_LO_24,
	S_LO_25,
	S_LO_26,
	S_LO_27,
	S_LO_28
} M1_state_type;

typedef enum logic [5:0] {
	S_M2_LI_1,
	S_M2_LI_2,
	S_M2_LI_3,
	S_M2_LI_4,
	S_M2_LI_5,
	S_M2_LI_6,
	S_M2_LI_7,
	S_M2_LI_8,
	S_M2_LI_9,
	S_M2_LI_10,
	S_M2_LI_11,
	S_M2_LI_12,
	S_M2_LI_13,
	S_MB_LI_1,
	S_MB_LI_2,
	S_MB_LI_3,
	S_MB_LI_4,
	S_MA_1,
	S_MA_2,
	S_MA_3,
	S_MA_4,
	S_MA_5,
	S_MA_6,
	S_MA_7,
	S_MA_8,
	S_MA_9,
	S_MA_10,
	S_MA_11,
	S_MA_12,
	S_MA_13,
	S_MA_14,
	S_MA_15,
	S_MA_16,
	S_MB_1,
	S_MB_2,
	S_MB_3,
	S_MB_4,
	S_MB_5,
	S_MB_6,
	S_MB_7,
	S_MB_8,
	S_MB_9,
	S_MB_10,
	S_MB_11,
	S_MB_12,
	S_MB_13,
	S_MB_14,
	S_MB_15,
	S_MB_16
} M2_state_type;


typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
