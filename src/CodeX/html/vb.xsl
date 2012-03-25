<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx maml vb xlink xs xsl"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:vb="http://www.codexdocs.com/languages/vb"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:function name="vb:built-in-name"
                  as="text()?">
    <xsl:param name="id" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$id = 'T:System.Object'">
        <xsl:text>Object</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Char'">
        <xsl:text>Char</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.String'">
        <xsl:text>String</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Single'">
        <xsl:text>Single</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Double'">
        <xsl:text>Double</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Byte'">
        <xsl:text>Byte</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.SByte'">
        <xsl:text>SByte</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Boolean'">
        <xsl:text>Boolean</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int16'">
        <xsl:text>Short</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int32'">
        <xsl:text>Integer</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Int64'">
        <xsl:text>Long</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt16'">
        <xsl:text>UShort</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt32'">
        <xsl:text>UInteger</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.UInt64'">
        <xsl:text>ULong</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.Decimal'">
        <xsl:text>Decimal</xsl:text>
      </xsl:when>
      <xsl:when test="$id = 'T:System.DateTime'">
        <xsl:text>Date</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="cdx:type" mode="vb">
    <xsl:value-of select="(vb:built-in-name(@id), @name)[1]"/>
    <xsl:if test="*">
      <xsl:apply-templates select="." mode="specialization" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cdx:refType" mode="vb">
    <xsl:apply-templates select="*" />
  </xsl:template>
  
  <xsl:template match="cdx:referenceTo" mode="vb">
    <xsl:text>ByRef </xsl:text>
    <xsl:apply-templates select="*" />
  </xsl:template>
  
  <xsl:template match="cdx:pointerTo" mode="vb">
    <xsl:apply-templates select="*" />
    <xsl:text>*</xsl:text>
  </xsl:template>
    
  <xsl:template match="cdx:arrayOf" mode="vb">
    <xsl:apply-templates select="*" />
    <xsl:text>()</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:externalCodeEntityReference" mode="vb">
    <xsl:value-of select="(vb:built-in-name(@id), @api-name)[1]"/>
  </xsl:template>
  
  <xsl:template match="maml:languageKeyword" mode="vb">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'null']" mode="vb">
    a null reference (<code class="keyword">Nothing</code> in Visual Basic)
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'true']" mode="vb">
    <code class="keyword">True</code>
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'false']" mode="vb">
    <code class="keyword">False</code>
  </xsl:template>
  
  <xsl:template match="maml:languageKeyword[. = 'sealed']" mode="vb">
    sealed (<code class="keyword">NotInheritable</code> in Visual Basic)
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'static']" mode="vb">
    static (<code class="keyword">Shared</code> in Visual Basic)
  </xsl:template>

  <xsl:template match="maml:languageKeyword[. = 'abstract']" mode="vb">
    abstract (<code class="keyword">MustInherit</code> in Visual Basic)
  </xsl:template>
  
  <xsl:template match="maml:languageKeyword[. = 'virtual']" mode="vb">
    virtual (<code class="keyword">CanOverride</code> in Visual Basic)
  </xsl:template>
  
  <xsl:template match="maml:languageKeyword[. = 'readonly']" mode="vb">
    <code class="keyword">ReadOnly</code>
  </xsl:template>
</xsl:stylesheet>