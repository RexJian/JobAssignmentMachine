
`timescale 1ns/1ps
`include "JAM.v"
`define CYCLE
`define End_CYCLE
`define PAT
10.0
10000000
"cost_rom"
module testfixture();

integer fd;
integer charcount;
string line;
integer freturn;
integer patnum;
reg CLK = 0; 
wire Valid; 
reg RST = 1; 
wire [2:0] W; 
wire [2:0] J; 
reg [6:0] Cost;
wire [3:0] MatchCount;
wire [9:0] MinCost;

JAM U_JAM(. CLK (CLK),
	  .RST (RST),
	  .W(W),
	  .J(J),
	  .Cost(Cost),
	  .MatchCount (MatchCount),
	  .MinCost (MinCost),
	  . Valid (Valid));
always begin #(`CYCLE/2) CLK = ~CLK; end

initial begin
	$fsdbDumpfile("JAM.fsdb");
	$fsdbDumpvars();
	$fsdbDumpMDA;
end

initial begin
	$display("***********************");
	$display("** Simulation Start  **");
	$display("***********************");
	@(posedge CLK); #2 RST = 1'b1;
	#(`CYCLE*2);
	@(posedge CLK); #2 RST=1'b0;
end


reg [30:0] cycle=0;
reg [6:0] costrom [0:63];
always @(posedge CLK) begin
	cycle-cycle+1;
	if (cycle > End_CYCLE) begin 
		$display("*************")
		$display ("**Failed waiting Valid signal, Simulation STOP at cycle %d **", cycle); 
		$display(" If needed, You can increase End_CYCLE value in tp.v);
		$display ("************")
		$fclose(fd);
		$finish;
	end
end
integer key_value;
string key;
integer v0, v1, v2, v3, v4, v5, v6, v7;
integer worker = -1;
integer i;
integer j;
reg [3:0] goldMatchCount;
reg [8:0] goldMinCost;
initial begin	
	fd = $fopen('PAT, "r"); 
	if (fd=0) begin
		$display ("pattern handle null"); 
		$finish;
	end
	
	else begin
		charcount = $fgets (line, fd);
		while (charcount > 0) begin: READ_PATTERN
			while((line == "\n") || (line.substr(1, 2) == "//") charcount = $fgets (line, fd);
			if (charcount == 0) disable READ_PATTERN ; 
			if(line.substr(0, 6) == "pattern") begin 
				freturn= $sscanf(line, "pattern %d", patnum);
			end
			else begin
				if (patnum == 1) begin
					freturn = $sscanf(line, "%s %d", key, key_value); 
					if (key == "min_cost") begin
						goldMinCost = key_value;
					end
					else if (key == "match_count") begin
						goldMatchCount = key_value;
					end
					else begin
						freturn = $sscanf(line,"%d %d %d %d %d %d %d %d",v0, v1, v2, v3, v4, v5, v6,v7); 
						if (freturn == 0) $display ("unknow line: -%%s-", line);
						else begin
							if (worker ==-1) begin
								$display("--------------- Cost Table --------------------------");
								$display("Jobs      0     1     2     3     4     5     6     7");
							end

							worker = worker + 1;
							$display("worker%d: %3d %3d %3d %3d %3d %3d %3d %3d", worker, v0, v1, v2, v3, v4, v5, v6,v7);
	
							costrom [worker*8]=v0;
							costrom [worker*8+1]=v1;
							costrom [worker*8+2]=v2;
							costrom [worker*8+3]=v3;
							costrom [worker*8+4]=v4; 
							costrom [worker*8+5]=v5; 
							costrom [worker*8+6]=v6;
							costrom [worker*8+7]=v7;
						end
					end
				end
			end
			charcount = $fgets (line, fd);
		end
	end
end


reg wait_valid; 
reg [2:0] W_s;
reg [2:0] J_s;
assign Cost-costrom [8*W_s+J_s]; 

always @(posedge CLK ) begin
	W_s <= #1 W;
	Js <= #1 J;
end

always @(posedge CLK ) begin 
	if (RST) begin
		wait_valid=1;
	end
	else begin
		if (cycle [20:0] == 20'd0) begin
			$display("cycle: %d, still running...", cycle);
		end
		if (wait_valid == 1) begin
			if (Valid ==1) begin
				wait_valid=0;
				$display("------------------------------------------------------------------------------");
				$display("Get Valid at cycle: %d", cycle);
				$display("receive MinCost/MatchCount= %d/%d, golden MinCost/MatchCount= %d/%d", MinCost, MatchCount, goldMinCost, goldMatchCount); 
				$display("------------------------------------------------------------------------------");
				$display("********************************");
				if((goldMatchCount == MatchCount) && (goldMinCost == MinCost)) begin 
					$display("** FUNCTION CORRECT **");
				end
				else begin
					$display("**FUNCTION WRONG!!**");
				end
				$display("*******************************");
				$finish;	
			end
		end
	end
end
endendmodule