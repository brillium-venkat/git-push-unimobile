import { AfterViewInit, Component } from "@angular/core";
import { Router } from "@angular/router";

import { AlertController } from "@ionic/angular";
import { TranslateService } from "@ngx-translate/core";
import { AppGlobalConstants } from "../../constants/global.constants";
import { Account } from "../../model/account.model";
import { UserData } from "../../providers/user-data";

@Component({
  selector: "page-account",
  templateUrl: "account.html",
  styleUrls: ["./account.scss"],
})
export class AccountPage implements AfterViewInit {
  username: string;
  languages = AppGlobalConstants.LANGMAP;
  userProfile: Account;

  constructor(
    public alertCtrl: AlertController,
    public router: Router,
    public userData: UserData,
    private translate: TranslateService
  ) {
    this.getLoggedInUserProfile();
    window.addEventListener("user:login", () => {
      this.getLoggedInUserProfile();
    });
  }

  getLoggedInUserProfile() {
    this.userData.getLoggedinUserProfile().then((uProfile: Account) => {
      if (uProfile != null) {
        this.username = uProfile.login;
        this.userProfile = uProfile;
      } else {
        const authorities = [""];
        this.userProfile = new Account(
          false,
          authorities,
          "",
          "",
          "en",
          "",
          "",
          ""
        );
      }
    });
  }

  ngAfterViewInit() {
    this.userData.getLoggedinUserProfile().then((uProfile: Account) => {
      if (uProfile != null) {
        this.username = uProfile.login;
        this.userProfile = uProfile;
      } else {
        const authorities = [""];
        this.userProfile = new Account(
          false,
          authorities,
          "",
          "",
          "en",
          "",
          "",
          ""
        );
      }
    });
    this.getUsername();
  }

  updatePicture() {
    console.log("Clicked to update picture");
  }

  // Present an alert with the current username populated
  // clicking OK will update the username and display it
  // clicking Cancel will close the alert and do nothing
  async changeUsername() {
    const alert = await this.alertCtrl.create({
      header: "Change Username",
      buttons: [
        "Cancel",
        {
          text: "Ok",
          handler: (data: any) => {
            this.userData.setUsername(data.username);
            this.getUsername();
          },
        },
      ],
      inputs: [
        {
          type: "text",
          name: "username",
          value: this.username,
          placeholder: "username",
        },
      ],
    });
    await alert.present();
  }

  getUsername() {
    this.userData.getUsername().then((username) => {
      this.username = username;
    });
  }

  changePassword() {
    console.log("Clicked to change password");
  }

  logout() {
    this.userData.logout();
    this.router.navigateByUrl("/login");
  }

  support() {
    this.router.navigateByUrl("/support");
  }

  //Switch language
  translateLanguageTo($event: any) {
    this.userProfile.langKey = $event.target.value;
    this.userProfile.langKey = $event.target.value;
    this.translate.use(this.userProfile.langKey);
    this.userData.storeLoggedinUserProfile(this.userProfile).then(() => {
      // nothing to do
    });
  }
}
