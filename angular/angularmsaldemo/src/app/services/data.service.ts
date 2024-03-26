import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { UserAccessLevels } from './user.service';
import { environment } from '../environment';

@Injectable({
  providedIn: 'root'
})
export class DataService {

  apiUrl = environment.apiPath;
  
  constructor(private http: HttpClient) { }

  getAccessLevel(): Observable<UserAccessLevels> {
    return this.http.get<UserAccessLevels>(`${this.apiUrl}/Access/GetAccessLevel`);
  }
}
