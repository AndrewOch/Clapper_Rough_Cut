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
  /// дата создания
  internal static let createdAt = L10n.tr("Localizable", "createdAt", fallback: "дата создания")
  /// создать папку
  internal static let createFolder = L10n.tr("Localizable", "createFolder", fallback: "создать папку")
  /// создать сцену
  internal static let createScene = L10n.tr("Localizable", "createScene", fallback: "создать сцену")
  /// создать дубль
  internal static let createTake = L10n.tr("Localizable", "createTake", fallback: "создать дубль")
  /// удалить
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "удалить")
  /// определить сцену
  internal static let determineScene = L10n.tr("Localizable", "determineScene", fallback: "определить сцену")
  /// определить сцены
  internal static let determineScenes = L10n.tr("Localizable", "determineScenes", fallback: "определить сцены")
  /// определить дубли
  internal static let determineTakes = L10n.tr("Localizable", "determineTakes", fallback: "определить дубли")
  /// длительность
  internal static let duration = L10n.tr("Localizable", "duration", fallback: "длительность")
  /// правка
  internal static let editSection = L10n.tr("Localizable", "editSection", fallback: "правка")
  /// экспорт
  internal static let export = L10n.tr("Localizable", "export", fallback: "экспорт")
  /// путь сохранения
  internal static let exportPath = L10n.tr("Localizable", "exportPath", fallback: "путь сохранения")
  /// введите путь сохранения
  internal static let exportPathPlaceholder = L10n.tr("Localizable", "exportPathPlaceholder", fallback: "введите путь сохранения")
  /// файл
  internal static let file = L10n.tr("Localizable", "file", fallback: "файл")
  /// файлы
  internal static let files = L10n.tr("Localizable", "files", fallback: "файлы")
  /// Найдите нужные файлы
  internal static let fileSystemSearchPlaceholder = L10n.tr("Localizable", "fileSystemSearchPlaceholder", fallback: "Найдите нужные файлы")
  /// название
  internal static let fileTitle = L10n.tr("Localizable", "fileTitle", fallback: "название")
  /// папка
  internal static let folder = L10n.tr("Localizable", "folder", fallback: "папка")
  /// папки
  internal static let folders = L10n.tr("Localizable", "folders", fallback: "папки")
  /// новая папка
  internal static let newFolder = L10n.tr("Localizable", "newFolder", fallback: "новая папка")
  /// фразы
  internal static let phrasesCount = L10n.tr("Localizable", "phrasesCount", fallback: "фразы")
  /// проект
  internal static let project = L10n.tr("Localizable", "project", fallback: "проект")
  /// название проекта
  internal static let projectName = L10n.tr("Localizable", "projectName", fallback: "название проекта")
  /// введите название проекта
  internal static let projectNamePlaceholder = L10n.tr("Localizable", "projectNamePlaceholder", fallback: "введите название проекта")
  /// сцена
  internal static let scene = L10n.tr("Localizable", "scene", fallback: "сцена")
  /// сцены
  internal static let scenes = L10n.tr("Localizable", "scenes", fallback: "сцены")
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
  /// выбрано
  internal static let selected = L10n.tr("Localizable", "selected", fallback: "выбрано")
  /// настройки
  internal static let settings = L10n.tr("Localizable", "settings", fallback: "настройки")
  /// Экспорт:
  internal static let shortcutExport = L10n.tr("Localizable", "shortcut_export", fallback: "Экспорт:")
  /// Открыть меню персонажей:
  internal static let shortcutOpenCharactersMenu = L10n.tr("Localizable", "shortcut_openCharactersMenu", fallback: "Открыть меню персонажей:")
  /// Расшифровать все:
  internal static let shortcutTranscribeAll = L10n.tr("Localizable", "shortcut_transcribeAll", fallback: "Расшифровать все:")
  /// сортировка
  internal static let sort = L10n.tr("Localizable", "sort", fallback: "сортировка")
  /// статусы
  internal static let statuses = L10n.tr("Localizable", "statuses", fallback: "статусы")
  /// синхр. по таймкоду
  internal static let synchronizeByTimecode = L10n.tr("Localizable", "synchronizeByTimecode", fallback: "синхр. по таймкоду")
  /// синхр. по звук. волне
  internal static let synchronizeByWaveform = L10n.tr("Localizable", "synchronizeByWaveform", fallback: "синхр. по звук. волне")
  /// дубль
  internal static let take = L10n.tr("Localizable", "take", fallback: "дубль")
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
