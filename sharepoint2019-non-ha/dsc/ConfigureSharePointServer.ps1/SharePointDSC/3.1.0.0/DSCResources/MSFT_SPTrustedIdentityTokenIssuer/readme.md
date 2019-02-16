# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to create or remove SPTrustedIdentityTokenIssuer in a
SharePoint farm.

Either parameter SigningCertificateThumbPrint or SigningCertificateFilePath
must be set, but not both.

The SigningCertificateThumbPrint must be the thumbprint of the signing
certificate stored in the certificate store LocalMachine\My of the server

Note that the private key of the certificate must not be available in the
certiificate store because SharePoint does not accept it.

The SigningCertificateFilePath must be the file path to the public key of
the signing certificate.

The ClaimsMappings property is an array of MSFT_SPClaimTypeMapping to use
with cmdlet New-SPClaimTypeMapping. Each MSFT_SPClaimTypeMapping requires
properties Name and IncomingClaimType. Property LocalClaimType is not
required if its value is identical to IncomingClaimType.

The IdentifierClaim property must match an IncomingClaimType element in
ClaimsMappings array.

The ClaimProviderName property can be set to specify a custom claims provider.
It must be already installed in the SharePoint farm and returned by cmdlet

The default value for the Ensure parameter is Present. When not specifying this
parameter, the token issuer is created.
