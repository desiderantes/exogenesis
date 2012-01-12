using Gtk;

namespace Exogenesis
{
    public class FInstall : Gtk.Layout
    {
        private Gtk.Fixed fxdLayout;
        private Gtk.Image imgInfo;
        private Gtk.Label lblInfo;
		private Gtk.VBox vbxProgress;
		private SegmentedBar segProgress;
		private string[] _imageFiles = {}; 
        private uint _timerId;
        private int _lastImgId = 0;
		private int _progress = 0;

        public FInstall()
        {
	        this.GetImageFiles();
            this.Build();
            this.add( this.fxdLayout );
        }  

        private void Build()
        {
            try 
            {
                // get the details from glade
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                // get the controls from glade
                this.fxdLayout = ( Gtk.Fixed ) builder.get_object("fxdProgress");
                this.imgInfo = ( Gtk.Image ) builder.get_object("imgProgessInfo");
                this.lblInfo = ( Gtk.Label) builder.get_object("lblInstallInfo");
				this.vbxProgress = ( Gtk.VBox ) builder.get_object("vbxProgress");
				this.imgInfo.set_from_file( this._imageFiles[0] );

				// create the segbar for HD
	            this.segProgress = new SegmentedBar();
	            segProgress.BarHeight = 20; 
	            segProgress.HorizontalPadding = segProgress.BarHeight / 2;
	            segProgress.ShowReflection = false;
	            segProgress.show_labels = false;
	            vbxProgress.pack_start (segProgress, false, false, 0);
	            vbxProgress.show_all ();

                // wire in the events
				this.fxdLayout.realize.connect( OnFxdLayout_Realise );
				
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
        
        private void GetImageFiles()
        {
			try 
			{
				FileInfo file_info;
			    var directory = File.new_for_path ("%s/slides".printf(AppPath) );
			    var enumerator = directory.enumerate_children (FILE_ATTRIBUTE_STANDARD_NAME, 0);

			    while ((file_info = enumerator.next_file ()) != null) 
				{ this._imageFiles += "%s/slides/%s".printf(AppPath, file_info.get_name() ); }
			} 
			catch (Error e) 
			{ stderr.printf ("Error: %s\n", e.message); }
        }

		private void UpdateProgressBar(int percentage)
		{ 
			this.segProgress.AddSegmentRgb ("one", percentage, GeneralFunctions.BarColour(2) );
		}

        public bool OnTimer () 
        {
            this.DisplayImage();
		    return true;
	    }
	    
	    public void DisplayImage()
    	{
	    	// loop the images if at the end
	    	if ( this._lastImgId < this._imageFiles.length -1 )
	    	{ this._lastImgId += 1; }
	    	else
	    	{ this._lastImgId = 0; }

	    	this.imgInfo.set_from_file( this._imageFiles[this._lastImgId] );
	    	this.UpdateProgressBar( this._progress += 20 );
	    	this.UpdateLabel("Copying System Files...");
    	}
    	
    	private void UpdateLabel(string text)
    	{ this.lblInfo.label = text; }
    	
    	public void OnFxdLayout_Realise()
    	{ this._timerId = Timeout.add (1000, OnTimer); }
    }
}