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
package com.cloud.agent.api.to;

import java.net.URI;
import java.util.List;

import com.cloud.network.Networks.BroadcastDomainType;
import com.cloud.network.Networks.TrafficType;

public class NicTO {
    NetworkTO net;
    public BroadcastDomainType getBroadcastType() {
        return net.getBroadcastType();
    }

    public void setBroadcastType(BroadcastDomainType broadcastType) {
        net.setBroadcastType(broadcastType);
    }

    public void setIp(String ip) {
        net.setIp(ip);
    }

    public void setNetmask(String netmask) {
        net.setNetmask(netmask);
    }

    public void setGateway(String gateway) {
        net.setGateway(gateway);
    }

    public void setMac(String mac) {
        net.setMac(mac);
    }

    public void setDns1(String dns1) {
        net.setDns1(dns1);
    }

    public void setDns2(String dns2) {
        net.setDns2(dns2);
    }

    public void setType(TrafficType type) {
        net.setType(type);
    }

    public void setName(String name) {
        net.setName(name);
    }

    public String getName() {
        return net.getName();
    }

    public void setSecurityGroupEnabled(boolean enabled) {
        net.setSecurityGroupEnabled(enabled);
    }

    public String getIp() {
        return net.getIp();
    }

    public String getNetmask() {
        return net.getNetmask();
    }

    public String getGateway() {
        return net.getGateway();
    }

    public String getMac() {
        return net.getMac();
    }

    public String getDns1() {
        return net.getDns1();
    }

    public String getDns2() {
        return net.getDns2();
    }

    public TrafficType getType() {
        return net.getType();
    }

    public URI getBroadcastUri() {
        return net.getBroadcastUri();
    }

    public void setBroadcastUri(URI broadcastUri) {
        net.setBroadcastUri(broadcastUri);
    }

    public URI getIsolationUri() {
        return net.getIsolationUri();
    }

    public void setIsolationuri(URI isolationUri) {
        net.setIsolationuri(isolationUri);
    }

    public boolean isSecurityGroupEnabled() {
        return net.isSecurityGroupEnabled();
    }

    int deviceId;
    Integer networkRateMbps;
    Integer networkRateMulticastMbps;
    boolean defaultNic;
    boolean pxeDisable;
    String nicUuid;
    List<String> nicSecIps;

    public NicTO() {
        net = new NetworkTO();
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public Integer getNetworkRateMbps() {
        return networkRateMbps;
    }

    public void setNetworkRateMbps(Integer networkRateMbps) {
        this.networkRateMbps = networkRateMbps;
    }

    public Integer getNetworkRateMulticastMbps() {
        return networkRateMulticastMbps;
    }

    public boolean isDefaultNic() {
        return defaultNic;
    }

    public void setDefaultNic(boolean defaultNic) {
        this.defaultNic = defaultNic;
    }

    public void setPxeDisable(boolean pxeDisable) {
        this.pxeDisable = pxeDisable;
    }

    public boolean getPxeDisable() {
        return pxeDisable;
    }

    public String getUuid() {
        return nicUuid;
    }

    public void setUuid(String uuid) {
        this.nicUuid = uuid;
    }

    @Override
    public String toString() {
        return new StringBuilder("[Nic:").append(net.type).append("-").append(net.ip).append("-").append(net.broadcastUri).append("]").toString();
    }

    public void setNicSecIps(List<String> secIps) {
        this.nicSecIps = secIps;
    }

    public List<String> getNicSecIps() {
        return nicSecIps;
    }

    public String getNetworkUuid() {
        return net.getUuid();
    }

    public void setNetworkUuid(String uuid) {
        net.setUuid(uuid);
    }
}
