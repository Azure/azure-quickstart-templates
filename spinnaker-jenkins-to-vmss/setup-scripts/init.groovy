package hudson.plugins.gradle;

import hudson.model.JDK
import hudson.tools.*
import jenkins.model.*
import hudson.model.*
import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;


def jdkdescriptor = new JDK.DescriptorImpl();
def grdlDescriptor = new Gradle.DescriptorImpl();
def OracleUser = args[0];
def OraclePwd = args[1];

// Add Orcale user credentials for JDK
def inst = Jenkins.getInstance()
def desc = inst.getDescriptor("hudson.tools.JDKInstaller")
println desc.doPostCredential(OracleUser,OraclePwd)

// Add the JDK installation
if (jdkdescriptor.getInstallations()) {
    println 'skip jdk installations'
} else {
    println 'add jdk8'
    Jenkins.instance.updateCenter.getById('default').updateDirectlyNow(true)
    def jdkInstaller = new JDKInstaller('jdk-8u121-oth-JPR', true)
    def jdk = new JDK("jdk8", null, [new InstallSourceProperty([jdkInstaller])])
    jdkdescriptor.setInstallations(jdk)
    jdkdescriptor.save()
}
inst.save()

// Add the Gradle configuration
println 'add gradle'
def grdlInstaller = new GradleInstaller('Gradle 3.3')
def grdl = new GradleInstallation('Gradle', '', [new InstallSourceProperty([grdlInstaller])] )
grdlDescriptor.setInstallations(grdl)
inst.save()


