class Environment {

    static const String _tenantId = "";

    static const List<String> scopes = [
          '${Environment.CLIENT_ID}/.default',
          'openid',
          'profile',
          'offline_access'
        ];

    static const REDIRECT_URI = "no.helsevestikt.hviktentra://login-callback/";
    static const CLIENT_ID = "<<App registration client ID>>";
    static const AUTHORIZATION_ENDPOINT =
        "https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/authorize";
    static const TOKEN_ENDPOINT =
        "https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/token";
    static const END_SESSION_ENDPOINT =
        "https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/logout";

    static const POST_LOGOUT_REDIRECT = "no.helsevesikt.hviktentra://loginScreen/";


    static const String API_BASE_URL = "";

}