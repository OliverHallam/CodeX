<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx ddue xs xsl xp"
                extension-element-prefixes="xp"
                xmlns="http://www.w3.org/1999/xhtml"
	              xmlns:cdx="http://www.codexdocs.com/"
                xmlns:ddue="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:xp="http://www.xmlprime.com/">
  
  <!-- This code is borrowed from StyleCop -->
  <!-- TODO: replace with a "clean room" implementation -->

  <xp:script language="C#" implements-prefix="ddue">
		<xp:using namespace="System" />
		<xp:using namespace="System.IO" />
		<xp:using namespace="System.Collections.Generic" />
		<xp:using namespace="System.Xml" />
		<xp:using namespace="System.Xml.XPath" />
		<xp:using namespace="XmlPrime" />
		<xp:using namespace="XmlPrime.Serialization" />
		<![CDATA[
			public static string getFileName(string id) {
        string fileName = id.Replace(':', '_').Replace('<', '_').Replace('>', '_');

			  if (fileName.IndexOf(".#ctor") != -1 && fileName.IndexOf("Overload") == -1)
			  {
				  fileName = "C_" + fileName.Substring(2);
				  fileName = fileName.Replace(".#ctor", ".ctor");
			  }
        else if (fileName.IndexOf(".#ctor") != -1 && fileName.IndexOf("Overload") != -1)
			  {
				  fileName = fileName.Replace("Overload", "O_T");
				  fileName = fileName.Replace(".#ctor", ".ctor");
			  }
			  else if (fileName.IndexOf(".#cctor") != -1 && fileName.IndexOf("Overload") == -1)
			  {
				  fileName = "C_" + fileName.Substring(2);
				  fileName = fileName.Replace(".#cctor", ".cctor");
			  }
        else if (fileName.IndexOf(".#cctor") != -1 && fileName.IndexOf("Overload") != -1)
			  {
				  fileName = fileName.Replace("Overload", "O_T");
				  fileName = fileName.Replace(".#cctor", ".cctor");
			  }
        else if (fileName.IndexOf("Overload") != -1)
        {
          fileName = fileName.Replace("Overload", "O_T");
        }

			  fileName = fileName.Replace('.', '_').Replace('#', '_');
			
			  int paramStart = fileName.IndexOf('(');
			  if(paramStart != -1)
			  {
				  fileName = fileName.Substring(0, paramStart) + GenerateParametersCode(id.Substring(paramStart));
			  }

			  return fileName;
			}
      
      private static string GenerateParametersCode(string parameterSection)
		  {
			  // TODO: figure out a consistent algorithm that works regardless of runtime version
			  int code = parameterSection.GetHashCode();
			
			  int parameterCount = 1;
			
			  for(int count = 0; count < parameterSection.Length; count += 1)
			  {
				  int c = (int) parameterSection[count];

				  if(c == ',')
					  ++parameterCount;
			  }

			  // format as (# of parameters)_(semi-unique hex code)
			  return string.Format("_{1}_{0:x8}", code, parameterCount);
		}

     private static Dictionary<string, XPathItem> 
       DataCache = new Dictionary<string, XPathItem>();

     public static XPathItem Cache(string key, XPathItem value)
     {
       DataCache[key] = value;
       return value;
     }

     public static XPathItem GetCache(string key)
     {
       if (DataCache.ContainsKey(key))
         return DataCache[key];
       return null;
     }

     private static bool noPost = false;

     public static XPathNavigator post(string uri,
                                         XPathNavigator payload)
      {
        if (noPost)
          return null;
try {
        System.Net.HttpWebRequest request = System.Net.WebRequest.Create(uri) as System.Net.HttpWebRequest;
	request.Method = "POST";
	request.ContentType = "text/xml; charset=utf-8";
	request.Accept = "text/xml";
        request.Headers.Add("SOAPAction", "\"urn:msdn-com:public-content-syndication/GetContent\"");

	using(Stream stream = request.GetRequestStream())
	{
          XdmWriterSettings settings = new XdmWriterSettings();
          settings.Indent = true;
          XdmWriter.Serialize(payload, stream, settings);
	}
        System.Net.WebResponse response = request.GetResponse();
        using (Stream stream = response.GetResponseStream())
        {
	  XmlReaderSettings settings = new XmlReaderSettings();
          settings.NameTable = payload.NameTable;
          using (XmlReader reader = XmlReader.Create(stream, settings))
          {
	    XdmDocument document = new XdmDocument(reader);
	    XPathNavigator result = document.CreateNavigator();
             
            return result;
          }
        }
}
catch (System.Net.WebException e)
{
  if (e.Response != null)
  {
    using (Stream stream = e.Response.GetResponseStream())
    {
          XdmDocument document = new XdmDocument(stream);
          Console.WriteLine(document.CreateNavigator().OuterXml);
    }
  }
  Console.WriteLine(e.Message);
  return null;
}
catch (System.Exception e)
{
  Console.WriteLine(e);
  noPost = true;
  return null;
}
      }
		]]>
	</xp:script>

  <xsl:function name="cdx:msdn"
                as="xs:string"
                xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
                xmlns:k="urn:mtpg-com:mtps/2004/1/key">
    <xsl:param name="id" as="xs:string" />
    <xsl:variable name="cache" select="ddue:GetCache($id)" />
    <xsl:choose>
      <xsl:when test="$cache">
        <xsl:sequence select="$cache" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="request">
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
                         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <getContentRequest xmlns="urn:msdn-com:public-content-syndication">
                <contentIdentifier>
                  <xsl:value-of select="concat('AssetID:', $id)" />
                </contentIdentifier>
                <locale xmlns="urn:mtpg-com:mtps/2004/1/key">en-us</locale>
                <requestedDocuments>
                  <requestedDocument type="common" selector="Mtps.Links" />
                </requestedDocuments>
              </getContentRequest>
            </soap:Body>
          </soap:Envelope>
        </xsl:variable>
        <xsl:variable name="response" select="ddue:post('http://services.msdn.microsoft.com/ContentServices/ContentService.asmx', $request)/soap:Envelope/soap:Body/*/k:contentId" />
        <xsl:copy-of select="ddue:Cache($id, string($response))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="cdx:local-uri">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="version" as="xs:string?" />
    
    <xsl:sequence select="cdx:local-uri($id, $version, '.aml')" />
  </xsl:function>
  
  <xsl:function name="cdx:local-uri">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="version" as="xs:string?" />
    <xsl:param name="extension" />
    <xsl:variable name="filename"
                  select="if (exists($version))
                          then concat(ddue:getFileName($id), '_', $version)
                          else ddue:getFileName($id)" />
    <xsl:sequence select="xs:anyURI(concat($filename,$extension))" />
  </xsl:function>
  
  <xsl:function name="cdx:uri" as="xs:anyURI" xmlns:ddue="http://ddue.schemas.microsoft.com/authoring/2003/5">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="version" as="xs:string?" />
    <xsl:param name="product-apis" as="node()*" />
    
    <xsl:choose>
      <xsl:when test="$product-apis/key('apis-by-id', $id, .)">
        <xsl:sequence select="cdx:local-uri($id, $version)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="xs:anyURI(concat('http://msdn.microsoft.com/en-us/library/', cdx:msdn($id), '.aspx'))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


</xsl:stylesheet>
