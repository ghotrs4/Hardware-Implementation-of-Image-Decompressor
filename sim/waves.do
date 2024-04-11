# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -bin UUT/M1_initialize
add wave -bin UUT/M1Finished
add wave -uns UUT/UART_timer

#add wave -divider -height 10 {SRAM signals}
#add wave -uns UUT/SRAM_address
#add wave -hex UUT/SRAM_write_data
#add wave -bin UUT/SRAM_we_n
#add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {M1 signals}

add wave UUT/M1_unit/SRAM_state
add wave -bin UUT/M1_unit/flag

add wave -uns UUT/M1_unit/SRAM_address
add wave -hex UUT/M1_unit/SRAM_write_data
add wave -bin UUT/M1_unit/SRAM_we_n
add wave -hex UUT/M1_unit/SRAM_read_data

add wave -dec UUT/M1_unit/Y_START
add wave -dec UUT/M1_unit/U_START
add wave -dec UUT/M1_unit/V_START

add wave -dec UUT/M1_unit/COL_NUM


#add wave -hex UUT/M1_unit/U_OLD
#add wave -hex UUT/M1_unit/V_PRIME_BEFORE

add wave -dec UUT/M1_unit/m1
add wave -dec UUT/M1_unit/op11
add wave -dec UUT/M1_unit/op12

add wave -dec UUT/M1_unit/m2
add wave -dec UUT/M1_unit/op21
add wave -dec UUT/M1_unit/op22

add wave -dec UUT/M1_unit/m3
add wave -dec UUT/M1_unit/op31
add wave -dec UUT/M1_unit/op32

add wave -dec UUT/M1_unit/m4
add wave -dec UUT/M1_unit/op41
add wave -dec UUT/M1_unit/op42


add wave -hex UUT/M1_unit/U_PRIME
add wave -dec UUT/M1_unit/U_PRIME_CALC

add wave -hex UUT/M1_unit/V_PRIME
add wave -dec UUT/M1_unit/V_PRIME_CALC




add wave -dec UUT/M1_unit/Y_STORE
add wave -dec UUT/M1_unit/Y_MULTIPLY


add wave -dec UUT/M1_unit/U_STORE
add wave -dec UUT/M1_unit/V_STORE


add wave -dec UUT/M1_unit/U_REG
add wave -dec UUT/M1_unit/V_REG


add wave -hex UUT/M1_unit/R_CALC_E
add wave -hex UUT/M1_unit/G_CALC_E
add wave -hex UUT/M1_unit/B_CALC_E


add wave -hex UUT/M1_unit/R_CALC_O
add wave -hex UUT/M1_unit/G_CALC_O
add wave -hex UUT/M1_unit/B_CALC_O



add wave -hex UUT/M1_unit/R_VALUE
add wave -hex UUT/M1_unit/G_VALUE
add wave -hex UUT/M1_unit/B_VALUE





