using GLib;
using Gdu;
using Gee;

namespace Exogenesis
{
    //-------------------------------------------------------------------------
    // Main HD control class, get info, create paritions, format etc
    //-------------------------------------------------------------------------
	public class HDManager
	{
	    // events
	    public signal void DriveMounted(string mountpoint);
	    public signal void DriveUnMounted();
	    public signal void PartitionCreated(int size, string typename);
	    public signal void PartitionDeleted(int freespace);
        public signal void DiskManagerError(GLib.Error err);
        public signal void DeviceAdded(HardDisk hd);
        public signal void DeviceRemoved(HardDisk hd);
        public signal void DeviceChanged(HardDisk hd);
        public signal void DeviceConnected();
        public signal void DeviceActionComplete(string action, int currentPindex, int currentEindex, InstallHardDisk ihd);
        public signal void DevicesRefreshed();

        public bool ThreadStop = false;
        public bool PartitionerRunning = false;

	    // private class vars    
	    private Gdu.Pool _drivepool;	    
        private MountPoints _MountPoints  = new MountPoints();
        private bool _MountComplete = false;
        private HashMap<string, string> FSTab = new HashMap<string, string>(str_hash, str_equal);
        
        public Gee.ArrayList<HardDisk> HardDisks = new Gee.ArrayList<HardDisk>();
        private Gee.ArrayList<FilesystemType> _fsTypes = new Gee.ArrayList<FilesystemType>();
        
        private int _currentPIdx;
        private int _currentEIdx;

        private InstallHardDisk _currentIDH;

		public int HardDiskCount 		{ get; set; }
        
        public Gee.ArrayList<FilesystemType> FileSystemTypes
        { get { return this._fsTypes; } }

	    // Default constructor
	    public HDManager()
	    {
	        // set drivepool ref 
	        this._drivepool = new Gdu.Pool();

	        // get the supported filesystem types
	        this.PopulateFileSystemTypes(true);

	        // get the drives attached now
	        this.GduGetDevices();

	        // populate mount points list
	        this._MountPoints.AddMountPointValues("root", "/", 0);
	        this._MountPoints.AddMountPointValues("home", "/home", 1);
	        this._MountPoints.AddMountPointValues("boot", "/boot", 2);
	        this._MountPoints.AddMountPointValues("opt", "/opt", 3);
	        this._MountPoints.AddMountPointValues("var", "/var", 4);
	        this._MountPoints.AddMountPointValues("none", "", 5);

	        // wire device events
            this._drivepool.device_added.connect( OnDeviceConnected );
            this._drivepool.device_removed.connect ( OnDeviceRemoved );
            this._drivepool.device_changed.connect ( OnDeviceChanged );
        }

		// reload the disk information
		public void RefreshDisks()
		{ 
			this.HardDisks.clear();
			this.GduGetDevices(); 
			this.DevicesRefreshed();
		}

        // get a hard disk object matching the serial num
        public HardDisk GetHDBySerial( string serialNumber )
        {
            HardDisk ret = null;

            foreach ( HardDisk hd in this.HardDisks )
            {
                if ( hd.SerialNumber == serialNumber )
                {
                    ret = hd;
                    break;
                }
            }
            return ret;
        }

        // get a hard disk object matching the device name
        public HardDisk GetHDByDevice( string deviceName )
        {
            HardDisk ret = null;

            foreach ( HardDisk hd in this.HardDisks )
            {
                if ( hd.Device == deviceName )
                {
                    ret = hd;
                    break;
                }
            }
            return ret;
        }

        public void MountTargetDisk()
        {
        }

        public void UnMountTargetDisk()
        {
        }

        // used to compare string at char/code level
        private bool HasStrv0 (string **strv, string *str)
        {
            bool ret;

            ret = false;

            for (int n = 0; strv != null && strv[n] != null; n++) 
            {
                if (strcmp(strv[n], str) == 0) 
                {
                    ret = true;
                    break;
                }
            }
            return ret;
        }

        // returns the list of valid mount points
        public MountPoints GetMountPoints()
        { return this._MountPoints; }

        // returns a populated HD object with partition info
	    private void GduGetDevices()
	    {
			try
			{
				GLib.List<Gdu.Drive> drvs = this.GetDrives();

	            // loop through disks and enumerate/populate disk/partition info
	            foreach ( Gdu.Drive drv in drvs )
	            {
		            // check if the drive is CD/DVD
		            if ( ! HasStrv0(drv.get_device().drive_get_media_compatibility(), "optical_cd") )
		            {
	                	// populate the HD object
	                	HardDisk hd = new HardDisk();
	                	hd.Device = drv.get_device().get_device_file();
	                	hd.Model = drv.get_device().drive_get_model();
	                	hd.Firmware = drv.get_device().drive_get_revision();
	                	hd.Location = "";
	                	hd.SerialNumber = drv.get_device().drive_get_serial();
	                	hd.CapacityDescription = Gdu.util_get_size_for_display(drv.get_size(), false, false);
	                	hd.Capacity = drv.get_size();
	                	hd.IsOptical = false;

	                	// get the enclosed volumes
	                	GLib.List<Gdu.Volume> vols = (GLib.List<Gdu.Volume>)drv.get_enclosed().copy();

	                	// get the volumes on the drive
	                	foreach ( Gdu.Volume vol in vols )
	                	{
		                	// get the first level details, Primary and any extended, ignore any partitions in the extended
							if ( vol.get_enclosing_presentable().get_name() == drv.get_name() )
							{ 
		                    	PartitionInfo pi = this.PopulatePartition(vol);
		                    	
		                    	// check if volume is enclosing partitions
		                    	GLib.List<Gdu.Volume> parts =  ((GLib.List<Gdu.Volume>)vol.get_enclosed()).copy();
		                    	
		                    	foreach ( Gdu.Volume v in parts )
		                    	{ pi.AddPartition( this.PopulatePartition( v ) ); }
		                    	hd.AddPartition(pi);
		                	}
	                	}
	                	hd.SortPartitions();
	                	this.HardDisks.add(hd);
						this.HardDiskCount += 1;
                	}
	            }
            }
            catch ( GLib.Error error )
            { GeneralFunctions.LogIt("ERROR ENUMERATING DEVICES - %s\n".printf(error.message) ); }
	    }

		private PartitionInfo PopulatePartition( Gdu.Volume vol )
		{
			// create the partition info object
        	PartitionInfo pi = new PartitionInfo();

        	// common details regardless of allocated or not
        	pi.CapacityDescription = Gdu.util_get_size_for_display(vol.get_size(), false, false);               // e.g. 82GB
        	pi.Capacity = vol.get_size();                                                                       // e.g. 82123333  - in bytes
        	pi.StartSector = vol.get_offset();
        	pi.EndSector = vol.get_offset() + vol.get_size();
			pi.ParentDevice =  ( vol.get_enclosing_presentable().get_device() != null ) ?
								 vol.get_enclosing_presentable().get_device().get_device_file() : "";

        	// Check if the OS Knows what the volume is
        	if ( vol.get_description().down().contains("unknown") )
        	{
        		pi.Device = vol.get_device().get_device_file();
        		pi.OSType = "Unknown";
        		pi.PartitionType = "Unknown"; 
        	}
        	else
        	{
        		// check to see if the volume has been allocated
            	if ( vol.get_type() != typeof(Gdu.VolumeHole) )
            	{
                    Gdu.Device dev = vol.get_device();
                    pi.Device = dev.get_device_file();                                                             // e.g /dev/sda1
                    pi.PartitionType = Gdu.util_get_desc_for_part_type(vol.get_device().partition_get_scheme(),
                                                                       vol.get_device().partition_get_type() );    // e.g. Linux (0x83) / Linux Swap (0x82)
                    pi.PartitionFlags = vol.get_device().partition_get_flags();                                    // e.g. bootable
                    pi.OSType = Gdu.util_get_fstype_for_display(dev.id_get_type(), 
                                                                dev.id_get_version(), true);                       // e.g. Ext4 (Version 1.0)
                    pi.OSTypeID = dev.id_get_type().to_string();
                    pi.Usage = vol.get_device().id_get_usage();                                                    // e.g. Filesystem, Container for logical...
                    pi.Label = vol.get_device().id_get_label();                                                    // e.g. mainboot (user set)
                    pi.PartitionLabel = "";
                    pi.PartitionNumber = vol.get_device().partition_get_number();
                    pi.UUID = vol.get_device().id_get_uuid();
                    pi.FSTabMountPoint = "";

                   // mount the disk
                   // if ( vol.get_device().is_partition() && ! pi.PartitionType.down().contains("extended") && !vol.get_device().is_mounted() )
                   // { vol.get_device().op_filesystem_mount( null, MountCallBack ); }
            	}
            	else
           	 	{
                	pi.Device = vol.get_drive().get_name();
                	pi.OSType = "Unallocated";
                	pi.PartitionType = "UNALLOCATED";
            	}
    		}
    		return pi;		
		}

        // Gets the HD drives installed on system
        private GLib.List<Gdu.Drive> GetDrives()
        {
            unowned GLib.List<Gdu.Device> devs = _drivepool.get_devices();
            GLib.List<Gdu.Drive> drvs = new GLib.List<Gdu.Drive>();
           
            foreach ( Device d in devs )
            {
                if ( d.is_drive() && !d.is_optical_disc() )
                {
                    GeneralFunctions.LogIt( "DEVICE FOUND %s\n".printf(d.get_device_file() ) ); 
                    drvs.append( (Gdu.Drive)this._drivepool.get_drive_by_device(d) ); 
                }
            }
            return drvs;
        }


	    // gets a list of all the partition format types
	    // that can be used.
	    public void PopulateFileSystemTypes( bool includeExtended )
	    {
		    try
		    {
		        Gdu.Pool pool = new Gdu.Pool();

		        foreach ( Gdu.KnownFilesystem kfs in (GLib.List<Gdu.KnownFilesystem>)pool.get_known_filesystems() )
		        {
		            FilesystemType fs = new FilesystemType();
		            fs.ID = kfs.get_id();
	                fs.Name = kfs.get_name();
	                fs.CanCreate = kfs.get_can_create();
	                fs.CanMount = kfs.get_can_mount();
	                fs.MaxLabelLen = (int)kfs.get_max_label_len();
	                fs.SupportUnixOwner = kfs.get_supports_unix_owners();
	                fs.AllowLabelRename = kfs.get_supports_label_rename();
	                fs.SupportFsck = kfs.get_supports_fsck();
	                fs.SupportResizeEnlarge = kfs.get_supports_resize_enlarge();
	                fs.SupportResizeShrink = kfs.get_supports_resize_shrink();
	                fs.SupportEnlargeOnline = kfs.get_supports_online_resize_enlarge();
	                fs.SupportShrinkOnline = kfs.get_supports_online_resize_shrink();
	                this._fsTypes.add(fs);
		        }

		        // add the extended Partition
		        FilesystemType fs = new FilesystemType();
		        fs.ID = "0x05";
		        fs.Name = "Extended Partition";
		        this._fsTypes.add(fs);
	        }
	        catch ( GLib.Error error )
	        { GeneralFunctions.LogIt("ERROR: Can't retrieve known filesystems : %s\n".printf(error.message) ); }
	    }

        private void AddMountPath( string uuid,  string MountPath )
        {
            foreach ( HardDisk hd in this.HardDisks )
            {
                foreach ( PartitionInfo pi in hd )
                {
                    if ( pi.UUID == uuid )
                    {
                        pi.IsMounted = true;
                        pi.MountPoint = MountPath; 
                    }
                }
            }
        }

	    private Gdu.Drive GetDriveFromDeviceName( string DeviceName )
	    {
	        Gdu.Device dev = _drivepool.get_by_device_file(DeviceName);
	        Gdu.Drive drv = (Gdu.Drive)_drivepool.get_drive_by_device(dev);
	        return drv;	        
	    }

//-------------------------------------------------------------------------
// Partitioning Methods
//-------------------------------------------------------------------------
		public bool CreatePartitionA( InstallPartition ip, int pindex, int eindex, InstallHardDisk ihd, bool primary )
		{
            string flags;
            string parttype;
            Gdu.Device dev;
            string dpidevice;
            string upidevice;
			this._currentPIdx = pindex;
			this._currentEIdx = eindex;
			this._currentIDH = ihd;

			GeneralFunctions.LogIt("\n\nCreate Partition Process Start on %s\n".printf(ihd.DeviceName) );

            try
            {
	            HardDisk hd = this.GetHDBySerial( ihd.SerialNumber );

	            if ( hd != null )
	            {
		            if ( this.UnMountRequired( ip, hd, out upidevice ) && primary )
		            {
			            dev = this._drivepool.get_by_device_file( upidevice );
						GeneralFunctions.LogIt("UNMOUNTING DEVICE %s\n".printf(upidevice) );

				        // unmount the device
			        	dev.op_filesystem_unmount( UnMountCallBackEvt );
			        	upidevice = "";
			        	dev = null;
			        	hd = null;
			        	return false;
		            }
					else if ( this.DeleteRequired( ip, ref hd, out dpidevice ) && primary )
					{
						dev = this._drivepool.get_by_device_file( dpidevice );
						GeneralFunctions.LogIt("DELETING DEVICE %s\n".printf(dpidevice) );

				    	// Delete the partition - callback fires event
				    	dev.op_partition_delete( PartitionDeletedCallBack );

						dev = null;
			    	}
					else
					{
						bool ownit = this.Ownership( ip.Type.to_string() );

						// check if the partition needs formatting
						if ( ip.Format && !ip.NewPartition )
						{
							GeneralFunctions.LogIt("USING EXISTING PARTITION DATA, FORMATTING %s\n".printf( ip.Device ) );

							dev = this._drivepool.get_by_device_file(ip.Device);
							GeneralFunctions.LogIt("FORMATTING PARTITION ON DEVICE %s TO %s\n".printf(dev.get_device_file(), ip.TypeID ) );

							dev.op_filesystem_create ( ip.TypeID, ip.Label, "", ownit, this.FileSystemCreateCallBack );
							dev = null;
						}
						else if ( ip.NewPartition )
						{
							dev = this._drivepool.get_by_device_file(hd.Device);
							GeneralFunctions.LogIt("CREATING PARTITION ON DEVICE %s : Size = %s  : Start = %s : End = %s : Type = %s TypeID = %s\n".printf( dev.get_device_file(), 
													ip.ByteSize.to_string(), ip.Start.to_string(), (ip.Start + ip.ByteSize).to_string(), ip.Type.to_string(), ip.TypeID ) );

							// get the partition type as mbr
							if ( ip.TypeID != "0x05" && ip.TypeID != "swap" )
	                		{ 
	                			parttype = Gdu.util_get_default_part_type_for_scheme_and_fstype("mbr", ip.TypeID, ip.ByteSize); 
	                			dev.op_partition_create(ip.Start, ip.ByteSize, parttype, null, out flags, ip.TypeID, ip.Label, "", ownit, CreatePartitionCallBack);
	                		}
	                		else if ( ip.TypeID == "0x05" )
	                		{ dev.op_partition_create(ip.Start, ip.ByteSize, ip.TypeID, null, out flags, null, ip.Label, "", ownit, CreatePartitionCallBack ); }
	                		else 
	                		{ dev.op_partition_create(ip.Start, ip.ByteSize, "0x82", null, out flags, ip.TypeID, ip.Label, "", false, CreatePartitionCallBack ); }
	                		dev = null;
                		}
                		else
                		{ this.DeviceActionComplete("create", this._currentPIdx, this._currentEIdx, this._currentIDH); }
                	}
	            }
	            dev = null;
	            hd = null;
            }
            catch ( GLib.Error error)
            { GeneralFunctions.LogIt("ERROR ON CREATE = %s\n".printf(error.message ) ); }
            return true;
		}

		private bool Ownership(string parttype)
		{
			GeneralFunctions.LogIt("OWNERSHIP PARTTYPE = %s\n".printf(parttype) );
			bool ret = false;

			switch ( parttype.down() )
			{
				case "ntfs":
				case "fat":
				case "swap":
					ret = false;
					break;
				default:
					ret = true;
					break;
			}
			return ret;
		}

		// check if the partition is mounted
        private bool UnMountRequired(InstallPartition ip, HardDisk hd, out string pidevice)
        {
	    	bool ret = false;
	    	GeneralFunctions.LogIt("CHECKING IF UMOUNT REQUIRED\n");
	    	foreach ( PartitionInfo pi in hd )
	    	{
		    	Gdu.Device d = this._drivepool.get_by_device_file(pi.Device);

		    	if ( pi.PartitionType.down() != "unallocated" && d.is_mounted() )
		    	{
					GeneralFunctions.LogIt("MOUNT CHECK - %s - Device Mounted = %s\n".printf( d.get_device_file(), d.is_mounted().to_string() ) );
			    	pidevice = pi.Device;
			    	ret = true;
			    	d = null;
			    	break;
		    	}
		    	//d = null;
			}

			if ( ret == true )
			{ GeneralFunctions.LogIt("UMOUNT REQUIRED\n"); }
			else
			{ GeneralFunctions.LogIt("UMOUNT NOT REQUIRED\n"); }

			return ret;
        }
                        
        // checks if an existing partition needs to be deleted ( overlaps etc )
        private bool DeleteRequired(InstallPartition ip, ref HardDisk hd, out string pidevice)
        {
	        bool ret = false;

			GeneralFunctions.LogIt("CHECKING IF DELETE REQUIRED\n");

			foreach ( PartitionInfo pi in hd )
			{
		    	// Check the overlap on other partitions, check if the size is the same and format flag set
		    	// this EXCLUDES partition from modification - FALSE = Modify Partition
				if ( pi.EndSector <= ip.Start || pi.StartSector >= ip.End || pi.PartitionType.down() == "unallocated" 
					  || ( !ip.Format && !ip.NewPartition ) || ( !ip.NewPartition && ip.Use ) )
		    	{ 
			    	pidevice = "";
		    		ret =  false; 
		    		continue;
				}
			    else
		    	{
					hd.RemovePartition( pi );  // remove current partition, a refresh of current devices is run on partitioner completion.
			    	pidevice = pi.Device;
			    	ret = true;
			    	break; 
				}
			}

	        if ( ret )
	        { GeneralFunctions.LogIt("DELETE REQUIRED\n"); }
	        else
	        { GeneralFunctions.LogIt("DELETE NOT REQUIRED\n"); }
	        
	        return ret; 
        }


	    public bool FormatPartition(string DeviceName, string FSType)
	    {
	        Gdu.Device dev = this._drivepool.get_by_device_file(DeviceName);
	        return true;
	    }


		public FilesystemType GetFileSystemTypeFromString( string val )
		{
			foreach ( FilesystemType fs in this._fsTypes )
			{
				if ( fs.Name == val )
				{ return fs; }
			}
			return null;
		}
//-------------------------------------------------------------------------
// Events for devices
//-------------------------------------------------------------------------

	    public void OnDeviceConnected(Gdu.Device dev)
	    { 
	        GeneralFunctions.LogIt("Device Connected %s\n".printf( dev.get_device_file() ) );
	    }
	    
	    public void OnDeviceRemoved(Gdu.Device dev)
	    { 
		    if ( ! this.PartitionerRunning )
		    {
				GeneralFunctions.LogIt("Device Removed %s\n".printf( dev.get_device_file() ) );
				this.RefreshDisks();
			}
	    }
	    
	    public void OnDeviceChanged(Gdu.Device dev)
	    { 
		    if ( ! this.PartitionerRunning )
		    {
	       		GeneralFunctions.LogIt("Device Changed %s\n".printf( dev.get_device_file() ) );
	       		this.RefreshDisks();
       		}
	    }


//-------------------------------------------------------------------------
// Call backs for GDU methods
//-------------------------------------------------------------------------

        // passed to mount function
        private void UnMountCallBack(Gdu.Device d, GLib.Error error)
        {
            if ( error == null ) 
            { this.DriveUnMounted (); }
            else
            { this.DiskManagerError(error); }
        }
        
        private void UnMountCallBackEvt(Gdu.Device d, GLib.Error error)
        {
	        GeneralFunctions.LogIt("CALLBACK CALLED UNMOUNT %s\n".printf( d.get_device_file() ) );
	        
	     	if ( error == null )
	     	{ this.DeviceActionComplete("unmount", this._currentPIdx, this._currentEIdx, this._currentIDH); 
	     	}
	     	else
	     	{ GeneralFunctions.LogIt("Error UNMOUNTING device %s\n".printf( d.get_device_file() ) ); }   
        }

		// passed to format function
		private void FileSystemCreateCallBack( Gdu.Device d, GLib.Error error)
		{
			if ( error == null )
			{
				GeneralFunctions.LogIt("FILESYSTEM CREATED %s\n".printf( d.get_device_file() ) );
				this.DeviceActionComplete("create", this._currentPIdx, this._currentEIdx, this._currentIDH); 
			}
			else
			{ GeneralFunctions.LogIt("ERROR CREATING FILESYSTEM %s\n".printf( error.message) ); }
		}
		
		// passed to Partition Schema Create
		private void PartitionTableCreateCallBack(Gdu.Device d, GLib.Error error)
		{
			
		}
		
        // passed to mount function
        private void MountCallBack(Gdu.Device d, string mountpoint, GLib.Error error)
        {
            if ( error == null ) 
            { 
            	GeneralFunctions.LogIt("DEVICE MOUNTED %s\n".printf(d.get_device_file() ) );
            	this.AddMountPath( d.id_get_uuid(), mountpoint);
            	this.DriveMounted( mountpoint );
            }
            else
            { 
                if ( error.message.down().contains("is mounted") )
                {
                    this.AddMountPath ( d.id_get_uuid(), d.get_mount_path() );
                    this.DriveMounted ( d.get_mount_path() );
                }
                else
                { 
	                GeneralFunctions.LogIt("MOUNT CALLBACK ERROR: ");
                	this.DiskManagerError(error); 
                } 
            }
            this._MountComplete = true;
        }

        // Passed to Delete Partition Function
        private void PartitionDeletedCallBack(Gdu.Device d,  GLib.Error error)
        {
            if ( error == null )
            {
	            GeneralFunctions.LogIt("PARTITION DELETED\n");
            	this.DeviceActionComplete("delete", this._currentPIdx, this._currentEIdx, this._currentIDH);
            }
            else
            { GeneralFunctions.LogIt("ERROR DELETING DEVICE %s\n".printf(error.message)); }
        }
        
        // passed to partition create function
        public void CreatePartitionCallBack(Gdu.Device d, string objectPath, GLib.Error error)
        {
            if ( error == null )
            {
	            string cmd = "sfdisk -R %s".printf( d.get_device_file() ); 
	            GeneralFunctions.LogIt("PARTITION CREATED %s\n".printf( d.get_device_file() ));
	            GLib.Process.spawn_command_line_sync (cmd);
            	this.DeviceActionComplete( "create", this._currentPIdx, this._currentEIdx, this._currentIDH );
            }
            else
            { GeneralFunctions.LogIt("CREATE PARTITION ERROR %s\n".printf( error.message )); }
        }
	}


//-------------------------------------------------------------------------
// Class to hold drive information, collection of partitions
//-------------------------------------------------------------------------
    
    public class HardDisk : Object, Iterable<PartitionInfo>
    {
	    public HardDisk()
	    {  }

		public string 		Model 				{ get; set; }
		public string 		Firmware 			{ get; set; }
        public string 		Location 			{ get; set; }
        public bool 		WriteCacheEnabled 	{ get; set; }
        public uint64 		Capacity 			{ get; set; }
        public string 		CapacityDescription { get; set; }
        public string 		Partitioning 		{ get; set; }
        public string 		SerialNumber 		{ get; set; }
        public string 		Device 				{ get; set; }
        public string 		Connection 			{ get; set; }
        public string 		SmartStatus 		{ get; set; }
        public int 		PartitionCount 		{ get { return GetPartitionCount(); } }
        public bool 		IsOptical 			{ get; set; }
        public string 		PreviousOS 			{ get; set; }
		public uint64		StartSector			{ get { return this.GetFirstStartSector (); } }
		
        protected Gee.ArrayList<PartitionInfo> _partitions = new Gee.ArrayList<PartitionInfo>();

        private int GetPartitionCount()
        {
            int i = 0;
            foreach ( PartitionInfo pi in this._partitions )
            {
                if ( ! pi.PartitionType.contains("Extended") )
                { i++; }
            }
            return i;
        }

        public bool HasHomePartition
        {
            get
            {
                bool bHasHome = false;

                foreach ( PartitionInfo pi in this )
                {
                    if ( pi.MountPoint.contains("home") )
                    {
                        bHasHome = true;
                        break;
                    } 
                }
                return bHasHome;
            }
        }

		private uint64 GetFirstStartSector ()
		{
			PartitionInfo p = null;
			
			foreach ( PartitionInfo pi in this )
			{
				foreach ( PartitionInfo ip in this )
				{
					if ( pi.StartSector < ip.StartSector )
					{ p = pi; }
				}
			}

			if ( p == null )
			{ return ( this._partitions.size == 0 ) ? 0 : this._partitions[0].StartSector; }
			else
			{ return p.StartSector; }
		}
		
		public void RemovePartition( PartitionInfo pi )
		{ this._partitions.remove(pi); }

        public void AddPartition( PartitionInfo pi )
        { this._partitions.add(pi); }

        public void SortPartitions()
        { this._partitions.sort(); }

        public Type element_type 
        {  get { return typeof (PartitionInfo); } }

        public Gee.Iterator<PartitionInfo> iterator ()
        { return _partitions.iterator(); }
	}


//-------------------------------------------------------------------------
// Class to hold partition information
//-------------------------------------------------------------------------
	
	public class PartitionInfo : GLib.Object, Comparable<PartitionInfo>, Iterable<PartitionInfo>
	{
        public string 		Usage 					{ get; set; default=""; }
        public string 		PartitionType 			{ get; set; default=""; }
        public string 		OSType 					{ get; set; default=""; }
        public string 		OSTypeID 				{ get; set; default=""; }
        public string 		Label 					{ get; set; default=""; }
        public string 		Device 					{ get; set; default=""; }
        public string 		PartitionLabel 			{ get; set; default=""; }
        public string 		CapacityDescription 	{ get; set; default=""; }
        public uint64 		Capacity 				{ get; set; }
        public string 		AvailableDescription 	{ get; set; default=""; }
        public uint64 		AvailableCapacity 		{ get; set; }
        public string 		MountPoint 				{ get; set; default=""; }
        public string 		PartitionFlags 			{ get; set; default=""; }
        public int 		PartitionNumber 		{ get; set; }
        public uint64 		StartSector 			{ get; set; }
        public uint64 		EndSector 				{ get; set; }
        public string 		UUID 					{ get; set; default=""; }
        public string 		FSTabMountPoint 		{ get; set; default=""; }
        public bool 		IsMounted 				{ get; set; }
		public string 		ParentDevice 			{ get; set; }

		private Gee.ArrayList<PartitionInfo> _lstPartitions = new Gee.ArrayList<PartitionInfo>();
	
        public int compare_to(PartitionInfo comp)
        {
            if (this.StartSector < comp.StartSector) 
            { return -1; }
            
            if (this.StartSector > comp.StartSector) 
            { return 1; }
            
            return 0;            
        }

		// add a partition to extended, sort when adding
		public void AddPartition(PartitionInfo pi)
		{ 
			this._lstPartitions.add(pi); 
			this._lstPartitions.sort();
		}
		
		public void RemovePartition(PartitionInfo pi)
		{ this._lstPartitions.remove(pi); }

        public Type element_type 
        {  get { return typeof (PartitionInfo); } }

        public Gee.Iterator<PartitionInfo> iterator () 
        { return _lstPartitions.iterator(); }
        
        public void SortPartitions()
        { this._lstPartitions.sort(); }
	}
	
	
//-------------------------------------------------------------------------
// Class to define System disk format type
//-------------------------------------------------------------------------
	
	public class FilesystemType : GLib.Object
	{
	    public string ID { get; set; }
	    public string Name { get; set; }
	    public bool CanCreate { get; set; }
	    public bool CanMount { get; set; }
	    public int MaxLabelLen { get; set; }
	    public bool SupportUnixOwner { get; set; }
	    public bool AllowLabelRename { get; set; }
	    public bool SupportFsck { get; set; }
	    public bool SupportResizeEnlarge { get; set; }
	    public bool SupportResizeShrink { get; set; }
	    public bool SupportEnlargeOnline { get; set; }
	    public bool SupportShrinkOnline { get; set; }
	    
	    public FilesystemType()
	    { }
	    
	    public string to_string()
	    {
	        string ret = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n".printf(
	        this.ID, this.Name, this.CanCreate.to_string(), this.CanMount.to_string(),
	        this.MaxLabelLen.to_string(), this.SupportUnixOwner.to_string(), this.AllowLabelRename.to_string(),
	        this.SupportFsck.to_string(), this.SupportResizeEnlarge.to_string(), 
	        this.SupportResizeShrink.to_string(), this.SupportEnlargeOnline.to_string(),
	        this.SupportShrinkOnline.to_string() );
	        //stdout.printf(ret);
	        return ret;
	    }
	}


//-------------------------------------------------------------------------
// Collection class for mount points
//-------------------------------------------------------------------------
	
	public class MountPoints : Object, Iterable<MountPoint>
	{
	    protected Gee.ArrayList<MountPoint> _MountPoints = new Gee.ArrayList<MountPoint>();
	    
	    public void AddMountPointValues(string key, string mountpoint, int order)
	    {
	        MountPoint mp = new MountPoint();
	        mp.Key = key;
	        mp.Path = mountpoint;
	        mp.DisplayOrder = order;
	        this._MountPoints.add(mp);
	    }
	    
        public void AddMountPoint( MountPoint mp )
        { this._MountPoints.add(mp); }

        public void Sort()
        { this._MountPoints.sort(); }

        public Type element_type 
        {  get { return typeof (MountPoint); } }

        public Gee.Iterator<MountPoint> iterator () 
        { return _MountPoints.iterator(); }	
	}


//-------------------------------------------------------------------------
// Class to hold system mount point
//-------------------------------------------------------------------------
	
	public class MountPoint : Object, Comparable<MountPoint>
	{
	    public string Key { get; set; }
	    public string Path { get; set; }
	    public int DisplayOrder { get; set; }

	    public MountPoint()
	    { }

        public int compare_to(MountPoint comp)
        {
            if (this.DisplayOrder < comp.DisplayOrder) 
            { return -1; }

            if (this.DisplayOrder > comp.DisplayOrder) 
            { return 1; }

            return 0;            
        }	    
	}

//-------------------------------------------------------------------------
// Classes to hold the default auto generated schema layout
// This is based on total disk size to create the percentages
// for each partition, taking into account total disk size and 
// total ram size for the swap partition
//-------------------------------------------------------------------------	

	public class DefaultSchema : Object, Iterable<DefaultPartitionData> 
	{
	    Gee.ArrayList<DefaultPartitionData> _dpd = new Gee.ArrayList<DefaultPartitionData>();
	    
	    public void AddPartitionData(DefaultPartitionData dpd)
	    { this._dpd.add(dpd); }
	    
	    public Type element_type
	    { get { return typeof(DefaultPartitionData); } }
	    
	    public Gee.Iterator<DefaultPartitionData> iterator ()
	    { return this._dpd.iterator(); }
	}
	
	public class DefaultPartitionData
	{
	    string MountPoint { get; set; }
	    string Label { get; set; }
	    int Percentage { get; set; }
	}
}