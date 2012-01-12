using Gtk;
using GLib;
using Gdu;
using Gtk;
namespace Exogenesis
{
    public class FPartitioner : Gtk.Layout
    {
        private enum PartitionCols
        {
            MountPoint = 0,
            DisplaySize,
            FormatType,
            Label,
            HardDisk,
            FormatFlag,
            UseFlag,
            RemoveIcon,
            ByteSize,
            FSTypeID,
            Device,
            PartitionID,
            NewPartition
        }
    
        private enum TreeCols
        {
            MountPoint = 0,
            DisplaySize,
            FormatType,
            FormatFlag,
            UseFlag,
            Label,
            Remove
        }
    
        // Controls from Glade
        Gtk.Fixed fxdPartitioner;
        Gtk.ComboBox cboHD;
        Gtk.TreeView tvwPartitions;
        Gtk.VBox vboxHD;
        Gtk.Button btnCreatePart;
        Gtk.RadioButton rdoBefore;
        Gtk.RadioButton rdoAfter;
        Gtk.Button btnApply;
        Gtk.Button btnCancel;

        SegmentedBar segbarHD;
        
        // Treestore columns:   0 = Mount Point : 1 = Partition Display Size : 2 = Partition Format Type 
        //                      3 = Partition Label : 4 = HardDisk Object : 5 = format partition flag
        //                      6 = Use Partition Flag : 7 = DELETE :  8 = Paritition byte size : 9 = Partition Type ID
        //						10 = DeviceName : 11 = Partition ID : 12 = New Partition Indicator
        private Gtk.TreeStore _lstPartitions = new Gtk.TreeStore ( 13, 	typeof(string), typeof(string), typeof(string), 
        																typeof(string), typeof(HardDisk), typeof(bool), 
                                                               			typeof(bool), typeof(string), typeof(uint64), 
                                                               			typeof(string), typeof(string), typeof(string),
                                                               			typeof(bool) );


        private ListStore _lstDisks = new ListStore( 2, typeof(string), typeof(HardDisk) );

        // Constructor         
        public FPartitioner(HardDisk selectedHD)
        {
            this.Build();
            this.GetDiskInfo();
			// select the current HD
			this.SetSelectedHD(selectedHD);             
            this.add( fxdPartitioner );
        }

        // assign controls from glade, setup initial form
        private void Build()
        {
	        try
	        {
	            // get the glade layouts/controls
	            Gtk.Builder builder = new Gtk.Builder();
	            builder.add_from_file( UIPath );

	            this.fxdPartitioner = ( Gtk.Fixed ) builder.get_object("fxdPartitioner");
	            this.vboxHD = ( Gtk.VBox ) builder.get_object("vboxHDP");
	            this.cboHD = ( Gtk.ComboBox ) builder.get_object("cboHDPDisks");
	            this.tvwPartitions = ( Gtk.TreeView ) builder.get_object("tvwHDPPartition");
	            this.btnCreatePart = ( Gtk.Button ) builder.get_object("btnHDPCreate");
	            this.btnCreatePart.sensitive = false;
	            this.btnApply = ( Gtk.Button ) builder.get_object("btnHDPApply");
	            this.btnCancel = ( Gtk.Button ) builder.get_object("btnHDPCancel");
	            this.rdoBefore = ( Gtk.RadioButton) builder.get_object("rdoHDPBefore");
	            this.rdoAfter = ( Gtk.RadioButton) builder.get_object("rdoHDPAfter");

	            // wire the events
	            this.btnCreatePart.clicked.connect ( this.OnBtnCreatePartition_Click );
	            this.btnApply.clicked.connect ( this.OnBtnApply_Click );
	            this.btnCancel.clicked.connect ( this.OnBtnCancel_Click );
	            this.cboHD.changed.connect ( this.OnCboHD_Changed );
	            this.rdoBefore.clicked.connect ( this.OnRdoBefore_Click );
	            this.rdoAfter.clicked.connect ( this.OnRdoAfter_Click );
	            this.tvwPartitions.button_release_event.connect ( this.TvwPartitions_RowClick );

	            // create the segbar for HD
	            this.segbarHD = new SegmentedBar();

	            this.segbarHD.BarHeight = 20; 
	            this.segbarHD.HorizontalPadding = segbarHD.BarHeight / 2;
	            this.segbarHD.ShowReflection = true;
	            this.vboxHD.pack_start (segbarHD, false, false, 0);
	            this.vboxHD.show_all ();

	            // set up HD combo
	            this.cboHD.set_model(this._lstDisks);
	            CellRendererText cellHD = new CellRendererText();
	            this.cboHD.pack_start(cellHD, true);
	            this.cboHD.add_attribute(cellHD, "text", 0);

	            // set the size of layout to size of fixed
	            this.width_request = this.fxdPartitioner.width_request;
	            this.height_request = this.fxdPartitioner.height_request;

				this.SetTreeColumns();
	            this.SetColumnWidths();

	            // show it all :-)
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

        private void SetTreeColumns()
        {
            // create the toggle renderer, attaching the event for click
            Gtk.CellRendererToggle togCellF = new Gtk.CellRendererToggle();
            togCellF.toggled.connect 
            (
                (toggle, path) => 
                {
                    var tree_path = new TreePath.from_string (path);
                    TreeIter iter;
                    _lstPartitions.get_iter (out iter, tree_path);
                    _lstPartitions.set (iter, this.PartitionCols.FormatFlag, !toggle.active);
                }
            );            

            // create the toggle renderer, attaching the event for click
            Gtk.CellRendererToggle togCellU = new Gtk.CellRendererToggle();
            togCellU.toggled.connect 
            (
                (toggle, path) => 
                {
                    var tree_path = new TreePath.from_string (path);
                    TreeIter iter;
                    _lstPartitions.get_iter (out iter, tree_path);
                    _lstPartitions.set (iter, this.PartitionCols.UseFlag, !toggle.active);
                }
            );

            CellRendererButton cellButtonDel = new CellRendererButton();
            cellButtonDel.clicked.connect( this.OnCellDelClicked );

            // Set up the treeview
            this.tvwPartitions.insert_column_with_attributes (-1, "Mount Point", new CellRendererText (), "text", this.PartitionCols.MountPoint, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Size", new CellRendererText (), "text", this.PartitionCols.DisplaySize, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Type", new CellRendererText (), "text", this.PartitionCols.FormatType, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Format", togCellF, "active", this.PartitionCols.FormatFlag, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Use", togCellU, "active", this.PartitionCols.UseFlag, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Label", new CellRendererText (), "text", this.PartitionCols.Label, null);
            this.tvwPartitions.insert_column_with_attributes (-1, "Delete", cellButtonDel, "stockicon",  this.PartitionCols.RemoveIcon, null);

            this.tvwPartitions.set_model(this._lstPartitions);
        }

        private void SetColumnWidths()
        {
            int w = (int)Math.round( this.tvwPartitions.parent.width_request / 100 );

            this.tvwPartitions.get_column(this.TreeCols.MountPoint).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.MountPoint).fixed_width = w * 25;

            this.tvwPartitions.get_column(this.TreeCols.DisplaySize).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.DisplaySize).fixed_width = w * 10;

            this.tvwPartitions.get_column(this.TreeCols.FormatType).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.FormatType).fixed_width = w * 20;

            this.tvwPartitions.get_column(this.TreeCols.FormatFlag).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.FormatFlag).fixed_width = w * 10;
            
            this.tvwPartitions.get_column(this.TreeCols.UseFlag).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.UseFlag).fixed_width = w * 10;

            this.tvwPartitions.get_column(this.TreeCols.Label).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.Label).fixed_width = w * 25;

            this.tvwPartitions.get_column(this.TreeCols.Remove).set_sizing(TreeViewColumnSizing.FIXED);
            this.tvwPartitions.get_column(this.TreeCols.Remove).fixed_width = w * 10;            
        }

        // if this is a return to the screen and previously configured then set model
        private void ModelFromNewSelection()
        {
	        this._lstPartitions.clear();

            if ( gInstallData.HardDiskCount > 0 )
            {
                foreach ( InstallHardDisk iHD in gInstallData )
                {
                    TreeIter iterDisk;

                    // get the matching system HD info - not the install data one
                    HardDisk hd = gHDManager.GetHDBySerial( iHD.SerialNumber );

                    // add the HD to the model
                    this._lstPartitions.append ( out iterDisk, null ); 
                    this._lstPartitions.set ( iterDisk, this.PartitionCols.MountPoint, hd.Model, this.PartitionCols.HardDisk, hd, -1 );

                    foreach ( InstallPartition ip in iHD )
                    {
                        TreeIter iterPart;

                        // add partition info to model
                        this._lstPartitions.append( out iterPart, iterDisk );
                        this.PopulateListItem( iterPart, ip.MountPoint, ip.Type, hd, ip.Label, ip.Format, ip.Use, "", ip.ByteSize, ip.TypeID, ip.Device, "", ip.NewPartition );
                        
                        foreach ( InstallPartition p in ip )
                        {
	                        TreeIter it;
	                        this._lstPartitions.append ( out it, iterPart );
	                        this.PopulateListItem( it, p.MountPoint, p.Type, hd, p.Label, p.Format, p.Use, "", p.ByteSize, p.TypeID, p.Device, "", p.NewPartition );
                        }
                    }
                }
            }
        }
        
        // No manual partitions have been defined so
        // check if disk has partitions, if so then populate the tree
        private void ModelFromCurrentLayout()
        {
            // clear the tree
            this._lstPartitions.clear();
			int PartCount = 0;
			string label;

            HardDisk hd = this.GetSelectedHD();

            if ( hd != null )
            {
                TreeIter iterDisk;

                // add the HD to the model
                this._lstPartitions.append ( out iterDisk, null ); 
                this._lstPartitions.set ( iterDisk, this.PartitionCols.MountPoint, hd.Model, this.PartitionCols.HardDisk, hd, -1 );
                this._lstPartitions.set ( iterDisk, this.PartitionCols.RemoveIcon, Gtk.Stock.DELETE, -1 );

                foreach ( PartitionInfo pi in hd )
                {
	                TreeIter iterPart;

                    if ( pi.OSType != "" &&  pi.Device != hd.Device )
                    {
                        // add partition to model
                        this._lstPartitions.append ( out iterPart, iterDisk );
	        			this.PopulateListItem( iterPart, pi.FSTabMountPoint, pi.OSType, hd, pi.Label, false, false, "", pi.Capacity, pi.OSTypeID, pi.Device, "", false );
	        			this.UpdateSegbar( hd, pi, PartCount );
	        			PartCount++;
                    }
                    else if ( pi.PartitionType.down().contains("extended") )
                    {
	                    this._lstPartitions.append ( out iterPart, iterDisk );
	                    this.PopulateListItem( iterPart, "", "Extended", hd, pi.Label, false, false, "", pi.Capacity, pi.OSTypeID, pi.Device, "", false );
	                    
	                    // add the partitions held in the extended partition
	                    foreach ( PartitionInfo p in pi )
	                    {
		                    TreeIter ti;
		                    this._lstPartitions.append ( out ti, iterPart );
		                    this.PopulateListItem( ti, p.FSTabMountPoint, p.OSType, hd, p.Label, false, false, "", p.Capacity, p.OSTypeID, p.Device, "", false );
		                    this.UpdateSegbar( hd, p, PartCount );
		                    PartCount++;
	                    }
                    }
                }
            }
        }

		private void UpdateSegbar( HardDisk hd, PartitionInfo pi, int PartCount)
		{
			string label;
			label = "%s\n%s".printf(pi.OSType, pi.CapacityDescription); 
			this.AddToDisk( this.segbarHD, hd.Capacity, pi.Capacity, label, PartCount );
		}

		// populate the selected iter - code reduction exercise :-)
		private void PopulateListItem( TreeIter iter, string mountpoint, string ostype, HardDisk hd, string label, bool format,
									  bool use, string icon, uint64 size, string ostypeid, string device, string partitionid, bool newpartition)
		{
	        this._lstPartitions.set ( iter,
	                                  this.PartitionCols.MountPoint, mountpoint,
	                                  this.PartitionCols.DisplaySize, GeneralFunctions.FormatHDSize(size),
	                                  this.PartitionCols.FormatType, ostype,
	                                  this.PartitionCols.HardDisk, hd,
	                                  this.PartitionCols.Label, label,
	                                  this.PartitionCols.FormatFlag, format,
	                                  this.PartitionCols.UseFlag, use,
	                                  this.PartitionCols.RemoveIcon, Gtk.Stock.DELETE,
	                                  this.PartitionCols.ByteSize, size,
	                                  this.PartitionCols.FSTypeID, ostypeid,
	                                  this.PartitionCols.Device, device, 
	                                  this.PartitionCols.PartitionID, partitionid,
	                                  this.PartitionCols.NewPartition, newpartition, -1 );
		}

        // add a partition to the segbar display
        private void AddToDisk( SegmentedBar bar, uint64 HDSize, uint64 PartitionSize, string title, int count )
        {
            double hdtotal = (double)(HDSize / 1024) / 1024;
            double ptnsize = (double)(PartitionSize / 1024) / 1024;
            int percent = (int)Math.round( (ptnsize / hdtotal) * 100 );

            segbarHD.SegmentLabelSpacing = 20;
            segbarHD.AddSegmentRgb (title, percent, GeneralFunctions.BarColour(count) );
        }

        // get the disk information for the selected disk
        private void GetDiskInfo()
        {
            TreeIter iter;
			this._lstDisks.clear();

            // add the hard disks found
            foreach ( HardDisk d in gHDManager.HardDisks )
            {
                if ( ! d.IsOptical )
                {
                    this._lstDisks.append(out iter);
                    string displaytxt = "%s - %s".printf(d.Model, d.CapacityDescription );
                    this._lstDisks.set (iter, 0, displaytxt, 1, d, -1 );
                }
            }
            this.cboHD.set_active(0);
        }

		// Selects the HD previously selected on the HD Main Screen
		private void SetSelectedHD(HardDisk hd)
		{
			TreeIter iter;
			GLib.Value val;

			this._lstDisks.get_iter_first(out iter);

			do
			{
				this._lstDisks.get_value(iter, 1, out val);
				if ( (HardDisk)val == hd )
				{
					this.cboHD.set_active_iter(iter);
					break;
				}
			} 
			while ( this.cboHD.model.iter_next(ref iter) );
		}

        // get the selected Hard disk object
        private HardDisk GetSelectedHD()
        {
            TreeIter iter;
            GLib.Value val;

            this.cboHD.get_active_iter(out iter);
            this._lstDisks.get_value(iter, 1, out val);
            return (HardDisk)val;
        }

        // only one mount point type is allowed 
        public bool IsMountPointUsed(string MountPoint)
        {
            TreeIter iter;
            GLib.Value hdVal;
			GLib.Value mp;

            // loop through select HD in tree
            this._lstPartitions.get_iter_first(out iter);

            do
            {
                // get the HD object for selected iter
                this._lstPartitions.get_value(iter, this.PartitionCols.HardDisk, out hdVal);

                TreeIter partIter;
                
                if ( this._lstPartitions.iter_has_child(iter) )
                {
                    int i = this._lstPartitions.iter_n_children(iter);

                    // loop through the child nodes
                    for ( int x = 0; x < i; x++)
                    {            
                        // get the child
                        this._lstPartitions.iter_nth_child(out partIter, iter, x);

                        // we only need partitions, not HD
                        this._lstPartitions.get_value(partIter, this.PartitionCols.MountPoint, out mp);

                        // check the mp value
                        if ( mp.get_string().down() == MountPoint && MountPoint != "none" )
                        { return true; }
                    }
                }
            }
            while ( this._lstPartitions.iter_next(ref iter) );
            
            // MP not used so return false
            return false;
        }

        // add the disk, partition and details to tree
        // if manually adding partitions assume full schema reset, device set to HD device
        // HD device will be used to create the partition schema
        public void AddToTree(FilesystemType fstype, string mountpoint, uint64 size, string label, string partitionid)
        {
            TreeIter iterDisk;
            TreeIter iterPart;

            HardDisk SelectedHD;
            GLib.Value val;

            // get the selected HD 
            SelectedHD = this.GetSelectedHD();

            // set the iter to the HD if exists in tree
            if ( ! HardDiskExists( SelectedHD, out iterDisk ) )
            { 
                this._lstPartitions.append ( out iterDisk, null ); 
                this._lstPartitions.set ( iterDisk, this.PartitionCols.MountPoint, SelectedHD.Model, this.PartitionCols.HardDisk, SelectedHD, -1 );
            }

			// Get the selected partition
			iterPart = this.GetSelectedPartition();

			// check the size of the partition compared to that being added
			this._lstPartitions.get_value( iterPart, PartitionCols.ByteSize, out val );

			if ( size < val.get_uint64() )
			{
				uint64 nSize = val.get_uint64() - size;
				string nDisplaySize = GeneralFunctions.FormatHDSize ( nSize );

				// update the current size, current partition size - new partition size
				// this is the unallocated partition
				this._lstPartitions.set ( iterPart, this.PartitionCols.DisplaySize, nDisplaySize,
											    this.PartitionCols.ByteSize, nSize );

				// create a new entry for the assigned partition
				this._lstPartitions.insert_before( out iterPart, null, iterPart );
			}

            // add partition info to model
            this.PopulateListItem( iterPart, mountpoint, fstype.Name, SelectedHD, label, false, 
            						true, "", size, fstype.ID, SelectedHD.Device, partitionid, true );

            // add the unallocated partition if parttype is extended
            if ( fstype.ID == "0x05" )
            {
	            TreeIter iterExt;
	            this._lstPartitions.append( out iterExt, iterPart );
	            this.PopulateListItem( iterExt, "", "Unallocated", SelectedHD, "", false, false, "", size, "Unallocated", SelectedHD.Device, "", true);
            }

            this.tvwPartitions.expand_all();

            if ( this.rdoAfter.active == true )
            { this.HDDisplayAfter( SelectedHD ); }
        }

        // Check if the Hard Disk has already been added to the list
        private bool HardDiskExists(HardDisk hd, out TreeIter iter)
        { 
            GLib.Value valHD;
            
            // get the first iter
            this._lstPartitions.get_iter_first(out iter);
            
            // loop through the list, find the matching HD
            do
            {
                // Get the HD value
                this._lstPartitions.get_value(iter, this.PartitionCols.HardDisk, out valHD);

                // check the match
                if ( valHD.holds( typeof(HardDisk) ) && ((HardDisk)valHD).SerialNumber == hd.SerialNumber )
                { return true; }                 

            } 
            while ( this._lstPartitions.iter_next(ref iter) );

            return false;
        }

        private uint64 AvailablePartSize(HardDisk hd)
        {
            TreeIter iter;
            uint64 Allocated = 0;
            GLib.Value size;
            GLib.Value hdVal;

            // loop through the allocated partitions, sum the sizes
            this._lstPartitions.get_iter_first(out iter);

            do
            {
                // only calc for current disk
                this._lstPartitions.get_value(iter, this.PartitionCols.HardDisk, out hdVal);

                if ( hdVal.holds ( typeof(HardDisk) ) && ((HardDisk)hdVal).SerialNumber == hd.SerialNumber )
                {    
                    TreeIter partIter;
                
                    if ( this._lstPartitions.iter_has_child( iter ) )
                    {
                        int i = this._lstPartitions.iter_n_children( iter );
                     
                        // loop through the child nodes
                        for ( int x = 0; x < i; x++)
                        {            
                            // get the child
                            this._lstPartitions.iter_nth_child( out partIter, iter, x );

                            // we only need partitions, not HD
                            this._lstPartitions.get_value( partIter, this.PartitionCols.ByteSize, out size );
                            Allocated += size.get_uint64();
                        } 
                    }
                }
            }
            while ( this._lstPartitions.iter_next(ref iter) );

            // return the available ( Disk size - allocated )
            uint64 available = hd.Capacity - Allocated;

            return ( available >= 0 ) ? available : 0;
        }

        // Segbar display the partitions that will be applied 
        private void HDDisplayAfter(HardDisk hd)
        {
            TreeIter iter;
            uint64 available = this.AvailablePartSize(hd);
			GLib.Value hdVal;

            // clear the seg bar
            this.segbarHD.RemoveAllSegments();

            // loop through the items in the treeview for selected HD
            this._lstPartitions.get_iter_first(out iter);
            do
            {
                // only calc for current disk
                this._lstPartitions.get_value( iter, this.PartitionCols.HardDisk, out hdVal );

                if ( hdVal.holds ( typeof(HardDisk) ) && ((HardDisk)hdVal).SerialNumber == hd.SerialNumber )
                {    
                    TreeIter partIter;

                    if ( this._lstPartitions.iter_has_child( iter ) )
                    {
                        int i = this._lstPartitions.iter_n_children(iter);

                        // loop through the child nodes
                        for ( int x = 0; x < i; x++)
                        {   
                            // get the child
                            this._lstPartitions.iter_nth_child( out partIter, iter, x );

	                        // ignore partitions with children (extended)
	                        if ( this._lstPartitions.iter_has_child( partIter ) )
                        	{
	                        	for ( int y = 0; y < this._lstPartitions.iter_n_children(partIter); y++ )
	                        	{
		                        	TreeIter it;
		                        	this._lstPartitions.iter_nth_child(out it, partIter, y);
		                        	this.PopulateFromExisting( it, x+y, hd );
	                        	}
                        	}
                        	else
                        	{ this.PopulateFromExisting( partIter, x, hd ); }
                        } 
                    }
                }
            }
            while ( this._lstPartitions.iter_next(ref iter) ); 

            // add the unallocated segment
            if ( available > 1 )
            { AddToDisk( this.segbarHD, hd.Capacity, available, "UNALLOCATED", 7 ); }
        }

		private void PopulateFromExisting( TreeIter iter, int idx, HardDisk hd )
		{
            GLib.Value pSize;
            GLib.Value pType;
            GLib.Value pMount;
            GLib.Value pLabel;
			
            // Get the part details
            this._lstPartitions.get_value(iter, this.PartitionCols.MountPoint, out pMount);
            this._lstPartitions.get_value(iter, this.PartitionCols.ByteSize, out pSize);
            this._lstPartitions.get_value(iter, this.PartitionCols.FormatType, out pType);
            this._lstPartitions.get_value(iter, this.PartitionCols.Label, out pLabel);

            // add the details
            string mount, fstype, label;
            fstype = ( pType.get_string() != null ) ? pType.get_string() : "";
            mount = ( pMount.get_string() != null ) ? "\n" + pMount.get_string() : "";
            label = ( pLabel.get_string() != null ) ? "\n" + pLabel.get_string() : "";
            this.AddToDisk( this.segbarHD, hd.Capacity, pSize.get_uint64(), "%s%s%s".printf(fstype, mount, label), idx );
		}

        // populate the install data - Disk and partition schema
        private void AddInstallPartitions()
        {
            // reset the install data to mirror changes here
            gInstallData.ClearInstallDisks();

            // get the hard disks to be partitioned
            TreeIter iter;
            GLib.Value hdVal;

            this._lstPartitions.get_iter_first(out iter);

            do
            {
                if ( this._lstPartitions.iter_depth(iter) == 0 )
                {
                    // Get Top level iter, HD to be partitioned
                    this._lstPartitions.get_value(iter, this.PartitionCols.HardDisk, out hdVal);

                    if ( hdVal.holds ( typeof(HardDisk) )  )
                    {   
                        HardDisk hd = (HardDisk)hdVal;

                        InstallHardDisk iHD = new InstallHardDisk();
                        iHD.DeviceName = hd.Device;
                        iHD.SerialNumber = hd.SerialNumber;
                        uint64 start = 1048576;
                        TreeIter partIter;

                        if ( this._lstPartitions.iter_has_child(iter) )
                        {
                            GLib.Value vSize;
                            int i = this._lstPartitions.iter_n_children(iter);

                            // loop through the child nodes
                            for ( int x = 0; x < i; x++ )
                            {   
                                // get the child
                                this._lstPartitions.iter_nth_child( out partIter, iter, x );

                                // Only get the primary/extended partition, ignore sub parts
                                if ( this.IsAllocated( partIter) && this._lstPartitions.iter_depth( partIter ) == 1 )
                                { 
	                                GLib.Value vUse;
	                                InstallPartition p = null;
	                                
	                                this._lstPartitions.get_value( partIter, this.PartitionCols.ByteSize, out vSize );
	                                this._lstPartitions.get_value( partIter, this.PartitionCols.UseFlag, out vUse );
	                                
	                                if ( vUse.get_boolean() )
	                                { p = this.PopulateInstallPartition( partIter, start ); }

	                                // check for extended children
	                                if ( this._lstPartitions.iter_has_child(partIter) )
	                                {
		                                uint64 estart = start;
							 			GLib.Value veSize;
										GLib.Value veUse;

		                             	// loop through the sub partitions and add to this partition
		                             	for ( int y = 0; y < this._lstPartitions.iter_n_children(partIter); y++ )
		                             	{
			                             	TreeIter it;
			                             	this._lstPartitions.iter_nth_child(out it, partIter, y);
			                             	if ( this.IsAllocated( it ) )
			                             	{
				                             	this._lstPartitions.get_value( it, this.PartitionCols.ByteSize, out veSize );
				                             	this._lstPartitions.get_value( it, this.PartitionCols.UseFlag, out veUse );
				                             	
				                             	if ( veUse.get_boolean() && p != null )
			                             		{ p.AddInstallPartition( this.PopulateInstallPartition( it, estart ) ); }
			                             		
			                             		estart += veSize.get_uint64();
		                             		}
		                             	}
	                                }
	                                start += vSize.get_uint64();
									iHD.AddPartition(p);
									p = null;
                                }
                            } 
                        }
                        gInstallData.AddInstallDisk(iHD);
                        iHD = null;
                    }
                }
            }
            while ( this._lstPartitions.iter_next(ref iter) );
        }

		private bool IsAllocated( TreeIter i )
		{
			GLib.Value val;
			this._lstPartitions.get_value( i, this.PartitionCols.FormatType, out val );
			
			if ( val.get_string() == null || val.get_string() == "" || val.get_string().down() == "unallocated" )
			{ return false; }
			else
			{ return true; }
		}

		private InstallPartition PopulateInstallPartition( TreeIter iter, uint64 start )
		{
			GLib.Value pVal;

            // Create Install Partition
            InstallPartition ip = new InstallPartition();

            // Get the partition info, enough to install
            this._lstPartitions.get_value(iter, this.PartitionCols.ByteSize, out pVal);
            ip.ByteSize = pVal.get_uint64() - 1048576;
            
            this._lstPartitions.get_value(iter, this.PartitionCols.DisplaySize, out pVal);
            ip.DisplaySize = pVal.get_string();

            this._lstPartitions.get_value(iter, this.PartitionCols.Label, out pVal);
            ip.Label = pVal.get_string();

            this._lstPartitions.get_value(iter, this.PartitionCols.MountPoint, out pVal);
            ip.MountPoint = pVal.get_string();

            this._lstPartitions.get_value(iter, this.PartitionCols.FormatFlag, out pVal);
            ip.Format = pVal.get_boolean();
            
			this._lstPartitions.get_value(iter, this.PartitionCols.FormatFlag, out pVal);
            ip.Use = pVal.get_boolean();

			this._lstPartitions.get_value(iter, this.PartitionCols.NewPartition, out pVal);
			ip.NewPartition = pVal.get_boolean();

            this._lstPartitions.get_value(iter, this.PartitionCols.FormatType, out pVal);
            ip.Type = pVal.get_string();

            this._lstPartitions.get_value(iter, this.PartitionCols.FSTypeID, out pVal);
            ip.TypeID = pVal.get_string();

			this._lstPartitions.get_value(iter, this.PartitionCols.Device, out pVal);
            ip.Device = ( pVal.holds(typeof(string) ) ) ? pVal.get_string() : "";

            // set the start and end sizes
            ip.Start = start;
            ip.End = ip.Start + ip.ByteSize;

            return ip;
		}
		
		private void DebugTree()
		{
			TreeIter iter;
			
			this._lstPartitions.get_iter_first(out iter);
			do
			{
				GeneralFunctions.LogIt("ITER\n");
			}
			while ( this._lstPartitions.iter_next(ref iter) );
		}
		
		private TreeIter GetSelectedPartition()
		{
			TreeIter iter;
			TreeSelection ts = this.tvwPartitions.get_selection();
			ts.get_selected(null, out iter);
			return iter;
		}
		
// CONTROL EVENTS
        
        // remove the item from the list
        public void OnCellDelClicked(string path)
        {
            Gtk.TreeIter iter;
            GLib.Value val;
			HardDisk hd;
			uint64 available;

            // get the item on the path
            Gtk.TreePath tp = new Gtk.TreePath.from_string(path);
        
            // check that the user hasn't clicked delete at drive level
            if ( tp.get_depth() > 1 )
            {
            	this._lstPartitions.get_iter(out iter, tp);
				this._lstPartitions.get_value(iter, this.PartitionCols.ByteSize, out val);
				available = val.get_uint64();

				this._lstPartitions.get_value(iter, this.PartitionCols.HardDisk, out val);
				hd = (HardDisk)val;

				// check if the iter is the extended partition
				if ( this._lstPartitions.iter_has_child(iter) )
				{
					Gtk.TreeIter childIter;
					int i;
					
					// remove the children
					i = this._lstPartitions.iter_n_children(iter) - 1;
					
					for ( int x = i; x > -1; x-- )
					{ 
						this._lstPartitions.iter_nth_child(out childIter, iter, x);
						this._lstPartitions.remove(childIter);
					}
				}

				// set the currently selected partition to unallocated
				this.PopulateListItem( iter, "", "Unallocated", hd, "", false, false, "", available, "Unallocated", hd.Device, "", true);
				
			 	this.RecalcUnallocated(iter);
		 	}
        }

		private void RecalcUnallocated(TreeIter iter)
		{
			Gtk.TreeIter partIter;
			Gtk.TreeIter diskIter;
			Gtk.TreeIter parentIter;
			GLib.Value val;
			int level = this._lstPartitions.iter_depth(iter);
			int i;
			bool bPreviousUnalloc = false;

			// check if this is the extended partition
			
			// get the iter count
			this._lstPartitions.iter_parent(out parentIter, iter);
			
			// check the iter is valid
			if ( this._lstPartitions.iter_is_valid(parentIter) )
			{
				// get the count of the parents children (i.e. siblings)
				i = this._lstPartitions.iter_n_children(parentIter) - 1;
				
				// Reverse loop the children
				for ( int x = i; x > -1; x-- )
				{
					// check if iter is unallocated, get the size
					this._lstPartitions.iter_nth_child(out partIter, parentIter, x);
					this._lstPartitions.get_value( partIter, this.TreeCols.FormatType, out val );
					
					if ( val.get_string().down() == "unallocated" && this._lstPartitions.iter_depth(partIter) == level )
					{
						this._lstPartitions.get_value( partIter, this.PartitionCols.ByteSize, out val );
						uint64 partsize = val.get_uint64();
						
						// check if previous iter was unallocated
						if ( bPreviousUnalloc )
						{
							uint64 available = 0;
							uint64 total;
							Gtk.TreeIter nextIter;
							
							this._lstPartitions.iter_nth_child(out nextIter, parentIter, x+1);
							this._lstPartitions.get_value( nextIter, this.PartitionCols.ByteSize, out val );
							available += val.get_uint64();
							total = available + partsize;

							// add the available to this iter, remove the previous one
							this._lstPartitions.set_value ( partIter, this.PartitionCols.ByteSize, total );
							this._lstPartitions.set_value ( partIter, this.PartitionCols.DisplaySize, GeneralFunctions.FormatHDSize(total) );
							
							// remove the previous iter
							this._lstPartitions.remove( nextIter );
						}
						bPreviousUnalloc = true;
					}
					else
					{ bPreviousUnalloc = false; }
				}
			}
		}

		// check the current row
		public bool TvwPartitions_RowClick(Gdk.EventButton evt)
		{
			TreeIter iter;
			GLib.Value val;
			TreeSelection ts = this.tvwPartitions.get_selection();
			ts.get_selected(null, out iter);
			bool enabled = false;

			this._lstPartitions.get_value(iter, PartitionCols.FormatType, out val);

			if ( val.get_string().down() == "unallocated" || val.get_string().down() == "extended partition")
			{ enabled = true; }

			this.btnCreatePart.sensitive = enabled;

			return false;
		}

        public void OnBtnApply_Click()
        { 
            this.AddInstallPartitions();
            this.parent.destroy();
        }

        public void OnRdoBefore_Click()
        { 
			if ( this.rdoBefore.active == true )        
        	{ OnCboHD_Changed(); }
        }

        public void OnRdoAfter_Click()
        { 
	        // TODO: Applying partitions when HD > 0 needs to compare
	        //       with existing, applying if different
	        if ( this.rdoAfter.active == true )
        	{
	        	if ( gInstallData.HardDiskCount == 0 )
	        	{ this.AddInstallPartitions();  }
	        	this.ModelFromNewSelection();
        		this.HDDisplayAfter( GetSelectedHD() ); 
        		this.tvwPartitions.expand_all();
        	}
        }

        public void OnBtnCreatePartition_Click()
        {
			TreeIter iter = this.GetSelectedPartition();
			GLib.Value val;

	        this._lstPartitions.get_value(iter, PartitionCols.ByteSize, out val);

           // GeneralFunctions.ShowWindow(new FCreatePartition(this.GetSelectedHD(), val.get_uint64(), this ), "Exogenesis", true);
        }

        public void OnBtnCancel_Click()
        { 
            Gtk.MessageDialog msg = new Gtk.MessageDialog (
            null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
            "Do your really wish to cancel and return to the previous screen?");
            Gtk.ResponseType res = (Gtk.ResponseType)msg.run();

            if (res == Gtk.ResponseType.YES) 
            {
                msg.destroy(); 
                this.parent.destroy();
            }         
        }

        public void OnCboHD_Changed()
        {
            HardDisk di;

            // clear the existing seg HD info
            this.segbarHD.RemoveAllSegments();

            // get the select HD and display
            di = this.GetSelectedHD();

            // Populate tree view from either existing schema or new proposed schema
            if ( this.rdoBefore.active = true )
            { this.ModelFromCurrentLayout(); }
            else
            {
            	if ( gInstallData.HardDiskCount > 0 )
            	{ this.ModelFromNewSelection(); }
            	else
            	{ this.ModelFromCurrentLayout(); }
           	}
            this.tvwPartitions.expand_all();
        }
    }
}