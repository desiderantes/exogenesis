/*

    To install the system needs to know
    
    Details of the main user
    
    Location for install
    
        - disk and partition schema
        
    Language and location
    
    Timezone

*/

using Gdk;
using GLib;
using Gee;

namespace Exogenesis
{
    public class InstallData : Object, Iterable<InstallHardDisk>
    {
        // Hard Disks to be added
        private Gee.ArrayList<InstallHardDisk> _installTargets = new Gee.ArrayList<InstallHardDisk>();

        // users and groupd to be added
        private InstallUsers _UserData = new InstallUsers(); 
        private InstallGroups _groups = new InstallGroups();

        // timezone info
        public string TimeZone 					{ get; set; }

        // Language Setting
        public string Language 					{ get; set; }

        // Keyboard Settings (For GConf)
        public string KeyboardLayout 				{ get; set; }
        public string KeyboardVariant 				{ get; set; }

        public void AddUser(UserDetail user)
        { this._UserData.AddUser(user); }

		public UserDetail GetMainUser()
		{
			foreach ( UserDetail ud in this._UserData )
			{
				if ( ud.MainAccount )
				{ return ud; }
			}
			return null;
		}

        public void AddGroup(Group group)
        { this._groups.AddGroup(group); }

        // Timezone setting
        public string SelectedTimeZone 			{ get; set; }
        public bool ManualTime 					{ get; set; default=false; } 

        // Grub Target device
        public string GrubTarget 					{ get; set; }

        // Add install Disks
        public void AddInstallDisk(InstallHardDisk hd)
        { this._installTargets.add(hd); }

        // clear all harddisks
        public void ClearInstallDisks()
        { this._installTargets.clear(); }

        // get the hard disk count
        public int HardDiskCount
        { get { return this._installTargets.size; }}

		// get the harddisk at index
		public InstallHardDisk GetTargetHD(int index)
		{ return this._installTargets.get(index); }

        // interface implementation for iterable
        public Type element_type 
        {  get { return typeof (InstallHardDisk); } }

        public Gee.Iterator<InstallHardDisk> iterator () 
        { return this._installTargets.iterator(); }
    }

    public class Installer
    {
        // signals/events
        public signal void InstallStarted();
        public signal void UserCreated(UserDetail user);
        public signal void GroupCreated(Group group);
        public signal void LanguageSet();
        public signal void TimezoneSet();
        public signal void PartitionsCreated();
        public signal void FileCopied(string file);
        public signal void NextSlide(string slidename);
        public signal void ProgressUpdate(int percentcomplete, string currentaction);
        public signal void InstallerError( string Error );
        public signal void InstallComplete();

        private InstallHardDisk _currentiHD;

		// timer info
		private const int MISC_TICKS = 10;
		private const int FORMAT_TICKS = 1000;
		private const int COPY_TICKS = 10000;

		private int copy_ticks;
		private int adjust_ticks;
		private int system_config_ticks;
		private int add_user_ticks;
		private int grub_ticks;
		private int total_ticks;

		private bool _PartitionError = false;

		private string mountpoint = "/media/target";

		public Installer()
		{
			// connect the required events 
			gHDManager.DeviceActionComplete.connect ( this.DeviceAction ); 
			gHDManager.DiskManagerError.connect ( this.OnDiskManagerError );
		}

        // ---------------------------------------------------------------------
        // Following methods are applied on user creation for new system
        // ---------------------------------------------------------------------
        public void CreatePartitionsStart(InstallHardDisk iHD)
        {
	        this._currentiHD = iHD;
			gHDManager.PartitionerRunning = true;

			// get the first installpartition and start the ball rolling
			if ( iHD.PartitionCount > 0 )
			{
				GeneralFunctions.LogIt("Partitions to create = %s\n".printf(iHD.PartitionCount.to_string()) );
				// get the first and fire away
				gHDManager.CreatePartitionA( iHD.GetPartition(0), 0, -1, iHD, true );
			}
        }

		// action = last action completed
		// curpindex = current primary partition index
		// cureindex - current extended partition index
		// InstallHardDisk = current HD target for partitions
		private void DeviceAction(string action, int curpindex, int cureindex, InstallHardDisk ihd)
		{
			GeneralFunctions.LogIt("DEVICE ACTION CALLBACK EVENT - ACTION = %s  Index = %s\n".printf(action, curpindex.to_string()));

			// check if the old partition was deleted or new partition created
			switch ( action.down() )
			{
				case "unmount":
					GeneralFunctions.LogIt("Partition UNMOUNTED, Proceed to NEXT STEP\n");
					gHDManager.CreatePartitionA( ihd.GetPartition(curpindex), curpindex, cureindex, ihd, true );
					break;

				case "delete":
					// create the partition
					GeneralFunctions.LogIt("Partition DELETED, Proceed to NEXT STEP\n");
					gHDManager.CreatePartitionA( ihd.GetPartition(curpindex), curpindex, cureindex, ihd, true );
					break;

				case "create":
					// move to next index
					GeneralFunctions.LogIt("Partition CREATED, Proceed to NEXT\n");

					// Check the extended partitions on last created partition
					if ( ihd.GetPartition(curpindex).ExtPartitionCount() > 0 && 
					     cureindex + 1 < ihd.GetPartition(curpindex).ExtPartitionCount() )
					{ 
						cureindex += 1;
						gHDManager.CreatePartitionA( ihd.GetPartition(curpindex).GetPartition(cureindex), curpindex, cureindex, ihd, false );
					}
					else
					{
						// last created partition has no extended, create the next one
						curpindex += 1;
					
						// check if the index + 1 breaks the array bounds
						if ( curpindex < ihd.PartitionCount )
						{ 	
							GeneralFunctions.LogIt("Partitions = %s\n".printf(ihd.PartitionCount.to_string()) );
							gHDManager.CreatePartitionA( ihd.GetPartition(curpindex), curpindex, cureindex, ihd, true ); 
						}
						else
						{ 
							// all complete, raise the event
							GeneralFunctions.LogIt("ALL PARTITIONS CREATED\n");

							// refresh the Hard disks to reflect changes
							gHDManager.PartitionerRunning = false;
						}
					}
					break;
			}
		}

		private bool CopyFiles()
		{
			return true;
		}

        public bool ValidInstallData()
        { return true; }

        public bool Install()
        { 
	        // create the partitions
	        this.CreatePartitionsStart(null);
	        
        	return true; 
        }

        public bool CreateUsers()
        { return true; }

        public bool CreateGroups()
        { return true; }

        public bool SaveConfigs()
        { return true; }

        public bool ApplyConfigs()
        { return true; }

        public bool CreateOS()
        { return true; }

		// Raise the error, stop the installer
        private void OnDiskManagerError( GLib.Error err )
        {
	        this._PartitionError = true;
	        string Error = "Partitioner Error Occurred \n%s".printf( err.message );
	        this.InstallerError(Error);
        }
    }

    // class names the device and contains a collection
    // of partition schema to be created
    public class InstallHardDisk : Object, Iterable<InstallPartition>
    {
        public string 	DeviceName 		{ get; set; }
		public string 	Model			{ get; set; }
        public string 	SerialNumber 	{ get; set; }
        public bool 	IsGrubTarget	{ get; set; }
		public uint64 	DriveSize		{ get; set; }
		public uint64 StartSector		{ get; set; }
		
        private Gee.ArrayList<InstallPartition> _partitions = new Gee.ArrayList<InstallPartition>(); 

        public InstallHardDisk()
        { }

		public uint64 AvailableSize()
		{
			uint64 size = this.DriveSize - StartSector;
			
			foreach ( InstallPartition p in this._partitions )
			{ 
				if ( p.Type.down().contains("extended") )
				{
					foreach ( InstallPartition i in p )
					{ size -= i.ByteSize; }
				}
				else
				{ size -= p.ByteSize; } 
			}
			return size;
		}
		
		public int PartitionCount
		{ get { return this._partitions.size; } }

		public int IndexOf(InstallPartition ip)
		{ return this._partitions.index_of(ip); }

		public InstallPartition GetPartition(int index)
		{ return this._partitions.get(index); }

        public void AddPartition( InstallPartition partition)
        { this._partitions.add(partition); }

         public Type element_type 
        {  get { return typeof (InstallPartition); } }

        public Gee.Iterator<InstallPartition> iterator () 
        { return this._partitions.iterator(); }  

        public void SortPartitions()
        { 
			this._partitions.sort();

			foreach ( InstallPartition p in this._partitions )
			{ p.SortPartitions(); }
		}

		public bool Remove( InstallPartition p )
		{
			int idx = this._partitions.index_of( p );

			if ( idx >= 0 )
			{ stdout.printf ( "REMOVING INDEX %s\n", idx.to_string() );
				this._partitions.remove_at( idx );
				return true;
			}
			else
			{ return false; }
		}
    }

    // class holds the partition types, formats and sizes    
    public class InstallPartition: GLib.Object, Comparable<InstallPartition>, Iterable<InstallPartition>
    {
        public uint64		ByteSize 		{ get; set; }
        public string   	DisplaySize 	{ get; set; }
        public bool     	Format 			{ get; set; }
        public bool     	Use 			{ get; set; }
        public bool		NewPartition 	{ get; set; }
        public string   	MountPoint 		{ get; set; }
        public string   	Type 			{ get; set; }
        public string   	TypeID 			{ get; set; }
        public string   	Label 			{ get; set; }
        public uint64 		Start 			{ get; set; }
        public uint64		End 			{ get; set; }
        public string   	Device 			{ get; set; }
		public string		ID 				{ get; set; }

		private Gee.ArrayList<InstallPartition> _lstPartitions = new Gee.ArrayList<InstallPartition>();

        public InstallPartition()
        { }

		public void AddInstallPartition(InstallPartition ip)
		{
			this._lstPartitions.add( ip );
		}

        public int compare_to(InstallPartition comp)
        {
            if (this.Start < comp.Start) 
            { return -1; }

            if (this.Start > comp.Start) 
            { return 1; }
            return 0;            
        }

		public InstallPartition GetPartition(int idx)
		{ return this._lstPartitions.get(idx); }

		public int ExtPartitionCount()
		{ return this._lstPartitions.size; }
		
         public Type element_type 
        {  get { return typeof (InstallPartition); } }

        public Gee.Iterator<InstallPartition> iterator () 
        { return this._lstPartitions.iterator(); }
        
        public void SortPartitions()
        { this._lstPartitions.sort(); }

		public bool Remove( InstallPartition p )
		{
			int idx = this._lstPartitions.index_of ( p );

			if ( idx >= 0 )
			{ stdout.printf ( "REMOVING INDEX %s\n", idx.to_string() );
				this._lstPartitions.remove_at ( idx );
				return true;
			}
			else
			{ return false; }
		}
    }


    //---------------------- USER DETAILS --------------------------------------
    public class InstallUsers : Object, Iterable<UserDetail>
    {
        public int Count { get { return this._Users.size; } }

        protected Gee.ArrayList<UserDetail> _Users = new Gee.ArrayList<UserDetail>();

        public InstallUsers () 
        { }

        public void AddUser( UserDetail user )
        { this._Users.add(user); }

        public void Sort()
        { this._Users.sort(); }
	
        public Type element_type 
        {  get { return typeof (UserDetail); } }

        public Gee.Iterator<UserDetail> iterator () 
        { return _Users.iterator(); }
    } 

    public class UserDetail : GLib.Object, Comparable<UserDetail>
    {
        public int UserId { get; set; }
        public int GroupId { get; set; }
        public string Username { get; set; }
        public string Fullname { get; set; }
        public string OfficeLocation { get; set; }
        public string WorkPhone { get; set; }
        public string HomePhone { get; set; }
        public string HomeFolder { get; set; }
        public string Shell { get; set; }
        public char Type { get; set; }
        public string Password { get; set; }
        public bool EncryptHome { get; set; }
        public bool AutoLogon { get; set; }
        public bool RequirePassword { get; set; }
		public bool MainAccount { get; set; }

        public int compare_to(UserDetail comp)
        {
            if (this.UserId < comp.UserId) 
            { return -1; }

            if (this.UserId > comp.UserId) 
            { return 1; }

            return 0;
        }           
    }

    public class InstallGroups : Object, Iterable<Group>
    {
        protected Gee.ArrayList<Group> _Groups = new Gee.ArrayList<Group>();

        public InstallGroups () 
        { }

        public void AddGroup( Group group )
        { this._Groups.add( group ); }

        public void Sort()
        { this._Groups.sort(); }

        public Type element_type 
        {  get { return typeof (Group); } }

        public Gee.Iterator<Group> iterator () 
        { return _Groups.iterator(); }   
    }

    public class Group : GLib.Object, Comparable<Group>
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public char Type { get; set; }

        private GLib.List<UserDetail> _Users = new GLib.List<UserDetail>();

        public void AddUser ( UserDetail user )
        { this._Users.append( user ); }

        public int compare_to(Group comp)
        {
            if (this.Name < comp.Name) 
            { return -1; }

            if (this.Name > comp.Name) 
            { return 1; }
            return 0;            
        }                
    }
}