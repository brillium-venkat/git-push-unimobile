import { Component, OnInit, ViewEncapsulation } from "@angular/core";
import { Router } from "@angular/router";
import { SwUpdate } from "@angular/service-worker";
import { MenuController, Platform, ToastController } from "@ionic/angular";
import { Storage } from "@ionic/storage";
import { UserData } from "./providers/user-data";
import { TranslateService } from "@ngx-translate/core";
import { StatusBar } from "@capacitor/status-bar";
import { SplashScreen } from "@capacitor/splash-screen";
import { FcmService } from "./services/fcm/fcm.service";
import { App } from "@capacitor/app";

@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.scss"],
  encapsulation: ViewEncapsulation.None,
})
export class AppComponent implements OnInit {
  appPages = [
    {
      title: "Schedule",
      url: "/app/tabs/schedule",
      icon: "calendar",
    },
    {
      title: "Speakers",
      url: "/app/tabs/speakers",
      icon: "people",
    },
    {
      title: "Map",
      url: "/app/tabs/map",
      icon: "map",
    },
    {
      title: "About",
      url: "/app/tabs/about",
      icon: "information-circle",
    },
  ];
  loggedIn = false;
  dark = false;

  constructor(
    private menu: MenuController,
    private platform: Platform,
    private router: Router,
    private storage: Storage,
    private userData: UserData,
    private swUpdate: SwUpdate,
    private toastCtrl: ToastController,
    private translate: TranslateService,
    public pushNotifications: FcmService
  ) {
    this.initializeApp();
  }

  async ngOnInit() {
    this.checkLoginStatus();
    this.listenForLoginEvents();

    this.swUpdate.available.subscribe(async (res) => {
      const toast = await this.toastCtrl.create({
        message: "Update available!",
        position: "bottom",
        buttons: [
          {
            role: "cancel",
            text: "Reload",
          },
        ],
      });

      await toast.present();

      toast
        .onDidDismiss()
        .then(() => this.swUpdate.activateUpdate())
        .then(() => window.location.reload());
    });
  }

  initializeApp() {
    this.platform.ready().then(() => {
      if (this.platform.is("hybrid")) {
        StatusBar.hide();
        SplashScreen.hide();
        this.registerAppStateHandlers();
        this.pushNotifications.initPush();
      }
    });
    this.initTranslate();
  }

  checkLoginStatus() {
    return this.userData.isLoggedIn().then((loggedIn) => {
      return this.updateLoggedInStatus(loggedIn);
    });
  }

  updateLoggedInStatus(loggedIn: boolean) {
    setTimeout(() => {
      this.loggedIn = loggedIn;
    }, 300);
  }

  listenForLoginEvents() {
    window.addEventListener("user:login", () => {
      this.updateLoggedInStatus(true);
    });

    window.addEventListener("user:signup", () => {
      this.updateLoggedInStatus(true);
    });

    window.addEventListener("user:logout", () => {
      this.updateLoggedInStatus(false);
    });
  }

  logout() {
    this.userData.logout().then(() => {
      return this.router.navigateByUrl("/login");
    });
  }

  openTutorial() {
    this.menu.enable(false);
    this.storage.set("ion_did_tutorial", false);
    this.router.navigateByUrl("/tutorial");
  }

  initTranslate() {
    // this.translate.addLangs(['en','hi','te','ar','de','fr','kn']);
    const enLang = "en";
    this.translate.setDefaultLang(enLang);
    this.translate.use(enLang);
  }

  registerAppStateHandlers(): void {
    App.addListener("appStateChange", ({ isActive }) => {
      this.appStateChangeHandler(isActive);
    });

    App.addListener("appUrlOpen", (data) => {
      this.appUrlOpenHandler(data);
    });

    App.addListener("appRestoredResult", (data) => {
      this.appRestoredHander(data);
    });
  }

  appStateChangeHandler(state: any): void {
    // alert('Application state changed to: ' + state );
  }

  appUrlOpenHandler(data: any): void {
    // alert('Application state changed to: ' + data );
  }

  appRestoredHander(data: any): void {
    // alert('Application state changed to: ' + data );
  }
}
