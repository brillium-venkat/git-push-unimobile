import { Injectable } from "@angular/core";
import { NavigationExtras, Router } from "@angular/router";
import { Capacitor } from "@capacitor/core";
import {
  ActionPerformed,
  DeliveredNotifications,
  PushNotifications,
  PushNotificationSchema,
  Token,
} from "@capacitor/push-notifications";
import { Badge } from "@awesome-cordova-plugins/badge/ngx";
import { AlertController, NavController } from "@ionic/angular";
import { StorageService } from "../storage/storage.service";

@Injectable({
  providedIn: "root",
})
export class FcmService {
  pnRegistered = false;
  removeAllPushNotification = false;
  notificationList: DeliveredNotifications;
  alert: any;
  badgeCount = 0;

  constructor(
    private badge: Badge,
    private router: Router,
    public alertController: AlertController,
    public navCtrl: NavController,
    private storage: StorageService
  ) {}

  initPush() {
    if (Capacitor.getPlatform() !== "web") {
      this.registerPush();
    }
    // this.badge.clear();
  }

  showNotificationAlert(nData) {
    let alertMsg = nData.body;
    const imageURL = "assets/img/user-alert.png";
    const imgAlt = "Alert Image Alternative Text";
    const alertImg =
      '<img src="' +
      imageURL +
      '"alt="' +
      imgAlt +
      '" style="border-radius: 2px">';
    alertMsg = alertImg + "<p>" + alertMsg + "</p>";

    this.alertController
      .create({
        header: "Notification Title",
        subHeader: "Notification Sub-title",
        message: alertMsg,
        buttons: [
          {
            text: "OK",
            handler: (hData: any) => {
              this.notiAlertOKHandler(nData, hData);
            },
          },
          {
            text: "Cancel",
            handler: (hData: any) => {
              this.notiAlertCancelHandler(nData, hData);
            },
          },
        ],
      })
      .then((res) => {
        this.alert = res;
        res.present();
      });
  }

  notiAlertOKHandler(nData: any, hData: any): void {
    // save notification data in a local persistent store, if needed
    // code and logic for the same

    // set the alert data in navigation extras
    const navigationExtras: NavigationExtras = {
      state: {
        notificationData: null,
        inAppNotifData: nData,
      },
    };
    this.badge.decrease(1);
    // navigate to alert action page
    this.router.navigate(["home/notifications/type1"], navigationExtras);
  }

  notiAlertCancelHandler(nData: any, hData: any): void {
    this.alert.dismiss().then(() => {
      this.navCtrl.pop();
    });
  }

  openPushNotificationType1Page(rData): void {
    this.showNotificationAlert(rData);
  }

  private registerPush() {
    const registerNotifications = async () => {
      let permStatus = await PushNotifications.checkPermissions();
      if (permStatus.receive === "prompt") {
        permStatus = await PushNotifications.requestPermissions();
      }
      if (permStatus.receive !== "granted") {
        // throw new Error('User denied permissions!');
        alert(
          "User denied push notification access permission:" +
            permStatus.receive
        );
        return;
      }
    };

    // Request permission to use push notifications
    // iOS will prompt user and return if they granted permission or not
    // Android will just grant without prompting
    PushNotifications.requestPermissions().then((result) => {
      if (result.receive === "granted") {
        // Register with Apple / Google to receive push via APNS/FCM
        PushNotifications.register();
        // this.badge.clear();
      } else {
        // Show some error
        alert("Push request permission failed: " + result.receive);
      }
    });

    // On success, we should be able to receive notifications
    PushNotifications.addListener("registration", (token: Token) => {
      alert("Push registration success, token: " + token.value);
      // this.pnRegistered = true;
      // this.storage.set(Constants.STG_KEY_PNS_REGISTERED, Constants.PUSH_NOTIF_REGISTERED);
    });

    // Some issue with our setup and push will not work
    PushNotifications.addListener("registrationError", (error: any) => {
      alert(
        "Error on Push notification registration with FCM: " +
          JSON.stringify(error) +
          "\n" +
          "This may happen when the app is run on Android emulator or iOS simulator. Please try running the app on real device." +
          "\n" +
          "However, you still can continue running/testing the app on emulator."
      );
      // this.badge.clear();
    });

    // Show us the notification payload if the app is open on our device
    PushNotifications.addListener(
      "pushNotificationReceived",
      (notification: PushNotificationSchema) => {
        this.badge.get().then((curCount) => {
          this.badgeCount = curCount + 1;
          this.badge.set(this.badgeCount);
          this.openPushNotificationType1Page(notification);
        });
      }
    );

    // Method called when tapping on a notification
    PushNotifications.addListener(
      "pushNotificationActionPerformed",
      (notification: ActionPerformed) => {
        // save notification data in a local persistent store, if needed
        // code and logic for the same

        // set the alert data in navigation extras
        const navigationExtras: NavigationExtras = {
          state: {
            notificationData: notification,
          },
        };
        this.badge.get().then((curCount) => {
          this.badgeCount = curCount + 1;
          this.badge.set(this.badgeCount);
        });
        this.badge.decrease(1);
        // navigate to alert action page
        this.router.navigate(["home/notifications/type1"], navigationExtras);
        /*
        PushNotifications.getDeliveredNotifications().then((dNotifications => {
          this.notificationList = dNotifications;
        }));
        */
      }
    );
    /*
    const getDeliveredNotifications = async () => {
      this.notificationList = await PushNotifications.getDeliveredNotifications();
      alert('Already delivered notifications are:' + this.notificationList);
    };
    */
  }
}
