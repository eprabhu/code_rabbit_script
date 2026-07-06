


CREATE PROCEDURE `GET_COI_DISCLOSURES_FOR_BANNER`( NO_OF_DAYS INT)
BEGIN
		SELECT 8                                           					AS MODULE_CODE,
         0                                                 					AS SUB_MODULE_CODE,
         T1.DISCLOSURE_ID                                  					AS MODULE_ITEM_KEY,
         0                                                 					AS SUB_MODULE_ITEM_KEY,
         GROUP_CONCAT(DISTINCT T1.PERSON_ID SEPARATOR ',') 					AS PERSON_ID,
         T1.EXPIRATION_DATE                                					AS EXPIRATION_DATE,
         'Your FCOIáDisclosure will expire in <b>{NO_OF_DAYS}</b> days'		AS USER_MESSAGE,
         '139' 																AS EXPIRING_MESSAGE_TYPE_CODE,
         CASE
    		WHEN T1.MODULE_CODE = 1  THEN T15.TITLE
    	  ELSE
    	  	T14.TITLE
  		  END 																AS DISCLOSURE_TITLE,
  		  UTC_TIMESTAMP() 													AS ARRIVAL_DATE,
         T1.UPDATE_USER                                    					AS UPDATE_USER,
         T1.UPDATE_TIMESTAMP                               					AS UPDATE_TIMESTAMP
  FROM   COI_DISCLOSURE T1 
  LEFT JOIN (SELECT TITLE, EXTERNAL_SYSTEM_REF_ID FROM COI_PROJECT_AWARD_V ) T15  ON T15.EXTERNAL_SYSTEM_REF_ID = T1.MODULE_ITEM_KEY
  LEFT JOIN (SELECT TITLE, EXTERNAL_SYSTEM_REF_ID FROM COI_PROJECT_PROPOSAL_V ) T14 ON T14.EXTERNAL_SYSTEM_REF_ID = T1.MODULE_ITEM_KEY
  WHERE  T1.VERSION_STATUS IN ('ACTIVE', 'PENDING')
  AND    DATE_SUB(T1.EXPIRATION_DATE, INTERVAL NO_OF_DAYS DAY) = CURRENT_DATE()
 
  UNION
  
  SELECT 24                                                					AS MODULE_CODE,
         0                                                 					AS SUB_MODULE_CODE,
         T3.TRAVEL_DISCLOSURE_ID                           					AS MODULE_ITEM_KEY,
         0                                                 					AS SUB_MODULE_ITEM_KEY,
         GROUP_CONCAT(DISTINCT T3.PERSON_ID SEPARATOR ',') 					AS PERSON_ID,
         T3.EXPIRATION_DATE                                					AS EXPIRATION_DATE,
         'Your TraveláDisclosure will expire in <b>{NO_OF_DAYS}</b> days'	AS USER_MESSAGE,
         '140' 																AS EXPIRING_MESSAGE_TYPE_CODE,
         T3.TRAVEL_TITLE 													AS DISCLOSURE_TITLE,
  		  UTC_TIMESTAMP() 													AS ARRIVAL_DATE, 
         T3.UPDATE_USER                                    					AS UPDATE_USER,
         T3.UPDATE_TIMESTAMP                               					AS UPDATE_TIMESTAMP
  FROM   COI_TRAVEL_DISCLOSURE T3
  WHERE  T3.VERSION_STATUS IN ('ACTIVE','PENDING')
  AND    DATE_SUB(T3.EXPIRATION_DATE, INTERVAL NO_OF_DAYS DAY) = CURRENT_DATE();
 END