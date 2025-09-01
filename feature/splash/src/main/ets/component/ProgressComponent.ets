@Component
export struct ProgressComponent {
  @Prop progress: number = 0
  @Prop isLoading: boolean = true

  build() {
    Stack() {
      // Circular Progress Bar
      Progress({
        value: this.progress,
        total: 100,
        type: ProgressType.ScaleRing
      })
        .width(60)
        .height(60)

      Text(`${this.progress}%`)
        .fontSize(14)
    }
    .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
  }
}