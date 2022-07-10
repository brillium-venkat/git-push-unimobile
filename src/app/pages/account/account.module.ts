import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { IonicModule } from "@ionic/angular";

import { AccountPage } from "./account";
import { AccountPageRoutingModule } from "./account-routing.module";
import { TranslateModule } from "@ngx-translate/core";

@NgModule({
  imports: [
    CommonModule,
    IonicModule,
    TranslateModule,
    AccountPageRoutingModule,
  ],
  declarations: [AccountPage],
})
export class AccountModule {}
