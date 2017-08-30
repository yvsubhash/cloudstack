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
package org.apache.cloudstack.api.command.admin.network;

import org.apache.log4j.Logger;

import org.apache.cloudstack.api.APICommand;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.cloudstack.api.ApiErrorCode;
import org.apache.cloudstack.api.BaseAsyncCmd;
import org.apache.cloudstack.api.Parameter;
import org.apache.cloudstack.api.response.PodResponse;
import org.apache.cloudstack.api.ServerApiException;
import org.apache.cloudstack.api.response.SuccessResponse;

import com.cloud.event.EventTypes;
import com.cloud.exception.ConcurrentOperationException;
import com.cloud.exception.InsufficientCapacityException;
import com.cloud.exception.ResourceAllocationException;
import com.cloud.exception.ResourceUnavailableException;
import com.cloud.user.Account;

@APICommand(name = "deleteManagementNetworkIpRange",
        description = "Deletes a management network IP range. This action is only allowed when no IPs in this range are allocated.",
        responseObject = SuccessResponse.class,
        since = "4.10.0.0",
        requestHasSensitiveInfo = false,
        responseHasSensitiveInfo = false)
public class DeleteManagementNetworkIpRangeCmd extends BaseAsyncCmd {
    public static final Logger s_logger = Logger.getLogger(DeleteManagementNetworkIpRangeCmd.class);

    private static final String s_name = "deletemanagementnetworkiprangeresponse";

    /////////////////////////////////////////////////////
    //////////////// API parameters /////////////////////
    /////////////////////////////////////////////////////

    @Parameter(name = ApiConstants.POD_ID,
            type = CommandType.UUID,
            entityType = PodResponse.class,
            required = true,
            description = "UUID of POD, where the IP range belongs to.")
    private Long podId;

    @Parameter(name = ApiConstants.START_IP,
            type = CommandType.STRING,
            required = true,
            description = "The starting IP address.")
    private String startIp;

    @Parameter(name = ApiConstants.END_IP,
            type = CommandType.STRING,
            required = true,
            description = "The ending IP address.")
    private String endIp;

    /////////////////////////////////////////////////////
    /////////////////// Accessors ///////////////////////
    /////////////////////////////////////////////////////

    public Long getPodId() {
        return podId;
    }

    public String getStartIp() {
        return startIp;
    }

    public String getEndIp() {
        return endIp;
    }

    @Override
    public String getEventType() {
        return EventTypes.EVENT_MANAGEMENT_IP_RANGE_DELETE;
    }

    @Override
    public String getEventDescription() {
        return "Deleting management ip range from " + getStartIp() + " to " + getEndIp() + " of Pod: " + getPodId();
    }

    @Override
    public void execute() throws ResourceUnavailableException, InsufficientCapacityException, ServerApiException, ConcurrentOperationException,
            ResourceAllocationException {
        try {
            _configService.deletePodIpRange(this);
            SuccessResponse response = new SuccessResponse(getCommandName());
            this.setResponseObject(response);
        } catch (Exception e) {
            s_logger.warn("Failed to delete management ip range from " + getStartIp() + " to " + getEndIp() + " of Pod: " + getPodId(), e);
            throw new ServerApiException(ApiErrorCode.INTERNAL_ERROR, e.getMessage());
        }
    }

    @Override
    public String getCommandName() {
        return s_name;
    }

    @Override
    public long getEntityOwnerId() {
        return Account.ACCOUNT_ID_SYSTEM;
    }

}