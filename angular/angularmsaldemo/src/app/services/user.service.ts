import { Injectable } from '@angular/core';
import { MsalService, MsalBroadcastService } from '@azure/msal-angular';
import { EventMessage, AuthenticationResult, EventError, EventType } from '@azure/msal-browser';
import { BehaviorSubject, filter } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  private userGroupsSubject: BehaviorSubject<string[] | null> = new BehaviorSubject<string[] | null>(null);
  public userGroups$ = this.userGroupsSubject.asObservable();

  private userLevelSubject: BehaviorSubject<UserAccessLevels | null> = new BehaviorSubject<UserAccessLevels | null>(null);
  public userLevel$ = this.userLevelSubject.asObservable();

  private loggedInSubject: BehaviorSubject<boolean | null> = new BehaviorSubject<boolean | null>(false);
  public loggedIn$ = this.loggedInSubject.asObservable();

  private userNameSubject: BehaviorSubject<string> = new BehaviorSubject<string>('');
  public userName$ = this.userNameSubject.asObservable();

  private accessTokenSubject: BehaviorSubject<string> = new BehaviorSubject<string>('');
  public accessToken$ = this.accessTokenSubject.asObservable();

  constructor(    
    private msalService: MsalService,
    private msalBroadcastService: MsalBroadcastService
    ) { }

  init() {
    this.msalBroadcastService.msalSubject$
      .pipe(
        filter((msg: EventMessage) => msg.eventType === EventType.LOGIN_SUCCESS || msg.eventType === EventType.ACQUIRE_TOKEN_SUCCESS)
      )
      .subscribe({
        next: (result: EventMessage) => {
          const payload = result.payload as AuthenticationResult;
          this.setAccessToken(payload.accessToken);
        },
        error: (error: EventError) => {
          this.msalService.getLogger().error(error?.message ?? 'msal error on login,');
        }
      });
  }


  public setUserName(username: string) {
    this.userNameSubject.next(username);
  }

  public setAccessToken(accessToken: string) {
    this.accessTokenSubject.next(accessToken);
  }

  public setUserLevel(userLevel: UserAccessLevels) {
    this.userLevelSubject.next(userLevel);
  }

  public setloggedIn(loggedIn: boolean) {
    this.loggedInSubject.next(loggedIn);
  }

  public userLevelOverride?: UserAccessLevels;
  public get userLevel() {
    if (this.userLevelOverride != null && this.userLevelSubject.value != null) {
      return this.userLevelOverride;
    }
    return this.userLevelSubject.value;
  }
}

export enum UserAccessLevels {
  None = 0,
  Read,
  Write,
  Admin,
  SuperAdmin
}
