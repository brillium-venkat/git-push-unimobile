import { NgModule } from "@angular/core";
import { Routes, RouterModule } from "@angular/router";

import { Type1NotificationPage } from "./type1-notification.page";

const routes: Routes = [
  {
    path: "",
    component: Type1NotificationPage,
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class Type1NotificationPageRoutingModule {}
