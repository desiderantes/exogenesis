using Gtk;
using Gdk;

namespace Exogenesis
{
    public class FWelcome : Gtk.Box
    {
        // glade widgets
        private Gtk.Box boxWelcome;
		private Gtk.TreeView tvwLanguages;
		private Gtk.Layout lytImage;
		private Gtk.Image imgNext;
		private Gtk.Box boxInfo;
		private Gtk.Image imgWelcome;
		private Gtk.Label lblWelcomeInfo;
		private Gtk.Button btnInstall;
		private Gtk.Button btnLive;
			
        // exo objects
        // private GeneralFunctions _gf = new GeneralFunctions();
        private ListStore _lstLanguages = new ListStore(2, typeof(string), typeof(string) );
        string _fName = "welcome";

		private Gtk.CssProvider _provider = new Gtk.CssProvider();
		private Gdk.Display _display = Gdk.Display.get_default();
		private Gdk.Screen _screen;
		
        private void Build()
        {
            try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                // builder.add_from_file( UIPath );
				builder.add_from_file( "%s/src/exogenesis.ui".printf( AppPath ) );
				
                // get the widgets
				this.boxWelcome = ( Gtk.Box ) builder.get_object ( "boxWelcome" );
				this.tvwLanguages = ( Gtk.TreeView ) builder.get_object ( "tvwLanguages" );
				this.lytImage = ( Gtk.Layout ) builder.get_object ( "lytImage" );
				this.imgNext = ( Gtk.Image ) builder.get_object ( "imgNext" );
				this.boxInfo = ( Gtk.Box ) builder.get_object ( "boxInfo" );
				this.imgWelcome = ( Gtk.Image ) builder.get_object ( "imgWelcome" );
				this.lblWelcomeInfo = ( Gtk.Label) builder.get_object ( "lblWelcomeInfo" );
				this.btnInstall = ( Gtk.Button ) builder.get_object ( "btnInstall" );
				this.btnLive = ( Gtk.Button ) builder.get_object ( "btnLive" );

                this.btnInstall.clicked.connect ( OnBtnInstall_Click );

                // set up Treeview
                this.tvwLanguages.set_model( this._lstLanguages );
                this.tvwLanguages.insert_column_with_attributes (-1, "Language", new CellRendererText (), "text", null);

                // set labels (for translations)
                // this.SetLabels();

				// css formatting - background image
				this._screen = this._display.get_default_screen();
				this.get_style_context().add_provider_for_screen( this._screen, this._provider, 1 );
				this._provider.load_from_data( " GtkWindow {\n background-image: url('images/default_bkground.png');\n }\n", -1);

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
        {
            this.lblWelcomeInfo.label = gGenFunc.GetLabelText(this._fName, "lblWelcomeInfo");
           // this.btnInstall.label = gGenFunc.GetLabelText(this._fName, "btninstall");
           // this.btnAdvanced.label = gGenFunc.GetLabelText(this._fName, "btnadvanced");
        } 

        public FWelcome() 
        {
            Build(); 
            this.GetLanguages();

            // add the fixed layout to the layout
            this.add( this.boxWelcome );
           	this.width_request = 700;
           	this.height_request = 450;
			Allocation alloc;
			this.get_allocation( out alloc );
			boxWelcome.set_allocation ( alloc );
            this.show_all();
        }


        public string GetSelectedLanguage()
        {
            TreeSelection ts;
            TreeIter iter;
            TreeModel tm;
            string val;

            ts = this.tvwLanguages.get_selection();
            ts.get_selected( out tm, out iter );
            tm.get(iter, 1, out val);
            return val;
        }

        private void GetLanguages()
        {
            GLib.List<Language> languages = gLanguageManager.AvailableLanguages();
            Gtk.TreeIter iter;

            foreach ( Language lang in languages )
            {
                string displaytxt = "%s %s".printf(lang.Country, lang.CountryNative);
                this._lstLanguages.append(out iter);
                this._lstLanguages.set (iter, 0, displaytxt, 1, lang.Code, -1);
            }
        }

        public void OnBtnInstall_Click (Button source) 
        { ((MainWin)this.get_toplevel() ).ShowNextWindow(); }
    }
}