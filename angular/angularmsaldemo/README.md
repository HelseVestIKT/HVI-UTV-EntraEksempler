# MSAL Angular demo
Requires updating environment.ts with tenant and client IDs.

Any routes protected by ```MsalGuard``` will trigger an authentication flow, and any subsequent API requests made to paths defined in ```app.module.ts```'s ```MSALInterceptorConfigFactory``` will have an ```Authorization Bearer {token}``` attached.

Mostly copy-pasted from HVIKT's SensorPortalen solution. Should be consistent with Microsoft Learn's [Entra/SPA documentation](https://learn.microsoft.com/en-us/entra/identity-platform/index-spa)'s How-to guides.