# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
""" Test cases for Checking the Hypervisor API called when VM is destroyed, depending on the value of vm.destroy.forcestop global config value.
    If set to true, Async.VM.hard_shutdown should be called, else Async.VM.clean_shutdown will be called.

    This test cases :
    1.Creates an account and a VM.
    2.Destroys the VM
    3.Depending on the value of 'vm.destroy.forcestop', check hypervisor API triggered on the host in the appropriate       log file (example on Xenserver it can be checked in /var/log/xensource.log) 
    4.Restore the destroyed VM and verify its state is 'Stopped' after restore.
    5.Start the VM
    6.Negate the value of the boolean parameter 'vm.destroy.forcestop'
    7.Destroy the VM. Check the API triggered on the host.(hard or clean shutdown) 
    8.Revert the value of the 'vm.destroy.forcestop' parameter to the original value
    9.Clean up resources.
"""

from marvin.cloudstackTestCase import *
from marvin.cloudstackAPI import *
from marvin.lib.utils import *
from marvin.lib.base import *
from marvin.lib.common import *
from nose.plugins.attrib import attr

from marvin.codes import (BACKED_UP, PASS, FAIL)

global original_valueOf_param

def verify_vm(self, vmid, state):
    list_vm = list_virtual_machines(self.userapiclient,
                                    account=self.account.name,
                                    domainid=self.account.domainid,
                                    id=vmid
                                    )
    self.assertEqual(
        validateList(list_vm)[0],
        PASS,
        "Check List vm response for vmid: %s" %
        vmid)
    self.assertGreater(
        len(list_vm),
        0,
        "Check the list vm response for vm id:  %s" %
        vmid)
    vm = list_vm[0]
    self.assertEqual(
        vm.id,
        str(vmid),
        "Vm deployed is different from the test")
    self.assertEqual(vm.state, state, "VM is in %s state" %state)


class TestShutdownTypeOnVmDestroy(cloudstackTestCase):

    @classmethod
    def setUpClass(cls):
        testClient = super(TestShutdownTypeOnVmDestroy, cls).getClsTestClient()
        cls.apiclient = testClient.getApiClient()
        cls.testdata = testClient.getParsedTestDataConfig()
        cls.hypervisor = cls.testClient.getHypervisorInfo()

        # Get Zone, Domain and templates
        cls.domain = get_domain(cls.apiclient)
        cls.zone = get_zone(cls.apiclient, testClient.getZoneForTests())

        cls.template = get_template(
            cls.apiclient,
            cls.zone.id,
            cls.testdata["ostype"])

        cls._cleanup = []

        try:
            cls.skiptest = False 
            if cls.hypervisor.lower() not in ['xenserver', 'kvm', 'vmware']:
                cls.skiptest = True
                return

            # Create an account
            cls.account = Account.create(
                cls.apiclient,
                cls.testdata["account"],
                domainid=cls.domain.id
            )
            cls._cleanup.append(cls.account)

            # Create user api client of the account
            cls.userapiclient = testClient.getUserApiClient(
                UserName=cls.account.name,
                DomainName=cls.account.domain
            )

            # Create Service offering
            cls.service_offering = ServiceOffering.create(
                cls.apiclient,
                cls.testdata["service_offering"],
            )
            cls._cleanup.append(cls.service_offering)

            cls.disk_offering = DiskOffering.create(
                cls.apiclient,
                cls.testdata["disk_offering"],
            )

            cls._cleanup.append(cls.disk_offering)

            cls.vm = VirtualMachine.create(
                cls.userapiclient,
                cls.testdata["small"],
                templateid=cls.template.id,
                accountid=cls.account.name,
                domainid=cls.account.domainid,
                serviceofferingid=cls.service_offering.id,
                zoneid=cls.zone.id
				)

        except Exception as e:
            cls.tearDownClass()
            raise e
        return

    @classmethod
    def tearDownClass(cls):
        try:
            #Revert back the value of the config parameter to the original value.
            cleanup_resources(cls.apiclient, cls._cleanup)
        except Exception as e:
               raise Exception("Warning: Exception during cleanup : %s" % e)

    def setUp(self):
        if self.skiptest:
            self.skipTest("This test is to be checked on Xenserver, KVM and VmWare only. Hence, skipping for %s"  % self.hypervisor)

    def tearDown(self):
        try:
            updateConfigurationCmd = updateConfiguration.updateConfigurationCmd()
            updateConfigurationCmd.name = "vm.destroy.forcestop"
            updateConfigurationCmd.value = original_valueOf_param
            self.apiclient.updateConfiguration(updateConfigurationCmd)
            self.debug("Reset the value of 'vm.destroy.forcestop' to %s"%original_valueOf_param)
        except Exception as e:
            raise Exception("Warning: Exception during cleanup : %s" % e)
        return


    @attr(tags=["basic", "advanced"], required_hardware="true")
    def test_01_ShutdownTypeOnVmDestroy(self):
        try:
            listConfigurationsCmd = listConfigurations.listConfigurationsCmd()
            listConfigurationsCmd.cfgName = "vm.destroy.forcestop"
            listConfigurationsResponse = self.apiclient.listConfigurations(listConfigurationsCmd)

            for item in listConfigurationsResponse:
                    if item.name == "vm.destroy.forcestop":
                        global original_valueOf_param
                        original_valueOf_param = item.value
                        if str(original_valueOf_param).lower() == 'true':
                            new_param_value = 'false'
                        else:
                            new_param_value = 'true'

            verify_vm(self, self.vm.id, 'Running')
            self.vm.delete(self.apiclient, expunge=False)
            cmd = recoverVirtualMachine.recoverVirtualMachineCmd()
            cmd.id = self.vm.id
            self.apiclient.recoverVirtualMachine(cmd)

            """Test recover Destroyed Virtual Machine
             """
            #Validate the following
            # 1. listVM command should return this VM.
            #  State of this VM should be "Stopped".
            self.debug("Recovering VM - ID: %s" % self.vm.id)

            #Verify that VM is in Stopped state after recovering it.
            verify_vm(self, self.vm.id, 'Stopped')
            #Start the VM for testing the destroy after resetting the value of the config parameter.
            self.vm.start(self.apiclient)

            verify_vm(self, self.vm.id, 'Running')

            updateConfigurationCmd = updateConfiguration.updateConfigurationCmd()
            updateConfigurationCmd.name = "vm.destroy.forcestop"
            updateConfigurationCmd.value = new_param_value
            updateConfigurationResponse = self.apiclient.updateConfiguration(updateConfigurationCmd)
            self.debug("Updated the parameter %s with value %s"%(updateConfigurationResponse.name, updateConfigurationResponse.value))

            self.vm.delete(self.apiclient, expunge=False)
            cmd = recoverVirtualMachine.recoverVirtualMachineCmd()
            cmd.id = self.vm.id
            self.apiclient.recoverVirtualMachine(cmd)

            self.debug("Recovering VM - ID: %s" % self.vm.id)

            #Verify that VM is in Stopped state after recovering it.
            verify_vm(self, self.vm.id, 'Stopped')

        except Exception as e:
            self.tearDown()
            raise e
	    return
