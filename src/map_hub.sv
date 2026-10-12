module map_hub(
	input  MapIn mai,
	output MapOut mao
);


	assign mao =
	mai.cfg.map_idx == 210 ? map_out_210 :
	map_out_nom;


	MapOut map_out_nom;
	map_nom mnom(mai, map_out_nom);

	MapOut map_out_210;
	map_210 m210(mai, map_out_210);

endmodule
