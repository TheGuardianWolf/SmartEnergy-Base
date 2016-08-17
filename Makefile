all: BaseStation.qpf
	quartus_sh --flow compile BaseStation.qpf
symbols: BaseStation.qpf
	quartus_map --read_settings_files=on --write_settings_files=off BaseStation -c BaseStation --generate_symbol="BaseStationDatapath.vhd"
	quartus_map --read_settings_files=on --write_settings_files=off BaseStation -c BaseStation --generate_symbol="BaseStationFSM.vhd"
