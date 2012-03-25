<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
                exclude-result-prefixes="cdx xs xsl"
                xmlns="http://www.w3.org/1999/xhtml" 
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="render-topic.xsl"/>
  
  <xsl:template match="/" mode="contents">
    <xsl:apply-templates mode="contents"/>
  </xsl:template>
  
  <xsl:template match="cdx:documentation" mode="contents">
    <xsl:apply-templates mode="contents"/>
  </xsl:template>
  
  <xsl:template match="cdx:product" mode="contents">
    <xsl:apply-templates mode="contents" />
  </xsl:template>
  
  <xsl:template match="cdx:topic[@href]" mode="contents">
    <!-- omit topics without source files (eg enumeration members) -->
    
    <xsl:variable name="topic-uri">
      <xsl:apply-templates select="." mode="topic-uri" />
    </xsl:variable>
    
    <xsl:result-document href="{$topic-uri}">
      <xsl:apply-templates select="document(@href)">
        <xsl:with-param name="topic" tunnel="yes" select="." />
      </xsl:apply-templates>
    </xsl:result-document>
    
    <xsl:apply-templates select="*" mode="contents" />
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="contents">
    <xsl:apply-templates select="*" mode="contents" />
  </xsl:template>
  
  <xsl:template match="node()|@*" mode="contents" />
</xsl:stylesheet>
