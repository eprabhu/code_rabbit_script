CREATE FUNCTION fn_jhu_unit_sortvalue_depth(p_sort VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE seg CHAR(3);

  -- sort_value length = 30 chars => 10 segments of 3 chars
  WHILE i <= 10 DO
    SET seg = SUBSTRING(p_sort, (i-1)*3 + 1, 3);
    IF seg = '000' THEN
      RETURN i - 1;
    END IF;
    SET i = i + 1;
  END WHILE;

  RETURN 10;
END 
