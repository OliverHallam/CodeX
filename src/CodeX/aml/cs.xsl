<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
            		exclude-result-prefixes="cdx syntax xs xsl"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
                xmlns:cdx="http://www.codexdocs.com/"
                xmlns:syntax="http://www.codexdocs.com/syntax"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="api[typedata]" mode="cs">
    <!-- serializable -->
    <xsl:if test="typedata/@serializable='true'">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="cdx:get-api('T:System.SerializableAttribute', $apis)" mode="api-link">
        <xsl:with-param name="text" select="'Serializable'" />
      </xsl:apply-templates>
      <xsl:text>]&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility -->
    <xsl:call-template name="cs-visibility">
      <xsl:with-param name="visibility" select="typedata/@visibility" />
    </xsl:call-template>
    <xsl:text> </xsl:text>

    <!-- abstract -->
    <xsl:if test="typedata/@abstract = 'true' and apidata/@subgroup != 'interface'">
      <languageKeyword>abstract</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- sealed -->
    <xsl:if test="typedata/@sealed and apidata/@subgroup != 'enumeration'">
      <languageKeyword>sealed</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="cs-signature" />
    
    <!-- inherits / implements -->
    <xsl:for-each select="(family/ancestors/type[last() gt 1][1], implements/*)">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:text> : </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>,&#10;</xsl:text>
          <xsl:text>        </xsl:text>
        </xsl:otherwise>        
      </xsl:choose>
      
      <xsl:apply-templates select="." mode="cs" />
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="api[memberdata]" mode="cs">
    <!-- constructors -->
    
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="cs" />
    <xsl:text> </xsl:text>
    
    <!-- signature-->
    <xsl:apply-templates select="." mode="cs-signature" />
  </xsl:template>
  
  <xsl:template match="api[fielddata]" mode="cs">
    <!-- [NonSerialized] -->
    <xsl:if test="fielddata/@serialized = 'false'">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="cdx:get-api('T:System.NonSerializedAttribute', $apis)" mode="api-link">
          <xsl:with-param name="text" select="'NonSerialized'" />
        </xsl:apply-templates>
      <xsl:text>]&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="cs" />
    <xsl:text> </xsl:text>
    
    <!-- initonly -->
    <xsl:if test="fielddata/@initonly">
      <languageKeyword>readonly</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <!-- volatile -->
    <xsl:if test="fielddata/@volatile">
      <languageKeyword>volatile</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="cs-signature" />
  </xsl:template>
  
  
  <xsl:template match="api[proceduredata]" mode="cs">
    <!-- visibility, static -->
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <xsl:apply-templates select="memberdata" mode="cs" />
      <xsl:text> </xsl:text>
      <!-- NOTE: static should not come up in the interface case! -->
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="cs" />
    </xsl:if>    
    
    <!-- signature-->
    <xsl:apply-templates select="." mode="cs-signature" />
  </xsl:template>
  
  <xsl:template match="api[propertydata]" mode="cs">
    <!--TODO: indexers-->
    
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="cs" />
      <xsl:text> </xsl:text>
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="cs" />
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="cs-signature" />

    <xsl:text> { </xsl:text>

    <xsl:variable name="show-get" select="propertydata/@get = 'true' and not($hide-private-accessors and propertydata/@get-visibility='private')" />
    <xsl:variable name="show-set" select="propertydata/@set = 'true' and not($hide-private-accessors and propertydata/@set-visibility='private')" />

    <!-- get -->
    <xsl:if test="$show-get">
      <!-- visibility -->
      <xsl:if test="propertydata/@get-visibility">
        <xsl:call-template name="cs-visibility">
          <xsl:with-param name="visibility" select="propertydata/@get-visibility" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
      
      <languageKeyword>get</languageKeyword>
      <xsl:text>; </xsl:text>
    </xsl:if>
    
    <!-- set -->
    <xsl:if test="$show-set">
      <!-- visibility -->
      <xsl:if test="propertydata/@set-visibility">
        <xsl:call-template name="cs-visibility">
          <xsl:with-param name="visibility" select="propertydata/@set-visibility" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
      
      <languageKeyword>set</languageKeyword>
      <xsl:text>; </xsl:text>
    </xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="api[eventdata]" mode="cs">
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="cs" />
      <xsl:text> </xsl:text>
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="cs" />
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="cs-signature" />

    <xsl:variable name="show-add" select="eventdata/@add = 'true' and not($hide-private-accessors and eventdata/@add-visibility='private')" />
    <xsl:variable name="show-remove" select="eventdata/@remove = 'true' and not($hide-private-accessors and eventdata/@remove-visibility='private')" />
    
    <!-- only display the rest if non-default -->
    <xsl:if test="(eventdata/@add-visibility and $show-add) or
                  (eventdata/@remove-visibility and $show-remove)">
      <xsl:text> { </xsl:text>

      <!-- add -->
      <xsl:if test="$show-add">
        <!-- visibility -->
        <xsl:if test="eventdata/@add-visibility">
          <xsl:call-template name="cs-visibility">
            <xsl:with-param name="visibility" select="eventdata/@add-visibility" />
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>
      
        <languageKeyword>add</languageKeyword>
        <xsl:text>; </xsl:text>
      </xsl:if>
      
      <!-- remove -->
      <xsl:if test="$show-remove">
        <!-- visibility -->
        <xsl:if test="eventdata/@remove-visibility">
          <xsl:call-template name="cs-visibility">
            <xsl:with-param name="visibility" select="eventdata/@remove-visibility" />
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>
      
        <languageKeyword>remove</languageKeyword>
        <xsl:text>; </xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
      
      <!-- TODO: raise-->
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="memberdata" mode="cs">
    <!-- visibility -->
    <xsl:call-template name="cs-visibility">
      <xsl:with-param name="visibility" select="@visibility" />
    </xsl:call-template>
    
    <!-- static -->
    <xsl:if test="@static = 'true'">
      <xsl:text> </xsl:text>
      <languageKeyword>static</languageKeyword>
    </xsl:if>

    <!-- special, default -->
  </xsl:template>
  
  <xsl:template match="proceduredata" mode="cs">
    <xsl:choose>
      <xsl:when test="../overrides">
        <xsl:if test="@final = 'true'">
          <languageKeyword>sealed</languageKeyword>
          <xsl:text> </xsl:text>
        </xsl:if>
        
        <xsl:if test="@abstract = 'true'">
          <languageKeyword>abstract</languageKeyword>
          <xsl:text> </xsl:text>
        </xsl:if>

        <languageKeyword>override</languageKeyword>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@virtual = 'true'">
        <xsl:choose>
          <xsl:when test="@final = 'true'" />
          <xsl:when test="@abstract = 'true'">
            <languageKeyword>abstract</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <languageKeyword>virtual</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="cs-visibility">
    <xsl:param name="visibility" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$visibility = 'private'">
        <languageKeyword>private</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'family'">
        <languageKeyword>protected</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'public'">
        <languageKeyword>public</languageKeyword>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Visibility <xsl:value-of select="$visibility" /> not supported.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="api[typedata]" mode="cs-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subgroup = 'interface'">
        <languageKeyword>interface</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'class'">
        <languageKeyword>class</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'struct'">
        <languageKeyword>struct</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'enumeration'">
        <languageKeyword>enum</languageKeyword>
      </xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
    
    <!-- TODO: generic constraints -->
  </xsl:template>
  
  <xsl:template match="api[memberdata]"
                mode="cs-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subsubgroup = 'operator'">
        <xsl:choose>
          <xsl:when test="apidata/@name = 'Implicit'">
            <languageKeyword>implicit</languageKeyword>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Explicit'">
            <languageKeyword>explicit</languageKeyword>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="returns">
                <xsl:apply-templates select="returns/*" mode="cs" />
              </xsl:when>
              <xsl:otherwise>
                <languageKeyword>void</languageKeyword>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:text> </xsl:text>
        <languageKeyword>operator</languageKeyword>
        <xsl:text> </xsl:text>
        
        <xsl:choose>
          <xsl:when test="apidata/@name = 'Equality'">
            <xsl:text>==</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Inequality'">
            <xsl:text>!=</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThan'">
            <xsl:text>&lt;</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThanOrEqual'">
            <xsl:text>&lt;</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'GreaterThan'">
            <xsl:text>&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'GreaterThanOrEqual'">
            <xsl:text>&gt;=</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Addition'">
            <xsl:text>+</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Subtraction'">
            <xsl:text>-</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'UnaryPlus'">
            <xsl:text>+</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'UnaryNegation'">
            <xsl:text>-</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Division'">
            <xsl:text>/</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Modulus'">
            <xsl:text>%</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Multiply'">
            <xsl:text>*</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = ('Implicit','Explicit')">
            <xsl:apply-templates select="returns/*" mode="cs" />
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="apidata/@subgroup='constructor'">
        <xsl:variable name="container" select="cdx:get-api(containers/type/@api, $apis)" />
        <xsl:value-of select="$container/apidata/@name" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="returns">
            <xsl:apply-templates select="returns/*" mode="cs" />
          </xsl:when>
          <xsl:otherwise>
            <languageKeyword>void</languageKeyword>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:text> </xsl:text>
        
        <xsl:if test="proceduredata/@eii">
          <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
          <xsl:text>.</xsl:text>
        </xsl:if>
        
        <xsl:value-of select="apidata/@name" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="templates[template]" mode="cs" />
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <xsl:text>()</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="cs" />
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- TODO: generic constraints -->
  </xsl:template>
    
  <xsl:template match="api[fielddata|propertydata]" mode="cs-signature">
    <xsl:apply-templates select="returns/*" mode="cs" />
    <xsl:text> </xsl:text>
    
    <xsl:if test="proceduredata/@eii">
      <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
      <xsl:text>.</xsl:text>
    </xsl:if>
    
    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
  <xsl:template match="api[eventdata]" mode="cs-signature">
    <languageKeyword>event</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="eventhandler/*" mode="cs" />
    <xsl:text> </xsl:text>
    
    <xsl:if test="proceduredata/@eii">
      <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
      <xsl:text>.</xsl:text>
    </xsl:if>

    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
  <xsl:template match="arrayOf"
                mode="cs">
    <xsl:apply-templates select="*" mode="cs" />
    <xsl:text>[]</xsl:text>
  </xsl:template>

  <xsl:template match="pointerTo"
                mode="cs">
    <xsl:apply-templates select="*" mode="cs" />
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="referenceTo"
                mode="cs">
    <xsl:choose>
      <xsl:when test="../@out='true'">
        <languageKeyword>out</languageKeyword>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <languageKeyword>ref</languageKeyword>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="*" mode="cs" />
  </xsl:template>

  <xsl:template match="type[@api='T:System.Nullable`1']" priority="10">
    <xsl:apply-templates select="specialization/*" mode="cs" />
    <xsl:text>?</xsl:text>
  </xsl:template>
  
  <xsl:template match="type[specialization]"
                mode="cs">
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@api" />
      <xsl:with-param name="typeparams" select="false()" />
    </xsl:call-template>
    <xsl:apply-templates select="*" mode="cs" />
  </xsl:template>

 
  <xsl:template match="type"
                mode="cs">
    <xsl:apply-templates select="cdx:get-api(@api, $apis)" mode="api-link" />
  </xsl:template>

  <xsl:template match="specialization"
                mode="cs">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="cs" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

   <xsl:template match="parameters"
                mode="cs">
    <xsl:text>(&#10;</xsl:text>
    <xsl:apply-templates select="parameter" mode="cs" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="parameter"
                mode="cs">
    <xsl:text>    </xsl:text>
    <xsl:apply-templates select="*" mode="cs" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@name" />
    <xsl:if test="position() != last()">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="templates"
                mode="cs">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="template">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@name" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
