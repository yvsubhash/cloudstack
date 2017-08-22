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
package com.cloud.moonshot.api;

import com.cloud.moonshot.model.MoonShotChassisVO;
import com.cloud.serializer.Param;
import com.google.gson.annotations.SerializedName;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.cloudstack.api.BaseResponse;
import org.apache.cloudstack.api.EntityReference;

@EntityReference(value = MoonShotChassisVO.class)
public class ListMoonShotNodeResponse extends BaseResponse {

    @SerializedName(ApiConstants.UUID)
    @Param(description = "uuid of Moonshot Node")
    private String uuid;

    @SerializedName("chassisuuid")
    @Param(description = "uuid of Moonshot Chassis")
    private String chassisUuid;

    @SerializedName("hostuuid")
    @Param(description = "uuid of Host")
    private String hostUuid;

    @SerializedName("cartridge")
    @Param(description = "cartridge number of Moonshot Node")
    private String cartridge;

    @SerializedName("node")
    @Param(description = "node number of Moonshot Node")
    private String node;

    @SerializedName("primary_mac_address")
    @Param(description = "primary mac address of Moonshot Node")
    private String primaryMacAddress;

    @SerializedName("secondary_mac_address")
    @Param(description = "secondary mac address of Moonshot Node")
    private String secondaryMacAddress;

    @SerializedName("cores")
    @Param(description = "number of cores in Moonshot Node")
    private String cores;

    @SerializedName("memory")
    @Param(description = "memory of Moonshot Node")
    private String memory;

    @SerializedName("clockspeed")
    @Param(description = "clock speed of Moonshot Node")
    private String clockSpeed;

    public ListMoonShotNodeResponse(String uuid, String chassisUuid, String hostUuid, String cartridge, String node, String primaryMacAddress, String secondaryMacAddress, String cores, String memory, String clockSpeed) {
        this.uuid = uuid;
        this.chassisUuid = chassisUuid;
        this.hostUuid = hostUuid;
        this.cartridge = cartridge;
        this.node = node;
        this.primaryMacAddress = primaryMacAddress;
        this.secondaryMacAddress = secondaryMacAddress;
        this.cores = cores;
        this.memory = memory;
        this.clockSpeed = clockSpeed;
        this.setObjectName("moonshotnode");
    }

    public ListMoonShotNodeResponse() {
        this.setObjectName("moonshotnode");
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getChassisUuid() {
        return chassisUuid;
    }

    public void setChassisUuid(String chassisUuid) {
        this.chassisUuid = chassisUuid;
    }

    public String getHostUuid() {
        return hostUuid;
    }

    public void setHostUuid(String hostUuid) {
        this.hostUuid = hostUuid;
    }

    public String getCartridge() {
        return cartridge;
    }

    public void setCartridge(String cartridge) {
        this.cartridge = cartridge;
    }

    public String getNode() {
        return node;
    }

    public void setNode(String node) {
        this.node = node;
    }

    public String getPrimaryMacAddress() {
        return primaryMacAddress;
    }

    public void setPrimaryMacAddress(String primaryMacAddress) {
        this.primaryMacAddress = primaryMacAddress;
    }

    public String getSecondaryMacAddress() {
        return secondaryMacAddress;
    }

    public void setSecondaryMacAddress(String secondaryMacAddress) {
        this.secondaryMacAddress = secondaryMacAddress;
    }

    public String getCores() {
        return cores;
    }

    public void setCores(String cores) {
        this.cores = cores;
    }

    public String getMemory() {
        return memory;
    }

    public void setMemory(String memory) {
        this.memory = memory;
    }

    public String getClockSpeed() {
        return clockSpeed;
    }

    public void setClockSpeed(String clockSpeed) {
        this.clockSpeed = clockSpeed;
    }
}
