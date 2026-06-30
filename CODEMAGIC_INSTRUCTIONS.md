# Инструкция по заливке проектов в Codemagic

## Что имеем

В каждом проекте лежит `codemagic.yaml`, скопированный из другого проекта (Ascendly).
В нём нужно заменить 6 значений на актуальные для каждого проекта.

## Откуда брать данные

| Поле | Откуда |
|---|---|
| `app_store_connect` | Имя `.xcodeproj` без расширения + `-Key`. Пример: `CalmDepth-Key` |
| `bundle_identifier` | Из `project.pbxproj` — поле `PRODUCT_BUNDLE_IDENTIFIER` |
| `XCODE_PROJECT` | Имя `.xcodeproj` файла. Пример: `"CalmDepth.xcodeproj"` |
| `XCODE_SCHEME` | Имя проекта (совпадает с именем папки `.xcodeproj`). Пример: `"CalmDepth"` |
| `BUNDLE_ID` | То же, что `bundle_identifier` |
| `APP_STORE_APPLE_ID` | Пользователь предоставляет маппинг SKU → Apple ID |

## Что заменять в codemagic.yaml

```yaml
# ЭТИ СТРОКИ (из Ascendly):
app_store_connect: Ascendly
bundle_identifier: com.ofri.ascendly
XCODE_PROJECT: "Ascendly.xcodeproj"
XCODE_SCHEME: "Ascendly"
BUNDLE_ID: "com.ofri.ascendly"
APP_STORE_APPLE_ID: 6760998912

# ЗАМЕНЯТЬ НА (пример CalmDepth):
app_store_connect: CalmDepth-Key
bundle_identifier: com.shmuel.calm
XCODE_PROJECT: "CalmDepth.xcodeproj"
XCODE_SCHEME: "CalmDepth"
BUNDLE_ID: "com.shmuel.calm"
APP_STORE_APPLE_ID: 6761521586
```

## Порядок действий

1. `ls` — посмотреть список проектов в папке
2. `Glob **/codemagic.yaml` — найти все файлы codemagic
3. `Glob **/*.xcodeproj/project.pbxproj` — найти все pbxproj
4. `Grep PRODUCT_BUNDLE_IDENTIFIER` в каждом pbxproj — получить bundle ID
5. Сопоставить SKU от пользователя с проектами, получить Apple ID
6. Заменить 6 полей в каждом `codemagic.yaml` (параллельно все файлы)
7. **Удалить `xcuserdata`** во всех `.xcodeproj` (персональные настройки Xcode — не должны попадать в репу): `rm -rf <Project>.xcodeproj/xcuserdata`
8. Git init + push — параллельно для всех проектов:

```bash
cd ProjectDir && git init && git add . && git commit -m "first commit" && git branch -M main && git remote add origin git@github.com:appsheroes/ProjectName.git && git push -u origin main
```

## Важно

- Репозитории на GitHub: `appsheroes/<ИмяПапки>` (имя папки проекта, НЕ имени `.xcodeproj`!). Пример: папка `WinterMiracle/` с `IceMiracle.xcodeproj` → репо `appsheroes/WinterMiracle`
- Пользователь заранее создаёт репозитории на GitHub
- Все операции (замена yaml, удаление xcuserdata, git push) делать параллельно для всех проектов
- **xcuserdata всегда удалять перед коммитом** — это персональные настройки Xcode (breakpoints, scheme management), не должны попадать в репу. Делать это автоматически без напоминания пользователя
- Старые значения из Ascendly могут отличаться если шаблон поменяется — сначала прочитать один yaml чтобы увидеть текущий шаблон
