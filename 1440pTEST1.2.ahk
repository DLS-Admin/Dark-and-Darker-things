#SingleInstance force
#Requires AutoHotkey v2.0+
#include SET YOUR OWN PATH\OCR.ahk ; https://github.com/Descolada/OCR
#include SET YOUR OWN PATH\Helper.ahk

; https://github.com/MonzterDev/AHK-Game-Scripts

F3::
{
    ocrResult := OCR.FromRect(1777, 187, 769, 1187, , scale:=1).Text  ; Scans Stash area in auction window for item

    rarity := GetItemRarity(ocrResult)
    itemName := GetItemName(ocrResult)

    if (itemName = "") {
        ToolTip("Item not found, try again.")
        SetTimer RemoveToolTip, -2000 ; Set timer to remove tooltip after 2 seconds
        return
    }

    enchantment := GetItemEnchantments(ocrResult)

    ; TODO
    ; We could use OCR for most of the following steps.

    ; Now we swap to view market tab
    MouseClick("Left", 1133, 153, ,) ; View Market button
    Sleep(500)

    MouseClick("Left", 2380, 267, ,) ; Reset Filters button
    Sleep(400)

    MouseClick("Left", 533, 267, , ) ; Click rarity selection
    Sleep(100)
    if (rarity = "Uncommon") {
        MouseClick("Left", 533, 433, , ) ; Click rarity
    } else if (rarity = "Common") {
        MouseClick("Left", 533, 399, , ) ; Click rarity
    } else if (rarity = "Rare") {
        MouseClick("Left", 533, 467, , ) ; Click rarity
    } else if (rarity = "Epic") {
        MouseClick("Left", 533, 500, , ) ; Click rarity
    } else if (rarity = "Legend") {
        MouseClick("Left", 533, 533, , ) ; Click rarity
    } else if (rarity = "Unique") {
        MouseClick("Left", 533, 567, , ) ; Click rarity
    }
    Sleep(100)

    MouseClick("Left", 200, 267, , ) ; Click item name selection
    Sleep(100)
    MouseClick("Left", 200, 333, , ) ; Click item name search box
    Sleep(200)
    Send(itemName) ; Type item name
    Sleep(100)
    MouseClick("Left", 200, 367, , ) ; Click item name
    Sleep(100)

    MouseClick("Left", 2000, 267, , ) ; Click random attributes
    Sleep(100)
    MouseClick("Left", 2000, 333, , ) ; Click enchantment name search box
    Sleep(250)
    Send("^a{BS}") ; Clear textbox
    Sleep(100)
    Send(enchantment) ; Type enchantment name
    Sleep(100)
    MouseClick("Left", 2000, 367, , ) ; Click enchantment name
    Sleep(100)
    MouseClick("Left", 2400, 367, , ) ; Click search
}

RemoveToolTip() {
    ToolTip  ; Remove the tooltip
}

GetItemRarity(ocrResult) {
    rarity := ""
    if InStr(ocrResult, "Uncommon") {
        rarity := "Uncommon"
    } else if InStr(ocrResult, "Common") {
        rarity := "Common"
    } else if InStr(ocrResult, "Rare") {
        rarity := "Rare"
    } else if InStr(ocrResult, "Epic") {
        rarity := "Epic"
    } else if InStr(ocrResult, "Legend") {
        rarity := "Legend"
    } else if InStr(ocrResult, "Unique") {
        rarity := "Unique"
    }

    return rarity
}

GetItemName(ocrResult) {
    itemName := ""
    ; TODO
    ; I tried using a while loop here because sometimes the OCR cannot detect the text.
    ; This didn't actually solve the issue. For now, just use hotkey again.
    while (itemName = "" && A_Index <= 3) {
        for i, item in ITEMS {
            if InStr(ocrResult, item) {
                itemName := item
                break
            }
        }

        if (itemName = "") {
            Sleep(100)
        }
    }

    return itemName
}

GetItemEnchantments(ocrResult) {
    ; Enchantments (Random Attributes) can be distinguished from the static attributes by the "+" sign and number on the left side of the enchantment name.
    ; For example, "+5 Magical Damage" is an enchantment, while "Magical Damage 5" is a static attribute.

    ; TODO
    ; This currently only finds the first enchantment. We need to find all enchantments.
    enchantmentsFound := []
    enchantment := ""

    for enchantmentI in ENCHANTMENTS {
        enchantmentRegex := "\+(\d+(?:\.\d+)?%?) " . enchantmentI
        if (matchPos := RegExMatch(ocrResult, enchantmentRegex, &matchObject)) {
            enchantmentValue := matchObject[1]
            enchantmentText := enchantmentValue . " " . enchantmentI
            enchantmentsFound.Push(enchantmentI)
        }
    }

    if (enchantmentsFound.Length > 0) {
        enchantmentsText := ""
        for index, enchantmentL in enchantmentsFound {
            enchantmentsText .= enchantmentL
            enchantment := enchantmentL
            if (index < enchantmentsFound.Length) {
                enchantmentsText .= ", "
            }
        }
        ; ToolTip(itemName . " " . rarity . " (" . enchantmentsText . ")") ; Easy debug
    }

    return enchantment
}
