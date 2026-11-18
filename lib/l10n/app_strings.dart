import 'package:flutter/widgets.dart';

extension AppStrings on BuildContext {
  String tr(String russian, [Map<String, Object> arguments = const {}]) {
    var text = Localizations.localeOf(this).languageCode == 'en'
        ? _english[russian] ?? russian
        : russian;
    for (final entry in arguments.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return text;
  }
}

const _english = <String, String>{
  "Переговорные": "Rooms",
  "Встречи": "Bookings",
  "Пользователи": "Users",
  "Настройки": "Settings",
  "Язык приложения": "App language",
  "Обновить": "Refresh",
  "Название комнаты": "Room name",
  "Не удалось загрузить комнаты. Проверьте сервер.":
      "Could not load rooms. Check the server.",
  "Комнаты не найдены": "No rooms found",
  "Изменить": "Edit",
  "Удалить": "Delete",
  "Не удалось загрузить пользователей": "Could not load users",
  "Пользователей нет": "No users",
  "Не удалось загрузить встречи": "Could not load bookings",
  "Встреч нет": "No bookings",
  "Расположение": "Location",
  "Вместимость": "Capacity",
  "Описание отсутствует": "No description",
  "Новый пользователь": "New user",
  "Изменить пользователя": "Edit user",
  "ФИО": "Full name",
  "Отдел": "Department",
  "Новая переговорная": "New room",
  "Изменить переговорную": "Edit room",
  "Название": "Name",
  "Количество мест": "Seats",
  "Этаж": "Floor",
  "Описание": "Description",
  "Адрес изображения": "Image URL",
  "Новая встреча": "New booking",
  "Изменить встречу": "Edit booking",
  "Переговорная": "Room",
  "Пользователь": "User",
  "Начало (2026-10-28T10:00)": "Start (2026-10-28T10:00)",
  "Конец (2026-10-28T11:00)": "End (2026-10-28T11:00)",
  "Цель встречи": "Purpose",
  "Участников": "Participants",
  "Укажите даты; конец должен быть позже начала":
      "Enter dates with the end after the start",
  "Не удалось загрузить пользователей и переговорные":
      "Could not load users and rooms",
  "Не удалось сохранить": "Could not save",
  "Повторить": "Retry",
  "Для создания встречи добавьте пользователя и переговорную.":
      "Add a user and a room before creating a booking.",
  "Выберите из списка": "Select an option",
  "Заполните поле": "Required field",
  "Введите целое число от 1": "Enter a whole number of at least 1",
  "Введите корректный email": "Enter a valid email address",
  "Отмена": "Cancel",
  "Сохранение…": "Saving…",
  "Сохранить": "Save",
  "Удаление": "Confirm deletion",
  "Не удалось удалить": "Could not delete",
  "Удалить «{name}»?": "Delete “{name}”?",
  "{count} мест": "{count} seats",
  "Подтверждена": "Confirmed",
  "Отменена": "Cancelled",
  "Завершена": "Completed",
  "Убрать из избранного": "Remove from favorites",
  "Добавить в избранное": "Add to favorites",
  "Подключить PostgreSQL": "Connect to PostgreSQL",
  "Пароль PostgreSQL": "PostgreSQL password",
  "Подключить": "Connect",
  "Не удалось подключиться к PostgreSQL": "Could not connect to PostgreSQL",
  "Не удалось сохранить пароль PostgreSQL":
      "Could not save the PostgreSQL password",
  "Не удалось сохранить лайк": "Could not save like",
  "Загрузка лайков…": "Loading likes…",
};
