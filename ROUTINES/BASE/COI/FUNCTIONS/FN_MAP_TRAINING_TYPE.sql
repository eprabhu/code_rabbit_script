

CREATE FUNCTION `FN_MAP_TRAINING_TYPE`( 
LS_TRAINING_GROUP VARCHAR(4000) ,  
LI_STAGE_NUMBER INT) RETURNS int
    DETERMINISTIC
BEGIN

 DECLARE LS_PERSON_ID VARCHAR(40);
 DECLARE LI_TRAINING_CODE  DECIMAL(18,6);

  IF (LI_STAGE_NUMBER = 1) then

    if (upper(LS_TRAINING_GROUP) = 'BIOMEDICAL RESEARCH INVESTIGATORS' ) then
      set LI_TRAINING_CODE = 15;
    elseif (upper(LS_TRAINING_GROUP) = 'SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') then
      set LI_TRAINING_CODE = 14;
    elseif (upper(LS_TRAINING_GROUP) = 'IRB-SOCIAL-BEHAVIORAL-FRENCH') then
      set LI_TRAINING_CODE = 14;
    elseif (upper(LS_TRAINING_GROUP) = 'DATA OR SPECIMENS ONLY RESEARCH') then
      set LI_TRAINING_CODE = 17;
    elseif (upper(LS_TRAINING_GROUP) = 'IRB MEMBERS') then
      set LI_TRAINING_CODE = 26;
    elseif (upper(LS_TRAINING_GROUP) = 'HUMANITIES RESPONSIBLE CONDUCT OF RESEARCH') then
       set LI_TRAINING_CODE = 140;
    elseif (upper(LS_TRAINING_GROUP) = 'SOCIAL AND BEHAVIORAL RESPONSIBLE CONDUCT OF RESEARCH') then
       set LI_TRAINING_CODE = 141;
    elseif (upper(LS_TRAINING_GROUP) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ENGINEERS') then
        set LI_TRAINING_CODE = 142;
    elseif (upper(LS_TRAINING_GROUP) = 'PHYSICAL SCIENCE RESPONSIBLE CONDUCT OF RESEARCH') then
        set LI_TRAINING_CODE = 143;
    elseif (upper(LS_TRAINING_GROUP) = 'BIOMEDICAL RESPONSIBLE CONDUCT OF RESEARCH') then
        set LI_TRAINING_CODE = 144;
    elseif (upper(LS_TRAINING_GROUP) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ADMINISTRATORS') then
        set LI_TRAINING_CODE = 145;
    elseif (upper(LS_TRAINING_GROUP) = 'RECR REFRESHER') then
        set LI_TRAINING_CODE = 151;
    elseif (upper(LS_TRAINING_GROUP) = 'NIH/PHS CONFLICT OF INTEREST COURSE') then
        set LI_TRAINING_CODE = 54;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH THE IACUC') then
        set LI_TRAINING_CODE = 57;
    elseif (upper(LS_TRAINING_GROUP) = 'ASEPTIC SURGERY') then
        set LI_TRAINING_CODE = 59;
    elseif (upper(LS_TRAINING_GROUP) = 'ANTIBODY PRODUCTION IN ANIMALS') then
        set LI_TRAINING_CODE = 60;
    elseif (upper(LS_TRAINING_GROUP) = 'ESSENTIALS FOR IACUC MEMBERS') then
        set LI_TRAINING_CODE = 61;
    elseif (upper(LS_TRAINING_GROUP) = 'IACUC COMMUNITY MEMBER') then
        set LI_TRAINING_CODE = 62;
    elseif (upper(LS_TRAINING_GROUP) = 'REDUCING PAIN AND DISTRESS IN LABORATORY MICE AND RATS') then
        set LI_TRAINING_CODE = 63;
    elseif (upper(LS_TRAINING_GROUP) = 'WILDLIFE RESEARCH') then
        set LI_TRAINING_CODE = 64;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH AMPHIBIANS IN RESEARCH SETTINGS.') then
        set LI_TRAINING_CODE = 65;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH CATS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 66;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH DOGS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 67;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH FERRETS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 68;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH FISH IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 69;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH GERBILS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 70;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH GUINEA PIGS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 71;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH HAMSTERS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 72;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH MICE IN RESEARCH') then
        set LI_TRAINING_CODE = 73;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH NON-HUMAN PRIMATES IN RESEARCH SETTINGS') then
       set LI_TRAINING_CODE = 74;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH RABBITS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 75;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH RATS IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 76;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH SWINE IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 77;
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH ZEBRAFISH (DANIO RERIO) IN RESEARCH SETTINGS') then
        set LI_TRAINING_CODE = 78;
    elseif (upper(LS_TRAINING_GROUP) = 'POST-APPROVAL MONITORING (PAM)') then
       set LI_TRAINING_CODE = 79;
    elseif (upper(LS_TRAINING_GROUP) = 'MIT EXPORT CONTROL') then
       set LI_TRAINING_CODE = 90;   
    elseif (upper(trim(substr(LS_TRAINING_GROUP,7))) = upper(substr('GCP ¿ Social and Behavioral Research Best Practices for Clinical Research',7))) then
       set LI_TRAINING_CODE = 100;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Investigations of Devices')) then
       set LI_TRAINING_CODE = 102;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Trials with Investigational Drugs and Biologics (ICH Focus)')) then
       set LI_TRAINING_CODE = 104;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Trials with Investigational Drugs and Medical Devices (U.S. FDA Focus)')) then
       set LI_TRAINING_CODE = 106;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('Undue Foreign Influence: Risks and Mitigations')) then
       set LI_TRAINING_CODE = 120;

    end if;

  ELSE

    if (upper(LS_TRAINING_GROUP) = 'BIOMEDICAL RESEARCH INVESTIGATORS' ) then
      set LI_TRAINING_CODE = 23;
    elseif (upper(LS_TRAINING_GROUP) = 'SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') then
      set LI_TRAINING_CODE = 25;
    elseif (upper(LS_TRAINING_GROUP)= 'DATA OR SPECIMENS ONLY RESEARCH') then
      set LI_TRAINING_CODE = 24;
    elseif (upper(LS_TRAINING_GROUP) = 'IRB MEMBERS') then
      set LI_TRAINING_CODE = 27;
    /*elseif (upper(LS_TRAINING_GROUP )= 'HUMANITIES RESPONSIBLE CONDUCT OF RESEARCH') then
       LI_TRAINING_CODE = 146;
    elseif (upper(LS_TRAINING_GROUP )= 'SOCIAL AND BEHAVIORAL RESPONSIBLE CONDUCT OF RESEARCH') then
       LI_TRAINING_CODE = 147;
    elseif (upper(LS_TRAINING_GROUP) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ENGINEERS') then
        LI_TRAINING_CODE = 148;
    elseif (upper(LS_TRAINING_GROUP) = 'PHYSICAL SCIENCE RESPONSIBLE CONDUCT OF RESEARCH') then
        LI_TRAINING_CODE = 149;
    elseif (upper(LS_TRAINING_GROUP) = 'BIOMEDICAL RESPONSIBLE CONDUCT OF RESEARCH') then
        LI_TRAINING_CODE = 150;
    elseif (upper(LS_TRAINING_GROUP) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ADMINISTRATORS') then
        LI_TRAINING_CODE = 151;*/
    elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH THE IACUC - REFRESHER') then
        set LI_TRAINING_CODE =58;
    --  elseif (upper(LS_TRAINING_GROUP) = 'WORKING WITH CATS IN RESEARCH SETTINGS') then
       -- LI_TRAINING_CODE = 66;
    elseif (upper(trim(substr(LS_TRAINING_GROUP,7))) = upper(substr('GCP ¿ Social and Behavioral Research Best Practices for Clinical Research',7))) then
       set LI_TRAINING_CODE = 101;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Investigations of Devices')) then
       set LI_TRAINING_CODE = 103;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Trials with Investigational Drugs and Biologics (ICH Focus)')) then
       set LI_TRAINING_CODE = 105;
    elseif (upper(trim(LS_TRAINING_GROUP)) = upper('GCP for Clinical Trials with Investigational Drugs and Medical Devices (U.S. FDA Focus)')) then
       set LI_TRAINING_CODE = 107;   
    end if;

    END IF;

  return LI_TRAINING_CODE;

 END
