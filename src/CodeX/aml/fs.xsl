<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
		            exclude-result-prefixes="xqsd syntax xs"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xqsd="http://www.codexdocs.com/"
                xmlns:syntax="http://www.codexdocs.com/syntax"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="apidata" mode="fs">
    <xsl:apply-templates select="@subgroup" mode="fs" />
  </xsl:template>

  <xsl:template match="@subgroup[. = 'interface']" mode="fs">
    <span class="keyword">
      <xsl:text>interface</xsl:text>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@subgroup[. = 'class']" mode="fs">
    <span class="keyword">
      <xsl:text>class</xsl:text>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@subgroup[. = 'enumeration']" mode="fs">
    <span class="keyword">
      <xsl:text>enum</xsl:text>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@subgroup[. = 'structure']" mode="fs">
    <span class="keyword">
      <xsl:text>struct</xsl:text>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@subgroup[. = 'event']" mode="fs">
    <span class="keyword">
      <xsl:text>event</xsl:text>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="api[typedata]" mode="fs">
    <xsl:apply-templates select="typedata/@serializable" mode="fs" />
    <xsl:apply-templates select="typedata/@visibility" mode="fs" />
    <xsl:if test="apidata/@subgroup = 'class'">
      <xsl:apply-templates select="typedata/@abstract" mode="fs" />
      <xsl:apply-templates select="typedata/@sealed" mode="fs" />
    </xsl:if>
    <span class="keyword">type</span>
    <xsl:text> </xsl:text>
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@id" />
    </xsl:call-template>
    <xsl:text> = </xsl:text>
    <div class="type">
      <xsl:apply-templates select="apidata" mode="fs" />
      <xsl:apply-templates select="family/ancestors" mode="fs" />
      <xsl:apply-templates select="implements" mode="fs" />
      <span class="keyword">end</span>
    </div>
  </xsl:template>

  <xsl:template match="ancestors" mode="fs">
    <xsl:if test="count(type) &gt; 1">
      <div class="inherit">
        <span class="keyword">inherit</span>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="type[1]" mode="fs" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="api[memberdata/@special]" mode="fs">
    <xsl:apply-templates select="memberdata" mode="fs" />
    <span class="keyword">new</span>
    <xsl:text> : </xsl:text>
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <span class="keyword">
          <xsl:text>unit</xsl:text>
        </span>
        <xsl:text> -&gt; </xsl:text>
        <xsl:call-template name="api-link">
          <xsl:with-param name="id" select="containers/type/@api" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="fs">
          <xsl:with-param name="returns" select="containers/type" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="api[fielddata]" mode="fs">
    <xsl:apply-templates select="memberdata" mode="fs" />
    <xsl:apply-templates select="fielddata" mode="fs" />
    <xsl:apply-templates select="returns" mode="fs" />
    <xsl:call-template name="api-name">
      <xsl:with-param name="api" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="api[proceduredata]" mode="fs">
    <xsl:if test="not(syntax:is-interface(containers/type/@api, $apis))">
      <xsl:apply-templates select="memberdata" mode="fs" />
      <xsl:apply-templates select="proceduredata" mode="fs" />
    </xsl:if>
    <xsl:apply-templates select="." mode="fs-signature" />
  </xsl:template>

  <xsl:template match="api[propertydata]" mode="fs">
    <xsl:apply-templates select="memberdata" mode="fs" />
    <xsl:apply-templates select="proceduredata" mode="fs" />
    <xsl:apply-templates select="returns" mode="fs" />
    <xsl:call-template name="api-name">
      <xsl:with-param name="api" select="." />
    </xsl:call-template>
    <xsl:apply-templates select="propertydata" mode="fs" />
  </xsl:template>

  <xsl:template match="api[eventdata]" mode="fs">
    <xsl:apply-templates select="memberdata" mode="fs" />
    <xsl:apply-templates select="eventhandler" mode="fs" />
    <xsl:call-template name="api-name">
      <xsl:with-param name="api" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="returns"
                mode="fs">
    <xsl:apply-templates mode="fs" />
  </xsl:template>

  <xsl:template match="implements"
                mode="fs">
    <div class="implements">
      <span class="keyword">interface</span>
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="fs" />
    </div>
  </xsl:template>

  <xsl:template match="arrayOf"
                mode="fs">
    <xsl:apply-templates select="*" mode="fs" />
    <xsl:text>[]</xsl:text>
  </xsl:template>

  <xsl:template match="pointerTo"
                mode="fs">
    <xsl:apply-templates select="*" mode="fs" />
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="referenceTo"
                mode="fs">
    <xsl:text>out </xsl:text>
    <xsl:apply-templates select="*" mode="fs" />
  </xsl:template>

  <xsl:template match="type[specialization]"
                mode="fs">
    <xsl:call-template name="api-link">
      <xsl:with-param name="id" select="@api" />
      <xsl:with-param name="typeparams" select="false()" />
    </xsl:call-template>
    <xsl:apply-templates select="*" mode="fs" />
  </xsl:template>

  <xsl:function name="syntax:fs-builtin-name"
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
        <xsl:text>string</xsl:text>
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
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>


  <xsl:template match="type"
                mode="fs">
    <xsl:param name="product-apis" tunnel="yes" />
    <xsl:param name="version" tunnel="yes" />

    <xsl:choose>
      <xsl:when test="syntax:fs-builtin-name(@api)">
        <a href="{xqsd:uri(@api, $version, $product-apis)}">
          <xsl:copy-of select="syntax:fs-builtin-name(@api)" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="api-link">
          <xsl:with-param name="id" select="@api" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="fs" />
  </xsl:template>

  <xsl:template match="specialization"
                mode="fs">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="fs" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="@serializable[. = 'true']"
                mode="fs">
    <div class="attributes">
      <xsl:text>[</xsl:text>
      <a href="http://msdn2.microsoft.com/en-us/library/bcfsa90a">
        <xsl:text>Serializable</xsl:text>
      </a>
      <xsl:text>]</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="@serializable"
                mode="fs" />

  <xsl:template match="@visibility[. = 'private']"
                mode="fs" priority="100">
    <span class="keyword">private</span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@visibility[. = 'family']"
                mode="fs" priority="100">
    <span class="keyword">protected</span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@visibility[. = 'public']"
                mode="fs" priority="100">
    <!--
    <span class="keyword">public</span>
    <xsl:text> </xsl:text>
    -->
  </xsl:template>

  <xsl:template match="@visibility"
                mode="fs" />

  <xsl:template match="@sealed[. = 'true'] | @final[. = 'true']"
                mode="fs">
    <div class="attribute">
      <xsl:text>[&lt;SealedAttribute&gt;]</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="@sealed | @final"
                mode="fs" />

  <xsl:template match="@initonly[. = 'true']"
                mode="fs">
    <span class="keyword">readonly</span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@initonly"
                mode="fs" />

  <xsl:template match="@static[. = 'true']"
                mode="fs">
    <span class="keyword">static</span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@static"
                mode="fs" />

  <xsl:template match="@virtual[. = 'true']"
                mode="fs">
    <span class="keyword">virtual</span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@virtual"
                mode="fs" />

  <xsl:template match="@abstract[. = 'true']"
                mode="fs">
    <div class="attribute">
      <xsl:text>[&lt;AbstractClassAttribute&gt;]</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="@abstract"
                mode="fs" />

  <xsl:template match="proceduredata"
                priority="1"
                mode="fs">
    <xsl:choose>
      <xsl:when test="@final = 'true'" />
      <xsl:otherwise>
        <xsl:apply-templates select="(@abstract, @virtual)[1]" mode="fs" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="proceduredata"
                mode="fs" />

  <xsl:template match="memberdata"
                mode="fs">
    <xsl:apply-templates select="@visibility" mode="fs" />
    <xsl:apply-templates select="@static" mode="fs" />
    <!-- special, default -->
  </xsl:template>

  <xsl:template match="propertydata"
                mode="fs">
    <xsl:text> { </xsl:text>
    <xsl:if test="@get = 'true'">
      <xsl:apply-templates select="@get-visibility" mode="fs" />
      <xsl:text>get; </xsl:text>
    </xsl:if>
    <xsl:if test="@set = 'true'">
      <xsl:apply-templates select="@set-visibility" mode="fs" />
      <xsl:text>set; </xsl:text>
    </xsl:if>
    <xsl:text> } </xsl:text>
  </xsl:template>

  <xsl:template match="fielddata"
                mode="fs">
    <xsl:apply-templates select="@initonly" mode="fs" />
    <xsl:apply-templates select="@volatile" mode="fs" />
    <!-- serialized -->
  </xsl:template>

  <xsl:template match="@get-visibility | @set-visibility"
                mode="fs">
    <xsl:choose>
      <xsl:when test=". = 'public'">
        <xsl:text>public </xsl:text>
      </xsl:when>
      <xsl:when test=". = 'family'">
        <xsl:text>protected </xsl:text>
      </xsl:when>
      <xsl:when test=". = 'assembly'">
        <xsl:text>internal </xsl:text>
      </xsl:when>
      <xsl:when test=". = 'family or assembly'">
        <xsl:text>protected internal </xsl:text>
      </xsl:when>
      <xsl:when test=". = 'family and assembly'">
        <xsl:text>protected and internal </xsl:text>
      </xsl:when>
      <xsl:when test=". = 'private'">
        <xsl:text>private </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="api[apidata/@group = 'member' and
	                   apidata/@subgroup = 'method' and
                           apidata/@subsubgroup = 'operator' and
                           (apidata/@name = 'Explicit' or
                            apidata/@name = 'Implicit')]"
                priority="1"
                mode="fs-signature">
    <xsl:text>F# does not support the declaration of new casting operators.</xsl:text>
  </xsl:template>

  <xsl:template match="api[apidata/@group = 'member' and
	                   apidata/@subgroup = 'method']"
                mode="fs-signature">
    <xsl:choose>
      <xsl:when test="apidata/@subsubgroup = 'operator'">
        <xsl:choose>
          <xsl:when test="apidata/@name = 'Equality'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(=)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Inequality'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(&lt;&gt;)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThan'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(&lt;)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'LessThanOrEqual'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(&lt;=)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'GreaterThan'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(&gt;)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'GreaterThanOrEqual'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(&gt;=)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Addition'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(+)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Subtraction'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(-)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'UnaryPlus'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(+)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'UnaryNegation'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(-)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Division'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(/)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Multiply'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(*)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Modulus'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>(%)</xsl:text>
          </xsl:when>
          <xsl:when test="apidata/@name = 'Explicit'">
            <span class="keyword">let</span>
            <xsl:text> </xsl:text>
            <span class="keyword">inline</span>
            <xsl:text> </xsl:text>
            <xsl:text>explicit operator </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text> unhandled operator </xsl:text>
              <xsl:value-of select="apidata/@name" />
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <span class="keyword">member</span>
        <xsl:text> </xsl:text>
        <xsl:value-of select="apidata/@name" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="templates[template]" mode="fs" />
    <xsl:text>  : </xsl:text>
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <span class="keyword">unit</span>
        <xsl:text> -&gt; </xsl:text>
        <xsl:apply-templates select="returns" mode="fs" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="fs">
          <xsl:with-param name="returns" select="returns" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="api"
                mode="fs-signature">
    <xsl:choose>
      <xsl:when test="not(parameters)">
        <span class="keyword">unit</span>
        <xsl:text> -&gt; </xsl:text>
        <xsl:apply-templates select="returns" mode="fs" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="parameters" mode="fs">
          <xsl:with-param name="returns" select="returns" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="parameters"
                mode="fs">
    <xsl:param name="returns" as="element()?" />
    <xsl:apply-templates select="parameter" mode="fs">
      <xsl:with-param name="returns" select="$returns" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="parameter"
                mode="fs">
    <xsl:param name="returns" as="element()?" />
    <div class="parameter">
      <xsl:value-of select="@name" />
      <xsl:text>:</xsl:text>
      <xsl:apply-templates select="*" mode="fs" />
      <xsl:if test="position() = last()">
        <xsl:text> -&gt; </xsl:text>
        <xsl:apply-templates select="$returns" mode="fs" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="templates"
                mode="fs">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="template">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="*" mode="fs" />
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="template"
                mode="fs">
    <xsl:apply-templates select="*" mode="fs" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@name" />
  </xsl:template>

</xsl:stylesheet>
