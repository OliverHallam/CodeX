<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
		            exclude-result-prefixes="xs maml html cont"
                xmlns="http://www.codexdocs.com/"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:cont="http://www.codexdocs.com/contents"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="product.xsl" />
  <xsl:import href="maml.xsl" />

  <xsl:import href="doc-uri.xsl" />
  <xsl:import href="api.xsl" />
  <xsl:import href="api-doc.xsl" />
  <xsl:import href="generate.xsl"/>

  <!-- TODO: Ideally we'd pass these in as variables but the msbuild task doesn't let us do that -->
  <xsl:variable name="documentation" select="collection('cdx:Documentation')" as="node()*"/>
  <xsl:variable name="apis" select="collection('cdx:ReflectionData')/reflection" as="node()*"/>

  <xsl:param name="framework-version" select="'v4.0'" as="xs:string" />

  <xsl:function name="cdx:doc-uri">
    <xsl:param name="href" as="xs:string?" />
    <xsl:param name="base" as="node()?" />
    <xsl:sequence select="if(matches($href,'^[A-Za-z]:\\')) then concat('file:///',replace($href,'\\','/')) else resolve-uri($href, document-uri(root($base)))" />
  </xsl:function>

  <xsl:function name="cdx:doc">
    <xsl:param name="href" as="xs:string?" />
    <xsl:param name="base" as="node()?" />
    <xsl:variable name="uri" select="cdx:doc-uri($href, $base)" />
    <xsl:sequence select="doc($uri)" />
  </xsl:function>

  <xsl:template match="/cont:documentation">
    <documentation>
      <xsl:apply-templates select="*" />
    </documentation>
  </xsl:template>

  <xsl:template match="cont:product">
    <xsl:variable name="assembly-names" select="cont:assembly/@name" />
    <xsl:variable name="product-apis" select="$apis[assemblies/assembly/@name=$assembly-names]" as="node()+"/>

    <product name="{@name}" version="{@version}">
      <xsl:apply-templates select="*">
        <xsl:with-param name="version" select="@version" tunnel="yes" />
        <xsl:with-param name="product-name" select="@name" tunnel="yes" />

        <xsl:with-param name="product-apis" tunnel="yes" select="$product-apis" as="node()*"/>
      </xsl:apply-templates>
    </product>
  </xsl:template>

  <xsl:template match="cont:topic">
    <xsl:param name="version" as="xs:string?" tunnel="yes" select="()"/>
    <xsl:param name="product-name" tunnel="yes" />

    <xsl:variable name="id" select="@id" />
    <xsl:variable name="filename" select="maml:getFileName($id)" />

    <xsl:variable name="doc" select="cdx:doc(@href, /)" />
    <xsl:variable name="title" select="@title" />

    <xsl:variable name="extension" select="if ($doc/html:html) then '.htm' else '.aml'" />
    <xsl:variable name="href" select="cdx:local-uri($id, $version, $extension)" />

    <xsl:result-document href="{$href}">
      <!-- The following excludes the root topic element in SHFB files -->
      <xsl:apply-templates select="$doc/topic/* | ($doc/* except $doc/topic)" mode="maml" />
      <!-- If the topic is an html file then just copy it verbatim -->
      <xsl:copy-of select="$doc/html:html" />
    </xsl:result-document>

    <topic href="{$href}" id="{$id}" filename="{$filename}" title="{$title}">
      <xsl:apply-templates select="*" />
    </topic>
  </xsl:template>

  <xsl:template match="cont:api-documentation">
    <xsl:call-template name="product" />
  </xsl:template>

  <xsl:template match="cont:include">
    <xsl:variable name="doc" select="cdx:doc(@href, /)" />

    <!-- TODO:
    BUG: The following test causes a Stack overflow exception!
    <xsl:if test="not($doc instance of document-node(element(cont:documentation, xs:anyType)))">
      <xsl:message terminate="yes"><xsl:text>TODO</xsl:text></xsl:message>
    </xsl:if>
    -->

    <xsl:apply-templates select="$doc/*" mode="include"/>
  </xsl:template>

  <xsl:template match="*" mode="include">
    <!-- TODO: improve message!-->
    <xsl:message>Included wrong file type</xsl:message>
  </xsl:template>

  <xsl:template match="cdx:documentation" mode="include">
    <xsl:for-each select="*">
      <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:attribute name="xml:base" select="document-uri(/)" />
        <xsl:copy-of select="*" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="cont:documentation" mode="include">
    <xsl:apply-templates select="*" />
  </xsl:template>

</xsl:stylesheet>
