import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MSAL_GUARD_CONFIG, MsalBroadcastService, MsalGuardConfiguration, MsalService } from '@azure/msal-angular';
import { UserAccessLevels, UserService } from './services/user.service';
import { DataService } from './services/data.service';
import { Subject, Subscription, filter, firstValueFrom, takeUntil } from 'rxjs';
import { InteractionStatus } from '@azure/msal-browser';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent  implements OnInit, OnDestroy{
  title = 'angularmsaldemo';
  private readonly _destroying$ = new Subject<void>();
  loggedInSubscription: Subscription = new Subscription();


  constructor(
    @Inject(MSAL_GUARD_CONFIG) private msalGuardConfig: MsalGuardConfiguration,
    private authService: MsalService,
    private msalBroadcastService: MsalBroadcastService,
    public userService: UserService,
    private dataService: DataService,
  ) {}

  ngOnInit() {
    this.msalBroadcastService.inProgress$
      .pipe(
        filter((status: InteractionStatus) => status === InteractionStatus.None),
        takeUntil(this._destroying$)
      )
      .subscribe(() => {
        this.checkAndSetActiveAccount();
      })
    this.userService.init();
  }

  checkAndSetActiveAccount(){
    /**
     * If no active account set but there are accounts signed in, sets first account to active account
     * To use active account set here, subscribe to inProgress$ first in your component
     * Note: Basic usage demonstrated. Your app may require more complicated account selection logic
     */
    const activeAccount = this.authService.instance.getActiveAccount();

    if (!activeAccount && this.authService.instance.getAllAccounts().length > 0) {
      const accounts = this.authService.instance.getAllAccounts();
      this.authService.instance.setActiveAccount(accounts[0]);
      this.userService.setUserName(accounts[0].username);
    }
    else if(activeAccount){
      this.userService.setUserName(activeAccount.username);
    }

    if (!this.userService.userLevel) {
      firstValueFrom(this.dataService.getAccessLevel())
        .then((userLevel: UserAccessLevels) => {
          this.userService.setUserLevel(userLevel);
          this.userService.setloggedIn(true);
        }, error => {
          console.log(`GetAccessLevel failed: ${JSON.stringify(error)}`)
        })
      
    }
  }

  ngOnDestroy() {
    if (this.loggedInSubscription) {
      this.loggedInSubscription.unsubscribe();
    }
    this._destroying$.next(undefined);
    this._destroying$.complete();
  }

}
