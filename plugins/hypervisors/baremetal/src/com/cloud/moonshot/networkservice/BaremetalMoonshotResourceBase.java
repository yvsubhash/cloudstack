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
package com.cloud.moonshot.networkservice;

import com.cloud.agent.api.Answer;
import com.cloud.agent.api.Command;
import com.cloud.agent.api.MigrateAnswer;
import com.cloud.agent.api.MigrateCommand;
import com.cloud.agent.api.PingCommand;
import com.cloud.agent.api.PingRoutingCommand;
import com.cloud.agent.api.RebootAnswer;
import com.cloud.agent.api.RebootCommand;
import com.cloud.agent.api.SecurityGroupRulesCmd;
import com.cloud.agent.api.StartAnswer;
import com.cloud.agent.api.StartCommand;
import com.cloud.agent.api.StartupCommand;
import com.cloud.agent.api.StartupRoutingCommand;
import com.cloud.agent.api.StopAnswer;
import com.cloud.agent.api.StopCommand;
import com.cloud.agent.api.baremetal.IpmISetBootDevCommand;
import com.cloud.agent.api.baremetal.IpmiBootorResetCommand;
import com.cloud.agent.api.to.VirtualMachineTO;
import com.cloud.baremetal.networkservice.BareMetalResourceBase;
import com.cloud.configuration.Config;
import com.cloud.hypervisor.Hypervisor;
import com.cloud.moonshot.client.MoonShotClient;
import com.cloud.moonshot.client.model.BootTarget;
import com.cloud.moonshot.client.model.MoonshotClientException;
import com.cloud.moonshot.client.model.ResetType;
import com.cloud.moonshot.manager.MoonShotBareMetalManager;
import com.cloud.utils.StringUtils;
import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.vm.dao.VMInstanceDao;
import com.cloud.wds.api.UpdateMoonshotDetailsCommand;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.cloudstack.framework.config.dao.ConfigurationDao;
import org.apache.log4j.Logger;

import javax.naming.ConfigurationException;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Raghav on 8/13/2015.
 */
public class BaremetalMoonshotResourceBase extends BareMetalResourceBase {
    private static final Logger s_logger = Logger.getLogger(BaremetalMoonshotResourceBase.class);
    protected String _cartridgeNodeLocation;
    protected String _secondaryMac;
    protected MoonShotClient _moonshotClient;

    private static final String HTTPS = "https";
    private static final int PORT = 443;

    @Override
    public boolean configure(String name, Map<String, Object> params) throws ConfigurationException {
        s_logger.debug("Configuring Baremetal resource. Mac:" + (String) params.get(ApiConstants.HOST_MAC) + " CartridgeNodeLocation:" + (String) params.get(MoonShotBareMetalManager.CARTRIDGE_NODE_LOCATION));
        _name = name;
        _uuid = (String) params.get("guid");
        try {
            _memCapacity = Long.parseLong((String) params.get(ApiConstants.MEMORY)) * 1024L * 1024L;
            _cpuCapacity = Long.parseLong((String) params.get(ApiConstants.CPU_SPEED));
            _cpuNum = Long.parseLong((String) params.get(ApiConstants.CPU_NUMBER));
        } catch (NumberFormatException e) {
            throw new ConfigurationException(String.format("Unable to parse number of CPU or memory capacity "
                            + "or cpu capacity(cpu number = %1$s memCapacity=%2$s, cpuCapacity=%3$s", params.get(ApiConstants.CPU_NUMBER),
                    params.get(ApiConstants.MEMORY), params.get(ApiConstants.CPU_SPEED)));
        }

        _zone = (String) params.get("zone");
        _pod = (String) params.get("pod");
        _cluster = (String) params.get("cluster");
        hostId = (Long) params.get("hostId");
        _ip = (String) params.get(ApiConstants.PRIVATE_IP);
        _mac = (String) params.get(ApiConstants.HOST_MAC);
        _secondaryMac = (String) params.get(ApiConstants.PRIVATE_MAC_ADDRESS);
        _username = (String) params.get(ApiConstants.USERNAME);
        _password = (String) params.get(ApiConstants.PASSWORD);
        _vmName = (String) params.get("vmName");
        _cartridgeNodeLocation = (String) params.get(MoonShotBareMetalManager.CARTRIDGE_NODE_LOCATION);
        _moonshotClient = new MoonShotClient(_username, _password, _ip, HTTPS, PORT);
        vmDao = (VMInstanceDao) params.get("vmDao");
        configDao = (ConfigurationDao) params.get("configDao");

        if (_pod == null) {
            throw new ConfigurationException("Unable to get the pod");
        }

        if (_cluster == null) {
            throw new ConfigurationException("Unable to get the pod");
        }

        if (_ip == null) {
            throw new ConfigurationException("Unable to get the host address");
        }

        if (_mac.equalsIgnoreCase("unknown")) {
            throw new ConfigurationException("Unable to get the host mac address");
        }

        if (_mac.split(":").length != 6) {
            throw new ConfigurationException("Wrong MAC format(" + _mac
                    + "). It must be in format of for example 00:11:ba:33:aa:dd which is not case sensitive");
        }

        if (_uuid == null) {
            throw new ConfigurationException("Unable to get the uuid");
        }

        try {
            ipmiRetryTimes = Integer.valueOf(configDao.getValue(Config.BaremetalIpmiRetryTimes.key()));
        } catch (Exception e) {
            s_logger.error(e.getMessage(), e);
        }

        s_logger.debug("Successfully configured Baremetal resource");
        return true;
    }

    @Override
    public StartupCommand[] initialize() {
        StartupRoutingCommand cmd = new StartupRoutingCommand(0, 0, 0, 0, null, Hypervisor.HypervisorType.BareMetal,
                new HashMap<String, String>());

        cmd.setDataCenter(_zone);
        cmd.setPod(_pod);
        cmd.setCluster(_cluster);
        cmd.setGuid(_uuid);
        cmd.setName(_ip + "-" + _cartridgeNodeLocation);
        cmd.setPrivateIpAddress(_ip);
        cmd.setStorageIpAddress(_ip);
        cmd.setVersion(BareMetalResourceBase.class.getPackage().getImplementationVersion());
        cmd.setCpus((int) _cpuNum);
        cmd.setSpeed(_cpuCapacity);
        cmd.setMemory(_memCapacity);
        cmd.setPrivateMacAddress(_secondaryMac);
        cmd.setPublicMacAddress(_mac);
        return new StartupCommand[] { cmd };
    }

    @Override
    public PingCommand getCurrentStatus(long id) {
        try {
            if (!_moonshotClient.pingNode(_cartridgeNodeLocation)) {
                Thread.sleep(10000); //TODO - make it config based.
                if (!_moonshotClient.pingNode(_cartridgeNodeLocation)) {
                    s_logger.warn("Cannot ping" + _cartridgeNodeLocation);
                    return null;
                }
            }
        } catch (Exception e) {
            s_logger.debug("Cannot ping" + _cartridgeNodeLocation, e);
            return null;
        }

        return new PingRoutingCommand(getType(), id, null);
    }

    @Override
    protected Answer execute(IpmISetBootDevCommand cmd) {
        BootTarget bootTarget = null;
        if (cmd.getBootDev() == IpmISetBootDevCommand.BootDev.disk) {
            bootTarget = BootTarget.M2;
        } else if (cmd.getBootDev() == IpmISetBootDevCommand.BootDev.pxe) {
            bootTarget = BootTarget.PXE;
        } else {
            throw new CloudRuntimeException("Unkonwn boot dev " + cmd.getBootDev());
        }

        String bootDev = cmd.getBootDev().name();
        boolean success = false;

        try {
            success = _moonshotClient.bootOnce(_cartridgeNodeLocation, bootTarget);
        } catch (MoonshotClientException e) {
            return new Answer(cmd, e);
        }

        if (!success) {
            s_logger.warn("Set " + _cartridgeNodeLocation + " boot dev to " + bootDev + "failed");
            return new Answer(cmd, false, "Set " + _cartridgeNodeLocation + " boot dev to " + bootDev + "failed");
        } else {
            s_logger.warn("Set " + _cartridgeNodeLocation + " boot dev to " + bootDev + "Success");
            return new Answer(cmd, true, "Set " + _cartridgeNodeLocation + " boot dev to " + bootDev + "Success");
        }
    }

    @Override
    protected MigrateAnswer execute(MigrateCommand cmd) {
        boolean success = false;
        try {
            success = _moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.OFF);
        } catch (MoonshotClientException e) {
            return new MigrateAnswer(cmd, false, e.getMessage(), null);
        }
        return success ? new MigrateAnswer(cmd, true, "success", null) : new MigrateAnswer(cmd, false, "Power off failed", null);
    }

    @Override
    protected Answer execute(IpmiBootorResetCommand cmd) {
        String failureMessage = "Boot or reboot failed";

        try {
            String status = _moonshotClient.getPowerStatus(_cartridgeNodeLocation);
            if(ResetType.ON.toString().equalsIgnoreCase(status)) {
                if(!_moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.RESET)) {
                    return new Answer(cmd, false, failureMessage);
                }
            } else if(ResetType.OFF.toString().equalsIgnoreCase(status)) {
                if(!_moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.ON)) {
                    return new Answer(cmd, false, failureMessage);
                }
            } else {
                return new Answer(cmd, false, failureMessage);
            }
        } catch (MoonshotClientException e) {
            return new Answer(cmd, e);
        }

        return new Answer(cmd, true, "Success");
    }

    @Override
    public Answer executeRequest(Command cmd) {
        if (cmd instanceof SecurityGroupRulesCmd) {
            return Answer.createUnsupportedCommandAnswer(cmd);
        } else if(cmd instanceof UpdateMoonshotDetailsCommand) {
            return execute((UpdateMoonshotDetailsCommand) cmd);
        } else {
            return super.executeRequest(cmd);
        }
    }

    private Answer execute(UpdateMoonshotDetailsCommand cmd) {
        String ip = _ip;
        String username = _username;
        String password = _password;

        if(StringUtils.isNotBlank(cmd.getIp())) {
            ip = cmd.getIp();
        }

        if(StringUtils.isNotBlank(cmd.getUsername())) {
            username = cmd.getUsername();
        }

        if(StringUtils.isNotBlank(cmd.getPassword())) {
            password = cmd.getPassword();
        }

        try {
            MoonShotClient client = new MoonShotClient(username, password, ip, HTTPS, PORT);
            if(client.pingNode(_cartridgeNodeLocation)) {
                _ip = ip;
                _username = username;
                _password = password;
                _moonshotClient = client;
                return new Answer(cmd);
            } else {
                s_logger.error("unable to update details of moonshot node " + _cartridgeNodeLocation + "with ip=" + ip + ", username=" + username + ", password=" + password);
                return new Answer(cmd, false, "unable to update details of moonshot node " + _cartridgeNodeLocation + "with ip=" + ip + ", username=" + username + ", password=" + password);
            }
        } catch (ConfigurationException e) {
            return new Answer(cmd, e);
        } catch (MoonshotClientException e) {
            return new Answer(cmd, e);
        } catch (Exception e) {
            return new Answer(cmd, e);
        }
    }

    @Override
    protected RebootAnswer execute(RebootCommand cmd) {
        boolean success = false;
        try {
            success = _moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.RESET);
        } catch (MoonshotClientException e) {
            return new RebootAnswer(cmd, e.getMessage(), false);
        }
        return success ?  new RebootAnswer(cmd, "Reboot succeeded", true) : new RebootAnswer(cmd, "Reboot failed", false);
    }

    @Override
    protected StopAnswer execute(StopCommand cmd) {
        boolean success = false;
        int count = 0;
        ResetType powerOff = ResetType.OFF;

        while (count < 10) {
            try {
                if (!_moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, powerOff)) {
                    break;
                }
            } catch (MoonshotClientException e) {
                return new StopAnswer(cmd, e.getMessage(), false);
            }

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                break;
            }

            String status = null;
            try {
                status = _moonshotClient.getPowerStatus(_cartridgeNodeLocation);
            } catch (MoonshotClientException e) {
                return new StopAnswer(cmd, e.getMessage(), false);
            }
            if (ResetType.OFF.toString().equalsIgnoreCase(status)) {
                success = true;
                break;
            } else if (ResetType.ON.toString().equalsIgnoreCase(status)) {
                powerOff = ResetType.OFF; // think of option force off
            } else {
                success = true;
                s_logger.warn("Cannot get power status of " + _name + ", assume VM state changed successfully");
                break;
            }

            count++;
        }

        return success ? new StopAnswer(cmd, "Success", true) : new StopAnswer(cmd, "Power off failed", false);
    }

    @Override
    protected StartAnswer execute(StartCommand cmd) {
        VirtualMachineTO vm = cmd.getVirtualMachine();

        try {
            String status = _moonshotClient.getPowerStatus(_cartridgeNodeLocation);
            if(ResetType.ON.toString().equalsIgnoreCase(status)) {
                if(!_moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.RESET)) {
                    return new StartAnswer(cmd, "Node reboot failed");
                }
            } else if(ResetType.OFF.toString().equalsIgnoreCase(status)) {
                if(!_moonshotClient.setNodePowerStatus(_cartridgeNodeLocation, ResetType.ON)) {
                    return new StartAnswer(cmd, "Node power on failed");
                }
            } else {
                return new StartAnswer(cmd, "Cannot get current power status of " + _cartridgeNodeLocation);
            }
        } catch (MoonshotClientException e) {
            return new StartAnswer(cmd, e);
        }

        s_logger.debug("Start bare metal vm " + vm.getName() + "successfully");
        _vmName = vm.getName();
        return new StartAnswer(cmd);
    }
}