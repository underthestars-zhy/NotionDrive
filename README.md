# NotionDrive

NotionDrive is a swift package that can upload files to Notion.so or download files from Notion.so.

## Prepare

To use NotionsDrive. You need have a **account** at Notion.so. And than create a root page and create a sub page in the root page. After this, open `Settings & Members`. Open the `Integrations` option, and click the `Develop your own integrations` button. Click `Create new integration` button.
Input a random name or other. Select a workspace that you have create a page recently. And add all `Content Capabilities`. Also select `Read user information including email addresses`. Back to the root page. Click `share`, and click `invie`, and choose the `integrations` that you created.
Open the sub page, repeat the opreations above.

## Start

1. Use `print(try await NotionDrive.getAllPages(token))` get all pages.
2. Find a `NotionSwift.Page` item whose name is the name of sub page.
3. Copy `7afbab54-72b5-4d7f-9939-d7f2d34e5bae` in the `id: ID<Page>:7afbab54-72b5-4d7f-9939-d7f2d34e5bae` of the item above (Just for a example)

## Create NotionDrive

```swift
father = The id that you got at Start (String)
token = The Integrations token (String)
let drive = NotionDrive(.init(father), token: token)
```

## Upload

I don't think uploading big files is a good choice.

```swift
data = The file's data (Data)
guard let uuid = try await drive.upload(data, name: UUID().uuidString) else { return }
```

You will use this uuid to donwload file.

## Download

Sometimes, you cannot download the file. Try again.

```swift
uuid = The uuid you saved at Upload (UUID)
let data = try await drive.download(uuid)
```
