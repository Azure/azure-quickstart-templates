from xml.etree.ElementTree import QName
import xml.etree.cElementTree as ET
from optparse import OptionParser
import sys

filename = " "

if __name__ == "__main__":

    parser = OptionParser()
    parser.add_option("-v","--hazelcast-version",dest="hazelcast_version")
    parser.add_option("-f","--filename",dest="filename")
    if len(sys.argv) > 0:
        opts,args = parser.parse_args(sys.argv)
        try:
            pom_ns = "http://maven.apache.org/POM/4.0.0"
            ET.register_namespace('', pom_ns)
            ns = {'pom_ns': pom_ns}
            tree = ET.parse(opts.filename)
            root = tree.getroot()

            for dependency in root.iter(str(QName(pom_ns, "dependency"))):
                if dependency.find("pom_ns:groupId", ns).text == "com.hazelcast" and dependency.find("pom_ns:artifactId", ns).text == "hazelcast":
                    dependency.find("pom_ns:version", ns).text = opts.hazelcast_version
            print("Updated hazelcast version at pom.xml...")

            tree.write(opts.filename)
            print("Updating pom.xml succeeded , file updated and saved at " + opts.filename)
        except IOError as e:
            print("Unable to open pom.xml, I/O error ({0}) : {1}".format(e.errno, e.strerror))

    else:
        print("Script exited without executing, no input parameters found")

