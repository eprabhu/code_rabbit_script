-- `FN_CHECK_DUPLICATE_RANK`; 

CREATE FUNCTION `FN_CHECK_DUPLICATE_RANK`(
    AV_MODULE_ITEM_KEY INT,
    AV_MODULE_CODE INT
) RETURNS varchar(6) 
    DETERMINISTIC
BEGIN
    DECLARE LI_COUNT INT;
    IF AV_MODULE_CODE = 1 THEN
        SELECT COUNT(*) INTO LI_COUNT FROM award_research_areas 
        WHERE RESEARCH_RANK IS NOT NULL 
        AND AWARD_ID = AV_MODULE_ITEM_KEY
		group by RESEARCH_RANK having count(*) >1;
        IF (LI_COUNT is null) THEN
            select count(*) INTO LI_COUNT from award_research_areas t1
            inner join (select RESRCH_AREA_ID, RESEARCH_RANK, ROW_NUMBER() OVER(ORDER BY RESEARCH_RANK ASC) AS RANK_ORDER 
            from award_research_areas where AWARD_ID = AV_MODULE_ITEM_KEY) t2 on t1.RESRCH_AREA_ID = t2.RESRCH_AREA_ID
            where AWARD_ID = AV_MODULE_ITEM_KEY and t1.RESEARCH_RANK <> t2.RANK_ORDER order by t1.RESEARCH_RANK;
        END IF;
    ELSEIF AV_MODULE_CODE = 2 THEN
        SELECT COUNT(*) INTO LI_COUNT FROM proposal_resrch_areas 
        WHERE RESEARCH_RANK IS NOT NULL 
        AND proposal_id = AV_MODULE_ITEM_KEY
		group by RESEARCH_RANK having count(*) >1;
        IF (LI_COUNT is null) THEN
            select count(*) INTO LI_COUNT from proposal_resrch_areas t1
            inner join (select RESRCH_AREA_ID, RESEARCH_RANK, ROW_NUMBER() OVER(ORDER BY RESEARCH_RANK ASC) AS RANK_ORDER 
            from proposal_resrch_areas where proposal_id = AV_MODULE_ITEM_KEY) t2 on t1.RESRCH_AREA_ID = t2.RESRCH_AREA_ID
            where proposal_id = AV_MODULE_ITEM_KEY and t1.RESEARCH_RANK <> t2.RANK_ORDER order by t1.RESEARCH_RANK;
        END IF;
    ELSEIF AV_MODULE_CODE = 3 THEN
        SELECT COUNT(*) INTO LI_COUNT FROM eps_proposal_resrch_areas 
        WHERE RESEARCH_RANK IS NOT NULL 
        AND proposal_id = AV_MODULE_ITEM_KEY
		group by RESEARCH_RANK having count(*) >1;
        IF (LI_COUNT is null) THEN
            select count(*) INTO LI_COUNT from eps_proposal_resrch_areas t1
            inner join (select RESRCH_AREA_ID, RESEARCH_RANK, ROW_NUMBER() OVER(ORDER BY RESEARCH_RANK ASC) AS RANK_ORDER 
            from eps_proposal_resrch_areas where proposal_id = AV_MODULE_ITEM_KEY) t2 on t1.RESRCH_AREA_ID = t2.RESRCH_AREA_ID
            where proposal_id = AV_MODULE_ITEM_KEY and t1.RESEARCH_RANK <> t2.RANK_ORDER order by t1.RESEARCH_RANK;
        END IF;
    END IF;
    IF (LI_COUNT > 0) THEN
        RETURN 'TRUE';
    ELSE
        RETURN 'FALSE';
    END IF;
END
