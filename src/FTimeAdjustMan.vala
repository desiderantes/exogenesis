using Gtk;
using Gdk;
using Oobs;

namespace Exogenesis
{
    public class FTimeAdjustMan : Gtk.Layout
    {
        private Gtk.Fixed fxdTimeAdjust;
        private Gtk.Button btnApply;
        private Gtk.Label lblCurrentTime;
        private Gtk.Calendar calTZ;
        private Gtk.SpinButton spnHour;
        private Gtk.SpinButton spnMinute;
        private Gtk.SpinButton spnSecond;
        private uint timerID;
        private int _Date[3];
        private int _Time[3];

        public FTimeAdjustMan()
        {
            this.Build();
            this.width_request = this.fxdTimeAdjust.width_request;
            this.height_request = this.fxdTimeAdjust.height_request;
            this.add( this.fxdTimeAdjust );
            timerID = Timeout.add (1000, OnTimer);
            this.SetRanges();
            this.SetCurrentTimeDate();
            this.show_all();
        }

        public void Build()
        {
            try
            {
                // get the glade details for control layout
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file("exogenesis1.glade");

                this.fxdTimeAdjust = ( Gtk.Fixed ) builder.get_object("fxdAdjustMan");
                this.btnApply =  ( Gtk.Button ) builder.get_object("btnApply");
                this.lblCurrentTime =  ( Gtk.Label ) builder.get_object("lblTime");
                this.calTZ =  ( Gtk.Calendar) builder.get_object("calTZ");
                this.spnHour =  ( Gtk.SpinButton ) builder.get_object("spnHour");
                this.spnMinute =  ( Gtk.SpinButton ) builder.get_object("spnMinute");
                this.spnSecond =  ( Gtk.SpinButton ) builder.get_object("spnSecond");

                // set time ranges
                this.spnHour.set_range(0, 23);
                this.spnMinute.set_range(0, 59);
                this.spnSecond.set_range(0, 59);

                // wire control events
                this.btnApply.clicked.connect ( OnBtnApplyClick );

                // current time display
                DisplayTime();
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

        private void SetRanges()
        {
            Gtk.Adjustment adj = new Gtk.Adjustment(0,0,23,1,1,1);
            this.spnHour.set_adjustment(adj);
            
            adj = new Gtk.Adjustment(0, 0, 59, 1, 1, 1);
            this.spnMinute.set_adjustment(adj);
            
            adj = new Gtk.Adjustment(0, 0, 59, 1, 1, 1);
            this.spnSecond.set_adjustment(adj);
        }

        private void DisplayTime()
        {
            // Get and display Current Time
            Time t =  Time.local((time_t)TimeVal().tv_sec); 
            this.lblCurrentTime.label = t.format("%Ec");                
        }

        private void SetCurrentTimeDate()
        {
            this.GetDateTime();
    
            this.calTZ.day = this._Date[2];
            this.calTZ.month = this._Date[1];
            this.calTZ.year = this._Date[0];
            
            this.spnHour.set_value(this._Time[0]);
            this.spnMinute.set_value(this._Time[1]);
            this.spnSecond.set_value(this._Time[2]);
        }

        private void GetDateTime()
        {
            var curTime = Time.local((time_t)TimeVal().tv_sec).to_string();
            string tSplit[2];
            tSplit[0] = curTime.split(" ")[0];
            tSplit[1] = curTime.split(" ")[1];
            
            GeneralFunctions.LogIt("%s\n".printf(curTime));
            for ( int i = 0; i < 2; i++)
            { 
                for ( int j = 0; j < 3; j++)
                {
                    if ( i == 0 )
                    { this._Date[j] = int.parse(tSplit[i].split("-")[j] ); }
                    else
                    { this._Time[j] = int.parse( tSplit[i].split(":")[j] ); }
                }
            } 
        }
        
        public void OnBtnApplyClick()
        {
            if ( gGenFunc.ShowDialogue("Manual Time Set", 
                                       "Set the current system time to the current configuration?",
                                       Gtk.ButtonsType.YES_NO, Gtk.MessageType.QUESTION) == Gtk.ResponseType.YES )
            {
                Oobs.TimeConfig tc = (Oobs.TimeConfig)Oobs.TimeConfig.get();
                tc.set_time(this._Date[0], this._Date[1], this._Date[2],
                                this._Time[0], this._Time[1], this._Time[2]);
            }
        }
        
        public bool OnTimer () 
        {
            DisplayTime();
		    return true;
	    }
    }
}