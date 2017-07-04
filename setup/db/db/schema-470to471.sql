-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.

--
-- Schema upgrade from 4.7.0 to 4.7.1
--

ALTER TABLE `cloud`.`vm_network_map` ADD INDEX `i_vm_network_map_vm_id` (`vm_id` ASC);

UPDATE IGNORE `cloud`.`configuration` SET `description` = 'Timeout (in milliseconds) up to which the console session would go to the same console proxy VM'
    WHERE name = 'consoleproxy.session.timeout';


UPDATE IGNORE `cloud`.`configuration` SET `value`="4.7.1" WHERE `name`="minreq.sysvmtemplate.version";


CREATE TABLE `cloud`.`firewall_rules_dcidrs`(
  `id` BIGINT(20) unsigned NOT NULL AUTO_INCREMENT,
  `firewall_rule_id` BIGINT(20) unsigned NOT NULL,
  `destination_cidr` VARCHAR(18) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `unique_rule_dcidrs` (`firewall_rule_id`, `destination_cidr`),
  KEY `fk_firewall_dcidrs_firewall_rules` (`firewall_rule_id`),
  CONSTRAINT `fk_firewall_dcidrs_firewall_rules` FOREIGN KEY (`firewall_rule_id`) REFERENCES `firewall_rules` (`id`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `cloud`.`guest_os_details` (
  `id` bigint unsigned NOT NULL auto_increment,
  `guest_os_id` bigint unsigned NOT NULL COMMENT 'VPC gateway id',
  `name` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  `display` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'True if the detail can be displayed to the end user',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_guest_os_details__guest_os_id` FOREIGN KEY `fk_guest_os_details__guest_os_id`(`guest_os_id`) REFERENCES `guest_os`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP VIEW IF EXISTS `cloud`.`template_view`;
CREATE
VIEW `cloud`.`template_view` AS
    SELECT
        `vm_template`.`id` AS `id`,
        `vm_template`.`uuid` AS `uuid`,
        `vm_template`.`unique_name` AS `unique_name`,
        `vm_template`.`name` AS `name`,
        `vm_template`.`public` AS `public`,
        `vm_template`.`featured` AS `featured`,
        `vm_template`.`type` AS `type`,
        `vm_template`.`hvm` AS `hvm`,
        `vm_template`.`bits` AS `bits`,
        `vm_template`.`url` AS `url`,
        `vm_template`.`format` AS `format`,
        `vm_template`.`created` AS `created`,
        `vm_template`.`checksum` AS `checksum`,
        `vm_template`.`display_text` AS `display_text`,
        `vm_template`.`enable_password` AS `enable_password`,
        `vm_template`.`dynamically_scalable` AS `dynamically_scalable`,
        `vm_template`.`state` AS `template_state`,
        `vm_template`.`guest_os_id` AS `guest_os_id`,
        `guest_os`.`uuid` AS `guest_os_uuid`,
        `guest_os`.`display_name` AS `guest_os_name`,
        `vm_template`.`bootable` AS `bootable`,
        `vm_template`.`prepopulate` AS `prepopulate`,
        `vm_template`.`cross_zones` AS `cross_zones`,
        `vm_template`.`hypervisor_type` AS `hypervisor_type`,
        `vm_template`.`extractable` AS `extractable`,
        `vm_template`.`template_tag` AS `template_tag`,
        `vm_template`.`sort_key` AS `sort_key`,
        `vm_template`.`removed` AS `removed`,
        `vm_template`.`enable_sshkey` AS `enable_sshkey`,
        `source_template`.`id` AS `source_template_id`,
        `source_template`.`uuid` AS `source_template_uuid`,
        `account`.`id` AS `account_id`,
        `account`.`uuid` AS `account_uuid`,
        `account`.`account_name` AS `account_name`,
        `account`.`type` AS `account_type`,
        `domain`.`id` AS `domain_id`,
        `domain`.`uuid` AS `domain_uuid`,
        `domain`.`name` AS `domain_name`,
        `domain`.`path` AS `domain_path`,
        `projects`.`id` AS `project_id`,
        `projects`.`uuid` AS `project_uuid`,
        `projects`.`name` AS `project_name`,
        `data_center`.`id` AS `data_center_id`,
        `data_center`.`uuid` AS `data_center_uuid`,
        `data_center`.`name` AS `data_center_name`,
        `launch_permission`.`account_id` AS `lp_account_id`,
        `template_store_ref`.`store_id` AS `store_id`,
        `image_store`.`scope` AS `store_scope`,
        `template_store_ref`.`state` AS `state`,
        `template_store_ref`.`download_state` AS `download_state`,
        `template_store_ref`.`download_pct` AS `download_pct`,
        `template_store_ref`.`error_str` AS `error_str`,
        `template_store_ref`.`size` AS `size`,
        `template_store_ref`.`destroyed` AS `destroyed`,
        `template_store_ref`.`created` AS `created_on_store`,
        `vm_template_details`.`name` AS `detail_name`,
        `vm_template_details`.`value` AS `detail_value`,
        `resource_tags`.`id` AS `tag_id`,
        `resource_tags`.`uuid` AS `tag_uuid`,
        `resource_tags`.`key` AS `tag_key`,
        `resource_tags`.`value` AS `tag_value`,
        `resource_tags`.`domain_id` AS `tag_domain_id`,
        `domain`.`uuid` AS `tag_domain_uuid`,
        `domain`.`name` AS `tag_domain_name`,
        `resource_tags`.`account_id` AS `tag_account_id`,
        `account`.`account_name` AS `tag_account_name`,
        `resource_tags`.`resource_id` AS `tag_resource_id`,
        `resource_tags`.`resource_uuid` AS `tag_resource_uuid`,
        `resource_tags`.`resource_type` AS `tag_resource_type`,
        `resource_tags`.`customer` AS `tag_customer`,
        CONCAT(`vm_template`.`id`,
                '_',
                IFNULL(`data_center`.`id`, 0)) AS `temp_zone_pair`
    FROM
        ((((((((((((`cloud`.`vm_template`
        JOIN `cloud`.`guest_os` ON ((`guest_os`.`id` = `vm_template`.`guest_os_id`)))
        JOIN `cloud`.`account` ON ((`account`.`id` = `vm_template`.`account_id`)))
        JOIN `cloud`.`domain` ON ((`domain`.`id` = `account`.`domain_id`)))
        LEFT JOIN `cloud`.`projects` ON ((`projects`.`project_account_id` = `account`.`id`)))
        LEFT JOIN `cloud`.`vm_template_details` ON ((`vm_template_details`.`template_id` = `vm_template`.`id`)))
        LEFT JOIN `cloud`.`vm_template` `source_template` ON ((`source_template`.`id` = `vm_template`.`source_template_id`)))
        LEFT JOIN `cloud`.`template_store_ref` ON (((`template_store_ref`.`template_id` = `vm_template`.`id`)
            AND (`template_store_ref`.`store_role` = 'Image')
            AND (`template_store_ref`.`destroyed` = 0))))
        LEFT JOIN `cloud`.`image_store` ON ((ISNULL(`image_store`.`removed`)
            AND (`template_store_ref`.`store_id` IS NOT NULL)
            AND (`image_store`.`id` = `template_store_ref`.`store_id`))))
        LEFT JOIN `cloud`.`template_zone_ref` ON (((`template_zone_ref`.`template_id` = `vm_template`.`id`)
            AND ISNULL(`template_store_ref`.`store_id`)
            AND ISNULL(`template_zone_ref`.`removed`))))
        LEFT JOIN `cloud`.`data_center` ON (((`image_store`.`data_center_id` = `data_center`.`id`)
            OR (`template_zone_ref`.`zone_id` = `data_center`.`id`))))
        LEFT JOIN `cloud`.`launch_permission` ON ((`launch_permission`.`template_id` = `vm_template`.`id`)))
        LEFT JOIN `cloud`.`resource_tags` ON (((`resource_tags`.`resource_id` = `vm_template`.`id`)
            AND ((`resource_tags`.`resource_type` = 'Template')
            OR (`resource_tags`.`resource_type` = 'ISO')))));

DROP VIEW IF EXISTS `cloud`.`volume_view`;
CREATE
VIEW `cloud`.`volume_view` AS
    SELECT
        `volumes`.`id` AS `id`,
        `volumes`.`uuid` AS `uuid`,
        `volumes`.`name` AS `name`,
        `volumes`.`device_id` AS `device_id`,
        `volumes`.`volume_type` AS `volume_type`,
        `volumes`.`provisioning_type` AS `provisioning_type`,
        `volumes`.`size` AS `size`,
        `volumes`.`min_iops` AS `min_iops`,
        `volumes`.`max_iops` AS `max_iops`,
        `volumes`.`created` AS `created`,
        `volumes`.`state` AS `state`,
        `volumes`.`attached` AS `attached`,
        `volumes`.`removed` AS `removed`,
        `volumes`.`pod_id` AS `pod_id`,
        `volumes`.`display_volume` AS `display_volume`,
        `volumes`.`format` AS `format`,
        `volumes`.`path` AS `path`,
        `volumes`.`chain_info` AS `chain_info`,
        `account`.`id` AS `account_id`,
        `account`.`uuid` AS `account_uuid`,
        `account`.`account_name` AS `account_name`,
        `account`.`type` AS `account_type`,
        `domain`.`id` AS `domain_id`,
        `domain`.`uuid` AS `domain_uuid`,
        `domain`.`name` AS `domain_name`,
        `domain`.`path` AS `domain_path`,
        `projects`.`id` AS `project_id`,
        `projects`.`uuid` AS `project_uuid`,
        `projects`.`name` AS `project_name`,
        `data_center`.`id` AS `data_center_id`,
        `data_center`.`uuid` AS `data_center_uuid`,
        `data_center`.`name` AS `data_center_name`,
        `data_center`.`networktype` AS `data_center_type`,
        `vm_instance`.`id` AS `vm_id`,
        `vm_instance`.`uuid` AS `vm_uuid`,
        `vm_instance`.`name` AS `vm_name`,
        `vm_instance`.`state` AS `vm_state`,
        `vm_instance`.`vm_type` AS `vm_type`,
        `user_vm`.`display_name` AS `vm_display_name`,
        `volume_store_ref`.`size` AS `volume_store_size`,
        `volume_store_ref`.`download_pct` AS `download_pct`,
        `volume_store_ref`.`download_state` AS `download_state`,
        `volume_store_ref`.`error_str` AS `error_str`,
        `volume_store_ref`.`created` AS `created_on_store`,
        `disk_offering`.`id` AS `disk_offering_id`,
        `disk_offering`.`uuid` AS `disk_offering_uuid`,
        `disk_offering`.`name` AS `disk_offering_name`,
        `disk_offering`.`display_text` AS `disk_offering_display_text`,
        `disk_offering`.`use_local_storage` AS `use_local_storage`,
        `disk_offering`.`system_use` AS `system_use`,
        `disk_offering`.`bytes_read_rate` AS `bytes_read_rate`,
        `disk_offering`.`bytes_write_rate` AS `bytes_write_rate`,
        `disk_offering`.`iops_read_rate` AS `iops_read_rate`,
        `disk_offering`.`iops_write_rate` AS `iops_write_rate`,
        `disk_offering`.`cache_mode` AS `cache_mode`,
        `storage_pool`.`id` AS `pool_id`,
        `storage_pool`.`uuid` AS `pool_uuid`,
        `storage_pool`.`name` AS `pool_name`,
        `cluster`.`hypervisor_type` AS `hypervisor_type`,
        `vm_template`.`id` AS `template_id`,
        `vm_template`.`uuid` AS `template_uuid`,
        `vm_template`.`extractable` AS `extractable`,
        `vm_template`.`type` AS `template_type`,
        `vm_template`.`name` AS `template_name`,
        `vm_template`.`display_text` AS `template_display_text`,
        `iso`.`id` AS `iso_id`,
        `iso`.`uuid` AS `iso_uuid`,
        `iso`.`name` AS `iso_name`,
        `iso`.`display_text` AS `iso_display_text`,
        `resource_tags`.`id` AS `tag_id`,
        `resource_tags`.`uuid` AS `tag_uuid`,
        `resource_tags`.`key` AS `tag_key`,
        `resource_tags`.`value` AS `tag_value`,
        `resource_tags`.`domain_id` AS `tag_domain_id`,
        `domain`.`uuid` AS `tag_domain_uuid`,
        `domain`.`name` AS `tag_domain_name`,
        `resource_tags`.`account_id` AS `tag_account_id`,
        `account`.`account_name` AS `tag_account_name`,
        `resource_tags`.`resource_id` AS `tag_resource_id`,
        `resource_tags`.`resource_uuid` AS `tag_resource_uuid`,
        `resource_tags`.`resource_type` AS `tag_resource_type`,
        `resource_tags`.`customer` AS `tag_customer`,
        `async_job`.`id` AS `job_id`,
        `async_job`.`uuid` AS `job_uuid`,
        `async_job`.`job_status` AS `job_status`,
        `async_job`.`account_id` AS `job_account_id`
    FROM
        ((((((((((((((`cloud`.`volumes`
        JOIN `cloud`.`account` ON ((`volumes`.`account_id` = `account`.`id`)))
        JOIN `cloud`.`domain` ON ((`volumes`.`domain_id` = `domain`.`id`)))
        LEFT JOIN `cloud`.`projects` ON ((`projects`.`project_account_id` = `account`.`id`)))
        LEFT JOIN `cloud`.`data_center` ON ((`volumes`.`data_center_id` = `data_center`.`id`)))
        LEFT JOIN `cloud`.`vm_instance` ON ((`volumes`.`instance_id` = `vm_instance`.`id`)))
        LEFT JOIN `cloud`.`user_vm` ON ((`user_vm`.`id` = `vm_instance`.`id`)))
        LEFT JOIN `cloud`.`volume_store_ref` ON ((`volumes`.`id` = `volume_store_ref`.`volume_id`)))
        LEFT JOIN `cloud`.`disk_offering` ON ((`volumes`.`disk_offering_id` = `disk_offering`.`id`)))
        LEFT JOIN `cloud`.`storage_pool` ON ((`volumes`.`pool_id` = `storage_pool`.`id`)))
        LEFT JOIN `cloud`.`cluster` ON ((`storage_pool`.`cluster_id` = `cluster`.`id`)))
        LEFT JOIN `cloud`.`vm_template` ON ((`volumes`.`template_id` = `vm_template`.`id`)))
        LEFT JOIN `cloud`.`vm_template` `iso` ON ((`iso`.`id` = `volumes`.`iso_id`)))
        LEFT JOIN `cloud`.`resource_tags` ON (((`resource_tags`.`resource_id` = `volumes`.`id`)
            AND (`resource_tags`.`resource_type` = 'Volume'))))
        LEFT JOIN `cloud`.`async_job` ON (((`async_job`.`instance_id` = `volumes`.`id`)
            AND (`async_job`.`instance_type` = 'Volume')
            AND (`async_job`.`job_status` = 0))));

DROP VIEW IF EXISTS `cloud`.`user_vm_view`;
CREATE
VIEW `cloud`.`user_vm_view` AS
    SELECT
        `vm_instance`.`id` AS `id`,
        `vm_instance`.`name` AS `name`,
        `user_vm`.`display_name` AS `display_name`,
        `user_vm`.`user_data` AS `user_data`,
        `account`.`id` AS `account_id`,
        `account`.`uuid` AS `account_uuid`,
        `account`.`account_name` AS `account_name`,
        `account`.`type` AS `account_type`,
        `domain`.`id` AS `domain_id`,
        `domain`.`uuid` AS `domain_uuid`,
        `domain`.`name` AS `domain_name`,
        `domain`.`path` AS `domain_path`,
        `projects`.`id` AS `project_id`,
        `projects`.`uuid` AS `project_uuid`,
        `projects`.`name` AS `project_name`,
        `instance_group`.`id` AS `instance_group_id`,
        `instance_group`.`uuid` AS `instance_group_uuid`,
        `instance_group`.`name` AS `instance_group_name`,
        `vm_instance`.`uuid` AS `uuid`,
        `vm_instance`.`user_id` AS `user_id`,
        `vm_instance`.`last_host_id` AS `last_host_id`,
        `vm_instance`.`vm_type` AS `type`,
        `vm_instance`.`limit_cpu_use` AS `limit_cpu_use`,
        `vm_instance`.`created` AS `created`,
        `vm_instance`.`state` AS `state`,
        `vm_instance`.`removed` AS `removed`,
        `vm_instance`.`ha_enabled` AS `ha_enabled`,
        `vm_instance`.`hypervisor_type` AS `hypervisor_type`,
        `vm_instance`.`instance_name` AS `instance_name`,
        `vm_instance`.`guest_os_id` AS `guest_os_id`,
        `vm_instance`.`display_vm` AS `display_vm`,
        `guest_os`.`uuid` AS `guest_os_uuid`,
        `vm_instance`.`pod_id` AS `pod_id`,
        `host_pod_ref`.`uuid` AS `pod_uuid`,
        `vm_instance`.`private_ip_address` AS `private_ip_address`,
        `vm_instance`.`private_mac_address` AS `private_mac_address`,
        `vm_instance`.`vm_type` AS `vm_type`,
        `data_center`.`id` AS `data_center_id`,
        `data_center`.`uuid` AS `data_center_uuid`,
        `data_center`.`name` AS `data_center_name`,
        `data_center`.`is_security_group_enabled` AS `security_group_enabled`,
        `data_center`.`networktype` AS `data_center_type`,
        `host`.`id` AS `host_id`,
        `host`.`uuid` AS `host_uuid`,
        `host`.`name` AS `host_name`,
        `vm_template`.`id` AS `template_id`,
        `vm_template`.`uuid` AS `template_uuid`,
        `vm_template`.`name` AS `template_name`,
        `vm_template`.`display_text` AS `template_display_text`,
        `vm_template`.`enable_password` AS `password_enabled`,
        `iso`.`id` AS `iso_id`,
        `iso`.`uuid` AS `iso_uuid`,
        `iso`.`name` AS `iso_name`,
        `iso`.`display_text` AS `iso_display_text`,
        `service_offering`.`id` AS `service_offering_id`,
        `svc_disk_offering`.`uuid` AS `service_offering_uuid`,
        `disk_offering`.`uuid` AS `disk_offering_uuid`,
        `disk_offering`.`id` AS `disk_offering_id`,
        (CASE
            WHEN ISNULL(`service_offering`.`cpu`) THEN `custom_cpu`.`value`
            ELSE `service_offering`.`cpu`
        END) AS `cpu`,
        (CASE
            WHEN ISNULL(`service_offering`.`speed`) THEN `custom_speed`.`value`
            ELSE `service_offering`.`speed`
        END) AS `speed`,
        (CASE
            WHEN ISNULL(`service_offering`.`ram_size`) THEN `custom_ram_size`.`value`
            ELSE `service_offering`.`ram_size`
        END) AS `ram_size`,
        `svc_disk_offering`.`name` AS `service_offering_name`,
        `disk_offering`.`name` AS `disk_offering_name`,
        `storage_pool`.`id` AS `pool_id`,
        `storage_pool`.`uuid` AS `pool_uuid`,
        `storage_pool`.`pool_type` AS `pool_type`,
        `volumes`.`id` AS `volume_id`,
        `volumes`.`uuid` AS `volume_uuid`,
        `volumes`.`device_id` AS `volume_device_id`,
        `volumes`.`volume_type` AS `volume_type`,
        `security_group`.`id` AS `security_group_id`,
        `security_group`.`uuid` AS `security_group_uuid`,
        `security_group`.`name` AS `security_group_name`,
        `security_group`.`description` AS `security_group_description`,
        `nics`.`id` AS `nic_id`,
        `nics`.`uuid` AS `nic_uuid`,
        `nics`.`network_id` AS `network_id`,
        `nics`.`ip4_address` AS `ip_address`,
        `nics`.`ip6_address` AS `ip6_address`,
        `nics`.`ip6_gateway` AS `ip6_gateway`,
        `nics`.`ip6_cidr` AS `ip6_cidr`,
        `nics`.`default_nic` AS `is_default_nic`,
        `nics`.`gateway` AS `gateway`,
        `nics`.`netmask` AS `netmask`,
        `nics`.`mac_address` AS `mac_address`,
        `nics`.`broadcast_uri` AS `broadcast_uri`,
        `nics`.`isolation_uri` AS `isolation_uri`,
        `vpc`.`id` AS `vpc_id`,
        `vpc`.`uuid` AS `vpc_uuid`,
        `networks`.`uuid` AS `network_uuid`,
        `networks`.`name` AS `network_name`,
        `networks`.`traffic_type` AS `traffic_type`,
        `networks`.`guest_type` AS `guest_type`,
        `user_ip_address`.`id` AS `public_ip_id`,
        `user_ip_address`.`uuid` AS `public_ip_uuid`,
        `user_ip_address`.`public_ip_address` AS `public_ip_address`,
        `ssh_keypairs`.`keypair_name` AS `keypair_name`,
        `resource_tags`.`id` AS `tag_id`,
        `resource_tags`.`uuid` AS `tag_uuid`,
        `resource_tags`.`key` AS `tag_key`,
        `resource_tags`.`value` AS `tag_value`,
        `resource_tags`.`domain_id` AS `tag_domain_id`,
        `domain`.`uuid` AS `tag_domain_uuid`,
        `domain`.`name` AS `tag_domain_name`,
        `resource_tags`.`account_id` AS `tag_account_id`,
        `account`.`account_name` AS `tag_account_name`,
        `resource_tags`.`resource_id` AS `tag_resource_id`,
        `resource_tags`.`resource_uuid` AS `tag_resource_uuid`,
        `resource_tags`.`resource_type` AS `tag_resource_type`,
        `resource_tags`.`customer` AS `tag_customer`,
        `async_job`.`id` AS `job_id`,
        `async_job`.`uuid` AS `job_uuid`,
        `async_job`.`job_status` AS `job_status`,
        `async_job`.`account_id` AS `job_account_id`,
        `affinity_group`.`id` AS `affinity_group_id`,
        `affinity_group`.`uuid` AS `affinity_group_uuid`,
        `affinity_group`.`name` AS `affinity_group_name`,
        `affinity_group`.`description` AS `affinity_group_description`,
        `vm_instance`.`dynamically_scalable` AS `dynamically_scalable`
    FROM
        ((((((((((((((((((((((((((((((((`cloud`.`user_vm`
        JOIN `cloud`.`vm_instance` ON (((`vm_instance`.`id` = `user_vm`.`id`)
            AND ISNULL(`vm_instance`.`removed`))))
        JOIN `cloud`.`account` ON ((`vm_instance`.`account_id` = `account`.`id`)))
        JOIN `cloud`.`domain` ON ((`vm_instance`.`domain_id` = `domain`.`id`)))
        LEFT JOIN `cloud`.`guest_os` ON ((`vm_instance`.`guest_os_id` = `guest_os`.`id`)))
        LEFT JOIN `cloud`.`host_pod_ref` ON ((`vm_instance`.`pod_id` = `host_pod_ref`.`id`)))
        LEFT JOIN `cloud`.`projects` ON ((`projects`.`project_account_id` = `account`.`id`)))
        LEFT JOIN `cloud`.`instance_group_vm_map` ON ((`vm_instance`.`id` = `instance_group_vm_map`.`instance_id`)))
        LEFT JOIN `cloud`.`instance_group` ON ((`instance_group_vm_map`.`group_id` = `instance_group`.`id`)))
        LEFT JOIN `cloud`.`data_center` ON ((`vm_instance`.`data_center_id` = `data_center`.`id`)))
        LEFT JOIN `cloud`.`host` ON ((`vm_instance`.`host_id` = `host`.`id`)))
        LEFT JOIN `cloud`.`vm_template` ON ((`vm_instance`.`vm_template_id` = `vm_template`.`id`)))
        LEFT JOIN `cloud`.`vm_template` `iso` ON ((`iso`.`id` = `user_vm`.`iso_id`)))
        LEFT JOIN `cloud`.`service_offering` ON ((`vm_instance`.`service_offering_id` = `service_offering`.`id`)))
        LEFT JOIN `cloud`.`disk_offering` `svc_disk_offering` ON ((`vm_instance`.`service_offering_id` = `svc_disk_offering`.`id`)))
        LEFT JOIN `cloud`.`disk_offering` ON ((`vm_instance`.`disk_offering_id` = `disk_offering`.`id`)))
        LEFT JOIN `cloud`.`volumes` ON ((`vm_instance`.`id` = `volumes`.`instance_id`)))
        LEFT JOIN `cloud`.`storage_pool` ON ((`volumes`.`pool_id` = `storage_pool`.`id`)))
        LEFT JOIN `cloud`.`security_group_vm_map` ON ((`vm_instance`.`id` = `security_group_vm_map`.`instance_id`)))
        LEFT JOIN `cloud`.`security_group` ON ((`security_group_vm_map`.`security_group_id` = `security_group`.`id`)))
        LEFT JOIN `cloud`.`nics` ON (((`vm_instance`.`id` = `nics`.`instance_id`)
            AND ISNULL(`nics`.`removed`))))
        LEFT JOIN `cloud`.`networks` ON ((`nics`.`network_id` = `networks`.`id`)))
        LEFT JOIN `cloud`.`vpc` ON (((`networks`.`vpc_id` = `vpc`.`id`)
            AND ISNULL(`vpc`.`removed`))))
        LEFT JOIN `cloud`.`user_ip_address` ON ((`user_ip_address`.`vm_id` = `vm_instance`.`id`)))
        LEFT JOIN `cloud`.`user_vm_details` `ssh_details` ON (((`ssh_details`.`vm_id` = `vm_instance`.`id`)
            AND (`ssh_details`.`name` = 'SSH.PublicKey'))))
        LEFT JOIN `cloud`.`ssh_keypairs` ON (((`ssh_keypairs`.`public_key` = `ssh_details`.`value`)
            AND (`ssh_keypairs`.`account_id` = `account`.`id`))))
        LEFT JOIN `cloud`.`resource_tags` ON (((`resource_tags`.`resource_id` = `vm_instance`.`id`)
            AND (`resource_tags`.`resource_type` = 'UserVm'))))
        LEFT JOIN `cloud`.`async_job` ON (((`async_job`.`instance_id` = `vm_instance`.`id`)
            AND (`async_job`.`instance_type` = 'VirtualMachine')
            AND (`async_job`.`job_status` = 0))))
        LEFT JOIN `cloud`.`affinity_group_vm_map` ON ((`vm_instance`.`id` = `affinity_group_vm_map`.`instance_id`)))
        LEFT JOIN `cloud`.`affinity_group` ON ((`affinity_group_vm_map`.`affinity_group_id` = `affinity_group`.`id`)))
        LEFT JOIN `cloud`.`user_vm_details` `custom_cpu` ON (((`custom_cpu`.`vm_id` = `vm_instance`.`id`)
            AND (`custom_cpu`.`name` = 'CpuNumber'))))
        LEFT JOIN `cloud`.`user_vm_details` `custom_speed` ON (((`custom_speed`.`vm_id` = `vm_instance`.`id`)
            AND (`custom_speed`.`name` = 'CpuSpeed'))))
        LEFT JOIN `cloud`.`user_vm_details` `custom_ram_size` ON (((`custom_ram_size`.`vm_id` = `vm_instance`.`id`)
            AND (`custom_ram_size`.`name` = 'memory'))));

-- Missing indexes (Add indexes to avoid full table scans)
ALTER TABLE `cloud`.`op_it_work` ADD INDEX `i_type_and_updated` (`type` ASC, `updated_at` ASC);
ALTER TABLE `cloud`.`vm_root_disk_tags` ADD INDEX `i_vm_id` (`vm_id` ASC);
ALTER TABLE `cloud`.`vm_compute_tags` ADD INDEX `i_vm_id` (`vm_id` ASC);
ALTER TABLE `cloud`.`ssh_keypairs` ADD INDEX `i_public_key` (`public_key` (64) ASC);
ALTER TABLE `cloud`.`user_vm_details` ADD INDEX `i_name_vm_id` (`vm_id` ASC, `name` ASC);
ALTER TABLE `cloud`.`instance_group` ADD INDEX `i_name` (`name` ASC);

-- Some views query (Change view to improve account retrieval speed)
CREATE OR REPLACE
VIEW `cloud`.`account_vmstats_view` AS
    SELECT
        `vm_instance`.`account_id` AS `account_id`,
        `vm_instance`.`state` AS `state`,
        COUNT(0) AS `vmcount`
    FROM
        `cloud`.`vm_instance`
    WHERE
        (`vm_instance`.`vm_type` = 'User' and `vm_instance`.`removed` is NULL)
    GROUP BY `vm_instance`.`account_id`, `vm_instance`.`state`;

ALTER TABLE `cloud`.`nicira_nvp_router_map` DROP INDEX `logicalrouter_uuid` ;

DROP VIEW IF EXISTS `cloud`.`async_job_view`;
CREATE VIEW `cloud`.`async_job_view` AS
    select
        account.id account_id,
        account.uuid account_uuid,
        account.account_name account_name,
        account.type account_type,
        domain.id domain_id,
        domain.uuid domain_uuid,
        domain.name domain_name,
        domain.path domain_path,
        user.id user_id,
        user.uuid user_uuid,
        async_job.id,
        async_job.uuid,
        async_job.related,
        async_job.job_cmd,
        async_job.job_status,
        async_job.job_process_status,
        async_job.job_result_code,
        async_job.job_result,
        async_job.created,
        async_job.removed,
        async_job.instance_type,
        async_job.instance_id,
        CASE
            WHEN async_job.instance_type = 'Volume' THEN volumes.uuid
            WHEN
                async_job.instance_type = 'Template'
                    or async_job.instance_type = 'Iso'
            THEN
                vm_template.uuid
            WHEN
                async_job.instance_type = 'VirtualMachine'
                    or async_job.instance_type = 'ConsoleProxy'
                    or async_job.instance_type = 'SystemVm'
                    or async_job.instance_type = 'DomainRouter'
            THEN
                vm_instance.uuid
            WHEN async_job.instance_type = 'Snapshot' THEN snapshots.uuid
            WHEN async_job.instance_type = 'Host' THEN host.uuid
            WHEN async_job.instance_type = 'StoragePool' THEN storage_pool.uuid
            WHEN async_job.instance_type = 'IpAddress' THEN user_ip_address.uuid
            WHEN async_job.instance_type = 'SecurityGroup' THEN security_group.uuid
            WHEN async_job.instance_type = 'PhysicalNetwork' THEN physical_network.uuid
            WHEN async_job.instance_type = 'TrafficType' THEN physical_network_traffic_types.uuid
            WHEN async_job.instance_type = 'PhysicalNetworkServiceProvider' THEN physical_network_service_providers.uuid
            WHEN async_job.instance_type = 'FirewallRule' THEN firewall_rules.uuid
            WHEN async_job.instance_type = 'Account' THEN acct.uuid
            WHEN async_job.instance_type = 'User' THEN us.uuid
            WHEN async_job.instance_type = 'StaticRoute' THEN static_routes.uuid
            WHEN async_job.instance_type = 'PrivateGateway' THEN vpc_gateways.uuid
            WHEN async_job.instance_type = 'Counter' THEN counter.uuid
            WHEN async_job.instance_type = 'Condition' THEN conditions.uuid
            WHEN async_job.instance_type = 'AutoScalePolicy' THEN autoscale_policies.uuid
            WHEN async_job.instance_type = 'AutoScaleVmProfile' THEN autoscale_vmprofiles.uuid
            WHEN async_job.instance_type = 'AutoScaleVmGroup' THEN autoscale_vmgroups.uuid
            ELSE null
        END instance_uuid
    from
        `cloud`.`async_job`
            left join
        `cloud`.`account` ON async_job.account_id = account.id
            left join
        `cloud`.`domain` ON domain.id = account.domain_id
            left join
        `cloud`.`user` ON async_job.user_id = user.id
            left join
        `cloud`.`volumes` ON async_job.instance_id = volumes.id
            left join
        `cloud`.`vm_template` ON async_job.instance_id = vm_template.id
            left join
        `cloud`.`vm_instance` ON async_job.instance_id = vm_instance.id
            left join
        `cloud`.`snapshots` ON async_job.instance_id = snapshots.id
            left join
        `cloud`.`host` ON async_job.instance_id = host.id
            left join
        `cloud`.`storage_pool` ON async_job.instance_id = storage_pool.id
            left join
        `cloud`.`user_ip_address` ON async_job.instance_id = user_ip_address.id
            left join
        `cloud`.`security_group` ON async_job.instance_id = security_group.id
            left join
        `cloud`.`physical_network` ON async_job.instance_id = physical_network.id
            left join
        `cloud`.`physical_network_traffic_types` ON async_job.instance_id = physical_network_traffic_types.id
            left join
        `cloud`.`physical_network_service_providers` ON async_job.instance_id = physical_network_service_providers.id
            left join
        `cloud`.`firewall_rules` ON async_job.instance_id = firewall_rules.id
            left join
        `cloud`.`account` acct ON async_job.instance_id = acct.id
            left join
        `cloud`.`user` us ON async_job.instance_id = us.id
            left join
        `cloud`.`static_routes` ON async_job.instance_id = static_routes.id
            left join
        `cloud`.`vpc_gateways` ON async_job.instance_id = vpc_gateways.id
            left join
        `cloud`.`counter` ON async_job.instance_id = counter.id
            left join
        `cloud`.`conditions` ON async_job.instance_id = conditions.id
            left join
        `cloud`.`autoscale_policies` ON async_job.instance_id = autoscale_policies.id
            left join
        `cloud`.`autoscale_vmprofiles` ON async_job.instance_id = autoscale_vmprofiles.id
            left join
        `cloud`.`autoscale_vmgroups` ON async_job.instance_id = autoscale_vmgroups.id;

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (271, UUID(), 6, 'Windows 10 (32-bit)', now());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (272, UUID(), 6, 'Windows 10 (64-bit)', now());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 4.5 (32-bit)', 1, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 4.6 (32-bit)', 2, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 4.7 (32-bit)', 3, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 4.8 (32-bit)', 4, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 5, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 6, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 7, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 8, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 9, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 10, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 11, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 12, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 13, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 14, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 111, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 112, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 141, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 142, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 161, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 162, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 173, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 174, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 175, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 176, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 231, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 232, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (32-bit)', 139, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 5 (64-bit)', 140, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 143, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 144, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 177, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 178, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 179, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 180, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 171, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 172, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 181, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 182, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 227, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 228, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 248, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 249, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 7', 246, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Debian Squeeze 6.0 (32-bit)', 132, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Debian Squeeze 6.0 (64-bit)', 133, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Debian Wheezy 7.0 (32-bit)', 183, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Debian Wheezy 7.0 (64-bit)', 184, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 16, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 17, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 18, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 19, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 20, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 21, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 22, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 23, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 24, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 25, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 134, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 135, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 145, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 146, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 207, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 208, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 209, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 210, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 211, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 212, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (32-bit)', 233, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 5 (64-bit)', 234, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 147, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 148, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 213, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 214, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 215, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 216, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 217, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 218, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 219, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 220, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 235, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 236, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (32-bit)', 250, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Enterprise Linux 6 (64-bit)', 251, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Oracle Linux 7', 247, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 4.5 (32-bit)', 26, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 4.6 (32-bit)', 27, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 4.7 (32-bit)', 28, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 4.8 (32-bit)', 29, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 30, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 31, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 32, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 33, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 34, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 35, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 36, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 37, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 38, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 39, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 113, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 114, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 149, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 150, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 189, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 190, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 191, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 192, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 193, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 194, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (32-bit)', 237, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 5 (64-bit)', 238, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 136, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 137, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 195, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 196, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 197, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 198, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 199, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 204, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 205, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 206, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 239, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 240, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 7', 245, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP1 (32-bit)', 41, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP1 (64-bit)', 42, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP2 (32-bit)', 43, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP2 (64-bit)', 44, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP3 (32-bit)', 151, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP3 (64-bit)', 45, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP4 (32-bit)', 153, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 10 SP4 (64-bit)', 152, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 (32-bit)', 46, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 (64-bit)', 47, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP1 (32-bit)', 155, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP1 (64-bit)', 154, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP2 (32-bit)', 186, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP2 (64-bit)', 185, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP3 (32-bit)', 188, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 11 SP3 (32-bit)', 187, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'SUSE Linux Enterprise Server 12 (64-bit)', 244, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 7 (32-bit)', 48, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 7 (64-bit)', 49, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 8 (32-bit)', 165, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 8 (64-bit)', 166, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (32-bit)', 50, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (64-bit)', 51, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (32-bit)', 87, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (64-bit)', 88, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (32-bit)', 89, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2003 (64-bit)', 90, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2008 (32-bit)', 52, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2008 (64-bit)', 53, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2008 R2 (64-bit)', 54, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2012 (64-bit)', 167, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2012 R2 (64-bit)', 168, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows XP SP3 (32-bit)', 58, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Lucid Lynx 10.04 (32-bit)', 121, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Lucid Lynx 10.04 (64-bit)', 126, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Maverick Meerkat 10.10 (32-bit) (experimental)', 156, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Maverick Meerkat 10.10 (64-bit) (experimental)', 157, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Precise Pangolin 12.04 (32-bit)', 163, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Precise Pangolin 12.04 (64-bit)', 164, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Trusty Tahr 14.04', 241, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 169, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 170, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 98, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 99, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 60, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 103, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 200, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 201, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 59, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 100, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 202, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Other install media', 203, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 252, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 253, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 8 (64-bit)', 229, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 8 (32-bit)', 230, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Ubuntu Trusty Tahr 14.04', 254, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 10 (32-bit)', 271, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 10 (64-bit)', 272, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows Server 2012 (64-bit)', 167, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 7', 259, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 7', 260, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 261, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (32-bit)', 263, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 264, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'CentOS 6 (64-bit)', 262, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 265, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (32-bit)', 267, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 266, '7.0.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Red Hat Enterprise Linux 6 (64-bit)', 268, '7.0.0', UUID(), now(), 0);

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 10 (32-bit)', 271, '6.5.0', UUID(), now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id, hypervisor_version, uuid, created, is_user_defined) VALUES ('Xenserver', 'Windows 10 (64-bit)', 272, '6.5.0', UUID(), now(), 0);

CREATE TABLE `cloud`.`domain_vlan_map` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` bigint unsigned NOT NULL COMMENT 'domain id. foreign key to domain table',
  `vlan_db_id` bigint unsigned NOT NULL COMMENT 'database id of vlan. foreign key to vlan table',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_domain_vlan_map__domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domain` (`id`) ON DELETE CASCADE,
  INDEX `i_domain_vlan_map__domain_id` (`domain_id`),
  CONSTRAINT `fk_domain_vlan_map__vlan_id` FOREIGN KEY (`vlan_db_id`) REFERENCES `vlan` (`id`) ON DELETE CASCADE,
  INDEX `i_domain_vlan_map__vlan_id` (`vlan_db_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`domain_vnet_map` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) UNIQUE,
  `vnet_range` varchar(255) NOT NULL COMMENT 'dedicated guest vlan range',
  `domain_id` bigint unsigned NOT NULL COMMENT 'domain id. foreign key to domain table',
  `physical_network_id` bigint unsigned NOT NULL COMMENT 'physical network id. foreign key to the the physical network table',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_domain_vnet_map__physical_network_id` FOREIGN KEY (`physical_network_id`) REFERENCES `physical_network` (`id`) ON DELETE CASCADE,
  INDEX `i_domain_vnet_map__physical_network_id` (`physical_network_id`),
  CONSTRAINT `fk_domain_vnet_map__domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domain` (`id`) ON DELETE CASCADE,
  INDEX `i_domain_vnet_map__domain_id` (`domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`op_dc_vnet_alloc` ADD COLUMN domain_vnet_map_id bigint unsigned DEFAULT NULL;
ALTER TABLE `cloud`.`op_dc_vnet_alloc` ADD CONSTRAINT `fk_op_dc_vnet_alloc__domain_vnet_map_id` FOREIGN KEY `fk_op_dc_vnet_alloc__domain_vnet_map_id` (`domain_vnet_map_id`) REFERENCES `domain_vnet_map` (`id`);

INSERT IGNORE INTO `cloud`.`hypervisor_capabilities`(uuid, hypervisor_type, hypervisor_version, max_guests_limit, security_group_enabled, max_data_volumes_limit, storage_motion_supported) VALUES (UUID(), 'XenServer', '7.0.0', 500, 1, 252, 1);

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows 10', 271, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows 10', 272, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows Server 2012', 167, now());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9Guest', 271, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9_64Guest', 272, now());

INSERT IGNORE INTO `cloud`.`hypervisor_capabilities`(uuid, hypervisor_type, hypervisor_version, max_guests_limit, security_group_enabled, max_data_volumes_limit, storage_motion_supported) VALUES (UUID(), 'XenServer', '7.0.0', 500, 1, 252, 1);

ALTER TABLE `cloud`.`image_store_details` CHANGE COLUMN `value` `value` VARCHAR(255) NULL DEFAULT NULL COMMENT 'value of the detail', ADD COLUMN `display` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'True if the detail can be displayed to the end user' AFTER `value`;

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (274, UUID(), 6, 'Windows Server 2016 (64-bit)', now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'Xenserver', '7.0.0', 'Windows Server 2016 (64-bit)', 274, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9srv-64', 274, now());

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (275, UUID(), 4, 'Red Hat Enterprise Linux 7.2', now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 7', 275, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'Xenserver', '7.0.0', 'Red Hat Enterprise Linux 7', 275, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '5.5', 'rhel7_64Guest', 275, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'rhel7_64Guest', 275, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Red Hat Enterprise Linux 7.2', 275, now());

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (276, UUID(), 1, 'CentOS 7.2', now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'Xenserver', '6.5.0', 'CentOS 7', 276, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'Xenserver', '7.0.0', 'CentOS 7', 276, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 276, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'centos64Guest', 276, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'CentOS 7.2', 276, now());
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos56-x86_64.vhd.bz2" WHERE `id` = "5";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos65-x86_64-xen.vhd.bz2" WHERE `id` = "13";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos65-x86_64-kvm.qcow2.bz2" WHERE `id` = "14";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos65-x86_64-vmware.ova" WHERE `id` = "15";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos65-x86_64-hyperv.vhd.bz2" WHERE `id` = "16";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/f59f18fb-ae94-4f97-afd2-f84755767aca.vhd.bz2" WHERE `id` = "2";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/releases/2.2.0/eec2209b-9875-3c8d-92be-c001bd8a0faf.qcow2.bz2" WHERE `id` = "4";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/releases/4.3/centos6_4_64bit.vhd.bz2" WHERE `id` = "6";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/releases/2.2.0/CentOS5.3-x86_64.ova" WHERE `id` = "7";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/builtin/centos-7-x86_64.tar.gz" WHERE `id` = "11";
UPDATE `cloud`.`vm_template` SET  `url` = "http://s3.download.accelerite.com/templates/4.6/systemvm64template.ovm.raw.bz2" WHERE `id` = "12";
