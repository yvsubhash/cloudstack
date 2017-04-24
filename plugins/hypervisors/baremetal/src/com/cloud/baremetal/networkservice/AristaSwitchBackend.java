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
package com.cloud.baremetal.networkservice;

import com.cloud.serializer.GsonHelper;
import com.cloud.utils.exception.CloudRuntimeException;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import org.apache.commons.lang.StringUtils;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.log4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class AristaSwitchBackend implements BaremetalSwitchBackend {

    private Logger logger = Logger.getLogger(AristaSwitchBackend.class);
    public static final String TYPE = "Arista";


    @Override
    public String getSwitchBackendType() {
        return TYPE;
    }

    @Override
    public void prepareVlan(BaremetalVlanStruct struct) {
        int vlanid = struct.getVlan();
        PortInfo portinfo = new PortInfo(struct);
        final Gson gson = new GsonBuilder().create();

        // Get vlan information from switch and check whether configuration already exists or not

        List<String> commands = Arrays.asList("show vlan " + String.valueOf(vlanid));
        String showVlanResponse  = executeJsonRpc(struct, commands);
        HashMap<String, Object> showVlanResponseMap = new HashMap<String, Object>();
        if (showVlanResponse != null) {
            showVlanResponseMap = GsonHelper.createHashMapFromJsonString(showVlanResponse);
        } else {
            throw new CloudRuntimeException("Failed to configure VLAN on Arista Switch");
        }
        // HTTP status code returns 200 (status OK) even if VLAN is not found. So we need to parse the json response for errors.

        if (showVlanResponseMap.get("error") != null) {
            Map<String, Object> error = (Map<String, Object>) showVlanResponseMap.get("error");
            ArrayList<Object> data = (ArrayList<Object>) error.get("data");
            if (data != null && data.size() > 0) {
                Map<String, Object> dataMap = (Map<String, Object>) data.get(0);
                if (dataMap != null) {
                    JsonArray errors = (JsonArray) dataMap.get("errors");
                    if (errors != null && errors.size() > 0) {
                        String errorMessage = errors.get(0).getAsString();
                        if (errorMessage != null && errorMessage.contains("not found in current VLAN database")) {
                            logger.debug(String.format("vlan [%s] is not configured on the switch", vlanid));
                            commands =  Arrays.asList("enable", "configure", "vlan " + vlanid, "interface " + portinfo.port, "switchport access vlan " + vlanid, "show vlan " + vlanid);
                            String configureVlanResponse = executeJsonRpc(struct, commands);
                            Map<String, Object> configureVlanResponseMap = GsonHelper.createHashMapFromJsonString(configureVlanResponse);
                            return;
                        }
                    }
                }
            }
            throw new CloudRuntimeException(String.format("unable to create vlan[%s] on Arista switch[ip:%s]. HTTP status code:%s, body dump:%s",
                    struct.getVlan(), struct.getSwitchIp(), (Integer)showVlanResponseMap.get("code"), (String)showVlanResponseMap.get("message")));
        } else {
            commands =  Arrays.asList("enable", "configure", "vlan " + vlanid, "interface " + portinfo.port, "switchport access vlan " + vlanid, "show vlan " + vlanid);
            String configureVlanResponse = executeJsonRpc(struct, commands);
            Map<String, Object> configureVlanResponseMap = GsonHelper.createHashMapFromJsonString(configureVlanResponse);
        }
    }

    @Override
    public void removePortFromVlan(BaremetalVlanStruct struct) {
        int vlanid = struct.getVlan();
        PortInfo portinfo = new PortInfo(struct);
        final Gson gson = new GsonBuilder().create();

        // Get vlan information from switch and check whether configuration already exists or not

        List<String> commands = Arrays.asList("show vlan " + String.valueOf(vlanid));
        String showVlanResponse  = executeJsonRpc(struct, commands);
        Map<String, Object> showVlanResponseMap = GsonHelper.createHashMapFromJsonString(showVlanResponse);

        // HTTP status code returns 200 (status OK) even if VLAN is not found. So we need to parse the json response for errors.

        if (showVlanResponseMap.get("error") != null) {
            Map<String, Object> error = (Map<String, Object>) showVlanResponseMap.get("error");
            ArrayList<Object> data = (ArrayList<Object>) error.get("data");
            if (data != null && data.size() > 0) {
                Map<String, Object> dataMap = (Map<String, Object>) data.get(0);
                if (dataMap != null) {
                    JsonArray errors = (JsonArray) dataMap.get("errors");
                    if (errors != null && errors.size() > 0) {
                        String errorMessage = errors.get(0).getAsString();
                        if (errorMessage != null && errorMessage.contains("not found in current VLAN database")) {
                            logger.debug(String.format("vlan[%s] has been deleted on Arista Switch[ip:%s], no need to remove the port[%s] anymore", struct.getVlan(), struct.getSwitchIp(), struct.getPort()));
                            return;
                        }
                    }
                }
            }
            throw new CloudRuntimeException(String.format("unable to read vlan[%s] information on Arista switch[ip:%s]. HTTP status code:%s, body dump:%s",
                    struct.getVlan(), struct.getSwitchIp(), (Integer)showVlanResponseMap.get("code"), (String)showVlanResponseMap.get("message")));
        } else {
            commands =  Arrays.asList("enable", "configure", "vlan " + vlanid, "interface " + portinfo.port, "no switchport access vlan " + vlanid, "show vlan " + vlanid);
            String removeVlanResponse = executeJsonRpc(struct, commands);
            Map<String, Object> removeVlanResponseMap = GsonHelper.createHashMapFromJsonString(removeVlanResponse);
        }
    }

    private String executeJsonRpc(BaremetalVlanStruct struct, List<String> commands) {

        final Gson gson = new GsonBuilder().create();
        AristaJsonRequest aristaJsonRequest = new AristaJsonRequest(commands);
        String strAristaJsonRequest = gson.toJson(aristaJsonRequest);

        DefaultHttpClient httpClient = null;
        StringBuilder sb = new StringBuilder();

        try {
            StringEntity input = new StringEntity(strAristaJsonRequest);
            //input.setContentType("application/json");
            httpClient = new DefaultHttpClient();
            URI uri = new URI("http://" + struct.getSwitchIp() + "/command-api");
            AuthScope authScope = new AuthScope(uri.getHost(), uri.getPort(), AuthScope.ANY_SCHEME);
            UsernamePasswordCredentials credentials = new UsernamePasswordCredentials(struct.getSwitchUsername(), struct.getSwitchPassword());
            httpClient.getCredentialsProvider().setCredentials(authScope, credentials);
            HttpPost postRequest = new HttpPost(uri);
            postRequest.setEntity(input);
            HttpResponse response = httpClient.execute(postRequest);

            if (response == null) {
                throw new CloudRuntimeException("Failed on JSON-RPC API call. returned null during request to Arista Switch");
            }
            if (!isSuccess(response.getStatusLine().getStatusCode())) {
                throw new CloudRuntimeException("Failed on JSON-RPC API call. HTTP error code = " + response.getStatusLine().getStatusCode());
            }

            try (BufferedReader br = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));) {
                String strOutput;
                while ((strOutput = br.readLine()) != null) {
                    sb.append(strOutput);
                }
            } catch (IOException ex) {
                throw new CloudRuntimeException(ex.getMessage());
            }
        } catch (UnsupportedEncodingException ex) {
            throw new CloudRuntimeException(ex.getMessage());
        } catch (ClientProtocolException ex) {
            throw new CloudRuntimeException(ex.getMessage());
        } catch (IOException ex) {
            throw new CloudRuntimeException(ex.getMessage());
        } catch (URISyntaxException ex) {
            throw new CloudRuntimeException(ex.getMessage());
        } finally {
            if (httpClient != null) {
                try {
                    httpClient.getConnectionManager().shutdown();
                } catch (Exception t) {
                    logger.info("[ignored]"
                            + "error shutting down http client: " + t.getLocalizedMessage());
                }
            }
        }

        String strAristaJsonResponse = sb.toString();
        return strAristaJsonResponse;
    }

    private static boolean isSuccess(int iCode) {
        return iCode >= 200 && iCode < 300;
    }

    private static final class AristaJsonRequest {
        private final String jsonrpc = "2.0";
        private final String method = "runCmds";
        private final AristaJsonRequestParams params;
        private final String id = "EapiExplorer-1";

        private AristaJsonRequest(List<String> commands)
        {
            params = new AristaJsonRequestParams(commands);
        }

        private static final class AristaJsonRequestParams
        {
            private final String format = "json";
            private final boolean timestamps = false;
            private final List<String> cmds;
            private final int version = 1;

            private AristaJsonRequestParams(List<String> commands)
            {
                this.cmds = commands;
            }
        }

    }

    private class PortInfo {

        static final String DEFAULT_INTERFACE = "ethernet";

        private String interfaceType;
        private String port;

        PortInfo(BaremetalVlanStruct struct) {
            String[] ps = StringUtils.split(struct.getPort(), ":");
            if (ps.length == 1) {
                interfaceType = DEFAULT_INTERFACE;
                port = ps[0];
            } else if (ps.length == 2) {
                interfaceType = ps[0];
                port = ps[1];
            } else {
                throw new CloudRuntimeException(String.format("wrong port definition[%s]. Arista Switch port should be in format of interface_type:ethernet, for example: ethernet:3", struct.getPort()));
            }
        }
    }

}
