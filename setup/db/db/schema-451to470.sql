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
-- Schema upgrade from 4.5.1 to 4.7.0
--
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='application/json; charset=UTF-8' where name='json.content.type';
UPDATE IGNORE `cloud`.`configuration` SET `description`='Http response content type for .js files (default is application/json; charset=UTF-8)' where name='json.content.type';
UPDATE IGNORE `cloud`.`configuration` SET `category`='Advanced' where name='alert.wait';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='SkipHeuresticsPlanner' where name='deployment.planners.exclude';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='SimpleInvestigator,XenServerInvestigator,KVMInvestigator,HypervInvestigator,VMwareInvestigator,PingInvestigator,ManagementIPSysVMInvestigator,Ovm3Investigator' where name='ha.investigators.order';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='Hyperv,KVM,XenServer,VMware,BareMetal,Ovm,LXC' where name='hypervisor.list';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='true' where name='system.vm.random.password';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='60' where name='xapiwait';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='xenserver61' where name='xenserver.pvdriver.version';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='false' where name='secondary.storage.vm';
UPDATE IGNORE `cloud`.`configuration` SET `description`='Sets the principle of the group that users must be a member of (optional)' where name='ldap.search.group.principle';
UPDATE IGNORE `cloud`.`configuration` SET `description`='Hypervisor type used to create system vm, valid values are: XenServer, KVM, VMware, Hyperv, VirtualBox, Parralels, BareMetal, Ovm, LXC, Any' where name='system.vm.default.hypervisor';
UPDATE IGNORE `cloud`.`configuration` SET `category`='Advanced' where name='network.router.EnableServiceMonitoring';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='admin1:AdMiN123' where name='network.loadbalancer.haproxy.stats.auth';

CREATE TABLE IF NOT EXISTS `cloud`.`moonshot_chassis` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` VARCHAR(40) NULL DEFAULT NULL,
  `name` VARCHAR(128) NULL DEFAULT NULL,
  `url` VARCHAR(255) NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uuid` (`uuid`),
  UNIQUE INDEX `url` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud`.`moonshot_nodes` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` VARCHAR(40) NULL DEFAULT NULL,
  `moonshot_chassis_id` BIGINT(20) UNSIGNED NOT NULL,
  `moonshot_chassis_uuid` VARCHAR(40) NULL DEFAULT NULL,
  `host_id` BIGINT(20) UNSIGNED NULL DEFAULT NULL,
  `host_uuid` VARCHAR(40) NULL DEFAULT NULL,
  `cartridge` VARCHAR(20) NOT NULL,
  `node` VARCHAR(20) NULL DEFAULT NULL,
  `mac_address` VARCHAR(17) NULL DEFAULT NULL,
  `secondary_mac_address` VARCHAR(17) NULL DEFAULT NULL,
  `no_of_cores` INT(10) NULL DEFAULT NULL,
  `memory` INT(10) NULL DEFAULT NULL,
  `max_clock_speed` INT(10) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`host` MODIFY `private_ip_address` CHAR(255);
ALTER TABLE `cloud`.`host` MODIFY `storage_ip_address` CHAR(255);


DROP VIEW IF EXISTS `cloud`.`template_view`;
CREATE VIEW `cloud`.`template_view` AS
    select
        vm_template.id,
        vm_template.uuid,
        vm_template.unique_name,
        vm_template.name,
        vm_template.public,
        vm_template.featured,
        vm_template.type,
        vm_template.hvm,
        vm_template.bits,
        vm_template.url,
        vm_template.format,
        vm_template.created,
        vm_template.checksum,
        vm_template.display_text,
        vm_template.enable_password,
        vm_template.dynamically_scalable,
        vm_template.state template_state,
        vm_template.guest_os_id,
        guest_os.uuid guest_os_uuid,
        guest_os.display_name guest_os_name,
        vm_template.bootable,
        vm_template.prepopulate,
        vm_template.cross_zones,
        vm_template.hypervisor_type,
        vm_template.extractable,
        vm_template.template_tag,
        vm_template.sort_key,
        vm_template.removed,
        vm_template.enable_sshkey,
        source_template.id source_template_id,
        source_template.uuid source_template_uuid,
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
        data_center.id data_center_id,
        data_center.uuid data_center_uuid,
        data_center.name data_center_name,
        launch_permission.account_id lp_account_id,
        template_store_ref.store_id,
        image_store.scope as store_scope,
        template_store_ref.state,
        template_store_ref.download_state,
        template_store_ref.download_pct,
        template_store_ref.error_str,
        template_store_ref.size,
        template_store_ref.destroyed,
        template_store_ref.created created_on_store,
        vm_template_details.name detail_name,
        vm_template_details.value detail_value,
        resource_tags.id tag_id,
        resource_tags.uuid tag_uuid,
        resource_tags.key tag_key,
        resource_tags.value tag_value,
        resource_tags.domain_id tag_domain_id,
        resource_tags.account_id tag_account_id,
        resource_tags.resource_id tag_resource_id,
        resource_tags.resource_uuid tag_resource_uuid,
        resource_tags.resource_type tag_resource_type,
        resource_tags.customer tag_customer,
        CONCAT(vm_template.id, '_', IFNULL(data_center.id, 0)) as temp_zone_pair
    from
        `cloud`.`vm_template`
            inner join
        `cloud`.`guest_os` ON guest_os.id = vm_template.guest_os_id
            inner join
        `cloud`.`account` ON account.id = vm_template.account_id
            inner join
        `cloud`.`domain` ON domain.id = account.domain_id
            left join
        `cloud`.`projects` ON projects.project_account_id = account.id
            left join
        `cloud`.`vm_template_details` ON vm_template_details.template_id = vm_template.id
            left join
        `cloud`.`vm_template` source_template ON source_template.id = vm_template.source_template_id
            left join
        `cloud`.`template_store_ref` ON template_store_ref.template_id = vm_template.id and template_store_ref.store_role = 'Image' and template_store_ref.destroyed=0
            left join
        `cloud`.`image_store` ON image_store.removed is NULL AND template_store_ref.store_id is not NULL AND image_store.id = template_store_ref.store_id
            left join
        `cloud`.`template_zone_ref` ON template_zone_ref.template_id = vm_template.id AND template_zone_ref.removed is null
            left join
        `cloud`.`data_center` ON (image_store.data_center_id = data_center.id OR template_zone_ref.zone_id = data_center.id)
            left join
        `cloud`.`launch_permission` ON launch_permission.template_id = vm_template.id
            left join
        `cloud`.`resource_tags` ON resource_tags.resource_id = vm_template.id
            and (resource_tags.resource_type = 'Template' or resource_tags.resource_type='ISO');

UPDATE IGNORE `cloud`.`configuration` SET `default_value`='300' where name='resourcecount.check.interval';
UPDATE IGNORE `cloud`.`configuration` SET `description`='Time (in seconds) to wait before retrying resource count check task. Default is 300, Setting this to 0 will not run the task' where name='resourcecount.check.interval';
UPDATE IGNORE `cloud`.`configuration` SET `value`='300' where name='resourcecount.check.interval' and `value`='0';
UPDATE IGNORE `cloud`.`configuration` SET `default_value`='361' where name='volume.snapshot.job.cancel.threshold';
UPDATE IGNORE `cloud`.`configuration` SET `value`='361' where name='volume.snapshot.job.cancel.threshold' and `value`='60';

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centosGuest', 171, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centosGuest', 171, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centosGuest', 171, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centosGuest', 171, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centosGuest', 171, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centos64Guest', 172, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centos64Guest', 172, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centos64Guest', 172, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centos64Guest', 172, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 172, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centosGuest', 177, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centosGuest', 177, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centosGuest', 177, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centosGuest', 177, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centosGuest', 177, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centos64Guest', 178, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centos64Guest', 178, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centos64Guest', 178, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centos64Guest', 178, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 178, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centosGuest', 179, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centosGuest', 179, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centosGuest', 179, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centosGuest', 179, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centosGuest', 179, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centos64Guest', 180, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centos64Guest', 180, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centos64Guest', 180, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centos64Guest', 180, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 180, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centosGuest', 181, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centosGuest', 181, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centosGuest', 181, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centosGuest', 181, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centosGuest', 181, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centos64Guest', 182, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centos64Guest', 182, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centos64Guest', 182, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centos64Guest', 182, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 182, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centosGuest', 227, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centosGuest', 227, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centosGuest', 227, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centosGuest', 227, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centosGuest', 227, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.0', 'centos64Guest', 228, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '4.1', 'centos64Guest', 228, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.0', 'centos64Guest', 228, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.1', 'centos64Guest', 228, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(), 'VMware', '5.5', 'centos64Guest', 228, now(), 0);

DELETE FROM `cloud`.`configuration` WHERE name like 'saml%';

ALTER TABLE `cloud`.`user` ADD COLUMN `external_entity` text DEFAULT NULL COMMENT "reference to external federation entity";

DROP TABLE IF EXISTS `cloud`.`saml_token`;
CREATE TABLE `cloud`.`saml_token` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) UNIQUE NOT NULL COMMENT 'The Authn Unique Id',
  `domain_id` bigint unsigned DEFAULT NULL,
  `entity` text NOT NULL COMMENT 'Identity Provider Entity Id',
  `created` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_saml_token__domain_id` FOREIGN KEY(`domain_id`) REFERENCES `domain`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET foreign_key_checks = 0;
ALTER TABLE `cloud`.`region` MODIFY `id` int unsigned UNIQUE NOT NULL;
SET foreign_key_checks = 1;

ALTER TABLE `cloud`.`snapshots` ADD COLUMN `min_iops` bigint(20) unsigned COMMENT 'Minimum IOPS';
ALTER TABLE `cloud`.`snapshots` ADD COLUMN `max_iops` bigint(20) unsigned COMMENT 'Maximum IOPS';

INSERT IGNORE INTO `cloud`.`configuration` VALUES ("Advanced", 'DEFAULT', 'management-server', "stats.output.uri", "", "URI to additionally send StatsCollector statistics to", "", NULL, NULL, 0);

DROP VIEW IF EXISTS `cloud`.`domain_view`;
CREATE VIEW `cloud`.`domain_view` AS
    select
        domain.id id,
        domain.parent parent,
        domain.name name,
        domain.uuid uuid,
        domain.owner owner,
        domain.path path,
        domain.level level,
        domain.child_count child_count,
        domain.next_child_seq next_child_seq,
        domain.removed removed,
        domain.state state,
        domain.network_domain network_domain,
        domain.type type,
        vmlimit.max vmLimit,
        vmcount.count vmTotal,
        iplimit.max ipLimit,
        ipcount.count ipTotal,
        volumelimit.max volumeLimit,
        volumecount.count volumeTotal,
        snapshotlimit.max snapshotLimit,
        snapshotcount.count snapshotTotal,
        templatelimit.max templateLimit,
        templatecount.count templateTotal,
        vpclimit.max vpcLimit,
        vpccount.count vpcTotal,
        projectlimit.max projectLimit,
        projectcount.count projectTotal,
        networklimit.max networkLimit,
        networkcount.count networkTotal,
        cpulimit.max cpuLimit,
        cpucount.count cpuTotal,
        memorylimit.max memoryLimit,
        memorycount.count memoryTotal,
        primary_storage_limit.max primaryStorageLimit,
        primary_storage_count.count primaryStorageTotal,
        secondary_storage_limit.max secondaryStorageLimit,
        secondary_storage_count.count secondaryStorageTotal
    from
        `cloud`.`domain`
            left join
        `cloud`.`resource_limit` vmlimit ON domain.id = vmlimit.domain_id
            and vmlimit.type = 'user_vm'
            left join
        `cloud`.`resource_count` vmcount ON domain.id = vmcount.domain_id
            and vmcount.type = 'user_vm'
            left join
        `cloud`.`resource_limit` iplimit ON domain.id = iplimit.domain_id
            and iplimit.type = 'public_ip'
            left join
        `cloud`.`resource_count` ipcount ON domain.id = ipcount.domain_id
            and ipcount.type = 'public_ip'
            left join
        `cloud`.`resource_limit` volumelimit ON domain.id = volumelimit.domain_id
            and volumelimit.type = 'volume'
            left join
        `cloud`.`resource_count` volumecount ON domain.id = volumecount.domain_id
            and volumecount.type = 'volume'
            left join
        `cloud`.`resource_limit` snapshotlimit ON domain.id = snapshotlimit.domain_id
            and snapshotlimit.type = 'snapshot'
            left join
        `cloud`.`resource_count` snapshotcount ON domain.id = snapshotcount.domain_id
            and snapshotcount.type = 'snapshot'
            left join
        `cloud`.`resource_limit` templatelimit ON domain.id = templatelimit.domain_id
            and templatelimit.type = 'template'
            left join
        `cloud`.`resource_count` templatecount ON domain.id = templatecount.domain_id
            and templatecount.type = 'template'
            left join
        `cloud`.`resource_limit` vpclimit ON domain.id = vpclimit.domain_id
            and vpclimit.type = 'vpc'
            left join
        `cloud`.`resource_count` vpccount ON domain.id = vpccount.domain_id
            and vpccount.type = 'vpc'
            left join
        `cloud`.`resource_limit` projectlimit ON domain.id = projectlimit.domain_id
            and projectlimit.type = 'project'
            left join
        `cloud`.`resource_count` projectcount ON domain.id = projectcount.domain_id
            and projectcount.type = 'project'
            left join
        `cloud`.`resource_limit` networklimit ON domain.id = networklimit.domain_id
            and networklimit.type = 'network'
            left join
        `cloud`.`resource_count` networkcount ON domain.id = networkcount.domain_id
            and networkcount.type = 'network'
            left join
        `cloud`.`resource_limit` cpulimit ON domain.id = cpulimit.domain_id
            and cpulimit.type = 'cpu'
            left join
        `cloud`.`resource_count` cpucount ON domain.id = cpucount.domain_id
            and cpucount.type = 'cpu'
            left join
        `cloud`.`resource_limit` memorylimit ON domain.id = memorylimit.domain_id
            and memorylimit.type = 'memory'
            left join
        `cloud`.`resource_count` memorycount ON domain.id = memorycount.domain_id
            and memorycount.type = 'memory'
            left join
        `cloud`.`resource_limit` primary_storage_limit ON domain.id = primary_storage_limit.domain_id
            and primary_storage_limit.type = 'primary_storage'
            left join
        `cloud`.`resource_count` primary_storage_count ON domain.id = primary_storage_count.domain_id
            and primary_storage_count.type = 'primary_storage'
            left join
        `cloud`.`resource_limit` secondary_storage_limit ON domain.id = secondary_storage_limit.domain_id
            and secondary_storage_limit.type = 'secondary_storage'
            left join
        `cloud`.`resource_count` secondary_storage_count ON domain.id = secondary_storage_count.domain_id
            and secondary_storage_count.type = 'secondary_storage';

INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.user.vms','-1','The default maximum number of user VMs that can be deployed for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.public.ips','-1','The default maximum number of public IPs that can be consumed by a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.templates','-1','The default maximum number of templates that can be deployed for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.snapshots','-1','The default maximum number of snapshots that can be created for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.volumes','-1','The default maximum number of volumes that can be created for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.networks', '-1', 'The default maximum number of networks that can be created for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.vpcs', '-1', 'The default maximum number of vpcs that can be created for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.cpus', '-1', 'The default maximum number of cpu cores that can be used for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.memory', '-1', 'The default maximum memory (in MiB) that can be used for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.primary.storage', '-1', 'The default maximum primary storage space (in GiB) that can be used for a domain', '-1', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Domain Defaults', 'DEFAULT', 'management-server', 'max.domain.secondary.storage', '-1', 'The default maximum secondary storage space (in GiB) that can be used for a domain', '-1', NULL, NULL, 0);

ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `user_id` bigint unsigned NOT NULL DEFAULT 1 COMMENT 'user id of VM deployer';

DROP VIEW IF EXISTS `cloud`.`user_vm_view`;
CREATE VIEW `cloud`.`user_vm_view` AS
    select
        vm_instance.id id,
        vm_instance.name name,
        user_vm.display_name display_name,
        user_vm.user_data user_data,
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
        instance_group.id instance_group_id,
        instance_group.uuid instance_group_uuid,
        instance_group.name instance_group_name,
        vm_instance.uuid uuid,
        vm_instance.user_id user_id,
        vm_instance.last_host_id last_host_id,
        vm_instance.vm_type type,
        vm_instance.limit_cpu_use limit_cpu_use,
        vm_instance.created created,
        vm_instance.state state,
        vm_instance.removed removed,
        vm_instance.ha_enabled ha_enabled,
        vm_instance.hypervisor_type hypervisor_type,
        vm_instance.instance_name instance_name,
        vm_instance.guest_os_id guest_os_id,
        vm_instance.display_vm display_vm,
        guest_os.uuid guest_os_uuid,
        vm_instance.pod_id pod_id,
        host_pod_ref.uuid pod_uuid,
        vm_instance.private_ip_address private_ip_address,
        vm_instance.private_mac_address private_mac_address,
        vm_instance.vm_type vm_type,
        data_center.id data_center_id,
        data_center.uuid data_center_uuid,
        data_center.name data_center_name,
        data_center.is_security_group_enabled security_group_enabled,
        data_center.networktype data_center_type,
        host.id host_id,
        host.uuid host_uuid,
        host.name host_name,
        vm_template.id template_id,
        vm_template.uuid template_uuid,
        vm_template.name template_name,
        vm_template.display_text template_display_text,
        vm_template.enable_password password_enabled,
        iso.id iso_id,
        iso.uuid iso_uuid,
        iso.name iso_name,
        iso.display_text iso_display_text,
        service_offering.id service_offering_id,
        svc_disk_offering.uuid service_offering_uuid,
        disk_offering.uuid disk_offering_uuid,
        disk_offering.id disk_offering_id,
        Case
             When (`cloud`.`service_offering`.`cpu` is null) then (`custom_cpu`.`value`)
             Else ( `cloud`.`service_offering`.`cpu`)
        End as `cpu`,
        Case
            When (`cloud`.`service_offering`.`speed` is null) then (`custom_speed`.`value`)
            Else ( `cloud`.`service_offering`.`speed`)
        End as `speed`,
        Case
            When (`cloud`.`service_offering`.`ram_size` is null) then (`custom_ram_size`.`value`)
            Else ( `cloud`.`service_offering`.`ram_size`)
        END as `ram_size`,
        svc_disk_offering.name service_offering_name,
        disk_offering.name disk_offering_name,
        storage_pool.id pool_id,
        storage_pool.uuid pool_uuid,
        storage_pool.pool_type pool_type,
        volumes.id volume_id,
        volumes.uuid volume_uuid,
        volumes.device_id volume_device_id,
        volumes.volume_type volume_type,
        security_group.id security_group_id,
        security_group.uuid security_group_uuid,
        security_group.name security_group_name,
        security_group.description security_group_description,
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
        networks.uuid network_uuid,
        networks.name network_name,
        networks.traffic_type traffic_type,
        networks.guest_type guest_type,
        user_ip_address.id public_ip_id,
        user_ip_address.uuid public_ip_uuid,
        user_ip_address.public_ip_address public_ip_address,
        ssh_keypairs.keypair_name keypair_name,
        resource_tags.id tag_id,
        resource_tags.uuid tag_uuid,
        resource_tags.key tag_key,
        resource_tags.value tag_value,
        resource_tags.domain_id tag_domain_id,
        resource_tags.account_id tag_account_id,
        resource_tags.resource_id tag_resource_id,
        resource_tags.resource_uuid tag_resource_uuid,
        resource_tags.resource_type tag_resource_type,
        resource_tags.customer tag_customer,
        async_job.id job_id,
        async_job.uuid job_uuid,
        async_job.job_status job_status,
        async_job.account_id job_account_id,
        affinity_group.id affinity_group_id,
        affinity_group.uuid affinity_group_uuid,
        affinity_group.name affinity_group_name,
        affinity_group.description affinity_group_description,
        vm_instance.dynamically_scalable dynamically_scalable

    from
        `cloud`.`user_vm`
            inner join
        `cloud`.`vm_instance` ON vm_instance.id = user_vm.id
            and vm_instance.removed is NULL
            inner join
        `cloud`.`account` ON vm_instance.account_id = account.id
            inner join
        `cloud`.`domain` ON vm_instance.domain_id = domain.id
            left join
        `cloud`.`guest_os` ON vm_instance.guest_os_id = guest_os.id
            left join
        `cloud`.`host_pod_ref` ON vm_instance.pod_id = host_pod_ref.id
            left join
        `cloud`.`projects` ON projects.project_account_id = account.id
            left join
        `cloud`.`instance_group_vm_map` ON vm_instance.id = instance_group_vm_map.instance_id
            left join
        `cloud`.`instance_group` ON instance_group_vm_map.group_id = instance_group.id
            left join
        `cloud`.`data_center` ON vm_instance.data_center_id = data_center.id
            left join
        `cloud`.`host` ON vm_instance.host_id = host.id
            left join
        `cloud`.`vm_template` ON vm_instance.vm_template_id = vm_template.id
            left join
        `cloud`.`vm_template` iso ON iso.id = user_vm.iso_id
            left join
        `cloud`.`service_offering` ON vm_instance.service_offering_id = service_offering.id
            left join
        `cloud`.`disk_offering` svc_disk_offering ON vm_instance.service_offering_id = svc_disk_offering.id
            left join
        `cloud`.`disk_offering` ON vm_instance.disk_offering_id = disk_offering.id
            left join
        `cloud`.`volumes` ON vm_instance.id = volumes.instance_id
            left join
        `cloud`.`storage_pool` ON volumes.pool_id = storage_pool.id
            left join
        `cloud`.`security_group_vm_map` ON vm_instance.id = security_group_vm_map.instance_id
            left join
        `cloud`.`security_group` ON security_group_vm_map.security_group_id = security_group.id
            left join
        `cloud`.`nics` ON vm_instance.id = nics.instance_id and nics.removed is null
            left join
        `cloud`.`networks` ON nics.network_id = networks.id
            left join
        `cloud`.`vpc` ON networks.vpc_id = vpc.id and vpc.removed is null
            left join
        `cloud`.`user_ip_address` ON user_ip_address.vm_id = vm_instance.id
            left join
        `cloud`.`user_vm_details` as ssh_details ON ssh_details.vm_id = vm_instance.id
            and ssh_details.name = 'SSH.PublicKey'
            left join
        `cloud`.`ssh_keypairs` ON ssh_keypairs.public_key = ssh_details.value
            left join
        `cloud`.`resource_tags` ON resource_tags.resource_id = vm_instance.id
            and resource_tags.resource_type = 'UserVm'
            left join
        `cloud`.`async_job` ON async_job.instance_id = vm_instance.id
            and async_job.instance_type = 'VirtualMachine'
            and async_job.job_status = 0
            left join
        `cloud`.`affinity_group_vm_map` ON vm_instance.id = affinity_group_vm_map.instance_id
            left join
        `cloud`.`affinity_group` ON affinity_group_vm_map.affinity_group_id = affinity_group.id
            left join
        `cloud`.`user_vm_details` `custom_cpu`  ON (((`custom_cpu`.`vm_id` = `cloud`.`vm_instance`.`id`) and (`custom_cpu`.`name` = 'CpuNumber')))
            left join
        `cloud`.`user_vm_details` `custom_speed`  ON (((`custom_speed`.`vm_id` = `cloud`.`vm_instance`.`id`) and (`custom_speed`.`name` = 'CpuSpeed')))
           left join
        `cloud`.`user_vm_details` `custom_ram_size`  ON (((`custom_ram_size`.`vm_id` = `cloud`.`vm_instance`.`id`) and (`custom_ram_size`.`name` = 'memory')));

-- ovm3 stuff
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Sun Solaris 10(32-bit)', 79);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Sun Solaris 10(64-bit)', 80);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Sun Solaris 11(32-bit)', 158);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Sun Solaris 11(64-bit)', 159);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Other Linux (32-bit)', 98);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Other Linux (64-bit)', 99);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ('Ovm3', 'Other PV (32-bit)', 139);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ('Ovm3', 'Other PV (64-bit)', 140);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ('Ovm3', 'DOS', 102);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Windows 8 (32-bit)', 165);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Windows 8 (64-bit)', 166);
INSERT INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, guest_os_name, guest_os_id) VALUES  ("Ovm3", 'Windows Server 2012 (64-bit)', 167);

INSERT IGNORE INTO `cloud`.`hypervisor_capabilities`(hypervisor_type, hypervisor_version, max_guests_limit, security_group_enabled) VALUES ('Ovm3', '3.2', 25, 0);
INSERT IGNORE INTO `cloud`.`hypervisor_capabilities`(hypervisor_type, hypervisor_version, max_guests_limit, security_group_enabled) VALUES ('Ovm3', '3.3', 50, 0);
UPDATE  `cloud`.`volumes` v,  `cloud`.`storage_pool` s,  `cloud`.`cluster` c  set v.format='RAW' where v.pool_id=s.id and s.cluster_id=c.id and c.hypervisor_type='Ovm3';
UPDATE configuration SET value='Hyperv,KVM,XenServer,VMware,BareMetal,Ovm,LXC' WHERE name='hypervisor.list';
INSERT INTO `cloud`.`vm_template` (id, uuid, unique_name, name, public, created, type, hvm, bits, account_id, url, checksum, enable_password, display_text, format, guest_os_id,featured, cross_zones, hypervisor_type, state)
VALUES (12, UUID(), 'routing-12', 'SystemVM Template (Ovm3)', 0, now(), 'SYSTEM', 0, 64, 1, 'http://download.cloud.com/templates/4.6/systemvm64template.ovm.raw.bz2', '4425688804dbcf0abc9e9e56c53070d7', 0, 'SystemVM Template (Ovm3)', 'RAW', 183, 0, 1, 'Ovm3', 'Active' );

INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Advanced', 'DEFAULT', 'ManagementServer', 'ovm3.heartbeat.timeout' , '180', '120', 'Timeout value to send to the checkheartbeat script for guarding the self fencing functionality on ovm3');
INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Advanced', 'DEFAULT', 'ManagementServer', 'ovm3.heartbeat.interval' , '10', '1', 'Interval value the checkheartbeat script uses before triggering the timeout for ovm3');
INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Advanced', 'DEFAULT', 'NetworkManager', 'router.template.ovm3', 'SystemVM Template (Ovm3)', 'Name of the default router template on Ovm3.','SystemVM Template (Ovm3)', NULL, NULL, 0);
INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Hidden', 'DEFAULT', 'ManagementServer', 'ovm3.public.network.device' , NULL, NULL, 'Specify the public bridge on host for public network');
INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Hidden', 'DEFAULT', 'ManagementServer', 'ovm3.private.network.device' , NULL, NULL, 'Specify the private bridge on host for private network');
INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Hidden', 'DEFAULT', 'ManagementServer', 'ovm3.guest.network.device' , NULL, NULL, 'Specify the guest bridge on host for guest network');
INSERT IGNORE INTO `cloud`.`configuration` (`category`, `instance`, `component`, `name`, `value`, `default_value`, `description`) VALUES ('Hidden', 'DEFAULT', 'ManagementServer', 'ovm3.storage.network.device' , NULL, NULL, 'Specify the storage bridge on host for storage network');


UPDATE IGNORE `cloud`.`configuration` SET `value`='8',`default_value`='8' WHERE `name`='vmware.ports.per.dvportgroup';

DROP TABLE IF EXISTS `cloud`.`external_bigswitch_vns_devices`;
CREATE TABLE `cloud`.`external_bigswitch_bcf_devices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` varchar(255) UNIQUE,
  `physical_network_id` bigint unsigned NOT NULL COMMENT 'id of the physical network in to which bigswitch bcf device is added',
  `provider_name` varchar(255) NOT NULL COMMENT 'Service Provider name corresponding to this bigswitch bcf device',
  `device_name` varchar(255) NOT NULL COMMENT 'name of the bigswitch bcf device',
  `host_id` bigint unsigned NOT NULL COMMENT 'host id coresponding to the external bigswitch bcf device',
  `hostname` varchar(255) NOT NULL COMMENT 'host name or IP address for the bigswitch bcf device',
  `username` varchar(255) NOT NULL COMMENT 'username for the bigswitch bcf device',
  `password` varchar(255) NOT NULL COMMENT 'password for the bigswitch bcf device',
  `nat` boolean NOT NULL COMMENT 'NAT support for the bigswitch bcf device',
  `hash` varchar(255) NOT NULL COMMENT 'topology hash for the bigswitch bcf networks',
  PRIMARY KEY  (`id`),
  CONSTRAINT `fk_external_bigswitch_bcf_devices__host_id` FOREIGN KEY (`host_id`) REFERENCES `host`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_external_bigswitch_bcf_devices__physical_network_id` FOREIGN KEY (`physical_network_id`) REFERENCES `physical_network`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE `cloud`.`host` SET `resource`='com.cloud.hypervisor.xenserver.resource.XenServer600Resource' WHERE `resource`='com.cloud.hypervisor.xenserver.resource.XenServer602Resource';

CREATE TABLE `cloud`.`ldap_trust_map` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` bigint unsigned NOT NULL,
  `type` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  `account_type` int(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ldap_trust_map__domain_id` (`domain_id`),
  CONSTRAINT `fk_ldap_trust_map__domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domain` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (258, UUID(), 7, 'CoreOS', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'XenServer', 'default', 'CoreOS', 258, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VmWare', 'default', 'coreos64Guest', 258, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'CoreOS', 258, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'coreos64Guest', 258, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'coreos64Guest', 258, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6Guest', 239, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6_64Guest', 240, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian6Guest', 132, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian6_64Guest', 133, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntuGuest', 121, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntu64Guest', 126, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntuGuest', 156, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntu64Guest', 157, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'ubuntuGuest', 169, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'ubuntu64Guest', 170, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntuGuest', 169, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'ubuntu64Guest', 170, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10_64Guest', 44, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'slesGuest', 40, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10_64Guest', 42 , utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10_64Guest', 45, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10_64Guest', 152 , utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10Guest', 41, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10Guest', 43, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10Guest', 151, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles10Guest', 153, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11Guest', 46, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11Guest', 155, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11Guest', 186, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11Guest', 188, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11_64Guest', 47, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11_64Guest', 154, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11_64Guest', 185, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles11_64Guest', 187, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'sles12_64Guest', 244, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 161, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 173, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 175, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 231, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 162, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 174, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 176, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 232, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 246, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian7Guest', 183, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian7_64Guest', 184, utc_timestamp(), 0);
ALTER TABLE `cloud`.`domain_router` ADD COLUMN  update_state varchar(64) DEFAULT NULL;

UPDATE IGNORE `cloud`.`guest_os_hypervisor` SET guest_os_name = 'windows7Server64Guest' where guest_os_id in (select id from guest_os where display_name like 'windows%2008%r2%64%') and hypervisor_type = 'VMware' and hypervisor_version != 'default';

DROP TABLE IF EXISTS `cloud`.`cluster_physical_network_traffic_info`;
CREATE TABLE `cloud`.`cluster_physical_network_traffic_info` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` varchar(40),
  `cluster_id` bigint unsigned NOT NULL COMMENT 'cluster id',
  `physical_network_traffic_id` bigint unsigned NOT NULL COMMENT 'id of physical network traffic in the zone of the cluster',
  `vmware_network_label` varchar(255) COMMENT 'network label of the physical device dedicated to this traffic on a VMware host at cluster level',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_cluster_physical_network_traffic_info__cluster_id` FOREIGN KEY (`cluster_id`) REFERENCES `cluster`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cluster_physical_network_traffic_info__traffic_id` FOREIGN KEY (`physical_network_traffic_id`) REFERENCES `physical_network_traffic_types`(`id`) ON DELETE CASCADE,
  CONSTRAINT `uc_cluster_physical_network_traffic_info__uuid` UNIQUE (`uuid`),
  UNIQUE KEY (`cluster_id`, `physical_network_traffic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `cloud`.`netscaler_servicepackages`;
CREATE TABLE `cloud`.`netscaler_servicepackages` (
   `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
   `uuid` varchar(255) UNIQUE,
   `name` varchar(255) UNIQUE COMMENT 'name of the service package',
   `description` varchar(255) COMMENT 'description of the service package',
   PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `cloud`.`external_netscaler_controlcenter`;
CREATE TABLE `cloud`.`external_netscaler_controlcenter` (
    `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `uuid` varchar(255) UNIQUE,
    `username` varchar(255) COMMENT 'username of the NCC',
    `password` varchar(255) COMMENT 'password of NCC',
    `ncc_ip` varchar(255) COMMENT 'IP of NCC Manager',
    `num_retries` bigint unsigned NOT NULL default 2 COMMENT 'Number of retries in ncc for command failure',
    PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`sslcerts` ADD COLUMN `name` varchar(255) NULL default NULL COMMENT 'Name of the Certificate';
ALTER TABLE `cloud`.`network_offerings` ADD COLUMN `service_package_id` varchar(255) NULL default NULL COMMENT 'Netscaler ControlCenter Service Package';

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'Red Hat Enterprise Linux 7', 245, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'CentOS 7', 246, utc_timestamp(), 0);

DROP TABLE IF EXISTS `cloud`.`vm_snapshot_spool_ref`;
CREATE TABLE `cloud`.`vm_snapshot_spool_ref` (
  `id` bigint unsigned NOT NULL auto_increment,
  `uuid` varchar(40),
  `pool_id` bigint unsigned NOT NULL,
  `vm_snapshot_id` bigint unsigned NOT NULL,
  `created` DATETIME NOT NULL,
  `job_id` varchar(255),
  `state` varchar(255),
  `status` varchar(255),
  `install_path` varchar(255),
  `template_size` bigint unsigned NOT NULL COMMENT 'the size of the template seed from vm snapshot on primary storage pool',
  `marked_for_gc` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'if true, the garbage collector will evict the template from this pool.',
  PRIMARY KEY  (`id`),
  UNIQUE `i_vm_snapshot_spool_ref__vm_snapshot_id__pool_id`(`vm_snapshot_id`, `pool_id`),
  CONSTRAINT `fk_vm_snapshot_spool_ref__vm_snapshot_id` FOREIGN KEY (`vm_snapshot_id`) REFERENCES `vm_snapshots`(`id`),
  CONSTRAINT `fk_vm_snapshot_spool_ref__pool_id` FOREIGN KEY (`pool_id`) REFERENCES `storage_pool`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

INSERT INTO `cloud`.`storage_pool_details` (pool_id,name,value,display) SELECT storage_pool.id,data_center_details.name,data_center_details.value,data_center_details.display FROM `cloud`.`storage_pool` JOIN `cloud`.`data_center_details` ON data_center_details.dc_id=storage_pool.data_center_id WHERE data_center_details.name = "storage.overprovisioning.factor";
DELETE FROM `cloud`.`data_center_details` WHERE name="storage.overprovisioning.factor";

ALTER TABLE `cloud`.`moonshot_chassis` ADD COLUMN `zone_id` bigint unsigned NOT NULL;

INSERT IGNORE INTO `cloud`.`hypervisor_capabilities` values (25,UUID(),'VMware','6.0',128,0,13,32,1,1);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) SELECT UUID(),'VMware', '6.0', guest_os_name, guest_os_id, utc_timestamp(), 0  FROM `cloud`.`guest_os_hypervisor` WHERE hypervisor_type='VMware' AND hypervisor_version='5.5' AND (guest_os_id NOT IN (1,2,3,4,62,63,64,65,156,157,221,222) AND guest_os_id NOT BETWEEN 121 AND 130);

UPDATE IGNORE `cloud`.`configuration` SET description='whether to enable baremetal provison done notification in advanced zone' where name='baremetal.provision.done.notification.enabled';
UPDATE IGNORE `cloud`.`configuration` SET description='the max time to wait before treating a baremetal provision as failure if no provision done notification is not received in advanced zone, in secs' where name='baremetal.provision.done.notification.timeout';

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (259, UUID(), 4, 'Red Hat Enterprise Linux 7.1', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'Red Hat Enterprise Linux 7.1', 259, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 7', 259, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'rhel7_64Guest', 259, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel7_64Guest', 259, utc_timestamp(), 0);

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (260, UUID(), 1, 'CentOS 7.1', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'CentOS 7.1', 260, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'CentOS 7', 260, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'centos64Guest', 260, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 260, utc_timestamp(), 0);

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'rhel7_64Guest', 245, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel7_64Guest', 245, utc_timestamp(), 0);

INSERT INTO `cloud`.`vm_template` (id, uuid, unique_name, name, public, created, type, hvm, bits, account_id, url, checksum, enable_password, display_text,  format, guest_os_id, featured, cross_zones, hypervisor_type, extractable, state, dynamically_scalable)
    VALUES (13, UUID(), 'centos65-x86_64-XenServer', 'CentOS 6.5(64-bit) no GUI (XenServer)', 1, now(), 'BUILTIN', 0, 64, 1, 'http://download.cloud.com/templates/builtin/centos65-x86_64-xen.vhd.bz2', 'd1a8f3c4e69e31499ef6e59f1ab2401f', 0, 'CentOS 6.5(64-bit) no GUI (XenServer)', 'VHD', 228, 1, 1, 'XenServer', 1, 'Active', 1);

INSERT INTO `cloud`.`vm_template` (id, uuid, unique_name, name, public, created, type, hvm, bits, account_id, url, checksum, enable_password, display_text,  format, guest_os_id, featured, cross_zones, hypervisor_type, extractable, state)
    VALUES (14, UUID(), 'centos65-x86_64-KVM', 'CentOS 6.5(64-bit) no GUI (KVM)', 1, now(), 'BUILTIN', 0, 64, 1, 'http://download.cloud.com/templates/builtin/centos65-x86_64-kvm.qcow2.bz2', '9adf836e53483845e93afda1414b0db6', 0, 'CentOS 6.5(64-bit) no GUI (KVM)', 'QCOW2', 228, 1, 1, 'KVM', 1, 'Active');

INSERT INTO `cloud`.`vm_template` (id, uuid, unique_name, name, public, created, type, hvm, bits, account_id, url, checksum, enable_password, display_text,  format, guest_os_id, featured, cross_zones, hypervisor_type, extractable, state, dynamically_scalable)
    VALUES (15, UUID(), 'centos65-x64-vSphere', 'CentOS 6.5(64-bit) no GUI (vSphere)', 1, now(), 'BUILTIN', 0, 64, 1, 'http://download.cloud.com/templates/builtin/centos65-x86_64-vmware.ova', 'debc11d5dd9f4bbcdd94660ed8c0a19b', 0, 'CentOS 6.5(64-bit) no GUI (vSphere)', 'OVA', 228, 1, 1, 'VMware', 1, 'Active', 1);

INSERT INTO `cloud`.`vm_template` (id, uuid, unique_name, name, public, created, type, hvm, bits, account_id, url, checksum, enable_password, display_text,  format, guest_os_id, featured, cross_zones, hypervisor_type, extractable, state)
    VALUES (16, UUID(), 'centos65-x64-Hyperv', 'CentOS 6.5(64-bit) GUI (Hyperv)', 1, now(), 'BUILTIN', 0, 64, 1, 'http://download.cloud.com/templates/builtin/centos65-x86_64-hyperv.vhd.bz2', '775776d7116415580de6a9a8ba378be2', 0, 'CentOS 6.5 (64-bit) GUI (Hyperv)', 'VHD', 228, 1, 1, 'Hyperv', 1, 'Active');

UPDATE IGNORE `cloud`.`vm_template` SET state = 'Inactive' where id in (4,5,6,7);

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (261, UUID(), 1, 'CentOS 6.6 (32-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (262, UUID(), 1, 'CentOS 6.6 (64-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (263, UUID(), 1, 'CentOS 6.7 (32-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (264, UUID(), 1, 'CentOS 6.7 (64-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'CentOS 6 (32-bit)', 261, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'CentOS 6 (32-bit)', 263, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 261, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centosGuest', 263, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'CentOS 6 (64-bit)', 264, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'CentOS 6 (64-bit)', 262, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 264, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'centos64Guest', 262, utc_timestamp(), 0);


INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (265, UUID(), 4, 'Red Hat Enterprise Linux 6.6 (32-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (266, UUID(), 4, 'Red Hat Enterprise Linux 6.6 (64-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (267, UUID(), 4, 'Red Hat Enterprise Linux 6.7 (32-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (268, UUID(), 4, 'Red Hat Enterprise Linux 6.7 (64-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 6 (32-bit)', 265, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 6 (32-bit)', 267, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6Guest', 265, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6Guest', 267, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 6 (64-bit)', 266, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Red Hat Enterprise Linux 6 (64-bit)', 268, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6_64Guest', 266, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'rhel6_64Guest', 268, utc_timestamp(), 0);


INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (269, UUID(), 2, 'Debian GNU/Linux 8 (32-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (270, UUID(), 2, 'Debian GNU/Linux 8 (64-bit)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian8Guest', 269, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '6.0', 'debian8_64Guest', 270, utc_timestamp(), 0);