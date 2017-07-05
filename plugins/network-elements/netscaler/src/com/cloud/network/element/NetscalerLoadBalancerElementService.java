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
package com.cloud.network.element;

import java.util.List;
import java.util.Map;

import com.cloud.api.commands.AddNetscalerLoadBalancerCmd;
import com.cloud.api.commands.ConfigureNetscalerLoadBalancerCmd;
import com.cloud.api.commands.DeleteNetscalerControlCenterCmd;
import com.cloud.api.commands.DeleteNetscalerLoadBalancerCmd;
import com.cloud.api.commands.DeleteServicePackageOfferingCmd;
import com.cloud.api.commands.DeployNetscalerVpxCmd;
import com.cloud.api.commands.ListNetscalerControlCenterCmd;
import com.cloud.api.commands.ListNetscalerLoadBalancerNetworksCmd;
import com.cloud.api.commands.ListNetscalerLoadBalancersCmd;
import com.cloud.api.commands.ListRegisteredServicePackageCmd;
import com.cloud.api.commands.RegisterNetscalerControlCenterCmd;
import com.cloud.api.commands.RegisterServicePackageCmd;
import com.cloud.api.response.NetScalerServicePackageResponse;
import com.cloud.api.response.NetscalerControlCenterResponse;
import com.cloud.api.response.NetscalerLoadBalancerResponse;
import com.cloud.exception.ConcurrentOperationException;
import com.cloud.exception.ResourceUnavailableException;
import com.cloud.network.NetScalerControlCenterVO;
import com.cloud.network.NetScalerServicePackageVO;
import com.cloud.network.Network;
import com.cloud.network.dao.ExternalLoadBalancerDeviceVO;
import com.cloud.network.router.VirtualRouter;
import com.cloud.user.Account;
import com.cloud.utils.component.PluggableService;
import com.cloud.utils.exception.CloudRuntimeException;

public interface NetscalerLoadBalancerElementService extends PluggableService {

    /**
     * lists all Netscaler Control Center user Details
     * @param ListNetscalerControlCenterCmd
     * @return list of NetScalerControlCenterVO for Net Scaler Control Center which contains information about user and their network
     * control center ID etc.
     *
     */
    List<NetScalerControlCenterVO> listNetscalerControlCenter(ListNetscalerControlCenterCmd cmd);

    /**
     * Lists all the list Registered Service Packages details in the Network.
     * @param ListRegisteredServicePackageCmd
     * @return list of NetScalerServicePackageVO for registered services in the network which contains details of services
     */

    List<NetScalerServicePackageVO> listRegisteredServicePackages(ListRegisteredServicePackageCmd cmd);

    /**
     * Deletes Service Package Offering
     *
     * @param DeleteServicePackageOffering
     * @return boolean value which tells deletion is successful or not.
     */
    boolean deleteServicePackageOffering(DeleteServicePackageOfferingCmd cmd) throws CloudRuntimeException;

    /**
     * Deletes Netscaler Control Center if it is  not in use.
     *
     * @param (DeleteNetscalerControlCenter
     * @return boolean value which tells deletion is successful or not.
     */
    boolean deleteNetscalerControlCenter(DeleteNetscalerControlCenterCmd cmd) throws CloudRuntimeException;

    /**
     * adds a Netscaler load balancer device in to a physical network
     * @param AddNetscalerLoadBalancerCmd
     * @return ExternalLoadBalancerDeviceVO object for the device added
     */
    ExternalLoadBalancerDeviceVO addNetscalerLoadBalancer(AddNetscalerLoadBalancerCmd cmd);

    /**
     * removes a Netscaler load balancer device from a physical network
     * @param DeleteNetscalerLoadBalancerCmd
     * @return true if Netscaler device is deleted successfully
     */
    boolean deleteNetscalerLoadBalancer(DeleteNetscalerLoadBalancerCmd cmd);

    /**
     * configures a Netscaler load balancer device added in a physical network
     * @param ConfigureNetscalerLoadBalancerCmd
     * @return ExternalLoadBalancerDeviceVO for the device configured
     */
    ExternalLoadBalancerDeviceVO configureNetscalerLoadBalancer(ConfigureNetscalerLoadBalancerCmd cmd);

    /**
     * lists all the load balancer devices added in to a physical network
     * @param ListNetscalerLoadBalancersCmd
     * @return list of ExternalLoadBalancerDeviceVO for the devices in the physical network.
     */
    List<ExternalLoadBalancerDeviceVO> listNetscalerLoadBalancers(ListNetscalerLoadBalancersCmd cmd);

    /**
     * lists all the guest networks using a Netscaler load balancer device
     * @param ListNetscalerLoadBalancerNetworksCmd
     * @return list of the guest networks that are using this Netscaler load balancer
     */
    List<? extends Network> listNetworks(ListNetscalerLoadBalancerNetworksCmd cmd);

    /**
     * creates API response object for netscaler load balancers
     * @param lbDeviceVO external load balancer VO object
     * @return NetscalerLoadBalancerResponse
     */
    NetscalerLoadBalancerResponse createNetscalerLoadBalancerResponse(ExternalLoadBalancerDeviceVO lbDeviceVO);

    /**
     * creates API response object for netscaler load balancers
     * @param lbDeviceVO external load balancer VO object
     * @return NetscalerLoadBalancerResponse
     */
    NetScalerServicePackageResponse registerNetscalerServicePackage(RegisterServicePackageCmd cmd);

    NetscalerControlCenterResponse createNetscalerControlCenterResponse(NetScalerControlCenterVO lncCentersVO);

    NetScalerServicePackageResponse createRegisteredServicePackageResponse(NetScalerServicePackageVO lrsPackageVO);

    NetScalerServicePackageResponse deleteNetscalerServicePackage(RegisterServicePackageCmd cmd);

    NetScalerServicePackageResponse listNetscalerServicePackage(RegisterServicePackageCmd cmd);

    NetScalerServicePackageResponse createNetscalerServicePackageResponse(NetScalerServicePackageVO servicePackageVO);

    NetScalerControlCenterVO registerNetscalerControlCenter(RegisterNetscalerControlCenterCmd registerNetscalerControlCenterCmd);

    Map<String, Object> deployNetscalerServiceVm(DeployNetscalerVpxCmd cmd);

    VirtualRouter stopNetscalerServiceVm(Long id, boolean forced, Account callingAccount, long callingUserId) throws ConcurrentOperationException, ResourceUnavailableException;
}