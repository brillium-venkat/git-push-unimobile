import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { Platform } from "@ionic/angular";

@Component({
  selector: "app-type1-notification",
  templateUrl: "./type1-notification.page.html",
  styleUrls: ["./type1-notification.page.scss"],
})
export class Type1NotificationPage implements OnInit {
  notiData: any;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    public platform: Platform
  ) {
    this.route.queryParams.subscribe((params) => {
      if (this.router.getCurrentNavigation().extras.state.notificationData) {
        const nData = this.router.getCurrentNavigation().extras.state
          .notificationData.notification;
        if (
          this.platform.is("ios") ||
          this.platform.is("ipad") ||
          this.platform.is("iphone")
        ) {
          this.notiData =
            nData.body + "\n" + nData.data.id + "\n" + nData.data.type + "\n";
        } else if (this.platform.is("android") || this.platform.is("tablet")) {
          this.notiData =
            nData.id +
            "\n" +
            nData.data.from +
            "\n" +
            nData.data.id +
            "\n" +
            nData.data.type +
            "\n";
        } else {
          // non-ios and non-android handling
        }
      } else {
        const nData = this.router.getCurrentNavigation().extras.state
          .inAppNotifData;
        if (
          this.platform.is("ios") ||
          this.platform.is("ipad") ||
          this.platform.is("iphone")
        ) {
          this.notiData =
            nData.body + "\n" + nData.data.id + "\n" + nData.data.type + "\n";
        } else if (this.platform.is("android") || this.platform.is("tablet")) {
          this.notiData =
            nData.body +
            "\n" +
            nData.title +
            "\n" +
            nData.data.id +
            "\n" +
            nData.data.type +
            "\n";
        } else {
          // non-ios and non-android handling
        }
      }
    });
  }
  // eslint-disable-next-line @angular-eslint/no-empty-lifecycle-method
  ngOnInit(): void {
    // initialization chores
  }
}
