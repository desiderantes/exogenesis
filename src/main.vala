using Gtk;
using Gdk;
using Gst;
using Cairo;

namespace Exogenesis
{

    public MainWin exoMainWin;
    Gtk.Window winbkgrd; 

    // Create global control classes
    public HDManager  gHDManager;
    public LanguageManager gLanguageManager;
    public InstallData gInstallData;
    public GeneralFunctions gGenFunc;
    public PreviousOS gPreviousOS;

    // Global Variables
    public string AppPath;
	public bool DebugMode = false;
	
	public const string UIPath = "src/exogenesis.ui";

    public static int main (string[] args)
    {
        Gtk.init (ref args);
        Gst.init (ref args);

		// get the debug mode, if passed
		if ( args.length > 1 )
		{
			if ( args[1] == "DEBUG" )
			{ DebugMode = true; }
		}

        // Set the execution path
        AppPath = GLib.Environment.get_current_dir();

        // control class references (globally available)
        gHDManager = new HDManager();
        gLanguageManager = new LanguageManager();
        gInstallData = new InstallData();
        gGenFunc = new GeneralFunctions();
        gPreviousOS = new PreviousOS();

		if ( ! DebugMode )
        { FadeDesktop(); }

        exoMainWin = new MainWin();
        exoMainWin.title = "Exogenesis";
        exoMainWin.set_transient_for(winbkgrd);
        exoMainWin.destroy.connect (Gtk.main_quit);
        Gtk.main ();    
        return 0;
    }

    public static void FadeDesktop()
    {
       /* winbkgrd = new Gtk.Window(Gtk.WindowType.POPUP);
        winbkgrd.move(0, 0);
        
        Gdk.Screen s = winbkgrd.get_screen(); 
        winbkgrd.decorated = false;
        winbkgrd.app_paintable = true;
        winbkgrd.sensitive = false;
        winbkgrd.can_focus = false;
        winbkgrd.fullscreen();	

      //  winbkgrd.set_source_rgba( s.get_rgba_visual() );
		winbkgrd.set_opacity ( 0.5 );
     //   winbkgrd.expose_event.connect ( w_ExposeEvent ) ;

        winbkgrd.border_width = 20;

        winbkgrd.show(); */        
    }

    public static bool w_ExposeEvent(Gtk.Widget w, Gdk.EventExpose evnt)
    {
      /*  Cairo.Surface sfc = w.get_parent_window().ref_cairo_surface();
        Cairo.Context cr = new Cairo.Context(sfc);
        cr.set_source_rgba(0.0, 0.0, 0.0, 0.5);
        cr.set_operator(Cairo.Operator.SOURCE);
        cr.paint(); */        

        return false;
    }     

    public errordomain XmlError 
    {
        FILE_NOT_FOUND,
        XML_DOCUMENT_EMPTY
    }

    public class Main
    {

    }
}