namespace TestServiceNamespace
{
    using System;
    using System.ComponentModel;
    using System.Configuration.Install;
    using System.IO;
    using System.ServiceProcess;

    [RunInstaller(true)]
    public class MyProjectInstaller : Installer
    {
        private ServiceInstaller serviceInstaller;
        private ServiceProcessInstaller processInstaller;

        public MyProjectInstaller()
        {
            processInstaller = new ServiceProcessInstaller();
            serviceInstaller = new ServiceInstaller();
            processInstaller.Account = ServiceAccount.LocalSystem;
            serviceInstaller.StartType = ServiceStartMode.Manual;
            serviceInstaller.ServiceName = TestService.TestServiceName;
            serviceInstaller.DisplayName = TestService.TestServiceDisplayName;
            serviceInstaller.Description = TestService.TestServiceDescription;
            serviceInstaller.ServicesDependedOn = new string[] { TestService.TestServiceDependsOn };
            Installers.Add(serviceInstaller);
            Installers.Add(processInstaller);
        }
    }

    public class TestService : ServiceBase
    {
        public const string TestServiceName = "TestServiceReplacementName";
        public const string TestServiceDisplayName = "TestServiceReplacementDisplayName";
        public const string TestServiceDescription = "TestServiceReplacementDescription";
        public const string TestServiceDependsOn = "TestServiceReplacementDependsOn";

        private string fileName = null;
        private System.ComponentModel.IContainer components = null;
        private bool failToStop = false;

        public TestService()
        {
            this.CanStop=true;
            this.CanPauseAndContinue=true;
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            if(args.Length == 1 && args[0] == "FailToStop")
            {
                this.failToStop=true;
                return;
            }

            if (args.Length == 0 || !Path.IsPathRooted(args[0]))
            {
                return;
            }

            this.fileName=args[0];
            using (StreamWriter writer = File.CreateText(fileName))
            {
                writer.WriteLine("Service started at {0}.", DateTime.Now);
                writer.WriteLine("Argument count: {0}.\r\nArguments:", args.Length);
                foreach (string arg in args)
                {
                    writer.WriteLine("   '{0}'", arg);
                }
            }
        }

        protected override void OnStop()
        {
            if(this.failToStop)
            {
                this.failToStop = false;
                throw new Exception("Will fail to stop");
            }

            if (this.fileName == null) { return; }
            using (StreamWriter writer = File.AppendText(this.fileName))
            {
                writer.WriteLine("Service stopped at {0}.", DateTime.Now);
            }
        }

        protected override void OnPause()
        {
            base.OnPause();
        }

        protected override void OnContinue()
        {
            base.OnContinue();
        }


        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            this.ServiceName = TestService.TestServiceName;
        }

        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[]
            {
                new TestService()
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}
