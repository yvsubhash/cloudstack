// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package com.cloud.upgrade.dao;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import com.cloud.utils.crypt.DBEncryptionUtil;
import com.cloud.utils.db.TransactionLegacy;
import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.utils.script.Script;

public class Upgrade442to450 implements DbUpgrade {
    final static Logger s_logger = Logger.getLogger(Upgrade442to450.class);

    @Override
    public String[] getUpgradableVersionRange() {
        return new String[] {"4.4.2", "4.5.0"};
    }

    @Override
    public String getUpgradedVersion() {
        return "4.5.0";
    }

    @Override
    public boolean supportsRollingUpgrade() {
        return false;
    }

    @Override
    public File[] getPrepareScripts() {
        String script = Script.findScript("", "db/schema-442to450.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-442to450.sql");
        }

        return new File[] {new File(script)};
    }

    @Override
    public void performDataMigration(Connection conn) {
        dropInvalidKeyFromStoragePoolTable(conn);
        dropDuplicatedForeignKeyFromAsyncJobTable(conn);
        upgradeVMwareLocalStorage(conn);
        upgradeMemoryOfVirtualRoutervmOffering(conn);
        upgradeMemoryOfInternalLoadBalancervmOffering(conn);
        encryptKeyInKeyStore(conn);
        updateRouterRamConfigurationValue(conn);
        encryptStoragePoolUserInfo(conn);
        updateUserVmDetailsWithNicAdapterType(conn);
        encryptIpSecPresharedKeysOfRemoteAccessVpn(conn);
    }

    private void encryptKeyInKeyStore(Connection conn) {
        PreparedStatement selectStatement = null;
        ResultSet selectResultSet = null;

        PreparedStatement updateStatement = null;

        String selectSql = "SELECT ks.id, ks.key FROM cloud.keystore ks where ks.key is not null";
        String updateSql = "UPDATE cloud.keystore ks SET ks.key = ? WHERE ks.id = ?";

        try {
            selectStatement = conn.prepareStatement(selectSql);
            selectResultSet = selectStatement.executeQuery();
            while (selectResultSet.next()) {
                Long id = selectResultSet.getLong(1);
                String encryptedKey = DBEncryptionUtil.encrypt(selectResultSet.getString(2));
                updateStatement = conn.prepareStatement(updateSql);
                updateStatement.setString(1, encryptedKey);
                updateStatement.setLong(2, id);
                updateStatement.executeUpdate();
                updateStatement.close();
            }
        } catch (SQLException e) {
            throw new CloudRuntimeException("Exception while encrypting key values in keystore", e);
        } finally {
            if (selectResultSet != null) {
                try {
                    selectResultSet.close();
                } catch (SQLException e) {
                }
            }

            if (selectStatement != null) {
                try {
                    selectStatement.close();
                } catch (SQLException e) {
                }
            }
            if (updateStatement != null) {
                try {
                    updateStatement.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    private void updateRouterRamConfigurationValue(Connection conn) {
        PreparedStatement updatePstmt = null;
        String newRamSize = "256"; //256MB
        s_logger.debug("Updating the configuration parameter value of router.ram.size to " + newRamSize);

        String encryptedValue = DBEncryptionUtil.encrypt(newRamSize);
        try {
            updatePstmt = conn.prepareStatement("UPDATE `cloud`.`configuration` SET category='Hidden', value=?, default_value=? WHERE name='router.ram.size'");
            updatePstmt.setString(1, encryptedValue);
            updatePstmt.setString(2, encryptedValue);
            updatePstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to update the configuration parameter value of router.ram.size to " + newRamSize + " " + e);
        } finally {
            try {
                if (updatePstmt != null) {
                    updatePstmt.close();
                }
            } catch (SQLException e) {
            }
        }
        s_logger.debug("Updating the configuration parameter value of router.ram.size to " + newRamSize);
    }

    private void upgradeMemoryOfVirtualRoutervmOffering(Connection conn) {
        PreparedStatement updatePstmt = null;
        PreparedStatement selectPstmt = null;
        ResultSet selectResultSet = null;
        int newRamSize = 256; //256MB
        long serviceOfferingId = 0;

        /**
         * Pick first row in service_offering table which has system vm type as domainrouter. User added offerings would start from 2nd row onwards.
         * We should not update/modify any user-defined offering.
         */

        try {
            selectPstmt = conn.prepareStatement("SELECT id FROM `cloud`.`service_offering` WHERE vm_type='domainrouter'");
            updatePstmt = conn.prepareStatement("UPDATE `cloud`.`service_offering` SET ram_size=? WHERE id=?");
            selectResultSet = selectPstmt.executeQuery();
            if(selectResultSet.next()) {
                serviceOfferingId = selectResultSet.getLong("id");
            }

            updatePstmt.setInt(1, newRamSize);
            updatePstmt.setLong(2, serviceOfferingId);
            updatePstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to upgrade ram_size of service offering for domain router. ", e);
        } finally {
            try {
                if (selectPstmt != null) {
                    selectPstmt.close();
                }
                if (selectResultSet != null) {
                    selectResultSet.close();
                }
                if (updatePstmt != null) {
                    updatePstmt.close();
                }
            } catch (SQLException e) {
            }
        }
        s_logger.debug("Done upgrading RAM for service offering of domain router to " + newRamSize);
    }

    private void upgradeMemoryOfInternalLoadBalancervmOffering(Connection conn) {
        PreparedStatement updatePstmt = null;
        PreparedStatement selectPstmt = null;
        ResultSet selectResultSet = null;
        int newRamSize = 256; //256MB
        long serviceOfferingId = 0;

        /**
         * Pick first row in service_offering table which has system vm type as internalloadbalancervm. User added offerings would start from 2nd row onwards.
         * We should not update/modify any user-defined offering.
         */

        try {
            selectPstmt = conn.prepareStatement("SELECT id FROM `cloud`.`service_offering` WHERE vm_type='internalloadbalancervm'");
            updatePstmt = conn.prepareStatement("UPDATE `cloud`.`service_offering` SET ram_size=? WHERE id=?");
            selectResultSet = selectPstmt.executeQuery();
            if(selectResultSet.next()) {
                serviceOfferingId = selectResultSet.getLong("id");
            }

            updatePstmt.setInt(1, newRamSize);
            updatePstmt.setLong(2, serviceOfferingId);
            updatePstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to upgrade ram_size of service offering for internal loadbalancer vm. ", e);
        } finally {
            try {
                if (selectPstmt != null) {
                    selectPstmt.close();
                }
                if (selectResultSet != null) {
                    selectResultSet.close();
                }
                if (updatePstmt != null) {
                    updatePstmt.close();
                }
            } catch (SQLException e) {
            }
        }
        s_logger.debug("Done upgrading RAM for service offering of internal loadbalancer vm to " + newRamSize);
    }

    private void upgradeVMwareLocalStorage(Connection conn) {
        PreparedStatement updatePstmt = null;

        try {
            updatePstmt = conn.prepareStatement("update storage_pool set pool_type='VMFS',host_address=@newaddress where " +
                    "(@newaddress:=concat('VMFS datastore: ',path)) is not null and scope = 'HOST' and pool_type = 'LVM' " +
                    "and id in (select * from (select storage_pool.id from storage_pool,cluster where storage_pool.cluster_id = cluster.id and cluster.hypervisor_type='VMware') as t);");
            updatePstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to upgrade vmware local storage pool type", e);
        } finally {
            try {
                if (updatePstmt != null) {
                    updatePstmt.close();
                }
            } catch (SQLException e) {
            }
        }
        s_logger.debug("Done, upgrade vmware local storage pool type to VMFS and host_address to VMFS format");
    }


    @Override
    public File[] getCleanupScripts() {
        String script = Script.findScript("", "db/schema-442to450-cleanup.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-442to450-cleanup.sql");
        }

        return new File[] {new File(script)};
    }

    private void dropInvalidKeyFromStoragePoolTable(Connection conn) {
        HashMap<String, List<String>> uniqueKeys = new HashMap<String, List<String>>();
        List<String> keys = new ArrayList<String>();

        keys.add("id_2");
        uniqueKeys.put("storage_pool", keys);

        s_logger.debug("Dropping id_2 key from storage_pool table");
        for (Map.Entry<String, List<String>> entry: uniqueKeys.entrySet()) {
            DbUpgradeUtils.dropKeysIfExist(conn,entry.getKey(), entry.getValue(), false);
        }
    }

    private void dropDuplicatedForeignKeyFromAsyncJobTable(Connection conn) {
        HashMap<String, List<String>> foreignKeys = new HashMap<String, List<String>>();
        List<String> keys = new ArrayList<String>();

        keys.add("fk_async_job_join_map__join_job_id");
        foreignKeys.put("async_job_join_map", keys);

        s_logger.debug("Dropping fk_async_job_join_map__join_job_id key from async_job_join_map table");
        for (Map.Entry<String, List<String>> entry: foreignKeys.entrySet()) {
            DbUpgradeUtils.dropKeysIfExist(conn,entry.getKey(), entry.getValue(), true);
        }
    }

    private void encryptStoragePoolUserInfo(Connection conn) {
        s_logger.debug("Encrypting storage pool user info");
        List<PreparedStatement> pstmt2Close = new ArrayList<PreparedStatement>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            pstmt = conn.prepareStatement("select id, user_info from `cloud`.`storage_pool` where user_info is not null");
            pstmt2Close.add(pstmt);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                long id = rs.getLong(1);
                String userInfo = rs.getString(2);
                String encryptedUserInfo = DBEncryptionUtil.encrypt(userInfo);
                pstmt = conn.prepareStatement("update `cloud`.`storage_pool` set user_info=? where id=?");
                pstmt2Close.add(pstmt);
                if (encryptedUserInfo == null) {
                    pstmt.setNull(1, Types.VARCHAR);
                } else {
                    pstmt.setBytes(1, encryptedUserInfo.getBytes("UTF-8"));
                }
                pstmt.setLong(2, id);
                pstmt.executeUpdate();
            }
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable encrypt storage pool user info ", e);
        } catch (UnsupportedEncodingException e) {
            throw new CloudRuntimeException("Unable encrypt storage pool user info ", e);
        } finally {
            TransactionLegacy.closePstmts(pstmt2Close);
        }
        s_logger.debug("Done encrypting user keys");
    }

    private void updateUserVmDetailsWithNicAdapterType(Connection conn) {
        PreparedStatement insertPstmt = null;

        try {
            insertPstmt = conn.prepareStatement("insert into `cloud`.`user_vm_details`(vm_id,name,value,display) " +
                    "select v.id as vm_id, details.name, details.value, details.display " +
                    "from `cloud`.`vm_instance` as v, `cloud`.`vm_template_details` as details  " +
                    "where v.removed is null and v.vm_template_id=details.template_id and details.name='nicAdapter' " +
                    "and details.template_id in (select id from `cloud`.`vm_template` where hypervisor_type = 'vmware') " +
                    "and v.id not in (select vm_id from `cloud`.`user_vm_details` where name='nicAdapter');");
            insertPstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Failed to update user_vm_details table with nicAdapter entries " +
                    "by copying from vm_template_detail table", e);
        } finally {
            try {
                if (insertPstmt != null) {
                    insertPstmt.close();
                }
            } catch (SQLException e) {
            }
        }
        s_logger.debug("Done. Updated user_vm_details table with nicAdapter entries by copying from " +
                "vm_template_detail table. This affects only VM/templates with hypervisor_type as VMware.");
    }

    private void encryptIpSecPresharedKeysOfRemoteAccessVpn(Connection conn) {
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        ResultSet result1 = null;
        try {
            // get all the unencrypted values.
            pstmt1 = conn.prepareStatement("select id, ipsec_psk from `cloud`.`remote_access_vpn`");
            result1 = pstmt1.executeQuery();
            String presharedkey = null;
            Long id = null;
            while (result1.next()){
                id = result1.getLong(1);
                presharedkey = result1.getString(2);
                //replace all the preshared keys with encrypted presharedkey values.
                pstmt2 = conn.prepareStatement("UPDATE `cloud`.`remote_access_vpn` set ipsec_psk=? where id=?");
                pstmt2.setString(1, DBEncryptionUtil.encrypt(presharedkey));
                pstmt2.setLong(2, id);
                pstmt2.executeUpdate();
            }
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to update the remote access vpn preshared keys", e);
        } finally {
            try {
                if (result1 != null) {
                    result1.close();
                }
                if (pstmt1 != null && !pstmt1.isClosed()) {
                    pstmt1.close();
                }
                if (pstmt2 != null && !pstmt2.isClosed()) {
                    pstmt2.close();
                }
            }catch (SQLException e){

            }
        }
    }
}
