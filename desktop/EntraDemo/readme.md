Basic example using Windows Presentation Foundation (WPF) based on Microsoft's
- [Using MSAL.NET with Web Account Manager (WAM)](https://learn.microsoft.com/nb-no/entra/msal/dotnet/acquiring-tokens/desktop-mobile/wam) 
- [Tutorial: Prepare your customer tenant to sign in user in .NET WPF application](https://learn.microsoft.com/en-us/entra/external-id/customers/tutorial-desktop-wpf-dotnet-sign-in-prepare-tenant)

Note: Does not work if the app is _run as_ a different user, which is not supported: https://github.com/AzureAD/microsoft-authentication-library-for-dotnet/issues/3792 

Requires updating appsettings.json with tenant ID and client ID.