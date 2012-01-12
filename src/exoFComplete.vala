using Gtk;

namespace Exogenesis
{
    public class FComplete : Gtk.Layout
    {
        private Gtk.Fixed fxdLayout;
        private Gtk.Button btnReboot;
        private Gtk.Button btnContinue;
        private Gtk.Label lblPostInstall;
		private Gtk.Image imgFinished;

        public FComplete()
        {
            this.Build();
            this.LoadImage();
            this.add(this.fxdLayout);
        }
        
        private void Build()
        {
           try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                // get the control references
                this.fxdLayout = ( Gtk.Fixed ) builder.get_object("fxdComplete");
                this.btnReboot = ( Gtk.Button ) builder.get_object("btnReboot");
                this.btnContinue = ( Gtk.Button ) builder.get_object("btnContinue");
                this.lblPostInstall = ( Gtk.Label ) builder.get_object("lblInstalled");
				this.imgFinished = ( Gtk.Image ) builder.get_object("imgFinished");

                // wire the events
                this.btnReboot.clicked.connect ( this.OnBtnReboot_Click );
                this.btnContinue.clicked.connect ( this.OnBtnContinue_Click );

                // set the size of layout to size of fixed and show
                this.width_request = this.fxdLayout.width_request;
                this.height_request = this.fxdLayout.height_request;
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
		
		private void LoadImage()
		{
			try
			{
				string file = "%s/images/reboot_or_continue.png".printf(AppPath);
				this.imgFinished.set_from_file(file);
			}
			catch ( Error err )
			{ GeneralFunctions.LogIt("ERROR - %s\n".printf(err.message)); }
		}
        public void OnBtnReboot_Click()
        { }
        
        public void OnBtnContinue_Click()
        { }
    }
}