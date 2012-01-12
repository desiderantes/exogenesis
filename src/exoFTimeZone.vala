using Gtk;
using GLib;

namespace Exogenesis
{
    public class FTimeZone : Gtk.Box
    {
        // widgets from UI
        private Gtk.Box boxTimeZone;
        private Gtk.Button btnPrevious;
		private Gtk.Label lblTimeZoneTitle;
		private Gtk.Image imgTimezone;
		private Gtk.Box boxTZWidget;
		private Gtk.Label lblCurrentTime;
		private Gtk.Button btnManual;
		private Gtk.Button btnNext;
		private Gtk.Box boxMain;
		
		// custom widgets
		TZWidget _tzmap;
		
		// module variables
		private string _SelectedTimeZone;
		private Time _SelectedTime;
		private uint timerID;
        private bool _ManualTime;       // manually adjusted time is immediately applied, set to override post install

        protected virtual void Build()
        {
            try
            {
                // get the glade details for control layout
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                // get the main window
				this.boxTimeZone = ( Gtk.Box ) builder.get_object ( "boxTimeZone" );
				this.btnPrevious = ( Gtk.Button ) builder.get_object ( "btnPrevious" );
				this.lblTimeZoneTitle = ( Gtk.Label ) builder.get_object ( "lblTimeZoneTitle" );
				this.imgTimezone = ( Gtk.Image ) builder.get_object ( "imgTimezone" );
				this.boxTZWidget = ( Gtk.Box ) builder.get_object ( "boxTZWidget" );
				this.lblCurrentTime = ( Gtk.Label ) builder.get_object ( "lblCurrentTime" );
				this.btnManual = ( Gtk.Button ) builder.get_object ( "btnManual" );
				this.btnNext = ( Gtk.Button ) builder.get_object ( "btnNext" );
				this.boxMain = ( Gtk.Box ) builder.get_object ( "boxMain" );
				
                // wire standard control events
                this.btnManual.clicked.connect ( this.OnBtnChangeTime_Click );
                this.btnNext.clicked.connect ( this.OnBtnTZNext_Click );
                this.btnPrevious.clicked.connect ( this.OnBtnTZPrevious_Click );
				this.realize.connect ( this.OnRealised );

				
				this._tzmap = new TZWidget();
				this._tzmap.TimeZoneSelected.connect ( this.OnTimeZoneSelected );
				this.boxTZWidget.pack_start( this._tzmap, false, false, 0 );

                // Get and display Current Time
                Time t =  Time.local((time_t)TimeVal().tv_sec); 
                this.lblCurrentTime.label = t.format("%Ec");  	
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

        public FTimeZone()
        { 
            this.Build();
            // add the fixed layout to the layout
            this.pack_start( boxTimeZone, false, false, 0 );
            this.width_request = 700;
            this.height_request = 450;
            timerID = Timeout.add (1000, OnTimer);
            this.show_all();
        }
        
        public bool OnTimer () 
        {
            this.DisplayTime();
		    return true;
	    }
	    
        private void DisplayTime()
        {
            // Get and display Current Time
            Time t =  Time.local((time_t)TimeVal().tv_sec); 
            this.lblCurrentTime.label = t.format("%Ec");                
        }
        
        protected void OnTimeZoneSelected(string Zone, Time localtime)
        {
            this._SelectedTimeZone = Zone;
            this._SelectedTime = localtime;
            this.lblCurrentTime.label = localtime.format("%Ec");
        }
     
        protected void OnBtnChangeTime_Click()
        {
            FTimeAdjustMan fta = new FTimeAdjustMan();
          //  GeneralFunctions.ShowWindow(fta, "Manual Time Adjust", true);
        }
        
        protected void OnBtnTZNext_Click()
        {
	        gInstallData.TimeZone = this._SelectedTimeZone;
        	((MainWin)this.get_toplevel()).ShowNextWindow(); 
        }
        
        protected void OnBtnTZPrevious_Click()
        { ((MainWin)this.get_toplevel()).ShowPreviousWindow(); }

		private void ShowAllocs( Container x )
		{
			Allocation alloc;
			x.get_allocation(out alloc);
			
			stdout.printf("%s ALLOC x=%s y=%s w=%s h=%s\n", x.get_name(), alloc.x.to_string(), alloc.y.to_string(), alloc.width.to_string(), alloc.height.to_string() );
			stdout.printf( "%s SIZE h=%s w=%s\n", x.get_name(), x.height_request.to_string(), x.width_request.to_string() );
			//stdout.printf( "%s SIZE h=%s w=%s\n", x.get_name(), x.height.to_string(), x.width.to_string() );
			
		}

		protected void OnRealised()
		{
			Allocation alloc;
			this.get_toplevel().get_allocation( out alloc );
			this.boxTimeZone.set_allocation ( alloc );

			// this.boxTimeZone.resize_children();
			((Gtk.Window)this.get_toplevel()).resize_children();

			boxTZWidget.get_allocation( out alloc );
			this._tzmap.set_allocation( alloc );
			this._tzmap.width_request = alloc.width;
			this._tzmap.height_request = alloc.height;
			this.boxTimeZone.show_all();
			this.boxTZWidget.show_all();
			
		}
		
    }
}