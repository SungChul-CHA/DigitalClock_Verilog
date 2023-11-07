# BTN for power on reset
set_property IOSTANDARD LVCMOS25 [get_ports reset_poweron]
set_property PACKAGE_PIN T18 [get_ports reset_poweron]

# BTN for clock
set_property IOSTANDARD LVCMOS25 [get_ports {btn[*]}]
set_property PACKAGE_PIN P16 	[get_ports {btn[0]}]
set_property PACKAGE_PIN N15 [get_ports {btn[1]}]
set_property PACKAGE_PIN R18 	[get_ports {btn[2]}]
set_property PACKAGE_PIN R16 	[get_ports {btn[3]}]

# CLK_100M
set_property IOSTANDARD LVCMOS25 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]


###########################################################
# JA
###########################################################
set_property IOSTANDARD LVCMOS25 [get_ports {seg_data[*]}]
set_property PACKAGE_PIN Y11 	[get_ports {seg_data[7]}]
set_property PACKAGE_PIN AA11 [get_ports {seg_data[6]}]
set_property PACKAGE_PIN Y10 	[get_ports {seg_data[5]}]
set_property PACKAGE_PIN AA9 	[get_ports {seg_data[4]}]
set_property PACKAGE_PIN AB11	[get_ports {seg_data[3]}]
set_property PACKAGE_PIN AB10	[get_ports {seg_data[2]}]
set_property PACKAGE_PIN AB9 	[get_ports {seg_data[1]}]
set_property PACKAGE_PIN AA8 	[get_ports {seg_data[0]}]

###########################################################
# JB
###########################################################
set_property IOSTANDARD LVCMOS25 [get_ports {seg_com[*]}]
set_property PACKAGE_PIN W12 	[get_ports {seg_com[0]}]
set_property PACKAGE_PIN W11	[get_ports {seg_com[1]}]
set_property PACKAGE_PIN V10	[get_ports {seg_com[2]}]
set_property PACKAGE_PIN W8	[get_ports {seg_com[3]}]
set_property PACKAGE_PIN V12 	[get_ports {seg_com[4]}]
set_property PACKAGE_PIN W10 	[get_ports {seg_com[5]}]
