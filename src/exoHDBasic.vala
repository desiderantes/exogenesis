using Gtk;

namespace Exogenesis
{
    public class FHDConfigBasic : Gtk.Box
    {
		private Gtk.Box boxHDConfig;
		private Gtk.Box boxHDHead;
		private Gtk.Box boxHDMain;
		private Gtk.Button btnHDPrevious;
		private Gtk.Button btnHDNext;
		private Gtk.Grid grdHD1;
		private Gtk.Button btnCompleteInstall;
		private Gtk.Image imgBtnCompleteInstall;
		private Gtk.Button btnAlongSide;
		private Gtk.Image imgAlongSide;
		private Gtk.Button btnManualInstall;
		private Gtk.Image imgManualInstall;
		private Gtk.Label lblAlongsideExisting;
		private Gtk.Label lblManualConfig;
		private Gtk.Label lblCompleteTakeover;
		private Gtk.Label lblOSSOnly;
		private Gtk.CheckButton chkOSSOnly;
		
		public FHDConfigBasic()
		{
			this.Build();
		}

		private void Build()
		{
			try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

				// get the widgets
				this.boxHDConfig = ( Gtk.Box ) builder.get_object( "boxHDConfig" );
				this.boxHDHead = ( Gtk.Box ) builder.get_object( "boxHDHead" );
				this.boxHDMain = ( Gtk.Box ) builder.get_object( "boxHDMain" );
				this.btnHDPrevious = ( Gtk.Button ) builder.get_object( "btnHDPrevious" );
				this.btnHDNext = ( Gtk.Button ) builder.get_object( "btnHDNext" );
				this.grdHD1 = ( Gtk.Grid ) builder.get_object( "grdHD1" );
				this.btnCompleteInstall = ( Gtk.Button ) builder.get_object ( "btnCompleteInstall" );
				this.imgBtnCompleteInstall = ( Gtk.Image ) builder.get_object ( "imgBtnCompleteInstall" );
				this.btnAlongSide = ( Gtk.Button ) builder.get_object ( "btnAlongSide" );
				this.imgAlongSide = ( Gtk.Image ) builder.get_object ( "imgAlongSide" );
				this.btnManualInstall = ( Gtk.Button ) builder.get_object ( "btnManualInstall" );
				this.imgManualInstall = ( Gtk.Image ) builder.get_object ( "imgManualInstall" );
				this.lblCompleteTakeover = ( Gtk.Label ) builder.get_object ( "lblCompleteTakeover" );
				this.lblOSSOnly = ( Gtk.Label ) builder.get_object ( "lblOSSOnly" );
				this.chkOSSOnly = ( Gtk.CheckButton ) builder.get_object ( "chkOSSOnly" );

				this.btnManualInstall.clicked.connect( this.OnBtnAdvancedClick );
				this.btnHDPrevious.clicked.connect ( this.OnBtnHDPreviousClick );
				
				this.add( this.boxHDConfig );
				this.show_all();
				
			}
			catch( GLib.Error err )
			{
                var msg = new Gtk.MessageDialog (
                null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.CANCEL,
                "Failed to load UI\n" + err.message);
                msg.run();
                Gtk.main_quit();				
			}
		}

		private void OnBtnAdvancedClick()
		{
			((MainWin)this.get_toplevel() ).DisplayWindow(new FHDConfigAdvanced());
		}

		private void OnBtnHDPreviousClick()
 		{ ((MainWin)this.get_toplevel()).ShowPreviousWindow(); }
	}
}