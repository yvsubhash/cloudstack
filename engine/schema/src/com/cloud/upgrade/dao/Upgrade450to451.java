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

import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.utils.script.Script;

import org.apache.log4j.Logger;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class Upgrade450to451 implements DbUpgrade {

    final static Logger s_logger = Logger.getLogger(Upgrade450to451.class);

    @Override
    public String[] getUpgradableVersionRange() {
        return new String[] {"4.5.0", "4.5.1"};
    }

    @Override
    public String getUpgradedVersion() {
       return "4.5.1";
    }

    @Override
    public boolean supportsRollingUpgrade() {
        return false;
    }

    @Override
    public File[] getPrepareScripts() {
        String script = Script.findScript("", "db/schema-450to451.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-450to451.sql");
        }

        return new File[] {new File(script)};    }

    @Override
    public void performDataMigration(Connection conn) {
        checkAdminDefaultPassword(conn);
        addIndexForVMInstance(conn);
    }

    // Check if this is a fresh cloud deployment, then force admin user to change the default login password.
    // In case if this is a upgraded setup then there is no need to change the admin user password.
    private void checkAdminDefaultPassword(Connection conn) {
        PreparedStatement selectZoneStatement = null;
        PreparedStatement selectUsersStatement = null;
        PreparedStatement selectUserDetailStatement = null;
        PreparedStatement removeStatement = null;

        String selectZoneSql = "SELECT COUNT(*) FROM cloud.data_center";
        String selectUsersSql = "SELECT COUNT(*) FROM cloud.user";
        ResultSet selectZoneResultSet = null;
        ResultSet selectUsersResultSet = null;
        ResultSet selectUserDetailResultSet = null;
        try {
            selectZoneStatement = conn.prepareStatement(selectZoneSql);
            selectZoneResultSet = selectZoneStatement.executeQuery();
            selectUsersStatement = conn.prepareStatement(selectUsersSql);
            selectUsersResultSet = selectUsersStatement.executeQuery();

            selectZoneResultSet.next();
            selectUsersResultSet.next();

            // Check if this is fresh cloud deployment or upgraded setup by querying database for total number of zone setup
            // and total number of users and compare the values with the default values of fresh cloud deployment.

            if(selectZoneResultSet.getLong(1) > 0 || selectUsersResultSet.getLong(1) > 2) {
                // This is an upgraded setup, so remove isdefaultpassword entry from user_details table for admin default user.
                Long userId = (long) 2;
                String key = "isdefaultpassword";
                String selectUserDetailSql = "SELECT * FROM cloud.user_details where user_id=? AND name = ?";
                String removeSql = "DELETE FROM cloud.user_details WHERE id=?;";

                    selectUserDetailStatement = conn.prepareStatement(selectUserDetailSql);
                    selectUserDetailStatement.setLong(1, userId);
                    selectUserDetailStatement.setString(2, key);
                    selectUserDetailResultSet = selectUserDetailStatement.executeQuery();
                    if (selectUserDetailResultSet.next()) {
                        Long id = selectUserDetailResultSet.getLong(1);
                        removeStatement = conn.prepareStatement(removeSql);
                        removeStatement.setLong(1, id);
                        removeStatement.executeUpdate();
                        removeStatement.close();
                    }
            }
        } catch (SQLException e) {
            throw new CloudRuntimeException("Exception while removing default password check", e);
        } finally {
            if (selectZoneResultSet != null) {
                try {
                    selectZoneResultSet.close();
                } catch (SQLException e) {
                }
            }
            if (selectUsersResultSet != null) {
                try {
                    selectUsersResultSet.close();
                } catch (SQLException e) {
                }
            }
            if (selectUserDetailResultSet != null) {
                try {
                    selectUserDetailResultSet.close();
                } catch (SQLException e) {
                }
            }
            if (selectZoneStatement != null) {
                try {
                    selectZoneStatement.close();
                } catch (SQLException e) {
                }
            }
            if (selectUsersStatement != null) {
                try {
                    selectUsersStatement.close();
                } catch (SQLException e) {
                }
            }
            if (selectUserDetailStatement != null) {
                try {
                    selectUserDetailStatement.close();
                } catch (SQLException e) {
                }
            }
            if (removeStatement != null) {
                try {
                    removeStatement.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    private void addIndexForVMInstance(Connection conn) {
        // Drop index if it exists
        List<String> indexList = new ArrayList<String>();
        s_logger.debug("Dropping index i_vm_instance__instance_name from vm_instance table if it exists");
        indexList.add("i_vm_instance__instance_name");
        DbUpgradeUtils.dropKeysIfExist(conn, "vm_instance", indexList, false);

        // Now add index
        try (PreparedStatement pstmt = conn.prepareStatement("ALTER TABLE `cloud`.`vm_instance` ADD INDEX `i_vm_instance__instance_name`(`instance_name`)");) {
            pstmt.executeUpdate();
            s_logger.debug("Added index i_vm_instance__instance_name to vm_instance table");
        } catch (SQLException e) {
            throw new CloudRuntimeException("Unable to add index i_vm_instance__instance_name to vm_instance table for the column instance_name", e);
        }
    }

    @Override
    public File[] getCleanupScripts() {
        String script = Script.findScript("", "db/schema-450to451-cleanup.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-450to451-cleanup.sql");
        }

        return new File[] {new File(script)};
    }
}
