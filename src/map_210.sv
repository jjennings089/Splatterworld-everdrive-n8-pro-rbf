//************************************************************* Mapper 210 submapper 1 (Namco 175)
// Written for Splatterworld (English translation, 512K PRG / 256K CHR / 8K battery SRAM).
//
// $8000-$BFFF  CHR 1K bank registers, one per $800 ($8000=PPU $0000 ... $B800=PPU $1C00), 8 bits
// $C000-$C7FF  PRG-RAM write enable, bit 0 (1 = $6000-$7FFF writable; always readable)
// $E000-$E7FF  PRG 8K bank at $8000, bits 5:0
// $E800-$EFFF  PRG 8K bank at $A000, bits 5:0
// $F000-$F7FF  PRG 8K bank at $C000, bits 5:0
//              $E000-$FFFF fixed to the last 8K bank
// Mirroring is hardwired (taken from the ROM header). No IRQ, no expansion audio.
//
// The game writes bank numbers with bit 5 set and relies on all 6 bits reaching the ROM,
// and sets bits 7:6 of the PRG registers (N163-style flags), which Namco 175 ignores.
module map_210(

	input  MapIn  mai,
	output MapOut mao
);
//************************************************************* base header
	CpuBus cpu;
	PpuBus ppu;
	SysCfg cfg;
	SSTBus sst;
	assign cpu = mai.cpu;
	assign ppu = mai.ppu;
	assign cfg = mai.cfg;
	assign sst = mai.sst;

	MemCtrl prg;
	MemCtrl chr;
	MemCtrl srm;
	assign mao.prg = prg;
	assign mao.chr = chr;
	assign mao.srm = srm;

	assign prg.dati			= cpu.data;
	assign chr.dati			= ppu.data;
	assign srm.dati			= cpu.data;

	wire int_cpu_oe;
	wire int_ppu_oe;
	wire [7:0]int_cpu_data;
	wire [7:0]int_ppu_data;

	assign int_cpu_oe			= 0;
	assign int_ppu_oe			= 0;
	assign int_cpu_data		= 8'hff;
	assign int_ppu_data		= 8'hff;

	assign mao.map_cpu_oe	= int_cpu_oe | (srm.ce & srm.oe) | (prg.ce & prg.oe);
	assign mao.map_cpu_do	= int_cpu_oe ? int_cpu_data : srm.ce ? mai.srm_do : mai.prg_do;

	assign mao.map_ppu_oe	= int_ppu_oe | (chr.ce & chr.oe);
	assign mao.map_ppu_do	= int_ppu_oe ? int_ppu_data : mai.chr_do;
//************************************************************* configuration
	assign mao.prg_mask_off = 0;
	assign mao.chr_mask_off = 0;
	assign mao.srm_mask_off = 0;
	assign mao.mir_4sc		= 0;//enable support for 4-screen mirroring. for activation should be enabled in cfg.mir_4 also
	assign mao.bus_cf 		= 0;//bus conflicts
//************************************************************* save state regs read
	assign mao.sst_di[7:0] =
	sst.addr[7:3] == 0 	? chr_reg[sst.addr[2:0]] :
	sst.addr[7:0] == 8 	? prg_reg[0] :
	sst.addr[7:0] == 9 	? prg_reg[1] :
	sst.addr[7:0] == 10 	? prg_reg[2] :
	sst.addr[7:0] == 11 	? {7'd0, ram_on} :
	sst.addr[7:0] == 127 ? cfg.map_idx : 8'hff;
//************************************************************* mapper-controlled pins
	//reads ignore ram_on: the game polls its dialog-face flag at $69FE ($E35A) with RAM closed,
	//and open bus there ($69) leaves the face sprite on screen. writes stay gated to protect saves.
	assign srm.ce				= {cpu.addr[15:13], 13'd0} == 16'h6000 & (cpu.rw | ram_on);
	assign srm.oe				= cpu.rw;
	assign srm.we				= !cpu.rw;
	assign srm.addr[12:0]	= cpu.addr[12:0];

	assign prg.ce				= cpu.addr[15];
	assign prg.oe 				= cpu.rw;
	assign prg.we				= 0;
	assign prg.addr[12:0]	= cpu.addr[12:0];
	assign prg.addr[18:13]	=
	cpu.addr[14:13] == 0 ? prg_reg[0] :
	cpu.addr[14:13] == 1 ? prg_reg[1] :
	cpu.addr[14:13] == 2 ? prg_reg[2] : 6'b111111;//masked to rom size by the base system

	assign chr.ce 				= mao.ciram_ce;
	assign chr.oe 				= !ppu.oe;
	assign chr.we 				= cfg.chr_ram ? !ppu.we & mao.ciram_ce : 0;
	assign chr.addr[9:0]		= ppu.addr[9:0];
	assign chr.addr[17:10]	= chr_reg[ppu.addr[12:10]];

	//A10-Vmir, A11-Hmir
	assign mao.ciram_a10 	= cfg.mir_v ? ppu.addr[10] : ppu.addr[11];
	assign mao.ciram_ce 		= !ppu.addr[13];

	assign mao.irq				= 0;
//************************************************************* mapper implementation

	wire [4:0]reg_addr = cpu.addr[15:11];

	reg [7:0]chr_reg[8];
	reg [5:0]prg_reg[3];
	reg ram_on;

	always @(negedge cpu.m2)
	if(sst.act)
	begin
		if(sst.we_reg & sst.addr[7:3] == 0)chr_reg[sst.addr[2:0]] <= sst.dato;
		if(sst.we_reg & sst.addr[7:0] == 8)prg_reg[0]	<= sst.dato[5:0];
		if(sst.we_reg & sst.addr[7:0] == 9)prg_reg[1]	<= sst.dato[5:0];
		if(sst.we_reg & sst.addr[7:0] == 10)prg_reg[2]	<= sst.dato[5:0];
		if(sst.we_reg & sst.addr[7:0] == 11)ram_on		<= sst.dato[0];
	end
		else
	if(mai.map_rst)
	begin
		ram_on <= 0;
	end
		else
	if(!cpu.rw & cpu.addr[15])
	begin

		if(reg_addr[4:3] == 2'b10)chr_reg[reg_addr[2:0]] <= cpu.data;//$8000-$BFFF

		case(reg_addr)
			5'b11000:ram_on 		<= cpu.data[0];		//$C000
			5'b11100:prg_reg[0] 	<= cpu.data[5:0];	//$E000
			5'b11101:prg_reg[1] 	<= cpu.data[5:0];	//$E800
			5'b11110:prg_reg[2] 	<= cpu.data[5:0];	//$F000
		endcase

	end

endmodule
