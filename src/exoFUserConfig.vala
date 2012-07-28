using Gtk;
using GLib;
using Gst;
using Gdk;
// using GUdev;
using Cairo;

namespace Exogenesis
{
    public class FUserConfig: Gtk.Box
    {
        // exo objects
        private exoXml _xmlhandler = new exoXml();

        // gstreamer objects
        private Pipeline _pipeline;
        private Element _src;
        private Element _sink;

        // glade widgets
        private Gtk.Window _UIDPopup;
        private Gtk.Label lblUserInfo;
        private Gtk.Label lblUserName;
        private Gtk.Entry txtUserName;
        private Gtk.Label lblUserFullName;
        private Gtk.Entry txtUserFullName;
        private Gtk.Label lblUserPwd1;
        private Gtk.Entry txtUserPwd1;
        private Gtk.Entry txtUserPwd2;
        private Gtk.Label lblUserPwdInst;
        private Gtk.Label lblUserPwdStrength;
        private Gtk.Label lblUserPwdMatch;
        private Gtk.RadioButton rdoUserNoPassword;
        private Gtk.RadioButton rdoUserPasswordRequired;
        private Gtk.RadioButton rdoUserPwdDecrypt;
        private Gtk.Label lblUserFace;
        private Gtk.Alignment algUserGrab;
        private Gtk.Button btnUserGrabImg;
        private Gtk.Button btnUserClear;
        private Gtk.Button btnUserNext;
        private Gtk.Button btnUserCancel;
        private Gtk.Button btnUserPrevious;
        private Gtk.Button btnUserFaceStk;
        private Gtk.DrawingArea dwgCapture;
        private Gtk.Image imgMissingFN;
        private Gtk.Image imgMissingUN;
        private Gtk.Image imgUserPwd1Err;
        private Gtk.Image imgUserPwd2Err;
		private Gtk.Box fxdUserDetails;
		private Gtk.Button btnUserSetUID;

        // focus list
        private GLib.List<Gtk.Widget> _Focus = new GLib.List<Gtk.Widget>();

        // module vars
        private bool _CapRunning = false;

        // Build the form and connect the control references
        protected virtual void Build()
        {
            try
            {
         // get the glade details for control layout
                Gtk.Builder builder = new Gtk.Builder();
                //builder.add_from_file( UIPath );
				builder.add_from_file( "%s/src/exogenesis.ui".printf( AppPath ) );
                stdout.printf("ADDING IT FROM THE FILE");
                // get the main window
                this.fxdUserDetails = (Gtk.Box) builder.get_object("boxUserConfig");
                this._UIDPopup = (Gtk.Window) builder.get_object("exoUIDPopup");
                
                // create the controls
                this.lblUserInfo = (Gtk.Label) builder.get_object("lblUserInfo");
                this.lblUserName = (Gtk.Label) builder.get_object("lblUserName");
                this.txtUserName = (Gtk.Entry) builder.get_object("txtUserName");
                this.lblUserFullName = (Gtk.Label) builder.get_object("lblUserFullName");
                this.txtUserFullName = (Gtk.Entry) builder.get_object("txtUserFullName");
                this.lblUserPwd1 = (Gtk.Label) builder.get_object("lblUserPwdInfo");
                this.txtUserPwd1 = (Gtk.Entry) builder.get_object("txtUserPwd1");
                this.txtUserPwd2 = (Gtk.Entry) builder.get_object("txtUserPwd2");
                this.lblUserPwdInst = (Gtk.Label) builder.get_object("lblUserPwdInst");
                this.lblUserPwdStrength = (Gtk.Label) builder.get_object("lblUserPwdStrength");
                this.lblUserPwdMatch = (Gtk.Label) builder.get_object("lblUserPwdMatch");
                this.rdoUserNoPassword = (Gtk.RadioButton) builder.get_object("rdoUserNoPassword");
                this.rdoUserPasswordRequired = (Gtk.RadioButton) builder.get_object("rdoUserPasswordRequired");
                this.rdoUserPwdDecrypt = (Gtk.RadioButton) builder.get_object("rdoUserPwdDecrypt");
                this.lblUserFace = (Gtk.Label) builder.get_object("lblUserFace");
                this.algUserGrab = (Gtk.Alignment) builder.get_object("algUserGrab");
                this.btnUserGrabImg = (Gtk.Button) builder.get_object("btnUserGrabImg");
                this.btnUserClear = (Gtk.Button) builder.get_object("btnUserClear");
                this.btnUserNext = (Gtk.Button) builder.get_object("btnUCNext");
                this.btnUserCancel = (Gtk.Button) builder.get_object("btnUserCancel");
                this.btnUserPrevious = (Gtk.Button) builder.get_object("btnUCPrevious");
                this.btnUserFaceStk = (Gtk.Button) builder.get_object("btnUserFaceStk");
                this.dwgCapture = (Gtk.DrawingArea) builder.get_object("dwgCapture");
                this.imgMissingFN = (Gtk.Image) builder.get_object("imgUserMissingFN");
                this.imgMissingUN = (Gtk.Image) builder.get_object("imgUserMissingUN");
                this.imgUserPwd1Err = (Gtk.Image) builder.get_object("imgUserPwd1Err");
                this.imgUserPwd2Err = (Gtk.Image) builder.get_object("imgUserPwd2Err");
                this.btnUserSetUID = (Gtk.Button) builder.get_object("btnUserSetUID");

                // wire up the events - button clicks
                this.btnUserGrabImg.clicked.connect ( this.OnBtnUserGrabImg_Clicked );
                this.btnUserClear.clicked.connect ( this.OnBtnUserClear_Clicked );
                this.btnUserNext.clicked.connect ( this.OnBtnUserNext_Clicked );
                this.btnUserPrevious.clicked.connect ( this.OnBtnUserPrevious_Clicked );
                this.btnUserCancel.clicked.connect ( this.OnBtnUserCancel_Clicked );
                this.btnUserFaceStk.clicked.connect ( this.OnBtnUserFaceStk_Clicked );
                this.btnUserSetUID.clicked.connect ( this.OnbtnUserSetUID_Clicked );
                this.fxdUserDetails.realize.connect ( this.OnFxdUserDetails_Realize );
                
                // wire up the events - focus control
                this.txtUserFullName.focus_in_event.connect ( this.OntxtUserFullName_Focus );
                this.txtUserFullName.focus_out_event.connect ( this.OntxtUserFullName_LostFocus );
                
                this.txtUserName.focus_in_event.connect ( this.OntxtUserName_Focus );
				this.txtUserName.focus_out_event.connect ( this.OntxtUserName_LostFocus );
				
				this.txtUserPwd1.focus_in_event.connect ( this.OntxtUserPwd1_Focus );
				this.txtUserPwd1.focus_out_event.connect ( this.OntxtUserPwd1_LostFocus );
				this.txtUserPwd1.key_release_event.connect ( this.OntxtUserPwd1_Keypress );
				
				this.txtUserPwd2.focus_in_event.connect ( this.OntxtUserPwd2_Focus );
				this.txtUserPwd2.focus_out_event.connect ( this.OntxtUserPwd2_LostFocus );				
				this.txtUserPwd2.key_release_event.connect ( this.OntxtUserPwd2_Keypress );

                // set the focus chain
                SetFocusChain();

				this.rdoUserPasswordRequired.active = true;

                // show the form
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

        // main class constructor
        public FUserConfig()
        {  
            this.Build();
            this.ConfigGStreamer();
            this.add(fxdUserDetails);
        }
    
        // check if any users have been found on the disks
        private void CheckExistingUsers()
        {
            if ( gPreviousOS.ExistingUsersCount > 0 )
            { 
                Gtk.ResponseType res = gGenFunc.ShowDialogue("Exogenesis: Users Found",
                                      "Existing users have been found on a previous linux installation\nDo you wish to migrate them?",
                                      Gtk.ButtonsType.YES_NO,
                                      Gtk.MessageType.QUESTION);
                                      
                // check what to do and just do it!(tm)
                if ( res == Gtk.ResponseType.YES )
                {
                    // show the users from import
                //    GeneralFunctions.ShowWindow(new FExistingUsers(), "Exogenesis", true);
                }
            }
        }

        // Set the focus chain for the widgets
        private void SetFocusChain()
        {
            // focus chain
            this._Focus.append(this.txtUserFullName);
            this._Focus.append(this.txtUserName);
            this._Focus.append(this.txtUserPwd1);
            this._Focus.append(this.txtUserPwd2);
            this._Focus.append(this.rdoUserNoPassword);
            this._Focus.append(this.rdoUserPasswordRequired);
            this._Focus.append(this.rdoUserPwdDecrypt);
            this._Focus.append(this.btnUserNext);
            this._Focus.append(this.btnUserPrevious);
            this._Focus.append(this.btnUserCancel);
            this._Focus.append(this.btnUserGrabImg);
            this._Focus.append(this.btnUserFaceStk);
            this._Focus.append(this.btnUserClear);

            this.fxdUserDetails.set_focus_chain(_Focus);
        }

        private void ConfigGStreamer () 
        {
            this._pipeline = (Pipeline) new Pipeline ("mypipeline");
            this._src = ElementFactory.make ("v4l2src", "video0");
            this._sink = ElementFactory.make ("xvimagesink", "sink");
            this._pipeline.add_many (this._src, this._sink);
            this._src.link (this._sink);
        }


        private bool ValidateEntry()
        {
            string msg = "Please enter the required information";
            bool ok = true;

            if ( this.txtUserFullName.text.length == 0 )
            { 
                this.imgMissingFN.visible = true;
                ok = false; 
            }
            else
            { this.imgMissingFN.visible = false; }
            
            if ( this.txtUserName.text.length == 0 )
            { 
                this.imgMissingUN.visible = true;
                ok = false; 
            }
            else
            { this.imgMissingUN.visible = false; }
            
            if ( this.txtUserPwd1.text.length == 0 )
            { 
                this.imgUserPwd1Err.visible = true;
                ok = false; 
            }
            else
            { this.imgUserPwd1Err.visible = false; }

            if ( this.txtUserPwd2.text.length == 0 )
            { 
                this.imgUserPwd2Err.visible = true;
                ok = false; 
            }
            else
            { this.imgUserPwd2Err.visible = false; }
            
            if ( this.txtUserPwd1.text != this.txtUserPwd2.text )
            {
	            this.imgUserPwd2Err.visible = true;
	           	ok = false;
            }
            else
            {this.imgUserPwd2Err.visible = false; }
            return ok;
        }

        // Grab image from webcam stream
        public Gdk.Pixbuf? GrabCamImage()
        {
            Gdk.Pixbuf pic = Gdk.pixbuf_get_from_window( dwgCapture.get_parent_window(), 
                                                         0, 0, 0, 0);
            if ( pic != null )
            { return pic; }
            else
            { return null; }
        }
        
        // clear the drawing area
        private void ClearDrawingArea()
        {
            // stop the webcam if running
            if ( this._pipeline.current_state == State.PLAYING )
            { 
                this._pipeline.set_state ( State.NULL );
                this._CapRunning = false; 
            }
            this.dwgCapture.get_parent_window().flush();
        }
        
        // load an image into the drawing area, scale to fit
        private void SetImage(Gdk.Pixbuf image)
        {
			
            if ( image != null )				
            {
                //Gdk.Pixbuf pic = image.scale_simple(150, 125, Gdk.InterpType.BILINEAR); 
				//Context cr = cairo_create((Gtk.Window)this.dwgCapture.get_window());
				//Context cr = cairo_create(this.dwgCapture.window);

				var cr = Gdk.cairo_create (this.dwgCapture.get_window());
				cairo_set_source_pixbuf (cr, image, image.get_width(),image.get_height()); 
				cr.paint();
				this.dwgCapture.draw(cr);

				

				/*this.dwgCapture.get_parent_window().draw_pixbuf(new Gdk.GC(dwgCapture.get_parent_window()), 
													pic, 0, 0, 0, 0, 
                                                   pic.get_width(), 
                                                   pic.get_height(), 
                                                   Gdk.RgbDither.NONE, 
                                                   0,0); 
*/
				//Context cr2 = cairo_create(this.dwgCapture.get_parent_window());
				//cairo_set_source_pixbuf (cr2, pic, pic.get_width(),pic.get_height()); 
				//cr2.paint();
				//delete cr;
            }
        }

// EVENTS -------------------------------------------------------------------------------------------------------------------

        public void OnFxdUserDetails_Realize()
        { this.CheckExistingUsers();}

		public void OnbtnUserSetUID_Clicked(Button button)
		{ this._UIDPopup.show_all(); }

        // event for button
        public void OnBtnUserClear_Clicked(Button button)
        { this.ClearDrawingArea(); }

        // event for button
        public void OnBtnUserFaceStk_Clicked(Button button)
        {
            // prompt to select a file
            Gtk.FileChooserDialog dlg = new Gtk.FileChooserDialog("Select an Image file", null, Gtk.FileChooserAction.OPEN);
            dlg.add_button(Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
            dlg.add_button(Gtk.Stock.OK, Gtk.ResponseType.OK);
            Gtk.ResponseType res = (Gtk.ResponseType)dlg.run();
            
            // check if the user clicked cancel or ok
            if ( res == Gtk.ResponseType.OK )
            { 
				stdout.printf("I am in the if statement\n");
                this.ClearDrawingArea(); 
                string file = dlg.get_filename();
                if ( file.length > 0 )
                {
					stdout.printf("I am in the if statement that says the file length is more then %s\n", file);
                    /*Gtk.Image img = new Gtk.Image();
                    img.file = file;
                    Gdk.Pixbuf pxb = img.get_pixbuf();
                    this.SetImage ( pxb );
                    img.destroy();
					*/
					//Gtk.Image img = new Gtk.Image.from_file(file);
					//this.SetImage (img.get_pixbuf());
					//img.destroy();
					Gtk.Image image = new Gtk.Image.from_file(file);
					this.SetImage(image.get_pixbuf());
                }
            }
            // kill the object
			stdout.printf("Killing the object\n");
            dlg.destroy();
        }
        
        // event for button
        public void OnBtnUserGrabImg_Clicked(Button button)
        { 
			
        	if ( ! this._CapRunning )
            {
		     	((XOverlay) this._sink).set_xwindow_id(Gdk.X11Window.get_xid(this.dwgCapture.get_window()));
				this._pipeline.set_state ( State.PLAYING );
                this._CapRunning = true; 
            }
            else
            {
                this._pipeline.set_state ( State.PAUSED );
                Gdk.Pixbuf img = this.GrabCamImage ();
                this._pipeline.set_state( State.NULL );
                this.SetImage ( img );
                this._CapRunning = false;
            }
           
        }
        // event for button
		public void OnBtnUserNext_Clicked(Button button)
        { 
            if ( this.ValidateEntry() )
            {
                UserDetail ud = new UserDetail();                
                ud.Fullname = this.txtUserFullName.text;
                ud.Username = this.txtUserName.text;
                ud.Password = this.txtUserPwd1.text;
                ud.EncryptHome = this.rdoUserPwdDecrypt.active;
                ud.AutoLogon = this.rdoUserNoPassword.active;
                ud.RequirePassword = this.rdoUserPasswordRequired.active;
				ud.MainAccount = true;
                gInstallData.AddUser(ud);

                // show the next screen if data requirements met
                ((MainWin)this.parent).ShowNextWindow();
            }
        }

        // event for button
        public void OnBtnUserPrevious_Clicked(Button button)
        { ((MainWin)this.parent).ShowPreviousWindow(); }

        // event for button
        public void OnBtnUserCancel_Clicked(Button button)
        { ((MainWin)this.parent).Cancel(); }
        
        public bool OntxtUserFullName_Focus()
        {
	        this.lblUserFullName.sensitive = true;
	        return false;
        }
        
        public bool OntxtUserFullName_LostFocus()
        {
	        this.lblUserFullName.sensitive = false;
	        return false;
        }

        public bool OntxtUserName_Focus()
        {
	        this.lblUserName.sensitive = true;
	        return false;
        }
        
        public bool OntxtUserName_LostFocus()
        {
	        this.lblUserName.sensitive = false;
	        return false;
        }

        public bool OntxtUserPwd1_Focus()
        {
	        this.lblUserPwd1.sensitive = true;
	        this.lblUserPwdInst.sensitive = true;

	        if ( this.txtUserPwd1.text.length == 0 || 
	             this.txtUserPwd2.text.length == 0 )
	        { this.lblUserPwdMatch.label = "Not Matched"; }
	        this.lblUserPwdMatch.visible = true;
	        return false;
        }

        public bool OntxtUserPwd1_LostFocus()
        {
	        this.lblUserPwd1.sensitive = false;
	        this.lblUserPwdInst.sensitive = false;
	        this.lblUserPwdMatch.visible = false;
	        return false;
        }

        public bool OntxtUserPwd2_Focus()
        {
	        this.lblUserPwd1.sensitive = true;
	        this.lblUserPwdInst.sensitive = true;

	        if ( this.txtUserPwd1.text.length == 0 || 
	             this.txtUserPwd2.text.length == 0 )
	        { this.lblUserPwdMatch.label = "Not Matched"; }	        
	        this.lblUserPwdMatch.visible = true;
	        return false;
        }

        public bool OntxtUserPwd2_LostFocus()
        {
	        this.lblUserPwd1.sensitive = false;
	        this.lblUserPwdInst.sensitive = false;
	        this.lblUserPwdMatch.visible = false;
	        return false;
        }
        
        public bool OntxtUserPwd1_Keypress(Gdk.EventKey key)
        {
	        if ( this.txtUserPwd1.text != this.txtUserPwd2.text )
	        { this.lblUserPwdMatch.label = "Not Matched"; }
	        else
	        { this.lblUserPwdMatch.label = "Matched";}
	        return false;
        }
        
        public bool OntxtUserPwd2_Keypress(Gdk.EventKey key)
        {
	        if ( this.txtUserPwd1.text != this.txtUserPwd2.text)
	        { this.lblUserPwdMatch.label = "Not Matched"; }
	        else
	        { this.lblUserPwdMatch.label = "Matched";}
	        return false;
        }        
    }
}