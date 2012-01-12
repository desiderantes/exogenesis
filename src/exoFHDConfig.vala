using Gtk;
using Gee;

namespace Exogenesis
{
    public class FHDConfig : Gtk.Layout
    {
        // GTK Controls
        private Gtk.Box segbox1;
        private Gtk.Box segbox2;
        private Gtk.Button btnPrevious;
        private Gtk.Button btnNext;
        private Gtk.Button btnCancel;
        private Gtk.RadioButton rdoAdvanced;
        private Gtk.RadioButton rdoUseAll;
        private Gtk.CheckButton chkKeepHome;
        private SegmentedBar segbarHD;
        private SegmentedBar segbarHDA;
        private Gtk.Fixed fxdHDConfig;
        private Gtk.Label lblHD;
        private Gtk.ComboBox cboHD;
        private Gtk.Label lblPrevious;
        private Gtk.Button btnCreateTest;
        private Gtk.Image imgBackground;

        // local vars
        private ListStore _disks = new ListStore(2, typeof(string), typeof(string) );

        public FHDConfig()
        { 
        	this.build(); 
        	this.add(fxdHDConfig);
        	this.GetDiskInfo();
        	gPreviousOS.GetFSTabMountPoints();
      	}

        private void build()
        {
            try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                // get the widgets
                this.fxdHDConfig = (Gtk.Fixed) builder.get_object("fxdHDConfig");
                this.imgBackground = ( Gtk.Image ) builder.get_object("imgBackground");
                this.imgBackground.set_from_file("%s/images/default_bkground.png".printf(AppPath) );       
                this.segbox1 = (Gtk.Box) builder.get_object("boxHD1");
                this.segbox2 = (Gtk.Box) builder.get_object("boxHD2");
                this.btnPrevious = (Gtk.Button) builder.get_object("btnHDPrevious");
                this.btnNext = (Gtk.Button) builder.get_object("btnHDNext");
                this.btnCancel = (Gtk.Button) builder.get_object("btnHDCancel");
                this.lblHD = (Gtk.Label) builder.get_object("lblHD");
                this.cboHD = (Gtk.ComboBox) builder.get_object("cboHD");
                this.rdoAdvanced = (Gtk.RadioButton) builder.get_object("rdoHDAdvanced");
                this.rdoUseAll = (Gtk.RadioButton) builder.get_object("rdoHDCUseAll");
                this.chkKeepHome = (Gtk.CheckButton) builder.get_object("chkHDKeepHome");
                this.lblPrevious = ( Gtk.Label ) builder.get_object("lblPrevious");
                this.btnCreateTest = ( Gtk.Button ) builder.get_object("btnCreateTest");


                this.segbarHD = new SegmentedBar();
                this.segbarHDA = new SegmentedBar();

                // wire the control events
                this.btnNext.clicked.connect (this.OnBtnNext_Click );
                this.btnPrevious.clicked.connect ( this.OnBtnPrevious_Click );
                this.btnCancel.clicked.connect ( this.OnBtnCancel_Click );
                this.cboHD.changed.connect ( this.OnCboHD_Changed );
                this.rdoAdvanced.clicked.connect ( this.OnRdoAdvanced_Click );
                this.rdoUseAll.clicked.connect ( this.OnRdoUseAll_Click );
                this.fxdHDConfig.realize.connect ( this.OnFxdHDConfig_Realize );
                this.chkKeepHome.clicked.connect ( this.OnChkKeepHome_Click );
                this.btnCreateTest.clicked.connect ( this.OnBtnCreate_Click);

                // set the size of layout to size of fixed
                this.width_request = this.fxdHDConfig.width_request;
                this.height_request = this.fxdHDConfig.height_request;
				
                // disk manager events
                gHDManager.DriveMounted.connect ( this.OnDriveMounted );
                gHDManager.DriveUnMounted.connect ( this.OnDriveUnMount );
                gHDManager.DiskManagerError.connect ( this.OnDiskManagerError );
                gHDManager.DevicesRefreshed.connect ( this.OnDevicesRefreshed );

               	segbarHD.BarHeight = 20; 
                segbarHD.HorizontalPadding = segbarHD.BarHeight / 2;
                segbarHD.ShowReflection = true;
                segbox1.pack_start (segbarHD, false, false, 0);
                segbox1.show_all ();

              	segbarHDA.BarHeight = 20; 
                segbarHDA.HorizontalPadding = segbarHDA.BarHeight / 2;
                segbarHDA.ShowReflection = true;
                segbox2.pack_start (segbarHDA, false, false, 0);

                segbox2.show_all ();

                // set labels (for translations)
                this.SetLabels();

                // set up HD combo
                cboHD.set_model(this._disks);
                CellRendererText cellHD = new CellRendererText();
                cboHD.pack_start(cellHD, true);
                cboHD.add_attribute(cellHD, "text", 0);                

                this.show_all();
            } 
            catch (GLib.Error err) 
            {
                var msg = new Gtk.MessageDialog (
                null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.CANCEL,
                "Failed to load UI\n" + err.message);
                msg.run();
                Gtk.main_quit();
            }                    
        }

        private void SetLabels()
        { }

        private void GetDiskInfo()
        {
            TreeIter iter;
			this._disks.clear();
            foreach ( HardDisk d in gHDManager.HardDisks )
            {
                if ( ! d.IsOptical && d.SerialNumber != null )
                {
                    this._disks.append(out iter);
                    string displaytxt = "%s - %s".printf(d.Model, d.CapacityDescription);
                    this._disks.set (iter, 0, displaytxt, 1, d.SerialNumber, -1);
                }
            }
            cboHD.set_active(0);
        }

        private void DisplayPartitionInfo(string hdserial, SegmentedBar segbar)
        {
            int partcount = 0;
			string label = "";

            segbar.RemoveAllSegments();
			if ( hdserial != null )
			{
	            foreach ( HardDisk hd in gHDManager.HardDisks )
	            {
	                if ( hd.SerialNumber != null && hd.SerialNumber == hdserial && ! hd.IsOptical)
	                {
	                    // sort by partition number
	                    hd.SortPartitions();

	                    // add the partitions to bar, ignore the extended partition type
	                    foreach ( PartitionInfo p in hd )
	                    {
	                        if ( p.OSType != "" && ! p.PartitionType.down().contains("extended") )
	                        {   
	                            label = "%s\n%s %s".printf(p.OSType, p.CapacityDescription, p.FSTabMountPoint); 
	                            this.AddToDisk( segbar, hd.Capacity, p.Capacity, label, partcount ); 
	                        }
	                        else if ( p.PartitionType.down().contains("extended") )
	                        {
								foreach ( PartitionInfo pi in p )
	                    		{
		                    		label = "%s\n%s".printf(pi.OSType, pi.CapacityDescription); 
		                    		this.AddToDisk( segbar, hd.Capacity, pi.Capacity, label, partcount );
		                    		partcount ++;
	                    		}
	                        }
	                        partcount ++;
	                    }
	                    // display current OS
	                    if ( hd.PreviousOS != null && hd.PreviousOS != "" )
	                    { this.lblPrevious.label = "This disk contains a version of %s".printf(hd.PreviousOS); }
	                    else
	                    { this.lblPrevious.label = ""; }
	                }
	            }
    		}
        }

        // get the selected HD
        private string GetSelectedHD()
        {
            TreeIter iter;
            string di;
            GLib.Value val;
            
            this.cboHD.get_active_iter(out iter);
            this._disks.get_value(iter, 1, out val);
            di = (string)val;
            return di;            
        }
        
        private void DisplaySuggested(string hdserial)
        {
            string title;
            string displaysize;
            uint64 partsize;
            HardDisk hd = gHDManager.GetHDBySerial( hdserial );
            
            if ( hd != null )
            {
                this.segbarHDA.RemoveAllSegments();

                // root partition
                partsize = this.RootSize(hd.Capacity);
                displaysize = GeneralFunctions.FormatHDSize(partsize);
                title = "%s - %s\n%s - %s".printf( "/root", displaysize,  "Ext4", "Formatted");
                this.AddToDisk(this.segbarHDA, hd.Capacity, partsize, title, 1);

                // home partition
                partsize = this.HomeSize(hd.Capacity);
                displaysize = GeneralFunctions.FormatHDSize(partsize);            
                title = "%s - %s\n%s - %s".printf( "/home", displaysize, "Ext4", "Keep Existing");
                this.AddToDisk(this.segbarHDA, hd.Capacity, partsize, title, 2);

                // var partition
                partsize = this.VarSize(hd.Capacity);
                displaysize = GeneralFunctions.FormatHDSize(partsize);            
                title = "%s - %s\n%s - %s".printf( "/var", displaysize, "Ext4", "Formatted");
                this.AddToDisk(this.segbarHDA, hd.Capacity, partsize, title, 3);

                // home partition
                partsize = this.SwapSize(hd.Capacity);
                displaysize = GeneralFunctions.FormatHDSize(partsize);            
                title = "%s - %s\n%ss".printf( "swap space", displaysize, "Swap");
                this.AddToDisk(this.segbarHDA, hd.Capacity, partsize, title, 4);
            }
        }

        // Partitions have already been defined for disk, so display them
        private void DisplayInstallHDInfo(string serial)
        {
            this.segbarHDA.RemoveAllSegments();

            if ( gInstallData.HardDiskCount > 0 )
            {
                foreach ( InstallHardDisk hd in gInstallData )
                {
                    if ( hd.SerialNumber == serial )
                    {
                        uint64 totalused = 0;
                        int pCount = 1;

                        foreach ( InstallPartition ip in hd )
                        {
                            uint64 partsize;
                            string displaysize, title, formattext;

                            formattext = ( ip.Format || ip.NewPartition ) ? "Formatted" : "Keep Existing";
                            partsize = ip.ByteSize;
                            displaysize = GeneralFunctions.FormatHDSize(partsize);
                            title = "%s - %s\n%s - %s".printf( ip.MountPoint, displaysize,  ip.Type, formattext);
                            this.AddToDisk(this.segbarHDA, gHDManager.GetHDBySerial(serial).Capacity, partsize, title, pCount);
                            totalused += partsize;
                            pCount++;
                        }

                        // add the unallocated part
                        uint64 available =  gHDManager.GetHDBySerial(serial).Capacity - totalused;
                        if ( segbarHDA.Remainder > 0 )
                        {
                            AddToDisk(this.segbarHDA, gHDManager.GetHDBySerial(serial).Capacity, available, "UNALLOCATED", 7 );
                        }
                    }
                }
            }
        }

        private void PopulateInstallInfo()
        {
            // get the selected HD
            HardDisk currentHD = gHDManager.GetHDBySerial( this.GetSelectedHD() );
            
            // create a new install disk
            InstallHardDisk iHD = new InstallHardDisk();
            
            iHD.DeviceName = currentHD.Device;
            iHD.SerialNumber = currentHD.SerialNumber;
            
            // add the partitions from here
            if ( this.chkKeepHome.active == true )
            {
                // populate based on existing schema
                foreach ( PartitionInfo pi in currentHD )
                {
                    if ( ! pi.PartitionType.down().contains("extended") )
                    {
                        InstallPartition ip = new InstallPartition();

                        ip.ByteSize = pi.Capacity;
                        ip.DisplaySize = GeneralFunctions.FormatHDSize(pi.Capacity);
                        ip.Format = (pi.MountPoint.contains("home")) ? false : true;
                        ip.MountPoint = pi.MountPoint;
                        ip.Type = pi.OSType;
                        ip.Label = pi.PartitionLabel;
                        ip.Device = pi.Device;
                    
                        iHD.AddPartition(ip);
                        ip = null;
                    }
               }
            }
            else
            {
                // populate per suggested schema
                InstallPartition ip = new InstallPartition();
                
                ip.ByteSize = this.RootSize(currentHD.Capacity);
                ip.DisplaySize = GeneralFunctions.FormatHDSize( this.RootSize(currentHD.Capacity) );
                ip.Format = true;
                ip.Label = "";
                
            }
            
            gInstallData.AddInstallDisk(iHD);
        }

// EVENT methods ---------------------------------------------------------------------------------------------------------------

		private void OnDevicesRefreshed()
		{ this.GetDiskInfo(); }

        private void OnDiskManagerError(GLib.Error error)
        { 
            GeneralFunctions.LogIt("event fired for error - HD Manager Error - %s\n".printf( error.message ));
        }
        
        private void OnDriveMounted(string mountpoint)
        { 
            gPreviousOS.GetFSTabMountPoints();
            this.OnCboHD_Changed(); 
        }
        
        private void OnDriveUnMount()
        {
           // stdout.printf("event fired for unmount - Disk unmounted\n");
        }
        
         public void OnRdoAdvanced_Click()
        {
			this.rdoUseAll.active = false;
            this.chkKeepHome.active = false;
            this.chkKeepHome.sensitive = false;
            
          //  if ( this.rdoAdvanced.active == true )
          //  { GeneralFunctions.ShowWindow(new FPartitioner( gHDManager.GetHDBySerial(this.GetSelectedHD()) ), 
          //  											   "Exogenesis", true); } 
        }

        public void OnRdoUseAll_Click()
        {
            this.chkKeepHome.sensitive = true;
            HardDisk hd = gHDManager.GetHDBySerial(this.GetSelectedHD());
            
            if ( hd.HasHomePartition )
            { this.chkKeepHome.active = true; }
            else
            {
                this.chkKeepHome.active = false; 
                this.DisplaySuggested( this.GetSelectedHD() ); 
            }
        }

        public void OnChkKeepHome_Click()
        {
            string hdserial = this.GetSelectedHD();
            
            if ( this.chkKeepHome.active )
            { this.DisplayPartitionInfo(hdserial, this.segbarHDA); }                
            else
            { this.DisplaySuggested(hdserial); }            
        }

        public void OnBtnNext_Click()
        {
	        stdout.printf("HARDDISKS USED = %s\n", gInstallData.HardDiskCount.to_string() );
         //   if ( gInstallData.HardDiskCount == 0 )
         //   { this.PopulateInstallInfo(); }
             
            ((MainWin)this.parent).ShowNextWindow(); 
        }

        public void OnBtnCreate_Click()
        {
            Installer inst = new Installer();
            inst.CreatePartitionsStart(gInstallData.GetTargetHD(0) );
        }

        public void OnBtnPrevious_Click()
        { ((MainWin)this.parent).ShowPreviousWindow(); }

        public void OnBtnCancel_Click()
        { ((MainWin)this.parent).Cancel(); }

        private void AddToDisk(SegmentedBar bar, uint64 HDSize, uint64 PartitionSize, string title, int count )
        {
            double hdtotal = (double)( HDSize / 1024 / 1024 );
            double ptnsize = (double) (PartitionSize / 1024 / 1024);
            int percent = (int)(Math.round( (ptnsize / hdtotal) * 100 )); 

            bar.SegmentLabelSpacing = 20;
            bar.AddSegmentRgb (title, percent, GeneralFunctions.BarColour(count) );
        }       
        
        public void OnCboHD_Changed()
        {
            string hdserial = this.GetSelectedHD();

			if ( hdserial != null )
			{
	            // display current HD info
	            DisplayPartitionInfo(hdserial, this.segbarHD);
	            
	            // check if a linux disk has been selected
	            this.chkKeepHome.active = gHDManager.GetHDBySerial(hdserial).HasHomePartition;
	            this.chkKeepHome.sensitive = this.chkKeepHome.active;
	            
	            // check if the default option used
	            // set the suggested layout to current to avoid resize
	            if ( this.rdoUseAll.get_active() == true )
	            { 
	                if ( this.chkKeepHome.active )
	                { this.DisplayPartitionInfo(hdserial, this.segbarHDA); }                
	                else
	                { this.DisplaySuggested(hdserial); } 
	            }
	            else
	            {
	                if ( gInstallData.HardDiskCount > 0 )
	                {
	                    this.DisplayInstallHDInfo(hdserial);
	                } 
	            }
            }
        }

        public void OnFxdHDConfig_Realize()
        { this.OnCboHD_Changed(); }

		public void OnDeviceConnected()
		{  this.GetDiskInfo(); }
		

//----------------------------------------------------------------------
//
// CALCULATIONS NEEDED TO WORK OUT THE PARTITIONS BASED ON
//
// - HD SIZE
// - RAM SIZE (FOR SWAP)
// pecentage of disk used for root
//
//----------------------------------------------------------------------
        private uint64 RootSize(uint64 totalsize)
        {
            return (totalsize / 100) * 20;
        }
        
        private uint64 HomeSize(uint64 totalsize)
        {
            return (totalsize / 100) * 66;
        }
        
        private uint64 VarSize(uint64 totalsize)
        {
            return ( totalsize / 100) * 10;
        }
        
        private uint64 SwapSize(uint64 totalsize)
        {
            return ( totalsize / 100) * 4;
        }
//----------------------------------------------------------------------
//
// SIZE CALCULATION FORMULA NEEDED
//
//----------------------------------------------------------------------
    }    
}