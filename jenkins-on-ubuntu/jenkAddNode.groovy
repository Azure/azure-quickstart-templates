import jenkins.model.*
import hudson.model.*
import hudson.slaves.*


if (args.length > 0) {
  int cnt = args[0].toInteger()

  for (int i = 0; i < cnt; i++) {
    String name = "Slave" + Integer.toString(i)
    
    Jenkins.instance.addNode(new DumbSlave(name,"Description","/var/jenkins","1",Node.Mode.NORMAL,"label",new JNLPLauncher(),new RetentionStrategy.Always(),new LinkedList()))
  }
}
