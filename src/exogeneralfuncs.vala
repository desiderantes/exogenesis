using GLib;
using Gtk;
namespace Exogenesis
{
    public class GeneralFunctions
    {
        private exoXml _xmlH;
        string _CurLang;
		

// -- STATIC METHODS AND PROPERTIES
		
		// array for segbar colours
		private static uint[] _barcolours = { 0xf57900, 0x3465a4, 0x73d216, 0xCA4141, 0x9CF2DE, 0xFFFE8E, 0xA2A2A2, 0xE1E1E1 };
		
        // returns a colour at the given index
        public static uint BarColour(int idx)
        { return _barcolours[idx]; }

		public static double ToDecimal(double x)
		{
			string y = Math.trunc(x).to_string();
			string z = "0." + y;
			stdout.printf("TRUNC = %s\n", z);
			return double.parse(z);
		}
        public static void ShowWindow(Gtk.Box layout, string Title, bool Modal)
        {
			Allocation alloc;
			layout.get_allocation( out alloc );
            Gtk.Window win = new Gtk.Window();
			win.height_request = layout.height_request;
			win.width_request = layout.width_request;
            win.title = Title;
            win.modal = Modal;
            win.add(layout);
            win.set_type_hint(Gdk.WindowTypeHint.NORMAL );
            win.set_transient_for(exoMainWin);
            
            win.set_position(WindowPosition.CENTER_ALWAYS);       
            win.show_all();
            
        }

        public static string Read_UTF8 (string path, out string? encoding = null) throws Error
        {
            string text = null;
            string contents = "";

            FileUtils.get_contents (path, out text, null);
            encoding = Encoding.get_charset (text);
            if (encoding != null)
            {
                contents = Encoding.convert (text, "UTF-8", encoding);
            }
            else
            { 
                contents = "";
                stdout.printf("error encoding"); 
            }
            return contents;
        }
        
        public static string FormatHDSize(uint64 size)
        {
            double gSize = ((double)size) / 1024 / 1024 / 1024;
            string sizetype = "GB";
            
            if ( gSize < 1 )
            {
                gSize = gSize * 1024;  // Megabyte
                sizetype = "MB";
            }
            
            if ( gSize < 1 )
            { 
                gSize = gSize * 1024; // Kilobyte;
                sizetype = "KB";
            }

            gSize = Math.round(gSize);
            
            // return "%s %s".printf(gSize.to_string(), sizetype);
            return Gdu.util_get_size_for_display(size, false, false);
        }
        
        public static void LogIt( string Message )
        {
			stdout.printf(Message);
        }

// -- INSTANCE METHODS ---------------------------------------------------------------------------------------

		// event used to return errors
		public signal void ErrorFound(exoError error);

        // default constructor
        public GeneralFunctions()
        {
            this._xmlH = new exoXml();
            this._CurLang = GetOSCurrentLanguage();
        }

	    public string GetOSCurrentLanguage()
	    { return Environment.get_variable("LANG").split(".")[0]; }

	    public string GetGDMCurrentLanguage()
	    { return Environment.get_variable("GDM_LANG").split(".")[0]; }

	    public bool SetLanguage(string selectedlang)
	    { return true; }

        // Get the text for a control label or label text for current lang
        public string GetLabelText(string formname, string controlname)
        { return this._xmlH.GetText(this._CurLang, formname, controlname); }

        
        public Gtk.ResponseType ShowDialogue(string Title, string Message, Gtk.ButtonsType buttons, Gtk.MessageType type)
        {
            Gtk.MessageDialog msg = new Gtk.MessageDialog (
                                        null, 
                                        Gtk.DialogFlags.MODAL, 
                                        type, 
                                        buttons,
                                        Message);
            msg.set_title(Title);
            msg.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU);
            msg.set_transient_for(exoMainWin);
            msg.set_position(  WindowPosition.CENTER_ALWAYS );       
            Gtk.ResponseType res = (Gtk.ResponseType)msg.run();
            msg.destroy();
            return res; 
        } 

        // read a text file and return as string
       	public string ReadTextFile(string filename)
       	{
	       	GLib.File file = GLib.File.new_for_path(filename);
			StringBuilder sb = new StringBuilder();

	       	try
	       	{	       	
		       	if ( !file.query_exists(null) )
		       	{  
		       		// raise error event
		       		exoError err = new exoError();
		       		err.Number = 1001;
		       		err.Message = "%s not found.".printf(filename);
		       		stdout.printf("%s\n", err.Message);
		       		sb.append("");
		       		ErrorFound(err);
	       		}
		       	else
		       	{
					string line;

			       	// open and read the file
			       	DataInputStream stream = new DataInputStream (file.read (null));

					while ((line = stream.read_line (null, null) ) != null) 
					{  sb.append( "%s\n".printf(line) ); }
		       	}
		       	return sb.str.to_string();
	       	}
	       	catch ( IOError e )
	       	{
		       	exoError err = new exoError();
		       	err.Number = e.code;
		       	err.Message = e.message;
		       	ErrorFound(err);
		       	return "";
	       	}
       	}
       	
    }
    
// --- ERROR CLASS DEFINITION
    public class exoError
    {
	    public int Number { get; set; }
	    public string Message { get; set; }
	    
	    public exoError()
	    { }
    }

// -- FILE PATHS CLASS    
    public class exoFilePaths
    {
	    public static string SupportedLanguages  { get; set; }
	    
	    
    }

// -- ENCODING CONVERSION CLASS
    public class Encoding : GLib.Object
    {
        private const string[] charsets = {"UTF-8", "ISO-8859-15"};

        public static string convert (string text, string to_codeset, string from_codeset) throws Error
        { return GLib.convert (text, -1, to_codeset, from_codeset); }

        public static string get_charset (string text)
        {
            string charset = null;

            foreach (string c in charsets)
            {
                if (Encoding.test (text, c))
                {
                    charset = c;
                    break;
                }
            }
            return charset;
        }

        private static bool test (string text, string charset)
        {
            bool valid = false;

            try
            {
                string convert;

                convert = GLib.convert (text, -1, "UTF-8", charset);
                valid = true;
            }
            catch (Error e)
            { debug (e.message); }
            return valid;
        }
    }

// Adjustment class for size allocations on hard disks
	public class exoSpinAdjust : Gtk.Adjustment
	{
		public exoSpinAdjust ( uint64 maxsize )
		{
//			base.value_changed.connect( this.OnValueChanged );
			base.lower = 0;
			base.page_increment = 10;
			base.page_size = 100;
			base.step_increment = 100;
			base.upper = maxsize;
			base.value = maxsize;
		}

		public void OnValueChanged()
		{
			
		}
	}
}