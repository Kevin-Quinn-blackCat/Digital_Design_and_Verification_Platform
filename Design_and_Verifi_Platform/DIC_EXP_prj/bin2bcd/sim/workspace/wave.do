onerror {resume}
radix define MyDigitRadix {
    "7'h40" "V0",
    "7'h79" "V1",
    "7'h24" "V2",
    "7'h30" "V3",
    "7'h19" "V4",
    "7'h12" "V5",
    "7'h02" "V6",
    "7'h78" "V7",
    "7'h00" "V8",
    "7'h10" "V9",
    "7'h7F" "Empty" -color "cyan",
    -default hexadecimal
}
quietly virtual signal -install /top4_tb { /top4_tb/sig_out[6:0]} U
quietly virtual signal -install /top4_tb { /top4_tb/sig_out[13:7]} T
quietly virtual signal -install /top4_tb { (context /top4_tb )&{ sig_out[13:7] , sig_out[20:14] }} H
quietly virtual signal -install /top4_tb { /top4_tb/sig_out[27:21]} TH
quietly virtual signal -install /top4_tb { /top4_tb/sig_out[20:14]} H001
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} /top4_tb/sys_clk
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} /top4_tb/sys_rst_n
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} /top4_tb/data
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} -radix MyDigitRadix /top4_tb/TH
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} -label H -radix MyDigitRadix /top4_tb/H001
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} -radix MyDigitRadix /top4_tb/T
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} -radix MyDigitRadix /top4_tb/U
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} -color Gold -subitemconfig {{/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[15]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[14]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[13]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[12]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[11]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[10]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[9]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[8]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[7]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[6]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[5]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[4]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[3]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[2]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[1]} {-color Gold} {/top4_tb/bin2sig_inst/u_bcd_8421/bcd_out[0]} {-color Gold}} /top4_tb/bin2sig_inst/u_bcd_8421/bcd_out
add wave -noupdate -expand -label sim:/top4_tb/Group1 -group {Region: sim:/top4_tb} /top4_tb/sig_out
add wave -noupdate -expand -label sim:/top4_tb/bin2sig_inst/u_bcd_8421/Group1 -group {Region: sim:/top4_tb/bin2sig_inst/u_bcd_8421} /top4_tb/bin2sig_inst/u_bcd_8421/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2513 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 245
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {7455 ns}
