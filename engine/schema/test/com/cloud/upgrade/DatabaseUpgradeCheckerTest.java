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
package com.cloud.upgrade;

import com.cloud.upgrade.dao.DbUpgrade;
import com.cloud.upgrade.dao.Upgrade41000to41100;
import com.cloud.upgrade.dao.Upgrade470to471;
import com.cloud.upgrade.dao.Upgrade471to480;
import com.cloud.upgrade.dao.Upgrade480to481;
import com.cloud.upgrade.dao.Upgrade481to490;
import com.cloud.upgrade.dao.Upgrade490to4910;
import com.cloud.upgrade.dao.Upgrade4910to4920;
import com.cloud.upgrade.dao.Upgrade4920to4930;
import com.cloud.upgrade.dao.Upgrade4930to41000;
import org.apache.cloudstack.utils.CloudStackVersion;
import org.junit.Test;

import java.util.Arrays;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class DatabaseUpgradeCheckerTest {

    @Test
    public void testCalculateUpgradePath480to481() {

        final CloudStackVersion dbVersion = CloudStackVersion.parse("4.7.0");
        assertNotNull(dbVersion);

        final CloudStackVersion currentVersion = CloudStackVersion.parse("4.7.1");
        assertNotNull(currentVersion);

        final DatabaseUpgradeChecker checker = new DatabaseUpgradeChecker();
        final DbUpgrade[] upgrades = checker.calculateUpgradePath(dbVersion, currentVersion);

        assertNotNull(upgrades);
        assertTrue(upgrades.length >= 1);
        assertTrue(upgrades[0] instanceof Upgrade470to471);

    }

    @Test
    public void testCalculateUpgradePath490to4910() {

        final CloudStackVersion dbVersion = CloudStackVersion.parse("4.9.0");
        assertNotNull(dbVersion);

        final CloudStackVersion currentVersion = CloudStackVersion.parse("4.9.1.0");
        assertNotNull(currentVersion);

        final DatabaseUpgradeChecker checker = new DatabaseUpgradeChecker();
        final DbUpgrade[] upgrades = checker.calculateUpgradePath(dbVersion, currentVersion);

        assertNotNull(upgrades);
        assertTrue(upgrades.length >= 1);
        assertTrue(upgrades[0] instanceof Upgrade490to4910);

        assertTrue(Arrays.equals(new String[] { "4.9.0", currentVersion.toString()}, upgrades[0].getUpgradableVersionRange()));
        assertEquals(currentVersion.toString(), upgrades[0].getUpgradedVersion());

    }

    @Test
    public void testFindUpgradePath470to481() {

        final CloudStackVersion dbVersion = CloudStackVersion.parse("4.7.0");
        assertNotNull(dbVersion);

        final CloudStackVersion currentVersion = CloudStackVersion.parse("4.8.1");
        assertNotNull(currentVersion);

        final DatabaseUpgradeChecker checker = new DatabaseUpgradeChecker();
        final DbUpgrade[] upgrades = checker.calculateUpgradePath(dbVersion, currentVersion);

        assertNotNull(upgrades);

        assertTrue(upgrades[0] instanceof Upgrade470to471);
        assertTrue(upgrades[1] instanceof Upgrade471to480);
        assertTrue(upgrades[2] instanceof Upgrade480to481);

    }

    @Test
    public void testFindUpgradePath471to41100() {

        final CloudStackVersion dbVersion = CloudStackVersion.parse("4.7.1");
        assertNotNull(dbVersion);

        final CloudStackVersion currentVersion = CloudStackVersion.parse("4.11.0.0");
        assertNotNull(currentVersion);

        final DatabaseUpgradeChecker checker = new DatabaseUpgradeChecker();
        final DbUpgrade[] upgrades = checker.calculateUpgradePath(dbVersion, currentVersion);

        assertNotNull(upgrades);

        assertTrue(upgrades[0] instanceof Upgrade471to480);
        assertTrue(upgrades[1] instanceof Upgrade480to481);
        assertTrue(upgrades[2] instanceof Upgrade481to490);
        assertTrue(upgrades[3] instanceof Upgrade490to4910);
        assertTrue(upgrades[4] instanceof Upgrade4910to4920);
        assertTrue(upgrades[5] instanceof Upgrade4920to4930);
        assertTrue(upgrades[6] instanceof Upgrade4930to41000);
        assertTrue(upgrades[7] instanceof Upgrade41000to41100);


        assertTrue(Arrays.equals(new String[] { "4.10.0.0", currentVersion.toString()}, upgrades[7].getUpgradableVersionRange()));
        assertEquals(currentVersion.toString(), upgrades[7].getUpgradedVersion());

    }
}
