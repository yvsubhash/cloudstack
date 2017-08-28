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
package com.cloud.moonshot.manager;

import com.cloud.agent.AgentManager;
import com.cloud.dc.ClusterVO;
import com.cloud.dc.DataCenterVO;
import com.cloud.dc.dao.ClusterDao;
import com.cloud.dc.dao.DataCenterDao;
import com.cloud.event.ActionEvent;
import com.cloud.exception.AgentUnavailableException;
import com.cloud.exception.DiscoveryException;
import com.cloud.exception.InvalidParameterValueException;
import com.cloud.exception.OperationTimedoutException;
import com.cloud.host.DetailVO;
import com.cloud.host.Host;
import com.cloud.host.HostVO;
import com.cloud.host.dao.HostDao;
import com.cloud.host.dao.HostDetailsDao;
import com.cloud.hypervisor.Hypervisor;
import com.cloud.moonshot.api.DeleteMoonShotChassisCmd;
import com.cloud.moonshot.api.DeleteMoonShotNodeCmd;
import com.cloud.moonshot.api.ImportMoonShotChassisCmd;
import com.cloud.moonshot.api.ListMoonShotChassisCmd;
import com.cloud.moonshot.api.ListMoonShotChassisResponse;
import com.cloud.moonshot.api.ListMoonShotNodeResponse;
import com.cloud.moonshot.api.ListMoonShotNodesCmd;
import com.cloud.moonshot.api.MoonShotChassisResponse;
import com.cloud.moonshot.api.SyncMoonShotChassisCmd;
import com.cloud.moonshot.api.SyncMoonShotChassisResponse;
import com.cloud.moonshot.api.UpdateMoonShotChassisCmd;
import com.cloud.moonshot.client.MoonShotClient;
import com.cloud.moonshot.client.model.MoonshotClientException;
import com.cloud.moonshot.client.model.Node;
import com.cloud.moonshot.dao.MoonShotChassisDao;
import com.cloud.moonshot.dao.MoonShotNodeDao;
import com.cloud.moonshot.model.MoonShotChassisVO;
import com.cloud.moonshot.model.MoonShotNodeVO;
import com.cloud.resource.ResourceManager;
import com.cloud.utils.Pair;
import com.cloud.utils.StringUtils;
import com.cloud.utils.UriUtils;
import com.cloud.utils.component.ManagerBase;
import com.cloud.utils.crypt.DBEncryptionUtil;
import com.cloud.utils.db.Filter;
import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.wds.api.UpdateMoonshotDetailsCommand;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.cloudstack.api.command.admin.host.AddHostCmd;
import org.apache.log4j.Logger;

import javax.inject.Inject;
import javax.naming.ConfigurationException;
import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Raghav on 5/8/15.
 */
public class MoonShotBareMetalManagerImpl extends ManagerBase implements MoonShotBareMetalManager {

    private static final Logger s_logger = Logger.getLogger(MoonShotBareMetalManagerImpl.class);

    @Inject
    public ResourceManager _resourceManager;
    @Inject
    AgentManager _agentManager;
    @Inject
    public ClusterDao _clusterDao;
    @Inject
    public MoonShotChassisDao _moonShotChassisDao;
    @Inject
    public MoonShotNodeDao _moonShotNodeDao;
    @Inject
    HostDetailsDao _hostDetailsDao;
    @Inject
    HostDao _hostDao;
    @Inject
    DataCenterDao _dataCenterDao;

    @Override
    @ActionEvent(eventType = "BAREMETAL.CHASSIS.IMPORT", eventDescription = "Importing Moonshot Chassis", async = true)
    public MoonShotChassisResponse addMoonShotChassis(ImportMoonShotChassisCmd cmd) {
        s_logger.debug("In addMoonShotChassis");

        String url;
        String username;
        String password;
        boolean newChassis = false;
        MoonShotChassisVO moonShotChassisVO = null;
        List<Integer> cartridges = new ArrayList<>();

        ClusterVO clusterVO = _clusterDao.findByUuid(cmd.getClusterId());

        if(clusterVO == null) {
            throw new CloudRuntimeException("Invalid cluster Id");
        }

        if(!clusterVO.getHypervisorType().equals(Hypervisor.HypervisorType.BareMetal)){
            throw new CloudRuntimeException("The provided cluster is not a baremetal cluster");
        }

        try {
            if (StringUtils.isNotBlank(cmd.getCartridges())) {
                String[] cartrgs = cmd.getCartridges().split(",");
                if (cartrgs != null) {
                    for (String cart : cartrgs) {
                        cartridges.add(Integer.valueOf(cart));
                    }
                }
            }
        } catch (Exception e) {
            throw new CloudRuntimeException("cartridges parameter is not in proper format, " + cmd.getCartridges());
        }


        if (StringUtils.isNotBlank(cmd.getId())) {

            moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getId());
            if (moonShotChassisVO == null) {
                throw new CloudRuntimeException("Invalid moonshot chassis id: " + cmd.getId());
            } else {
                url = moonShotChassisVO.getUrl();
                username = moonShotChassisVO.getUsername();
                password = moonShotChassisVO.getPassword();
            }

        } else {

            url = cmd.getUrl();
            username = cmd.getUsername();
            password = cmd.getPassword();

            if (!StringUtils.isNotBlank(url) || !StringUtils.isNotBlank(username) || !StringUtils.isNotBlank(password)) {
                throw new CloudRuntimeException("url, username and password are required when id is not passed");
            }

            MoonShotChassisVO chassis = _moonShotChassisDao.findByUrl(url);

            if(chassis != null) {
                throw new CloudRuntimeException("Moonshot chassis with url: " + url + " already exists. if you wish to import more nodes, then please call this api with id parameter and it's value as :" + chassis.getUuid());
            }

            newChassis = true;
        }

        // Initialize moonshot client
        MoonShotClient client = getMoonshotClient(url, username, password);
        List<Node> nodes = null;
        try {
            nodes = client.getAllNodes();
        } catch (MoonshotClientException e) {
            throw new CloudRuntimeException("unable to fetch moonshot nodes", e);
        }

        if (nodes == null || nodes.isEmpty()) {
            throw new CloudRuntimeException("no nodes returned from the moonshot chassis");
        }

        if (newChassis) {
            // persist moonshot chassis
            moonShotChassisVO = new MoonShotChassisVO();
            moonShotChassisVO.setZoneId(clusterVO.getDataCenterId());
            moonShotChassisVO.setName(cmd.getName());
            moonShotChassisVO.setUsername(cmd.getUsername());
            moonShotChassisVO.setUrl(cmd.getUrl());
            moonShotChassisVO.setPassword(cmd.getPassword());

            moonShotChassisVO = _moonShotChassisDao.persist(moonShotChassisVO);
            s_logger.debug("MoonShot chassis persisted, with id: " + moonShotChassisVO.getId());
        }

        List<MoonShotNodeVO> moonShotNodeVOs = getMoonShotNodeVOs(nodes, moonShotChassisVO, client, cartridges);

        List<HostVO> createdHosts = createHosts(cmd, moonShotNodeVOs, moonShotChassisVO);

        if (createdHosts != null && !createdHosts.isEmpty()) {
            s_logger.info("Created " + createdHosts.size() + " host(s)");
        }

        MoonShotChassisResponse response = new MoonShotChassisResponse();
        response.setUuid(moonShotChassisVO.getUuid());
        response.setName(moonShotChassisVO.getName());
        response.setUrl(moonShotChassisVO.getUrl());
        response.setCount(createdHosts.size());
        response.setObjectName("moonshot");

        return response;
    }

    @Override
    public Pair<? extends List<ListMoonShotChassisResponse>, Integer> listMoonShotChassis(ListMoonShotChassisCmd cmd) {
        s_logger.debug("In listMoonShotChassis");

        Pair<? extends List<ListMoonShotChassisResponse>, Integer> finalResponse = new Pair<>(new ArrayList<ListMoonShotChassisResponse>(), 0);

        if (StringUtils.isNotBlank(cmd.getId())) {
            MoonShotChassisVO moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getId());
            if (moonShotChassisVO == null) {
                throw new CloudRuntimeException("Invalid moonshot chassis id");
            } else {
                List<ListMoonShotChassisResponse> responses = new ArrayList<>();
                responses.add(new ListMoonShotChassisResponse(moonShotChassisVO.getUuid(), moonShotChassisVO.getUrl(), moonShotChassisVO.getName(), moonShotChassisVO.getUsername()));
                return new Pair<>(responses, 1);
            }
        }

        if(!StringUtils.isNotBlank(cmd.getZoneId())) {
            throw new CloudRuntimeException("zoneid is required when id is not passed");
        }

        DataCenterVO zone = _dataCenterDao.findByUuid(cmd.getZoneId());

        if(zone == null) {
            throw new CloudRuntimeException("Invalid zoneid");
        }

        Pair<List<MoonShotChassisVO>, Integer> response = _moonShotChassisDao.listWithCount(zone.getId(), new Filter(MoonShotChassisVO.class, "id", true, cmd.getStartIndex(), cmd.getPageSizeVal()));

        if (response != null && response.first() != null && !response.first().isEmpty()) {
            List<ListMoonShotChassisResponse> resp = new ArrayList<>();
            for (MoonShotChassisVO moonShotChassisVO : response.first()) {
                resp.add(new ListMoonShotChassisResponse(moonShotChassisVO.getUuid(), moonShotChassisVO.getUrl(), moonShotChassisVO.getName(), moonShotChassisVO.getUsername()));
            }
            finalResponse = new Pair<>(resp, response.second());
        }

        return finalResponse;
    }

    @Override
    public Pair<? extends List<ListMoonShotNodeResponse>, Integer> listMoonShotNode(ListMoonShotNodesCmd cmd) {
        s_logger.debug("In listMoonShotNode");

        Pair<? extends List<ListMoonShotNodeResponse>, Integer> finalResponse = new Pair<>(new ArrayList<ListMoonShotNodeResponse>(), 0);

        if (StringUtils.isNotBlank(cmd.getId())) {
            MoonShotNodeVO moonShotNodeVO = _moonShotNodeDao.findByUuid(cmd.getId());
            if (moonShotNodeVO == null) {
                throw new CloudRuntimeException("Invalid moonshot node id");
            } else {
                List<ListMoonShotNodeResponse> responses = new ArrayList<>();
                ListMoonShotNodeResponse response = new ListMoonShotNodeResponse(moonShotNodeVO.getUuid(), moonShotNodeVO.getMoonshotChassisUuid(), moonShotNodeVO.getHostUuid(), moonShotNodeVO.getCartridge(), moonShotNodeVO.getNode(), moonShotNodeVO.getMacAddress(), moonShotNodeVO.getSecondaryMacAddress(), String.valueOf(moonShotNodeVO.getNoOfCores()), String.valueOf(moonShotNodeVO.getMemory()), String.valueOf(moonShotNodeVO.getMaxClockSpeed()));
                responses.add(response);
                return new Pair<>(responses, 1);
            }
        }

        if (StringUtils.isNotBlank(cmd.getChassisId())) {
            MoonShotChassisVO moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getChassisId());
            if (moonShotChassisVO == null) {
                throw new CloudRuntimeException("Invalid moonshot chassis id");
            } else {
                Pair<List<MoonShotNodeVO>, Integer> response = _moonShotNodeDao.searchAndCountByChassisId(moonShotChassisVO.getId(), new Filter(MoonShotNodeVO.class, "id", true, cmd.getStartIndex(), cmd.getPageSizeVal()));
                if (response != null && response.first() != null && !response.first().isEmpty()) {
                    List<ListMoonShotNodeResponse> resp = new ArrayList<>();
                    for(MoonShotNodeVO moonShotNodeVO : response.first()) {
                        resp.add(new ListMoonShotNodeResponse(moonShotNodeVO.getUuid(), moonShotNodeVO.getMoonshotChassisUuid(), moonShotNodeVO.getHostUuid(), moonShotNodeVO.getCartridge(), moonShotNodeVO.getNode(), moonShotNodeVO.getMacAddress(), moonShotNodeVO.getSecondaryMacAddress(), String.valueOf(moonShotNodeVO.getNoOfCores()), String.valueOf(moonShotNodeVO.getMemory()), String.valueOf(moonShotNodeVO.getMaxClockSpeed())));
                    }
                    finalResponse = new Pair<>(resp, response.second());
                }
            }
        } else {
            throw new CloudRuntimeException("moonshot chassis id is required when id is not passed");
        }

        return finalResponse;
    }

    @Override
    @ActionEvent(eventType = "BAREMETAL.NODE.DELETE", eventDescription = "Deleting Moonshot Node", async = true)
    public boolean deleteMoonshotNode(String uuid) {
        return deleteMoonshotNode(_moonShotNodeDao.findByUuid(uuid));
    }

    @Override
    @ActionEvent(eventType = "BAREMETAL.CHASSIS.DELETE", eventDescription = "Deleting Moonshot Chassis", async = true)
    public boolean deleteMoonshotChassis(DeleteMoonShotChassisCmd cmd) {
        boolean success = true;

        MoonShotChassisVO moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getId());
        if(moonShotChassisVO == null) {
            throw new CloudRuntimeException("Invalid moonshot chassis id");
        } else {
            List<MoonShotNodeVO> moonShotNodeVOs = _moonShotNodeDao.searchAndCountByChassisId(moonShotChassisVO.getId(), null).first();
            if(moonShotNodeVOs != null && !moonShotNodeVOs.isEmpty()) {
                for(MoonShotNodeVO moonShotNode : moonShotNodeVOs) {
                    success = success && deleteMoonshotNode(moonShotNode);
                    if(!success) {
                        break;
                    }
                }
            }

            if(success) {
                success = success && _moonShotChassisDao.remove(moonShotChassisVO.getId());
            }
        }

        return success;
    }

    @Override
    @ActionEvent(eventType = "BAREMETAL.CHASSIS.UPDATE", eventDescription = "Updating Moonshot Chassis", async = true)
    public boolean updateMoonshotChassis(UpdateMoonShotChassisCmd cmd) {
        boolean success = true;

        if(!StringUtils.isNotBlank(cmd.getUrl()) && !StringUtils.isNotBlank(cmd.getUsername()) && !StringUtils.isNotBlank(cmd.getPassword())) {
            throw new CloudRuntimeException("please pass at least one of url, username and password");
        }

        String moonshotHost = null;

        if(StringUtils.isNotBlank(cmd.getUrl())) {
            try {
                URI uri = new URI(UriUtils.encodeURIComponent(cmd.getUrl()));
                moonshotHost = InetAddress.getByName(uri.getHost()).getHostAddress();
            } catch (final URISyntaxException e) {
                throw new CloudRuntimeException(cmd.getUrl() + " is not a valid url");
            } catch (UnknownHostException e) {
                throw new CloudRuntimeException(cmd.getUrl() + " is not a valid url");
            }
        }


        MoonShotChassisVO moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getId());
        if(moonShotChassisVO == null) {
            throw new CloudRuntimeException("Invalid moonshot chassis id");
        } else {
            List<MoonShotNodeVO> moonShotNodeVOs = _moonShotNodeDao.searchAndCountByChassisId(moonShotChassisVO.getId(), null).first();
            if(moonShotNodeVOs != null && !moonShotNodeVOs.isEmpty()) {
                for(MoonShotNodeVO moonShotNode : moonShotNodeVOs) {

                    DetailVO ip = _hostDetailsDao.findDetail(moonShotNode.getHostId(), ApiConstants.PRIVATE_IP);
                    DetailVO username = _hostDetailsDao.findDetail(moonShotNode.getHostId(), ApiConstants.USERNAME);
                    DetailVO password = _hostDetailsDao.findDetail(moonShotNode.getHostId(), ApiConstants.PASSWORD);

                    UpdateMoonshotDetailsCommand command = new UpdateMoonshotDetailsCommand();

                    if(StringUtils.isNotBlank(cmd.getUrl())) {
                        moonShotChassisVO.setUrl(cmd.getUrl());
                        ip.setValue(moonshotHost);
                        command.setIp(moonshotHost);
                    }

                    if(StringUtils.isNotBlank(cmd.getUsername())) {
                        moonShotChassisVO.setUsername(cmd.getUsername());
                        username.setValue(cmd.getUsername());
                        command.setUsername(cmd.getUsername());
                    }

                    if(StringUtils.isNotBlank(cmd.getPassword())) {
                        moonShotChassisVO.setPassword(cmd.getPassword());
                        password.setValue(DBEncryptionUtil.encrypt(cmd.getPassword()));
                        command.setPassword(cmd.getPassword());
                    }

                    try {
                        success = success && _agentManager.send(moonShotNode.getHostId(), command).getResult();
                        if(success && StringUtils.isNotBlank(cmd.getUrl())) {
                            success = success && _hostDetailsDao.update(ip.getId(), ip);
                        }
                        if(success && StringUtils.isNotBlank(cmd.getUsername())) {
                            success = success && _hostDetailsDao.update(username.getId(), username);
                        }
                        if(success && StringUtils.isNotBlank(cmd.getPassword())) {
                            success = success && _hostDetailsDao.update(password.getId(), password);
                        }
                    } catch (AgentUnavailableException e) {
                        success = false;
                    } catch (OperationTimedoutException e) {
                        success = false;
                    } catch (Exception e) {
                        success = false;
                    }

                    if(!success) {
                        break;
                    }
                }

                if(success) {
                    success = success && _moonShotChassisDao.update(moonShotChassisVO.getId(), moonShotChassisVO);
                }

            }
        }

        return success;
    }

    private boolean deleteMoonshotNode(MoonShotNodeVO moonShotNodeVO) {
        if (moonShotNodeVO == null) {
            throw new CloudRuntimeException("Invalid moonshot node, cannot delete");
        } else {
            HostVO hostVO = _hostDao.findById(moonShotNodeVO.getHostId());
            if(hostVO != null) {
                return _resourceManager.deleteHost(moonShotNodeVO.getHostId(), true, false) && _moonShotNodeDao.remove(moonShotNodeVO.getId());
            } else { //host already removed, just remove node
                return _moonShotNodeDao.remove(moonShotNodeVO.getId());
            }
        }
    }

    @Override
    public List<Class<?>> getCommands() {
        List<Class<?>> cmds = new ArrayList<>();
        cmds.add(ImportMoonShotChassisCmd.class);
        cmds.add(ListMoonShotChassisCmd.class);
        cmds.add(SyncMoonShotChassisCmd.class);
        cmds.add(DeleteMoonShotChassisCmd.class);
        cmds.add(UpdateMoonShotChassisCmd.class);
        cmds.add(ListMoonShotNodesCmd.class);
        cmds.add(DeleteMoonShotNodeCmd.class);
        return cmds;
    }

    private List<MoonShotNodeVO> getMoonShotNodeVOs(List<Node> nodes, MoonShotChassisVO chassis, MoonShotClient client, List<Integer> cartridgesToBeImported) {
        int mbsInGbs = 1024;
        List<MoonShotNodeVO> nodeVOs = new ArrayList<>();
        for (Node node : nodes) {

            s_logger.debug("Processing node: " + node.getPrimaryMac() + " " + node.getSecondaryMac() + " " + node.getShortName());

            if (!cartridgesToBeImported.isEmpty() && !cartridgesToBeImported.contains(node.getCartridge())) {
                s_logger.debug("Ignoring node: " + node.getShortName() + " As is in not is the passed list of cartridges");
                continue;
            }

            MoonShotNodeVO moonshotNode = _moonShotNodeDao.findByMacAddress(node.getPrimaryMac());

            if (moonshotNode != null) {
                s_logger.debug("Node " + node.getShortName() + " with mac address " + node.getPrimaryMac() + " is already mapped to host with id: " + moonshotNode.getHostId() + " and corresponding moonshot node with id: " + moonshotNode.getId() + " and name: " + moonshotNode.getShortName() + " having " + moonshotNode.getMacAddress() + " and " + moonshotNode.getSecondaryMacAddress() + " mac addresses");
            } else {

                Node fullNode = null; //getAllNode does not give all the data!
                try {
                    fullNode = client.getNode(node.getShortName());
                } catch (MoonshotClientException e) {
                    throw new CloudRuntimeException("Unable to fetch full details for moonshot node " + node.getShortName(), e);
                }
                moonshotNode = new MoonShotNodeVO();
                moonshotNode.setMoonshotChassisId(chassis.getId());
                moonshotNode.setMoonshotChassisUuid(chassis.getUuid());
                moonshotNode.setCartridge(String.valueOf(node.getCartridge()));
                moonshotNode.setNode(String.valueOf(node.getNode()));
                moonshotNode.setNoOfCores(fullNode.getNoOfCores());
                moonshotNode.setMemory(node.getMemory() * mbsInGbs);
                moonshotNode.setMaxClockSpeed(fullNode.getMaxClockSpeed());
                moonshotNode.setMacAddress(node.getPrimaryMac());
                moonshotNode.setSecondaryMacAddress(node.getSecondaryMac());
                nodeVOs.add(moonshotNode);

            }

        }
        return nodeVOs;
    }

    private List<HostVO> createHosts(ImportMoonShotChassisCmd cmd, List<MoonShotNodeVO> moonshotNodes, MoonShotChassisVO moonShotChassisVO) {
        List<HostVO> hosts = new ArrayList<HostVO>();

        ClusterVO clusterVO = _clusterDao.findByUuid(cmd.getClusterId());

        if(clusterVO == null) {
            throw new CloudRuntimeException("Invalid cluster Id");
        }

        for (MoonShotNodeVO node : moonshotNodes) {

            String cartridgeNumber = node.getCartridge();
            String nodeNumber = node.getNode();

            Map<String, String> params = cmd.getFullUrlParams();

            if(params == null) {
                params = new HashMap<>();
            }

            params.put(ApiConstants.BAREMETAL_DISCOVER_NAME, MoonShotBareMetalDiscoverer.class.getName());
            params.put(ApiConstants.HOST_MAC, node.getMacAddress());
            params.put(ApiConstants.PRIVATE_MAC_ADDRESS, node.getSecondaryMacAddress());
            params.put(ApiConstants.CLUSTER_TYPE, "CloudManaged");
            params.put(ApiConstants.CPU_SPEED, String.valueOf(node.getMaxClockSpeed()));
            params.put(ApiConstants.CPU_NUMBER, String.valueOf(node.getNoOfCores()));
            params.put(ApiConstants.MEMORY, String.valueOf(node.getMemory()));
            params.put(CARTRIDGE_NUMBER, cartridgeNumber);
            params.put(NODE_NUMBER, nodeNumber);
            params.put(CARTRIDGE_NODE_LOCATION, node.getShortName());

            cmd.setFullUrlParams(params);

            List<String> tags = new ArrayList<>();
            tags.add(cmd.getHostTag());

            try {
                AddHostCmd addHostCmd = new AddHostCmd();
                addHostCmd.setZoneId(clusterVO.getDataCenterId());
                addHostCmd.setPodId(clusterVO.getPodId());
                addHostCmd.setClusterId(clusterVO.getId());
                addHostCmd.setUrl(moonShotChassisVO.getUrl());
                addHostCmd.setUsername(moonShotChassisVO.getUsername());
                addHostCmd.setPassword(moonShotChassisVO.getPassword());
                addHostCmd.setHostTags(tags);
                addHostCmd.setHypervisor(Hypervisor.HypervisorType.BareMetal.toString());
                addHostCmd.setFullUrlParams(cmd.getFullUrlParams());

                List<? extends Host> discoveredHosts = _resourceManager.discoverHosts(addHostCmd);
                if (discoveredHosts != null && !discoveredHosts.isEmpty()) {
                    HostVO hostVO = (HostVO) discoveredHosts.get(0);
                    node.setHostId(hostVO.getId());
                    node.setHostUuid(hostVO.getUuid());
                    _moonShotNodeDao.persist(node);
                    hosts.add(hostVO);
                } else {
                    s_logger.error("No host discovered for moonshot node : " + node.getShortName());
                }
            } catch (DiscoveryException e) {
                throw new CloudRuntimeException("Error while creating host for ", e);
            } catch (IllegalArgumentException e) {
                throw new CloudRuntimeException("Error while creating host for ", e);
            } catch (InvalidParameterValueException e) {
                throw new CloudRuntimeException("Error while creating host for ", e);
            }
        }

        return hosts;
    }

    @Override
    public List<SyncMoonShotChassisResponse> syncMoonShotChassis(SyncMoonShotChassisCmd cmd) {

        List<SyncMoonShotChassisResponse> response = new ArrayList<>();

        MoonShotChassisVO moonShotChassisVO = _moonShotChassisDao.findByUuid(cmd.getId());

        if(moonShotChassisVO == null) {
            throw new CloudRuntimeException("Invalid moonshot chassis id: " + cmd.getId());
        } else {
            List<MoonShotNodeVO> moonShotNodes = _moonShotNodeDao.searchAndCountByChassisId(moonShotChassisVO.getId(), null).first();

            if(!moonShotNodes.isEmpty()) {
                MoonShotClient client = getMoonshotClient(moonShotChassisVO.getUrl(), moonShotChassisVO.getUsername(), moonShotChassisVO.getPassword());
                List<Node> nodes = null;
                try {
                    nodes = client.getAllNodes();
                } catch (MoonshotClientException e) {
                    throw new CloudRuntimeException("unable to fetch all nodes for sync", e);
                }
                Map<String, Node> macToNodeMap = new LinkedHashMap<>();

                for(Node node : nodes) {
                    macToNodeMap.put(node.getPrimaryMac(), node);
                }

                for(MoonShotNodeVO existingNode : moonShotNodes) {
                    String macKey = existingNode.getMacAddress();

                    if(macToNodeMap.containsKey(macKey)) { // node already exists and it's still there in chassis
                        Node matchingNode = macToNodeMap.get(macKey);

                        if(!existingNode.getShortName().equalsIgnoreCase(matchingNode.getShortName())) { //cartridge relocated

                            String oldCartridgeNodeLocation = existingNode.getShortName();

                            s_logger.debug("updating location of node from " + existingNode.getShortName() + " to " +  matchingNode.getShortName());

                            DetailVO cartrideNodeLocation = _hostDetailsDao.findDetail(existingNode.getHostId(), MoonShotBareMetalManager.CARTRIDGE_NODE_LOCATION);

                            if(cartrideNodeLocation != null) {
                                cartrideNodeLocation.setValue(matchingNode.getShortName());
                                _hostDetailsDao.update(cartrideNodeLocation.getId(), cartrideNodeLocation);
                            }

                            DetailVO cartridgeNumber = _hostDetailsDao.findDetail(existingNode.getHostId(), MoonShotBareMetalManager.CARTRIDGE_NUMBER);

                            if(cartridgeNumber != null) {
                                cartridgeNumber.setValue(String.valueOf(matchingNode.getCartridge()));
                                _hostDetailsDao.update(cartridgeNumber.getId(), cartridgeNumber);
                            }

                            DetailVO nodeNumber = _hostDetailsDao.findDetail(existingNode.getHostId(), MoonShotBareMetalManager.NODE_NUMBER);

                            if(nodeNumber != null) {
                                nodeNumber.setValue(String.valueOf(matchingNode.getNode()));
                                _hostDetailsDao.update(nodeNumber.getId(), nodeNumber);
                            }

                            existingNode.setCartridge(String.valueOf(matchingNode.getCartridge()));
                            existingNode.setNode(String.valueOf(matchingNode.getNode()));

                            _moonShotNodeDao.update(existingNode.getId(), existingNode);

                            HostVO host = _hostDao.findById(existingNode.getHostId());

                            host.setName(host.getPrivateIpAddress() + "-" + matchingNode.getShortName());

                            _hostDao.update(host.getId(), host);

                            SyncMoonShotChassisResponse res = new SyncMoonShotChassisResponse(oldCartridgeNodeLocation, matchingNode.getShortName());

                            response.add(res);

                        }

                        macToNodeMap.remove(macKey);
                    } else { //node exists in MS but not in chassis
                        _resourceManager.deleteHost(existingNode.getHostId(), true, false); //delete host
                        _moonShotNodeDao.remove(existingNode.getId()); // remove node
                    }
                }

            } else {
                throw new CloudRuntimeException("No moonshot cartridges/nodes are available for chassis with id: " + cmd.getId() + " . Please call importMoonShotChassis command with id=" + moonShotChassisVO.getUuid() +" to import cartridges/nodes first");
            }
        }

        return response;
    }

    private MoonShotClient getMoonshotClient(String url, String username, String password) {
        // Initialize moonshot client
        MoonShotClient client;

        try {
            URI uri = new URI(url);
            client = new MoonShotClient(username, password, uri.getHost(), "https", 443); //TODO: Make scheme and port configurable
        } catch (ConfigurationException e) {
            throw new CloudRuntimeException("Error initializing moonshot client", e);
        } catch (URISyntaxException e) {
            throw new CloudRuntimeException("Error initializing moonshot client", e);
        }

        return client;
    }
}
