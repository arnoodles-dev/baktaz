/// Supported value types for remote configuration parameters.
enum ConfigValueType {
  string('Strings'),
  boolean('Booleans'),
  number('Numbers'),
  json('JSON');

  const ConfigValueType(this.label);

  final String label;

  /// Parses the Firebase Remote Config `valueType` string into this enum.
  static ConfigValueType fromString(String value) => switch (value.toUpperCase()) {
    'STRING' => ConfigValueType.string,
    'BOOLEAN' => ConfigValueType.boolean,
    'NUMBER' => ConfigValueType.number,
    'JSON' => ConfigValueType.json,
    _ => ConfigValueType.string,
  };
}
