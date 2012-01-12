using Gtk;

namespace Exogenesis
{
    public class FConfirm : Gtk.Layout
    {
        private Gtk.Fixed fxdLayout;
        private Gtk.Button btnCancel;
        private Gtk.Button btnPrevious;
        private Gtk.Button btnInstall;
		private Gtk.ComboBox cboHDBootTarget;
		private Gtk.Label lblConfirmText;
		private Gtk.ScrolledWindow scrConfirm;

		// messages
		private string _Title = "Confirmation Options";
		private string _UserDetail = "User To Be Added:";
		private string _KeyboardSetting = "Keyboard Setting:";
		private string _KeyboardVariant = "Keyboard Variant:";
		private string _TimeZone = "Timezone:";
		private string _HDTarget = "Hard Disk Configuration:";

        private ListStore _lstGrubTarget = new ListStore(1, typeof(string) );

        public FConfirm()
        {
            this.build();
            this.add(this.fxdLayout);
        }

        private void build()
        {
            try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                this.fxdLayout = ( Gtk.Fixed ) builder.get_object("fxdConfirmation");
                this.btnCancel = ( Gtk.Button ) builder.get_object("btnConfirmCancel");
                this.btnPrevious = ( Gtk.Button ) builder.get_object("btnConfirmPrevious");
                this.btnInstall = ( Gtk.Button ) builder.get_object("btnConfirmInstall");
				this.cboHDBootTarget = ( Gtk.ComboBox ) builder.get_object("cboHDBootTarget");
				this.lblConfirmText = ( Gtk.Label ) builder.get_object("lblConfirmText");
				this.scrConfirm = ( Gtk.ScrolledWindow ) builder.get_object("scrConfirm");

                // wire the events
                this.btnCancel.clicked.connect ( this.OnBtnCancel_Click );
                this.btnPrevious.clicked.connect ( this.OnBtnPrevious_Click );
                this.btnInstall.clicked.connect ( this.OnBtnInstall_Click ); 
				this.cboHDBootTarget.changed.connect ( this.OnCboHDBootTarget_Changed );
				this.fxdLayout.realize.connect ( this.OnRealize );

                // set the size of layout to size of fixed and show
                this.width_request = this.fxdLayout.width_request;
                this.height_request = this.fxdLayout.height_request;

                // attach the model and combo
                this.cboHDBootTarget.set_model( this._lstGrubTarget );
				CellRendererText cellHD = new CellRendererText();
	            this.cboHDBootTarget.pack_start(cellHD, true);
	            this.cboHDBootTarget.add_attribute(cellHD, "text", 0);

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

        private void PopulateGrubTarget()
        {
			TreeIter iter;

			this._lstGrubTarget.clear();

			foreach ( InstallHardDisk hd in gInstallData )
			{
				GeneralFunctions.LogIt("Oooo you have a hard one!\n");
				this._lstGrubTarget.append( out iter );
				this._lstGrubTarget.set ( iter, 0, hd.DeviceName, -1 );
			}

			//if ( this._lstGrubTarget.length > 0 )
			//{ this.cboHDBootTarget.set_active(0); }
        }

		private void PopulateDetails()
		{
			UserDetail ud = gInstallData.GetMainUser();
			StringBuilder options = new StringBuilder();

			// add the timezone
			options.append( "<b>%s</b> %s\n\n".printf(this._TimeZone, gInstallData.TimeZone ) );

			// add the keyboard setting
			options.append( "<b>%s</b> %s\n".printf(this._KeyboardSetting, gInstallData.KeyboardLayout ) );

			// add variant if selected
			if ( gInstallData.KeyboardVariant != null && gInstallData.KeyboardVariant != "" )
			{ options.append( "<b>%s</b> %s\n".printf ( this._KeyboardVariant, gInstallData.KeyboardVariant ) ); }

			// add the user
			options.append( "\n<b>%s</b> %s - %s\n".printf(this._UserDetail, ud.Fullname, ud.Username ) );

			// add the HD and partitions to create
			options.append( "\n<b>%s</b>\n".printf(this._HDTarget) );

			foreach ( InstallHardDisk hd in gInstallData )
			{
				options.append("\t%s\n".printf( hd.DeviceName ) );

				foreach ( InstallPartition ip in hd )
				{ options.append("\t\t%s\n".printf(ip.Device) ); }
			}
			this.lblConfirmText.label = options.str;
		}

		public void OnCboHDBootTarget_Changed()
		{
		}

		public void OnRealize()
		{ 
			this.PopulateDetails();
			this.PopulateGrubTarget(); 
		}

        public void OnBtnCancel_Click()
        { ((MainWin)this.parent).Cancel(); }

        public void OnBtnPrevious_Click()
        { ((MainWin)this.parent).ShowPreviousWindow(); }

        public void OnBtnInstall_Click()
        { ((MainWin)this.parent).ShowNextWindow(); }
    }
}