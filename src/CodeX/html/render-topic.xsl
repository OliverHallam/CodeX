<?xml version="1.0"?>
<xsl:stylesheet version="2.0" 
                exclude-result-prefixes="cdx xs xsl"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="maml2html.xsl"/>

  <xsl:template name="token-type-seperator">
    <xsl:param name="lang" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="$lang='cpp'">
        <xsl:text>::</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>.</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="token-template-begin">
    <xsl:param name="lang" tunnel="yes" />

    <xsl:choose>
      <xsl:when test="$lang='cs' or $lang='cpp'">
        <xsl:text>&lt;</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='vb'">
        <xsl:text>(Of </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>(</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="token-template-end">
    <xsl:param name="lang" tunnel="yes" />

    <xsl:choose>
      <xsl:when test="$lang='cs' or $lang='cpp'">
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cdx:type" mode="specialization">
    <xsl:call-template name="token-template-begin" />
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:call-template name="token-template-end" />
  </xsl:template>
    
  <xsl:template match="cdx:topic[@api-category='constructor']" mode="category-list-title">
    <xsl:text>Constructors</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='event']" mode="category-list-title">
    <xsl:text>Events</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='field']" mode="category-list-title">
    <xsl:text>Fields</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='method']" mode="category-list-title">
    <xsl:text>Methods</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='operator']" mode="category-list-title">
    <xsl:text>Operators</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='property']" mode="category-list-title">
    <xsl:text>Properties</xsl:text>
  </xsl:template>
     
  <xsl:template match="cdx:topic[@api-category='class']" mode="category-title">
    <xsl:text>Class</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='constructor']" mode="category-title">
    <xsl:text>Constructor</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='delegates']" mode="category-title">
    <xsl:text>Delegate</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='enumeration']" mode="category-title">
    <xsl:text>Enumeration</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='event']" mode="category-title">
    <xsl:text>Event</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='field']" mode="category-title">
    <xsl:text>Field</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='interface']" mode="category-title">
    <xsl:text>Interface</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='method']" mode="category-title">
    <xsl:text>Method</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='namespace']" mode="category-title">
    <xsl:text>Namespace</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='operator']" mode="category-title">
    <xsl:text>Operator</xsl:text>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-category='property']" mode="category-title">
    <xsl:text>Property</xsl:text>
  </xsl:template>

  <xsl:template match="cdx:topic[@api-category='structure']" mode="category-title">
    <xsl:text>Structure</xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="parameters">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="cdx:parameter">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="*" />
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="template-parameters">
    <xsl:call-template name="token-template-begin" />
    <xsl:for-each select="cdx:template-parameter">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@name" />
    </xsl:for-each>
    <xsl:call-template name="token-template-end" />
  </xsl:template>
  
  <xsl:template match="cdx:topic[@title]" mode="name-all-languages">
    <xsl:apply-templates select="." mode="name" />
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="name-all-languages">
    <xsl:param name="title" select="false()" as="xs:boolean" />
    <xsl:param name="qualify-hint" select="false()" as="xs:boolean"/>
    
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="exists($lang)">
        <xsl:apply-templates select="." mode="name">
          <xsl:with-param name="title" select="$title" />
          <xsl:with-param name="qualify-hint" select="$qualify-hint" />
        </xsl:apply-templates>
      </xsl:when>
    
      <xsl:otherwise>
        <xsl:variable name="current" select="." />
        <xsl:for-each select="$languages">
        <span class="{.}">
          <xsl:apply-templates select="$current" mode="name">
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="qualify-hint" select="$qualify-hint" />
            <xsl:with-param name="lang" tunnel="yes" select="." />
          </xsl:apply-templates>
        </span>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@title]" mode="name">
    <!-- simple content -->
    <xsl:value-of select="@title" />
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-name]" mode="name">
    <xsl:param name="qualify-hint" select="false()" as="xs:boolean" />
    <xsl:param name="title" select="false()" as="xs:boolean" />
    <xsl:param name="related-topics" select="false()" as="xs:boolean" />
    <xsl:param name="type-params" select="true()" as="xs:boolean" />
    
    <!-- api member -->

    <xsl:variable name="container" select="ancestor::cdx:topic[not(@api-list)][1]/@api-name" />

    <xsl:choose>
      <xsl:when test="@api-name='.ctor'">
        <xsl:value-of select="$container"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$qualify-hint and $container">
          <xsl:value-of select="$container" />
          <xsl:call-template name="token-type-seperator" />
        </xsl:if>
        
        <xsl:if test="cdx:explicit-interface">
          <xsl:apply-templates select="cdx:explicit-interface/*">
            <xsl:with-param name="ignore-ref" select="true()" tunnel="yes" />
          </xsl:apply-templates>
          
          <xsl:call-template name="token-type-seperator" />
        </xsl:if>
        
        <xsl:value-of select="@api-name" />
      </xsl:otherwise>                
    </xsl:choose>
    
    <xsl:if test="$type-params and cdx:template-parameter">
      <xsl:apply-templates select="." mode="template-parameters" />
    </xsl:if>
    
    <xsl:if test="$title">
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="$related-topics and @api-list='overloads'">
          <xsl:text>Overload</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="category-title" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    
    <xsl:if test="../@api-list='overloads'">
      <!-- overloaded-->
      <xsl:apply-templates select="." mode="parameters" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@api-list='members']" mode="name">
    <xsl:param name="qualify-hint" select="false()" as="xs:boolean" />
    <xsl:param name="type-params" select="true()" as="xs:boolean" />
      
    <!-- api member -->
    <xsl:variable name="container" select="../ancestor::cdx:topic[not(@api-list)][1]/@api-name" />
    <xsl:if test="$qualify-hint and $container">
      <xsl:value-of select="$container" />
      <xsl:call-template name="token-type-seperator" />
    </xsl:if>
    
    <xsl:value-of select="../@api-name" />
        
    <xsl:if test="$type-params and ../cdx:template-parameter">
      <xsl:apply-templates select="." mode="template-parameters" />
    </xsl:if>
    
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="." mode="category-list-title" />
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="topic-uri">
    <xsl:value-of select=".[@fragment]/parent::cdx:topic/@filename | @filename" />
    
    <xsl:if test="ancestor-or-self::cdx:product">
      <xsl:text>_</xsl:text>
      <xsl:value-of select="ancestor-or-self::cdx:product[1]/@version" />
    </xsl:if>
    <xsl:text>.htm</xsl:text>
    
    <xsl:if test="@fragment">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="@fragment" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cdx:topic">
    <xsl:apply-templates select="doc(@href)">
      <xsl:with-param name="topic" select="." tunnel="yes" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:key name="topic-by-id" match="cdx:topic" use="@id" />
  
  <xsl:template match="cdx:topic" mode="versions">
    <xsl:variable name="product" select="ancestor-or-self::cdx:product[1]" as="node()?" />
    <xsl:if test="$product">
      <div id="versions">
		    <ul id="dropdown">
	        <li><strong><xsl:value-of select="$product/@name"/><xsl:text> </xsl:text><xsl:value-of select="$product/@version" /></strong></li>
          <xsl:variable name="other-versions" select="key('topic-by-id', @id) except ." />
          <xsl:if test="$other-versions">
		        <li><span>Other Versions &#x25bc;</span>
		          <ul>
		            <xsl:for-each select="$other-versions">
			            <xsl:sort select="ancestor-or-self::cdx:product[1]/@version"
                            data-type="number" 
                            order="descending" />
                  <xsl:variable name="topic-uri">
                    <xsl:apply-templates select="." mode="topic-uri" />
                  </xsl:variable>
			            <li><a href="{$topic-uri}"><xsl:value-of select="concat(ancestor-or-self::cdx:product[1]/@name, ' ', ancestor-or-self::cdx:product[1]/@version)" /></a></li>
		            </xsl:for-each>
		          </ul>
		        </li>
          </xsl:if>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cdx:topic" mode="navigation">
    <ul>
      <xsl:for-each select="ancestor::cdx:topic">
        <li class="nav-ancestor">
          <xsl:apply-templates select="." mode="nav-link" />
        </li>
      </xsl:for-each>
      <li class="nav-self">
        <xsl:apply-templates select="." mode="name-all-languages">
          <xsl:with-param name="qualify-hint" select="false()" />
          <xsl:with-param name="title" select="true()" />
        </xsl:apply-templates>
      </li>
      <xsl:apply-templates select="*" mode="nav-children" />
    </ul>
  </xsl:template>
  
  <xsl:template match="cdx:topic[@href]" mode="nav-children">
    <!-- only display children with their own pages -->
    <li class="nav-child">
      <xsl:apply-templates select="." mode="nav-link" />
    </li>
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="nav-children" />
 
  <xsl:template match="*" mode="nav-children">
    <xsl:apply-templates select="*" mode="nav-children" />
  </xsl:template>
  
  <xsl:template match="cdx:topic[@title]" mode="nav-link">
    <xsl:variable name="topic-uri">
      <xsl:apply-templates select="." mode="topic-uri" />
    </xsl:variable>
    
    <a href="{$topic-uri}" title="{@title}">
      <xsl:value-of select="@title" />
    </a>
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="nav-link">
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    
    <xsl:choose>
      <xsl:when test="exists($lang)">
        <xsl:apply-templates select="." mode="generate-link">
          <xsl:with-param name="lang-class" select="false()" />
        </xsl:apply-templates>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="generate-link">
          <xsl:with-param name="lang" select="'cs'" tunnel="yes" />
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="generate-link">
          <xsl:with-param name="lang" select="'vb'" tunnel="yes" />
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="generate-link">
          <xsl:with-param name="lang" select="'cpp'" tunnel="yes" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cdx:topic" mode="generate-link">
    <xsl:param name="lang" as="xs:string?" tunnel="yes" />
    <xsl:param name="lang-class" as="xs:boolean" select="true()" />
    
    <xsl:variable name="topic-uri">
      <xsl:apply-templates select="." mode="topic-uri" />
    </xsl:variable>
    
    <a href="{$topic-uri}">
      <xsl:if test="$lang-class">
        <xsl:attribute name="class">
          <xsl:value-of select="$lang" />
        </xsl:attribute>
      </xsl:if>
      
      <xsl:attribute name="title">
        <xsl:apply-templates select="." mode="name">
          <xsl:with-param name="qualify-hint" select="true()" />
          <xsl:with-param name="title" select="true()" />
        </xsl:apply-templates>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="name">
        <xsl:with-param name="qualify-hint" select="false()" />
        <xsl:with-param name="title" select="true()" />
      </xsl:apply-templates>
    </a>
  </xsl:template>
</xsl:stylesheet>
