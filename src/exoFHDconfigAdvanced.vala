/* -*- Mode: vala; tab-width: 4; intend-tabs-mode: t -*- */
/* exogenesis
 *
 * Copyright (C) Steve Wood 2012 <steve.wood@inixsys.com>
 *
exogenesis is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * exogenesis is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Gtk;
using Gdk;

namespace Exogenesis
{
	public class FHDConfigAdvanced : Gtk.Box 
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
            NewPartition,
			Partition
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

		private Gtk.Box boxHDAdvanced;
		private Gtk.Box boxHDAHead;
		private Gtk.Label lblHDAdvancedTitle;
		private Gtk.Image imgHD2;
		private Gtk.Separator sepHD2;
		private Gtk.Box boxHD2Main;
		private Gtk.Button btnHDAPrevious;
		private Gtk.Image imgBtnHDAPrevious;
		private Gtk.Box boxHDADetails;
		private Gtk.Box boxHDAHardDisk;
		private Gtk.Label lblHDADrives;
		private Gtk.ComboBox cboHDADrives;
		private Gtk.Button btnHDAAddPartition;
		private Gtk.Box boxBtnAddPartition;
		private Gtk.Image imgBtnHDAAddPartition;
		private Gtk.Label lblBtnHDAAddPartition;		
		private Gtk.Box boxHDWidget;
		private Gtk.ScrolledWindow sclHDALayout;
		private Gtk.TreeView trvHDALayout;
		private Gtk.TreeSelection selHDALayout;
		private Gtk.Grid grdHDAButtons;
		private Gtk.Button btnHDAApply;
		private Gtk.Button btnHDARevert;
		private Gtk.Label lblPrevious;
		private Gtk.RadioButton rdoHDBefore;
		private Gtk.RadioButton rdoHDAfter;
		
		// custom widgets
		private SegmentedBar segbarHD;
		
        // local vars
        private ListStore _lstDisks = new ListStore( 2, typeof(string), typeof(HardDisk) );

        // Treestore columns:   0 = Mount Point : 1 = Partition Display Size : 2 = Partition Format Type 
        //                      3 = Partition Label : 4 = HardDisk Object : 5 = format partition flag
        //                      6 = Use Partition Flag : 7 = DELETE :  8 = Paritition byte size : 9 = Partition Type ID
        //						10 = DeviceName : 11 = Partition ID : 12 = New Partition Indicator : 13 = Partition Object
		
        private Gtk.TreeStore _lstPartitions = new Gtk.TreeStore ( 14, typeof(string), typeof(string), typeof(string), 
        																typeof(string), typeof(HardDisk), typeof(bool), 
                                                               			typeof(bool), typeof(string), typeof(uint64), 
                                                               			typeof(string), typeof(string), typeof(string),
                                                               			typeof(bool), typeof(PartitionInfo) );
		

		// this is used to store the model for the new hard disk partition schema
        private Gtk.TreeStore _lstNewPartitions = new Gtk.TreeStore ( 14, typeof(string), typeof(string), typeof(string), 
        																typeof(string), typeof(InstallHardDisk), typeof(bool), 
                                                               			typeof(bool), typeof(string), typeof(uint64), 
                                                               			typeof(string), typeof(string), typeof(string),
                                                               			typeof(bool), typeof(InstallPartition) );

		// Constructor
		public FHDConfigAdvanced () 
		{
            this.Build();
            this.GetDiskInfo();

			// Copy the old Schema to the New Schema
			this.CopyOldSchemaToNew ();

			// set selected HD to the first in list
			if ( gHDManager.HardDiskCount > 0 )
			{ this.SetSelectedHD( gHDManager.HardDisks[0] ); }

			// Add layout to parent box
            this.add( this.boxHDAdvanced );
		}

		private void Build()
		{
			try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                // builder.add_from_file( UIPath );
				builder.add_from_file( "%s/src/exogenesis.ui".printf( AppPath ) );

				// get the widgets
				this.boxHDAdvanced = ( Gtk.Box ) builder.get_object( "boxHDAdvanced" );
				this.boxHDAHead = ( Gtk.Box )  builder.get_object( "boxHDAHead" );
				this.lblHDAdvancedTitle = ( Gtk.Label )  builder.get_object( "lblHDAdvancedTitle" );
				this.imgHD2 = ( Gtk.Image )  builder.get_object( "imgHD2" );
				this.sepHD2 = ( Gtk.Separator )  builder.get_object( "sepHD2" );
				this.boxHD2Main = ( Gtk.Box )  builder.get_object( "boxHD2Main" );
				this.btnHDAPrevious = ( Gtk.Button )  builder.get_object( "btnHDAPrevious" );
				this.imgBtnHDAPrevious = ( Gtk.Image ) builder.get_object( "imgBtnHDAPrevious" );
				this.boxHDADetails = ( Gtk.Box ) builder.get_object( "boxHDADetails" );
				this.boxHDAHardDisk = ( Gtk.Box ) builder.get_object( "boxHDAHardDisk" );
				this.lblHDADrives = ( Gtk.Label ) builder.get_object( "lblHDADrives" );
				this.cboHDADrives = ( Gtk.ComboBox ) builder.get_object( "cboHDADrives" );
				this.btnHDAAddPartition = ( Gtk.Button ) builder.get_object( "btnHDAAddPartition" );
				this.imgBtnHDAAddPartition = ( Gtk.Image ) builder.get_object( "imgBtnHDAAddPartition" );
				this.lblBtnHDAAddPartition = ( Gtk.Label ) builder.get_object( "lblBtnHDAAddPartition" );
				this.boxBtnAddPartition = ( Gtk.Box ) builder.get_object ( "boxBtnAddPartition" );
				this.boxHDWidget = ( Gtk.Box ) builder.get_object( "boxHDWidget" );
				this.sclHDALayout = ( Gtk.ScrolledWindow ) builder.get_object( "sclHDALayout" );
				this.trvHDALayout = ( Gtk.TreeView ) builder.get_object( "trvHDALayout" );
				this.grdHDAButtons = ( Gtk.Grid ) builder.get_object( "grdHDAButtons" );
				this.btnHDAApply = ( Gtk.Button ) builder.get_object( "btnHDAApply" );
				this.btnHDARevert = ( Gtk.Button ) builder.get_object( "btnHDARevert" );
				this.lblPrevious = ( Gtk.Label ) builder.get_object ( "lblPrevious" );
				this.rdoHDBefore = ( Gtk.RadioButton ) builder.get_object ( "rdoHDBefore" );
				this.rdoHDAfter = ( Gtk.RadioButton ) builder.get_object ( "rdoHDAfter" );
				this.selHDALayout = ( Gtk.TreeSelection ) builder.get_object ( "selHDALayout" );
				
                // disk manager events
        		gHDManager.DriveMounted.connect ( this.OnDriveMounted );
                gHDManager.DriveUnMounted.connect ( this.OnDeviceConnected );
				gHDManager.DevicesRefreshed.connect ( this.OnDeviceConnected );
               // gHDManager.DiskManagerError.connect ( this.OnDiskManagerError );

                // set up HD combo
                cboHDADrives.set_model(this._lstDisks);
                CellRendererText cellHD = new CellRendererText();
                cboHDADrives.pack_start(cellHD, true);
                cboHDADrives.add_attribute(cellHD, "text", 0);  

				// Widget Events
				this.cboHDADrives.changed.connect( this.OnCboHD_Changed );
				this.rdoHDAfter.clicked.connect( this.OnRdoAfter_Click );
				this.rdoHDBefore.clicked.connect( this.OnRdoBefore_Click );
				this.trvHDALayout.button_release_event.connect ( this.TrvHDALayout_RowClick );
				this.realize.connect ( this.OnRealized );
				this.btnHDAAddPartition.clicked.connect( this.OnBtnCreatePartition_Click );
				
				// set up the segbarHD
	            this.segbarHD = new SegmentedBar();

	            this.segbarHD.BarHeight = 20; 
	            this.segbarHD.HorizontalPadding = segbarHD.BarHeight / 2;
	            this.segbarHD.ShowReflection = true;
	            this.boxHDWidget.pack_start (segbarHD, false, false, 0);
	            this.boxHDWidget.show_all ();				
				
				this.SetTreeColumns();
	     		// this.SetColumnWidths();

				this.rdoHDBefore.set_active(true);

				// check the previous OSType
				gPreviousOS.GetFSTabMountPoints();
				
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

		// Setup the treeview depending on the before/after view selected
        private void SetTreeColumns()
        {
			// Remove all columns before displaying data
			foreach ( Gtk.TreeViewColumn tvc in this.trvHDALayout.get_columns() )
			{ this.trvHDALayout.remove_column( tvc ); 	}
			
            // Set up the treeview
            this.trvHDALayout.insert_column_with_attributes (-1, "Mount Point", new CellRendererText (), "text", this.PartitionCols.MountPoint, null);
            this.trvHDALayout.insert_column_with_attributes (-1, "Size", new CellRendererText (), "text", this.PartitionCols.DisplaySize, null);
            this.trvHDALayout.insert_column_with_attributes (-1, "Type", new CellRendererText (), "text", this.PartitionCols.FormatType, null);
            this.trvHDALayout.insert_column_with_attributes (-1, "Label", new CellRendererText (), "text", this.PartitionCols.Label, null);

			// Only display the delete on AFTER view
			if ( this.rdoHDAfter.active )
			{
		        // create the toggle renderer, attaching the event for click
		        Gtk.CellRendererToggle togCellF = new Gtk.CellRendererToggle();
		        togCellF.toggled.connect 
		        (
		            (toggle, path) => 
		            {
		                var tree_path = new TreePath.from_string (path);
		                TreeIter iter;
		                this._lstPartitions.get_iter (out iter, tree_path);
		                this._lstPartitions.set (iter, this.PartitionCols.FormatFlag, !toggle.active);
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
		                this._lstPartitions.get_iter (out iter, tree_path);
		                this._lstPartitions.set (iter, this.PartitionCols.UseFlag, !toggle.active);
		            }
		        );

        		this.trvHDALayout.insert_column_with_attributes (-1, "Format", togCellF, "active", this.PartitionCols.FormatFlag, null);
        		this.trvHDALayout.insert_column_with_attributes (-1, "Use", togCellU, "active", this.PartitionCols.UseFlag, null);				

				CellRendererButton cellButtonDel = new CellRendererButton();
        		cellButtonDel.clicked.connect( this.OnCellDelClicked );

				this.trvHDALayout.insert_column_with_attributes (-1, "Delete", cellButtonDel, "stockicon",  this.PartitionCols.RemoveIcon, null); 
			}
            this.trvHDALayout.set_model(this._lstPartitions);
        }

		// Default the new selection to the old and allow changes on new schema only
		// this is run on screen initialise only
		private void CopyOldSchemaToNew ()
		{
			gInstallData.ClearInstallDisks();
			InstallPartition ip;

			foreach ( HardDisk hd in gHDManager.HardDisks )
			{
stdout.printf ( "START SECTOR %s = %s\n", hd.Model, hd.StartSector.to_string () );
								
				InstallHardDisk ihd = new InstallHardDisk();
				ihd.SerialNumber = hd.SerialNumber;
				ihd.DeviceName = hd.Device;
				ihd.DriveSize = hd.Capacity;
				ihd.Model = hd.Model;

				foreach ( PartitionInfo pi in hd )
				{
					if ( pi.PartitionType.down().contains("extended") )
					{
						ip = new InstallPartition ();
						ip.ByteSize = pi.Capacity;
						ip.DisplaySize = pi.CapacityDescription;
						ip.Type = pi.PartitionType;
						ip.MountPoint = pi.FSTabMountPoint;
						ip.Start = pi.StartSector;
						ip.End = pi.EndSector;
						ip.TypeID = pi.OSTypeID;
						ip.NewPartition = false;
						ip.Format = false;

						foreach ( PartitionInfo p in pi )
						{ ip.AddInstallPartition( this.CopyPartition( p ) ); }
					}
					else
					{ ip = this.CopyPartition (pi ); }

					ihd.AddPartition( ip );
				}
				gInstallData.AddInstallDisk( ihd );
			}
		}

		// Copy partition Info from Current to NewPartition
		private InstallPartition CopyPartition( PartitionInfo pi )
		{
			InstallPartition ip = new InstallPartition ();
			ip.ByteSize = pi.Capacity;
			ip.DisplaySize = pi.CapacityDescription;
			ip.Format = false;
			ip.Use = false;
			ip.NewPartition = false;
			ip.MountPoint = pi.FSTabMountPoint;
			ip.Type = pi.OSType;
			ip.TypeID = pi.OSTypeID;
			ip.Label = pi.Label;
			ip.Start = pi.StartSector;
			ip.Device = pi.Device;
			
			return ip;
		}

        // if this is a return to the screen and previously configured then set model
        private void ModelFromNewLayout()
        {
	        this._lstNewPartitions.clear();
			HardDisk selectedHD = this.GetSelectedHD ();
			
            if ( gInstallData.HardDiskCount > 0 )
            {
                foreach ( InstallHardDisk iHD in gInstallData )
                {
                    TreeIter iterDisk;

                    // get the matching system HD info - not the install data one
                    // HardDisk hd = gHDManager.GetHDBySerial( iHD.SerialNumber );

                    // add the HD to the model
                    this._lstNewPartitions.append ( out iterDisk, null ); 
                    this._lstNewPartitions.set ( iterDisk, this.PartitionCols.MountPoint, iHD.Model, this.PartitionCols.HardDisk, iHD, -1 );
					this._lstNewPartitions.set ( iterDisk, this.PartitionCols.RemoveIcon, Gtk.Stock.DELETE, -1 );
					
                    foreach ( InstallPartition ip in iHD )
                    {
                        TreeIter iterPart;
						int PartCount = 0;

						// add partition info to model - This level with be a partition type or extended partition
                        this._lstNewPartitions.append( out iterPart, iterDisk );
					//	this._lstNewPartitions.set ( iterPart, this.PartitionCols.RemoveIcon, Gtk.Stock.DELETE, 
					//	                        	  PartitionCols.FormatType, "Extended",
					//	                        	  PartitionCols.DisplaySize, GeneralFunctions.FormatHDSize( ip.ByteSize), -1 );

                        this.PopulateListItemNew( ref iterPart, ip.MountPoint, ip.Type, iHD, ip.Label, ip.Format, ip.Use, "", ip.ByteSize, ip.TypeID, ip.Device, "", ip.NewPartition, ip );

						// Only Update Segbar if the partition is not extended
						if ( ! ip.Type.down().contains("extended") )
						{
							if ( iHD.SerialNumber == selectedHD.SerialNumber )
							{ this.UpdateSegbarNew( iHD, ip, PartCount ); } 
						}

						// this level will be the partition types inside an extended partition
                        foreach ( InstallPartition p in ip )
                        {
	                        TreeIter it;
							PartCount++;
	                        this._lstNewPartitions.append ( out it, iterPart );
	                        this.PopulateListItemNew( ref it, p.MountPoint, p.Type, iHD, p.Label, p.Format, p.Use, "", p.ByteSize, p.TypeID, p.Device, "", p.NewPartition, p );

							if ( iHD.SerialNumber == selectedHD.SerialNumber )
							{ this.UpdateSegbarNew( iHD, p, PartCount ); }
                        }
                    }
                }
            }
			this.trvHDALayout.model = this._lstNewPartitions;
        }


		// populate the selected iter - code reduction exercise :-) - NEW LAYOUT
		private void PopulateListItemNew( ref TreeIter iter, string mountpoint, string ostype, InstallHardDisk hd, string label, bool format,
											bool use, string icon, uint64 size, string ostypeid, string device, string partitionid, 
		                             	    bool newpartition, InstallPartition p )
		{
	        this._lstNewPartitions.set ( iter,
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
	                                  this.PartitionCols.NewPartition, newpartition,
	                                  this.PartitionCols.Partition, p, -1 );
		}
        
		// Show disk 
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
	        			this.PopulateListItemCurrent( iterPart, pi.FSTabMountPoint, pi.OSType, hd, pi.Label, false, false, "", pi.Capacity, pi.OSTypeID, pi.Device, "", false, pi );
	        			this.UpdateSegbarCurrent( hd, pi, PartCount );
	        			PartCount++;
                    }
                    else if ( pi.PartitionType.down().contains("extended") )
                    {
	                    this._lstPartitions.append ( out iterPart, iterDisk );
	                    this.PopulateListItemCurrent( iterPart, "", "Extended", hd, pi.Label, false, false, "", pi.Capacity, pi.OSTypeID, pi.Device, "", false, pi );
	                    
	                    // add the partitions held in the extended partition
	                    foreach ( PartitionInfo p in pi )
	                    {
		                    TreeIter ti;
		                    this._lstPartitions.append ( out ti, iterPart );
		                    this.PopulateListItemCurrent( ti, p.FSTabMountPoint, p.OSType, hd, p.Label, false, false, "", p.Capacity, p.OSTypeID, p.Device, "", false, p );
		                    this.UpdateSegbarCurrent( hd, p, PartCount );
		                    PartCount++;
	                    }
                    }
                }
                // display current OS
                if ( hd.PreviousOS != null && hd.PreviousOS != "" )
                { this.lblPrevious.label = "This disk contains a version of \n%s".printf(hd.PreviousOS); }
                else
                { this.lblPrevious.label = ""; }				
            }
        }

		private void UpdateSegbarCurrent( HardDisk hd, PartitionInfo pi, int PartCount)
		{
			string label;
			label = "%s\n%s".printf(pi.OSType, pi.CapacityDescription); 
			this.AddToDiskDisplayBar( this.segbarHD, hd.Capacity, pi.Capacity, label, PartCount );
		}

		private void UpdateSegbarNew( InstallHardDisk hd, InstallPartition pi, int PartCount)
		{
			string label;
			label = "%s\n%s".printf( pi.Type, pi.DisplaySize ); 
			this.AddToDiskDisplayBar( this.segbarHD, hd.DriveSize, pi.ByteSize, label, PartCount );
		}
				
		// populate the selected iter - code reduction exercise :-) - CURRENT LAYOUT
		private void PopulateListItemCurrent( TreeIter iter, string mountpoint, string ostype, HardDisk hd, string label, bool format,
												bool use, string icon, uint64 size, string ostypeid, string device, string partitionid, 
		                                 	    bool newpartition, PartitionInfo p )
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
	                                  this.PartitionCols.NewPartition, newpartition,
	                             	   -1 );
		}

        // add a partition to the segbar display
        private void AddToDiskDisplayBar ( SegmentedBar bar, uint64 HDSize, uint64 PartitionSize, string title, int count )
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
            this.cboHDADrives.set_active(0);
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
					this.cboHDADrives.set_active_iter(iter);
					break;
				}
			} 
			while ( this.cboHDADrives.model.iter_next(ref iter) );
		}

        // get the selected Hard disk object
        private HardDisk GetSelectedHD()
        {
            TreeIter iter;
            GLib.Value val;

            this.cboHDADrives.get_active_iter(out iter);
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
            this._lstNewPartitions.get_iter_first(out iter);

            do
            {
                // get the HD object for selected iter
                this._lstNewPartitions.get_value(iter, this.PartitionCols.HardDisk, out hdVal);

                TreeIter partIter;
                
                if ( this._lstNewPartitions.iter_has_child(iter) )
                {
                    int i = this._lstNewPartitions.iter_n_children(iter);

                    // loop through the child nodes
                    for ( int x = 0; x < i; x++)
                    {            
                        // get the child
                        this._lstNewPartitions.iter_nth_child(out partIter, iter, x);

                        // we only need partitions, not HD
                        this._lstNewPartitions.get_value(partIter, this.PartitionCols.MountPoint, out mp);

                        // check the mp value
                        if ( mp.get_string().down() == MountPoint && MountPoint != "none" )
                        { return true; }
                    }
                }
            }
            while ( this._lstNewPartitions.iter_next(ref iter) );
            
            // MP not used so return false
            return false;
        }

        // add the disk, partition and details to tree
        // if manually adding partitions assume full schema reset, device set to HD device
        // HD device will be used to create the partition schema - CALLED FROM EXTERNAL PARTITION CREATOR APPLIES ONLY TO NEW
   /*     public void AddToTree(FilesystemType fstype, string mountpoint, uint64 size, string label, string partitionid)
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

            this.trvHDALayout.expand_all();

            if ( this.rdoHDAfter.active == true )
            { this.HDDisplayAfter( SelectedHD ); }
        } */

        // Check if the Hard Disk has already been added to the list
        private bool HardDiskExists(InstallHardDisk hd, out TreeIter iter)
        { 
            GLib.Value valHD;
            
            // get the first iter
            this._lstNewPartitions.get_iter_first(out iter);
            
            // loop through the list, find the matching HD
            do
            {
                // Get the HD value
                this._lstNewPartitions.get_value(iter, this.PartitionCols.HardDisk, out valHD);

                // check the match
                if ( valHD.holds( typeof(InstallHardDisk) ) && ((InstallHardDisk)valHD).SerialNumber == hd.SerialNumber )
                { return true; }                 

            } 
            while ( this._lstNewPartitions.iter_next(ref iter) );

            return false;
        }

        private uint64 AvailablePartSize(InstallHardDisk hd)
        {
            TreeIter iter;
            uint64 Allocated = 0;
            GLib.Value size;
            GLib.Value hdVal;

            // loop through the allocated partitions, sum the sizes
            this._lstNewPartitions.get_iter_first(out iter);

            do
            {
                // only calc for current disk
                this._lstNewPartitions.get_value(iter, this.PartitionCols.HardDisk, out hdVal);

                if ( hdVal.holds ( typeof(HardDisk) ) && ((HardDisk)hdVal).SerialNumber == hd.SerialNumber )
                {    
                    TreeIter partIter;
                
                    if ( this._lstNewPartitions.iter_has_child( iter ) )
                    {
                        int i = this._lstNewPartitions.iter_n_children( iter );
                     
                        // loop through the child nodes
                        for ( int x = 0; x < i; x++)
                        {            
                            // get the child
                            this._lstNewPartitions.iter_nth_child( out partIter, iter, x );

                            // we only need partitions, not HD
                            this._lstNewPartitions.get_value( partIter, this.PartitionCols.ByteSize, out size );
                            Allocated += size.get_uint64();
                        } 
                    }
                }
            }
            while ( this._lstNewPartitions.iter_next(ref iter) );

            // return the available ( Disk size - allocated )
            uint64 available = hd.DriveSize - Allocated;

            return ( available >= 0 ) ? available : 0;
        }

        // Segbar display the partitions that will be applied 
        private void HDDisplayAfter( InstallHardDisk hd)
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
		                        //	this.PopulateFromExisting( it, x+y, hd );
	                        	}
                        	}
                        	else
                        	{ //this.PopulateFromExisting( partIter, x, hd ); }
							}
                        } 
                    }
                }
            }
            while ( this._lstPartitions.iter_next(ref iter) ); 

            // add the unallocated segment
            if ( available > 1 )
            { this.AddToDiskDisplayBar( this.segbarHD, hd.DriveSize, available, "UNALLOCATED", 7 ); }
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
            this.AddToDiskDisplayBar( this.segbarHD, hd.Capacity, pSize.get_uint64(), "%s%s%s".printf(fstype, mount, label), idx );
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
			TreeSelection ts = this.trvHDALayout.get_selection();
			ts.get_selected(null, out iter);
			return iter;
		}
		
// CONTROL EVENTS
        
        // remove the item from the list - CAN ONLY DELETE ON NEW MODEL NOT EXISTING
        public void OnCellDelClicked( string path )
        {
            Gtk.TreeIter iter;
            GLib.Value val;
			InstallHardDisk ihd;
			uint64 available;
			Gtk.TreeStore selectedStore;

            // get the item on the path
            Gtk.TreePath tp = new Gtk.TreePath.from_string(path);

			// set the store to the one working on
			selectedStore = this._lstNewPartitions;
			
            // check that the user hasn't clicked delete at drive level
            if ( tp.get_depth() > 1 )
            {
				selectedStore.get_iter(out iter, tp);
				selectedStore.get_value(iter, this.PartitionCols.ByteSize, out val);
				available = val.get_uint64();
				selectedStore.get_value(iter, this.PartitionCols.HardDisk, out val);

				// get the harddisk from current or from new config
				ihd = ( InstallHardDisk )val; 

				// check if the iter is the extended partition
				if ( selectedStore.iter_has_child(iter) )
				{
					Gtk.TreeIter childIter;
					int i;
					
					// remove the children
					i = selectedStore.iter_n_children(iter) - 1;
					
					for ( int x = i; x > -1; x-- )
					{ 
						selectedStore.iter_nth_child(out childIter, iter, x);
						selectedStore.remove(childIter);
					}
				}

				// set the currently selected partition to unallocated
				this.PopulateListItemNew ( ref iter, "", "Unallocated", ihd, "", false, false, "", available, "Unallocated", ihd.DeviceName, "", true, null); 
			 	this.RecalcUnallocated(iter);
		 	}
        }

		private void RecalcUnallocated(TreeIter iter)
		{
			Gtk.TreeIter partIter;

			Gtk.TreeIter parentIter;
			GLib.Value val;
			int level = this._lstNewPartitions.iter_depth(iter);
			int i;
			bool bPreviousUnalloc = false;

			// check if this is the extended partition
			
			// get the iter count
			this._lstNewPartitions.iter_parent(out parentIter, iter);
			
			// check the iter is valid
			if ( this._lstNewPartitions.iter_is_valid(parentIter) )
			{
				// get the count of the parents children (i.e. siblings)
				i = this._lstNewPartitions.iter_n_children(parentIter) - 1;
				
				// Reverse loop the children
				for ( int x = i; x > -1; x-- )
				{
					// check if iter is unallocated, get the size
					this._lstNewPartitions.iter_nth_child(out partIter, parentIter, x);
					this._lstNewPartitions.get_value( partIter, this.TreeCols.FormatType, out val );
					
					if ( val.get_string().down() == "unallocated" && this._lstPartitions.iter_depth(partIter) == level )
					{
						this._lstNewPartitions.get_value( partIter, this.PartitionCols.ByteSize, out val );
						uint64 partsize = val.get_uint64();
						
						// check if previous iter was unallocated
						if ( bPreviousUnalloc )
						{
							uint64 available = 0;
							uint64 total;
							Gtk.TreeIter nextIter;
							
							this._lstNewPartitions.iter_nth_child(out nextIter, parentIter, x+1);
							this._lstNewPartitions.get_value( nextIter, this.PartitionCols.ByteSize, out val );
							available += val.get_uint64();
							total = available + partsize;

							// add the available to this iter, remove the previous one
							this._lstNewPartitions.set_value ( partIter, this.PartitionCols.ByteSize, total );
							this._lstNewPartitions.set_value ( partIter, this.PartitionCols.DisplaySize, GeneralFunctions.FormatHDSize(total) );
							
							// remove the previous iter
							this._lstNewPartitions.remove( nextIter );
						}
						bPreviousUnalloc = true;
					}
					else
					{ bPreviousUnalloc = false; }
				}
			}
		}

		// check the current row
		public bool TrvHDALayout_RowClick(Gdk.EventButton evt)
		{
			TreeIter iter;
			GLib.Value val;
			TreeSelection ts = this.trvHDALayout.get_selection();
			ts.get_selected(null, out iter);
			bool enabled = false;

			this._lstPartitions.get_value(iter, PartitionCols.FormatType, out val);

			if ( val.get_string().down() == "unallocated" || val.get_string().down().contains("extended") )
			{ enabled = true; }

			//this.btnCreatePart.sensitive = enabled;

			return false;
		}

        public void OnBtnApply_Click()
        { 
            this.AddInstallPartitions();
            this.parent.destroy();
        }

        public void OnRdoBefore_Click()
        { this.OnCboHD_Changed (); }

        public void OnRdoAfter_Click()
        { this.OnCboHD_Changed (); }

        public void OnBtnCreatePartition_Click()
        {
			FCreatePartition fcp;
			InstallHardDisk ihd = null;
			HardDisk selectedHD = this.GetSelectedHD ();
			
			// get the install HD Target
			foreach ( InstallHardDisk h in gInstallData )
			{
				if ( h.SerialNumber == selectedHD.SerialNumber )
				{
					ihd = h;
					break;
				}
			}

stdout.printf("AVAILABLE SIZE %s\n", ihd.AvailableSize().to_string() );
			
			// check if there is anything available on the disk
			if ( ihd != null && ihd.AvailableSize() > 0 )
			{
				fcp = new FCreatePartition( ihd, ihd.AvailableSize(), this );
				GeneralFunctions.ShowWindow( (Gtk.Box)fcp, "Exogenesis", true);
			}
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

			// set/re-set the treeview columns
			this.SetTreeColumns ();
			
            // clear the existing seg HD info
            this.segbarHD.RemoveAllSegments();

            // get the select HD and display
            di = this.GetSelectedHD();

            // Populate tree view from either existing schema or new proposed schema
            if ( this.rdoHDBefore.active )
            { this.ModelFromCurrentLayout(); }
            else
            { this.ModelFromNewLayout(); }

            this.trvHDALayout.expand_all();
        }

		public void OnDeviceConnected()
		{  this.GetDiskInfo(); }

        private void OnDriveMounted(string mountpoint)
        { 
            gPreviousOS.GetFSTabMountPoints();
            this.OnCboHD_Changed(); 
        }

		private void OnRealized()
		{
			stdout.printf("REALISED\n");
			this.OnCboHD_Changed(); 
			this.show_all();
		}
	}
}