
@Component
export struct AnimatedProgressButton {
  @Prop value: number = 0;
  @Prop type: ProgressType = 0;

  onCancel() {
  }

  build() {

      Column() {
        Stack() {
          Progress({ value: this.value, total: 120, type: this.type })
            .width(200)
            .height(200)
            .backgroundColor(0x23b479)
            .style({ strokeWidth: 30, scaleCount: 30, scaleWidth: 16 });

        }
      }
  }
}
