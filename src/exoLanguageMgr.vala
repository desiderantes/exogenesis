using GLib;
using Gee;
using Xml;
using GConf;

namespace Exogenesis
{
	public class LanguageManager
	{
        // events 
	    public signal void OnGConfLayoutChanged();

	    private string _curLocale;
        private Xml.Doc* _xKbLayoutDoc;
        private KeyboardModels _kbrds = new KeyboardModels();
        private KbCountries _countries = new KbCountries();
        private GConf.Client _gc = GConf.Client.get_default();
        private GConf.Engine _eng = GConf.Engine.get_default();
        
        private SList<string> _CurrentKbConf;
        private string _GCKbKey = "/desktop/gnome/peripherals/keyboard/kbd/layouts";

		public LanguageManager()
		{
		    this._curLocale = Environment.get_variable ("LANG");
		    GetKbLayouts("/usr/share/X11/xkb/rules/xorg.xml");
		    this.BackupCurrentKbSetting();
		    this.AddGconfListener();
        }

        public KbCountries Countries
        { get { return this._countries; } }
        
        public KeyboardModels Keyboards
        { get { return this._kbrds; } }

        public string CurrentLocale
        {
            get { return this._curLocale; }
            set { this._curLocale = value; }
        }
        
        public string GetCurrentCountry()
        {
            string ret = "";
            foreach ( string s in this._CurrentKbConf )
            {
                ret = s;
                break;
            }
            return ret;
        }

    // GCONF handlers for keyboard and layout changes        
        private void AddGconfListener()
        { 
            string listening_dir = "/desktop/gnome/peripherals/keyboard/kbd";
            this._gc.add_dir (listening_dir, GConf.ClientPreloadType.ONELEVEL);
            
            this._gc.notify_add(this._GCKbKey, GConfCallBack);

        }

        private void GConfCallBack (GConf.Client gc, uint cxnid, GConf.Entry entry) 
        {
            SList<string> newList = this._gc.get_list(entry.key, GConf.ValueType.STRING); 
            string s ="";
            
            // there'll only be one string in list during these edits
            foreach ( string st in newList )
            { s += st; }
        }

        public void GConfSetLayout(string layout, string variant="")
        {
            string entry;
            SList<string> nu = new SList<string>();
            
            if ( layout != null && layout != "" )
            {
                if ( variant != "" )
                { entry = "%s\t%s".printf(layout, variant); }
                else
                { entry = layout; }

                // set the locale
                nu.prepend(entry);
                this._gc.set_list(this. _GCKbKey, GConf.ValueType.STRING, nu);
                nu = null;
                this.OnGConfLayoutChanged();
            }
        }

        private void BackupCurrentKbSetting()
        {
            try
            {
                this._CurrentKbConf = this._gc.get_list(this. _GCKbKey, GConf.ValueType.STRING);
            }
            catch ( GLib.Error err )
            { GeneralFunctions.LogIt("Can't get current keyboard configs! - %s\n".printf( err.message )); }
        }
        
    // END GCONF Handlers

		public GLib.List<Language>? AvailableLanguages()
		{
		    GLib.List<Language> langs = new GLib.List<Language>();
            string filedata;
            string ot;

            try
            {
		        // get the installed file names
		        filedata = gGenFunc.ReadTextFile("%s/locale/languagelist.data".printf(AppPath) );

		        // split the data
		        string[] lines = filedata.split("\n");

		        foreach ( string line in lines )
		        {
		            string[] lang = line.split(":");
		            if (lang.length == 4)
		            {
			            Language language = new Language();
	
	                    language.Order = int.parse(lang[0]);
	                    language.Code = (string)lang[1];
	                    language.Country = (string)lang[2];
	                    language.CountryNative = (string)lang[3];
			            langs.append(language); 
		        	}
		        } 
		        return langs;
		    }
		    catch ( GLib.Error e )
		    { 
                GeneralFunctions.LogIt(e.message);
		    }
		    return null;
		}
		
		public void GetKbLayouts(string xorgfile)
		{
            //parse the document from path
            this._xKbLayoutDoc = Xml.Parser.parse_file (xorgfile);

            this.PopulateKbModels(); 
            this.PopulateCountries();

            if (this._xKbLayoutDoc == null) 
            { throw new XmlError.FILE_NOT_FOUND ("file %s not found or permissions missing", xorgfile); }

            delete this._xKbLayoutDoc;
 
		}

        // get the model list from the XML
        private void PopulateKbModels()
        {
            if ( this._xKbLayoutDoc != null )
            {
                Xml.XPath.Context* xpath = new Xml.XPath.Context(this._xKbLayoutDoc);
                Xml.XPath.Object* result = xpath->eval_expression("//model/configItem");

                if ( result != null )
                {                 
                    this._kbrds = new KeyboardModels(); 

                    for ( int i=0; i < result->nodesetval->length(); i++ )
                    {
                        // gets children under //model/configitem  
                        Xml.Node* nd = result->nodesetval->item(i)->children;
                        
                        if ( nd->type == ElementType.TEXT_NODE )
                        {
                            KbModel model = new KbModel();

                            for ( Xml.Node* curNode = nd; curNode != null; curNode = curNode->next )
                            {
                                if ( curNode->type == ElementType.ELEMENT_NODE )
                                { 
                                    switch ( curNode->name )
                                    {
                                        case "name":
                                            model.Name = curNode->get_content();
                                            break;
                                        case "description":
                                            model.Description = curNode->get_content();
                                            break;
                                        case "vendor":
                                            model.Vendor = curNode->get_content();
                                            break;
                                        default:
                                            break;
                                    }
                                }
                            }
                            this._kbrds.AddKeyboard( model );
                            model = null;
                        }
                    }
                }
            }   
        }
        
        // populate countries and variants
        public void PopulateCountries()
        {
            if ( this._xKbLayoutDoc != null )
            {
                Xml.XPath.Context* xpath = new Xml.XPath.Context(this._xKbLayoutDoc);

                Xml.XPath.Object* result = xpath->eval_expression("//layout");
                
                if ( result != null )
                {
                    // loop at layout node
                    for ( int i=0; i < result->nodesetval->length(); i++ )
                    {
                         Xml.Node* nd = result->nodesetval->item(i)->children;
                         
                         KbCountry country = new KbCountry();
                         
                         // loop at layout/child node
                         for ( Xml.Node* curNode = nd; curNode != null; curNode = curNode->next )
                         {
                            switch (curNode->name )
                            {
                                case "configItem":
                                    PopulateCountry(curNode->children, country);
                                    break;
                                case "variantList":
                                    PopulateVariant(curNode->children, country);
                                    break;
                            }
                        }
                        this._countries.AddCountry(country);
                        country = null;
                    }
                }
            }
        }
        
        private void PopulateCountry(Xml.Node* nd, KbCountry country)
        {
            for ( Xml.Node* n = nd; n != null; n = n->next )
            {
                switch ( n->name )
                {
                    case "name":
                        country.Name = n->get_content();
                        break;
                    case "shortDescription":
                        country.ShortDescription = n->get_content();
                        break;
                    case "description":
                        country.Description = n->get_content();
                        break;
                    case "languageList":
                        // stdout.printf("PARSING COUNTRY LANGUAGE LIST\n");
                        break;
                }
            }
        }
        
        private void PopulateVariant(Xml.Node* nd, KbCountry country)
        {
            // add the default variant, no extension
            KbVariant kv = new KbVariant();
            kv.Name = "";
            kv.Description = country.Description;
            country.AddVariant(kv);
            kv = null;
            
            // populate variants from xorg xml
            for ( Xml.Node* n = nd; n != null; n = n->next )
            {
                if ( n->name == "variant" )
                {
                    for ( Xml.Node* m = n->children; m != null; m = m->next )
                    {
                        if ( m->name == "configItem" )
                        {
                            KbVariant kbv = new KbVariant();

                            for ( Xml.Node* o = m->children; o != null; o = o->next )
                            {
                                switch ( o->name )
                                {
                                    case "name":
                                        kbv.Name = o->get_content();
                                        break;
                                    case "description":
                                        kbv.Description = o->get_content();
                                        break;
                                    case "languageList":
                                       // stdout.printf("PARSING VARIANT LANGUAGE LIST\n");
                                        break;
                                }
                            }
                            country.AddVariant(kbv);
                            kbv = null;                            
                        }
                    }
                }
            }
        }
	}

    public class Language
    {
        public int Order { get; set; }
        public string Code { get; set; }
        public string Country { get; set; }
        public string CountryNative { get; set; }

        public Language()
        { }
    }

// -----------------------------------------------------------------------------------------------------------------------------------------------
//
//  Keyboard Layout Classes
//
// -----------------------------------------------------------------------------------------------------------------------------------------------
    public class KeyboardModels : Object, Iterable<KbModel>
    {
        protected Gee.ArrayList<KbModel> _kbrds = new Gee.ArrayList<KbModel>();
        private long _count = 0;
        
        public void KeyboardModels()
        { }
        
        public void AddKeyboard(KbModel m)
        {
            this._count++; 
            this._kbrds.add(m);
        }
        
        public void Sort()
        { this._kbrds.sort(); }
        
        public Type element_type
        { get { return typeof ( KbModel ); } }
        
        public Gee.Iterator<KbModel> iterator ()
        { return this._kbrds.iterator(); }
        
        public long Count
        { get { return this._count; } }
    }
    
    
    public class KbModel
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string Vendor { get; set; }
        
        public KbModel()
        { }
        
        public KbModel.WithValues(string name, string description, string vendor )
        {
            this.Name = name;
            this.Description = description;
            this.Vendor = vendor;
        }
    }
    
    
    // Collection wrapper class for keyboard countries
    // parse xorg.xml to populate each country
    public class KbCountries : Object, Iterable<KbCountry>
    {
        protected Gee.ArrayList<KbCountry> _countries = new Gee.ArrayList<KbCountry>();

        public void KbCountries()
        { }

        public void AddCountry(KbCountry country)
        { this._countries.add(country); }

        public void Sort()
        { this._countries.sort(); }

        public Type element_type 
        {  get { return typeof (KbCountry); } }

        public Gee.Iterator<KbCountry> iterator () 
        { return this._countries.iterator(); }	
    }

    // Country specific class
    public class KbCountry : Object, Comparable<KbCountry>, Iterable<KbVariant>
    {
        public string Name { get; set; }
        public string ShortDescription { get; set; }
        public string Description { get; set; }
        protected Gee.ArrayList<KbVariant> _variant = new Gee.ArrayList<KbVariant>();
        protected Gee.ArrayList<string> _isocode = new Gee.ArrayList<string>();
        private int _variantcount = 0;
                
        public void KbCountry()
        { }

        public void AddLanguageISO(string iso)
        { this._isocode.add(iso); }

        public int VariantCount
        { get { return this._variantcount; } }


        public void AddVariant(KbVariant kbvariant)
        { 
            this._variantcount++;
            this._variant.add(kbvariant); 
        }
        
        public Type element_type
        { get { return typeof (KbVariant); } }
        
        public Gee.Iterator<KbVariant> iterator ()
        { return this._variant.iterator(); }
        
        public int compare_to(KbCountry comp)
        {
            if (this.Description < comp.Description) 
            { return -1; }
            
            if (this.Description > comp.Description) 
            { return 1; }
            return 0;
        }
    }
 
    // country layout variant list   
    public class KbVariant : Object, Iterable<string>
    {
        public string Name { get; set; }
        public string Description { get; set; }
        protected Gee.ArrayList<string> _languageList = new Gee.ArrayList<string>();
        
        public void KbVariant()
        { }
        
        public void AddLanguage(string lang)
        { this._languageList.add(lang); }
        
        public Type element_type
        { get { return typeof (string); } }
        
        public Gee.Iterator<string> iterator ()
        { return this._languageList.iterator(); } 
    }  
}