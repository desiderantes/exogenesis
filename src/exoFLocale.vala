using Gtk;
using GLib;
using Gdk;

namespace Exogenesis
{
    public class FLocale : Gtk.Layout
    {
        // controls (assigned from glade)
        private Gtk.Fixed fxdLocale;
        private Gtk.Button btnPrevious;
        private Gtk.Button btnNext;
        private Gtk.Button btnCancel;
        private Gtk.ComboBox cboCountry;
        private Gtk.ComboBox cboVariant;
        private Gtk.Entry txtTester;
        private Gtk.Label lblKC49;
        private Gtk.Label lblKC10;
        private Gtk.Label lblKC11;
        private Gtk.Label lblKC12;
        private Gtk.Label lblKC13;
        private Gtk.Label lblKC14;
        private Gtk.Label lblKC15;
        private Gtk.Label lblKC16;
        private Gtk.Label lblKC17;
        private Gtk.Label lblKC18;
        private Gtk.Label lblKC19;
        private Gtk.Label lblKC20;
        private Gtk.Label lblKC21;
        private Gtk.Label lblKC22;
        private Gtk.Label lblKC23;
        private Gtk.Label lblKC24;
        private Gtk.Label lblKC25;
        private Gtk.Label lblKC26;
        private Gtk.Label lblKC27;
        private Gtk.Label lblKC28;
        private Gtk.Label lblKC29;
        private Gtk.Label lblKC30;
        private Gtk.Label lblKC31;
        private Gtk.Label lblKC32;
        private Gtk.Label lblKC33;
        private Gtk.Label lblKC34;
        private Gtk.Label lblKC35;
        private Gtk.Label lblKC36;
        private Gtk.Label lblKC66;
        private Gtk.Label lblKC38;
        private Gtk.Label lblKC39;
        private Gtk.Label lblKC40;
        private Gtk.Label lblKC41;
        private Gtk.Label lblKC42;
        private Gtk.Label lblKC43;
        private Gtk.Label lblKC44;
        private Gtk.Label lblKC45;
        private Gtk.Label lblKC46;
        private Gtk.Label lblKC47;
        private Gtk.Label lblKC48;
        private Gtk.Label lblKC51;
        private Gtk.Label lblKC50;
        private Gtk.Label lblKC94;
        private Gtk.Label lblKC52;
        private Gtk.Label lblKC53;
        private Gtk.Label lblKC54;
        private Gtk.Label lblKC55;
        private Gtk.Label lblKC56;
        private Gtk.Label lblKC57;
        private Gtk.Label lblKC58;
        private Gtk.Label lblKC59;
        private Gtk.Label lblKC60;
        private Gtk.Label lblKC61;
        private Gtk.Button btnRefresh;
        private Gtk.Image imgKeyboard;
        
        // local vars
        private ListStore _Countries = new ListStore(3, typeof(string), typeof(string), typeof(KbCountry) ); // display, country code, country object
        private ListStore _Variants = new ListStore(3, typeof(string), typeof(string), typeof(string) );   // display, variant code, country code

        Gdk.Keymap _gkm = Gdk.Keymap.get_default();        

        protected virtual void Build()
        {
            try
            {
                // get the glade details for control layout
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                // get the main window
                this.fxdLocale = (Gtk.Fixed) builder.get_object("fxdLocale");
                this.btnPrevious = (Gtk.Button) builder.get_object("btnLocalePrevious");
                this.btnNext = (Gtk.Button) builder.get_object("btnLocaleNext");
                this.btnCancel = (Gtk.Button) builder.get_object("btnLocaleCancel");
                this.cboCountry = (Gtk.ComboBox) builder.get_object("cboLocaleCountry");
                this.cboVariant = (Gtk.ComboBox) builder.get_object("cboLocaleLayout");
                this.txtTester = (Gtk.Entry) builder.get_object("txtTester");
                this.lblKC49 = (Gtk.Label) builder.get_object("lblKC49");
                this.lblKC10 = (Gtk.Label) builder.get_object("lblKC10");
                this.lblKC11 = (Gtk.Label) builder.get_object("lblKC11");
                this.lblKC12 = (Gtk.Label) builder.get_object("lblKC12");
                this.lblKC13 = (Gtk.Label) builder.get_object("lblKC13");
                this.lblKC14 = (Gtk.Label) builder.get_object("lblKC14");
                this.lblKC15 = (Gtk.Label) builder.get_object("lblKC15");
                this.lblKC16 = (Gtk.Label) builder.get_object("lblKC16");
                this.lblKC17 = (Gtk.Label) builder.get_object("lblKC17");
                this.lblKC18 = (Gtk.Label) builder.get_object("lblKC18");
                this.lblKC19 = (Gtk.Label) builder.get_object("lblKC19");
                this.lblKC20 = (Gtk.Label) builder.get_object("lblKC20");
                this.lblKC21 = (Gtk.Label) builder.get_object("lblKC21");
                this.lblKC22 = (Gtk.Label) builder.get_object("lblKC22");
                this.lblKC23 = (Gtk.Label) builder.get_object("lblKC23");
                this.lblKC24 = (Gtk.Label) builder.get_object("lblKC24");
                this.lblKC25 = (Gtk.Label) builder.get_object("lblKC25");
                this.lblKC26 = (Gtk.Label) builder.get_object("lblKC26");
                this.lblKC27 = (Gtk.Label) builder.get_object("lblKC27");
                this.lblKC28 = (Gtk.Label) builder.get_object("lblKC28");
                this.lblKC29 = (Gtk.Label) builder.get_object("lblKC29");
                this.lblKC30 = (Gtk.Label) builder.get_object("lblKC30");
                this.lblKC31 = (Gtk.Label) builder.get_object("lblKC31");
                this.lblKC32 = (Gtk.Label) builder.get_object("lblKC32");
                this.lblKC33 = (Gtk.Label) builder.get_object("lblKC33");
                this.lblKC34 = (Gtk.Label) builder.get_object("lblKC34");
                this.lblKC35 = (Gtk.Label) builder.get_object("lblKC35");
                this.lblKC36 = (Gtk.Label) builder.get_object("lblKC36");
                this.lblKC66 = (Gtk.Label) builder.get_object("lblKC66");
                this.lblKC38 = (Gtk.Label) builder.get_object("lblKC38");
                this.lblKC39 = (Gtk.Label) builder.get_object("lblKC39");
                this.lblKC40 = (Gtk.Label) builder.get_object("lblKC40");
                this.lblKC41 = (Gtk.Label) builder.get_object("lblKC41");
                this.lblKC42 = (Gtk.Label) builder.get_object("lblKC42");
                this.lblKC43 = (Gtk.Label) builder.get_object("lblKC43");
                this.lblKC44 = (Gtk.Label) builder.get_object("lblKC44");
                this.lblKC45 = (Gtk.Label) builder.get_object("lblKC45");
                this.lblKC46 = (Gtk.Label) builder.get_object("lblKC46");
                this.lblKC47 = (Gtk.Label) builder.get_object("lblKC47");
                this.lblKC48 = (Gtk.Label) builder.get_object("lblKC48");
                this.lblKC51 = (Gtk.Label) builder.get_object("lblKC51");
                this.lblKC50 = (Gtk.Label) builder.get_object("lblKC50");
                this.lblKC94 = (Gtk.Label) builder.get_object("lblKC94");
                this.lblKC52 = (Gtk.Label) builder.get_object("lblKC52");
                this.lblKC53 = (Gtk.Label) builder.get_object("lblKC53");
                this.lblKC54 = (Gtk.Label) builder.get_object("lblKC54");
                this.lblKC55 = (Gtk.Label) builder.get_object("lblKC55");
                this.lblKC56 = (Gtk.Label) builder.get_object("lblKC56");
                this.lblKC57 = (Gtk.Label) builder.get_object("lblKC57");
                this.lblKC58 = (Gtk.Label) builder.get_object("lblKC58");
                this.lblKC59 = (Gtk.Label) builder.get_object("lblKC59");
                this.lblKC60 = (Gtk.Label) builder.get_object("lblKC60");
                this.lblKC61 = (Gtk.Label) builder.get_object("lblKC61");
                this.btnRefresh = ( Gtk.Button) builder.get_object("btnRefresh");
                this.imgKeyboard = ( Gtk.Image ) builder.get_object("imgKeyboard");
                this.imgKeyboard.set_from_file( "%s/locale/keyboard.png".printf(AppPath) );

                // wire the events
                this.btnNext.clicked.connect ( this.OnBtnNext_Click );
                this.btnPrevious.clicked.connect ( this.OnBtnPrevious_Click );
                this.btnCancel.clicked.connect ( this.OnBtnCancel_Click );
                this.cboCountry.changed.connect ( this.OnCboCountry_Changed );
                this.cboVariant.changed.connect ( this.OnCboVariant_Changed );

                // set the size of layout to size of fixed
                this.width_request = this.fxdLocale.width_request;
                this.height_request = this.fxdLocale.height_request;

                // set up Country Combo
                cboCountry.set_model(this._Countries);
                CellRendererText cellCountry = new CellRendererText();
                cboCountry.pack_start(cellCountry, true);
                cboCountry.add_attribute(cellCountry, "text", 0);      

                // set up variant Combo
                cboVariant.set_model(this._Variants);
                CellRendererText cellVariant = new CellRendererText();
                cboVariant.pack_start(cellVariant, true);
                cboVariant.add_attribute(cellVariant, "text", 0);      
                
                // gLanguageManager.OnGConfLayoutChanged.connect ( this.PopulateKeyboard );
                this._gkm.keys_changed.connect( this.OnKeyMap_Changed ); 
                 
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

        public FLocale()
        { 
            this.Build();
            this.add(fxdLocale); 
            this.PopulateCountry();
            this.SetCurrentKeyboard();
        }

        private void SetCurrentKeyboard()
        {
            string kv = gLanguageManager.GetCurrentCountry();
            
            TreeIter iter;
            GLib.Value val;
            this._Countries.get_iter_first(out iter);
            
            do
            {
                this._Countries.get_value(iter ,1 , out val);
                string tv = (string)val;
                
                if (  kv.contains(tv) )
                { break; }

            }
            while ( this._Countries.iter_next(ref iter) );
            
            this.cboCountry.set_active_iter(iter);
        }

        private void PopulateKeyboard()
        {
            Gdk.KeymapKey kmk = Gdk.KeymapKey();
            Gdk.KeymapKey[] kmks;

            foreach ( Gtk.Widget lbl in this.fxdLocale.get_children() )
            {
                if ( lbl.get_type() == typeof(Gtk.Label) && lbl.get_name().contains("lblKC") )
                {
                    Gtk.Label curLabel = (Gtk.Label)lbl;

                    // create the stub keymap object
                    string hwkeycode = curLabel.get_name().substring(5, -1);
                    curLabel.label = "";

                    // populate keymap
                    kmk.keycode = int.parse(hwkeycode);

                    for ( int i = 0; i < 3; i++ )
                    {
                        for ( int j = 0; j < 4; j++ )
                        {
                            kmk.group = i;
                            kmk.level = j;

                            uint keyval = this._gkm.lookup_key(kmk);

                            if ( keyval != 0 )
                            {
                                // get all posible maps for the key in question
                                this._gkm.get_entries_for_keyval(keyval, out kmks);

                                foreach ( Gdk.KeymapKey k in kmks )
                                {
                                    k.keycode = int.parse(hwkeycode);
                                    keyval = this._gkm.lookup_key(k);
                                    unichar chr = (unichar)Gdk.keyval_to_unicode(keyval);
                                    string labeltext = "";

                                    if ( chr.to_string() == "" )
                                    { 
                                        if ( i == 0 && j == 0 )
                                        { labeltext = (string)Gdk.keyval_name(keyval); } 
                                    }
                                    else
                                    { labeltext = chr.to_string(); }

                                    if ( curLabel.label.length == 0 )
                                    { curLabel.label = labeltext; }
                                    else
                                    {
                                        if ( curLabel.label.contains(labeltext ) == false )
                                        {
                                            if ( curLabel.label.length % 3 == 1 )  // odd field
                                            { curLabel.label += " " + "%s".printf(labeltext ); }
                                            else
                                            { curLabel.label +=  "\n%s".printf( labeltext ); }
                                        } 
                                    }
                                }
                            }
                        }
                    }
                }
            }
          //  kmks = null;
        }

        private void PopulateCountry()
        {
            TreeIter iter;
             
            foreach ( KbCountry c in gLanguageManager.Countries )
            {
                this._Countries.append( out iter );
                this._Countries.set (iter, 0, c.Description, 1, c.Name, 2, c, -1);
            }
            this.cboCountry.set_active(0); 
        }

        public void OnCboCountry_Changed()
        {
            TreeIter iter;
            KbCountry country;
            GLib.Value val;

            this.cboCountry.get_active_iter(out iter);
            this._Countries.get_value(iter, 2, out val);            
            country = ( KbCountry )val;

            PopulateVariant(country);
        }

        private void PopulateVariant(KbCountry country)
        {
            TreeIter iter;
            
            this._Variants.clear();
            
            foreach ( KbVariant v in country )
            {
                this._Variants.append ( out iter );
                this._Variants.set ( iter, 0, v.Description, 1, v.Name, 2, country.Name, -1 );
            }
            
            // check if there are variants for keyboard
           /* if ( this._Variants.length > 0 )
            { this.cboVariant.set_active(0); }
            else
            { gLanguageManager.GConfSetLayout(country.Name, ""); } */
        }

        public void OnCboVariant_Changed()
        {
            TreeIter iter;
            string variant;
            string country;
            GLib.Value val;

            this.cboVariant.get_active_iter(out iter);
            this._Variants.get_value( iter, 1, out val );
            variant = (string)val;
            this._Variants.get_value ( iter, 2, out val );
            country = (string)val;

            // change GConf to the new keyboard country/variant setting
            gLanguageManager.GConfSetLayout(country, variant);
        }
        
        private string GetSelectedKeyboard()
        {
            TreeIter iter;
            GLib.Value val;
            
            this.cboCountry.get_active_iter(out iter);
            this._Countries.get_value(iter, 1, out val);
            
            return (string)val; 
        }
        
        private string GetSelectedVariant()
        {
            TreeIter iter;
            GLib.Value val;
            
            this.cboVariant.get_active_iter(out iter);
            this._Variants.get_value ( iter, 1, out val);
            
            return (string)val;
        }    
        
        public void OnBtnNext_Click()
        {
            gInstallData.KeyboardLayout = this.GetSelectedKeyboard();
            gInstallData.KeyboardVariant = this.GetSelectedVariant(); 
            ((MainWin)this.parent).ShowNextWindow(); 
        }

        private void OnKeyMap_Changed()
        { 
          this.PopulateKeyboard(); 
        }

        public void OnBtnPrevious_Click()
        { ((MainWin)this.parent).ShowPreviousWindow(); }

        public void OnBtnCancel_Click()
        { ((MainWin)this.parent).Cancel(); } 
    }
}