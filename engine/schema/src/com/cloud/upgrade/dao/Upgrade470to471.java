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


package com.cloud.upgrade.dao;

import com.cloud.storage.Storage;
import com.cloud.utils.exception.CloudRuntimeException;
import com.cloud.utils.script.Script;
import org.apache.log4j.Logger;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.UUID;

/**
 * Created by sudharma_jain on 5/25/16.
 */
public class Upgrade470to471 implements DbUpgrade {
    final static Logger s_logger = Logger.getLogger(Upgrade470to471.class);

    public static class MemoryValues {
        long max;
        long min;

        public MemoryValues(final long min, final long max) {
            this.min = min * 1024 * 1024;
            this.max = max * 1024 * 1024;
        }

        public long getMax() {
            return max;
        }

        public long getMin() {
            return min;
        }
    }

    @Override
    public String[] getUpgradableVersionRange() {
        return new String[] {"4.7.0", "4.7.1"};
    }

    @Override
    public String getUpgradedVersion() {
        return "4.7.1";
    }

    @Override
    public boolean supportsRollingUpgrade() {
        return false;
    }

    @Override
    public File[] getPrepareScripts() {
        String script = Script.findScript("", "db/schema-470to471.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-470to471.sql");
        }

        return new File[] {new File(script)};
    }

    @Override
    public void performDataMigration(Connection conn) {
        populateGuestOsDetails(conn);
        updateStoragePoolUuid(conn);
        updateSourceCidrs(conn);
    }

    @Override
    public File[] getCleanupScripts() {
        String script = Script.findScript("", "db/schema-470to471-cleanup.sql");
        if (script == null) {
            throw new CloudRuntimeException("Unable to find db/schema-470to471-cleanup.sql");
        }

        return new File[] {new File(script)};
    }

    private void populateGuestOsDetails(Connection conn){
        final HashMap<String, MemoryValues> xenServerGuestOsMemoryMap = new HashMap<String, MemoryValues>(70);

        xenServerGuestOsMemoryMap.put("CentOS 4.5 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 4.6 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 4.7 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 4.8 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.0 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.0 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.1 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.1 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.2 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.3 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.4 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.5 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.6 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.6 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.7 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.7 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.8 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.8 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.9 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.9 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.10 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 5.10 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.0 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.0 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.1 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.1 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.4 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.5 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.6 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.6 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.7 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 6.7 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 7", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 7.1 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 7.2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CentOS 7.3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.0 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.0 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.1 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.1 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.2 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.3 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.4 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.4 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.5 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.5 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.6 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.6 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.7 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.7 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.8 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.8 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.9 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.9 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.10 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 5.10 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.0 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.0 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.1 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.1 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.4 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Oracle Enterprise Linux 6.5 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 4.5 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 4.6 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 4.7 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 4.8 (32-bit)", new MemoryValues(256l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.0 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.0 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.1 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.1 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.2 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.3 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.4 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.5 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.6 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.6 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.7 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.7 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.8 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.8 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.9 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.9 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.10 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 5.10 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.0 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.0 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.1 (32-bit)", new MemoryValues(512l, 8 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.1 (64-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.4 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.5 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.5 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.6 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.6 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.7 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 6.7 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 7", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 7.1", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Red Hat Enterprise Linux 7.2", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 5.0 (64-bit)", new MemoryValues(128l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 5(64-bit)", new MemoryValues(128l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 6(32-bit)", new MemoryValues(128l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 6(64-bit)", new MemoryValues(128l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 7(32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 7(64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 8(32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Debian GNU/Linux 8(64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10(32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10(64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP1 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP1 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP4 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 10 SP4 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP1 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP1 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP2 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP3 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 11 SP3 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 12 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("SUSE Linux Enterprise Server 12 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 7 (32-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 7 (64-bit)", new MemoryValues(2 * 1024l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 8 (32-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 8 (64-bit)", new MemoryValues(2 * 1024l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2003 Enterprise Edition(32-bit)", new MemoryValues(256l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2003 Enterprise Edition(64-bit)", new MemoryValues(256l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2003 SP2 (32-bit)", new MemoryValues(256l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2003 SP2 (64-bit)", new MemoryValues(256l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 SP2 (32-bit)", new MemoryValues(512l, 64 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 SP2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 R2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2008 R2 SP1 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2012 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Server 2012 R2 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Vista (32-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Vista (64-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows Vista SP2 (32-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows XP (32-bit)", new MemoryValues(256l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows XP (64-bit)", new MemoryValues(256l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows XP SP3 (32-bit)", new MemoryValues(256l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 10.04 (32-bit)", new MemoryValues(128l, 512l));
        xenServerGuestOsMemoryMap.put("Ubuntu 10.04 (64-bit)", new MemoryValues(128l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 10.10 (32-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 10.10 (64-bit)", new MemoryValues(512l, 16 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 12.04 (32-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 12.04 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 14.04 (32-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 14.04 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 16.04 (32-bit)", new MemoryValues(512l, 32 * 1024l));
        xenServerGuestOsMemoryMap.put("Ubuntu 16.04 (64-bit)", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("CoreOS", new MemoryValues(512l, 128 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 10 (32-bit)", new MemoryValues(1024l, 4 * 1024l));
        xenServerGuestOsMemoryMap.put("Windows 10 (64-bit)", new MemoryValues(2 * 1024l, 128 * 1024l));

        final String insertDynamicMemoryVal = "insert into guest_os_details(guest_os_id, name, value, display) select id,?, ?, 0 from guest_os where display_name = ?";


        PreparedStatement ps = null;
        try{
            ps = conn.prepareStatement(insertDynamicMemoryVal);

            for (String key: xenServerGuestOsMemoryMap.keySet()){
                ps.setString(1,"xenserver.dynamicMin");
                ps.setString(2,String.valueOf(xenServerGuestOsMemoryMap.get(key).getMin()));
                ps.setString(3, key);
                ps.executeUpdate();

                ps.setString(1,"xenserver.dynamicMax");
                ps.setString(2,String.valueOf(xenServerGuestOsMemoryMap.get(key).getMax()));
                ps.setString(3, key);
                ps.executeUpdate();
            }


        }catch(SQLException e){
            throw new CloudRuntimeException("Unable to update guestOs details", e);
        }finally {
            try {
                if (ps != null && !ps.isClosed())  {
                    ps.close();
                }
            } catch (SQLException e) {
            }
        }

    }

    private void updateStoragePoolUuid(Connection conn) {
        s_logger.debug("updateStoragePoolUUID start");
        try (PreparedStatement pstmt1 = conn.prepareStatement("SELECT id, hypervisor, path" + " FROM `cloud`.`storage_pool` "
                + " WHERE `pool_type` = ?")) {
            pstmt1.setString(1, Storage.StoragePoolType.PreSetup.toString());
            try (ResultSet rsCount = pstmt1.executeQuery()) {
                if (rsCount.next()) {
                    String uuid = UUID.nameUUIDFromBytes((rsCount.getString(2) + rsCount.getString(3)).getBytes()).toString();
                    updateUuid(conn, uuid, rsCount.getLong(1));
                }
                s_logger.debug("updateStoragePoolUUID finish");
            } catch (SQLException e) {
                s_logger.error("updateStoragePoolUUID finished with errors : " + e.getMessage());
                throw new CloudRuntimeException("Unable to update storage pool UUID  ", e);
            }
        } catch (SQLException e) {
            throw new CloudRuntimeException("updateStoragePoolUUID:Exception:" + e.getMessage(), e);
        }
    }


    private void updateUuid(Connection conn, String uuid, Long poolId){
        try(PreparedStatement pstmt = conn.prepareStatement("UPDATE `cloud`.`storage_pool` SET uuid=? WHERE `id`=?")) {
            pstmt.setString(1, uuid);
            pstmt.setLong(2, poolId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new CloudRuntimeException("updateUUID:Exception:" + e.getMessage(), e);
        }
    }

    private void updateSourceCidrs(Connection conn){
        try(PreparedStatement pstmt = conn.prepareStatement("UPDATE `cloud`.`firewall_rules_cidrs` AS s, ((SELECT IFNULL(networks.network_cidr,networks.cidr) cidr,"+
                " `firewall_rules_cidrs`.`id`, `firewall_rules`.`traffic_type` "+
                "FROM `cloud`.`networks`, `cloud`.`firewall_rules`,`cloud`.`firewall_rules_cidrs` WHERE `cloud`.`networks`.`id`=`cloud`.`firewall_rules`.`network_id` " +
                "AND `cloud`.`firewall_rules`.`id` = `cloud`.`firewall_rules_cidrs`.`firewall_rule_id`) AS p " +
                "SET `s`.`source_cidr` = `p`.`cidr` WHERE `s`.`source_cidr`=\"0.0.0.0/0\" AND `s`.`id`=`p`.`id` AND `p`.`traffic_type`=\"Egress\" ;")){
            pstmt.execute();
        }catch (SQLException e) {
            throw new CloudRuntimeException("updateSourceCidrs:Exception:" + e.getMessage(), e);
        }
    }

}
