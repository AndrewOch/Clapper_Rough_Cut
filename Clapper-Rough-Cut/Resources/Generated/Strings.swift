// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// добавить файлы
  internal static let addFiles = L10n.tr("Localizable", "addFiles", fallback: "добавить файлы")
  /// добавить папки
  internal static let addFolder = L10n.tr("Localizable", "addFolder", fallback: "добавить папки")
  /// добавить сценарий
  internal static let addScript = L10n.tr("Localizable", "addScript", fallback: "добавить сценарий")
  /// аудио
  internal static let audio = L10n.tr("Localizable", "audio", fallback: "аудио")
  /// заменить сцену
  internal static let changeScene = L10n.tr("Localizable", "changeScene", fallback: "заменить сцену")
  /// персонажи
  internal static let characters = L10n.tr("Localizable", "characters", fallback: "персонажи")
  /// персонажей в сценарии
  internal static let charactersInScript = L10n.tr("Localizable", "charactersInScript", fallback: "персонажей в сценарии")
  /// выбрано персонажей
  internal static let charactersSelected = L10n.tr("Localizable", "charactersSelected", fallback: "выбрано персонажей")
  /// выбрать
  internal static let choose = L10n.tr("Localizable", "choose", fallback: "выбрать")
  /// выбрать сцену
  internal static let chooseScene = L10n.tr("Localizable", "chooseScene", fallback: "выбрать сцену")
  /// удалить
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "удалить")
  /// определить сцену
  internal static let determineScene = L10n.tr("Localizable", "determineScene", fallback: "определить сцену")
  /// определить сцены
  internal static let determineScenes = L10n.tr("Localizable", "determineScenes", fallback: "определить сцены")
  /// определить дубли
  internal static let determineTakes = L10n.tr("Localizable", "determineTakes", fallback: "определить дубли")
  /// экспорт
  internal static let export = L10n.tr("Localizable", "export", fallback: "экспорт")
  /// путь сохранения
  internal static let exportPath = L10n.tr("Localizable", "exportPath", fallback: "путь сохранения")
  /// введите путь сохранения
  internal static let exportPathPlaceholder = L10n.tr("Localizable", "exportPathPlaceholder", fallback: "введите путь сохранения")
  /// фразы
  internal static let phrasesCount = L10n.tr("Localizable", "phrasesCount", fallback: "фразы")
  /// проект
  internal static let project = L10n.tr("Localizable", "project", fallback: "проект")
  /// название проекта
  internal static let projectName = L10n.tr("Localizable", "projectName", fallback: "название проекта")
  /// введите название проекта
  internal static let projectNamePlaceholder = L10n.tr("Localizable", "projectNamePlaceholder", fallback: "введите название проекта")
  /// выбор сцены
  internal static let sceneSelection = L10n.tr("Localizable", "sceneSelection", fallback: "выбор сцены")
  /// сценарий
  internal static let script = L10n.tr("Localizable", "script", fallback: "сценарий")
  /// поиск
  internal static let search = L10n.tr("Localizable", "search", fallback: "поиск")
  /// поиск фразы
  internal static let searchPhrase = L10n.tr("Localizable", "searchPhrase", fallback: "поиск фразы")
  /// введите текст фразы
  internal static let searchPhrasePlaceholder = L10n.tr("Localizable", "searchPhrasePlaceholder", fallback: "введите текст фразы")
  /// выбрать
  internal static let select = L10n.tr("Localizable", "select", fallback: "выбрать")
  /// настройки
  internal static let settings = L10n.tr("Localizable", "settings", fallback: "настройки")
  /// сортировка
  internal static let sort = L10n.tr("Localizable", "sort", fallback: "сортировка")
  /// дубли
  internal static let takes = L10n.tr("Localizable", "takes", fallback: "дубли")
  /// расшифровать
  internal static let transcribe = L10n.tr("Localizable", "transcribe", fallback: "расшифровать")
  /// распознанная речь
  internal static let transcribedSpeech = L10n.tr("Localizable", "transcribedSpeech", fallback: "распознанная речь")
  /// несортированное
  internal static let unsorted = L10n.tr("Localizable", "unsorted", fallback: "несортированное")
  /// отделить файлы
  internal static let unwrapFiles = L10n.tr("Localizable", "unwrapFiles", fallback: "отделить файлы")
  /// видео
  internal static let video = L10n.tr("Localizable", "video", fallback: "видео")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
