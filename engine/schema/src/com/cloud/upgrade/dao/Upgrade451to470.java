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

import com.cloud.network.Networks;
import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.utils.net.NetUtils;
import com.cloud.utils.script.Script;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.log4j.Logger;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

public class Upgrade451to470 implements DbUpgrade {
    final static Logger s_logger = Logger.getLogger(Upgrade451to470.class);

    @Override
    public String[] getUpgradableVersionRange() {
        return new String[] { "4.5.1", "4.7.0" };
    }

    @Override
    public String getUpgradedVersion() {
        return "4.7.0";
    }

    @Override
    public boolean supportsRollingUpgrade() {
        return false;
    }

    @Override
    public File[] getPrepareScripts() {
        final String script = Script.findScript("", "db/schema-451to470.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-451to470.sql");
        }

        return new File[] { new File(script) };
    }

    @Override
    public void performDataMigration(final Connection conn) {
        updateVMInstanceUserId(conn);
        correctNetworkNetmaskValues(conn);
        updateClusterLevelPhysicalNetworkTrafficInfo(conn, Networks.TrafficType.Guest);
        updateClusterLevelPhysicalNetworkTrafficInfo(conn, Networks.TrafficType.Public);
    }

    @Override
    public File[] getCleanupScripts() {
        final String script = Script.findScript("", "db/schema-451to470-cleanup.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-451to470-cleanup.sql");
        }

        return new File[] { new File(script) };
    }


    public void updateVMInstanceUserId(final Connection conn) {
        // For schemas before this, copy first user from an account_id which
        // deployed already running VMs
        s_logger.debug("Updating vm_instance column user_id using first user in vm_instance's account_id");
        final String vmInstanceSql = "SELECT id, account_id FROM `cloud`.`vm_instance`";
        final String userSql = "SELECT id FROM `cloud`.`user` where account_id=?";
        final String userIdUpdateSql = "update `cloud`.`vm_instance` set user_id=? where id=?";
        try (PreparedStatement selectStatement = conn.prepareStatement(vmInstanceSql)) {
            final ResultSet results = selectStatement.executeQuery();
            while (results.next()) {
                final long vmId = results.getLong(1);
                final long accountId = results.getLong(2);
                try (PreparedStatement selectUserStatement = conn.prepareStatement(userSql)) {
                    selectUserStatement.setLong(1, accountId);
                    final ResultSet userResults = selectUserStatement.executeQuery();
                    if (userResults.next()) {
                        final long userId = userResults.getLong(1);
                        try (PreparedStatement updateStatement = conn.prepareStatement(userIdUpdateSql)) {
                            updateStatement.setLong(1, userId);
                            updateStatement.setLong(2, vmId);
                            updateStatement.executeUpdate();
                        } catch (final SQLException e) {
                            throw new CloudRuntimeException("Unable to update user ID " + userId + " on vm_instance id=" + vmId, e);
                        }
                    }

                } catch (final SQLException e) {
                    throw new CloudRuntimeException("Unable to update user ID using accountId " + accountId + " on vm_instance id=" + vmId, e);
                }
            }
        } catch (final SQLException e) {
            throw new CloudRuntimeException("Unable to update user Ids for previously deployed VMs", e);
        }
        s_logger.debug("Done updating user Ids for previously deployed VMs");
        addRedundancyForNwAndVpc(conn);
        removeBumPriorityColumn(conn);
    }

    private void addRedundancyForNwAndVpc(final Connection conn) {
        ResultSet rs = null;
        try (PreparedStatement addRedundantColToVpcOfferingPstmt = conn
                .prepareStatement("ALTER TABLE `cloud`.`vpc_offerings` ADD COLUMN `redundant_router_service` tinyint(1) DEFAULT 0");
             PreparedStatement addRedundantColToVpcPstmt = conn.prepareStatement("ALTER TABLE `cloud`.`vpc` ADD COLUMN `redundant` tinyint(1) DEFAULT 0");
             PreparedStatement addRedundantColToNwPstmt = conn.prepareStatement("ALTER TABLE `cloud`.`networks` ADD COLUMN `redundant` tinyint(1) DEFAULT 0");

             // The redundancy of the networks must be based on the
             // redundancy of their network offerings
             PreparedStatement redundancyPerNwPstmt = conn.prepareStatement("select distinct nw.network_offering_id from networks nw join network_offerings off "
                     + "on nw.network_offering_id = off.id where off.redundant_router_service = 1");
             PreparedStatement updateNwRedundancyPstmt = conn.prepareStatement("update networks set redundant = 1 where network_offering_id = ?");) {
            addRedundantColToVpcPstmt.executeUpdate();
            addRedundantColToVpcOfferingPstmt.executeUpdate();
            addRedundantColToNwPstmt.executeUpdate();

            rs = redundancyPerNwPstmt.executeQuery();
            while (rs.next()) {
                final long nwOfferingId = rs.getLong("nw.network_offering_id");
                updateNwRedundancyPstmt.setLong(1, nwOfferingId);
                updateNwRedundancyPstmt.executeUpdate();
            }
        } catch (final SQLException e) {
            e.printStackTrace();
            throw new CloudRuntimeException("Adding redundancy to vpc, networks and vpc_offerings failed", e);
        }
    }

    private void removeBumPriorityColumn(final Connection conn) {
        try (PreparedStatement removeBumPriorityColumnPstmt = conn.prepareStatement("ALTER TABLE `cloud`.`domain_router` DROP COLUMN `is_priority_bumpup`");) {
            removeBumPriorityColumnPstmt.executeUpdate();
        } catch (final SQLException e) {
            e.printStackTrace();
            throw new CloudRuntimeException("Adding redundancy to vpc, networks and vpc_offerings failed", e);
        }
    }

    private void updateClusterLevelPhysicalNetworkTrafficInfo(Connection conn, Networks.TrafficType trafficType) {
        if (conn == null) {
            s_logger.debug("DB connection is null");
            return;
        }

        if (trafficType != Networks.TrafficType.Guest && trafficType != Networks.TrafficType.Public) {
            s_logger.debug("Cluster level physical network traffic info update is supported for guest and public traffic only");
            return;
        }

        String phyNetworktrafficType = (trafficType == Networks.TrafficType.Guest) ? "Guest" : "Public";
        String vswitchParamName = (trafficType == Networks.TrafficType.Guest) ? ApiConstants.VSWITCH_NAME_GUEST_TRAFFIC : ApiConstants.VSWITCH_NAME_PUBLIC_TRAFFIC;

        String vswitchNameAtClusterDetailsSelectSql = "SELECT cluster_id, value FROM `cloud`.`cluster_details` where name = ?";
        String vswitchNameAtClusterDetailsDeleteSql = "DELETE FROM `cloud`.`cluster_details` where name = ?";
        String physicalNetworkTrafficIdSelectSql = "SELECT traffictype.id FROM `cloud`.`physical_network` as network, `cloud`.`physical_network_traffic_types` as traffictype where network.id=traffictype.physical_network_id and network.data_center_id=(SELECT data_center_id FROM `cloud`.`cluster` where id=?) and traffictype.traffic_type=?";
        String clusterPhysicalNwTrafficInsertSql = "INSERT INTO `cloud`.`cluster_physical_network_traffic_info` (uuid, cluster_id, physical_network_traffic_id, vmware_network_label) VALUES (?,?,?,?)";

        s_logger.debug("Updating cluster level physical network traffic info for " + phyNetworktrafficType + " traffic");

        try (PreparedStatement pstmtSelectVswitchNameAtClusterDetails = conn.prepareStatement(vswitchNameAtClusterDetailsSelectSql);
             PreparedStatement pstmtDeleteVswitchNameAtClusterDetails = conn.prepareStatement(vswitchNameAtClusterDetailsDeleteSql);) {
            pstmtSelectVswitchNameAtClusterDetails.setString(1, vswitchParamName);
            ResultSet rsVswitchNameAtClusters = pstmtSelectVswitchNameAtClusterDetails.executeQuery();

            // for each vswitch name at the cluster
            while (rsVswitchNameAtClusters.next()) {
                // get the cluster id
                long clusterId = rsVswitchNameAtClusters.getLong(1);
                // get vswitch name at cluster
                String vswitchNameAtCluster = rsVswitchNameAtClusters.getString(2);
                if (vswitchNameAtCluster == null || vswitchNameAtCluster.isEmpty()) {
                    continue;
                }

                try (PreparedStatement pstmtSelectPhysicalNetworkTrafficId = conn.prepareStatement(physicalNetworkTrafficIdSelectSql);
                     PreparedStatement pstmtInsertClusterPhysicalNwTraffic = conn.prepareStatement(clusterPhysicalNwTrafficInsertSql);) {
                    pstmtSelectPhysicalNetworkTrafficId.setLong(1, clusterId);
                    pstmtSelectPhysicalNetworkTrafficId.setString(2, phyNetworktrafficType);
                    ResultSet rsPhysicalNetworkTrafficIds = pstmtSelectPhysicalNetworkTrafficId.executeQuery();

                    while (rsPhysicalNetworkTrafficIds.next()) {
                        long physicalNetworkTrafficId = rsPhysicalNetworkTrafficIds.getLong(1);
                        String uuid = UUID.randomUUID().toString();

                        pstmtInsertClusterPhysicalNwTraffic.setString(1, uuid);
                        pstmtInsertClusterPhysicalNwTraffic.setLong(2, clusterId);
                        pstmtInsertClusterPhysicalNwTraffic.setLong(3, physicalNetworkTrafficId);
                        pstmtInsertClusterPhysicalNwTraffic.setString(4, vswitchNameAtCluster);

                        pstmtInsertClusterPhysicalNwTraffic.executeUpdate();
                        break; // Perform only for first physical network traffic id
                    }
                } catch (SQLException e) {
                    throw new CloudRuntimeException("Exception while adding cluster level traffic info for " + phyNetworktrafficType + " traffic", e);
                }
            }

            pstmtDeleteVswitchNameAtClusterDetails.setString(1, vswitchParamName);
            pstmtDeleteVswitchNameAtClusterDetails.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("Exception while updating cluster level physical network traffic info for " + phyNetworktrafficType + " traffic", e);
        }

        s_logger.debug("Updated cluster level physical network traffic info for " + phyNetworktrafficType + " traffic");
    }
    private void correctNetworkNetmaskValues(Connection conn){

        //Related to CLOUDSTACK-8940. Need to correct the wrong values present in the database.

        s_logger.debug("Updating the nics table for correcting the wrong values stored (if any)");
        final String selectSql = "SELECT id,netmask FROM `cloud`.`nics`";
        final String updateSql = "UPDATE `cloud`.`nics` SET netmask=? where id=?";
        try (PreparedStatement selectStatement = conn.prepareStatement(selectSql)){
            final ResultSet results = selectStatement.executeQuery();
            String correctNetmask;
            while(results.next()){
                final String netmask = results.getString(2);
                final int id = results.getInt(1);
                if(NetUtils.isValidCIDR(netmask)){
                    correctNetmask = NetUtils.getCidrNetmask(netmask);
                    try(PreparedStatement updateStatement = conn.prepareStatement(updateSql)){
                        updateStatement.setString(1,correctNetmask);
                        updateStatement.setInt(2,id);
                        updateStatement.executeUpdate();
                    } catch (final SQLException e){
                        throw new CloudRuntimeException("Unable to update nics table row with id" + id, e);
                    }
                }
            }
        } catch (SQLException e){
            throw new CloudRuntimeException("Unable to extract rows from the nics table",e);
        }
    }
}