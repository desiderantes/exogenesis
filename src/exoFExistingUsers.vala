using Gtk;
using Gee;

namespace Exogenesis
{


    public class FExistingUsers : Gtk.Layout
    {
        ListStore _lstUsers = new ListStore( 6, typeof(string), typeof(string), typeof(string), typeof(string), typeof(bool), typeof(bool) );
        Gtk.CellRendererToggle tglUserImport = new Gtk.CellRendererToggle();
        Gtk.CellRendererToggle tglConfigImport = new Gtk.CellRendererToggle();

        Gtk.Fixed fxdEU;
        Gtk.Button btnCancel;
        Gtk.Button btnImport;
        Gtk.TreeView tvwUsers;
        
        public FExistingUsers()
        {
            this.Build();
            this.add( this.fxdEU );
        }
        
        private void Build()
        {
            try
            {
                // get the glade details for control layout
                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file( UIPath );

                this.fxdEU = ( Gtk.Fixed ) builder.get_object("fxdExistingUsers");
                this.btnCancel = ( Gtk.Button ) builder.get_object("btnEUCancel");
                this.btnImport = ( Gtk.Button ) builder.get_object("btnEUImport");
                this.tvwUsers = ( Gtk.TreeView ) builder.get_object("tvwExistingUsers");

                // Set up the treeview
                this.tvwUsers.insert_column_with_attributes (-1, "User ID", new CellRendererText (), "text", 0, null);
                this.tvwUsers.insert_column_with_attributes (-1, "Username", new CellRendererText (), "text", 1, null);
                this.tvwUsers.insert_column_with_attributes (-1, "Home Folder", new CellRendererText (), "text", 2, null);
                this.tvwUsers.insert_column_with_attributes (-1, "Shell",  new CellRendererText (), "text", 3, null);
                this.tvwUsers.insert_column_with_attributes (-1, "Import", this.tglUserImport, "active", 4, null);
                this.tvwUsers.insert_column_with_attributes (-1, "Save Files", this.tglConfigImport, "active", 5, null);
                                
                this.tvwUsers.set_model(this._lstUsers);

                // wire the events
                this.btnCancel.clicked.connect ( OnBtnCancel_Click );
                this.btnImport.clicked.connect ( OnBtnImport_Click );
                this.fxdEU.realize.connect ( OnFxdEU_Realize );
                this.tglUserImport.toggled.connect ( OnTglUserImport_Toggle );
                this.tglConfigImport.toggled.connect ( OnTglConfigImport_Toggle );

                // set the size of layout to size of fixed
                this.width_request = this.fxdEU.width_request;
                this.height_request = this.fxdEU.height_request;

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
        
        public void OnFxdEU_Realize()
        { 
            TreeIter iter;

            // clear first
            this._lstUsers.clear();

            // populate the list store
            foreach ( UserDetail user in gPreviousOS.ExistingUsers )
            {
                this._lstUsers.append ( out iter ); 
                this._lstUsers.set ( iter, 0, user.UserId.to_string(), 1, user.Username, 2, user.HomeFolder, 3, user.Shell, -1 );                
            }
        }

        private void OnTglUserImport_Toggle(string path)
        { this.SetToggle ( path, 4 ); }

        public void  OnTglConfigImport_Toggle(string path)
        { this.SetToggle ( path, 5 ); }
        
        private void SetToggle(string path, int col)
        {
            Gtk.TreePath tpath = new TreePath.from_string (path);
            TreeIter iter;
            GLib.Value active;
            
            this._lstUsers.get_iter (out iter, tpath);
            this._lstUsers.get_value(iter, col, out active);
            this._lstUsers.set (iter, col, ! active.get_boolean() );        
        }

        public void OnBtnCancel_Click()
        { }

        public void OnBtnImport_Click()
        { }
    }
}