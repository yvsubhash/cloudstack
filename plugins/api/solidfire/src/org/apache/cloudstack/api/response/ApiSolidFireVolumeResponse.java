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
package org.apache.cloudstack.api.response;

import com.cloud.serializer.Param;

import com.google.gson.annotations.SerializedName;

import org.apache.cloudstack.api.BaseResponse;

public class ApiSolidFireVolumeResponse extends BaseResponse {
    @SerializedName("id")
    @Param(description = "CloudStack ID")
    private long _id;

    @SerializedName("uuid")
    @Param(description = "CloudStack UUID")
    private String _uuid;

    @SerializedName("name")
    @Param(description = "Name of volume")
    private String _name;

    @SerializedName("size")
    @Param(description = "Size of volume")
    private long _size;

    @SerializedName("miniops")
    @Param(description = "Min IOPS of volume")
    private long _minIops;

    @SerializedName("maxiops")
    @Param(description = "Max IOPS of volume")
    private long _maxIops;

    @SerializedName("burstiops")
    @Param(description = "Burst IOPS of volume")
    private long _burstIops;

    @SerializedName("accountid")
    @Param(description = "Account ID that the volume is associated with")
    private long _accountId;

    public void setId(long id) {
        _id = id;
    }

    public long getId() {
        return _id;
    }

    public void setUuid(String uuid) {
        _uuid = uuid;
    }

    public String getUuid() {
        return _uuid;
    }

    public void setName(String name) {
        _name = name;
    }

    public String getName() {
        return _name;
    }

    public void setSize(long size) {
        _size = size;
    }

    public long getSize() {
        return _size;
    }

    public void setMinIops(long minIops) {
        _minIops = minIops;
    }

    public long getMinIops() {
        return _minIops;
    }

    public void setMaxIops(long maxIops) {
        _maxIops = maxIops;
    }

    public long getMaxIops() {
        return _maxIops;
    }

    public void setBurstIops(long burstIops) {
        _burstIops = burstIops;
    }

    public long getBurstIops() {
        return _burstIops;
    }

    public void setAccountId(long accountId) {
        _accountId = accountId;
    }

    public long getAccountId() {
        return _accountId;
    }
}