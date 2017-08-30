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
package org.apache.cloudstack.api.command.user.job;

import com.cloud.event.EventTypes;
import com.cloud.exception.ResourceUnavailableException;
import com.cloud.user.Account;
import org.apache.cloudstack.acl.RoleType;
import org.apache.cloudstack.api.APICommand;
import org.apache.cloudstack.api.ApiCommandJobType;
import org.apache.cloudstack.api.ApiConstants;
import org.apache.cloudstack.api.ApiErrorCode;
import org.apache.cloudstack.api.BaseCmd;
import org.apache.cloudstack.api.Parameter;
import org.apache.cloudstack.api.ServerApiException;
import org.apache.cloudstack.api.command.user.vm.DestroyVMCmd;
import org.apache.cloudstack.api.response.AsyncJobResponse;
import org.apache.cloudstack.jobs.AsyncJobService;
import org.apache.log4j.Logger;
import com.google.common.base.Strings;

import javax.inject.Inject;

@APICommand(name = "cancelAsyncJob", description = "Cancel asynchronous job.",
        responseObject = AsyncJobResponse.class,
        requestHasSensitiveInfo = false, responseHasSensitiveInfo = false, since = "4.10.0.0", authorized = {RoleType.Admin})
public class CancelAsyncJobCmd extends BaseCmd {
    public static final Logger s_logger = Logger.getLogger(DestroyVMCmd.class.getName());

    private static final String s_name = "cancelasyncjobresponse";

    @Parameter(name = ApiConstants.ID, type = CommandType.UUID, entityType = AsyncJobResponse.class,
            required = true, description = "The ID of the job to cancel")
    protected Long id;

    @Inject
    private AsyncJobService asyncJobService;


    public String getEventType() {
        return EventTypes.EVENT_JOB_CANCEL;
    }

    public String getEventDescription() {
        return "cancelling job with id: " + id;
    }

    @Override
    public void execute() throws ResourceUnavailableException, ClassNotFoundException {
        String errorString = asyncJobService.cancelAsyncJob(id, "cancel request by user using cancelAsyncJob api");
        if(Strings.isNullOrEmpty(errorString)) {
            AsyncJobResponse response = _responseGenerator.queryJobResult(this);
            response.setResponseName(getCommandName());
            setResponseObject(response);
        } else {
            throw new ServerApiException(ApiErrorCode.INTERNAL_ERROR, errorString);
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

    public ApiCommandJobType getInstanceType() {
        return ApiCommandJobType.Job;
    }

    public Long getInstanceId() {
        return getId();
    }

    public Long getId() {
        return id;
    }
}