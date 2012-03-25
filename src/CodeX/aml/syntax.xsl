<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
		            exclude-result-prefixes="cdx syntax xs"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5" 
	              xmlns:cdx="http://www.codexdocs.com/"
                xmlns:syntax="http://www.codexdocs.com/syntax"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="hide-private-accessors" select="true()" as="xs:boolean"/>
    
  <xsl:include href="vb.xsl" />
  <xsl:include href="cs.xsl" />
  <xsl:include href="cpp.xsl" />
  <!--xsl:include href="fs.xsl" /-->

  <xsl:function name="syntax:is-interface"
                as="xs:boolean">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="apis" />
    <xsl:sequence select="cdx:get-api($id, $apis)/apidata/@subgroup = 'interface'" />
  </xsl:function>

  <xsl:template match="api" mode="syntax">
    <syntax>
      <sections>
        <section>
          <title>Syntax</title>
          <content>
            <code language="VB.NET">
              <xsl:choose>
                <xsl:when test="//pointerTo">
                  <xsl:text>Visual Basic does not support APIs that consume or return unsafe types.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="vb" />
                </xsl:otherwise>
              </xsl:choose>
            </code>
            <code language="C#">
          	  <xsl:apply-templates select="." mode="cs" />
            </code>
            <code language="C++">
          	  <xsl:apply-templates select="." mode="cpp" />
            </code>
            <!--xsl:apply-templates select="." mode="fs" /-->
          </content>
        </section>
      </sections>
    </syntax>
  </xsl:template>
 
</xsl:stylesheet>
