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
""" Test cases for checking that the secondary Storage usage is accounted. This is verified by making sure that storage_type=4 is added in the cloud_usage.usage_storage
    table for a volume in 'Uploaded' state.

    This test case:
    1.Creates an account and uploads a volume.
    2.After the volume is uploaded successfully, restarts the usage server.
    3.Connectst ot the datbase
    4.From the database verifies that an entry is added to cloud_usage.usage_storage table with storage_type=4 for the uploaded volume.
    5.Clean up resources.
"""

from marvin.cloudstackTestCase import *
from marvin.cloudstackAPI import *
from marvin.lib.utils import *
from marvin.lib.base import *
from marvin.lib.common import *
from nose.plugins.attrib import attr
from marvin.sshClient import SshClient
from marvin.codes import (BACKED_UP, PASS, FAIL)
import time


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


def uploadVolume(self):
    # upload a volume
    self.debug("Upload volume format is '%s'" %self.uploadVolumeformat)
    self.testdata["configurableData"]["upload_volume"]["format"] = self.uploadVolumeformat
    self.testdata["configurableData"]["upload_volume"][
        "url"] = "http://10.147.28.7/templates/CentOS/centos65_password_ssh_enabled.vhd"
    upload_volume = Volume.upload(
        self.apiclient,
        self.testdata["configurableData"]["upload_volume"],
        account=self.account.name,
        domainid=self.domain.id,
        zoneid=self.zone.id
    )
    upload_volume.wait_for_upload(self.apiclient)
    return upload_volume.id

def restartUsageServer(self):
    """ Restart usage server """

    sshClient = SshClient(
        self.mgtSvrDetails["mgtSvrIp"],
        22,
        self.mgtSvrDetails["user"],
        self.mgtSvrDetails["passwd"]
    )
    command = "service cloudstack-usage restart"
    sshClient.execute(command)
    return

def checkUsage(self, uuid_upload_volume_id):
    volume_id = self.dbclient.execute("SELECT id from cloud.volumes where uuid='%s';" % uuid_upload_volume_id)
    self.debug("Volume id of uploaded volume is= %s" %volume_id[0]);
    qryresult_after_usageServerExecution = self.dbclient.execute("SELECT storage_type FROM cloud_usage.usage_storage where id = '%s';" % (volume_id[0]))
    self.debug("Storage Type is %s " %qryresult_after_usageServerExecution[0][0])

    self.assertEqual(qryresult_after_usageServerExecution[0][0], 4)

class TestSecondaryVolumeUsage(cloudstackTestCase):

    @classmethod
    def setUpClass(cls):
        testClient = super(TestSecondaryVolumeUsage, cls).getClsTestClient()
        cls.apiclient = testClient.getApiClient()
        cls.dbclient = testClient.getDbConnection()
        cls.testdata = testClient.getParsedTestDataConfig()
        cls.hypervisor = cls.testClient.getHypervisorInfo()
        cls.uploadVolumeformat = "VHD"
        cls.storagetype = 'shared'
        # Get Zone, Domain and templates
        cls.domain = get_domain(cls.apiclient)
        cls.zone = get_zone(cls.apiclient, testClient.getZoneForTests())
        cls.mgtSvrDetails = cls.config.__dict__["mgtSvr"][0].__dict__
        cls._cleanup = []

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


        cls.skip = 0
        hosts = list_hosts(
            cls.apiclient,
            type="Routing"
        )

        if hosts is not None:
            cls.skip = 1
            return
            raise unittest.SkipTest(
                "There are no hypervisor's available.Check listhosts response")
        for hypervisorhost in hosts:
            if hypervisorhost.hypervisor == "XenServer":
                cls.uploadVolumeformat = "VHD"
                break
            elif hypervisorhost.hypervisor == "VMware":
                cls.uploadVolumeformat = "OVA"
                break
            elif hypervisorhost.hypervisor == "KVM":
                cls.uploadVolumeformat = "QCOW2"
                break
            elif hypervisorhost.hypervisor == "LXC":
                cls.uploadvolumeformat = "QCOW2"
                break
            else:
                break

        cls.md5sum = cls.testdata["configurableData"][
            "browser_upload_volume"][cls.uploadVolumeformat]["checksum"]
        cls.pod = get_pod(cls.apiclient, cls.zone.id)

        cls.template = get_template(
            cls.apiclient,
            cls.zone.id,
            cls.testdata["ostype"])

        try:
            cls.skiptest = False
            if not (cls.IsUsageJobRunning):
                cls.skiptest = True
                return

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
    def IsUsageJobRunning(cls):
        """ Check that usage job is running on Management server or not"""

        sshClient = SshClient(
            cls.mgtSvrDetails["mgtSvrIp"],
            22,
            cls.mgtSvrDetails["user"],
            cls.mgtSvrDetails["passwd"]
        )

        command = "service cloudstack-usage status"
        response = str(sshClient.execute(command)).lower()
        if "running" not in response:
            return False
        return True

    def setUp(self):
        if self.skiptest:
            self.skipTest("Usage Server must be running for this test case.")


    @classmethod
    def tearDownClass(cls):
        try:
            cleanup_resources(cls.apiclient, cls._cleanup)
        except Exception as e:
            raise Exception("Warning: Exception during cleanup : %s" % e)

    @attr(tags=["basic", "advanced"], required_hardware="true")
    def test_01_SecondaryUsageUploadedVolume(self):
        try:
            uploaded_volume_id_uuid = uploadVolume(self)
            restartUsageServer(self)
            checkUsage(self, uploaded_volume_id_uuid)
        except Exception as e:
            self.tearDown()
            raise e
        return
