# Job Assignment Machine
&nbsp;&nbsp;This lab focuses on optimizing job assignments through the use of the lexicographical algorithm, which examines all potential combinations for assigning workers to tasks, with the goal of reducing the overall cost. Below are the steps:  
1. Calculate the total cost for every possible combination of assignments.
2. Determine the lowest possible cost among all combinations.
3. Calculate the number of combinations that lead to the lowest cost.

## Specification

| Signal Name | I/O | Width | Sample Description |
| :----: | :----: | :----: | :----|
| CLK | I | 1 | Clock Signal |
| RST | I | 1 | Reset Signal. Restore to 2 low cycles after pull up |
| W | O | 3 | Assign to acquire the cost information for the W-th worker, 0 &le; W &le; 7 |
| J | O | 3 | Assign to acquire the J-th cost informationl, 0 &le; J &le; 7 |
| Cost | I | 7 | The cost value corresponds to the assignment of workers and Jobs. When a worker is assigned to a job, the cost is determined by the value associated with that particular worker and Job combination. The cost is represented as an unsigned integer ranging from 0 to 100. |
| MatchCount | O | 4 | The number of combinations with minimum cost |
| MinCost | O | 10 | The value of the minimum total job cost. MinCost is an unsigned integer. |
| Valid | O | 1 | When Valid is high, the MatchCount and MinCost represent valid output, then the testbench finishes the simulation in the next cycle. |
