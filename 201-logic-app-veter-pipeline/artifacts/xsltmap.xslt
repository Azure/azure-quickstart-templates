<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var s0 userCSharp" version="1.0" xmlns:ns0="http://Integration.SAPOrder" xmlns:s0="http://Integration.Order" xmlns:userCSharp="http://schemas.microsoft.com/BizTalk/2003/userCSharp">
  <xsl:import href="https://az818438.vo.msecnd.net/functoids/functoidsscript.xslt" />
  <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />
  <xsl:template match="/">
    <xsl:apply-templates select="/s0:Order" />
  </xsl:template>
  <xsl:template match="/s0:Order">
    <xsl:variable name="var:v1" select="userCSharp:DateCurrentDateTime()" />
    <ns0:SAPOrder>
      <OrderId>
        <xsl:value-of select="Orderheader/OrderNumber/text()" />
      </OrderId>
      <ClientId>
        <xsl:text>1</xsl:text>
      </ClientId>
      <Dates>
        <ProcessDate>
          <xsl:value-of select="$var:v1" />
        </ProcessDate>
        <OrderDate>
          <xsl:value-of select="Orderheader/OrderDate/text()" />
        </OrderDate>
        <EstimatedDeliveryDate>
          <xsl:value-of select="Orderheader/EstimatedDeliveryDate/text()" />
        </EstimatedDeliveryDate>
      </Dates>
      <Details>
        <ItemId>
          <xsl:value-of select="OrderDetails/ItemCustomerCode/text()" />
        </ItemId>
        <Units>
          <xsl:value-of select="OrderDetails/TotalAmount/text()" />
        </Units>
        <UnitType>
          <xsl:value-of select="OrderDetails/UnitType/text()" />
        </UnitType>
      </Details>
    </ns0:SAPOrder>
  </xsl:template>
</xsl:stylesheet>