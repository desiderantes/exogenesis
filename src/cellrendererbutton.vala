using Gtk;
using Gdk;
using Cairo;

namespace Exogenesis
{
    class CellRendererButton : Gtk.CellRenderer
    {
        // icon property set by the tree column 
        public string stockicon { get; set; }
        public int IconWidth { get; set; }
        public int IconHeight { get; set; }
        public bool Active { get; set; default=true;}
        
        private Gdk.Pixbuf icon;
        public signal void clicked(string path);

        // dumb constructor
        public CellRendererButton () 
        {
            this.set_property("mode", Gtk.CellRendererMode.ACTIVATABLE );
            this.set_property("xalign", 0.5);
        }
     
        /* get_size method, always request a 32x32 area */
        public override void get_size (Gtk.Widget widget,
                                     Gdk.Rectangle? cell_area,
                                     out int x_offset,
                                     out int y_offset,
                                     out int width,
                                     out int height)
        {
            if ( &width != null ) {  width = 32; }
            if ( &height != null ) { height = 32; }
            return;
        }
     
        // render method 
        public override void render ( Context ctx,
                                   Gtk.Widget    widget,
                                   Gdk.Rectangle background_area,
                                   Gdk.Rectangle cell_area,
                                   Gtk.CellRendererState flags)
        {
            icon = widget.render_icon( stockicon, Gtk.IconSize.MENU, null);
            
        /*    if (&expose_area != null)
            {
                Gdk.cairo_rectangle (ctx, expose_area);
                ctx.clip();
            } */

            Gdk.cairo_rectangle (ctx, background_area);
            if ( icon != null && this.Active )
            {
                // centre icon in cell
                int x = cell_area.x + (( background_area.width / 2) - ( icon.width / 2));
                int y = cell_area.y + (( background_area.height / 2 ) - ( icon.height / 2 ));

                Gdk.cairo_set_source_pixbuf (ctx, icon, x, y); 
                ctx.fill();
            }
            return;
        }

        public override bool activate (Event event, Widget widget, string path, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, CellRendererState flags)
        { 
	        if ( this.Active )
            {	
            	this.clicked(path);
            	return true; 
           	}
           	else
           	{ return false; }
        }
    }
}