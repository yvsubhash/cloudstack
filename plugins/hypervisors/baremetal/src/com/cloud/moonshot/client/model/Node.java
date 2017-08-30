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
package com.cloud.moonshot.client.model;

import java.util.Arrays;

/**
 * Created by Raghav on 8/13/2015.
 */
public class Node {

    public static final String NODE_NAME = "Name";
    public static final String NODE_POWER = "Power";
    public static final String NODE_HEALTH = "Health";
    public static final String NODE_STATUS = "Status";
    public static final String NODE_HOST_MAC_ADDRESS = "HostMACAddress";
    public static final String NODE_HOST_CORRELATION = "HostCorrelation";
    public static final String NODE_MEMORY = "Memory";
    public static final String NODE_TOTAL_SYSTEM_MEMORY_GB = "TotalSystemMemoryGB";
    public static final String NODE_PROCESSORS = "Processors";
    public static final String NODE_CURRENT_CLOCK_SPEED_MHZ = "CurrentClockSpeedMHz";
    public static final String NODE_MAX_CLOCK_SPEED_MHZ = "MaxClockSpeedMHz";
    public static final String NODE_NUMBER_OF_CORES = "NumberOfCores";

    private String name;

    private Health health;

    private String power;

    private String[] mac;

    private int cartridge;

    private int node;

    private int memory;

    private int noOfCores;

    private int currentClockSpeed;

    private int maxClockSpeed;

    private BootTarget bootOnce;

    private BootTarget[] bootOrder;

    public Node(String name) {
        if (name == null || name.equals("")) {
            throw new IllegalArgumentException("Node name cannot be empty");
        }

        this.name = name;
        String[] parts = name.split("\\s+");
        this.cartridge = Integer.parseInt(parts[1]);
        this.node = Integer.parseInt(parts[3]);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Health getHealth() {
        return health;
    }

    public void setHealth(Health health) {
        this.health = health;
    }

    public String getPower() {
        return power;
    }

    public void setPower(String power) {
        this.power = power;
    }

    public String[] getMac() {
        return mac;
    }

    public void setMac(String[] mac) {
        this.mac = mac;
    }

    public String getPrimaryMac() {
        return this.mac[0];
    }

    public String getSecondaryMac() {
        return this.mac[1];
    }

    public int getCartridge() {
        return cartridge;
    }

    public void setCartridge(int cartridge) {
        this.cartridge = cartridge;
    }

    public int getNode() {
        return node;
    }

    public void setNode(int node) {
        this.node = node;
    }

    public int getMemory() {
        return memory;
    }

    public void setMemory(int memory) {
        this.memory = memory;
    }

    public int getNoOfCores() {
        return noOfCores;
    }

    public void setNoOfCores(int noOfCores) {
        this.noOfCores = noOfCores;
    }

    public int getCurrentClockSpeed() {
        return currentClockSpeed;
    }

    public void setCurrentClockSpeed(int currentClockSpeed) {
        this.currentClockSpeed = currentClockSpeed;
    }

    public int getMaxClockSpeed() {
        return maxClockSpeed;
    }

    public void setMaxClockSpeed(int maxClockSpeed) {
        this.maxClockSpeed = maxClockSpeed;
    }

    public BootTarget getBootOnce() {
        return bootOnce;
    }

    public void setBootOnce(BootTarget bootOnce) {
        this.bootOnce = bootOnce;
    }

    public BootTarget[] getBootOrder() {
        return bootOrder;
    }

    public void setBootOrder(BootTarget[] bootOrder) {
        this.bootOrder = bootOrder;
    }

    public String getShortName() {
        return "C" + this.cartridge + "N" + this.node;
    }

    @Override
    public String toString() {
        return "Node [name=" + name + ", health=" + health + ", power=" + power
                + ", mac=" + Arrays.toString(mac) + ", cartridge=" + cartridge
                + ", node=" + node + ", memory=" + memory + ", noOfCores="
                + noOfCores + ", currentClockSpeed=" + currentClockSpeed
                + ", maxClockSpeed=" + maxClockSpeed + ", bootOnce=" + bootOnce
                + ", bootOrder=" + Arrays.toString(bootOrder) + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((bootOnce == null) ? 0 : bootOnce.hashCode());
        result = prime * result + Arrays.hashCode(bootOrder);
        result = prime * result + cartridge;
        result = prime * result + currentClockSpeed;
        result = prime * result + ((health == null) ? 0 : health.hashCode());
        result = prime * result + Arrays.hashCode(mac);
        result = prime * result + maxClockSpeed;
        result = prime * result + memory;
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        result = prime * result + noOfCores;
        result = prime * result + node;
        result = prime * result + ((power == null) ? 0 : power.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        Node other = (Node) obj;
        if (bootOnce != other.bootOnce)
            return false;
        if (!Arrays.equals(bootOrder, other.bootOrder))
            return false;
        if (cartridge != other.cartridge)
            return false;
        if (currentClockSpeed != other.currentClockSpeed)
            return false;
        if (health != other.health)
            return false;
        if (!Arrays.equals(mac, other.mac))
            return false;
        if (maxClockSpeed != other.maxClockSpeed)
            return false;
        if (memory != other.memory)
            return false;
        if (name == null) {
            if (other.name != null)
                return false;
        } else if (!name.equals(other.name))
            return false;
        if (noOfCores != other.noOfCores)
            return false;
        if (node != other.node)
            return false;
        if (power == null) {
            if (other.power != null)
                return false;
        } else if (!power.equals(other.power))
            return false;
        return true;
    }
}