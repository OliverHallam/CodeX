<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
            		exclude-result-prefixes="cdx xs xsl"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="msdn-version" as="xs:string">
    <xsl:choose>
      <xsl:when test="$framework-version='v2.0'"><xsl:value-of select="VS.80"/></xsl:when>
      <xsl:when test="$framework-version='v3.0'"><xsl:value-of select="VS.85"/></xsl:when>
      <xsl:when test="$framework-version='v3.5'"><xsl:value-of select="VS.90"/></xsl:when>
      <xsl:when test="$framework-version='v4.0'"><xsl:value-of select="VS.100"/></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>Framework version '</xsl:text>
          <xsl:value-of select="$framework-version"/>
          <xsl:text>' is not supported.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:key name="api-by-id"
	   match="api"
	   use="@id" />
  
  <xsl:key name="api-by-containing-type"
           match="api"
           use="containers/type/@api"/>
  
  <xsl:key name="api-by-name"
           match="api"
           use="apidata/@name"/>
  
  <xsl:function name="cdx:get-api" as="element(api)">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="apis" as="node()+" />
    
    <!-- TODO: do we need to handle methods/properties etc? -->
    
    <xsl:choose>
      <xsl:when test="$apis/key('api-by-id', $id)">
        <xsl:sequence select="($apis/key('api-by-id', $id))[1]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">get-api failed for <xsl:value-of select="$id" /></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="cdx:is-overloaded" as="xs:boolean">
    <xsl:param name="api" as="element(api)" />

    <xsl:sequence select="exists(
               key('api-by-containing-type', 
                    $api/containers/type/@api, root($api)) intersect 
               key('api-by-name', $api/apidata/@name, root($api)))" />
  </xsl:function>
              
  <xsl:function name="cdx:subgroup-id">
    <xsl:param name="id" />
    <xsl:param name="subgroup" />
    
    <xsl:variable name="subgroup-prefix">
      <!-- NOTE: this should really be a seperate template, but as it happens for the values we use this works. -->
      <xsl:call-template name="category-list-name">
        <xsl:with-param name="category" select="$subgroup" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:value-of select="concat($subgroup-prefix, '.', $id)"/>
  </xsl:function>
  
  <!--TODO: could be match=api?-->
  <xsl:key name="node-by-name"
	   match="*"
	   use="@name" />
  
  <xsl:function name="cdx:lookup-documentation"
                as="element()?">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="apis" />
    <xsl:param name="documentation" as="node()*" />

    <xsl:if test="not($documentation/key('node-by-name', $id)
                      instance of element())">
      <xsl:message>
        <xsl:text>No documentation found for </xsl:text>
        <xsl:value-of select="$id" />
        <xsl:text> or not an instance of element()</xsl:text>
      </xsl:message>
    </xsl:if>
    
    <xsl:sequence select="$documentation/key('node-by-name', $id)" />
  </xsl:function>


  <!-- API NAME: System.String rendered as String -->

  <xsl:function name="cdx:container"
                as="xs:string?">
    <xsl:param name="arg" as="element(api)" />
    <xsl:choose>
      <xsl:when test="$arg/topicdata/@typeTopicId">
        <xsl:sequence select="$arg/topicdata/@typeTopicId" />
      </xsl:when>
      <xsl:when test="$arg/containers/type">
        <xsl:sequence select="$arg/containers/type/@api" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$arg/containers/namespace/@api" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="api" mode="api-link">
		<xsl:param name="current" tunnel="yes" />
		<!-- TODO: customize list of excempted namespaces-->
    <xsl:param name="qualify-hint" as="xs:boolean" select="not(($current/(@id,containers/*/@api),'N:System') =
                                                                (@id,containers/*[last()]/@api))"/>
    <xsl:param name="auto-upgrade" as="xs:boolean" select="false()" />
    <xsl:param name="subgroup" as="xs:string?" select="()" />
    <xsl:param name="typeparams" as="xs:boolean" select="true()" />
    <xsl:param name="text" as="xs:string?" select="()" />
    
    <xsl:param name="product-apis" tunnel="yes" as="node()*" />
    
    <xsl:choose>
      <xsl:when test="some $product-api in $product-apis satisfies root($product-api) is root()">
        <!-- TODO: links between products -->
        <codeEntityReference autoUpgrade="{$auto-upgrade}" qualifyHint="{$qualify-hint}" cdx:typeParams="{$typeparams}">
          <xsl:if test="exists($text)">
            <xsl:attribute name="cdx:text" select="$text" />
          </xsl:if>
          
          <xsl:value-of select="if (exists($subgroup)) then cdx:subgroup-id(@id, $subgroup) else @id" />
        </codeEntityReference>
      </xsl:when>
      <xsl:otherwise>
        <cdx:externalCodeEntityReference autoUpgrade="{$auto-upgrade}" qualifyHint="{$qualify-hint}" cdx:typeParams="{$typeparams}" id="{@id}" version="{$msdn-version}" api-name="{apidata/@name}" category="{cdx:api-subgroup(.)}">
          <xsl:variable name="container" select="containers/(type,namespace)[1]/@api/cdx:get-api(., $apis)" />
          
          <xsl:if test="$container">
            <xsl:attribute name="container-name" select="$container/apidata/@name" />
          </xsl:if>
                     
          <!--xsl:attribute name="cdx:uri" select="xs:anyURI(concat('http://msdn.microsoft.com/en-us/library/', cdx:msdn(@id), '.aspx'))" /-->
          <xsl:attribute name="msdn-id" select="cdx:msdn(@id)" />
          
          <xsl:if test="exists($text)">
            <xsl:attribute name="cdx:text" select="$text" />
          </xsl:if>
          
          <xsl:apply-templates select="templates/template" mode="type" />
          <xsl:apply-templates select="parameters/parameter" mode="type" />
        </cdx:externalCodeEntityReference>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="api-link">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="qualify-hint" as="xs:boolean?" select="()"/>
    <xsl:param name="auto-upgrade" as="xs:boolean" select="false()" />
    <xsl:param name="subgroup" as="xs:string?" select="()" />
    <xsl:param name="typeparams" as="xs:boolean" select="true()" />
		<xsl:param name="target-version" as="xs:string?" select="()" />
		<xsl:param name="version" tunnel="yes" />
		
		<xsl:choose>
			<xsl:when test="$version != $target-version">
				<codeEntityReference autoUpgrade="{$auto-upgrade}" qualifyHint="{$qualify-hint}" cdx:typeParams="{$typeparams}" cdx:version="{$target-version}">
					<xsl:value-of select="if (exists($subgroup)) then cdx:subgroup-id($id, $subgroup) else $id" />
				</codeEntityReference>
			</xsl:when>

			<xsl:otherwise>
				<!-- we deviate from the schema here to resolve the codeEntityReferences-->
    
				<xsl:variable name="api" select="cdx:get-api($id, $apis)" />
        
				<xsl:choose>
					<xsl:when test="exists($qualify-hint)">
						<xsl:apply-templates select="$api" mode="api-link">
							<xsl:with-param name="qualify-hint" select="$qualify-hint" />
							<xsl:with-param name="auto-upgrade" select="$auto-upgrade" />
							<xsl:with-param name="subgroup" select="$subgroup" />
							<xsl:with-param name="typeparams" select="$typeparams" />
						</xsl:apply-templates>
					</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$api" mode="api-link">
						<xsl:with-param name="auto-upgrade" select="$auto-upgrade" />
						<xsl:with-param name="subgroup" select="$subgroup" />
						<xsl:with-param name="typeparams" select="$typeparams" />
					</xsl:apply-templates>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:template>

</xsl:stylesheet>
