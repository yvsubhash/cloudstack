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
package com.cloud.moonshot.api;

import com.cloud.moonshot.manager.MoonShotBareMetalManager;
import org.apache.cloudstack.acl.RoleType;
import org.apache.cloudstack.api.APICommand;
import org.apache.cloudstack.api.ApiErrorCode;
import org.apache.cloudstack.api.BaseListCmd;
import org.apache.cloudstack.api.Parameter;
import org.apache.cloudstack.api.ServerApiException;
import org.apache.cloudstack.api.response.ListResponse;
import org.apache.cloudstack.context.CallContext;
import org.apache.log4j.Logger;

import javax.inject.Inject;
import java.util.List;

/**
 * Created by Raghav on 8/13/2015.
 */
@APICommand(name = "syncMoonShotChassis", description = "Syncs Moonshot Chassis cartridges", responseObject = SyncMoonShotChassisResponse.class,
        requestHasSensitiveInfo = false, responseHasSensitiveInfo = false, authorized = {RoleType.Admin})
public class SyncMoonShotChassisCmd extends BaseListCmd {

    private static final String s_name = "syncmoonshotchassisresponse";

    public static final Logger s_logger = Logger.getLogger(SyncMoonShotChassisCmd.class);

    @Inject
    MoonShotBareMetalManager _moonShotBareMetalMgr;

    @Parameter(name = "id", required = true, description = "Id of the moonshot chassis")
    private String id;

    public SyncMoonShotChassisCmd() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @Override
    public String getCommandName() {
        return s_name;
    }

    @Override
    public long getEntityOwnerId() {
        return CallContext.current().getCallingAccount().getId();
    }

    @Override
    public void execute() {
        try {
            List<SyncMoonShotChassisResponse> rsp = _moonShotBareMetalMgr.syncMoonShotChassis(this);
            ListResponse<SyncMoonShotChassisResponse> response = new ListResponse<>();
            response.setResponses(rsp, rsp.size());
            response.setResponseName(getCommandName());
            setResponseObject(response);
        } catch (Exception e) {
            s_logger.warn("unable to sync Moonshot Chassis with id: " + id, e);
            throw new ServerApiException(ApiErrorCode.INTERNAL_ERROR, e.getMessage());
        }
    }
}
