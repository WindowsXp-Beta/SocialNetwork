"""12 bare-metal x86 nodes running Ubuntu 20.04 LTS (focal) 64-bit"""

#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

node_cnt = 12
nodes = []
hw_type = 'r320'
disk_img = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
for node_idx in range(node_cnt):
    node_new = request.RawPC('node-%s' % node_idx)
    node_new.hardware_type = hw_type
    node_new.disk_image = disk_img
    nodes.append((node_new, node_new.addInterface('interface-%s' % node_idx)))

# Link link-0
link_0 = request.Link('link-0')
link_0.Site('undefined')
for _, iface in nodes:
    link_0.addInterface(iface)

# Print the generated rspec
pc.printRequestRSpec(request)