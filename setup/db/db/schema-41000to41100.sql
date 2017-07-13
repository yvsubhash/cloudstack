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

--;
-- Schema upgrade from 4.10.0.0 to 4.11.0.0;
--;

CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_account` (
      `account_id` int(11) NOT NULL,
      `quota_balance` decimal(15,2) NULL,
      `quota_balance_date` datetime NULL,
      `quota_enforce` int(1) DEFAULT NULL,
      `quota_min_balance` decimal(15,2) DEFAULT NULL,
      `quota_alert_date` datetime DEFAULT NULL,
      `quota_alert_type` int(11) DEFAULT NULL,
      `last_statement_date` datetime DEFAULT NULL,
      PRIMARY KEY (`account_id`),
  CONSTRAINT `account_id` FOREIGN KEY (`account_id`) REFERENCES `cloud_usage`.`account` (`quota_enforce`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_tariff` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usage_type` int(2) unsigned DEFAULT NULL,
  `usage_name` varchar(255) NOT NULL COMMENT 'usage type',
  `usage_unit` varchar(255) NOT NULL COMMENT 'usage type',
  `usage_discriminator` varchar(255) NOT NULL COMMENT 'usage type',
  `currency_value` decimal(15,2) NOT NULL COMMENT 'usage type',
  `effective_on` datetime NOT NULL COMMENT 'date time on which this quota values will become effective',
  `updated_on` datetime NOT NULL COMMENT 'date this entry was updated on',
  `updated_by` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


LOCK TABLES `cloud_usage`.`quota_tariff` WRITE;
INSERT IGNORE INTO `cloud_usage`.`quota_tariff` (`usage_type`, `usage_name`, `usage_unit`, `usage_discriminator`, `currency_value`, `effective_on`,  `updated_on`, `updated_by`) VALUES
 (1,'RUNNING_VM','Compute-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (2,'ALLOCATED_VM','Compute-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (3,'IP_ADDRESS','IP-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (4,'NETWORK_BYTES_SENT','GB','',0.00,'2010-05-04', '2010-05-04',1),
 (5,'NETWORK_BYTES_RECEIVED','GB','',0.00,'2010-05-04', '2010-05-04',1),
 (6,'VOLUME','GB-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (7,'TEMPLATE','GB-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (8,'ISO','GB-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (9,'SNAPSHOT','GB-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (10,'SECURITY_GROUP','Policy-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (11,'LOAD_BALANCER_POLICY','Policy-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (12,'PORT_FORWARDING_RULE','Policy-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (13,'NETWORK_OFFERING','Policy-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (14,'VPN_USERS','Policy-Month','',0.00,'2010-05-04', '2010-05-04',1),
 (15,'CPU_SPEED','Compute-Month','100MHz',0.00,'2010-05-04', '2010-05-04',1),
 (16,'vCPU','Compute-Month','1VCPU',0.00,'2010-05-04', '2010-05-04',1),
 (17,'MEMORY','Compute-Month','1MB',0.00,'2010-05-04', '2010-05-04',1),
 (21,'VM_DISK_IO_READ','GB','1',0.00,'2010-05-04', '2010-05-04',1),
 (22,'VM_DISK_IO_WRITE','GB','1',0.00,'2010-05-04', '2010-05-04',1),
 (23,'VM_DISK_BYTES_READ','GB','1',0.00,'2010-05-04', '2010-05-04',1),
 (24,'VM_DISK_BYTES_WRITE','GB','1',0.00,'2010-05-04', '2010-05-04',1),
 (25,'VM_SNAPSHOT','GB-Month','',0.00,'2010-05-04', '2010-05-04',1);
UNLOCK TABLES;

CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_credits` (
  `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
  `account_id` bigint unsigned NOT NULL,
  `domain_id` bigint(20) unsigned NOT NULL,
  `credit` decimal(15,4) COMMENT 'amount credited',
  `updated_on` datetime NOT NULL COMMENT 'date created',
  `updated_by` bigint unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_usage` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `usage_item_id` bigint(20) unsigned NOT NULL,
  `zone_id` bigint(20) unsigned NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `domain_id` bigint(20) unsigned NOT NULL,
  `usage_type` varchar(64) DEFAULT NULL,
  `quota_used` decimal(15,8) unsigned NOT NULL,
  `start_date` datetime NOT NULL COMMENT 'start time for this usage item',
  `end_date` datetime NOT NULL COMMENT 'end time for this usage item',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_balance` (
  `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
  `account_id` bigint unsigned NOT NULL,
  `domain_id` bigint(20) unsigned NOT NULL,
  `credit_balance` decimal(15,8) COMMENT 'amount of credits remaining',
  `credits_id`  bigint unsigned COMMENT 'if not null then this entry corresponds to credit change quota_credits',
  `updated_on` datetime NOT NULL COMMENT 'date updated on',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `cloud_usage`.`quota_email_templates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(64) NOT NULL UNIQUE,
  `template_subject` longtext,
  `template_body` longtext,
  `locale` varchar(25) DEFAULT 'en_US',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `cloud_usage`.`quota_email_templates` WRITE;
INSERT IGNORE INTO `cloud_usage`.`quota_email_templates` (`template_name`, `template_subject`, `template_body`) VALUES
 ('QUOTA_LOW', 'Quota Usage Threshold crossed by your account ${accountName}', 'Your account ${accountName} in the domain ${domainName} has reached quota usage threshold, your current quota balance is ${quotaBalance}.'),
 ('QUOTA_EMPTY', 'Quota Exhausted, account ${accountName} has no quota left.', 'Your account ${accountName} in the domain ${domainName} has exhausted allocated quota, please contact the administrator.'),
 ('QUOTA_UNLOCK_ACCOUNT', 'Quota credits added, account ${accountName} is unlocked now, if it was locked', 'Your account ${accountName} in the domain ${domainName} has enough quota credits now with the current balance of ${quotaBalance}.'),
 ('QUOTA_STATEMENT', 'Quota Statement for your account ${accountName}', 'Monthly quota statement of your account ${accountName} in the domain ${domainName}:<br>Balance = ${quotaBalance}<br>Total Usage = ${quotaUsage}.');
UNLOCK TABLES;

DROP VIEW IF EXISTS `cloud`.`domain_router_view`;
CREATE VIEW `cloud`.`domain_router_view` AS
    select
        vm_instance.id id,
        vm_instance.name name,
        account.id account_id,
        account.uuid account_uuid,
        account.account_name account_name,
        account.type account_type,
        domain.id domain_id,
        domain.uuid domain_uuid,
        domain.name domain_name,
        domain.path domain_path,
        projects.id project_id,
        projects.uuid project_uuid,
        projects.name project_name,
        vm_instance.uuid uuid,
        vm_instance.created created,
        vm_instance.state state,
        vm_instance.removed removed,
        vm_instance.pod_id pod_id,
        vm_instance.instance_name instance_name,
        host_pod_ref.uuid pod_uuid,
        data_center.id data_center_id,
        data_center.uuid data_center_uuid,
        data_center.name data_center_name,
        data_center.networktype data_center_type,
        data_center.dns1 dns1,
        data_center.dns2 dns2,
        data_center.ip6_dns1 ip6_dns1,
        data_center.ip6_dns2 ip6_dns2,
        host.id host_id,
        host.uuid host_uuid,
        host.name host_name,
        host.hypervisor_type,
        host.cluster_id cluster_id,
        vm_template.id template_id,
        vm_template.uuid template_uuid,
        service_offering.id service_offering_id,
        disk_offering.uuid service_offering_uuid,
        disk_offering.name service_offering_name,
        nics.id nic_id,
        nics.uuid nic_uuid,
        nics.network_id network_id,
        nics.ip4_address ip_address,
        nics.ip6_address ip6_address,
        nics.ip6_gateway ip6_gateway,
        nics.ip6_cidr ip6_cidr,
        nics.default_nic is_default_nic,
        nics.gateway gateway,
        nics.netmask netmask,
        nics.mac_address mac_address,
        nics.broadcast_uri broadcast_uri,
        nics.isolation_uri isolation_uri,
        vpc.id vpc_id,
        vpc.uuid vpc_uuid,
        vpc.name vpc_name,
        networks.uuid network_uuid,
        networks.name network_name,
        networks.network_domain network_domain,
        networks.traffic_type traffic_type,
        networks.guest_type guest_type,
        async_job.id job_id,
        async_job.uuid job_uuid,
        async_job.job_status job_status,
        async_job.account_id job_account_id,
        domain_router.template_version template_version,
        domain_router.scripts_version scripts_version,
        domain_router.is_redundant_router is_redundant_router,
        domain_router.redundant_state redundant_state,
        domain_router.stop_pending stop_pending,
        domain_router.role role
    from
        `cloud`.`domain_router`
            inner join
        `cloud`.`vm_instance` ON vm_instance.id = domain_router.id
            inner join
        `cloud`.`account` ON vm_instance.account_id = account.id
            inner join
        `cloud`.`domain` ON vm_instance.domain_id = domain.id
            left join
        `cloud`.`host_pod_ref` ON vm_instance.pod_id = host_pod_ref.id
            left join
        `cloud`.`projects` ON projects.project_account_id = account.id
            left join
        `cloud`.`data_center` ON vm_instance.data_center_id = data_center.id
            left join
        `cloud`.`host` ON vm_instance.host_id = host.id
            left join
        `cloud`.`vm_template` ON vm_instance.vm_template_id = vm_template.id
            left join
        `cloud`.`service_offering` ON vm_instance.service_offering_id = service_offering.id
            left join
        `cloud`.`disk_offering` ON vm_instance.service_offering_id = disk_offering.id
            left join
        `cloud`.`nics` ON vm_instance.id = nics.instance_id and nics.removed is null
            left join
        `cloud`.`networks` ON nics.network_id = networks.id
            left join
        `cloud`.`vpc` ON domain_router.vpc_id = vpc.id and vpc.removed is null
            left join
        `cloud`.`async_job` ON async_job.instance_id = vm_instance.id
            and async_job.instance_type = 'DomainRouter'
            and async_job.job_status = 0;


update guest_os_hypervisor set guest_os_name='windows9Server64Guest' where guest_os_id in (select id from guest_os where display_name like 'Windows Server 2016%') and hypervisor_type ='vmware';

ALTER TABLE cloud.s2s_customer_gateway ADD COLUMN force_encap INT(1) NOT NULL DEFAULT 0 AFTER dpd;

DROP VIEW IF EXISTS `cloud`.`user_vm_view`;
CREATE VIEW `user_vm_view` AS
SELECT `cloud`.`vm_instance`.`id` AS `id`,
       `cloud`.`vm_instance`.`name` AS `name`,
       `cloud`.`user_vm`.`display_name` AS `display_name`,
       `cloud`.`user_vm`.`user_data` AS `user_data`,
       `cloud`.`account`.`id` AS `account_id`,
       `cloud`.`account`.`uuid` AS `account_uuid`,
       `cloud`.`account`.`account_name` AS `account_name`,
       `cloud`.`account`.`type` AS `account_type`,
       `cloud`.`domain`.`id` AS `domain_id`,
       `cloud`.`domain`.`uuid` AS `domain_uuid`,
       `cloud`.`domain`.`name` AS `domain_name`,
       `cloud`.`domain`.`path` AS `domain_path`,
       `cloud`.`projects`.`id` AS `project_id`,
       `cloud`.`projects`.`uuid` AS `project_uuid`,
       `cloud`.`projects`.`name` AS `project_name`,
       `cloud`.`instance_group`.`id` AS `instance_group_id`,
       `cloud`.`instance_group`.`uuid` AS `instance_group_uuid`,
       `cloud`.`instance_group`.`name` AS `instance_group_name`,
       `cloud`.`vm_instance`.`uuid` AS `uuid`,
       `cloud`.`vm_instance`.`user_id` AS `user_id`,
       `cloud`.`vm_instance`.`last_host_id` AS `last_host_id`,
       `cloud`.`vm_instance`.`vm_type` AS `type`,
       `cloud`.`vm_instance`.`limit_cpu_use` AS `limit_cpu_use`,
       `cloud`.`vm_instance`.`created` AS `created`,
       `cloud`.`vm_instance`.`state` AS `state`,
       `cloud`.`vm_instance`.`removed` AS `removed`,
       `cloud`.`vm_instance`.`ha_enabled` AS `ha_enabled`,
       `cloud`.`vm_instance`.`hypervisor_type` AS `hypervisor_type`,
       `cloud`.`vm_instance`.`instance_name` AS `instance_name`,
       `cloud`.`vm_instance`.`guest_os_id` AS `guest_os_id`,
       `cloud`.`vm_instance`.`display_vm` AS `display_vm`,
       `cloud`.`guest_os`.`uuid` AS `guest_os_uuid`,
       `cloud`.`vm_instance`.`pod_id` AS `pod_id`,
       `cloud`.`host_pod_ref`.`uuid` AS `pod_uuid`,
       `cloud`.`vm_instance`.`private_ip_address` AS `private_ip_address`,
       `cloud`.`vm_instance`.`private_mac_address` AS `private_mac_address`,
       `cloud`.`vm_instance`.`vm_type` AS `vm_type`,
       `cloud`.`data_center`.`id` AS `data_center_id`,
       `cloud`.`data_center`.`uuid` AS `data_center_uuid`,
       `cloud`.`data_center`.`name` AS `data_center_name`,
       `cloud`.`data_center`.`is_security_group_enabled` AS `security_group_enabled`,
       `cloud`.`data_center`.`networktype` AS `data_center_type`,
       `cloud`.`host`.`id` AS `host_id`,
       `cloud`.`host`.`uuid` AS `host_uuid`,
       `cloud`.`host`.`name` AS `host_name`,
       `cloud`.`vm_template`.`id` AS `template_id`,
       `cloud`.`vm_template`.`uuid` AS `template_uuid`,
       `cloud`.`vm_template`.`name` AS `template_name`,
       `cloud`.`vm_template`.`display_text` AS `template_display_text`,
       `cloud`.`vm_template`.`enable_password` AS `password_enabled`,
       `iso`.`id` AS `iso_id`,
       `iso`.`uuid` AS `iso_uuid`,
       `iso`.`name` AS `iso_name`,
       `iso`.`display_text` AS `iso_display_text`,
       `cloud`.`service_offering`.`id` AS `service_offering_id`,
       `svc_disk_offering`.`uuid` AS `service_offering_uuid`,
       `cloud`.`disk_offering`.`uuid` AS `disk_offering_uuid`,
       `cloud`.`disk_offering`.`id` AS `disk_offering_id`,
       (CASE
            WHEN isnull(`cloud`.`service_offering`.`cpu`) THEN `custom_cpu`.`value`
            ELSE `cloud`.`service_offering`.`cpu`
        END) AS `cpu`,
       (CASE
            WHEN isnull(`cloud`.`service_offering`.`speed`) THEN `custom_speed`.`value`
            ELSE `cloud`.`service_offering`.`speed`
        END) AS `speed`,
       (CASE
            WHEN isnull(`cloud`.`service_offering`.`ram_size`) THEN `custom_ram_size`.`value`
            ELSE `cloud`.`service_offering`.`ram_size`
        END) AS `ram_size`,
       `svc_disk_offering`.`name` AS `service_offering_name`,
       `cloud`.`disk_offering`.`name` AS `disk_offering_name`,
       `cloud`.`storage_pool`.`id` AS `pool_id`,
       `cloud`.`storage_pool`.`uuid` AS `pool_uuid`,
       `cloud`.`storage_pool`.`pool_type` AS `pool_type`,
       `cloud`.`volumes`.`id` AS `volume_id`,
       `cloud`.`volumes`.`uuid` AS `volume_uuid`,
       `cloud`.`volumes`.`device_id` AS `volume_device_id`,
       `cloud`.`volumes`.`volume_type` AS `volume_type`,
       `cloud`.`security_group`.`id` AS `security_group_id`,
       `cloud`.`security_group`.`uuid` AS `security_group_uuid`,
       `cloud`.`security_group`.`name` AS `security_group_name`,
       `cloud`.`security_group`.`description` AS `security_group_description`,
       `cloud`.`nics`.`id` AS `nic_id`,
       `cloud`.`nics`.`uuid` AS `nic_uuid`,
       `cloud`.`nics`.`network_id` AS `network_id`,
       `cloud`.`nics`.`ip4_address` AS `ip_address`,
       `cloud`.`nics`.`ip6_address` AS `ip6_address`,
       `cloud`.`nics`.`ip6_gateway` AS `ip6_gateway`,
       `cloud`.`nics`.`ip6_cidr` AS `ip6_cidr`,
       `cloud`.`nics`.`default_nic` AS `is_default_nic`,
       `cloud`.`nics`.`gateway` AS `gateway`,
       `cloud`.`nics`.`netmask` AS `netmask`,
       `cloud`.`nics`.`mac_address` AS `mac_address`,
       `cloud`.`nics`.`broadcast_uri` AS `broadcast_uri`,
       `cloud`.`nics`.`isolation_uri` AS `isolation_uri`,
       `cloud`.`vpc`.`id` AS `vpc_id`,
       `cloud`.`vpc`.`uuid` AS `vpc_uuid`,
       `cloud`.`networks`.`uuid` AS `network_uuid`,
       `cloud`.`networks`.`name` AS `network_name`,
       `cloud`.`networks`.`traffic_type` AS `traffic_type`,
       `cloud`.`networks`.`guest_type` AS `guest_type`,
       `cloud`.`user_ip_address`.`id` AS `public_ip_id`,
       `cloud`.`user_ip_address`.`uuid` AS `public_ip_uuid`,
       `cloud`.`user_ip_address`.`public_ip_address` AS `public_ip_address`,
       `ssh_details`.`value` AS `keypair_name`,
       `cloud`.`resource_tags`.`id` AS `tag_id`,
       `cloud`.`resource_tags`.`uuid` AS `tag_uuid`,
       `cloud`.`resource_tags`.`key` AS `tag_key`,
       `cloud`.`resource_tags`.`value` AS `tag_value`,
       `cloud`.`resource_tags`.`domain_id` AS `tag_domain_id`,
       `cloud`.`domain`.`uuid` AS `tag_domain_uuid`,
       `cloud`.`domain`.`name` AS `tag_domain_name`,
       `cloud`.`resource_tags`.`account_id` AS `tag_account_id`,
       `cloud`.`account`.`account_name` AS `tag_account_name`,
       `cloud`.`resource_tags`.`resource_id` AS `tag_resource_id`,
       `cloud`.`resource_tags`.`resource_uuid` AS `tag_resource_uuid`,
       `cloud`.`resource_tags`.`resource_type` AS `tag_resource_type`,
       `cloud`.`resource_tags`.`customer` AS `tag_customer`,
       `cloud`.`async_job`.`id` AS `job_id`,
       `cloud`.`async_job`.`uuid` AS `job_uuid`,
       `cloud`.`async_job`.`job_status` AS `job_status`,
       `cloud`.`async_job`.`account_id` AS `job_account_id`,
       `cloud`.`affinity_group`.`id` AS `affinity_group_id`,
       `cloud`.`affinity_group`.`uuid` AS `affinity_group_uuid`,
       `cloud`.`affinity_group`.`name` AS `affinity_group_name`,
       `cloud`.`affinity_group`.`description` AS `affinity_group_description`,
       `cloud`.`vm_instance`.`dynamically_scalable` AS `dynamically_scalable`
FROM (((((((((((((((((((((((((((((((`cloud`.`user_vm`
    JOIN `cloud`.`vm_instance` on(((`cloud`.`vm_instance`.`id` = `cloud`.`user_vm`.`id`)
        AND isnull(`cloud`.`vm_instance`.`removed`))))
    JOIN `cloud`.`account` on((`cloud`.`vm_instance`.`account_id` = `cloud`.`account`.`id`)))
                                  JOIN `cloud`.`domain` on((`cloud`.`vm_instance`.`domain_id` = `cloud`.`domain`.`id`)))
    LEFT JOIN `cloud`.`guest_os` on((`cloud`.`vm_instance`.`guest_os_id` = `cloud`.`guest_os`.`id`)))
    LEFT JOIN `cloud`.`host_pod_ref` on((`cloud`.`vm_instance`.`pod_id` = `cloud`.`host_pod_ref`.`id`)))
    LEFT JOIN `cloud`.`projects` on((`cloud`.`projects`.`project_account_id` = `cloud`.`account`.`id`)))
    LEFT JOIN `cloud`.`instance_group_vm_map` on((`cloud`.`vm_instance`.`id` = `cloud`.`instance_group_vm_map`.`instance_id`)))
    LEFT JOIN `cloud`.`instance_group` on((`cloud`.`instance_group_vm_map`.`group_id` = `cloud`.`instance_group`.`id`)))
    LEFT JOIN `cloud`.`data_center` on((`cloud`.`vm_instance`.`data_center_id` = `cloud`.`data_center`.`id`)))
    LEFT JOIN `cloud`.`host` on((`cloud`.`vm_instance`.`host_id` = `cloud`.`host`.`id`)))
    LEFT JOIN `cloud`.`vm_template` on((`cloud`.`vm_instance`.`vm_template_id` = `cloud`.`vm_template`.`id`)))
    LEFT JOIN `cloud`.`vm_template` `iso` on((`iso`.`id` = `cloud`.`user_vm`.`iso_id`)))
    LEFT JOIN `cloud`.`service_offering` on((`cloud`.`vm_instance`.`service_offering_id` = `cloud`.`service_offering`.`id`)))
    LEFT JOIN `cloud`.`disk_offering` `svc_disk_offering` on((`cloud`.`vm_instance`.`service_offering_id` = `svc_disk_offering`.`id`)))
    LEFT JOIN `cloud`.`disk_offering` on((`cloud`.`vm_instance`.`disk_offering_id` = `cloud`.`disk_offering`.`id`)))
    LEFT JOIN `cloud`.`volumes` on((`cloud`.`vm_instance`.`id` = `cloud`.`volumes`.`instance_id`)))
    LEFT JOIN `cloud`.`storage_pool` on((`cloud`.`volumes`.`pool_id` = `cloud`.`storage_pool`.`id`)))
    LEFT JOIN `cloud`.`security_group_vm_map` on((`cloud`.`vm_instance`.`id` = `cloud`.`security_group_vm_map`.`instance_id`)))
    LEFT JOIN `cloud`.`security_group` on((`cloud`.`security_group_vm_map`.`security_group_id` = `cloud`.`security_group`.`id`)))
    LEFT JOIN `cloud`.`nics` on(((`cloud`.`vm_instance`.`id` = `cloud`.`nics`.`instance_id`)
        AND isnull(`cloud`.`nics`.`removed`))))
    LEFT JOIN `cloud`.`networks` on((`cloud`.`nics`.`network_id` = `cloud`.`networks`.`id`)))
    LEFT JOIN `cloud`.`vpc` on(((`cloud`.`networks`.`vpc_id` = `cloud`.`vpc`.`id`)
        AND isnull(`cloud`.`vpc`.`removed`))))
    LEFT JOIN `cloud`.`user_ip_address` on((`cloud`.`user_ip_address`.`vm_id` = `cloud`.`vm_instance`.`id`)))
    LEFT JOIN `cloud`.`user_vm_details` `ssh_details` on(((`ssh_details`.`vm_id` = `cloud`.`vm_instance`.`id`)
        AND (`ssh_details`.`name` = 'SSH.KeyPairName'))))
    LEFT JOIN `cloud`.`resource_tags` on(((`cloud`.`resource_tags`.`resource_id` = `cloud`.`vm_instance`.`id`)
                                                  AND (`cloud`.`resource_tags`.`resource_type` = 'UserVm'))))
    LEFT JOIN `cloud`.`async_job` on(((`cloud`.`async_job`.`instance_id` = `cloud`.`vm_instance`.`id`)
                                             AND (`cloud`.`async_job`.`instance_type` = 'VirtualMachine')
                                             AND (`cloud`.`async_job`.`job_status` = 0))))
    LEFT JOIN `cloud`.`affinity_group_vm_map` on((`cloud`.`vm_instance`.`id` = `cloud`.`affinity_group_vm_map`.`instance_id`)))
    LEFT JOIN `cloud`.`affinity_group` on((`cloud`.`affinity_group_vm_map`.`affinity_group_id` = `cloud`.`affinity_group`.`id`)))
    LEFT JOIN `cloud`.`user_vm_details` `custom_cpu` on(((`custom_cpu`.`vm_id` = `cloud`.`vm_instance`.`id`)
                                                            AND (`custom_cpu`.`name` = 'CpuNumber'))))
    LEFT JOIN `cloud`.`user_vm_details` `custom_speed` on(((`custom_speed`.`vm_id` = `cloud`.`vm_instance`.`id`)
                                                              AND (`custom_speed`.`name` = 'CpuSpeed'))))
    LEFT JOIN `cloud`.`user_vm_details` `custom_ram_size` on(((`custom_ram_size`.`vm_id` = `cloud`.`vm_instance`.`id`)
                                                                AND (`custom_ram_size`.`name` = 'memory'))));


INSERT INTO `cloud`.`user_vm_details` (`vm_id`,`name`,`value`,`display` )
    SELECT vm_id, 'SSH.KeyPairName', keypair_name, 1
        FROM cloud.user_vm_details inner join cloud.ssh_keypairs
            ON ssh_keypairs.public_key = user_vm_details.value AND user_vm_details.name = 'SSH.PublicKey'
    GROUP BY ssh_keypairs.public_key,vm_id;

DROP VIEW IF EXISTS `cloud`.`affinity_group_view`;
CREATE VIEW `affinity_group_view`
	AS SELECT
	   `affinity_group`.`id` AS `id`,
	   `affinity_group`.`name` AS `name`,
	   `affinity_group`.`type` AS `type`,
	   `affinity_group`.`description` AS `description`,
	   `affinity_group`.`uuid` AS `uuid`,
	   `affinity_group`.`acl_type` AS `acl_type`,
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
	   `vm_instance`.`id` AS `vm_id`,
	   `vm_instance`.`uuid` AS `vm_uuid`,
	   `vm_instance`.`name` AS `vm_name`,
	   `vm_instance`.`state` AS `vm_state`,
	   `user_vm`.`display_name` AS `vm_display_name`
FROM `affinity_group`
	JOIN `account` ON`affinity_group`.`account_id` = `account`.`id`
	JOIN `domain` ON`affinity_group`.`domain_id` = `domain`.`id`
	LEFT JOIN `projects` ON`projects`.`project_account_id` = `account`.`id`
	LEFT JOIN `affinity_group_vm_map` ON`affinity_group`.`id` = `affinity_group_vm_map`.`affinity_group_id`
	LEFT JOIN `vm_instance` ON`vm_instance`.`id` = `affinity_group_vm_map`.`instance_id`
	LEFT JOIN `user_vm` ON`user_vm`.`id` = `vm_instance`.`id`;
