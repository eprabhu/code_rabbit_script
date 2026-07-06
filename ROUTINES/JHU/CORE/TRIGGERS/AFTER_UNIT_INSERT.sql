CREATE TRIGGER AFTER_UNIT_INSERT
AFTER INSERT ON unit
FOR EACH ROW
BEGIN
  DECLARE v_parent_sort VARCHAR(50);
  DECLARE v_parent_depth INT;
  DECLARE v_next_seg INT;
  DECLARE v_seg_str CHAR(3);
  DECLARE v_prefix VARCHAR(50);
  DECLARE v_pad_len INT;
  DECLARE v_new_sort VARCHAR(50);

  /*
    ROOT insert: parent_unit_number = '000001'
    sort_value = next root sequence (001..n) + 9 * '000'
  */
  IF NEW.parent_unit_number = '000001' THEN

    SELECT COALESCE(MAX(CAST(SUBSTRING(jc.sort_value, 1, 3) AS UNSIGNED)), 0) + 1
      INTO v_next_seg
    FROM unit c
    JOIN jhu_unit jc ON jc.unit_number = c.unit_number
    WHERE c.parent_unit_number = '000001';

    SET v_seg_str  = LPAD(v_next_seg, 3, '0');
    SET v_new_sort = CONCAT(v_seg_str, REPEAT('000', 9));  -- 30 chars

  ELSE
    /*
      Non-root insert: build sort from parent's sort_value
    */
    SELECT j.sort_value
      INTO v_parent_sort
    FROM jhu_unit j
    WHERE j.unit_number = NEW.parent_unit_number
    LIMIT 1;

    IF v_parent_sort IS NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parent sort_value not found in jhu_unit (insert)';
    END IF;

    SET v_parent_depth = fn_jhu_unit_sortvalue_depth(v_parent_sort);

    SELECT COALESCE(
             MAX(CAST(SUBSTRING(jc.sort_value, v_parent_depth*3 + 1, 3) AS UNSIGNED)),
             0
           ) + 1
      INTO v_next_seg
    FROM unit c
    JOIN jhu_unit jc ON jc.unit_number = c.unit_number
    WHERE c.parent_unit_number = NEW.parent_unit_number;

    SET v_seg_str = LPAD(v_next_seg, 3, '0');
    SET v_prefix  = LEFT(v_parent_sort, v_parent_depth * 3);
    SET v_pad_len = 30 - (CHAR_LENGTH(v_prefix) + 3);

    SET v_new_sort = CONCAT(v_prefix, v_seg_str, REPEAT('0', v_pad_len));
  END IF;

  -- Upsert into jhu_unit
  INSERT INTO jhu_unit (unit_number, unit_name, sort_value)
  VALUES (NEW.unit_number, NEW.unit_name, v_new_sort)
  ON DUPLICATE KEY UPDATE
    unit_name  = VALUES(unit_name),
    sort_value = VALUES(sort_value);
END 
