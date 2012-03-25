<xsl:stylesheet version="2.0"
                exclude-result-prefixes="xs cdx cpp maml xlink"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:cpp="http://www.codexdocs.com/languages/cpp"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:function name="cpp:built-in-name"
                as="text()?">
    <xsl:param name="id" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$id = 'T:System.Object'">
        <xsl:text>object</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Char'">
        <xsl:text>char</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.String'">
        <xsl:text>String</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Single'">
        <xsl:text>float</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Double'">
        <xsl:text>double</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Byte'">
        <xsl:text>byte</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.SByte'">
        <xsl:text>sbyte</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Boolean'">
        <xsl:text>bool</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int16'">
        <xsl:text>short</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int32'">
        <xsl:text>int</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int64'">
        <xsl:text>long</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt16'">
        <xsl:text>ushort</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt32'">
        <xsl:text>uint</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt64'">
        <xsl:text>ulong</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Decimal'">
        <xsl:text>decimal</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Void'">
        <xsl:text>void</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
    
  <xsl:template match="cdx:type" mode="cpp">
    <xsl:param name="ignore-ref" select="false()" as="xs:boolean" tunnel="yes"/>
    
    <xsl:value-of select="(cpp:built-in-name(@id), @name)[1]"/>
    <xsl:if test="*">
      <xsl:apply-templates select="." mode="specialization" />
    </xsl:if>
    <xsl:if test="not($ignore-ref) and @ref = 'true'">
      <xsl:text>^</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cdx:refType" mode="cpp">
    <xsl:apply-templates select="*" />
    <xsl:text>^</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:referenceTo" mode="cpp">
    <xsl:apply-templates select="*" />
    <xsl:text>%</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:pointerTo" mode="cpp">
    <xsl:apply-templates select="*" />
    <xsl:text>*</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:arrayOf" mode="cpp">
    <code class="keyword">array</code>
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text>&gt;^</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:externalCodeEntityReference" mode="cpp">
    <xsl:value-of select="(cpp:built-in-name(@id), @api-name)[1]"/>
  </xsl:template>
  
    <xsl:template match="maml:languageKeyword" mode="cpp">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = ('true','false','sealed','static','abstract','virtual')]" mode="cpp">
    <code class="keyword"><xsl:value-of select="node()" /></code>
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'null']" mode="cpp">
    <code class="keyword">nullptr</code>
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'readonly']" mode="cpp">
    <code class="keyword">initonly</code>
  </xsl:template>
</xsl:stylesheet>