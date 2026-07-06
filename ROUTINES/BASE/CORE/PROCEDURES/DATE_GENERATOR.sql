CREATE PROCEDURE `DATE_GENERATOR`(
    IN PARA_START_DATE DATE,
    IN PARA_END_DATE DATE,
    IN PARA_FREQ_MONTHS INT,
    IN PARA_FREQ_DAYS INT
)
BEGIN
DECLARE LD_CURRENT_DATE DATE;
DECLARE LI_CURRENT_INDEX int;
SET LI_CURRENT_INDEX = 0;
SET LD_CURRENT_DATE = PARA_START_DATE;

/*
   Description:
   This procedure generates a series of dates between `PARA_START_DATE` and `PARA_END_DATE` 
   based on a specified frequency. The dates are generated according to the following parameters:
   
   Parameters:
   - `PARA_START_DATE` (DATE): The starting date from which the generation begins.
   - `PARA_END_DATE` (DATE): The ending date up to which the dates are generated.
   - `PARA_FREQ_MONTHS` (INT): Specifies the frequency in months. Dates are generated every 'n' months.
   - `PARA_FREQ_DAYS` (INT): Specifies the frequency in days. Dates are generated every 'n' days.
   
   Logic:
   - If both PARA_FREQ_MONTHS and PARA_FREQ_DAYS are NULL or zero, the procedure inserts only the PARA_START_DATE.
   - If PARA_FREQ_MONTHS or PARA_FREQ_DAYS is negative, it adjusts LD_CURRENT_DATE backward from PARA_START_DATE.
   - If the frequency values are positive, the procedure uses WHILE loops to generate dates until LD_CURRENT_DATE exceeds PARA_END_DATE.
   
   Note:
   - PARA_START_DATE only be included in generated due date for frequency null or zero.
   - Make sure to provide either a valid `PARA_FREQ_DAYS` or `PARA_FREQ_MONTHS` to control the frequency.
   - If both parameters are provided, the procedure prioritizes `PARA_FREQ_DAYS`.
   - If PARA_FREQ_DAYS and PARA_FREQ_MONTHS is null or zero, then PARA_START_DATE will be the generated due date.
   - If PARA_FREQ_DAYS and PARA_FREQ_MONTHS is neagtive, then one due date will be generated from PARA_START_DATE with negative frequency.
   - Use temp_tracking table to collect the generated due date "CREATE TEMPORARY TABLE temp_tracking (DUE_DATE DATE);"
   - Drop the table after use "DROP TEMPORARY TABLE IF EXISTS temp_tracking;"

   Author - Vishnu BH
*/

    IF PARA_START_DATE > PARA_END_DATE THEN
    SET PARA_END_DATE =  PARA_START_DATE;
    END IF;


	IF (PARA_FREQ_MONTHS IS NULL OR PARA_FREQ_MONTHS = 0 ) AND (PARA_FREQ_DAYS IS NULL OR PARA_FREQ_DAYS = 0) THEN 
        INSERT INTO temp_tracking (DUE_DATE) VALUES (PARA_START_DATE);
	ELSEIF PARA_FREQ_MONTHS IS NOT NULL AND PARA_FREQ_MONTHS < 0 THEN
	    SET LD_CURRENT_DATE = DATE_ADD(PARA_START_DATE, INTERVAL PARA_FREQ_MONTHS MONTH);
        INSERT INTO temp_tracking (DUE_DATE) VALUES (LD_CURRENT_DATE);
	ELSEIF PARA_FREQ_DAYS IS NOT NULL AND PARA_FREQ_DAYS < 0 THEN 
        SET LD_CURRENT_DATE = DATE_ADD(PARA_START_DATE, INTERVAL PARA_FREQ_DAYS DAY);
        INSERT INTO temp_tracking (DUE_DATE) VALUES (LD_CURRENT_DATE); 
   ELSEIF PARA_FREQ_MONTHS IS NOT NULL AND PARA_FREQ_MONTHS != 0 AND PARA_FREQ_MONTHS > 0 THEN
        WHILE LD_CURRENT_DATE <= PARA_END_DATE DO
            SET LI_CURRENT_INDEX = LI_CURRENT_INDEX + PARA_FREQ_MONTHS;
            SET LD_CURRENT_DATE = DATE_ADD(PARA_START_DATE, INTERVAL LI_CURRENT_INDEX MONTH);
            IF LD_CURRENT_DATE <= PARA_END_DATE THEN
            INSERT INTO temp_tracking (DUE_DATE) VALUES (LD_CURRENT_DATE);
            END IF;
        END WHILE;
    ELSEIF PARA_FREQ_DAYS IS NOT NULL AND PARA_FREQ_DAYS != 0 AND PARA_FREQ_DAYS > 0 THEN
        WHILE LD_CURRENT_DATE <= PARA_END_DATE DO
            SET LI_CURRENT_INDEX = LI_CURRENT_INDEX + PARA_FREQ_DAYS;
            SET LD_CURRENT_DATE = DATE_ADD(PARA_START_DATE, INTERVAL LI_CURRENT_INDEX DAY);
            IF LD_CURRENT_DATE <= PARA_END_DATE THEN
            INSERT INTO temp_tracking (DUE_DATE) VALUES (LD_CURRENT_DATE); 
            END IF;
        END WHILE;
    END IF;

END
