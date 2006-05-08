<?xml version="1.0" encoding="utf-8"?>

<!--
    This style sheet is used in the Math4All project. This project
    will provide an on-line math method for secondary and tertiary
    education. In addition to the web-bases content the project
    provides high quality typeset output as well.

    This style converts some elements to open math alternatives and
    its sole purpose is to easy the input of inline math.

    <i>x</i>    identifier (use <v>x</v> when possible)
    <n>5</n>    number
    <v>5</v>    variable
    <r>1:2</r>  interval (range)
    <r>x:y</r>  interval (range) using variables

    This style is dedicated to Frits Spijkers, an open minded math
    author who patiently tested all the related TeX things.

    Hans Hagen, PRAGMA ADE, Hasselt NL / 2006-04-27

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml"/>

    <xsl:template match ="processing-instruction()"><xsl:copy/><xsl:text>
    </xsl:text></xsl:template>

    <xsl:template match = "node()|@*" >
        <xsl:copy>
            <xsl:apply-templates select = "node()|@*" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="comment"></xsl:template>

    <xsl:variable name='openmath-to-content-mathml'><value-of select='$stylesheet-path'/>/x-openmath.xsl</xsl:variable>

    <xsl:template match='i|n'>
        <xsl:element name="OMOBJ">
            <xsl:attribute name="xmlns">http://www.openmath.org/OpenMath</xsl:attribute>
            <xsl:attribute name="version">2.0</xsl:attribute>
            <xsl:element name="OMI">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match='v'>
        <xsl:element name="OMOBJ">
            <xsl:attribute name="xmlns">http://www.openmath.org/OpenMath</xsl:attribute>
            <xsl:attribute name="version">2.0</xsl:attribute>
            <xsl:element name="OMV">
                <xsl:attribute name="name"><xsl:apply-templates/></xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- r a/b split in two parts -->

    <xsl:template match='r'>
        <xsl:element name="OMOBJ">
            <xsl:attribute name="xmlns">http://www.openmath.org/OpenMath</xsl:attribute>
            <xsl:attribute name="version">2.0</xsl:attribute>
            <xsl:element name="OMA">
                <xsl:element name="OMS">
                    <xsl:attribute name="cd">interval1</xsl:attribute>
                    <xsl:attribute name="name">interval_oo</xsl:attribute>
                </xsl:element>
                <xsl:choose>
                    <xsl:when test="not(number(substring-before(translate(text(),',','.'),':')))">
                        <xsl:element name="OMV">
                            <xsl:attribute name="name"><xsl:value-of select="substring-before(text(),':')"/></xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="OMI">
                            <xsl:value-of select="substring-before(text(),':')"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="not(number(substring-after(translate(text(),',','.'),':')))">
                        <xsl:element name="OMV">
                            <xsl:attribute name="name"><xsl:value-of select="substring-after(text(),':')"/></xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="OMI">
                            <xsl:value-of select="substring-after(text(),':')"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
