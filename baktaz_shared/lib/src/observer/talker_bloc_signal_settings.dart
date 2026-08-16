class TalkerBlocSignalSettings {
  const TalkerBlocSignalSettings({
    this.printEvent = true,
    this.printChange = true,
    this.printError = true,
    this.printClose = true,
  });

  final bool printEvent;
  final bool printChange;
  final bool printError;
  final bool printClose;
}
