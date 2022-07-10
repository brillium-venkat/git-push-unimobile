import { Component, OnInit } from "@angular/core";
import { NgForm } from "@angular/forms";
import { Router } from "@angular/router";
import { TranslateService } from "@ngx-translate/core";
import { UserData } from "../../providers/user-data";
import { UserOptions } from "../../interfaces/user-options";
import { ToastController } from "@ionic/angular";
import { LoginService } from "../../services/login/login.service";
import { Account } from "../../model/account.model";

@Component({
  selector: "page-login",
  templateUrl: "login.html",
  styleUrls: ["./login.scss"],
})
export class LoginPage implements OnInit {
  login: UserOptions = { username: "", password: "", rememberMe: "" };
  submitted = false;
  userLoginText = "";

  // Our translated text strings
  private loginErrorString: string;

  constructor(
    public userData: UserData,
    public translateService: TranslateService,
    public loginService: LoginService,
    public toastController: ToastController,
    public router: Router
  ) {
    this.translateService.get("login.loginUserText").subscribe((text) => {
      this.userLoginText = text;
    });
  }

  ngOnInit() {
    this.translateService.get("LOGIN_ERROR").subscribe((value) => {
      this.loginErrorString = value;
    });
  }

  onLogin(form: NgForm) {
    this.submitted = true;

    if (form.valid) {
      this.userData.login(this.login.username);
      this.router.navigateByUrl("/app/tabs/schedule");
      // this.navController.navigateRoot('/app/tabs/schedule');
    }
  }

  onSignup() {
    this.router.navigateByUrl("/signup");
  }

  doServerLogin(form: NgForm) {
    this.loginService
      .login(this.login)
      .then((userProfile: Account) => {
        // this.userLoginText = 'Authenticated successfully.'
        this.translateService.use(userProfile.langKey);
        this.userData.userLoggedIn(userProfile).then(() => {
          this.router.navigateByUrl("/app/tabs/schedule");
        });

        /*
        this.userData.login(this.login.username).then(() => {          
          this.router.navigateByUrl('/app/tabs/schedule');
        });
        */

        // this.navController.navigateRoot('/app/tabs/schedule');
      })
      .catch((error) => {
        this.login.password = "";
        this.userLoginText = error.message;
        // this.presentToast(error.message, 3000,'bottom', 'dark');
      });
  }

  async presentToast(msg: string, duration: number, pos: any, color: string) {
    const toast = await this.toastController.create({
      message: msg,
      duration: duration,
      position: pos,
      color: color,
    });
    await toast.present();
  }
}
