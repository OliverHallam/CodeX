<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
		            exclude-result-prefixes="maml xs xsl"
                xmlns="http://www.codexdocs.com/"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Stylesheet to handle conceptual content in sandcastle .content files -->
  
  <xsl:template match="/Topics" mode="content">
    <!--TODO: work out how to handle visible attribute -->
    <xsl:apply-templates select="child::Topic[@visible = 'True']" mode="content" />
  </xsl:template>

  <xsl:template match="Topic" mode="content">
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />

    <xsl:variable name="id" select="@id" />
    <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
    <xsl:variable name="filename" select="maml:getFileName($id)" />
    
    <xsl:variable name="doc" select="cdx:doc(concat(@id, '.aml'), .)" />
    <xsl:variable name="title" select="@title" />

    <xsl:result-document href="{$href}">
      <xsl:apply-templates select="$doc/topic/* | ($doc/* except $doc/topic)" mode="maml" />
    </xsl:result-document>

    <topic href="{$href}" id="{$id}" filename="{$filename}" title="{$title}">
      <xsl:apply-templates select="child::Topic[@visible = 'True']" mode="content"/>
    </topic>
  </xsl:template>  
</xsl:stylesheet>
