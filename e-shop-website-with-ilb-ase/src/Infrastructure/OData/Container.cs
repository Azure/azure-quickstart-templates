/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.OData.Client;
using System;

namespace Infrastructure.OData
{
    public partial class Container : DataServiceContext
    {
        public Container(System.Uri serviceRoot) :
                base(serviceRoot, ODataProtocolVersion.V4)
        {
            this.OnContextCreated();
            this.Format.LoadServiceModel = GeneratedEdmModel.GetInstance;
            this.Format.UseJson();
        }

        partial void OnContextCreated();

        private abstract class GeneratedEdmModel
        {
            private static Microsoft.OData.Edm.IEdmModel ParsedModel = LoadModelFromString();

            private const string Edmx = @"<edmx:Edmx Version=""4.0"" xmlns:edmx=""http://docs.oasis-open.org/odata/ns/edmx"">
                <edmx:DataServices>
                <Schema Namespace=""ApplicationCore.Entities.OrderAggregate"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">
                    <EntityType Name=""Order"">
                    <Key>
                        <PropertyRef Name=""Id"" />
                    </Key>
                    <Property Name=""BuyerId"" Type=""Edm.String"" />
                    <Property Name=""OrderDate"" Type=""Edm.DateTimeOffset"" Nullable=""false"" />
                    <Property Name=""ShipToAddress"" Type=""ApplicationCore.Entities.OrderAggregate.Address"" />
                    <Property Name=""Id"" Type=""Edm.Int32"" Nullable=""false"" />
                    <NavigationProperty Name=""OrderItems"" Type=""Collection(ApplicationCore.Entities.OrderAggregate.OrderItem)"" />
                    </EntityType>
                    <EntityType Name=""OrderItem"">
                    <Key>
                        <PropertyRef Name=""Id"" />
                    </Key>
                    <Property Name=""ItemOrdered"" Type=""ApplicationCore.Entities.OrderAggregate.CatalogItemOrdered"" />
                    <Property Name=""UnitPrice"" Type=""Edm.Decimal"" Nullable=""false"" />
                    <Property Name=""Units"" Type=""Edm.Int32"" Nullable=""false"" />
                    <Property Name=""Id"" Type=""Edm.Int32"" Nullable=""false"" />
                    <NavigationProperty Name=""Order"" Type=""ApplicationCore.Entities.OrderAggregate.Order"" />
                    </EntityType>
                    <ComplexType Name=""Address"">
                    <Property Name=""Street"" Type=""Edm.String"" />
                    <Property Name=""City"" Type=""Edm.String"" />
                    <Property Name=""State"" Type=""Edm.String"" />
                    <Property Name=""Country"" Type=""Edm.String"" />
                    <Property Name=""ZipCode"" Type=""Edm.String"" />
                    </ComplexType>
                    <ComplexType Name=""CatalogItemOrdered"">
                    <Property Name=""CatalogItemId"" Type=""Edm.Int32"" Nullable=""false"" />
                    <Property Name=""ProductName"" Type=""Edm.String"" />
                    <Property Name=""PictureUri"" Type=""Edm.String"" />
                    </ComplexType>
                </Schema>
                <Schema Namespace=""Default"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">
                    <EntityContainer Name=""Container"">
                    <EntitySet Name=""Orders"" EntityType=""ApplicationCore.Entities.OrderAggregate.Order"">
                        <NavigationPropertyBinding Path=""OrderItems"" Target=""OrderItems"" />
                    </EntitySet>
                    <EntitySet Name=""OrderItems"" EntityType=""ApplicationCore.Entities.OrderAggregate.OrderItem"">
                        <NavigationPropertyBinding Path=""Order"" Target=""Orders"" />
                    </EntitySet>
                    </EntityContainer>
                </Schema>
                </edmx:DataServices>
            </edmx:Edmx>";

            public static Microsoft.OData.Edm.IEdmModel GetInstance()
            {
                return ParsedModel;
            }

            private static Microsoft.OData.Edm.IEdmModel LoadModelFromString()
            {
                System.Xml.XmlReader reader = CreateXmlReader(Edmx);
                try
                {
                    return Microsoft.OData.Edm.Csdl.CsdlReader.Parse(reader);
                }
                finally
                {
                    ((IDisposable)(reader)).Dispose();
                }
            }

            private static System.Xml.XmlReader CreateXmlReader(string edmxToParse)
            {
                return System.Xml.XmlReader.Create(new System.IO.StringReader(edmxToParse));
            }
        }
    }
}
