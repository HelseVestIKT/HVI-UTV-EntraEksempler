using Microsoft.Identity.Client;
using System.Windows;
using System.Windows.Interop;


namespace EntraDemo
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        string[] scopes = new string[] {
            "<<Client ID>>/.default",
            "openid",
            "profile",

        };

        public MainWindow()
        {
            InitializeComponent();
        }

        private async void SignInButton_Click(object sender, RoutedEventArgs e)
        {
            
            AuthenticationResult authResult = null;
            var app = App.PublicClientApp;

            ResultText.Text = string.Empty;
            TokenInfoText.Text = string.Empty;

            var accounts = await app.GetAccountsAsync();

            IAccount accountToLogin = accounts.FirstOrDefault();

            if (accountToLogin == null)
            {
                // 3. No account in the cache; try to log in with the OS account
                accountToLogin = PublicClientApplication.OperatingSystemAccount;
            }

            
            try
            {
                authResult = await app.AcquireTokenSilent(scopes, accountToLogin).ExecuteAsync();
            }
            catch (Exception ex)
            {
                try
                {
                    authResult = await app.AcquireTokenInteractive(scopes)
                        .WithAccount(accountToLogin)
                        
                        .WithParentActivityOrWindow(new WindowInteropHelper(this).Handle)
                        .WithPrompt(Prompt.ForceLogin)
                        
                        .WithUseEmbeddedWebView(true)
                        .ExecuteAsync();
                }
                catch (MsalException msalex)
                {
                    ResultText.Text = $"Error Acquiring Token:{System.Environment.NewLine}{msalex}";
                }
                catch (Exception exb)
                {
                    ResultText.Text = $"Error Acquiring Token Silently:{System.Environment.NewLine}{exb}";
                    return;
                }

                
            }

            if (authResult != null)
            {
                ResultText.Text = "Sign in was successful.";
                DisplayBasicTokenInfo(authResult);
                this.SignInButton.Visibility = Visibility.Collapsed;
                this.SignOutButton.Visibility = Visibility.Visible;
            }

        }

        private async void SignOutButton_Click(object sender, RoutedEventArgs e)
        {
            var accounts = await App.PublicClientApp.GetAccountsAsync();
            if (accounts.Any())
            {
                try
                {
                    await App.PublicClientApp.RemoveAsync(accounts.FirstOrDefault());
                    this.ResultText.Text = "User has signed-out";
                    this.TokenInfoText.Text = string.Empty;
                    this.SignInButton.Visibility = Visibility.Visible;
                    this.SignOutButton.Visibility = Visibility.Collapsed;
                }
                catch (MsalException ex)
                {
                    ResultText.Text = $"Error signing-out user: {ex.Message}";
                }
            }
        }

        private void DisplayBasicTokenInfo(AuthenticationResult authResult)
        {
            TokenInfoText.Text = "";
            if (authResult != null)
            {
                TokenInfoText.Text += $"Username: {authResult.Account.Username}" + Environment.NewLine;
                TokenInfoText.Text += $"{authResult.Account.HomeAccountId}" + Environment.NewLine;
            }
        }
    }
}