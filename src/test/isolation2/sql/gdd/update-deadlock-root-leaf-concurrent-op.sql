DROP TABLE IF EXISTS part_tbl;
CREATE TABLE part_tbl (a int, b int, c int) PARTITION BY RANGE(b) (START(1) END(2) EVERY(1));
INSERT INTO part_tbl SELECT i, 1, i FROM generate_series(1,10)i;

-- check gdd is enabled
show gp_enable_global_deadlock_detector;
1:BEGIN;
1:UPDATE part_tbl_1_prt_1 SET c = 9 WHERE c = 9;

2:BEGIN;
2:UPDATE part_tbl SET c = 1 WHERE c = 1;

-- the below update will wait to acquire the transaction lock to update the tuple
-- held by Session 2
1&:UPDATE part_tbl_1_prt_1 SET c = 1 WHERE c = 1;

-- the below update will wait to acquire the transaction lock to update the tuple
-- held by Session 1
2&:UPDATE part_tbl SET c = 9 WHERE c = 9;

1<:
2<:

-- since gdd is on, Session 2 will be cancelled.

1:ROLLBACK;
2:ROLLBACK;
DROP TABLE IF EXISTS part_tbl;
