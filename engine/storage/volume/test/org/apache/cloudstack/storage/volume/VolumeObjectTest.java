/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.cloudstack.storage.volume;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.runners.MockitoJUnitRunner;

import org.apache.cloudstack.engine.subsystem.api.storage.DataStore;
import org.apache.cloudstack.storage.datastore.ObjectInDataStoreManager;
import org.apache.cloudstack.storage.datastore.db.VolumeDataStoreDao;

import com.cloud.hypervisor.Hypervisor.HypervisorType;
import com.cloud.service.dao.ServiceOfferingDetailsDao;
import com.cloud.storage.Storage;
import com.cloud.storage.Volume;
import com.cloud.storage.VolumeVO;
import com.cloud.storage.dao.DiskOfferingDao;
import com.cloud.storage.dao.VolumeDao;
import com.cloud.vm.UserVmVO;
import com.cloud.vm.dao.VMInstanceDao;

@RunWith(MockitoJUnitRunner.class)
public class VolumeObjectTest {

    @Mock
    VolumeDao volumeDao;

    @Mock
    VolumeDataStoreDao volumeStoreDao;

    @Mock
    ObjectInDataStoreManager objectInStoreMgr;

    @Mock
    VMInstanceDao vmInstanceDao;

    @Mock
    DiskOfferingDao diskOfferingDao;

    @Mock
    ServiceOfferingDetailsDao serviceOfferingDetailsDao;

    @InjectMocks
    VolumeObject volumeObject;

    @InjectMocks
    VolumeObject rootVolumeObject;

    @InjectMocks
    UserVmVO vmVo;

    @Before
    public void setUp() throws Exception {
        volumeObject.configure(Mockito.mock(DataStore.class), new VolumeVO("name", 1l, 1l, 1l, 1l, 1l, "folder", "path", Storage.ProvisioningType.THIN, 1l, Volume.Type.DATADISK));
        rootVolumeObject.configure(Mockito.mock(DataStore.class),
                new VolumeVO("rootVolume", 1l, 1l, 1l, 1l, 1l, "folder", "path", Storage.ProvisioningType.THIN, 1l, Volume.Type.ROOT));
        vmVo = new UserVmVO(1L, "vm", "vm", 1, HypervisorType.VMware, 1L, false, false, 1L, 1L, 1, 1L, null, "vm", null);
    }

    /**
     * Tests the following scenario:
     * If the volume gets deleted by another thread (cleanup) and the cleanup is attempted again, the volume isnt found in DB and hence NPE occurs
     * during transition
     */
    @Test
    public void testStateTransit() {
        boolean result = volumeObject.stateTransit(Volume.Event.OperationFailed);
        Assert.assertFalse("since the volume doesnt exist in the db, the operation should fail but, should not throw any exception", result);
    }

    /**
     * Tests fetching storage policy in case of a ROOT volume that attached to existing VM
     */
    @Test
    public void testGetStoragePolicyVmExists() {
        Mockito.when(serviceOfferingDetailsDao.getDetail(Mockito.anyLong(), Mockito.anyString())).thenReturn("");
        Mockito.when(vmInstanceDao.findById(Mockito.anyLong())).thenReturn(vmVo);
        Mockito.when(vmInstanceDao.findByIdIncludingRemoved(Mockito.anyLong())).thenReturn(vmVo);
        rootVolumeObject.getStoragePolicy();
    }

    /**
     * Tests fetching storage policy in case of a ROOT volume that is detached, and the VM it was attached to earlier was destroyed.
     */
    @Test
    public void testGetStoragePolicyVmDestroyed() {
        Mockito.when(serviceOfferingDetailsDao.getDetail(Mockito.anyLong(), Mockito.anyString())).thenReturn("");
        Mockito.when(vmInstanceDao.findById(Mockito.anyLong())).thenReturn(null);
        Mockito.when(vmInstanceDao.findByIdIncludingRemoved(Mockito.anyLong())).thenReturn(vmVo);
        rootVolumeObject.getStoragePolicy();
    }

}