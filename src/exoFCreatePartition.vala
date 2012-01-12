using GLib;
using Gtk;
using Gdu;

namespace Exogenesis
{
    public class FCreatePartition : Gtk.Layout
    {

		private Gtk.Box boxCreatePartition;
		private Gtk.Label lblCPTitle;
		private Gtk.Box boxCPMain;
		private Gtk.Grid grdCPOptions;
		private Gtk.Label lblCPPartType;
		private Gtk.Label lblCPMountPoint;
		private Gtk.Label lblCPLabel;
		private Gtk.ComboBox cboCPPartType;
		private Gtk.ComboBox cboCPMountPoint;
		private Gtk.Entry txtCPLabel;
		private Gtk.Box boxCPSize;
		private Gtk.SpinButton spnCPSize;
		private Gtk.Scale sclCPSize;
		private Gtk.Box boxCPButtons;
		private Gtk.Button btnCPCancel;
		private Gtk.Image imgCPBtnCancel;
		private Gtk.Label lblCPBtnCancel;
		private Gtk.Button btnCPApply;
		private Gtk.Image imgCPBtnApply;
		private Gtk.Label lblCPBtnApply;

        // Local Vars
        private ListStore _lstPartTypes = new ListStore( 2, typeof(string), typeof(FilesystemType) );
        private ListStore _lstMountPoints = new ListStore( 2, typeof(string), typeof(MountPoint) );

        private InstallHardDisk _iHD;
		private FHDConfigAdvanced _Owner;

        public FCreatePartition( InstallHardDisk hd, uint64 availablesize, FHDConfigAdvanced owner)
        {
	        this._Owner = owner;
            if ( hd != null )
            { this._iHD = hd; }

            this.Build();
            this.SetMaxAvailable(availablesize);
            this.GetFileSystemTypes();
            this.GetMountPoints();
            this.add ( this.boxCreatePartition );
        }

        // assign controls from glade, setup initial form
        private void Build()
        {
	        try
	        {
	            // get the glade layouts/controls
	            Gtk.Builder builder = new Gtk.Builder();
	            builder.add_from_file( "%s/src/exogenesis.ui".printf( AppPath ) );

				this.boxCreatePartition = ( Gtk.Box ) builder.get_object ( "boxCreatePartition" );
				this.lblCPTitle = ( Gtk.Label ) builder.get_object ( "lblCPTitle" );
				this.boxCPMain = ( Gtk.Box ) builder.get_object ( "boxCPMain" );
				this.grdCPOptions = ( Gtk.Grid ) builder.get_object ( "grdCPOptions" );
				this.lblCPPartType = ( Gtk.Label ) builder.get_object ( "lblCPPartType" );
				this.lblCPMountPoint = ( Gtk.Label ) builder.get_object ( "lblCPMountPoint" );
				this.lblCPLabel = ( Gtk.Label ) builder.get_object ( "lblCPLabel" );
				this.cboCPPartType = ( Gtk.ComboBox ) builder.get_object ( "cboCPPartType" );
				this.cboCPMountPoint = ( Gtk.ComboBox ) builder.get_object ( "cboCPMountPoint" );
				this.txtCPLabel = ( Gtk.Entry ) builder.get_object ( "txtCPLabel" );
				this.boxCPSize = ( Gtk.Box ) builder.get_object ( "boxCPSize" );
				this.spnCPSize = ( Gtk.SpinButton ) builder.get_object ( "spnCPSize" );
				this.sclCPSize = ( Gtk.Scale ) builder.get_object ( "sclCPSize" );
				this.boxCPButtons = ( Gtk.Box ) builder.get_object ( "boxCPButtons" );
				this.btnCPCancel = ( Gtk.Button ) builder.get_object ( "btnCPCancel" );
				this.imgCPBtnCancel = ( Gtk.Image ) builder.get_object ( "imgCPBtnCancel" );
				this.lblCPBtnCancel = ( Gtk.Label ) builder.get_object ( "lblCPBtnCancel" );
				this.btnCPApply = ( Gtk.Button ) builder.get_object ( "btnCPApply" );
				this.imgCPBtnApply = ( Gtk.Image ) builder.get_object ( "imgCPBtnApply" );
				this.lblCPBtnApply = ( Gtk.Label ) builder.get_object ( "lblCPBtnApply" );

	            this.cboCPPartType.changed.connect ( this.OnCboFileTypes_Changed );
				this.btnCPApply.clicked.connect( this.OnBtnApplyCP_Click );
				this.btnCPCancel.clicked.connect( this.OnBtnCancelCP_Click );

	            // set up the size control
	          //  this.spnHDSize.height_request = vboxSize.height_request;
	          //  this.spnHDSize.width_request = vboxSize.width_request;
	          //  vboxSize.pack_start(this.spnHDSize, false, false, 0);
	           // vboxSize.show_all();

	            // set up formats combo
	            this.cboCPPartType.set_model(this._lstPartTypes);
	            CellRendererText cellFormat = new CellRendererText();
	            this.cboCPPartType.pack_start(cellFormat, true);
	            this.cboCPPartType.add_attribute(cellFormat, "text", 0);

	            // set up mounts points
	            this.cboCPMountPoint.set_model(this._lstMountPoints);
	            CellRendererText cellMP = new CellRendererText();
	            this.cboCPMountPoint.pack_start(cellMP, true);
	            this.cboCPMountPoint.add_attribute(cellMP, "text", 0);

	            this.width_request = this.boxCreatePartition.width_request;
	            this.height_request = this.boxCreatePartition.height_request;
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

        // get the standard mount points
        private void GetMountPoints()
        {
            TreeIter iter;

            // clear down before populating 
            // (added as this is called each time a partition is created/removed)
            this._lstMountPoints.clear();

            foreach ( MountPoint mp in gHDManager.GetMountPoints() )
            {
                string sDisplay;

                if ( mp.Key != "none" )
                { sDisplay = "%s - %s".printf(mp.Key, mp.Path); }
                else
                { sDisplay = "%s".printf(mp.Key); }

                if ( ! this._Owner.IsMountPointUsed(sDisplay) )
                {
                    this._lstMountPoints.append(out iter);
                    this._lstMountPoints.set( iter, 0, sDisplay, 1, mp);
                }
            }
            this.cboCPMountPoint.set_active(0);
        }

        // disable label and mountpoint for SWAP selection
        public void OnCboFileTypes_Changed()
        { 
			TreeIter iter;
			GLib.Value v;
			string s;
			
			this.cboCPPartType.get_active_iter( out iter );
			this._lstPartTypes.get_value( iter, 2, out v );
			s = v.get_string();
			
            if ( s.down().contains("swap") || 
                 s.down().contains("extended partition") )
            {
	            this.SetMountToNone();
                this.cboCPMountPoint.sensitive = false;
                this.txtCPLabel.sensitive = false;
            }
            else
            {
                this.cboCPMountPoint.sensitive = true;
                this.txtCPLabel.sensitive = true;            
            }
        }

        // get the supported filesystem types
        private void GetFileSystemTypes()
        {
            TreeIter iter;
            int idxExt4 = 0;
            int i = 0;

            // add the filesystems that udisks understands
            foreach ( FilesystemType f in gHDManager.FileSystemTypes )
            {
                this._lstPartTypes.append(out iter);
                string sDisplay = "%s".printf(f.Name);
                this._lstPartTypes.set( iter, 0, sDisplay, 1, f, -1 );

                // get the index of EXT4 type to show as default
                if ( sDisplay.down().contains("ext4") )
                { idxExt4 = i; }
                i++;
            }
            this.cboCPPartType.set_active(idxExt4);
        }

        // set the max available space
        private void SetMaxAvailable(uint64 available)
        {
            if ( available > 0 )
            {
                this.spnCPSize.sensitive = true;
                this.spnCPSize.set_range(0, available);
            }
            else
            {
                this.spnCPSize.sensitive = false;
               // this.spnCPSize.set_max_size(0);
            }
            // this.spnCPSize.set_size(0);
        }

        // get the selected file type
        private FilesystemType GetSelectedFileType()
        {
            TreeIter iter;
            GLib.Value val;
 
            this.cboCPPartType.get_active_iter(out iter);
            this._lstPartTypes.get_value(iter, 1, out val);
            return (FilesystemType)val; 
        }

		// set mount point to none
		private void SetMountToNone()
		{
			TreeIter iter;
			
			this._lstMountPoints.get_iter_first( out iter );
			
			do
			{
				GLib.Value gVal;
				this._lstMountPoints.get_value ( iter, 0, out gVal );
				if ( gVal.get_string().down() == "none" )
				{
					this.cboCPMountPoint.set_active_iter( iter );
					break;
				}
			} while ( this._lstMountPoints.iter_next( ref iter ) );
		}

        // get the selected mount point
        private string GetSelectedMountPoint()
        {
			TreeIter iter;
			GLib.Value v;
			
			this.cboCPMountPoint.get_active_iter( out iter );
			this._lstMountPoints.get_value( iter, 2, out v );
			
			return v.get_string(); 
		}

		private string GetSelectedMountPointID()
		{
			TreeIter iter;
			GLib.Value val;

			this.cboCPMountPoint.get_active_iter(out iter);
			this._lstMountPoints.get_value( iter, 0, out val);
			return val.get_string();			
		}

		private void OnBtnApplyCP_Click()
		{
			/*if ( this.spnHDSize.get_size() == 0 )
			{
				gGenFunc.ShowDialogue("Invalid Partition Size", "Partition size needs be larger than 0 bytes", Gtk.ButtonsType.OK, Gtk.MessageType.WARNING);
			}
			else
			{ 
				this._Owner.AddToTree( this.GetSelectedFileType(), this.GetSelectedMountPoint(), 
								   	   this.spnHDSize.get_size(), this.txtPartLabel.text, this.GetSelectedMountPointID() ); 
				this.parent.destroy();
			} */
		}

		private void OnBtnCancelCP_Click()
		{
			if ( gGenFunc.ShowDialogue("Abort Create Partition", "Cancel and return to previous screen?", Gtk.ButtonsType.YES_NO, Gtk.MessageType.QUESTION) 
				 == Gtk.ResponseType.YES )
			{
				this.parent.destroy();
			}
		}
    }
}