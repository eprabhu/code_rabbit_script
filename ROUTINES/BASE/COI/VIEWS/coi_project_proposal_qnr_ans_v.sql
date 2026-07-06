-- `coi_project_proposal_qnr_ans_v`;

CREATE  VIEW `coi_project_proposal_qnr_ans_v` AS select `coi_int_stage_dev_qnr_answer`.`STAGE_PROPOSAL_QNR_ANSWER_ID` AS `QNR_ANSWER_ID`,`coi_int_stage_dev_qnr_answer`.`PROPOSAL_NUMBER` AS `PROPOSAL_NUMBER`,`coi_int_stage_dev_qnr_answer`.`KEY_PERSON_ID` AS `KEY_PERSON_ID`,`coi_int_stage_dev_qnr_answer`.`QUESTIONNAIRE_ID` AS `QUESTIONNAIRE_ID`,`coi_int_stage_dev_qnr_answer`.`QUESTION_ID` AS `QUESTION_ID`,`coi_int_stage_dev_qnr_answer`.`ANSWER` AS `ANSWER` from `coi_int_stage_dev_qnr_answer`;

