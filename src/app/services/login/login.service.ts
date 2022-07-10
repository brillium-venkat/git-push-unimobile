import { Injectable } from "@angular/core";
import { TranslateService } from "@ngx-translate/core";
import { UserOptions } from "../../interfaces/user-options";
import { AccountService } from "../auth/account.service";
import { AuthServerProvider } from "../auth/auth-jwt.service";

@Injectable({
  providedIn: "root",
})
export class LoginService {
  constructor(
    private accountService: AccountService,
    private authServerProvider: AuthServerProvider,
    private translate: TranslateService
  ) {}

  login(credentials: UserOptions) {
    return new Promise((resolve, reject) => {
      this.authServerProvider.login(credentials).subscribe(
        (data) => {
          this.accountService.identity(true).then((account) => {
            resolve(account);
          });
        },
        (err) => {
          this.logout();
          reject(err);
        }
      );
    });
  }

  loginWithToken(jwt, rememberMe) {
    return this.authServerProvider.loginWithToken(jwt, rememberMe);
  }

  logout() {
    this.authServerProvider.logout().subscribe();
    this.accountService.authenticate(null);
  }
}
