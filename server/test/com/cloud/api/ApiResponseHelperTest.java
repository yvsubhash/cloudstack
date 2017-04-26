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
package com.cloud.api;

import com.cloud.dc.DataCenterVO;
import com.cloud.dc.HostPodVO;
import com.cloud.domain.DomainVO;
import com.cloud.usage.UsageVO;
import com.cloud.user.AccountVO;
import org.apache.cloudstack.api.response.PodResponse;
import org.apache.cloudstack.api.response.UsageRecordResponse;
import org.apache.cloudstack.usage.UsageService;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import java.lang.reflect.Field;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import static org.junit.Assert.assertEquals;
import static org.mockito.Matchers.anyLong;
import static org.mockito.Mockito.when;

@RunWith(PowerMockRunner.class)
@PrepareForTest(ApiDBUtils.class)
public class ApiResponseHelperTest {

    @Mock
    UsageService usageService;

    ApiResponseHelper helper;

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss ZZZ");

    @Before
    public void injectMocks() throws SecurityException, NoSuchFieldException,
            IllegalArgumentException, IllegalAccessException {
        Field usageSvcField = ApiResponseHelper.class
                .getDeclaredField("_usageSvc");
        usageSvcField.setAccessible(true);
        helper = new ApiResponseHelper();
        usageSvcField.set(helper, usageService);
    }

    @Test
    public void getDateStringInternal() throws ParseException {
        Mockito.when(usageService.getUsageTimezone()).thenReturn(
                TimeZone.getTimeZone("UTC"));
        assertEquals("2014-06-29'T'23:45:00+00:00", helper
                .getDateStringInternal(dateFormat.parse("2014-06-29 23:45:00 UTC")));
        assertEquals("2014-06-29'T'23:45:01+00:00", helper
                .getDateStringInternal(dateFormat.parse("2014-06-29 23:45:01 UTC")));
        assertEquals("2014-06-29'T'23:45:11+00:00", helper
                .getDateStringInternal(dateFormat.parse("2014-06-29 23:45:11 UTC")));
        assertEquals("2014-06-29'T'23:05:11+00:00", helper
                .getDateStringInternal(dateFormat.parse("2014-06-29 23:05:11 UTC")));
        assertEquals("2014-05-29'T'08:45:11+00:00", helper
                .getDateStringInternal(dateFormat.parse("2014-05-29 08:45:11 UTC")));
    }

    @Test
    public void testUsageRecordResponse(){
        //Creating the usageVO object to be passed to the createUsageResponse.
        Long zoneId = null;
        Long accountId = null;
        Long domainId = null;
        String Description = "Test Object";
        String usageDisplay = " ";
        int usageType = -1;
        Double rawUsage = null;
        Long vmId = null;
        String vmName = " ";
        Long offeringId = null;
        Long templateId = null;
        Long usageId = null;
        Date startDate = null;
        Date endDate = null;
        String type = " ";
        UsageVO usage = new UsageVO(zoneId,accountId,domainId,Description,usageDisplay,usageType,rawUsage,vmId,vmName,offeringId,templateId,usageId,startDate,endDate,type);

        DomainVO domain = new DomainVO();
        domain.setName("DomainName");

        AccountVO account = new AccountVO();

        PowerMockito.mockStatic(ApiDBUtils.class);
        when(ApiDBUtils.findAccountById(anyLong())).thenReturn(account);
        when(ApiDBUtils.findDomainById(anyLong())).thenReturn(domain);

        UsageRecordResponse MockResponse = helper.createUsageResponse(usage);
        assertEquals("DomainName",MockResponse.getDomainName());
    }

    @Test
    public void testCreatePodResponse(){
        String name = " ";
        long dcId = 1l;
        String gateway = " ";
        String cidrAddress = " ";
        int cidrSize = 1;
        String description = " ";
        List<String> startIp, endIp;
        PodResponse mockResponse;

        HostPodVO pod = new HostPodVO(name, dcId, gateway, cidrAddress, cidrSize, description);

        DataCenterVO zone = null;
        PowerMockito.mockStatic(ApiDBUtils.class);
        when(ApiDBUtils.findZoneById(1l)).thenReturn(zone);

        pod.setDescription("1-2,3-4");
        mockResponse = helper.createPodResponse(pod, false);

        startIp = mockResponse.getStartIp();
        endIp = mockResponse.getEndIp();

        //Multiple.
        assertEquals("1", startIp.get(0));
        assertEquals("2", endIp.get(0));
        assertEquals("3", startIp.get(1));
        assertEquals("4", endIp.get(1));

        pod.setDescription("1-2");
        mockResponse = helper.createPodResponse(pod, false);

        startIp = mockResponse.getStartIp();
        endIp = mockResponse.getEndIp();

        //Single.
        assertEquals("1", startIp.get(0));
        assertEquals("2", endIp.get(0));
    }
}
