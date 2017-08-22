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
//
// Automatically generated by addcopyright.py at 01/29/2013
// Apache License, Version 2.0 (the "License"); you may not use this
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// Automatically generated by addcopyright.py at 04/03/2012
package com.cloud.moonshot.manager;

import com.cloud.baremetal.manager.BareMetalDiscoverer;
import com.cloud.baremetal.manager.BaremetalManager;
import com.cloud.baremetal.networkservice.BareMetalResourceBase;
import com.cloud.configuration.Config;
import com.cloud.dc.ClusterVO;
import com.cloud.dc.DataCenterVO;
import com.cloud.exception.DiscoveryException;
import com.cloud.hypervisor.Hypervisor;
import com.cloud.moonshot.client.MoonShotClient;
import com.cloud.moonshot.networkservice.BaremetalMoonshotResourceBase;
import com.cloud.network.Network;
import com.cloud.resource.Discoverer;
import com.cloud.resource.ServerResource;
import com.cloud.utils.StringUtils;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.log4j.Logger;

import javax.ejb.Local;
import java.net.InetAddress;
import java.net.URI;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Local(value = Discoverer.class)
public class MoonShotBareMetalDiscoverer extends BareMetalDiscoverer {
    protected static final Logger s_logger = Logger.getLogger(MoonShotBareMetalDiscoverer.class);

    @Override
    public Map<? extends ServerResource, Map<String, String>> find(long dcId, Long podId, Long clusterId, URI url, String username, String password, List<String> hostTags) throws DiscoveryException {

        s_logger.debug("In MoonShotBareMetalDiscoverer find");

        String discoverName = _params.get(ApiConstants.BAREMETAL_DISCOVER_NAME);

        s_logger.debug("Discoverer name passed as: " + discoverName);

        if (!StringUtils.isNotBlank(discoverName) || !discoverName.equalsIgnoreCase(this.getClass().getName())) { // This discoverer will only work if discover name is passed and is equal to current class name
            return null;
        }

        if (clusterId == null) {
            String msg = "must specify cluster Id when add host";
            s_logger.debug(msg);
            throw new RuntimeException(msg);
        }

        if (podId == null) {
            String msg = "must specify pod Id when add host";
            s_logger.debug(msg);
            throw new RuntimeException(msg);
        }

        ClusterVO cluster = _clusterDao.findById(clusterId);
        if (cluster == null || (cluster.getHypervisorType() != Hypervisor.HypervisorType.BareMetal)) {
            if (s_logger.isInfoEnabled())
                s_logger.info("invalid cluster id or cluster is not for Bare Metal hosts");
            return null;
        }

        DataCenterVO zone = _dcDao.findById(dcId);
        if (zone == null) {
            throw new RuntimeException("Cannot find zone " + dcId);
        }

        Map<BareMetalResourceBase, Map<String, String>> resources = new HashMap<>();
        Map<String, String> details = new HashMap<>();

        Map<String, Object> params = new HashMap<>();
        params.putAll(_params);

        s_logger.debug("Got these parameters for discovery:" + Arrays.toString(params.entrySet().toArray()));

        String cartridgeNodeString = (String) params.get(MoonShotBareMetalManager.CARTRIDGE_NODE_LOCATION);

        try {
            String hostname = url.getHost();
            InetAddress ia = InetAddress.getByName(hostname);
            String moonshotHost = ia.getHostAddress();
            String mac = (String)params.get(ApiConstants.HOST_MAC);
            String secondaryMac = (String)params.get(ApiConstants.PRIVATE_MAC_ADDRESS);
            String guid = UUID.nameUUIDFromBytes(mac.getBytes()).toString();

            s_logger.info("Pinging " + cartridgeNodeString + " On " + moonshotHost + " with username: " + username + " and password: " + password); //TODO: remove password from log

            MoonShotClient client = new MoonShotClient(username, password, moonshotHost, "https", 443);
            boolean result = client.pingNode(cartridgeNodeString);

            if (!result) {
                throw new DiscoveryException("Cannot ping moonshot chassis at " + moonshotHost + " with username " + username);
            } else {
                s_logger.info("Successfully pinged Moonshot node:" + cartridgeNodeString);
            }

            ClusterVO clu = _clusterDao.findById(clusterId);
            if (clu.getGuid() == null) {
                clu.setGuid(UUID.randomUUID().toString());
                _clusterDao.update(clusterId, clu);
            }

            params.put("zone", Long.toString(dcId));
            params.put("pod", Long.toString(podId));
            params.put("cluster",  Long.toString(clusterId));
            params.put("guid", guid);
            params.put(ApiConstants.PRIVATE_IP, moonshotHost);
            params.put(ApiConstants.USERNAME, username);
            params.put(ApiConstants.PASSWORD, password);
            params.put("vmDao", _vmDao);
            params.put("configDao", _configDao);
            //params.put("moonshotScheme", url.getScheme()); //TODO 1. change to enum string 2. configure also should refer same enum
            //params.put("moonshotPort", url.getPort()); //TODO  1. change to enum string 2. configure also should refer same enum

            BaremetalMoonshotResourceBase resource = new BaremetalMoonshotResourceBase();

            String memCapacity = (String)params.get(ApiConstants.MEMORY);
            String cpuCapacity = (String)params.get(ApiConstants.CPU_SPEED);
            String cpuNum = (String)params.get(ApiConstants.CPU_NUMBER);

            resource.configure("Bare Metal Agent", params);

            if (hostTags != null && hostTags.size() != 0) {
                details.put("hostTag", hostTags.get(0));
            }
            details.put(ApiConstants.MEMORY, memCapacity);
            details.put(ApiConstants.CPU_SPEED, cpuCapacity);
            details.put(ApiConstants.CPU_NUMBER, cpuNum);
            details.put(ApiConstants.HOST_MAC, mac);
            details.put(ApiConstants.PRIVATE_MAC_ADDRESS, secondaryMac);
            details.put(ApiConstants.USERNAME, username);
            details.put(ApiConstants.PASSWORD, password);
            details.put(ApiConstants.PRIVATE_IP, moonshotHost);
            String vmIp = (String)params.get(ApiConstants.IP_ADDRESS);
            if (vmIp != null) {
                details.put(ApiConstants.IP_ADDRESS, vmIp);
            }
            String isEchoScAgent = _configDao.getValue(Config.EnableBaremetalSecurityGroupAgentEcho.key());
            details.put(BaremetalManager.EchoSecurityGroupAgent, isEchoScAgent);

            details.put(MoonShotBareMetalManager.CARTRIDGE_NODE_LOCATION, cartridgeNodeString);

            resources.put(resource, details);
            resource.start();

            zone.setGatewayProvider(Network.Provider.ExternalGateWay.getName());
            zone.setDnsProvider(Network.Provider.ExternalDhcpServer.getName());
            zone.setDhcpProvider(Network.Provider.ExternalDhcpServer.getName());
            _dcDao.update(zone.getId(), zone);

            s_logger.debug(String.format("Discover Bare Metal host successfully(ip=%1$s, username=%2$s, password=%3%s," +
                    "cpuNum=%4$s, cpuCapacity-%5$s, memCapacity=%6$s)", moonshotHost, username, "******", cpuNum, cpuCapacity, memCapacity));
            return resources;

        } catch (Exception e) {
            throw new DiscoveryException("Error during discovery of node " + cartridgeNodeString, e);
        }
    }
}
