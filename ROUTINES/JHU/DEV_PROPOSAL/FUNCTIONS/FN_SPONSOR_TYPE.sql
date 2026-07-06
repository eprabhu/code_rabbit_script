CREATE FUNCTION `FN_SPONSOR_TYPE`(
AV_PROPOSAL_ID   int(10),
AV_SPONSOR_TYPE_CODE varchar(3)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE LI_COUNT int;
DECLARE li_code varchar(3);
                  
        
 SELECT COUNT(1) 
 INTO LI_COUNT 
 FROM eps_proposal 
 WHERE PROPOSAL_ID=AV_PROPOSAL_ID 
 AND SPONSOR_CODE 
 in(SELECT SPONSOR_CODE FROM SPONSOR WHERE  SPONSOR_TYPE_CODE = AV_SPONSOR_TYPE_CODE);
   
IF LI_COUNT > 0 THEN


                SELECT sponsor_type.sponsor_type_code
                INTO    li_code
                FROM    eps_proposal,
                        sponsor,
                        sponsor_type
                WHERE        eps_proposal.proposal_id = AV_PROPOSAL_ID
                AND        eps_proposal.sponsor_code = sponsor.SPONSOR_CODE                   
                AND        sponsor.sponsor_type_code = sponsor_type.sponsor_type_code;

                IF (li_code = AV_SPONSOR_TYPE_CODE) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
else 
return 'FALSE';
END IF;

END
