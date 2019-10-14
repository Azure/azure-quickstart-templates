from xml.etree.ElementTree import QName
import xml.etree.cElementTree as ET
from optparse import OptionParser
import sys

filename = " "

if __name__ == "__main__":

    parser = OptionParser()
    parser.add_option("-n","--cluster-name",dest="cluster_name")
    parser.add_option("-s","--subscription-id",dest="subscription_id")
    parser.add_option("-t","--tenant-id",dest="tenant_id")
    parser.add_option("-a","--aad-client-id",dest="aad_client_id")
    parser.add_option("-c","--aad-client-secret",dest="aad_client_secret")
    parser.add_option("-g","--group-name",dest="group_name")
    parser.add_option("-l","--cluster-tag",dest="cluster_tag")
    parser.add_option("-k","--cluster-port",dest="cluster_port")
    parser.add_option("-f","--filename",dest="filename")
    if len(sys.argv) > 0:
        opts,args = parser.parse_args(sys.argv)
        ## Opening the hazelcast.xml file
        try:
            ## f = open(opts.filename)
            ## Registering default namespace
            hazelcast_ns = "http://www.hazelcast.com/schema/config"
            ET.register_namespace('', hazelcast_ns)
            ns = {'hazelcast_ns': hazelcast_ns}
            ## Loading the root parser
            tree = ET.parse(opts.filename)
            root = tree.getroot()

            ## Finding and replacing the old group tag with the new one
            for group in root.iter(str(QName(hazelcast_ns, "group"))):
                group.find("hazelcast_ns:name", ns).text = opts.cluster_name
            print("Updated cluster user name...")

            for network in root.iter(str(QName(hazelcast_ns, "network"))):
                network.find("hazelcast_ns:port", ns).text = opts.cluster_port
            print("Updated cluster port...")

            print("Updating Azure discovery...")
            for azure in root.iter(str(QName(hazelcast_ns, "azure"))):
                azure.find("hazelcast_ns:client-id", ns).text = opts.aad_client_id
                azure.find("hazelcast_ns:client-secret", ns).text = opts.aad_client_secret
                azure.find("hazelcast_ns:tenant-id", ns).text = opts.tenant_id
                azure.find("hazelcast_ns:subscription-id", ns).text = opts.subscription_id
                azure.find("hazelcast_ns:cluster-id", ns).text = opts.cluster_tag
                azure.find("hazelcast_ns:group-name", ns).text = opts.group_name
            print("Updated Azure discovery....")

            tree.write(opts.filename)
            print("Updating configuration file suceeded , file updated and saved at " + opts.filename)
        except IOError as e:
            print("Unable to open configuration file, I/O error ({0}) : {1}".format(e.errno, e.strerror))

    else:
        print("Script exited without executing, no input parameters found")