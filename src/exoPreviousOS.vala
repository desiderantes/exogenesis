using Gee;
using GLib;

namespace Exogenesis
{
    public class PreviousOS
    {
        private HashMap<string, string> FSTab = new HashMap<string, string>(str_hash, str_equal);
        private Gee.ArrayList<UserDetail> _existingUsers = new Gee.ArrayList<UserDetail>();

        public Gee.ArrayList<UserDetail> ExistingUsers { get { return this._existingUsers; } }
        public int ExistingUsersCount { get { return (int)this._existingUsers.size; } }

        public void GetFSTabMountPoints()
        {
            // loop throught the hardisks found
            foreach ( HardDisk hd in gHDManager.HardDisks )
            {
                // loop through the partitions on each disk
                foreach ( PartitionInfo pi in hd )
                {
                    if ( pi.UUID != null && ! this.InFSTab( pi.UUID )  ) 
                    {
                        // read fstab file - if exists
                        string fstabfile = "%s/etc/fstab".printf( pi.MountPoint );
                        GLib.File file = GLib.File.new_for_path(fstabfile);

                        // check if root part, get fstab entry
                        if ( file.query_exists(null) )
                        {
                            // read fstab and process
                            SetFSTabMountPath(fstabfile);
                        }

                        // whilst we're at it, get the lsb release data (if any)
                        string lsbfile = "%s/etc/lsb-release".printf( pi.MountPoint );
                        file = GLib.File.new_for_path( lsbfile );

						// check if file exists if not check secondary location from log
						if ( ! file.query_exists(null) )
						{
							lsbfile = "%s/var/log/installer/lsb-release".printf( pi.MountPoint );
							file = GLib.File.new_for_path( lsbfile );
						}

                        // check the file
                        if ( file.query_exists( null ) )
                        { this.SetLSBName(lsbfile, ref hd); }

                        // and another thing, get the existing users and groups too while you're at it
                        string usrpwd = "%s/etc/passwd".printf( pi.MountPoint );
                        file = GLib.File.new_for_path( usrpwd );

                        if ( file.query_exists ( null ) )
                        { this.GetExistingUsers ( usrpwd ); }
                    }
                }
            }
        }

        // if HD contains a file system and is root partition
        // get the original mount path for the device uuid
        private void SetFSTabMountPath(string fstabfilepath)
        {
            // read the file
            string fstabfile = gGenFunc.ReadTextFile(fstabfilepath);
            
            string[] lines;

            // check the file size
            if ( fstabfile.length > 0 )
            {
                // split file to array
                lines = fstabfile.split("\n");

                // loop through each line
                foreach ( string line in lines )
                {
                    // ignore comments
                    if ( ! line.has_prefix("#") )
                    {
                        // split the line to fstab line values
                        string[] values = line.split(" ");

                        // get the uuid from the file
                        string uuid = values[0];

                        // is this the UUID line?
                        if ( uuid.contains("UUID") )
                        {
                            string[] uuidval =  uuid.split("=");

                            // add entries to FSTab
                            if ( ! InFSTab(uuidval[1]) ) 
                            { this.FSTab.set( uuidval[1], values[1]); }
                            
                            // set the HD values
                            foreach ( HardDisk hd in gHDManager.HardDisks )
                            {
                                foreach ( PartitionInfo pi in hd )
                                {
                                    if ( pi.UUID == uuidval[1] )
                                    { pi.FSTabMountPoint = values[1]; }
                                }
                            }
                        }
                    }
                }
            }
        }        
        
        // check if the entry exists in FSTab map
        private bool InFSTab(string uuid)
        {
            bool bFound = false;
            
            foreach ( string key in this.FSTab.keys )
            {
                if ( key == uuid )
                { 
                    bFound = true;
                    break;
                }
            } 
            return bFound;
        }
        
        // if there is an existing lsb file, get it and display info
        // appending to HD name
        private void SetLSBName(string lsbfilepath, ref HardDisk hd)
        {
            string lsbdata = gGenFunc.ReadTextFile(lsbfilepath);
            string[] lines;

            if ( lsbdata.length > 0 )
            {
                lines = lsbdata.split("\n");
                string os = lines[0].split("=")[1];
                string ver = lines[1].split("=")[1];
                hd.PreviousOS = "%s %s".printf(os, ver);
            }
        }

        // check if there are any existing users, get the info
        private void GetExistingUsers( string passwdfile )
        { 
            string filetext = gGenFunc.ReadTextFile(passwdfile);
           
            string[] lines;

            if ( filetext.length > 0 )
            {
                lines = filetext.split("\n");
    
                // loop through the users
                foreach ( string userdetail in lines )
                {
                    // check the line length, ignore blanks
                    if ( userdetail.length > 0 )
                    {
                        string[] userdata = userdetail.split(":");

                        if ( int.parse( userdata[2].to_string() )  > 999 && 
                            ! this.UserExists( int.parse(userdata[2].to_string() ) ) )
                        {
                            UserDetail user = new UserDetail();

                            string[] detail = userdata[4].split(",");

                            user.Username = userdata[0];
                            user.Type = (char)userdata[1];
                            user.UserId = int.parse( userdata[2].to_string() );
                            user.GroupId = int.parse( userdata[3].to_string() );

                            if ( detail.length > 0 )
                            { user.Fullname = detail[0]; }

                            if ( detail.length > 1 )
                            { user.OfficeLocation = detail[1]; }

                            if ( detail.length > 2)
                            { user.WorkPhone = detail[2]; }

                            if ( detail.length > 3 )
                            { user.HomePhone = detail[3]; }

                            user.HomeFolder = userdata[5];
                            user.Shell = userdata[6];

                            this._existingUsers.add(user);
                        }
                    }
                }
            }
        }
        
        private bool UserExists(int uid)
        {
            bool ret = false;

            foreach ( UserDetail user in this._existingUsers )
            {
                if ( user.UserId == uid )
                { 
                    ret = true;
                    break;
                }
            }
            return ret;
        }        
    }
}