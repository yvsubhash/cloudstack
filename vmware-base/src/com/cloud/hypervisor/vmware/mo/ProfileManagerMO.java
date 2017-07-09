//Licensed to the Apache Software Foundation (ASF) under one
//or more contributor license agreements.  See the NOTICE file
//distributed with this work for additional information
//regarding copyright ownership.  The ASF licenses this file
//to you under the Apache License, Version 2.0 (the
//"License"); you may not use this file except in compliance
//with the License.  You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing,
//software distributed under the License is distributed on an
//"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//KIND, either express or implied.  See the License for the
//specific language governing permissions and limitations
//under the License.
package com.cloud.hypervisor.vmware.mo;

import java.util.List;

import org.apache.log4j.Logger;

import com.vmware.pbm.PbmCapabilityProfile;
import com.vmware.pbm.PbmProfile;
import com.vmware.pbm.PbmProfileId;
import com.vmware.pbm.PbmProfileResourceType;
import com.vmware.pbm.PbmProfileResourceTypeEnum;
import com.vmware.pbm.PbmServerObjectRef;
import com.vmware.vim25.EntityType;
import com.vmware.vim25.ManagedObjectReference;

import com.cloud.hypervisor.vmware.util.VmwareContext;
import com.cloud.utils.exception.CloudRuntimeException;

public class ProfileManagerMO extends BaseMO {

    private static final Logger s_logger = Logger.getLogger(ProfileManagerMO.class);

    public ProfileManagerMO(VmwareContext context) {
        super(context, context.getPbmServiceContent().getProfileManager());
    }

    public ProfileManagerMO(VmwareContext context, ManagedObjectReference morProfileMgr) {
        super(context, morProfileMgr);
    }

    public ProfileManagerMO(VmwareContext context, String morType, String morValue) {
        super(context, morType, morValue);
    }

    public List<PbmProfileId> getProfiles(PbmProfileResourceType pbmResourceType) throws Exception {
        if (s_logger.isDebugEnabled()) {
            s_logger.debug("Querying vCenter " + _context.getServerAddress() + " for profiles of resource type : " + pbmResourceType.getResourceType());
        }
        List<PbmProfileId> profileIds = _context.getPbmService().pbmQueryProfile(_mor, pbmResourceType, null);
        return profileIds;
    }

    public List<PbmProfileId> getStorageProfiles() throws Exception {
        return getProfiles(getStorageResourceType());
    }

    public PbmCapabilityProfile getPbmProfile(String name) throws Exception {
        List<PbmProfileId> profileIds = _context.getPbmService().pbmQueryProfile(_mor,
                getStorageResourceType(), null);

        if (profileIds == null || profileIds.isEmpty())
            throw new Exception("No storage Profiles exist.");

        List<PbmProfile> pbmProfiles = _context.getPbmService().pbmRetrieveContent(_mor, profileIds);
        for (PbmProfile pbmProfile : pbmProfiles) {
            if (pbmProfile.getName().equalsIgnoreCase(name)) {
                PbmCapabilityProfile profile = (PbmCapabilityProfile)pbmProfile;
                return profile;
            }
        }
        throw new CloudRuntimeException("Profile with the given name does not exist", null);
    }

    public List<PbmServerObjectRef> queryAssociatedEntities(PbmProfile profile, EntityType a) throws Exception {
        List<PbmServerObjectRef> entities = _context.getPbmService().pbmQueryAssociatedEntity(_mor,
                profile.getProfileId(), "virtualMachine");
        return entities;
    }

    public static PbmProfileResourceType getStorageResourceType() {
        PbmProfileResourceType resourceType = new PbmProfileResourceType();
        resourceType.setResourceType(PbmProfileResourceTypeEnum.STORAGE.value());
        return resourceType;
    }
}
