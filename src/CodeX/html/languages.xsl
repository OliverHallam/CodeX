<xsl:stylesheet version="2.0"
                exclude-result-prefixes="cdx maml xlink xs xsl"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:maml="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="vb.xsl" />
  <xsl:include href="cs.xsl" />
  <xsl:include href="cpp.xsl" />
  
  <xsl:param name="languages" select="('cs','vb','cpp')" />
  
  <xsl:template match="node()" mode="apply-language">
    <xsl:param name="lang" as="xs:string" required="yes" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="$lang='vb'">
        <xsl:apply-templates select="." mode="vb" />
      </xsl:when>
      <xsl:when test="$lang='cs'">
        <xsl:apply-templates select="." mode="cs" />
      </xsl:when>
      <xsl:when test="$lang='cpp'">
        <xsl:apply-templates select="." mode="cpp" />
      </xsl:when>
      <xsl:when test="$lang='default'">
        <xsl:apply-templates select="." mode="default-language" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cdx:type" mode="default-language">
    <xsl:value-of select="@name"/>
    <xsl:if test="*">
      <xsl:apply-templates select="." mode="specialization" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cdx:refType" mode="default-language">
    <xsl:apply-templates select="*" />
  </xsl:template>
    
  <xsl:template match="cdx:referenceTo" mode="default-language">
    <xsl:apply-templates select="*" />
    <!-- MSDN displays nothing here - surely % is better? -->
    <xsl:text>%</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:pointerTo" mode="default-language">
    <xsl:apply-templates select="*" />
    <xsl:text>*</xsl:text>
  </xsl:template>
    
  <xsl:template match="cdx:arrayOf" mode="default-language">
    <xsl:apply-templates select="*" />
    <xsl:text>[]</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:externalCodeEntityReference" mode="default-language">
    <xsl:value-of select="@api-name"/>
  </xsl:template>
  
  <xsl:template match="cdx:languageKeyword" mode="default-language">
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="cdx:languageKeyword[. = ('null','sealed','static','abstract','virtual','readonly')]" mode="default-language">
    <!-- in most cases we default to the VB description (but not for true and false) -->
    <xsl:apply-templates select="." mode="vb" />
  </xsl:template>

  <xsl:template match="*" mode="apply-all-languages">
    <xsl:param name="title" select="false()" as="xs:boolean" />
    <xsl:param name="qualify-hint" select="false()" as="xs:boolean"/>
    
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="exists($lang)">
        <xsl:apply-templates select="." mode="apply-language" />
      </xsl:when>
    
      <xsl:otherwise>
        <xsl:variable name="current" select="." />
        <xsl:for-each select="$languages">
        <span class="{.}">
          <xsl:apply-templates select="$current" mode="apply-language">
            <xsl:with-param name="lang" select="." tunnel="yes" />
          </xsl:apply-templates>
        </span>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>