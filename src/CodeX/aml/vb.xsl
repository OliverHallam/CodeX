<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
		            exclude-result-prefixes="cdx syntax xs"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
	              xmlns:cdx="http://www.codexdocs.com/"
                xmlns:syntax="http://www.codexdocs.com/syntax"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="api[typedata]" mode="vb">
    <!-- serializable -->
    <xsl:if test="typedata/@serializable = 'true'">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates select="cdx:get-api('T:System.SerializableAttribute', $apis)" mode="api-link">
        <xsl:with-param name="text" select="'Serializable'" />
      </xsl:apply-templates>
      <xsl:text>&gt; _&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility -->
    <xsl:call-template name="vb-visibility">
      <xsl:with-param name="visibility" select="typedata/@visibility" />
    </xsl:call-template>
    <xsl:text> </xsl:text>

    <!-- abstract-->
    <xsl:if test="typedata/@abstract and apidata/@subgroup != 'interface'">
      <languageKeyword>MustInherit</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- sealed -->
    <xsl:if test="typedata/@sealed and apidata/@subgroup != 'enumeration'">
      <languageKeyword>NotInheritable</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="vb-signature" />
    
    <!-- inherits / implements -->
    <xsl:variable name="inherits" select="family/ancestors/type[last() gt 1][1]" />
    <xsl:if test="$inherits">
      <xsl:text> _&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      <languageKeyword>Inherits</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="$inherits" mode="vb" />
    </xsl:if>
    
    <xsl:for-each select="implements/*">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:text> _&#10;</xsl:text>
          <xsl:text>        </xsl:text>
          <languageKeyword>Implements</languageKeyword>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>, _&#10;</xsl:text>
          <xsl:text>                   </xsl:text>
        </xsl:otherwise>        
      </xsl:choose>
      
      <xsl:apply-templates select="." mode="vb" />
    </xsl:for-each>
  </xsl:template>
      
  <xsl:template match="api[memberdata]" mode="vb">
    <!-- constructors -->
    
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="vb" />
    
    <!-- signature-->
    <xsl:apply-templates select="." mode="vb-signature" />
  </xsl:template>

  <xsl:template match="api[fielddata]" mode="vb">
    <!-- [NonSerialized] -->
    <xsl:if test="fielddata/@serialized = 'false'">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates select="cdx:get-api('T:System.NonSerializedAttribute', $apis)" mode="api-link">
          <xsl:with-param name="text" select="'NonSerialized'" />
        </xsl:apply-templates>
      <xsl:text>&gt; _&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="vb" />
    
    <!-- initonly -->
    <xsl:if test="fielddata/@initonly">
      <languageKeyword>ReadOnly</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <!-- NOTE: there is no VB representation for volatile -->
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="vb-signature" />
  </xsl:template>

  <xsl:template match="api[proceduredata]" mode="vb">
    <!-- visibility, static -->
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <xsl:apply-templates select="memberdata" mode="vb" />
      <!-- NOTE: static should not come up in the interface case! -->
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="vb" />
    </xsl:if>
    
    <!-- signature-->
    <xsl:apply-templates select="." mode="vb-signature" />
  </xsl:template>

  <xsl:template match="api[propertydata]" mode="vb">
    <!--TODO: indexers-->
    
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="vb" />
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="vb" />
    </xsl:if>
    
    <xsl:variable name="show-get" select="propertydata/@get = 'true' and not($hide-private-accessors and propertydata/@get-visibility='private')" />
    <xsl:variable name="show-set" select="propertydata/@set = 'true' and not($hide-private-accessors and propertydata/@set-visibility='private')" />

    <xsl:if test="not($show-get)">
      <languageKeyword>WriteOnly</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <xsl:if test="not($show-set)">
      <languageKeyword>ReadOnly</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <xsl:apply-templates select="." mode="vb-signature" />

    <!-- get -->
    <xsl:if test="$show-get">
      <xsl:text>&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      
      <!-- visibility -->
      <xsl:if test="propertydata/@get-visibility">
        <xsl:call-template name="vb-visibility">
          <xsl:with-param name="visibility" select="propertydata/@get-visibility" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
      
      <languageKeyword>Get</languageKeyword>
    </xsl:if>
 
    <!-- set -->
    <xsl:if test="$show-set">
      <xsl:text>&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      
      <!-- visibility -->
      <xsl:if test="propertydata/@set-visibility">
        <xsl:call-template name="vb-visibility">
          <xsl:with-param name="visibility" select="propertydata/@set-visibility" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
     
      <languageKeyword>Set</languageKeyword>
      <xsl:text>(</xsl:text>
      <languageKeyword>ByVal</languageKeyword>
      <xsl:text> value </xsl:text>
      <languageKeyword>As</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="returns/*" mode="vb" />
      <xsl:text>)</xsl:text>
    </xsl:if>
 </xsl:template>

  <xsl:template match="api[eventdata]" mode="vb">
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="vb" />
    
      <!-- abstract, virtual, sealed, override -->
      <xsl:apply-templates select="proceduredata" mode="vb" />
    </xsl:if>
    
    <xsl:apply-templates select="." mode="vb-signature" />

    <xsl:variable name="show-add" select="eventdata/@add = 'true' and not($hide-private-accessors and eventdata/@add-visibility='private')" />
    <xsl:variable name="show-remove" select="eventdata/@remove = 'true' and not($hide-private-accessors and eventdata/@remove-visibility='private')" />
    
    <!-- only display the rest if non-default -->
    <xsl:if test="(eventdata/@add-visibility and $show-add) or
                  (eventdata/@remove-visibility and $show-remove)">

      <xsl:if test="$show-add">
        <!-- add -->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>        </xsl:text>
      
        <!-- visibility -->
        <xsl:if test="propertydata/@add-visibility">
          <xsl:call-template name="vb-visibility">
            <xsl:with-param name="visibility" select="propertydata/@add-visibility" />
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>
      
        <languageKeyword>AddHandler</languageKeyword>
        <xsl:text>(</xsl:text>
        <languageKeyword>ByVal</languageKeyword>
        <xsl:text> value </xsl:text>
        <languageKeyword>As</languageKeyword>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="eventhandler/*" mode="vb" />
        <xsl:text>)</xsl:text>
      </xsl:if>
      
      <!-- remove -->
      <xsl:if test="$show-remove">
      
        <xsl:text>&#10;</xsl:text>
        <xsl:text>        </xsl:text>
      
        <!-- visibility -->
        <xsl:if test="propertydata/@remove-visibility">
          <xsl:call-template name="vb-visibility">
            <xsl:with-param name="visibility" select="propertydata/@remove-visibility" />
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>
      
        <languageKeyword>RemoveHandler</languageKeyword>
        <xsl:text>(</xsl:text>
        <languageKeyword>ByVal</languageKeyword>
        <xsl:text> value </xsl:text>
        <languageKeyword>As</languageKeyword>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="eventhandler/*" mode="vb" />
        <xsl:text>)</xsl:text>
      </xsl:if>
      
      <!-- TODO: RaiseEvent -->
    </xsl:if>
  </xsl:template>

  <xsl:template match="memberdata"
                mode="vb">
    <!-- visibility -->
    <xsl:call-template name="vb-visibility">
      <xsl:with-param name="visibility" select="@visibility" />
    </xsl:call-template>
    <xsl:text> </xsl:text>

    <!-- static -->
    <xsl:if test="@static = 'true'">
      <languageKeyword>Shared</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
    
    <!-- special, default -->
  </xsl:template>
  
  <xsl:template match="proceduredata" mode="vb">
    <xsl:choose>
      <xsl:when test="../overrides">
        <xsl:if test="@final = 'true'">
          <languageKeyword>NotOverridable</languageKeyword>
          <xsl:text> </xsl:text>
        </xsl:if>
        
        <xsl:if test="@abstract = 'true'">
          <languageKeyword>MustOverride</languageKeyword>
          <xsl:text> </xsl:text>
        </xsl:if>

        <languageKeyword>Overrides</languageKeyword>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@virtual = 'true'">
        <xsl:choose>
          <xsl:when test="@final = 'true'" />
          <xsl:when test="@abstract = 'true'">
            <languageKeyword>MustOverride</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <languageKeyword>Overridable</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="vb-visibility">
    <xsl:param name="visibility" />
    <xsl:choose>
      <xsl:when test="$visibility = 'private'">
        <languageKeyword>Private</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'family'">
        <languageKeyword>Protected</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'public'">
        <languageKeyword>Public</languageKeyword>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Visibility <xsl:value-of select="$visibility" /> not supported.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="api[typedata]" mode="vb-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subgroup = 'interface'">
        <languageKeyword>Interface</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'class'">
        <languageKeyword>Class</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'struct'">
        <languageKeyword>Structure</languageKeyword>
      </xsl:when>
      <xsl:when test="apidata/@subgroup = 'enumeration'">
        <languageKeyword>Enumeration</languageKeyword>
      </xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
    <!-- TODO: generic constraints -->
  </xsl:template>
  
  <xsl:template match="api[memberdata]" mode="vb-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subsubgroup = 'operator'">
        <xsl:choose>
          <xsl:when test="apidata/@name = 'Implicit'">
            <languageKeyword>Widening</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Explicit'">
            <languageKeyword>Narrowing</languageKeyword>
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
       
        <languageKeyword>Operator</languageKeyword>
        <xsl:text> </xsl:text>

        <xsl:choose>
          <xsl:when test="apidata/@name = 'Equality'">
            <xsl:text>=</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Inequality'">
            <xsl:text>&lt;&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThan'">
            <xsl:text>&lt;</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThanOrEqual'">
            <xsl:text>&lt;=</xsl:text>
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
            <xsl:text>Mod</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Multiply'">
            <xsl:text>*</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = ('Implicit','Explicit')">
            <xsl:apply-templates select="returns/*" mode="vb" />
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="apidata/@subgroup='constructor'">
        <languageKeyword>Sub</languageKeyword>
        <xsl:text> </xsl:text>
        <languageKeyword>New</languageKeyword>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="returns">
            <languageKeyword>Function</languageKeyword>
          </xsl:when>
          <xsl:otherwise>
            <languageKeyword>Sub</languageKeyword>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="apidata/@name" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="templates[template]" mode="vb" />
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <xsl:text>()</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="vb" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="returns">
      <xsl:text> </xsl:text>
      <languageKeyword>As</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="returns/*" mode="vb" />
    </xsl:if>
    
    <xsl:if test="proceduredata/@eii">
      <xsl:text> _&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      <languageKeyword>Implements</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="cdx:get-api(implements/member/@api, $apis)" mode="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
      </xsl:apply-templates>
    </xsl:if>
    <!-- TODO: generic constraints -->
  </xsl:template>

  <xsl:template match="api[fielddata]" mode="vb-signature">
    <xsl:value-of select="apidata/@name" />
    <xsl:text> </xsl:text>
    <languageKeyword>As</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="returns/*" mode="vb" />
  </xsl:template>
  
  <xsl:template match="api[propertydata]" mode="vb-signature">
    <languageKeyword>Property</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
    <xsl:text> </xsl:text>
    <languageKeyword>As</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="returns/*" mode="vb" />
    
    <xsl:if test="proceduredata/@eii">
      <xsl:text> _&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      <languageKeyword>Implements</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="cdx:get-api(implements/member/@api, $apis)" mode="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="api[eventdata]" mode="vb-signature">
    <languageKeyword>Event</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
    <xsl:text> </xsl:text>
    <languageKeyword>As</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="eventhandler/*" mode="vb" />
    
    <xsl:if test="proceduredata/@eii">
      <xsl:text> _&#10;</xsl:text>
      <xsl:text>        </xsl:text>
      <languageKeyword>Implements</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="cdx:get-api(implements/member/@api, $apis)" mode="api-link">
        <xsl:with-param name="qualify-hint" select="true()" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="arrayOf"
                mode="vb">
    <xsl:apply-templates select="*" mode="vb" />
    <xsl:text>[]</xsl:text>
  </xsl:template>

  <xsl:template match="pointerTo"
                mode="vb">
    <xsl:apply-templates select="*" mode="vb" />
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="referenceTo"
                mode="vb">
    <languageKeyword>ByRef</languageKeyword>
    <xsl:text> </xsl:text>

    <xsl:apply-templates select="*" mode="vb" />
  </xsl:template>

  <xsl:template match="type[specialization]"
                mode="vb">
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@api" />
      <xsl:with-param name="typeparams" select="false()" />
    </xsl:call-template>
    <xsl:apply-templates select="*" mode="vb" />
  </xsl:template>

  <xsl:template match="type"
                mode="vb">
    <xsl:apply-templates select="cdx:get-api(@api, $apis)" mode="api-link" />
  </xsl:template>

  <xsl:template match="specialization"
                mode="vb">
    <xsl:text>(Of </xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="vb" />
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="parameters"
                mode="vb">
    <xsl:text>( _&#10;</xsl:text>
    <xsl:apply-templates select="parameter" mode="vb" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="parameter"
                mode="vb">
    <xsl:text>    </xsl:text>
    <xsl:if test="@out='true'">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates select="cdx:get-api('T:System.Runtime.InteropServices.OutAttribute', $apis)" mode="api-link">
        <xsl:with-param name="text" select="'Out'" />
      </xsl:apply-templates>
      <xsl:text>&gt;</xsl:text>
    </xsl:if>

    <xsl:value-of select="@name" />
    <xsl:text> </xsl:text>
    <languageKeyword>As</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*" mode="vb" />
    <xsl:if test="position() != last()">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text> _&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="templates"
                mode="vb">
    <xsl:text>(Of </xsl:text>
    <xsl:for-each select="template">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@name" />
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

</xsl:stylesheet>
