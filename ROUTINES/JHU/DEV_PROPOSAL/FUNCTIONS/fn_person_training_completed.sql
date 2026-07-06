CREATE FUNCTION `fn_person_training_completed`(
  av_person_id VARCHAR(40),
  av_proposal_id INT(11)
) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

  DECLARE person_count1 INT;
  DECLARE person_count2 INT;
  DECLARE training_status VARCHAR(20);

  SELECT COUNT(t1.person_training_id) 
  INTO   person_count1
  FROM   person_training t1
  WHERE  t1.person_id = av_person_id
  AND    t1.training_code = '20' 
  AND    t1.date_acknowledged >= DATE_SUB(NOW(),INTERVAL 5 YEAR); 

  SELECT COUNT(t1.person_training_id) 
  INTO   person_count2 
  FROM   person_training t1 
  WHERE  t1.person_id = av_person_id
  AND    t1.training_code = '4'
  AND    t1.date_acknowledged >= DATE_SUB(NOW(),INTERVAL 4 YEAR);  


  IF (person_count1 > 0 AND person_count2 > 0) 
  THEN
    SET training_status = 'Completed';
  ELSE 
    SET training_status = 'Pending';
  END IF;

  RETURN training_status;

END
