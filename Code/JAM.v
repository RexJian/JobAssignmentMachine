
module JAM (
input
CLK,
input
RST,
output reg [2:0] W,
output reg [2:0] J,
input
[6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg
Valid );

reg [2:0] current_state, next_state; 
reg [2:0] W_Seq [0:7];
reg [2:0] work order [0:7];
reg [10:0] sum;
reg [3:0] counter;
reg [2:0] sort_idx, min_idx, idx_tmp, head_idx, tail_idx, w_j_idx;
reg delay_one_cycle;

parameter RST_STATE = 0, UPDATE_SUM = 1, FIND_CHANGE_IDX = 2, FIND_MIN_IDX = 3, CHANGE_POS = 4, REVERSE = 5, END_STATE = 6;

always @(*) begin
	case (current state)	
		RST_STATE: next_state = RST ? RST STATE UPDATE SUM;
		UPDATE SUM: next_state=counter == 4'd10 ? FIND CHANGE IDX UPDATE SUM;
		FIND_CHANGE_IDX: next_state= (sort_idx==3'd0 && work_order [sort_idx]> work_order [sort_idx+3'd1]) ? END_STATE : (work_order [sort_idx]> work_order [sort_idx+3'd1] ? FIND_CHANGE_IDX : FIND_MIN_IDX);
		next_state = delay_one_cycle ? CHANGE_POS : FIND_MIN_IDX;
		CHANGE POS: next_state = REVERSE;
		REVERSE: next_state= (head_idx >= tail_idx || head_idx == tail_idx 3'dl)? UPDATE_SUM: REVERSE; 
		END_STATE: next_state = RST ? RST_STATE: END_STATE;
		default: next_state = RST_STATE;
	endcase
end

always @(posedge CLK or posedge RST) 
	current_state <= next_state;

always @(posedge CLK or posedge RST) begin
	if (RST)
		W <= 3' d0;
	else
		W <= W_Seq[w_j_idx];
end


always @(posedge CLK or posedge RST) begin
	if (RST)
		counter <= 4'd0;
	else if (current_state == UPDATE_SUM) 
		counter <= counter+ 4'd1;
	else if (next_state== UPDATE_SUM)
		counter <= 4'd0;
	else
		counter <= counter;
end

always @(posedge CLK or posedge RST) begin
	if (RST)
		J <= 3'd0;
	else
		J <= work_order[w_j_idx];
end

always @(posedge CLK or posedge RST) begin if (RST)
	if(RST)
		w_j_idx <= 3'd0;
	else if (current_state== UPDATE_SUM) begin 
		if (w_j_idx == 3'd7) 
			w_j_idx <= w_j_idx;
		else
			w_j_idx <= w_j_idx + 3'd1;
	end
	else if (next_state== UPDATE_SUM)
		w_j_idx <= 3'do;
	else
		w_j_idx <= w_j_idx;
end

always @(posedge CLK or posedge RST) begin
	W_Seq[0] <= 3'd0;
	W_Seq[1] <= 3'd1;
	W_Seq[2] <= 3'd2;
	W_Seq[3] <= 3'd3;
	W_Seq[4] <= 3'd4;
	W_Seq[5] <= 3'd5;
	W_Seq[6] <= 3'd6;
	W_Seq[7] <= 3'd7;
end


always @(posedge CLK or posedge RST) begin
	if (RST)
		sum <= 11'd0;
	else if (current_state== UPDATE_SUM && counter >= 4'd2 && counter <= 4'd9 ) 
		sum <= sum + {{4{1'b0}}, Cost};
	else
		sum <= 11'd0;
	end


always @(posedge CLK or posedge RST) begin
	if (RST)
		MatchCount <= 4'do;
	else if (current_state== UPDATE_SUM && counter == 4'd10) begin
		if (sum == MinCost)
			MatchCount <<= MatchCount + 4'd1;
		else if (sum < MinCost)
			MatchCount <= 4'd1;
		else
			MatchCount <= MatchCount;
end

always @(posedge CLK or posedge RST) begin
	if (RST)
		MinCost <= 10'd1023;
	else if (current_state== UPDATE_SUM && counter == 4'd10 && sum < MinCost)
		MinCost <= sum[9:0];
	else
		MinCost <= MinCost;
end


always @(posedge CLK or posedge RST) begin
	if (RST)
		sort_idx <= 3'd6;
	else if (current_state== FIND_CHANGE_IDX) begin
		if (work_order[sort_idx] < work_order[sort_idx+3'd1] || sort_idx == 3'd0)
			 sort_idx <= sort_idx;
		else
			sort_idx <= sort_idx - 3'd1;
		end
	else if (current_state== FIND_MIN_IDX)
		sort_idx <= sort_idx;
	else
		sort_idx <= 3'd6;
end

always @(posedge CLK or posedge RST) begin
	if (RST)
		idx_tmp <= 3'd0;
	else if (current_state== FIND_CHANGE_IDX) begin
		if (work_order[sort_idx] < work_order [sort_idx+3'd1] || sort_idx == 3'd0) 
			idx_tmp <= sort_idx + 3'd1;
		else
			idx_tmp <= sort_idx;
		end
		else if (current_state== FIND_MIN_IDX) begin
			if(idx_tmp < 3'd7)
				idx_tmp <= idx_tmp + 3'd1;
			else
				idx_tmp <= idx_tmp;
		end
	else
		idx_tmp <= idx_tmp;
	end

always @(posedge CLK or posedge RST) begin
	if (RST)
		delay_one_cycle <= 1'b0;
	else if(idx_tmp == 3'd7)
		delay_one_cycle <=1'b1;
	else
		delay_one_cycle <=1'b0;
end


always @(posedge CLK or posedge RST) begin
	if (RST)
		min_idx <= 3'd0;
	else if (current_state== FIND_CHANGE_IDX) begin
		if (work_order[sort_idx] < work_order [sort_idx+3'd1] || sort_idx == 3'd0)
			min_idx <= sort_idx + 3'd1;
		else
			min_idx <= sort_idx;
	end
	else if (current_state== FIND_MIN_IDX) begin
		if (work_order [sort_idx] <work_order [min_idx] && work_order [sort_idx] <work_order[idx_tmp]) begin if (work_order [min_idx] >= work_order[idx_tmp])
			min_idx <= idx_tmp;
		else
			min_idx <= min_idx;
		end
	else
		min_idx <= min_idx;
end

always @(posedge CLK or posedge RST) begin
	if (RST)
		head_idx <= 3'd1;
	else if (current_state== REVERSE)
		head_idx <= head_idx + 3'dl;
	else
		head_idx <= sort_idx + 3'd1;
end


always @(posedge CLK or posedge RST) begin
	if (RST)
		tail idx <= 3'd7;
	else if (current_state== REVERSE)
		tail_idx <= tail_idx 3'dl;
	else
		tail_idx <= 3'd7;
end


always @(posedge CLK or posedge RST) begin
	if (RST) begin
		work_order[0] <= 3'd0;
		work_order[1] <= 3'd1;
		work_order[2] <= 3'd2;
		work_order[3] <= 3'd3;
		work_order[4] <= 3'd4;
		work_order[5] <= 3'd5;
		work_order[6] <= 3'd6; 
		work_order[7] <= 3'd7;
	end

	else if (current_state== CHANGE_POS) begin
		work_order[min_idx] <= work_order [sort_idx]; 
		work_order[sort_idx] <= work_order[min_idx];
	end

	else if (current_state== REVERSE) begin
		work_order[head_idx] <= work_order [tail_idx]; 
		work_order [tail_idx] <= work_order[head_idx];
	end 
		work_order <= work_order;
	else
end

assign Valid = (current_state == END STATE);
endmodule
