
Annotate Root Item Path
=======================

![Last tested in Nuix 7.4](https://img.shields.io/badge/Nuix-7.4-green.svg)

View the GitHub project [here](https://github.com/NuixSDK/Annotate-Root-Item-Path) or download the latest release [here](https://github.com/NuixSDK/Annotate-Root-Item-Path/releases).

# Overview

**Written By:** Jason Wells

This script will iterate either all items in the case or the currently selected items, annotating an item path containing the top N items each item, optionally including the evidence container's name.

For example, imagine your case has an attachment to an email with the following item path:

```
Evidence 1/MailBox.pst/Top of Personal Folders/Inbox/Email/Attachment
```

With a depth setting of 3, with **Include Evidence Container** checked, the following would be recorded on the item:

```
Evidence 1/MailBox.pst/Top of Personal Folders
```

Without **Include Evidence Container** checked:

```
MailBox.pst/Top of Personal Folders/Inbox
```

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Settings

| Setting                        | Description                                                                            |
|--------------------------------|----------------------------------------------------------------------------------------|
| **Root Item Path Depth**       | How many items from the top of the item path to include.                               |
| **Include Evidence Container** | When checked the evidence container item will be included in the calculated path value. |
| **Custom Field Name**          | The name of the custom metadata field the value will be recorded to.                   |

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```