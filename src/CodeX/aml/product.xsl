<?xml version="1.0"?>

<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx xs xsl"
                xmlns="http://www.codexdocs.com/"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="product">
    <xsl:param name="product-name" tunnel="yes" />
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    
    <!--TODO: escape the product name for the file name -->
    <xsl:variable name="href" select="concat('Namespaces_', $product-name, '_', $version, '.aml')" />
    
    <!--TODO: have a flag indicating whether to include the namespaces file -->
    
    <xsl:result-document href="{$href}">
      <xsl:call-template name="generate-namespaces">
        <xsl:with-param name="current" tunnel="yes" select="()" />
      </xsl:call-template>
    </xsl:result-document>

    <topic href="{$href}" id="Namespaces:{$product-name}" filename="Namespaces_{$product-name}" title="{$product-name} Class Library" fulltitle="{$product-name} Class Library">
      <xsl:for-each-group select="$product-apis/apis/api[apidata/@group='namespace']" group-by="apidata/@name">
        <xsl:call-template name="namespace">
          <xsl:with-param name="namespace-apis" select="current-group()" tunnel="no" />
        </xsl:call-template>
      </xsl:for-each-group>
    </topic>
  </xsl:template>
  
  <xsl:key name="assembly-by-apis-document-uri" match="assembly" use="document-uri(cdx:doc(@href, /))" />
  
  <xsl:template name="generate-namespaces">
    <xsl:param name="product" tunnel="yes" />
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <developerReferenceWithoutSyntaxDocument xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5">
      <introduction>
        <!-- TODO: get this from somewhere! -->
      </introduction>
      <section>
        <title>Namespaces</title>
        <content>
          <para>
            The
            <xsl:value-of select="$product-name" />
            class library provides the following namespaces, which are documented in detail in this reference.
          </para>
          <definitionTable>
            <xsl:for-each-group select="$product-apis/apis/api[apidata/@group='namespace']" group-by="apidata/@name">
              <xsl:variable name="namespace-api" select="current-group()[1]" />
              
              <!-- merge in framework documentation for this version -->
              <definedTerm>
                <xsl:call-template name="api-link">
                  <xsl:with-param name="id" select="$namespace-api/@id" />
                </xsl:call-template>
              </definedTerm>
              <definition>
                <xsl:variable name="documentation"
                              select="cdx:lookup-documentation(@id, 
                                      $apis,
                                      $documentation)" />
                <xsl:apply-templates select="$documentation/summary/node()" mode="api-doc">
                  <xsl:with-param name="current" select="$namespace-api" tunnel="yes" />
                </xsl:apply-templates>
              </definition>
            </xsl:for-each-group>
          </definitionTable>
        </content>
      </section>
    </developerReferenceWithoutSyntaxDocument>
  </xsl:template>
</xsl:stylesheet>