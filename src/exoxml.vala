using Xml;

namespace Exogenesis
{
    public class exoXml
    {
        private string _xmlFile = "%s/translate.xml".printf(AppPath);
        private Xml.Doc* _xDoc;

        public exoXml()
        { loadXml(); }

        private void loadXml () throws XmlError 
        {
            //parse the document from path
            this._xDoc = Xml.Parser.parse_file (this._xmlFile);

            if (this._xDoc == null) 
            { throw new XmlError.FILE_NOT_FOUND ("file %s not found or permissions missing", this._xmlFile); }
 
            //get the root node. notice the dereferencing operator -> instead of .
            Xml.Node* xrootnode = this._xDoc->get_root_element ();
            if (xrootnode == null) 
            {
                //free the document manually before throwing because the garbage collector can't work on pointers
                delete this._xDoc;
                throw new XmlError.XML_DOCUMENT_EMPTY ("the xml'%s' is empty", this._xmlFile);
            }
        }

        public string GetText(string currentlanguage, string formname, string item)
        {
            Xml.XPath.Object* result;
            try
            {
                // create the basic plumbing for XPath
                if ( this._xDoc != null )
                {
                    Xml.XPath.Context* xpath = new Xml.XPath.Context(this._xDoc);
                    //XPathContext* xpath = new XPathContext(this._xDoc);

                    // execute an xpath query
                    result = xpath->eval_expression("//"+ formname + "/" + item + "/" + currentlanguage);
                    // XPathObject* result = xpath->eval_expression("/user");
                    return result->nodesetval->item(0)->get_content();
               }
               else
               {
                   return "Welcome to Exogenesis, the Aurura Installer";
               }
            }
            catch ( GLib.Error err )
            {
                stdout.printf("%s\n", err.message);
                return "";
            }
        }
    }
}