CREATE TRIGGER AFTER_UNIT_UPDATE
AFTER UPDATE ON unit
FOR EACH ROW
main_block: BEGIN
  DECLARE v_old_parent VARCHAR(50);
  DECLARE v_new_parent VARCHAR(50);

  DECLARE v_old_unit_sort VARCHAR(50);
  DECLARE v_old_unit_depth INT;
  DECLARE v_old_unit_prefix VARCHAR(50);

  DECLARE v_new_parent_sort VARCHAR(50);
  DECLARE v_new_parent_depth INT;
  DECLARE v_new_prefix VARCHAR(50);

  DECLARE v_next_seg INT;
  DECLARE v_seg_str CHAR(3);

  -- For resequencing old parent siblings
  DECLARE v_old_parent_sort VARCHAR(50);
  DECLARE v_old_parent_depth INT;
  DECLARE v_old_parent_prefix VARCHAR(50);

  DECLARE v_child_unit VARCHAR(50);
  DECLARE v_child_sort VARCHAR(50);
  DECLARE v_old_child_prefix VARCHAR(50);
  DECLARE v_new_child_prefix VARCHAR(50);

  DECLARE v_counter INT DEFAULT 0;
  DECLARE done INT DEFAULT 0;

  DECLARE cur_children CURSOR FOR
    SELECT c.unit_number
    FROM unit c
    JOIN jhu_unit jc ON jc.unit_number = c.unit_number
    WHERE c.parent_unit_number = v_old_parent
      AND c.unit_number <> NEW.unit_number
    ORDER BY
      CASE
        WHEN v_old_parent = '000001'
          THEN CAST(SUBSTRING(jc.sort_value, 1, 3) AS UNSIGNED)
        ELSE
          CAST(SUBSTRING(jc.sort_value, v_old_parent_depth*3 + 1, 3) AS UNSIGNED)
      END;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  SET v_old_parent = OLD.parent_unit_number;
  SET v_new_parent = NEW.parent_unit_number;

  -- Always sync unit_name to jhu_unit
  INSERT INTO jhu_unit (unit_number, unit_name, sort_value)
  VALUES (NEW.unit_number, NEW.unit_name, NULL)
  ON DUPLICATE KEY UPDATE unit_name = VALUES(unit_name);

  -- If parent didn't change, stop here
  IF v_old_parent = v_new_parent THEN
    LEAVE main_block;
  END IF;

  /*
    1) Read current (old) sort_value of the moved unit (before we update subtree)
  */
  SELECT j.sort_value
    INTO v_old_unit_sort
  FROM jhu_unit j
  WHERE j.unit_number = NEW.unit_number
  LIMIT 1;

  IF v_old_unit_sort IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'sort_value missing for moved unit in jhu_unit';
  END IF;

  SET v_old_unit_depth  = fn_jhu_unit_sortvalue_depth(v_old_unit_sort);
  SET v_old_unit_prefix = LEFT(v_old_unit_sort, v_old_unit_depth * 3);

  /*
    2) Compute NEW prefix for moved unit based on NEW parent
  */
  IF v_new_parent = '000001' THEN
    -- next root sequence (exclude moved unit)
    SELECT COALESCE(MAX(CAST(SUBSTRING(jc.sort_value, 1, 3) AS UNSIGNED)), 0) + 1
      INTO v_next_seg
    FROM unit c
    JOIN jhu_unit jc ON jc.unit_number = c.unit_number
    WHERE c.parent_unit_number = '000001'
      AND c.unit_number <> NEW.unit_number;

    SET v_seg_str   = LPAD(v_next_seg, 3, '0');
    SET v_new_prefix = v_seg_str; -- root prefix is only first segment
  ELSE
    SELECT j.sort_value
      INTO v_new_parent_sort
    FROM jhu_unit j
    WHERE j.unit_number = v_new_parent
    LIMIT 1;

    IF v_new_parent_sort IS NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New parent sort_value not found in jhu_unit';
    END IF;

    SET v_new_parent_depth = fn_jhu_unit_sortvalue_depth(v_new_parent_sort);

    -- next sibling segment under the new parent (exclude moved unit)
    SELECT COALESCE(
             MAX(CAST(SUBSTRING(jc.sort_value, v_new_parent_depth*3 + 1, 3) AS UNSIGNED)),
             0
           ) + 1
      INTO v_next_seg
    FROM unit c
    JOIN jhu_unit jc ON jc.unit_number = c.unit_number
    WHERE c.parent_unit_number = v_new_parent
      AND c.unit_number <> NEW.unit_number;

    SET v_seg_str    = LPAD(v_next_seg, 3, '0');
    SET v_new_prefix = CONCAT(LEFT(v_new_parent_sort, v_new_parent_depth * 3), v_seg_str);
  END IF;

  /*
    3) Update moved unit + ALL descendants by prefix replacement
  */
  UPDATE jhu_unit j
  SET j.sort_value = CONCAT(
        v_new_prefix,
        SUBSTRING(j.sort_value, CHAR_LENGTH(v_old_unit_prefix) + 1)
      )
  WHERE j.sort_value LIKE CONCAT(v_old_unit_prefix, '%');

  /*
    4) Resequence OLD parent's remaining children (close gaps)
       Works for old parent = root ('10000') and non-root.
  */
  IF v_old_parent = '000001' THEN
    SET v_old_parent_depth  = 0;
    SET v_old_parent_prefix = ''; -- root has no prefix
  ELSE
    SELECT j.sort_value
      INTO v_old_parent_sort
    FROM jhu_unit j
    WHERE j.unit_number = v_old_parent
    LIMIT 1;

    IF v_old_parent_sort IS NULL THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Old parent sort_value not found in jhu_unit';
    END IF;

    SET v_old_parent_depth  = fn_jhu_unit_sortvalue_depth(v_old_parent_sort);
    SET v_old_parent_prefix = LEFT(v_old_parent_sort, v_old_parent_depth * 3);
  END IF;

  SET v_counter = 0;
  SET done = 0;

  OPEN cur_children;

  children_loop: LOOP
    FETCH cur_children INTO v_child_unit;
    IF done = 1 THEN
      LEAVE children_loop;
    END IF;

    SET v_counter = v_counter + 1;

    SELECT j.sort_value
      INTO v_child_sort
    FROM jhu_unit j
    WHERE j.unit_number = v_child_unit
    LIMIT 1;

    IF v_old_parent = '000001' THEN
      -- old prefix: first 3 chars
      SET v_old_child_prefix = LEFT(v_child_sort, 3);
      SET v_new_child_prefix = LPAD(v_counter, 3, '0');
    ELSE
      -- old prefix: parent_depth+1 segments
      SET v_old_child_prefix = LEFT(v_child_sort, (v_old_parent_depth + 1) * 3);
      SET v_new_child_prefix = CONCAT(v_old_parent_prefix, LPAD(v_counter, 3, '0'));
    END IF;

    -- If segment changes, update the child's subtree by prefix replacement
    IF v_new_child_prefix <> v_old_child_prefix THEN
      UPDATE jhu_unit j2
      SET j2.sort_value = CONCAT(
            v_new_child_prefix,
            SUBSTRING(j2.sort_value, CHAR_LENGTH(v_old_child_prefix) + 1)
          )
      WHERE j2.sort_value LIKE CONCAT(v_old_child_prefix, '%');
    END IF;

  END LOOP;

  CLOSE cur_children;

END main_block
