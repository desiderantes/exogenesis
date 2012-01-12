using Gtk;
using Gee;

namespace Exogenesis
{
    public class MainWin : Gtk.Window
    {
        private int CurrentIndex = 0;
        private Gee.ArrayList<WindowItem> WindowList = new Gee.ArrayList<WindowItem>();
                
        // public references to allow window-window calls
        public FWelcome fWelcome = new FWelcome();
        public FTimeZone fTimezone = new FTimeZone();
		public FHDConfigBasic fHDConfigBasic = new FHDConfigBasic();
		
		
		private Gtk.Box _boxMain = new Gtk.Box( Gtk.Orientation.VERTICAL, 0  );
		
       /* public FHDConfig fHDConfig = new FHDConfig();
        public FUserConfig fUserConfig = new FUserConfig();
        public FLocale fLocale = new FLocale();
        public FConfirm fConfirm = new FConfirm();
        public FInstall fInstall = new FInstall();
        public FComplete fComplete = new FComplete(); */

        public MainWin()
        {
			// this.add( new Gtk.Box( Gtk.Orientation.horizontal, 0) );
            base.set_type_hint(Gdk.WindowTypeHint.NORMAL);
            base.set_position( WindowPosition.CENTER_ALWAYS );

            WindowList.add( new WindowItem(0, fWelcome  ));
            WindowList.add( new WindowItem(1, fTimezone ));
			WindowList.add( new WindowItem(2, fHDConfigBasic ));
          /*  WindowList.add( new WindowItem(2, fHDConfig ));
            WindowList.add( new WindowItem(3, fUserConfig ));    
            WindowList.add( new WindowItem(4, fLocale ));
            WindowList.add( new WindowItem(5, fConfirm ));
            WindowList.add( new WindowItem(6, fInstall ));
            WindowList.add( new WindowItem(7, fComplete )); */

            WindowList.sort();

			this.add( this._boxMain );
			
            this._boxMain.pack_start ( WindowList[CurrentIndex].LayoutData, true, true, 0 );
            this.SetSize( WindowList[CurrentIndex].LayoutData );
			this.show_all ();
		}

        private void SetSize(Gtk.Box layout)
        {
            this.width_request = layout.width_request;
            this.height_request = layout.height_request;
        }

        public void ShowNextWindow()
        {
            if ( CurrentIndex < WindowList.size)
            { 
				this._boxMain.remove( WindowList[CurrentIndex].LayoutData );
				//WindowList[CurrentIndex].LayoutData.reparent(this._boxHold);
				CurrentIndex += 1;
              	// this._boxMain.pack_start ( WindowList[CurrentIndex].LayoutData, true, true, 0 );
				this._boxMain.add ( WindowList[CurrentIndex].LayoutData );
                this.SetSize(WindowList[CurrentIndex].LayoutData);
                this.show_all();
            }
        }

		public void DisplayWindow( Gtk.Box layout )
		{
			this._boxMain.remove( WindowList[CurrentIndex].LayoutData );
			this._boxMain.add ( layout );
			this.SetSize( layout );
			this.show_all();
		}
        public void ShowPreviousWindow()
        {
            if ( CurrentIndex > 0 )
            {
                this._boxMain.remove( WindowList[CurrentIndex].LayoutData );
				CurrentIndex -= 1;
				//this._boxMain.pack_start ( WindowList[CurrentIndex].LayoutData, false, false, 0 );
				this._boxMain.add ( WindowList[CurrentIndex].LayoutData );
             	this.SetSize(WindowList[CurrentIndex].LayoutData);
                this.show_all();
            }               
        }

        public void Cancel()
        {
            Gtk.MessageDialog msg = new Gtk.MessageDialog (
            null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
            "Do you really wish to cancel and quit?");
            Gtk.ResponseType res = (Gtk.ResponseType)msg.run();
            
            if (res == Gtk.ResponseType.YES) 
            { Gtk.main_quit(); }
            else
            { msg.destroy(); }
        }
        
        
        public override void show_all()
        {
            this.visible = true;
            base.show_all();
        }
    }

    //public class WindowItem : GLib.Object, Comparable<WindowItem>
    public class WindowItem : Gtk.Widget, Comparable<WindowItem>
    {

		public int Index 					{ get; set; }

		public Gtk.Box LayoutData  			{ get; set; }

		
        public WindowItem(int index, Gtk.Box layout )
        {
            this.Index = index;
            this.LayoutData = layout;
        }

	
        public int compare_to(WindowItem comp)
        {
            if (this.Index < comp.Index) 
            { return -1; }
            
            if (this.Index > comp.Index) 
            { return 1; }
            
            return 0;            
        }
    }
}