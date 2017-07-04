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
-- Schema changes from 4.5.0 to 4.5.1
--

INSERT IGNORE INTO `cloud`.`configuration`(category, instance, component, name, value, description, default_value) VALUES ('Advanced', 'DEFAULT', 'management-server', 'vmware.snapshot.backup.session.timeout', '1200', 'VMware client timeout in seconds for snapshot backup', '1200');
UPDATE IGNORE `cloud`.`configuration` SET description='heartbeat interval to use when checking before XenServer Self Fencing' where name='xenserver.heartbeat.interval';
UPDATE IGNORE `cloud`.`configuration` SET description='Hypervisor type used to create system vm, valid values are: XenServer, KVM, VMware, Hyperv, VirtualBox, Parralels, BareMetal, Ovm, LXC, Any' where name='system.vm.default.hypervisor';
UPDATE IGNORE `cloud`.`configuration` SET description='Limit number of snapshots that can be handled concurrently; default is NULL - unlimited.' where name='concurrent.snapshots.threshold.perhost';
UPDATE IGNORE `cloud`.`configuration` SET description='whether to enable baremetal provison done notification in advanced zone' where name='baremetal.provision.done.notification.enabled';
UPDATE IGNORE `cloud`.`configuration` SET description='the max time to wait before treating a baremetal provision as failure if no provision done notification is not received in advanced zone, in secs' where name='baremetal.provision.done.notification.timeout';
UPDATE IGNORE `cloud`.`configuration` SET `value`="PLAINTEXT" WHERE `name`="user.authenticators.exclude";
UPDATE `cloud`.`configuration` SET description='Uuid of the service offering used by secondary storage; if NULL - system offering will be used' where name='secstorage.service.offering';

--Add admin user details to check if admin is still using the default password
INSERT INTO `cloud`.`user_details` (id, user_id, name, value) VALUES (1, 2, "isdefaultpassword", "true");

UPDATE IGNORE `cloud`.`configuration` SET description='Specify the default disk controller for root volumes, valid values are scsi, ide, osdefault. Please check documentation for more details on each of these values.' where name='vmware.root.disk.controller';

--Pre 3.0.7 setups have incorrect broadcast_domain_type and broadcast_uri for basic untagged shared network
UPDATE `cloud`.`vlan` v, `cloud`.`networks` n set n.broadcast_uri = v.vlan_id, n.broadcast_domain_type='Native' where v.network_id = n.id and n.broadcast_uri is null and v.vlan_id = 'vlan://untagged' and n.traffic_type = 'Guest' and n.broadcast_domain_type = 'vlan';

ALTER TABLE `cloud`.`guest_os_hypervisor` ADD FOREIGN KEY (`guest_os_id`) REFERENCES `cloud`.`guest_os`(`id`);

UPDATE IGNORE `cloud`.`configuration` SET description='Maximum recurring hourly snapshots to be retained for a volume. If the limit is reached, early snapshots from the start of the hour are deleted so that newer ones can be saved. This limit does not apply to manual snapshots. If set to 0, recurring hourly snapshots can not be scheduled.' where name='snapshot.max.hourly';
UPDATE IGNORE `cloud`.`configuration` SET description='Maximum recurring daily snapshots to be retained for a volume. If the limit is reached, snapshots from the start of the day are deleted so that newer ones can be saved. This limit does not apply to manual snapshots. If set to 0, recurring daily snapshots can not be scheduled.' where name='snapshot.max.daily';
UPDATE IGNORE `cloud`.`configuration` SET description='Maximum recurring weekly snapshots to be retained for a volume. If the limit is reached, snapshots from the beginning of the week are deleted so that newer ones can be saved. This limit does not apply to manual snapshots. If set to 0, recurring weekly snapshots can not be scheduled.' where name='snapshot.max.weekly';
UPDATE IGNORE `cloud`.`configuration` SET description='Maximum recurring monthly snapshots to be retained for a volume. If the limit is reached, snapshots from the beginning of the month are deleted so that newer ones can be saved. This limit does not apply to manual snapshots. If set to 0, recurring monthly snapshots can not be scheduled.' where name='snapshot.max.monthly';

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Windows 8 (64-bit)', 229, now(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Windows 8 (32-bit)', 230, now(), 0);

UPDATE IGNORE `cloud`.`configuration` SET `value` = '5', `default_value` = '5' WHERE `name` = 'baremetal.ipmi.fail.retry' AND `value` = 'default';
DELETE FROM `cloud`.`configuration` where name = 'concurrent.snapshots.threshold.perhost';

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (254, UUID(), 10, 'Ubuntu 14.04 (64-bit)', utc_timestamp());
UPDATE IGNORE `cloud`.`guest_os` SET `display_name` = 'Ubuntu 14.04 (32-bit)' WHERE `id` = '241' AND `display_name` = 'Ubuntu 14.04';
--Support for Ubuntu 14.04
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.0', 'ubuntuGuest', 241, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.1', 'ubuntuGuest', 241, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'ubuntuGuest', 241, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.0', 'ubuntu64Guest', 254, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.1', 'ubuntu64Guest', 254, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'VMware', '5.5', 'ubuntu64Guest', 254, utc_timestamp(), 0);

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'Ubuntu 14.04', 241, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'KVM', 'default', 'Ubuntu 14.04', 254, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'LXC', 'default', 'Ubuntu 14.04', 241, utc_timestamp(), 0);
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'LXC', 'default', 'Ubuntu 14.04', 254, utc_timestamp(), 0);

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created, is_user_defined) VALUES (UUID(),'Xenserver', '6.5.0', 'Ubuntu Trusty Tahr 14.04', 254, utc_timestamp(), 0);
UPDATE IGNORE `cloud`.`guest_os_hypervisor` SET `hypervisor_version` = '5.5' WHERE `hypervisor_version` = '5,5';

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (255, UUID(), 6, 'Windows 10 Preview (64-bit) (experimental)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (256, UUID(), 6, 'Windows 10 Preview (32-bit) (experimental)', utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (257, UUID(), 6, 'Windows Server 10 Preview (64-bit) (experimental)', utc_timestamp());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'Xenserver', '6.5.0', 'Windows 10 Preview (64-bit) (experimental)', 255, utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'Xenserver', '6.5.0', 'Windows 10 Preview (32-bit) (experimental)', 256, utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'Xenserver', '6.5.0', 'Windows Server 10 Preview (64-bit) (experimental)', 257, utc_timestamp());

UPDATE `cloud`.`configuration` SET name = 'router.template.xenserver' where name = 'router.template.xen';
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'VMware', '6.0', 'windows9_64Guest', 255, utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'VMware', '6.0', 'windows9Guest', 256, utc_timestamp());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid,hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(),'VMware', '6.0', 'windows9Server64Guest', 257, utc_timestamp());
