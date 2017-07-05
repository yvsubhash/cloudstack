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
package com.cloud.offering;

import org.apache.cloudstack.acl.InfrastructureEntity;
import org.apache.cloudstack.api.Identity;
import org.apache.cloudstack.api.InternalIdentity;

import com.cloud.network.Network.GuestType;
import com.cloud.network.Networks.TrafficType;

/**
 * Describes network offering
 *
 */
public interface NetworkOffering extends InfrastructureEntity, InternalIdentity, Identity {

    enum Availability {
        Required, Optional
    }

    enum State {
        Disabled, Enabled
    }

    enum Detail {
        InternalLbProvider, PublicLbProvider, servicepackageuuid, servicepackagedescription, BaremetalInternalStorageServerIP
    }

    String SystemPublicNetwork = "System-Public-Network";
    String SystemControlNetwork = "System-Control-Network";
    String SystemManagementNetwork = "System-Management-Network";
    String SystemStorageNetwork = "System-Storage-Network";
    String SystemPrivateGatewayNetworkOffering = "System-Private-Gateway-Network-Offering";

    String DefaultSharedNetworkOfferingWithSGService = "DefaultSharedNetworkOfferingWithSGService";
    String QuickCloudNoServices = "QuickCloudNoServices";
    String DefaultIsolatedNetworkOfferingWithSourceNatService = "DefaultIsolatedNetworkOfferingWithSourceNatService";
    String OvsIsolatedNetworkOfferingWithSourceNatService = "OvsIsolatedNetworkOfferingWithSourceNatService";
    String DefaultSharedNetworkOffering = "DefaultSharedNetworkOffering";
    String DefaultIsolatedNetworkOffering = "DefaultIsolatedNetworkOffering";
    String DefaultSharedEIPandELBNetworkOffering = "DefaultSharedNetscalerEIPandELBNetworkOffering";
    String DefaultIsolatedNetworkOfferingForVpcNetworks = "DefaultIsolatedNetworkOfferingForVpcNetworks";
    String DefaultIsolatedNetworkOfferingForVpcNetworksNoLB = "DefaultIsolatedNetworkOfferingForVpcNetworksNoLB";
    String DefaultIsolatedNetworkOfferingForVpcNetworksWithInternalLB = "DefaultIsolatedNetworkOfferingForVpcNetworksWithInternalLB";

    /**
     * @return name for the network offering.
     */
    String getName();

    /**
     * @return text to display to the end user.
     */
    String getDisplayText();

    /**
     * @return the rate in megabits per sec to which a VM's network interface is throttled to
     */
    Integer getRateMbps();

    /**
     * @return the rate megabits per sec to which a VM's multicast&broadcast traffic is throttled to
     */
    Integer getMulticastRateMbps();

    TrafficType getTrafficType();

    boolean getSpecifyVlan();

    String getTags();

    boolean isDefault();

    boolean isSystemOnly();

    Availability getAvailability();

    String getUniqueName();

    void setState(State state);

    State getState();

    GuestType getGuestType();

    Long getServiceOfferingId();

    boolean getDedicatedLB();

    boolean getSharedSourceNat();

    boolean getRedundantRouter();

    boolean isConserveMode();

    boolean getElasticIp();

    boolean getAssociatePublicIP();

    boolean getElasticLb();

    boolean getSpecifyIpRanges();

    boolean isInline();

    boolean getIsPersistent();

    boolean getInternalLb();

    boolean getPublicLb();

    boolean getEgressDefaultPolicy();

    Integer getConcurrentConnections();

    boolean isKeepAliveEnabled();

    boolean getSupportsStrechedL2();

    boolean getSupportsPublicAccess();

    String getServicePackage();
}
