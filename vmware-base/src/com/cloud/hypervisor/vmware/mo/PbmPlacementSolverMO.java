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

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import com.vmware.pbm.PbmPlacementCompatibilityResult;
import com.vmware.pbm.PbmPlacementHub;
import com.vmware.pbm.PbmProfile;
import com.vmware.pbm.PbmProfileId;
import com.vmware.vim25.ManagedObjectReference;

import com.cloud.hypervisor.vmware.util.VmwareContext;

public class PbmPlacementSolverMO extends BaseMO {

    private static final Logger s_logger = Logger.getLogger(PbmPlacementSolverMO.class);

    public PbmPlacementSolverMO(VmwareContext context) {
        super(context, context.getPbmServiceContent().getPlacementSolver());
    }

    public PbmPlacementSolverMO(VmwareContext context, ManagedObjectReference morPlacementSolver) {
        super(context, morPlacementSolver);
    }

    public PbmPlacementSolverMO(VmwareContext context, String morType, String morValue) {
        super(context, morType, morValue);
    }

    public boolean isDatastoreCompatible(ManagedObjectReference dsMor, PbmProfile profile) throws Exception {
        boolean placementHubCompatible = false;
        if (dsMor == null || profile == null) {
            if (s_logger.isDebugEnabled()) {
                s_logger.debug("Unable to check compatibility of placement hub " +
                        "with pofile due to invalid placement hub or profile.");
            }
            return placementHubCompatible;
        }

        PbmPlacementHub placementHub = new PbmPlacementHub();
        placementHub.setHubId(dsMor.getValue());
        placementHub.setHubType(dsMor.getType());

        PbmProfileId profileId = profile.getProfileId();
        List<PbmPlacementHub> placementHubList = new ArrayList<PbmPlacementHub>();
        placementHubList.add(placementHub);
        List<PbmPlacementCompatibilityResult> placementCompatibilityResultList = _context.getPbmService().pbmCheckCompatibility(_mor, placementHubList, profileId);
        if (placementCompatibilityResultList != null && !placementCompatibilityResultList.isEmpty()) {
            for (PbmPlacementCompatibilityResult placementResult : placementCompatibilityResultList) {
                if ((placementResult.getError() == null || placementResult.getError().isEmpty()) &&
                        (placementResult.getWarning() == null || placementResult.getWarning().isEmpty())) {
                    placementHubCompatible = true;
                }
            }
        }
        if (s_logger.isDebugEnabled()) {
            if (placementHubCompatible) {
                s_logger.debug("Successfully verified that the placement hub : " + placementHub.getHubId() +
                        " is compatible with specified profile : " + profile.getName());
            } else {
                s_logger.debug("Placement hub : " + placementHub.getHubId() +
                        " is not compatible with specified profile : " + profile.getName());
            }
        }
        return placementHubCompatible;
    }
}
