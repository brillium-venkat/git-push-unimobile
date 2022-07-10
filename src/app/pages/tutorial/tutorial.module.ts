import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { IonicModule } from "@ionic/angular";
import { SwiperModule } from "swiper/angular";

import { TutorialPage } from "./tutorial";
import { TutorialPageRoutingModule } from "./tutorial-routing.module";
import { TranslateModule } from "@ngx-translate/core";

@NgModule({
  imports: [
    CommonModule,
    IonicModule,
    TutorialPageRoutingModule,
    SwiperModule,
    TranslateModule,
  ],
  declarations: [TutorialPage],
  entryComponents: [TutorialPage],
})
export class TutorialModule {}
