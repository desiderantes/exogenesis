using Gdk;
using Gtk;
using GLib;
using Gee;
using Oobs;
using Gdk;
using Cairo;

namespace Exogenesis
{
    public enum CairoCorners
    {
        None = 0,
        TopLeft = 1,
        TopRight = 2,
        BottomLeft = 4,
        BottomRight = 8,
        All = 15
    }

	public class TZWidget : Gtk.Widget
	{
		// Class Variables - objects
		private ColourMap _colourmap = new ColourMap();
		private Gee.ArrayList<TZDistance> _Distances = new Gee.ArrayList<TZDistance>();
		private TZDb _TZDb = new TZDb();


		private double _PrevClickX = -1;
		private double _PrevClickY = -1;
        private int _DistPos = 0;

		// private _tzinfo;
		private string _ImagePath;
		private Gdk.Pixbuf _OrigBackground;
		private Gdk.Pixbuf _OrigColourMap;
		private Gdk.Pixbuf _Background;
		private Gdk.Pixbuf _ColourMap;
		private unowned uchar[] _VisibleMapPixels;
		private int _VisibleMapRowStride;
		private uint _timerID;

		private string? _SelectedOffset;
		private string? _SelectedCity;
		private uint? _TimeoutID;
		
		private int _BgScaleHeight;
		private int _BgScaleWidth;
		
		// properties
		public string BackGroundFile { get; set; }
		public string ColourMapFile { get; set; }

		
		public signal void TimeZoneSelected(string Zone, Time localtime);
		
		// -------------- MAIN Class start -----------------------------------
		public TZWidget()
		{ 
			try
			{
				this.button_press_event.connect ( OnButtonPress );
				this._OrigBackground = new Gdk.Pixbuf.from_file("%s/timezone/bg.png".printf(AppPath));
				this._OrigColourMap = new Gdk.Pixbuf.from_file("%s/timezone/cc.png".printf(AppPath));
				this._timerID = Timeout.add (1000, OnTimer);
				this.unrealize.connect ( this.OnUnRealised );
				this.PopulateColourMap();
			}
			catch ( GLib.Error err)
			{
				stdout.printf( "%s\n", err.message );
			}
		}

		public void OnUnRealised()
		{
			this.set_parent_window(null);
		}
		
        public bool OnTimer () 
        {
			Context cr = Gdk.cairo_create( get_parent_window() );
			//parent.propagate_draw( this, cr );
			draw ( cr );
			return true;
	    }

		private void PopulateColourMap()
		{
			this._colourmap.AddColourMap("-11.0", 43, 0, 0, 255);
			this._colourmap.AddColourMap("-10.0", 85, 0, 0, 255);
			this._colourmap.AddColourMap("-9.5", 102, 255, 0, 255);
			this._colourmap.AddColourMap("-9.0", 128, 0, 0, 255);
			this._colourmap.AddColourMap("-8.0", 170, 0, 0, 255);
			this._colourmap.AddColourMap("-7.0", 212, 0, 0, 255);
			this._colourmap.AddColourMap("-6.0|north", 255, 0, 1, 255);
			this._colourmap.AddColourMap("-6.0|south", 255, 0, 0, 255);
			this._colourmap.AddColourMap("-5.0" , 255, 42, 42, 255);
			this._colourmap.AddColourMap("-4.5" , 192, 255, 0, 255);
			this._colourmap.AddColourMap("-4.0" , 255, 85, 85, 255);
			this._colourmap.AddColourMap("-3.5" , 0, 255, 0, 255);
			this._colourmap.AddColourMap("-3.0" , 255, 128, 128, 255);
			this._colourmap.AddColourMap("-2.0" , 255, 170, 170, 255);
			this._colourmap.AddColourMap("-1.0" , 255, 213, 213, 255);
			this._colourmap.AddColourMap("0.0" , 43, 17, 0, 255);
			this._colourmap.AddColourMap("1.0" , 85, 34, 0, 255);
			this._colourmap.AddColourMap("2.0" , 128, 51, 0, 255);
			this._colourmap.AddColourMap("3.0" , 170, 68, 0, 255);
			this._colourmap.AddColourMap("3.5" , 0, 255, 102, 255);
			this._colourmap.AddColourMap("4.0" , 212, 85, 0, 255);
			this._colourmap.AddColourMap("4.5" , 0, 204, 255, 255);
			this._colourmap.AddColourMap("5.0" , 255, 102, 0, 255);
			this._colourmap.AddColourMap("5.5" , 0, 102, 255, 255);
			this._colourmap.AddColourMap("5.75" , 0, 238, 207, 247);
			this._colourmap.AddColourMap("6.0" , 255, 127, 42, 255);
			this._colourmap.AddColourMap("6.5" , 204, 0, 254, 254);
			this._colourmap.AddColourMap("7.0" , 255, 153, 85, 255);
			this._colourmap.AddColourMap("8.0" , 255, 179, 128, 255);
			this._colourmap.AddColourMap("9.0" , 255, 204, 170, 255);
			this._colourmap.AddColourMap("9.5" , 170, 0, 68, 250);
			this._colourmap.AddColourMap("10.0" , 255, 230, 213, 255);
			this._colourmap.AddColourMap("10.5" , 212, 124, 21, 250);
			this._colourmap.AddColourMap("11.0" , 212, 170, 0, 255);
			this._colourmap.AddColourMap("11.5" , 249, 25, 87, 253);
			this._colourmap.AddColourMap("12.0" , 255, 204, 0, 255);
			this._colourmap.AddColourMap("12.75" , 254, 74, 100, 248);
			this._colourmap.AddColourMap("13.0" , 255, 85, 153, 250);
		}

		private double ConvertLatitudeToY(double latitude, double mapheight)
		{
			double bottomlat = -59;
			double toplat = 81;
 			double topper = toplat / 180.0;
 		
    		double y = 1.25 * Math.log(Math.tan(Math.PI / 4.0 + 0.4 * ( latitude * Math.PI / 180  )));
    		double fullrange = 4.6068250867599998;
    		double topoffset = fullrange * topper; 
    		double maprange = Math.fabs( 1.25 * Math.log(Math.tan(Math.PI / 4.0 + 0.4 * ( bottomlat * Math.PI / 180))) - topoffset );
    		y = Math.fabs(y - topoffset);
    		y = y / maprange;
    		y = y * mapheight;
    		return y;
		}

		private double ConvertLongitudeToX(double longitude, double mapwidth)
		{
			double xdegoffset = -6;
			double x = (mapwidth * (180.0 + longitude) / 360.0) + (mapwidth * xdegoffset / 180.0);
			x = x % mapwidth;
			return x;
		}

		private Colour? ConvertXYToOffset(double X, double Y)
		{
			int x,y;
			int rs = this._VisibleMapRowStride;
			unowned uchar[] px = this._VisibleMapPixels;

			Colour colour = new Colour();

			x = (int)X;
			y = (int)Y;

			colour.DataA = (int)px[(rs * y + x * 4)];
			colour.DataB = (int)px[(rs * y + x * 4)+1];
			colour.DataC = (int)px[(rs * y + x * 4)+2];
			colour.DataD = (int)px[(rs * y + x * 4)+3];

			foreach ( Colour C in this._colourmap )
			{
				if ( CompareColour(C, colour) )
				{ return C; }
			}
            return null;			
		}

        private bool CompareColour(Colour a, Colour b)
        {
           
           if ( a.DataA == b.DataA && a.DataB == b.DataB && a.DataC == b.DataC && a.DataD == b.DataD ) 
           { return true; }
           else
           { return false; }
        }

		protected override void get_preferred_width ( out int minwidth, out int natwidth )
		{ minwidth = natwidth = 0; }

		protected override void get_preferred_height ( out int minheight, out int natheight )
		{ minheight = natheight = 0; }
		
		protected override void size_allocate (Gdk.Rectangle rec)
		{
			stdout.printf("Size changed\n");
		 	this._Background = this._OrigBackground.scale_simple( rec.width, 
																 rec.height, 
																 Gdk.InterpType.BILINEAR);

			this._ColourMap = this._OrigColourMap.scale_simple(rec.width, 
															   rec.height, 
															   Gdk.InterpType.BILINEAR);

			this._VisibleMapPixels = (uint8[])this._ColourMap.get_pixels();
			this._VisibleMapRowStride = this._ColourMap.get_rowstride();
			base.size_allocate( rec );
		}

		
		protected override void realize()
		{
			Allocation alloc;

			this.parent.get_allocation( out alloc );
			
			Gdk.WindowAttr wa = WindowAttr();

			wa.window_type = Gdk.WindowType.CHILD;
			wa.wclass = Gdk.WindowWindowClass.OUTPUT;
			wa.event_mask = get_events() | 
							  Gdk.EventMask.EXPOSURE_MASK | 
							  Gdk.EventMask.BUTTON_PRESS_MASK;

			wa.height = alloc.height;
			wa.width = alloc.width;

			set_parent_window( new Gdk.Window( get_parent_window(), wa, 0 ) );

			get_parent_window().set_user_data( this );

			style.attach( get_parent_window() );
			style.set_background( get_parent_window(), Gtk.StateType.NORMAL );
			get_parent_window().show();
			
			get_parent_window().set_cursor( new Gdk.Cursor( Gdk.CursorType.HAND2 ) );
			get_parent_window().set_user_data( this );

			
			// get_allocation(out alloc);
			parent.get_allocation( out alloc );

			get_parent_window().move_resize( alloc.x, alloc.y, alloc.width, alloc.height );
			
			this.set_realized( true );
		}

		
		protected override bool draw ( Context cr )
		{
			Gdk.Pixbuf pixbuf;
			int height, width;
			bool onlydrawselected = false;
			double pointx, pointy, newx, newy;
			Time now;
			string sTime;
			Cairo.TextExtents te;
			Gdk.Color colour;
			Location location;

			Allocation alloc;
			parent.get_allocation(out alloc);
			
			Gdk.cairo_set_source_pixbuf(cr, this._Background, 0, 0);	
			cr.paint();
						
			if ( this._SelectedOffset != null )
			{
				try
				{
				    // select timezone image and display over map
					pixbuf = new Gdk.Pixbuf.from_file("%s/timezone/timezone_%s.png".printf( AppPath, this._SelectedOffset.split("|")[0]));
					pixbuf = pixbuf.scale_simple( alloc.width, alloc.height, Gdk.InterpType.BILINEAR);

					Gdk.cairo_set_source_pixbuf(cr,pixbuf, 0, 0);
					cr.paint();
				}
				catch( GLib.Error e )
				{
					GeneralFunctions.LogIt("error setting time zone band highlight:%s".printf( e.message));
					return false;
				}
			}
			
			// height = this._Background.get_height();
			// width = this._Background.get_width();
			height = alloc.height;
			width = alloc.width;
			
			onlydrawselected = true;

			if ( this._SelectedCity != null && this._SelectedCity != "" )
			{
				location = this._TZDb.GetLocationForCity(this._SelectedCity);

				if ( location != null )
				{
					pointx = this.ConvertLongitudeToX(location.Longitude, width);
					pointy = this.ConvertLatitudeToY(location.Latitude, height);

		            // draw centre dot on click spot				
					Gdk.Color.parse("black", out colour);
					cr.set_source_rgb((uint)colour.red, (uint)colour.green, (uint)colour.blue);
					cr.arc(pointx, pointy, 2.5, 0, 2 * Math.PI);
					cr.fill_preserve();
		            cr.set_line_width(1.5);
		            cr.stroke();

		            // text rendering                				
				    Gdk.Color.parse("white", out colour);
		    		cr.set_source_rgb((uint)colour.red, (uint)colour.green, (uint)colour.blue);
					cr.stroke();
				
					sTime = location.CityName.replace("_", " "); // now.strftime("");
					sTime += " - %s".printf( location.LocalTime.format("%X") ); 
					cr.select_font_face("sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
					cr.set_font_size(12);
					cr.text_extents(sTime, out te);
					newy = pointy - ( te.y_bearing / 2);
				
					if ( pointx + te.width + 10 > alloc.width )
					{ newx = pointx - 12 - te.width - 4; }
					else
					{ newx = pointx + 12; }
					cr.move_to(newx, newy);
				
					// text background
					Gdk.Color.parse("black", out colour);
					cr.set_source_rgb((uint)colour.red, (uint)colour.green, (uint)colour.blue);
					RoundedRectangle(cr, newx - 5, newy + te.y_bearing - 6, te.width + 10, te.height + 12, te.height / 6,
									 CairoCorners.All, false );
					cr.fill_preserve();
					cr.stroke();
				
				    Gdk.Color.parse("white", out colour);
		    		cr.set_source_rgb((uint)colour.red, (uint)colour.green, (uint)colour.blue);
				
					cr.move_to(newx, newy);
					cr.show_text(sTime);
					cr.stroke();
				}
			}
			return true;
		}

		public bool TimeOut()
		{
			this.queue_draw();
			return true;
		}
		
		public void Mapped(Gtk.Widget widget, Event evt )
		{
		    if ( this._TimeoutID != null )
		    { this._TimeoutID = Timeout.add(1000, TimeOut); } 
		}	
	
	    public void UnMapped(Gtk.Widget widget, Event evt)
	    { 
	        if ( this._TimeoutID != null )
	        {
	            
	        }
	    }
        private bool OnButtonPress(EventButton evt)
        {
	        double x, y;
	        Colour o;
            double DistPos, PointX, PointY;
            string Zone;
            
	        x = evt.x;
	        y = evt.y;

	        o = this.ConvertXYToOffset(x, y);

            if ( o == null )
            { return false; }
            else
            { this._SelectedOffset = o.Offset; }

	        if ( (x == this._PrevClickX && y == this._PrevClickY)  && (this._Distances.size > 0) )
	        {
                this._DistPos = ( this._DistPos + 1 ) % this._Distances.size;
                Zone = this._Distances[this._DistPos].Loc.Zone;
	        } 
	        else
	        {
	            this._Distances.clear();
	            
	            bool SameContext;
	            double dx, dy, dist;
	            double height = this._Background.get_height();
	            double width = this._Background.get_width();
                Colour PointTo;

	            bool HasContext = o.Offset.contains("|");

	            foreach ( Location loc in this._TZDb.Locations )
	            {
	                int roffsetsecs;
	                double roffsetdays;
	                
                    roffsetdays  = loc.RawUTCOffsetDays();
	                roffsetsecs = loc.RawUTCOffsetSeconds();
	                 
	                string offset = this.TZFormatString( ( roffsetdays * 24 ) + ( roffsetsecs / 60.0 / 60.0 ) );

	                if ( offset.to_string() != this._SelectedOffset.split("|")[0] )
	                { continue; }
	                
	                PointX = this.ConvertLongitudeToX(loc.Longitude, width);
	                PointY = this.ConvertLatitudeToY(loc.Latitude, height);
	                
	                
	                if ( HasContext )
	                {
	                    PointTo = this.ConvertXYToOffset(PointX, PointY);
	                    SameContext =  CompareColour(PointTo, o);
	                }
	                else
	                { SameContext = true; }
	                
	                dx = PointX - x;
	                dy = PointY - y;
	                dist = dx * dx + dy * dy; 
	                
	                this._Distances.add( new TZDistance(dist, loc, SameContext)); 
	            }
                
                this._Distances.sort();

                for ( int i=0;i< this._Distances.size; i++ )
                {
                    if ( this._Distances[i].SameContext )
                    {
                        if ( i > 0 )
                        {   
                            TZDistance tzdist = this._Distances.get(i);
                            this._Distances.remove_at(i); 
                            this._Distances.insert(0, tzdist); 
                        }
                        break;
                    }
                }

                Zone = this._Distances[0].Loc.Zone;
                
                this._DistPos = 0;
	            this._PrevClickX = x;
	            this._PrevClickY = y;
	        }

	        this.SelectCity(Zone);
	        this.queue_draw();
			return true;
        }

        public virtual void SelectCity(string Zone)
        {
            Location loc = this._TZDb.GetLocationFromZone(Zone);
            
            if ( loc != null )
            {
                double roffsetdays = loc.RawUTCOffsetDays();
                int roffset = loc.RawUTCOffsetSeconds();
                
                this._SelectedCity = loc.CityName;

                this._SelectedOffset = this.TZFormatString( (roffsetdays * 24) + roffset / 60.0 / 60.0 );
            
                this.TimeZoneSelected(Zone, loc.LocalTime);
            }
            
            this.queue_draw(); 
        }



		public static void RoundedRectangle( Cairo.Context cr, double x, double y, double w, double h,  double r, 
		 									 CairoCorners corners, bool topBottomFallsThrough )
	    {
	        if(topBottomFallsThrough && corners == CairoCorners.None) {
	            cr.move_to(x, y - r);
	            cr.line_to(x, y + h + r);
	            cr.move_to(x + w, y - r);
	            cr.line_to(x + w, y + h + r);
	            return;
	        } else if(r < 0.0001 || corners == CairoCorners.None) {
	            cr.rectangle(x, y, w, h);
	            return;
	        }
	
	        if((corners & (CairoCorners.TopLeft | CairoCorners.TopRight)) == 0 && topBottomFallsThrough) {
	            y -= r;
	            h += r;
	            cr.move_to(x + w, y);
	        } else {
	            if((corners & CairoCorners.TopLeft) != 0) {
	                cr.move_to(x + r, y);
	            } else {
	                cr.move_to(x, y);
	            }
	
	            if((corners & CairoCorners.TopRight) != 0) {
	                cr.arc(x + w - r, y + r, r, Math.PI * 1.5, Math.PI * 2);
	            } else {
	                cr.line_to(x + w, y);
	            }
	        }
	
	        if((corners & (CairoCorners.BottomLeft | CairoCorners.BottomRight)) == 0 && topBottomFallsThrough) {
	            h += r;
	            cr.line_to(x + w, y + h);
	            cr.move_to(x, y + h);
	            cr.line_to(x, y + r);
	            cr.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
	        } else {
	            if((corners & CairoCorners.BottomRight) != 0) {
	                cr.arc(x + w - r, y + h - r, r, 0, Math.PI * 0.5);
	            } else {
	                cr.line_to(x + w, y + h);
	            }
	
	            if((corners & CairoCorners.BottomLeft) != 0) {
	                cr.arc(x + r, y + h - r, r, Math.PI * 0.5, Math.PI);
	            } else {
	                cr.line_to(x, y + h);
	            }
	
	            if((corners & CairoCorners.TopLeft) != 0) {
	                cr.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
	            } else {
	                cr.line_to(x, y);
	            }
	        }
	    }
	    
	    public string TZFormatString(double tzdiff)
        {
            string pos = Math.floor(tzdiff).to_string();
            string rmdr = (tzdiff % 1).to_string();
            
            rmdr = rmdr.split(".")[1];
            
            return pos + "." +((rmdr == "" || rmdr == null) ? "0" : rmdr);
        }	
	}
	

	// --------- TZ Database Class ----------------------------------------
	public class TZDb
	{
		public string TZDataFile { get; set; default = "/usr/share/zoneinfo/zone.tab"; }
		public string ISO3166File {get; set; default = "/usr/share/xml/iso-codes/iso_3166.xml"; }			
		private Gee.ArrayList<Location> _Locations = new Gee.ArrayList<Location>();

		public TZDb()
		{
		    ReadTZFile();
		}

		public Location? GetLocationForCity(string city)
		{
		    if ( city != null )
		    {
			    foreach (Location loc in this._Locations)
			    {
				    if ( loc.CityName == city )
				    { return loc; }
			    }
			    return null;
			}
			else
			{ return null; }
		}

        public Location? GetLocationFromZone(string Zone)
        {
            if ( Zone != null && Zone != "" )
            {
                foreach (Location loc in this._Locations)
                {
                    if ( loc.Zone == Zone )
                    { return loc; }
                }
            }
            return null;       
        }
        

        public Gee.ArrayList<Location> Locations { get { return this._Locations; } }

		private void ReadTZFile()
		{
			string datain = gGenFunc.ReadTextFile(TZDataFile);
			Location location;
			string[] country;
            string lng = "", lat="";

            try
            {
			    // loop through the data lines
			    if ( datain.length > 0 )
			    {
				    country = datain.split("\n");

				    // loop through the items on data line
				    foreach( string c in country )
				    {
				        if ( c.substring(0,1) != "#" && c != "" )
				        {
				            location = new Location();

					        string[] data = c.split("\t", 6);

				        	string coord = data[1];

                            int pos = this.StringFind(coord, "-", 1); 
                            
				        	if ( pos == -1 )
				        	{ pos = this.StringFind(coord, "+", 1); }

                            if ( pos != -1 )
                            {
                                lat = coord.substring(0, pos);
                                lng = coord.substring(pos, -1);
                            }
				        	else
				        	{
				        	    lat = coord;
				        	    lng = "+0";
				        	}

                            location.CountryCode = data[0];
                            location.CountryName = data[2];
                            location.Zone = data[2];
                            location.CityName = data[2].split("/")[1];
                            location.Comment = (data[3] != null) ? data[3] : "";
                            
				            location.Latitude = ParsePosition(lat, 2);
				            location.Longitude = ParsePosition(lng, 3);

                            this._Locations.add(location);
				        }
				    }
				} 
			}
			catch ( GLib.Error e )
			{ GeneralFunctions.LogIt("%s\n".printf( e.message ) ); }
		}


        
        private double ParsePosition(string position, int wholedigits)
        {
            string ws, fs;
            double w, f;

            if ( position == "" || position.length < 4 || wholedigits > 9)
            { return 0.0; }

            ws = position.substring(0, wholedigits + 1);
            fs = position.substring(wholedigits + 1, -1);

            w = double.parse(ws);
            f = double.parse(fs);

            if ( w >= 0.0 )
            {   return w + f / Math.pow(10.0, fs.length); }
            else
            { return w - f / Math.pow(10.0, fs.length); } 
        }

        private int StringFind(string st, string chr, int start)
        {
            for ( int i=start;i<st.length;i++ ) 
            {
                string s = st.substring(i,1);
                if ( s == chr )
                { return i; } 
            }
            return -1;
        }
	}

	// --------- Location Class ----------------------------------------
	public class Location
	{
		// private vars
        private Oobs.TimeConfig _tc = (Oobs.TimeConfig)Oobs.TimeConfig.get();
        
        // public properties
		public double Longitude { get; set; }
		public double Latitude { get; set; }

		public string CountryCode { get; set; }
		public string CountryName { get; set; }
		public string CityName { get; set; }
		public string Comment { get; set; }
        public string Zone { get; set; } 
        public Time LocalTime { get; set; }
        
        // returns offset as TZ offset hrs e.g  5.5/3.0
        public double UtcOffset() 
        {   
            // set the timezone to this location
            Environment.set_variable("TZ", this.Zone, true);
            
            // Time config variables, bit of fudge as this causes compiler warnings
            // can be ignored but the TZ won't refresh until this call
            int yr = 0, mnth = 0, day = 0, hr= 0, min = 0, sec = 0;
            this._tc.get_time(yr, mnth, day, hr, min, sec);
            
            // get the local time
            TimeVal tv = TimeVal();
            tv.get_current_time();
            Time local = Time.local((time_t)tv.tv_sec);
            this.LocalTime = local;
            
            // get the diff between GMT and local
            long gmt =  (long)Time.gm( (time_t) tv.tv_sec).mktime();
            long lcl = (long)this.LocalTime.mktime();

            
            // return the offset from GMT in hours
            double offset = ((double)(lcl - gmt)) / 60 / 60;
            
            return offset;
        }

        public int RawUTCOffsetDays()
        {
            double offsethrs = UtcOffset();
            return (int)(offsethrs / 24);
        }

        public int RawUTCOffsetMinutes()
        {
            double offsetsecs = UtcOffset(); 
            return (int)(offsetsecs * 60); 
        }
            
        
        public int RawUTCOffsetSeconds()
        {
            return (int)(this.UtcOffset() * 60 * 60);
        }

		public void Location()
		{ }
	}
	

	// -------- COLOURMAP wrapper class -----------------------------
	public class ColourMap : GLib.Object, Iterable<Colour>
	{
		private Gee.ArrayList<Colour> _colours = new Gee.ArrayList<Colour>();

		public ColourMap.WithDetail(string offset, int a, int b, int c, int d)
		{ this.AddColourMap(offset, a, b, c, d); }
		
		public void AddColourMap(string offset, int a, int b, int c, int d)
		{
			Colour colour = new Colour();
			colour.Offset = offset;
			colour.DataA = a;
			colour.DataB = b;
			colour.DataC = c;
			colour.DataD = d;
			this._colours.add(colour);
		}

		public Colour? GetOffsetColour(string offset)
		{
			foreach ( Colour c in this._colours )
			{
				if ( c.Offset == offset )
				{ return c; }
			}
			return null;
		}
		
		public Type element_type
		{  get { return typeof (Colour); } }
		
		public Gee.Iterator<Colour> iterator()
		{ return this._colours.iterator(); }
	}
	
	
	// colour class
	public class Colour
	{
	    public string Offset { get; set; }
	    public int DataA { get; set; }
	    public int DataB { get; set; }
	    public int DataC { get; set; }
	    public int DataD { get; set; }

	    public Colour()
	    { }

	    public Colour.WithValues(string offset, int a, int b, int c, int d)
	    {
	        this.Offset = offset;
	        this.DataA = a;
	        this.DataB = b;
	        this.DataC = c;
	        this.DataD = d;
	    }
	}

	public class TZDistance : GLib.Object, Comparable<TZDistance>
	{
	    public double Distance { get; set; }
	    public Location Loc { get; set; }
	    public bool SameContext { get; set; } 
	    
	    public TZDistance(double Dist, Location loc, bool samecontext)
	    {
	        this.Distance = Dist;
	        this.Loc = loc;
	        this.SameContext = samecontext;
	    }
	    
        public int compare_to(TZDistance comp)
        {
            if (this.Distance < comp.Distance) 
            { return -1; }
            
            if (this.Distance > comp.Distance) 
            { return 1; }
            
            return 0;            
        }
	}
}