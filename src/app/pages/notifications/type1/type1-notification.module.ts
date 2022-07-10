import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";

import { IonicModule } from "@ionic/angular";

import { Type1NotificationPageRoutingModule } from "./type1-notification-routing.module";

import { Type1NotificationPage } from "./type1-notification.page";

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    Type1NotificationPageRoutingModule,
  ],
  declarations: [Type1NotificationPage],
})
export class Type1NotificationPageModule {}
