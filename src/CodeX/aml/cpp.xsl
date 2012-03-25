<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
            		exclude-result-prefixes="cdx syntax xs xsl"
                xmlns="http://ddue.schemas.microsoft.com/authoring/2003/5"
	              xmlns:cdx="http://www.codexdocs.com/"
                xmlns:syntax="http://www.codexdocs.com/syntax"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="api[typedata]" mode="cpp">
    <!-- serializable -->
    <xsl:if test="typedata/@serializable = 'true'">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="cdx:get-api('T:System.SerializableAttribute', $apis)" mode="api-link">
          <xsl:with-param name="text" select="'Serializable'" />
        </xsl:apply-templates>
      <xsl:text>]&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility -->
    <xsl:call-template name="cpp-visibility">
      <xsl:with-param name="visibility" select="typedata/@visibility" />
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:apply-templates select="templates" mode="cpp-generic" />

    <!-- signature -->
    <xsl:apply-templates select="." mode="cpp-signature" />

    <!-- abstract -->
    <xsl:if test="typedata/@abstract = 'true' and apidata/@subgroup != 'interface'">
      <xsl:text> </xsl:text>
      <languageKeyword>abstract</languageKeyword>
    </xsl:if>
    
    <!-- sealed -->
    <xsl:if test="typedata/@sealed = 'true' and apidata/@subgroup != 'enumeration'">
      <xsl:text> </xsl:text>
      <languageKeyword>sealed</languageKeyword>
    </xsl:if>

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
      
      <xsl:apply-templates select="." mode="cpp">
        <xsl:with-param name="ignore-ref" select="true()" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="api[memberdata]" mode="cpp">
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="cpp" />
   
    <!-- signature -->
    <xsl:apply-templates select="." mode="cpp-signature" />
  </xsl:template>
  
  <xsl:template match="api[fielddata]" mode="cpp">
    <!-- [NonSerialized] -->
    <xsl:if test="fielddata/@serialized = 'false'">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="cdx:get-api('T:System.NonSerializedAttribute', $apis)" mode="api-link">
          <xsl:with-param name="text" select="'NonSerialized'" />
        </xsl:apply-templates>
      <xsl:text>]&#10;</xsl:text>
    </xsl:if>
    
    <!-- visibility, static -->
    <xsl:apply-templates select="memberdata" mode="cpp" />
    
    <!-- initonly -->
    <xsl:if test="fielddata/@initonly">
      <languageKeyword>initonly</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <!-- volatile -->
    <xsl:if test="fielddata/@volatile">
      <languageKeyword>volatile</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>

    <!-- signature -->
    <xsl:apply-templates select="." mode="cpp-signature" />
  </xsl:template>
  
  <xsl:template match="api[proceduredata]" mode="cpp">
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="cpp" />
   
      <!-- virtual -->
      <xsl:apply-templates select="proceduredata" mode="cpp" />
    </xsl:if>
    
    <!-- signature -->
    <xsl:apply-templates select="." mode="cpp-signature" />
    
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <!-- sealed, abstract, overrides -->
      <xsl:apply-templates select="." mode="cpp-overrides" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="api[propertydata]" mode="cpp">
    <!--TODO: indexers-->
    
    <xsl:variable name="is-interface-member" select="syntax:is-interface(containers/type/@api, $apis)" />
    <xsl:variable name="explicit-overrides" select="proceduredata/(@abstract, @final) = 'true' and not($is-interface-member)" />
    
    <xsl:if test="not($is-interface-member)">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="cpp" />
   
      <xsl:if test="not($explicit-overrides)">
        <!-- virtual -->
        <xsl:apply-templates select="proceduredata" mode="cpp" />
      </xsl:if>
    </xsl:if>
          
    <xsl:apply-templates select="." mode="cpp-signature" />
    
    <xsl:text> {&#10;</xsl:text>
    
    <xsl:variable name="show-get" select="propertydata/@get = 'true' and (not($hide-private-accessors and propertydata/@get-visibility='private') or proceduredata/@eii)" />
    <xsl:variable name="show-set" select="propertydata/@set = 'true' and (not($hide-private-accessors and propertydata/@set-visibility='private') or proceduredata/@eii)" />
   
    <!--BUG: virtualness is per-accessor  --> 
    <xsl:if test="$show-get">
      <xsl:text>    </xsl:text>
      
      <!-- visibility -->
      <xsl:if test="propertydata/@get-visibility">
        <xsl:call-template name="cpp-visibility">
          <xsl:with-param name="visibility" select="propertydata/@get-visibility" />
        </xsl:call-template>
        <xsl:text>:&#10;</xsl:text>
        <xsl:text>    </xsl:text>
      </xsl:if>

      <xsl:if test="$explicit-overrides">
        <!-- virtual -->
        <xsl:apply-templates select="proceduredata" mode="cpp" />
      </xsl:if>
      
      <xsl:apply-templates select="returns/*" mode="cpp" />
      <xsl:text> </xsl:text>

      <xsl:if test="proceduredata/@eii">
        <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
        <xsl:text>::</xsl:text>
      </xsl:if>

      <languageKeyword>get</languageKeyword>
      <xsl:text>()</xsl:text>
      
      <xsl:if test="$explicit-overrides">
        <!-- sealed, abstract, overrides -->
        <xsl:apply-templates select="." mode="cpp-overrides" />
      </xsl:if>
      
      <xsl:text>;&#10;</xsl:text>
    </xsl:if>
    
    <xsl:if test="$show-set">
      <xsl:text>    </xsl:text>
      
      <!-- visibility -->
      <!-- display if the visibility of the setter is different to the visibility of the getter-->
      <xsl:if test="(propertydata/@set-visibility, memberdata/@visibility)[1] != 
                    (propertydata/@get-visibility[$show-get], memberdata/@visibility)[1]">
        <xsl:call-template name="cpp-visibility">
          <xsl:with-param name="visibility" select="(propertydata/@set-visibility, memberdata/@visibility)[1]" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
      
      <xsl:if test="$explicit-overrides">
        <!-- virtual -->
        <xsl:apply-templates select="proceduredata" mode="cpp" />
      </xsl:if>
      
      <languageKeyword>void</languageKeyword>
      <xsl:text> </xsl:text>

      <xsl:if test="proceduredata/@eii">
        <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
        <xsl:text>::</xsl:text>
      </xsl:if>

      <languageKeyword>set</languageKeyword>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="returns/*" mode="cpp" />
      <xsl:text> </xsl:text>
      <xsl:text>value</xsl:text>
      <xsl:text>)</xsl:text>
      
      <xsl:if test="$explicit-overrides">
        <!-- sealed, abstract, overrides -->
        <xsl:apply-templates select="." mode="cpp-overrides" />
      </xsl:if>

      <xsl:text>;&#10;</xsl:text>
    </xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- TODO: delegates! -->
  
  <xsl:template match="api[eventdata]" mode="cpp">
    <xsl:variable name="is-interface-member" select="syntax:is-interface(containers/type/@api, $apis)" />
    <xsl:variable name="explicit-overrides" select="proceduredata/(@abstract, @final) = 'true' and not($is-interface-member)" />
    
    <xsl:if test="not($is-interface-member)">
      <!-- visibility, static -->
      <xsl:apply-templates select="memberdata" mode="cpp" />
   
      <!-- virtual -->
      <xsl:apply-templates select="proceduredata" mode="cpp" />
    </xsl:if>

    <!-- signature-->
    <xsl:apply-templates select="." mode="cpp-signature" />
    
    <xsl:text> {&#10;</xsl:text>
    
    <xsl:variable name="show-add" select="eventdata/@add = 'true' and (not($hide-private-accessors and eventdata/@add-visibility='private') or proceduredata/@eii)" />
    <xsl:variable name="show-remove" select="eventdata/@remove = 'true' and (not($hide-private-accessors and eventdata/@remove-visibility='private') or proceduredata/@eii)" />
    
    <!--BUG: virtualness is per-accessor  --> 
    <xsl:if test="$show-add">
      <xsl:text>    </xsl:text>
      
      <!-- visibility -->
      <xsl:if test="propertydata/@add-visibility">
        <xsl:call-template name="cpp-visibility">
          <xsl:with-param name="visibility" select="eventdata/@add-visibility" />
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>    </xsl:text>
      </xsl:if>
      
      <languageKeyword>void</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:if test="proceduredata/@eii">
        <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
        <xsl:text>::</xsl:text>
      </xsl:if>
      <languageKeyword>add</languageKeyword>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="eventhandler/*" mode="cpp" />
      <xsl:text> </xsl:text>
      <xsl:text>value</xsl:text>
      <xsl:text>)</xsl:text>
      
      <!-- sealed, abstract, overrides -->
      <xsl:apply-templates select="." mode="cpp-overrides" />
      
      <xsl:text>;&#10;</xsl:text>
    </xsl:if>
      
    <xsl:if test="$show-remove">
      <xsl:text>    </xsl:text>
      
      <!-- visibility -->
      <!-- display if the visibility of the setter is different to the visibility of the getter-->
      <xsl:if test="(eventdata/@remove-visibility, memberdata/@visibility)[1] != 
                    (eventdata/@add-visibility[$show-add], memberdata/@visibility)[1]">
        <xsl:call-template name="cpp-visibility">
          <xsl:with-param name="visibility" select="(propertydata/@remove-visibility, memberdata/@visibility)[1]" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:if>
      
      <xsl:if test="$explicit-overrides">
        <!-- virtual -->
        <xsl:apply-templates select="proceduredata" mode="cpp" />
      </xsl:if>
      
      <languageKeyword>void</languageKeyword>
      <xsl:text> </xsl:text>
      <xsl:if test="proceduredata/@eii">
        <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
        <xsl:text>::</xsl:text>
      </xsl:if>
      <languageKeyword>remove</languageKeyword>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="eventhandler/*" mode="cpp" />
      <xsl:text> </xsl:text>
      <xsl:text>value</xsl:text>
      <xsl:text>)</xsl:text>
      
      <xsl:if test="$explicit-overrides">
        <!-- sealed, abstract, overrides -->
        <xsl:apply-templates select="." mode="cpp-overrides" />
      </xsl:if>

      <xsl:text>;&#10;</xsl:text>
    </xsl:if>
    
    <!--TODO: raise-->
    
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="memberdata" mode="cpp">
    <!-- visibility -->
    <xsl:call-template name="cpp-visibility">
      <xsl:with-param name="visibility" select="@visibility" />
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    
    <!-- TODO: pull this bit out of memberdata -->
    <xsl:apply-templates select="../templates" mode="cpp-generic" />
    
    <!-- static-->
    <xsl:if test="@static = 'true'">
      <languageKeyword>static</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="proceduredata" mode="cpp">
    <!-- virtual -->
    <xsl:if test="@virtual = 'true'">
      <languageKeyword>virtual</languageKeyword>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="cpp-visibility">
    <xsl:param name="visibility" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$visibility = 'private'">
        <languageKeyword>private:</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'family'">
        <languageKeyword>protected:</languageKeyword>
      </xsl:when>
      <xsl:when test="$visibility = 'public'">
        <languageKeyword>public:</languageKeyword>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Visibility <xsl:value-of select="$visibility" /> not supported.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="api[typedata]" mode="cpp-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subgroup = 'enumeration'">
        <languageKeyword>enum</languageKeyword>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="apidata/@subgroup = 'interface'">
            <languageKeyword>interface</languageKeyword>
          </xsl:when>
          <xsl:when test="apidata/@subgroup = 'class'">
            <languageKeyword>ref</languageKeyword>
          </xsl:when>
          <xsl:when test="apidata/@subgroup = 'structure'">
            <languageKeyword>value</languageKeyword>
          </xsl:when>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <languageKeyword>class</languageKeyword>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
    <xsl:template match="api[memberdata]" mode="cpp-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subsubgroup = 'operator'">
        <xsl:choose>
          <xsl:when test="apidata/@name = 'Implicit'" />
          <xsl:when test="apidata/@name = 'Explicit'">
            <languageKeyword>explicit</languageKeyword>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="returns">
                <xsl:apply-templates select="returns/*" mode="cpp" />
              </xsl:when>
              <xsl:otherwise>
                <languageKeyword>void</languageKeyword>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        
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
            <xsl:text>%</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Multiply'">
            <xsl:text>*</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = ('Implicit','Explicit')">
            <xsl:apply-templates select="returns/*" mode="cpp" />
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
            <xsl:apply-templates select="returns/*" mode="cpp" />
          </xsl:when>
          <xsl:otherwise>
            <languageKeyword>void</languageKeyword>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>

        <xsl:if test="proceduredata/@eii">
          <xsl:apply-templates select="cdx:get-api(implements/member/type/@api, $apis)" mode="api-link"/>
          <xsl:text>::</xsl:text>
        </xsl:if>
        
        <xsl:value-of select="apidata/@name" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="templates[template]" mode="cpp" />
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <xsl:text>()</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="cpp" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="api[fielddata]" mode="cpp-signature">
    <xsl:apply-templates select="returns/*" mode="cpp" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
  <xsl:template match="api[propertydata]" mode="cpp-signature">
    <languageKeyword>property</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="returns/*" mode="cpp" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
  <xsl:template match="api[eventdata]" mode="cpp-signature">
    <languageKeyword>event</languageKeyword>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="eventhandler/*" mode="cpp" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="apidata/@name" />
  </xsl:template>
  
  <xsl:template match="api" mode="cpp-overrides">
    <!-- sealed -->
    <xsl:if test="proceduredata/@final = 'true'">
      <xsl:text> </xsl:text>
      <languageKeyword>sealed</languageKeyword>
    </xsl:if>

    <!-- abstract -->
    <xsl:if test="proceduredata/@abstract = 'true'">
      <xsl:text> </xsl:text>
      <languageKeyword>abstract</languageKeyword>
    </xsl:if>

    <!-- override -->
    <xsl:if test="overrides">
      <xsl:text> </xsl:text>
      <languageKeyword>override</languageKeyword>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="arrayOf"
                mode="cpp">
    <languageKeyword>array</languageKeyword>
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates select="*" mode="cpp" />
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="pointerTo"
                mode="cpp">
    <xsl:apply-templates select="*" mode="cpp" />
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="referenceTo"
                mode="cpp">
    <xsl:apply-templates select="*" mode="cpp" />
    <xsl:text>%</xsl:text>
  </xsl:template>

  <xsl:template match="type[specialization]"
                mode="cpp">
    <xsl:param name="ignore-ref" select="false()" as="xs:boolean" />
    
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@api" />
      <xsl:with-param name="typeparams" select="false()" />
    </xsl:call-template>
    <xsl:apply-templates select="*" mode="cpp" />
    
    <xsl:if test="not($ignore-ref) and @ref = 'true'">
      <xsl:text>^</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="type"
                mode="cpp">
    <xsl:variable name="api" select="cdx:get-api(@api, $apis)" />
    <xsl:apply-templates select="$api" mode="api-link" />

    <xsl:if test="@ref = 'true'">
      <xsl:text>^</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="specialization"
                mode="cpp">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="cpp" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="parameters"
                mode="cpp">
    <xsl:text>(&#10;</xsl:text>
    <xsl:apply-templates select="parameter" mode="cpp" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="parameter"
                mode="cpp">
    <xsl:text>    </xsl:text>
    <xsl:if test="@out='true'">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="cdx:get-api('T:System.Runtime.InteropServices.OutAttribute', $apis)" mode="api-link">
        <xsl:with-param name="text" select="'Out'" />
      </xsl:apply-templates>
      <xsl:text>] </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*" mode="cpp" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@name" />
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="templates"
                mode="cpp">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="template">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@name" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="templates"
                mode="cpp-generic">
    <languageKeyword>generic</languageKeyword>
    <xsl:text> &lt;</xsl:text>
    <xsl:for-each select="template">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="@name" />
    </xsl:for-each>
    <xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
