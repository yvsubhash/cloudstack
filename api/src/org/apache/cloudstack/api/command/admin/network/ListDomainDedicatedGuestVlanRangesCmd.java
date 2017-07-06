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
package org.apache.cloudstack.api.command.admin.network;

import org.apache.cloudstack.acl.RoleType;
import org.apache.cloudstack.api.APICommand;
import org.apache.cloudstack.api.response.GuestVlanRangeResponse;

/**
 * @deprecated as of 4.11 use the new api {@link ListDedicatedGuestVlanRangesCmd}
 */

@APICommand(name = "listDomainDedicatedGuestVlanRanges", description = "Lists dedicated guest vlan ranges for domains", responseObject = GuestVlanRangeResponse.class,
        requestHasSensitiveInfo = false, responseHasSensitiveInfo = false, authorized = { RoleType.Admin, RoleType.DomainAdmin, RoleType.ResourceAdmin})
public class ListDomainDedicatedGuestVlanRangesCmd extends ListDedicatedGuestVlanRangesCmd {

}