<xsl:stylesheet version="2.0"
		            exclude-result-prefixes="ddue xs xsl"
                xmlns="http://www.codexdocs.com/"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:ddue="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="api-links.xsl"/>
      
  <xsl:template match="parameter" mode="type">
    <cdx:parameter>
      <xsl:apply-templates select="*" mode="type" />
    </cdx:parameter>
  </xsl:template>
  
  <xsl:template match="template" mode="type">
    <cdx:template-parameter name="{@name}" />
  </xsl:template>
  
  <xsl:template match="pointerTo" mode="type">
    <cdx:pointerTo>
      <xsl:apply-templates select="*" mode="type" />
    </cdx:pointerTo>
  </xsl:template>
  
  <xsl:template match="arrayOf" mode="type">
    <cdx:arrayOf>
      <xsl:apply-templates select="*" mode="type" />
    </cdx:arrayOf>
  </xsl:template>
  
  <xsl:template match="referenceTo" mode="type">
    <cdx:referenceTo>
      <xsl:copy-of select ="../@out" />
      <xsl:apply-templates select="*" mode="type" />
    </cdx:referenceTo>
  </xsl:template>
  
  <xsl:template match="type" mode="type">
    <xsl:variable name="type" select="cdx:get-api(@api, $apis)" />
    <cdx:type name="{$type/apidata/@name}" id="{@api}" ref="{@ref}">
      <xsl:apply-templates select="specialization/*" mode="type"/>
    </cdx:type>
  </xsl:template>
  
  <xsl:function name="cdx:api-subgroup" as="xs:string">
    <xsl:param name="arg" as="element(api)" />
    <xsl:sequence select="data(($arg/apidata/@subsubgroup, $arg/apidata/@subgroup, $arg/apidata/@group)[1])" />
  </xsl:function>
  
  <xsl:template name="namespace">
    <xsl:param name="namespace-apis" tunnel="no" />
    <xsl:param name="product" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />
    
    <xsl:variable name="id" select="$namespace-apis[1]/@id" />
    <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
    <xsl:variable name="filename" select="ddue:getFileName($id)" />

    <xsl:result-document href="{$href}">
      <xsl:call-template name="generate-namespace">
        <xsl:with-param name="namespace-apis" select="$namespace-apis" tunnel="no" />
      </xsl:call-template>
    </xsl:result-document>

    <topic href="{$href}" id="{$id}" filename="{$filename}" api-name="{$namespace-apis[1]/apidata/@name}" api-category="namespace">
      <xsl:for-each select="$namespace-apis/elements/element/cdx:get-api(@api, $apis)">
        <xsl:sort select="@api" />
        
        <xsl:apply-templates select="." mode="type" />
      </xsl:for-each>
    </topic>
  </xsl:template>
  
  <xsl:template match="api" mode="type">
    <!-- generates a topic for a type -->
    
    <xsl:param name="product-name" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="current-type" tunnel="yes" select="." />
    <xsl:param name="current" select="." tunnel="yes"/>
                
    <xsl:variable name="id" select="@id" as="xs:string"/>
    <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
    <xsl:variable name="filename" select="ddue:getFileName($id)" />

    <xsl:result-document href="{$href}">
      <xsl:call-template name="generate-api">
        <xsl:with-param name="api" select="." />
      </xsl:call-template>
    </xsl:result-document>

    <topic href="{$href}" id="{$id}" filename="{$filename}" api-name="{apidata/@name}" api-category="{cdx:api-subgroup(.)}">
      <xsl:apply-templates select="templates/template" mode="type" />

      <xsl:variable name="members" select="elements/element/cdx:get-api(@api, $apis)" />

      <xsl:choose>
        <xsl:when test="apidata/@subgroup = 'enumeration'">
          <!-- Enumerations have no child topics, just fragments -->
          <xsl:for-each select="$members">
            <topic fragment="{apidata/@name}" id="{@id}" api-name="{apidata/@name}" api-category="member" />
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- generate a topic for each group of members-->
          <xsl:for-each-group select="$members"
                              group-by="cdx:api-subgroup(.)">
        
            <xsl:sort select="index-of(('constructor', 'field', 'method', 'operator', 'property', 'event'), current-grouping-key())" />

            <xsl:choose>
              <xsl:when test="current-grouping-key()='constructor'">
                <!-- Constructors do not get their own page - this goes straight to the overload page -->
                <xsl:call-template name="members">
                  <xsl:with-param name="category" select="current-grouping-key()" tunnel="yes"/>
                  <xsl:with-param name="members" select="current-group()" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="member-group">
                  <xsl:with-param name="category" select="current-grouping-key()" tunnel="yes"/>
                  <xsl:with-param name="members" select="current-group()" />
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each-group>
        </xsl:otherwise>
      </xsl:choose>
    </topic>
  </xsl:template>
 
  <xsl:template name="member-group">
    <!-- generates a "members" topic, eg Methods, Events -->
    
    <xsl:param name="members" />
    
    <xsl:param name="category" tunnel="yes" />
    <xsl:param name="current" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="current-type" tunnel="yes" />
    
    <!-- do not output the group if the class does not add/override any of the members -->
    <xsl:if test="$members[containers/type/@api=$current/@id]"> 
      <xsl:variable name="id" select="cdx:subgroup-id($current/@id, $category)" />
      <xsl:variable name="filename" select="ddue:getFileName($id)" />
      <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
      
      <xsl:result-document href="{$href}">
        <xsl:call-template name="generate-members">
          <xsl:with-param name="members" select="$members" />
        </xsl:call-template>
      </xsl:result-document>
      
      <topic href="{$href}" id="{$id}" filename="{$filename}" api-category="{$category}" api-list="members">
        <xsl:call-template name="members">
          <xsl:with-param name="members" select="$members" />
        </xsl:call-template>
      </topic>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="members">
    <!-- generates the children of a members topic - a list of member and overload topics -->
    
    <xsl:param name="members" />
    
    <xsl:param name="category" tunnel="yes "/>
    <xsl:param name="current" tunnel="yes "/>
    <xsl:param name="product-apis" tunnel="yes" />
    
    
    <xsl:for-each-group select="$members"
                        group-by="string(.[proceduredata/@eii='true']/implements/member/type/@api)">
      <xsl:sort select="current-grouping-key()" />
      
      <xsl:for-each-group select="current-group()"
                          group-by="apidata/@name">
        <xsl:sort select="current-grouping-key()" />
      
        <xsl:if test="current-group()[containers/type/@api=$current/@id]">
          <xsl:choose>
            <xsl:when test="count(current-group()) > 1">
              <xsl:call-template name="overloads">
                <xsl:with-param name="members" select="current-group()" />
                <xsl:with-param name="member-name" select="current-grouping-key()" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="member">
                <xsl:with-param name="overloaded" select="false()" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="overloads">
    <!-- Generates an overloads topic for a set of methods-->
    
    <xsl:param name="members" />
    <xsl:param name="member-name" />
    
    <xsl:param name="category" tunnel="yes" />
    <xsl:param name="current" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />
    <xsl:param name="product-apis" tunnel="yes" />
    
    <xsl:variable name="member-id" select="if ($category='operator') then concat('op_', $member-name) else $member-name" />
    
    <!--TODO: investigate whether it is better to leave T: in the ID!-->
    <xsl:variable name="id" select="concat('Overload.', substring-after($current/@id, 'T:'), '.', $member-id)"/>
    <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
    <xsl:variable name="filename" select="ddue:getFileName($id)" />
    
    <xsl:result-document href="{$href}">
      <xsl:call-template name="generate-overloads">
        <xsl:with-param name="members" select="$members" />
      </xsl:call-template>
    </xsl:result-document>

    <topic href="{$href}" id="{$id}" filename="{$filename}" api-category="{$category}" api-name="{$members[1]/apidata/@name}" api-list="overloads">
      <xsl:apply-templates mode="member" select="$members[containers/type/@api=$current/@id]">
        <xsl:with-param name="overloaded" select="true()" />
      </xsl:apply-templates>
    </topic>
  </xsl:template>
  
  <xsl:template match="api" mode="member">
    <!-- generates a topic for a member -->
    <xsl:param name="overloaded" />
    
    <xsl:param name="current" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />
    <xsl:param name="product-name" tunnel="yes" />
    
    <xsl:variable name="id" select="@id" as="xs:string"/>
    <xsl:variable name="href" select="cdx:local-uri($id, $version)" />
    <xsl:variable name="filename" select="ddue:getFileName($id)" />
    
    <xsl:result-document href="{$href}">
      <xsl:call-template name="generate-api">
        <xsl:with-param name="current" select="."/>
        <xsl:with-param name="api" select="."/>
        <xsl:with-param name="overloaded" select="$overloaded" />
      </xsl:call-template>
    </xsl:result-document>
    
    <topic href="{$href}" id="{$id}" filename="{$filename}" api-name="{apidata/@name}" api-category="{cdx:api-subgroup(.)}">
      <xsl:if test="proceduredata/@eii">
        <cdx:explicit-interface>
          <xsl:apply-templates select="implements/member/*" mode="type" />
        </cdx:explicit-interface>
      </xsl:if>
      <xsl:apply-templates select="templates/template" mode="type" />
      <xsl:apply-templates select="parameters/parameter" mode="type" />
    </topic>
  </xsl:template>
</xsl:stylesheet>
