-- `coi_project_proposal_status_v`;

CREATE  VIEW `coi_project_proposal_status_v` AS select `coi_int_stage_dev_proposal_status`.`STATUS_CODE` AS `status_code`,`coi_int_stage_dev_proposal_status`.`DESCRIPTION` AS `description` from `coi_int_stage_dev_proposal_status`;

